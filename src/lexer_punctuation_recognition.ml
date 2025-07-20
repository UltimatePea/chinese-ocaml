(** 骆言词法分析器 - 中文标点符号识别模块 *)

open Lexer_state

(** 全角符号检查辅助函数 *)
let check_fullwidth_symbol state byte3 =
  Lexer_char_processing.check_utf8_char state Constants.UTF8.fullwidth_start_byte1 Constants.UTF8.fullwidth_start_byte2 byte3

(** 全角数字检查辅助函数 *)
let is_fullwidth_digit state =
  state.position + Constants.Numbers.one < state.length
  && Char.code state.input.[state.position + Constants.Numbers.one]
     = Constants.UTF8.fullwidth_start_byte2
  && state.position + Constants.Numbers.two < state.length
  && let third_byte = Char.code state.input.[state.position + Constants.Numbers.two] in
     third_byte >= Constants.UTF8.fullwidth_digit_start && third_byte <= Constants.UTF8.fullwidth_digit_end

(** 处理双冒号的特殊逻辑 *)
let handle_colon_sequence state pos =
  let state_after_first_colon = Lexer_char_processing.make_new_state state in
  if state_after_first_colon.position + Constants.Numbers.two < state_after_first_colon.length
     && check_fullwidth_symbol state_after_first_colon Constants.UTF8.fullwidth_colon_byte3
  then
    let final_state = Lexer_char_processing.make_new_state state_after_first_colon in
    Some (Lexer_tokens.ChineseDoubleColon, pos, final_state)
  else
    Some (Lexer_tokens.ChineseColon, pos, state_after_first_colon)

(** 处理全角符号（0xEF开头）*)
let handle_fullwidth_symbols state pos =
  if check_fullwidth_symbol state Constants.UTF8.fullwidth_left_paren_byte3 then
    Some (Lexer_tokens.ChineseLeftParen, pos, Lexer_char_processing.make_new_state state)
  else if check_fullwidth_symbol state Constants.UTF8.fullwidth_right_paren_byte3 then
    Some (Lexer_tokens.ChineseRightParen, pos, Lexer_char_processing.make_new_state state)
  else if check_fullwidth_symbol state Constants.UTF8.fullwidth_comma_byte3 then
    Some (Lexer_tokens.ChineseComma, pos, Lexer_char_processing.make_new_state state)
  else if check_fullwidth_symbol state Constants.UTF8.fullwidth_colon_byte3 then
    handle_colon_sequence state pos
  else if check_fullwidth_symbol state Constants.UTF8.fullwidth_semicolon_byte3 then
    Some (Lexer_tokens.ChineseSemicolon, pos, Lexer_char_processing.make_new_state state)
  else if Lexer_char_processing.check_utf8_char state Constants.UTF8.fullwidth_pipe_byte1 Constants.UTF8.fullwidth_pipe_byte2 Constants.UTF8.fullwidth_pipe_byte3 then
    Some (Lexer_tokens.ChinesePipe, pos, Lexer_char_processing.make_new_state state)
  else if check_fullwidth_symbol state Constants.UTF8.fullwidth_period_byte3 then
    Lexer_char_processing.create_unsupported_char_error state pos
  else if is_fullwidth_digit state then
    None
  else
    Lexer_char_processing.create_unsupported_char_error state pos

(** 中文标点符号检查辅助函数 *)
let check_chinese_punctuation state byte1 byte2 byte3 =
  Lexer_char_processing.check_utf8_char state byte1 byte2 byte3

(** 处理中文标点符号（0xE3开头）*)
let handle_chinese_punctuation state pos =
  if check_chinese_punctuation state Constants.UTF8.left_quote_byte1 Constants.UTF8.left_quote_byte2 Constants.UTF8.left_quote_byte3
     || check_chinese_punctuation state Constants.UTF8.right_quote_byte1 Constants.UTF8.right_quote_byte2 Constants.UTF8.right_quote_byte3
     || check_chinese_punctuation state Constants.UTF8.string_start_byte1 Constants.UTF8.string_start_byte2 Constants.UTF8.string_start_byte3
     || check_chinese_punctuation state Constants.UTF8.string_end_byte1 Constants.UTF8.string_end_byte2 Constants.UTF8.string_end_byte3 then
    None
  else if check_chinese_punctuation state Constants.UTF8.chinese_period_byte1 Constants.UTF8.chinese_period_byte2 Constants.UTF8.chinese_period_byte3 then
    Some (Lexer_tokens.Dot, pos, Lexer_char_processing.make_new_state state)
  else if check_chinese_punctuation state Constants.UTF8.chinese_square_left_bracket_byte1 Constants.UTF8.chinese_square_left_bracket_byte2 Constants.UTF8.chinese_square_left_bracket_byte3 then
    Some (Lexer_tokens.ChineseSquareLeftBracket, pos, Lexer_char_processing.make_new_state state)
  else if check_chinese_punctuation state Constants.UTF8.chinese_square_right_bracket_byte1 Constants.UTF8.chinese_square_right_bracket_byte2 Constants.UTF8.chinese_square_right_bracket_byte3 then
    Some (Lexer_tokens.ChineseSquareRightBracket, pos, Lexer_char_processing.make_new_state state)
  else
    Lexer_char_processing.create_unsupported_char_error state pos

(** 处理中文操作符（0xE8开头）*)
let handle_chinese_operators state pos =
  if check_chinese_punctuation state Constants.UTF8.chinese_minus_byte1 Constants.UTF8.chinese_minus_byte2 Constants.UTF8.chinese_minus_byte3 then
    Some (Lexer_tokens.Minus, pos, Lexer_char_processing.make_new_state state)
  else 
    (* 对于其他0xE8开头的字符（如"负"），让它们通过正常的中文字符处理流程 *)
    None

(** 处理箭头符号（0xE2开头）*)
let handle_arrow_symbols state pos =
  (* 检查支持的箭头符号 *)
  if check_chinese_punctuation state Constants.UTF8.chinese_arrow_byte1 Constants.UTF8.chinese_arrow_byte2 Constants.UTF8.chinese_arrow_byte3 then
    Some (Lexer_tokens.ChineseArrow, pos, Lexer_char_processing.make_new_state state)
  else if check_chinese_punctuation state Constants.UTF8.chinese_double_arrow_byte1 Constants.UTF8.chinese_double_arrow_byte2 Constants.UTF8.chinese_double_arrow_byte3 then
    Some (Lexer_tokens.ChineseDoubleArrow, pos, Lexer_char_processing.make_new_state state)
  else if check_chinese_punctuation state Constants.UTF8.chinese_assign_arrow_byte1 Constants.UTF8.chinese_assign_arrow_byte2 Constants.UTF8.chinese_assign_arrow_byte3 then
    Some (Lexer_tokens.ChineseAssignArrow, pos, Lexer_char_processing.make_new_state state)
  else
    (* 其他箭头符号不支持 *)
    Lexer_char_processing.create_unsupported_char_error state pos

(** 主函数 - 重构后的recognize_chinese_punctuation *)
let recognize_chinese_punctuation state pos =
  match Lexer_char_processing.get_current_char state with
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
      (* 箭头符号范围 - 支持特定的箭头符号 *)
      handle_arrow_symbols state pos
  | _ -> None

(** 问题105: ｜符号已禁用，数组符号不再支持 *)
let recognize_pipe_right_bracket _state _pos =
  (* 问题105禁用所有非指定符号，包括｜ *)
  None