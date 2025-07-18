(** 词法分析器解析器模块 *)

open Lexer_state
open Lexer_tokens
open Lexer_utils

(** 帮助函数：检查UTF-8字符匹配 *)
let check_utf8_char state _byte1 byte2 byte3 =
  state.position + 2 < state.length
  && Char.code state.input.[state.position + 1] = byte2
  && Char.code state.input.[state.position + 2] = byte3

(** 读取字符串字面量 *)
let read_string_literal state : token * lexer_state =
  let rec read state acc =
    match current_char state with
    | Some c when Char.code c = 0xE3 && check_utf8_char state 0xE3 0x80 0x8F ->
        (* 』 (U+300F) - 结束字符串字面量 *)
        let new_state =
          { state with position = state.position + 3; current_column = state.current_column + 1 }
        in
        (StringToken acc, new_state)
    | Some '\\' -> (
        let state1 = advance state in
        match current_char state1 with
        | Some 'n' -> read (advance state1) (acc ^ "\n")
        | Some 't' -> read (advance state1) (acc ^ "\t")
        | Some 'r' -> read (advance state1) (acc ^ "\r")
        | Some '"' -> read (advance state1) (acc ^ "\"")
        | Some '\\' -> read (advance state1) (acc ^ "\\")
        | Some c -> read (advance state1) (acc ^ String.make 1 c)
        | None ->
            raise
              (LexError
                 ( "Unterminated string",
                   {
                     line = state.current_line;
                     column = state.current_column;
                     filename = state.filename;
                   } )))
    | Some c -> read (advance state) (acc ^ String.make 1 c)
    | None ->
        raise
          (LexError
             ( "Unterminated string",
               {
                 line = state.current_line;
                 column = state.current_column;
                 filename = state.filename;
               } ))
  in
  read state ""

(** 读取引用标识符 *)
let read_quoted_identifier state =
  let rec loop pos acc =
    if pos >= state.length then failwith "未闭合的引用标识符"
    else
      let ch, next_pos = next_utf8_char state.input pos in
      if ch = "」" then (acc, next_pos) (* 找到结束引号，返回内容和新位置 *)
      else if ch = "" then failwith "引用标识符中的无效字符"
      else loop next_pos (acc ^ ch)
  in
  let identifier, new_pos = loop state.position "" in
  let new_col = state.current_column + (new_pos - state.position) in
  let token = QuotedIdentifierToken identifier in
  (token, { state with position = new_pos; current_column = new_col })

