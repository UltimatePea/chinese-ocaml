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
  | "一" | "二" | "三" | "四" | "五" | "六" | "七" | "八" | "九" | "零" | "十" | "百" | "千" | "万" | "亿" | "点" ->
      true
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

  let char_to_unit = function
    | "十" -> 10
    | "百" -> 100
    | "千" -> 1000
    | "万" -> 10000
    | "亿" -> 100000000
    | _ -> 1
  in

  (* 将UTF-8字符串解析为中文字符列表 *)
  let rec utf8_to_char_list input pos chars =
    if pos >= String.length input then List.rev chars
    else
      let ch, next_pos = next_utf8_char input pos in
      if ch = "" then List.rev chars else utf8_to_char_list input next_pos (ch :: chars)
  in

  let parse_chinese_number chars =
    (* 检查是否包含单位字符 *)
    let has_units = List.exists (fun ch -> char_to_unit ch > 1) chars in

    if has_units then
      (* 包含单位的数字，使用复杂算法 *)
      let rec parse_group chars acc current_num =
        match chars with
        | [] -> acc + current_num
        | ch :: rest ->
            if char_to_digit ch > 0 then
              (* 数字字符 *)
              parse_group rest acc (char_to_digit ch)
            else if ch = "零" then
              (* 零字符，继续处理 *)
              parse_group rest acc current_num
            else
              (* 单位字符 *)
              let unit = char_to_unit ch in
              if unit = 1 then
                (* 不是单位字符，当作数字处理 *)
                parse_group rest acc ((current_num * 10) + char_to_digit ch)
              else if unit >= 10000 then
                (* 万、亿等大单位 *)
                let section_value = if current_num = 0 then acc else acc + current_num in
                parse_group rest (section_value * unit) 0
              else
                (* 十、百、千等小单位 *)
                let digit = if current_num = 0 then 1 else current_num in
                parse_group rest (acc + (digit * unit)) 0
      in
      parse_group chars 0 0
    else
      (* 纯数字序列，使用简单算法（兼容原有测试） *)
      let rec parse_simple chars acc =
        match chars with
        | [] -> acc
        | ch :: rest ->
            let digit = char_to_digit ch in
            parse_simple rest ((acc * 10) + digit)
      in
      parse_simple chars 0
  in

  (* 分割整数部分和小数部分 *)
  let parts = Str.split (Str.regexp "点") sequence in
  match parts with
  | [ integer_part ] ->
      (* 只有整数部分 *)
      let chars = utf8_to_char_list integer_part 0 [] in
      let int_val = parse_chinese_number chars in
      Lexer_tokens.IntToken int_val
  | [ integer_part; decimal_part ] ->
      (* 有整数和小数部分 *)
      let int_chars = utf8_to_char_list integer_part 0 [] in
      let dec_chars = utf8_to_char_list decimal_part 0 [] in
      let int_val = parse_chinese_number int_chars in
      let dec_val = parse_chinese_number dec_chars in
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
      if Utf8_utils.FullwidthDetection.is_fullwidth_digit_string ch then loop next_pos (acc ^ ch)
      else (acc, pos)
  in
  let sequence, new_pos = loop state.Lexer_state.position "" in
  let new_col = state.Lexer_state.current_column + ((new_pos - state.Lexer_state.position) / 3) in
  (* 每个全角字符3字节但占1列 *)
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
(* 通用辅助函数 *)
let get_current_char state =
  if state.Lexer_state.position >= state.Lexer_state.length then None
  else Some state.Lexer_state.input.[state.Lexer_state.position]

let check_utf8_char state _byte1 byte2 byte3 =
  state.Lexer_state.position + 2 < state.Lexer_state.length
  && Char.code state.Lexer_state.input.[state.Lexer_state.position + 1] = byte2
  && Char.code state.Lexer_state.input.[state.Lexer_state.position + 2] = byte3

let make_new_state state =
  {
    state with
    Lexer_state.position = state.Lexer_state.position + 3;
    current_column = state.Lexer_state.current_column + 1;
  }

let create_unsupported_char_error state pos =
  let char_bytes =
    String.sub state.Lexer_state.input state.Lexer_state.position
      Constants.SystemConfig.string_slice_length
  in
  raise (Lexer_tokens.LexError (Constants.ErrorMessages.unsupported_char_error char_bytes, pos))

(* 处理全角符号（0xEF开头）*)
let handle_fullwidth_symbols state pos =
  if
    check_utf8_char state Constants.UTF8.fullwidth_start_byte1 Constants.UTF8.fullwidth_start_byte2
      Constants.UTF8.fullwidth_left_paren_byte3
  then
    (* （ (U+FF08) - 保留 *)
    Some (Lexer_tokens.ChineseLeftParen, pos, make_new_state state)
  else if
    check_utf8_char state Constants.UTF8.fullwidth_start_byte1 Constants.UTF8.fullwidth_start_byte2
      Constants.UTF8.fullwidth_right_paren_byte3
  then
    (* ） (U+FF09) - 保留 *)
    Some (Lexer_tokens.ChineseRightParen, pos, make_new_state state)
  else if
    check_utf8_char state Constants.UTF8.fullwidth_start_byte1 Constants.UTF8.fullwidth_start_byte2
      Constants.UTF8.fullwidth_comma_byte3
  then
    (* ， (U+FF0C) - 保留 *)
    Some (Lexer_tokens.ChineseComma, pos, make_new_state state)
  else if
    check_utf8_char state Constants.UTF8.fullwidth_start_byte1 Constants.UTF8.fullwidth_start_byte2
      Constants.UTF8.fullwidth_semicolon_byte3
  then
    (* ； (U+FF1B) - 问题105禁用，只支持「」『』：，。（） *)
    create_unsupported_char_error state pos
  else if
    check_utf8_char state Constants.UTF8.fullwidth_start_byte1 Constants.UTF8.fullwidth_start_byte2
      Constants.UTF8.fullwidth_colon_byte3
  then
    (* ： (U+FF1A) - 检查是否为双冒号 *)
    let state_after_first_colon = make_new_state state in
    if
      state_after_first_colon.Lexer_state.position + Constants.Numbers.two
      < state_after_first_colon.Lexer_state.length
      && check_utf8_char state_after_first_colon Constants.UTF8.fullwidth_start_byte1
           Constants.UTF8.fullwidth_start_byte2 Constants.UTF8.fullwidth_colon_byte3
    then
      (* ：： - 双冒号 *)
      let final_state = make_new_state state_after_first_colon in
      Some (Lexer_tokens.ChineseDoubleColon, pos, final_state)
    else
      (* 单冒号 *)
      Some (Lexer_tokens.ChineseColon, pos, state_after_first_colon)
  else if
    check_utf8_char state Constants.UTF8.fullwidth_pipe_byte1 Constants.UTF8.fullwidth_pipe_byte2
      Constants.UTF8.fullwidth_pipe_byte3
  then
    (* ｜ (U+FF5C) - 问题105禁用，只支持「」『』：，。（） *)
    create_unsupported_char_error state pos
  else if
    check_utf8_char state Constants.UTF8.fullwidth_start_byte1 Constants.UTF8.fullwidth_start_byte2
      Constants.UTF8.fullwidth_period_byte3
  then
    (* ． (U+FF0E) - 全宽句号，但问题105要求中文句号 *)
    create_unsupported_char_error state pos
  else if
    state.Lexer_state.position + Constants.Numbers.one < state.Lexer_state.length
    && Char.code state.Lexer_state.input.[state.Lexer_state.position + Constants.Numbers.one]
       = Constants.UTF8.fullwidth_start_byte2
    && state.Lexer_state.position + Constants.Numbers.two < state.Lexer_state.length
    &&
    let third_byte =
      Char.code state.Lexer_state.input.[state.Lexer_state.position + Constants.Numbers.two]
    in
    third_byte >= Constants.UTF8.fullwidth_digit_start
    && third_byte <= Constants.UTF8.fullwidth_digit_end
  then
    (* 全角数字 ０-９ (U+FF10-U+FF19) - 现在允许，返回None让主词法分析器处理 *)
    None
  else
    (* 其他全角符号已禁用 *)
    create_unsupported_char_error state pos

(* 处理中文标点符号（0xE3开头）*)
let handle_chinese_punctuation state pos =
  if
    check_utf8_char state Constants.UTF8.left_quote_byte1 Constants.UTF8.left_quote_byte2
      Constants.UTF8.left_quote_byte3
  then
    (* 「 (U+300C) - 保留，用于引用标识符 *)
    None (* 在主函数中专门处理 *)
  else if
    check_utf8_char state Constants.UTF8.right_quote_byte1 Constants.UTF8.right_quote_byte2
      Constants.UTF8.right_quote_byte3
  then
    (* 」 (U+300D) - 保留，用于引用标识符 *)
    None (* 在主函数中专门处理 *)
  else if
    check_utf8_char state Constants.UTF8.string_start_byte1 Constants.UTF8.string_start_byte2
      Constants.UTF8.string_start_byte3
  then
    (* 『 (U+300E) - 保留，用于字符串字面量 *)
    None (* 在主函数中专门处理 *)
  else if
    check_utf8_char state Constants.UTF8.string_end_byte1 Constants.UTF8.string_end_byte2
      Constants.UTF8.string_end_byte3
  then
    (* 』 (U+300F) - 保留，用于字符串字面量 *)
    None (* 在主函数中专门处理 *)
  else if
    check_utf8_char state Constants.UTF8.chinese_period_byte1 Constants.UTF8.chinese_period_byte2
      Constants.UTF8.chinese_period_byte3
  then
    (* 。 (U+3002) - 中文句号，保留 *)
    Some (Lexer_tokens.Dot, pos, make_new_state state)
  else
    (* 其他中文标点符号已禁用 *)
    create_unsupported_char_error state pos

(* 处理中文操作符（0xE8开头）*)
let handle_chinese_operators state pos =
  if
    check_utf8_char state Constants.UTF8.chinese_minus_byte1 Constants.UTF8.chinese_minus_byte2
      Constants.UTF8.chinese_minus_byte3
  then
    (* 负 (U+8D1F) - 作为负号操作符 *)
    Some (Lexer_tokens.Minus, pos, make_new_state state)
  else None

(* 处理不支持的符号（0xE2开头）*)
let handle_unsupported_symbols state pos =
  (* 箭头符号范围 - 全部禁用 *)
  create_unsupported_char_error state pos

(* 主函数 - 重构后的recognize_chinese_punctuation *)
let recognize_chinese_punctuation state pos =
  match get_current_char state with
  | Some c when Constants.UTF8.is_fullwidth_prefix (Char.code c) ->
      (* 全角符号范围 - 支持HEAD分支的功能，保持Issue #105的符号限制 *)
      handle_fullwidth_symbols state pos
  | Some c when Constants.UTF8.is_chinese_punctuation_prefix (Char.code c) ->
      (* 中文标点符号范围 - 仅支持「」『』 *)
      handle_chinese_punctuation state pos
  | Some c when Constants.UTF8.is_chinese_operator_prefix (Char.code c) ->
      (* 处理汉字字符 - 支持负号 *)
      handle_chinese_operators state pos
  | Some c when Constants.UTF8.is_arrow_symbol_prefix (Char.code c) ->
      (* 箭头符号范围 - 全部禁用 *)
      handle_unsupported_symbols state pos
  | _ -> None

(** 问题105: ｜符号已禁用，数组符号不再支持 *)
let recognize_pipe_right_bracket _state _pos =
  (* 问题105禁用所有非指定符号，包括｜ *)
  None
