(** 骆言词法分析器 - 工具函数模块 *)

(** 是否为中文字符 *)
let is_chinese_char c =
  let code = Char.code c in
  (* CJK Unified Ideographs range: U+4E00-U+9FFF *)
  (* But for UTF-8 bytes, we need to check differently *)
  code >= Constants.UTF8.chinese_char_start
  || (code >= Constants.UTF8.chinese_char_mid_start && code <= Constants.UTF8.chinese_char_mid_end)

(** 是否为字母或中文 *)
let is_letter_or_chinese c = (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || is_chinese_char c

(** 是否为数字 *)
let is_digit c = c >= '0' && c <= '9'

(** 是否为空白字符 - 空格仍需跳过，但不用于关键字消歧 *)
let is_whitespace c = c = ' ' || c = '\t' || c = '\r'

(** 是否为分隔符字符 - 用于关键字边界检查（不包括空格） *)
let is_separator_char c = c = '\t' || c = '\r' || c = '\n'

(** 判断一个UTF-8字符串是否为中文字符（CJK Unified Ideographs） *)
let is_chinese_utf8 s =
  match Uutf.decode (Uutf.decoder (`String s)) with
  | `Uchar u ->
      let code = Uchar.to_int u in
      code >= 0x4E00 && code <= 0x9FFF
  | _ -> false

(** 读取下一个UTF-8字符，返回字符和新位置 *)
let next_utf8_char input pos =
  let dec = Uutf.decoder (`String (String.sub input pos (String.length input - pos))) in
  match Uutf.decode dec with
  | `Uchar u ->
      let buf = Buffer.create 8 in
      Uutf.Buffer.add_utf_8 buf u;
      let s = Buffer.contents buf in
      let len = Bytes.length (Bytes.of_string s) in
      (s, pos + len)
  | _ -> ("", pos)

(** 是否为中文数字字符 *)
let is_chinese_digit_char ch =
  match ch with
  | "一" | "二" | "三" | "四" | "五" | "六" | "七" | "八" | "九" | "十" | "零" | "点" -> true
  | _ -> false

(** 从指定位置开始读取字符串，直到满足停止条件 *)
let read_string_until state start_pos stop_condition =
  let rec loop pos acc =
    if pos >= String.length state.Lexer_state.input then (String.concat "" (List.rev acc), pos)
    else
      let ch, next_pos = next_utf8_char state.Lexer_state.input pos in
      if stop_condition ch then (String.concat "" (List.rev acc), pos) else loop next_pos (ch :: acc)
  in
  loop start_pos []

(** 解析整数 *)
let parse_integer str = try Some (int_of_string str) with Failure _ -> None

(** 解析浮点数 *)
let parse_float str = try Some (float_of_string str) with Failure _ -> None

(** 解析十六进制数 *)
let parse_hex_int str = try Some (int_of_string ("0x" ^ str)) with Failure _ -> None

(** 解析八进制数 *)
let parse_oct_int str = try Some (int_of_string ("0o" ^ str)) with Failure _ -> None

(** 解析二进制数 *)
let parse_bin_int str = try Some (int_of_string ("0b" ^ str)) with Failure _ -> None

(** 转义字符处理 *)
let process_escape_sequences str =
  let len = String.length str in
  let buf = Buffer.create len in
  let rec loop i =
    if i >= len then Buffer.contents buf
    else if str.[i] = '\\' && i + 1 < len then (
      match str.[i + 1] with
      | 'n' ->
          Buffer.add_char buf '\n';
          loop (i + 2)
      | 't' ->
          Buffer.add_char buf '\t';
          loop (i + 2)
      | 'r' ->
          Buffer.add_char buf '\r';
          loop (i + 2)
      | '\\' ->
          Buffer.add_char buf '\\';
          loop (i + 2)
      | '"' ->
          Buffer.add_char buf '"';
          loop (i + 2)
      | '\'' ->
          Buffer.add_char buf '\'';
          loop (i + 2)
      | c ->
          Buffer.add_char buf '\\';
          Buffer.add_char buf c;
          loop (i + 2))
    else (
      Buffer.add_char buf str.[i];
      loop (i + 1))
  in
  loop 0

(** 检查字符串是否只包含数字 *)
let is_all_digits str =
  let len = String.length str in
  let rec check i = if i >= len then true else if is_digit str.[i] then check (i + 1) else false in
  len > 0 && check 0

(** 检查字符串是否只包含字母、数字和下划线 *)
let is_valid_identifier str =
  let len = String.length str in
  let rec check i =
    if i >= len then true
    else
      let c = str.[i] in
      if is_letter_or_chinese c || is_digit c || c = '_' then check (i + 1) else false
  in
  len > 0 && check 0

(** 读取中文数字序列 *)
let read_chinese_number_sequence state =
  let input = state.Lexer_state.input in
  let length = state.Lexer_state.length in
  let rec loop pos acc =
    if pos >= length then (acc, pos)
    else
      let ch, next_pos = next_utf8_char input pos in
      if is_chinese_digit_char ch then loop next_pos (acc ^ ch) else (acc, pos)
  in
  let sequence, new_pos = loop state.Lexer_state.position "" in
  let new_col = state.Lexer_state.current_column + (new_pos - state.Lexer_state.position) in
  (sequence, { state with position = new_pos; current_column = new_col })

(** 转换中文数字序列为数值 *)
let convert_chinese_number_sequence sequence =
  let char_to_digit = function
    | "一" -> 1
    | "二" -> 2
    | "三" -> 3
    | "四" -> 4
    | "五" -> 5
    | "六" -> 6
    | "七" -> 7
    | "八" -> 8
    | "九" -> 9
    | "零" -> 0
    | _ -> 0
  in

  (* 将UTF-8字符串解析为中文字符列表 *)
  let rec utf8_to_char_list input pos chars =
    if pos >= String.length input then List.rev chars
    else
      let ch, next_pos = next_utf8_char input pos in
      if ch = "" then List.rev chars else utf8_to_char_list input next_pos (ch :: chars)
  in

  let rec parse_chars chars acc =
    match chars with
    | [] -> acc
    | ch :: rest ->
        let digit = char_to_digit ch in
        parse_chars rest ((acc * 10) + digit)
  in

  (* 分割整数部分和小数部分 *)
  let parts = Str.split (Str.regexp "点") sequence in
  match parts with
  | [ integer_part ] ->
      (* 只有整数部分 *)
      let chars = utf8_to_char_list integer_part 0 [] in
      let int_val = parse_chars chars 0 in
      Lexer_tokens.IntToken int_val
  | [ integer_part; decimal_part ] ->
      (* 有整数和小数部分 *)
      let int_chars = utf8_to_char_list integer_part 0 [] in
      let dec_chars = utf8_to_char_list decimal_part 0 [] in
      let int_val = parse_chars int_chars 0 in
      let dec_val = parse_chars dec_chars 0 in
      let decimal_places = List.length dec_chars in
      let float_val =
        float_of_int int_val +. (float_of_int dec_val /. (10. ** float_of_int decimal_places))
      in
      Lexer_tokens.FloatToken float_val
  | _ ->
      (* 默认情况，应该不会到达这里 *)
      Lexer_tokens.IntToken 0

(** 读取全角数字序列 *)
let read_fullwidth_number_sequence state =
  let input = state.Lexer_state.input in
  let length = state.Lexer_state.length in
  let rec loop pos acc =
    if pos >= length then (acc, pos)
    else
      let ch, next_pos = next_utf8_char input pos in
      if Utf8_utils.FullwidthDetection.is_fullwidth_digit_string ch then 
        loop next_pos (acc ^ ch) 
      else (acc, pos)
  in
  let sequence, new_pos = loop state.Lexer_state.position "" in
  let new_col = state.Lexer_state.current_column + ((new_pos - state.Lexer_state.position) / 3) in (* 每个全角字符3字节但占1列 *)
  (sequence, { state with position = new_pos; current_column = new_col })

(** 转换全角数字序列为数值 *)
let convert_fullwidth_number_sequence sequence =
  let rec loop pos acc =
    if pos >= String.length sequence then acc
    else if pos + 2 < String.length sequence then
      let ch = String.sub sequence pos 3 in
      match Utf8_utils.FullwidthDetection.fullwidth_digit_to_int ch with
      | Some digit -> loop (pos + 3) ((acc * 10) + digit)
      | None -> acc
    else acc
  in
  let int_val = loop 0 0 in
  Lexer_tokens.IntToken int_val

(* 识别中文标点符号 - 问题105: 仅支持「」『』：，。（） *)
let recognize_chinese_punctuation state pos =
  let current_char state =
    if state.Lexer_state.position >= state.Lexer_state.length then None
    else Some state.Lexer_state.input.[state.Lexer_state.position]
  in
  let check_utf8_char state _byte1 byte2 byte3 =
    state.Lexer_state.position + 2 < state.Lexer_state.length
    && Char.code state.Lexer_state.input.[state.Lexer_state.position + 1] = byte2
    && Char.code state.Lexer_state.input.[state.Lexer_state.position + 2] = byte3
  in
  match current_char state with
  | Some c when Char.code c = 0xEF ->
      (* 全角符号范围 - 支持HEAD分支的功能，保持Issue #105的符号限制 *)
      if check_utf8_char state 0xEF 0xBC 0x88 then
        (* （ (U+FF08) - 保留 *)
        let new_state =
          { state with position = state.position + 3; current_column = state.current_column + 1 }
        in
        Some (Lexer_tokens.ChineseLeftParen, pos, new_state)
      else if check_utf8_char state 0xEF 0xBC 0x89 then
        (* ） (U+FF09) - 保留 *)
        let new_state =
          { state with position = state.position + 3; current_column = state.current_column + 1 }
        in
        Some (Lexer_tokens.ChineseRightParen, pos, new_state)
      else if check_utf8_char state 0xEF 0xBC 0x8C then
        (* ， (U+FF0C) - 保留 *)
        let new_state =
          { state with position = state.position + 3; current_column = state.current_column + 1 }
        in
        Some (Lexer_tokens.ChineseComma, pos, new_state)
      else if check_utf8_char state 0xEF 0xBC 0x9B then
        (* ； (U+FF1B) - 问题105禁用，只支持「」『』：，。（） *)
        let char_bytes = String.sub state.input state.position 3 in
        raise (Lexer_tokens.LexError ("非支持的中文符号已禁用，只支持「」『』：，。（）。禁用符号: " ^ char_bytes, pos))
      else if check_utf8_char state 0xEF 0xBC 0x9A then
        (* ： (U+FF1A) - 检查是否为双冒号 *)
        let state_after_first_colon =
          { state with position = state.position + 3; current_column = state.current_column + 1 }
        in
        if
          state_after_first_colon.position + 2 < state_after_first_colon.length
          && check_utf8_char state_after_first_colon 0xEF 0xBC 0x9A
        then
          (* ：： - 双冒号 *)
          let final_state =
            {
              state_after_first_colon with
              position = state_after_first_colon.position + 3;
              current_column = state_after_first_colon.current_column + 1;
            }
          in
          Some (Lexer_tokens.ChineseDoubleColon, pos, final_state)
        else
          (* 单冒号 *)
          Some (Lexer_tokens.ChineseColon, pos, state_after_first_colon)
      else if check_utf8_char state 0xEF 0xBD 0x9C then
        (* ｜ (U+FF5C) - 问题105禁用，只支持「」『』：，。（） *)
        let char_bytes = String.sub state.input state.position 3 in
        raise (Lexer_tokens.LexError ("非支持的中文符号已禁用，只支持「」『』：，。（）。禁用符号: " ^ char_bytes, pos))
      else if check_utf8_char state 0xEF 0xBC 0x8E then
        (* ． (U+FF0E) - 全宽句号，但问题105要求中文句号 *)
        let char_bytes = String.sub state.input state.position 3 in
        raise (Lexer_tokens.LexError ("非支持的中文符号已禁用，只支持「」『』：，。（）。禁用符号: " ^ char_bytes, pos))
      else if
        state.position + 1 < state.length
        && Char.code state.input.[state.position + 1] = 0xBC
        && state.position + 2 < state.length
        && let third_byte = Char.code state.input.[state.position + 2] in
           third_byte >= 0x90 && third_byte <= 0x99
      then
        (* 全角数字 ０-９ (U+FF10-U+FF19) - 现在允许，返回None让主词法分析器处理 *)
        None
      else
        (* 其他全角符号已禁用 *)
        let char_bytes = String.sub state.input state.position 3 in
        raise (Lexer_tokens.LexError ("非支持的中文符号已禁用，只支持「」『』：，。（）。禁用符号: " ^ char_bytes, pos))
  | Some c when Char.code c = 0xE3 ->
      (* 中文标点符号范围 - 仅支持「」『』 *)
      if check_utf8_char state 0xE3 0x80 0x8C then
        (* 「 (U+300C) - 保留，用于引用标识符 *)
        None (* 在主函数中专门处理 *)
      else if check_utf8_char state 0xE3 0x80 0x8D then
        (* 」 (U+300D) - 保留，用于引用标识符 *)
        None (* 在主函数中专门处理 *)
      else if check_utf8_char state 0xE3 0x80 0x8E then
        (* 『 (U+300E) - 保留，用于字符串字面量 *)
        None (* 在主函数中专门处理 *)
      else if check_utf8_char state 0xE3 0x80 0x8F then
        (* 』 (U+300F) - 保留，用于字符串字面量 *)
        None (* 在主函数中专门处理 *)
      else if check_utf8_char state 0xE3 0x80 0x82 then
        (* 。 (U+3002) - 中文句号，保留 *)
        let new_state =
          { state with position = state.position + 3; current_column = state.current_column + 1 }
        in
        Some (Lexer_tokens.Dot, pos, new_state)
      else
        (* 其他中文标点符号已禁用 *)
        let char_bytes = String.sub state.input state.position 3 in
        raise (Lexer_tokens.LexError ("非支持的中文符号已禁用，只支持「」『』：，。（）。禁用符号: " ^ char_bytes, pos))
  | Some c when Char.code c = 0xE2 ->
      (* 箭头符号范围 - 全部禁用 *)
      let char_bytes = String.sub state.input state.position 3 in
      raise (Lexer_tokens.LexError ("非支持的中文符号已禁用，只支持「」：，。（）。禁用符号: " ^ char_bytes, pos))
  | _ -> None

(** 问题105: ｜符号已禁用，数组符号不再支持 *)
let recognize_pipe_right_bracket _state _pos =
  (* 问题105禁用所有非指定符号，包括｜ *)
  None
