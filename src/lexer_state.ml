(** 骆言词法分析器 - 状态管理模块 *)

open Lexer_tokens

(** 词法分析器状态 *)
type lexer_state = {
  input : string;
  length : int;
  position : int;
  current_line : int;
  current_column : int;
  filename : string;
}

(** 创建词法状态 *)
let create_lexer_state input filename =
  {
    input;
    length = String.length input;
    position = 0;
    current_line = 1;
    current_column = 1;
    filename;
  }

(** 获取当前字符 *)
let current_char state =
  if state.position >= state.length then None else Some state.input.[state.position]

(** 向前移动 *)
let advance state =
  if state.position >= state.length then state
  else
    let c = state.input.[state.position] in
    if c = '\n' then
      {
        state with
        position = state.position + 1;
        current_line = state.current_line + 1;
        current_column = 1;
      }
    else { state with position = state.position + 1; current_column = state.current_column + 1 }

(** 获取当前位置信息 *)
let get_position state =
  { line = state.current_line; column = state.current_column; filename = state.filename }

(** 跳过单个注释 *)
let skip_comment state =
  let rec skip_until_close state depth =
    match current_char state with
    | None ->
        failwith "Unterminated comment"
    | Some '(' -> (
        let state1 = advance state in
        match current_char state1 with
        | Some '*' -> skip_until_close (advance state1) (depth + 1)
        | _ -> skip_until_close state1 depth)
    | Some '*' -> (
        let state1 = advance state in
        match current_char state1 with
        | Some ')' ->
            if depth = 1 then advance state1 else skip_until_close (advance state1) (depth - 1)
        | _ -> skip_until_close state1 depth)
    | Some _ -> skip_until_close (advance state) depth
  in
  skip_until_close state 1

(** 检查UTF-8字符匹配 *)
let check_utf8_char state _byte1 byte2 byte3 =
  state.position + 2 < state.length
  && Char.code state.input.[state.position + 1] = byte2
  && Char.code state.input.[state.position + 2] = byte3

(** 跳过中文注释 「：注释内容：」 *)
let skip_chinese_comment state =
  let rec skip_until_close state =
    match current_char state with
    | None ->
        failwith "Unterminated Chinese comment"
    | Some c when Char.code c = 0xEF ->
        if check_utf8_char state 0xEF 0xBC 0x9A then
          (* 找到 ： *)
          let state1 =
            { state with position = state.position + 3; current_column = state.current_column + 1 }
          in
          match current_char state1 with
          | Some c when Char.code c = 0xE3 ->
              if check_utf8_char state1 0xE3 0x80 0x8D then
                (* 找到 ：」 组合，注释结束 *)
                {
                  state1 with
                  position = state1.position + 3;
                  current_column = state1.current_column + 1;
                }
              else skip_until_close state1
          | _ -> skip_until_close state1
        else skip_until_close (advance state)
    | Some _ -> skip_until_close (advance state)
  in
  skip_until_close state

(** 跳过空白字符和注释 *)
let rec skip_whitespace_and_comments state =
  let is_whitespace c = c = ' ' || c = '\t' || c = '\r' in
  match current_char state with
  | Some c when is_whitespace c -> skip_whitespace_and_comments (advance state)
  | Some '(' -> (
      let state1 = advance state in
      match current_char state1 with
      | Some '*' -> skip_whitespace_and_comments (skip_comment (advance state1))
      | _ -> state)
  | Some c when Char.code c = 0xE3 ->
      (* 检查中文注释 「： *)
      if check_utf8_char state 0xE3 0x80 0x8C then
        (* 找到 「 *)
        let state1 =
          { state with position = state.position + 3; current_column = state.current_column + 1 }
        in
        match current_char state1 with
        | Some c when Char.code c = 0xEF ->
            if check_utf8_char state1 0xEF 0xBC 0x9A then
              (* 找到 「： 组合，开始中文注释 *)
              let state2 =
                {
                  state1 with
                  position = state1.position + 3;
                  current_column = state1.current_column + 1;
                }
              in
              skip_whitespace_and_comments (skip_chinese_comment state2)
            else state
        | _ -> state
      else state
  | _ -> state