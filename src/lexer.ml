(** 骆言词法分析器 - 模块化重构版本 *)

(* 导入模块化的词法分析器组件 *)
open Lexer_state
open Lexer_utils
open Lexer_chars
open Lexer_parsers

(* 重新导出类型和函数以匹配接口 *)
include Lexer_tokens

(* 重新导出ppx_deriving生成的函数 *)
let pp_token = Lexer_tokens.pp_token

let show_token token =
  let s = Lexer_tokens.show_token token in
  (* 将 Lexer_tokens.* 替换为 Lexer.* 以匹配测试期望 *)
  Str.global_replace (Str.regexp "Lexer_tokens\\.") "Lexer." s

let equal_token = Lexer_tokens.equal_token
let pp_position = Lexer_tokens.pp_position
let show_position = Lexer_tokens.show_position
let equal_position = Lexer_tokens.equal_position
let pp_positioned_token = Lexer_tokens.pp_positioned_token
let show_positioned_token = Lexer_tokens.show_positioned_token
let equal_positioned_token = Lexer_tokens.equal_positioned_token

(* 重新导出关键函数以满足接口要求 *)
let find_keyword = Lexer_keywords.find_keyword

(** 字符处理函数组 *)
module CharacterProcessing = struct
  (** 检查ASCII字符禁用 *)
  let check_ascii_forbidden c pos =
    match c with
    | '+' | '-' | '*' | '/' | '%' | '^' | '=' | '<' | '>' | '.' | '(' | ')' | '[' | ']' | '{' | '}'
    | ',' | ';' | ':' | '!' | '|' | '_' | '@' | '#' | '$' | '&' | '?' | '\'' | '`' | '~' ->
        raise (LexError ("ASCII符号已禁用，请使用中文标点符号。禁用字符: " ^ String.make 1 c, pos))
    | _ when is_digit c ->
        (* 阿拉伯数字已禁用 - Issue #105 *)
        raise (LexError (Constants.ErrorMessages.arabic_numbers_disabled, pos))
    | _ -> ()

  (** 处理单字节字符 *)
  let tokenize_single_byte_char state pos utf8_char =
    let c = utf8_char.[0] in
    check_ascii_forbidden c pos;
    if is_letter_or_chinese c then handle_letter_or_chinese_char state pos
    else raise (LexError ("意外的字符: " ^ String.make 1 c, pos))

  (** 处理字符串字面量 *)
  let tokenize_string_literal state pos =
    let skip_state =
      { state with position = state.position + 3; current_column = state.current_column + 1 }
    in
    let token, new_state = read_string_literal skip_state in
    (token, pos, new_state)

  (** 处理引用标识符 *)
  let tokenize_quoted_identifier state pos =
    let skip_state =
      { state with position = state.position + 3; current_column = state.current_column + 1 }
    in
    let token, new_state = read_quoted_identifier skip_state in
    (token, pos, new_state)

  (** 处理全角数字 *)
  let tokenize_fullwidth_number state pos =
    let sequence, new_state = Lexer_utils.read_fullwidth_number_sequence state in
    let token = Lexer_utils.convert_fullwidth_number_sequence sequence in
    (token, pos, new_state)

  (** 处理多字节UTF-8字符 *)
  let tokenize_multibyte_char state pos utf8_char =
    if Utf8_utils.FullwidthDetection.is_fullwidth_digit_string utf8_char then
      tokenize_fullwidth_number state pos
    else if is_chinese_utf8 utf8_char || Keyword_matcher.is_keyword utf8_char then
      handle_letter_or_chinese_char state pos
    else raise (LexError ("意外的字符: " ^ utf8_char, pos))
end

(** 词元化处理模块 *)
module TokenizationEngine = struct
  open CharacterProcessing

  (** UTF-8字符分发处理 *)
  let tokenize_utf8_char state pos utf8_char =
    if utf8_char = "" then (Lexer_tokens.EOF, pos, state)
    else if utf8_char = "\n" then (Lexer_tokens.Newline, pos, advance state)
    else if utf8_char = "\"" then raise (LexError ("ASCII符号已禁用，请使用中文标点符号。禁用字符: \"", pos))
    else if utf8_char = "『" then tokenize_string_literal state pos
    else if utf8_char = "「" then tokenize_quoted_identifier state pos
    else if String.length utf8_char = 1 then tokenize_single_byte_char state pos utf8_char
    else if String.length utf8_char > 1 then tokenize_multibyte_char state pos utf8_char
    else raise (LexError ("意外的字符: " ^ utf8_char, pos))

  (** 主要的字符处理分发器 *)
  let dispatch_char_processing state pos =
    if state.position >= state.length then (Lexer_tokens.EOF, pos, state)
    else
      let utf8_char, _next_pos = next_utf8_char state.input state.position in
      tokenize_utf8_char state pos utf8_char
end

(** 获取下一个词元 *)
let next_token state : token * position * lexer_state =
  let state = skip_whitespace_and_comments state in
  let pos =
    { line = state.current_line; column = state.current_column; filename = state.filename }
  in

  try
    match current_char state with
    | None -> (Lexer_tokens.EOF, pos, state)
    | Some '\n' -> (Lexer_tokens.Newline, pos, advance state)
    | _ -> (
        (* 首先尝试识别中文标点符号 *)
        match recognize_chinese_punctuation state pos with
        | Some result -> result
        | None -> (
            (* 尝试识别｜」组合 *)
            match recognize_pipe_right_bracket state pos with
            | Some result -> result
            | None -> TokenizationEngine.dispatch_char_processing state pos))
  with LexError (msg, pos) -> raise (LexError (msg, pos))

(** 词法分析主函数 *)
let tokenize input filename : positioned_token list =
  let rec analyze state acc =
    let token, pos, new_state = next_token state in
    let positioned_token = (token, pos) in
    match token with
    | Lexer_tokens.EOF -> List.rev (positioned_token :: acc)
    | Lexer_tokens.Newline -> analyze new_state (positioned_token :: acc)
    | _ -> analyze new_state (positioned_token :: acc)
  in
  let initial_state = create_lexer_state input filename in
  analyze initial_state []