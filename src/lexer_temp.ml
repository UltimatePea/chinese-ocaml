(** 骆言词法分析器 - 模块化重构版本 *)

(* 导入模块化的词法分析器组件 *)
open Lexer_state
open Lexer_utils
open Lexer_chars
open Lexer_parsers

(* 重新导出类型和函数以匹配接口 *)
type token = Lexer_tokens.token
type position = Lexer_tokens.position
type positioned_token = Lexer_tokens.positioned_token

exception LexError = Lexer_tokens.LexError

(* 重新导出ppx_deriving生成的函数 *)
let pp_token = Lexer_tokens.pp_token

let show_token token =
  let s = Lexer_tokens.show_token token in
  (* 将 Lexer_tokens.* 替换为 Lexer.* 以匹配测试期望 *)
  Str.global_replace (Str.regexp "Lexer_tokens\\.") "Lexer." s

let equal_token = Lexer_tokens.equal_token
let compare_token = Lexer_tokens.compare_token
let sexp_of_token = Lexer_tokens.sexp_of_token
let token_of_sexp = Lexer_tokens.token_of_sexp

let sexp_of_position = Lexer_tokens.sexp_of_position
let position_of_sexp = Lexer_tokens.position_of_sexp
let show_position = Lexer_tokens.show_position
let pp_position = Lexer_tokens.pp_position
let equal_position = Lexer_tokens.equal_position
let compare_position = Lexer_tokens.compare_position

(** 字符处理模块 *)
module CharacterProcessing = struct
  (** 验证字符是否在有效范围内 *)
  let validate_char c = 
    let code = Char.code c in
    code >= 0 && code <= 127

  (** 处理单字节字符 *)
  let process_single_byte_char state pos =
    let c = Lexer_state.peek_char state pos in
    let c_str = String.make 1 c in
    match Lexer_chars.find_best_match c_str with
    | Some token -> (token, Lexer_state.advance_position pos 1, Lexer_state.advance_state state 1)
    | None -> 
      let tokens = Lexer_parsers.parse_character state pos in
      match tokens with
      | Some result -> result
      | None -> 
        if Char.code c < 128 then
          raise (LexError ("未知字符: " ^ c_str, pos))
        else
          raise (LexError ("无效的UTF-8字符", pos))

  (** 处理字符串字面量 *)
  let process_string_literal state pos =
    let str, new_pos, new_state = Lexer_parsers.parse_string_literal state pos in
    (Lexer_tokens.StringToken str, new_pos, new_state)

  (** 处理注释 *)
  let process_comment state pos =
    let comment, new_pos, new_state = Lexer_parsers.parse_comment state pos in
    (Lexer_tokens.Comment comment, new_pos, new_state)
end

(** 词元化引擎模块 *)
module TokenizationEngine = struct
  (** 分发UTF-8字符处理 *)
  let dispatch_utf8_char state pos =
    try
      Lexer_parsers.parse_utf8_char state pos
    with
    | LexError (msg, error_pos) -> raise (LexError (msg, error_pos))
    | Failure msg -> raise (LexError ("UTF-8解析失败: " ^ msg, pos))

  (** 主要字符处理分发器 *)
  let dispatch_char_processing state pos =
    let input = Lexer_state.get_input state in
    let current_pos = Lexer_state.get_position state in
    if current_pos >= String.length input then
      (Lexer_tokens.EOF, pos, state)
    else
      let c = input.[current_pos] in
      if Char.code c < 128 then
        CharacterProcessing.process_single_byte_char state pos
      else
        dispatch_utf8_char state pos
end

(** 获取下一个词元 *)
let next_token state =
  try
    let pos = Lexer_state.get_current_position state in
    let input = Lexer_state.get_input state in
    let current_pos = Lexer_state.get_position state in
    
    if current_pos >= String.length input then
      (Lexer_tokens.EOF, pos, state)
    else
      (* 尝试快速路径处理 *)
      let fast_result = Lexer_chars.try_fast_lookup state pos in
      match fast_result with
      | Some result -> result
      | None -> TokenizationEngine.dispatch_char_processing state pos
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
  let initial_state = Lexer_state.create_lexer_state input filename in
  analyze initial_state []