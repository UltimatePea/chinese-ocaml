(** 骆言词法分析器 - 工具函数模块（模块化重构） *)

(** 基础字符处理模块 *)
module BasicCharacterUtils = struct
  let is_chinese_char = Utf8_utils.is_chinese_char
  let is_letter_or_chinese = Utf8_utils.is_letter_or_chinese
  let is_digit = Utf8_utils.is_digit
  let is_whitespace = Utf8_utils.is_whitespace
  let is_separator_char = Utf8_utils.is_separator_char
  let is_chinese_utf8 = Utf8_utils.is_chinese_utf8
  let next_utf8_char = Utf8_utils.next_utf8_char_uutf
  let is_chinese_digit_char = Utf8_utils.is_chinese_digit_char
end

(** 向后兼容性别名 *)
let is_chinese_char = BasicCharacterUtils.is_chinese_char
let is_letter_or_chinese = BasicCharacterUtils.is_letter_or_chinese
let is_digit = BasicCharacterUtils.is_digit
let is_whitespace = BasicCharacterUtils.is_whitespace
let is_separator_char = BasicCharacterUtils.is_separator_char
let is_chinese_utf8 = BasicCharacterUtils.is_chinese_utf8
let next_utf8_char = BasicCharacterUtils.next_utf8_char
let is_chinese_digit_char = BasicCharacterUtils.is_chinese_digit_char

(** 字符串解析功能模块 *)
module StringParsingModule = struct
  (** 从指定位置开始读取字符串，直到满足停止条件 *)
  let read_string_until state start_pos stop_condition =
    let rec loop pos acc =
      if pos >= String.length state.Lexer_state.input then (String.concat "" (List.rev acc), pos)
      else
        let ch, next_pos = BasicCharacterUtils.next_utf8_char state.Lexer_state.input pos in
        if stop_condition ch then (String.concat "" (List.rev acc), pos) else loop next_pos (ch :: acc)
    in
    loop start_pos []

  (** 数值解析函数 *)
  let parse_integer str = try Some (int_of_string str) with Failure _ -> None
  let parse_float str = try Some (float_of_string str) with Failure _ -> None
  let parse_hex_int str = try Some (int_of_string ("0x" ^ str)) with Failure _ -> None
  let parse_oct_int str = try Some (int_of_string ("0o" ^ str)) with Failure _ -> None
  let parse_bin_int str = try Some (int_of_string ("0b" ^ str)) with Failure _ -> None
end

(** 向后兼容性接口 *)
let read_string_until = StringParsingModule.read_string_until
let parse_integer = StringParsingModule.parse_integer
let parse_float = StringParsingModule.parse_float
let parse_hex_int = StringParsingModule.parse_hex_int
let parse_oct_int = StringParsingModule.parse_oct_int
let parse_bin_int = StringParsingModule.parse_bin_int

(** 转义字符处理模块 *)
module EscapeProcessingModule = struct
  (** 转义字符处理 *)
  let process_escape_sequences str =
    let len = String.length str in
    let buf = Buffer.create len in
    let rec loop i =
      if i >= len then Buffer.contents buf
      else if str.[i] = '\\' && i + 1 < len then (
        match str.[i + 1] with
        | 'n' -> Buffer.add_char buf '\n'; loop (i + 2)
        | 't' -> Buffer.add_char buf '\t'; loop (i + 2)
        | 'r' -> Buffer.add_char buf '\r'; loop (i + 2)
        | '\\' -> Buffer.add_char buf '\\'; loop (i + 2)
        | '"' -> Buffer.add_char buf '"'; loop (i + 2)
        | '\'' -> Buffer.add_char buf '\''; loop (i + 2)
        | c -> Buffer.add_char buf '\\'; Buffer.add_char buf c; loop (i + 2))
      else (Buffer.add_char buf str.[i]; loop (i + 1))
    in
    loop 0
    
  let is_all_digits = Utf8_utils.is_all_digits
  let is_valid_identifier = Utf8_utils.is_valid_identifier
end

(** 向后兼容性接口 *)
let process_escape_sequences = EscapeProcessingModule.process_escape_sequences
let is_all_digits = EscapeProcessingModule.is_all_digits
let is_valid_identifier = EscapeProcessingModule.is_valid_identifier

(** 中文数字处理模块 *)
module ChineseNumberModule = struct
  (** 读取中文数字序列 *)
  let read_chinese_number_sequence state =
    let input = state.Lexer_state.input in
    let length = state.Lexer_state.length in
    let rec loop pos acc =
      if pos >= length then (acc, pos)
      else
        let ch, next_pos = BasicCharacterUtils.next_utf8_char input pos in
        if BasicCharacterUtils.is_chinese_digit_char ch then loop next_pos (acc ^ ch) else (acc, pos)
    in
    let sequence, new_pos = loop state.Lexer_state.position "" in
    let new_col = state.Lexer_state.current_column + (new_pos - state.Lexer_state.position) in
    (sequence, { state with position = new_pos; current_column = new_col })
end

(** 向后兼容性接口 *)
let read_chinese_number_sequence = ChineseNumberModule.read_chinese_number_sequence

(** 转换中文数字序列为数值 *)
(** 中文数字转换器模块 *)
module ChineseNumberConverter = struct
  (* 数字字符映射 *)
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

  (* 单位字符映射 *)
  let char_to_unit = function
    | "十" -> 10
    | "百" -> 100
    | "千" -> 1000
    | "万" -> 10000
    | "亿" -> 100000000
    | _ -> 1

  (* 将UTF-8字符串解析为中文字符列表 *)
  let rec utf8_to_char_list input pos chars =
    if pos >= String.length input then List.rev chars
    else
      let ch, next_pos = next_utf8_char input pos in
      if ch = "" then List.rev chars else utf8_to_char_list input next_pos (ch :: chars)

  (* 解析带单位的复杂数字 *)
  let rec parse_with_units chars acc current_num =
    match chars with
    | [] -> acc + current_num
    | ch :: rest ->
        if char_to_digit ch > 0 then
          (* 数字字符 *)
          parse_with_units rest acc (char_to_digit ch)
        else if ch = "零" then
          (* 零字符，继续处理 *)
          parse_with_units rest acc current_num
        else
          (* 单位字符 *)
          let unit = char_to_unit ch in
          if unit = 1 then
            (* 不是单位字符，当作数字处理 *)
            parse_with_units rest acc ((current_num * 10) + char_to_digit ch)
          else if unit >= 10000 then
            (* 万、亿等大单位 *)
            let section_value = if current_num = 0 then acc else acc + current_num in
            parse_with_units rest (section_value * unit) 0
          else
            (* 十、百、千等小单位 *)
            let digit = if current_num = 0 then 1 else current_num in
            parse_with_units rest (acc + (digit * unit)) 0

  (* 解析纯数字序列 *)
  let rec parse_simple_digits chars acc =
    match chars with
    | [] -> acc
    | ch :: rest ->
        let digit = char_to_digit ch in
        parse_simple_digits rest ((acc * 10) + digit)

  (* 解析中文数字字符列表 *)
  let parse_chinese_number chars =
    (* 检查是否包含单位字符 *)
    let has_units = List.exists (fun ch -> char_to_unit ch > 1) chars in
    if has_units then
      parse_with_units chars 0 0
    else
      parse_simple_digits chars 0

  (* 构造浮点数值 *)
  let construct_float_value int_val dec_val decimal_places =
    float_of_int int_val +. (float_of_int dec_val /. (10. ** float_of_int decimal_places))
end

let convert_chinese_number_sequence sequence =
  (* 分割整数部分和小数部分 *)
  let parts = Str.split (Str.regexp "点") sequence in
  match parts with
  | [ integer_part ] ->
      (* 只有整数部分 *)
      let chars = ChineseNumberConverter.utf8_to_char_list integer_part 0 [] in
      let int_val = ChineseNumberConverter.parse_chinese_number chars in
      Lexer_tokens.IntToken int_val
  | [ integer_part; decimal_part ] ->
      (* 有整数和小数部分 *)
      let int_chars = ChineseNumberConverter.utf8_to_char_list integer_part 0 [] in
      let dec_chars = ChineseNumberConverter.utf8_to_char_list decimal_part 0 [] in
      let int_val = ChineseNumberConverter.parse_chinese_number int_chars in
      let dec_val = ChineseNumberConverter.parse_chinese_number dec_chars in
      let decimal_places = List.length dec_chars in
      let float_val = ChineseNumberConverter.construct_float_value int_val dec_val decimal_places in
      Lexer_tokens.FloatToken float_val
  | _ ->
      (* 默认情况，应该不会到达这里 *)
      Lexer_tokens.IntToken 0

(** 全角数字处理模块 *)
module FullwidthNumberModule = struct
  let read_fullwidth_number_sequence state =
    let input = state.Lexer_state.input in
    let length = state.Lexer_state.length in
    let rec loop pos acc =
      if pos >= length then (acc, pos)
      else
        let ch, next_pos = BasicCharacterUtils.next_utf8_char input pos in
        if Utf8_utils.FullwidthDetection.is_fullwidth_digit_string ch then loop next_pos (acc ^ ch)
        else (acc, pos)
    in
    let sequence, new_pos = loop state.Lexer_state.position "" in
    let new_col = state.Lexer_state.current_column + ((new_pos - state.Lexer_state.position) / 3) in
    (sequence, { state with position = new_pos; current_column = new_col })

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
end

let read_fullwidth_number_sequence = FullwidthNumberModule.read_fullwidth_number_sequence
let convert_fullwidth_number_sequence = FullwidthNumberModule.convert_fullwidth_number_sequence

(** 中文标点符号识别模块 *)
module ChinesePunctuationModule = struct
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

(* 全角符号检查辅助函数 *)
let check_fullwidth_symbol state byte3 =
  check_utf8_char state Constants.UTF8.fullwidth_start_byte1 Constants.UTF8.fullwidth_start_byte2 byte3

(* 全角数字检查辅助函数 *)
let is_fullwidth_digit state =
  state.Lexer_state.position + Constants.Numbers.one < state.Lexer_state.length
  && Char.code state.Lexer_state.input.[state.Lexer_state.position + Constants.Numbers.one]
     = Constants.UTF8.fullwidth_start_byte2
  && state.Lexer_state.position + Constants.Numbers.two < state.Lexer_state.length
  && let third_byte = Char.code state.Lexer_state.input.[state.Lexer_state.position + Constants.Numbers.two] in
     third_byte >= Constants.UTF8.fullwidth_digit_start && third_byte <= Constants.UTF8.fullwidth_digit_end

(* 处理双冒号的特殊逻辑 *)
let handle_colon_sequence state pos =
  let state_after_first_colon = make_new_state state in
  if state_after_first_colon.Lexer_state.position + Constants.Numbers.two < state_after_first_colon.Lexer_state.length
     && check_fullwidth_symbol state_after_first_colon Constants.UTF8.fullwidth_colon_byte3
  then
    let final_state = make_new_state state_after_first_colon in
    Some (Lexer_tokens.ChineseDoubleColon, pos, final_state)
  else
    Some (Lexer_tokens.ChineseColon, pos, state_after_first_colon)

(* 处理全角符号（0xEF开头）*)
let handle_fullwidth_symbols state pos =
  if check_fullwidth_symbol state Constants.UTF8.fullwidth_left_paren_byte3 then
    Some (Lexer_tokens.ChineseLeftParen, pos, make_new_state state)
  else if check_fullwidth_symbol state Constants.UTF8.fullwidth_right_paren_byte3 then
    Some (Lexer_tokens.ChineseRightParen, pos, make_new_state state)
  else if check_fullwidth_symbol state Constants.UTF8.fullwidth_comma_byte3 then
    Some (Lexer_tokens.ChineseComma, pos, make_new_state state)
  else if check_fullwidth_symbol state Constants.UTF8.fullwidth_colon_byte3 then
    handle_colon_sequence state pos
  else if check_fullwidth_symbol state Constants.UTF8.fullwidth_semicolon_byte3
       || check_utf8_char state Constants.UTF8.fullwidth_pipe_byte1 Constants.UTF8.fullwidth_pipe_byte2 Constants.UTF8.fullwidth_pipe_byte3
       || check_fullwidth_symbol state Constants.UTF8.fullwidth_period_byte3 then
    create_unsupported_char_error state pos
  else if is_fullwidth_digit state then
    None
  else
    create_unsupported_char_error state pos

(* 中文标点符号检查辅助函数 *)
let check_chinese_punctuation state byte1 byte2 byte3 =
  check_utf8_char state byte1 byte2 byte3

(* 处理中文标点符号（0xE3开头）*)
let handle_chinese_punctuation state pos =
  if check_chinese_punctuation state Constants.UTF8.left_quote_byte1 Constants.UTF8.left_quote_byte2 Constants.UTF8.left_quote_byte3
     || check_chinese_punctuation state Constants.UTF8.right_quote_byte1 Constants.UTF8.right_quote_byte2 Constants.UTF8.right_quote_byte3
     || check_chinese_punctuation state Constants.UTF8.string_start_byte1 Constants.UTF8.string_start_byte2 Constants.UTF8.string_start_byte3
     || check_chinese_punctuation state Constants.UTF8.string_end_byte1 Constants.UTF8.string_end_byte2 Constants.UTF8.string_end_byte3 then
    None
  else if check_chinese_punctuation state Constants.UTF8.chinese_period_byte1 Constants.UTF8.chinese_period_byte2 Constants.UTF8.chinese_period_byte3 then
    Some (Lexer_tokens.Dot, pos, make_new_state state)
  else
    create_unsupported_char_error state pos

(* 处理中文操作符（0xE8开头）*)
let handle_chinese_operators state pos =
  if check_chinese_punctuation state Constants.UTF8.chinese_minus_byte1 Constants.UTF8.chinese_minus_byte2 Constants.UTF8.chinese_minus_byte3 then
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

  let recognize_pipe_right_bracket _state _pos =
    (* 问题105禁用所有非指定符号，包括｜ *)
    None
end

(** 向后兼容性接口 *)
let recognize_chinese_punctuation = ChinesePunctuationModule.recognize_chinese_punctuation
let recognize_pipe_right_bracket = ChinesePunctuationModule.recognize_pipe_right_bracket
