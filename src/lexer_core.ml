(** 骆言词法分析器核心模块 - 重构版本 *)

open Token_types
open Utf8_utils
open Compiler_errors

type lexer_state = {
  input : string;
  position : int;
  length : int;
  current_line : int;
  current_column : int;
  filename : string;
}
(** 词法分析器状态 *)

(** 词法分析器异常 - 已迁移到统一错误处理系统 *)

(** 创建词法分析器状态 *)
let create_lexer_state input filename =
  {
    input;
    position = 0;
    length = String.length input;
    current_line = 1;
    current_column = 1;
    filename;
  }

(** 获取当前字符 *)
let current_char state =
  if state.position >= state.length then None else Some state.input.[state.position]

(** 前进状态 *)
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

(** 跳过空白字符和注释 *)
let rec skip_whitespace_and_comments state =
  match current_char state with
  | None -> state
  | Some c when is_whitespace c -> skip_whitespace_and_comments (advance state)
  | Some '(' when state.position + 1 < state.length && state.input.[state.position + 1] = '*' ->
      skip_comment (advance (advance state))
  | Some c when Char.code c = 0xEF && state.position + 2 < state.length ->
      (* 检查中文注释 *)
      if state.input.[state.position + 1] = '\xBC' && state.input.[state.position + 2] = '\x88' then
        skip_chinese_comment (advance (advance (advance state)))
      else state
  | _ -> state

(** 跳过注释 *)
and skip_comment state =
  match current_char state with
  | None ->
      let pos =
        { Compiler_errors.line = state.current_line; column = state.current_column; filename = state.filename }
      in
      (match lex_error Constants.ErrorMessages.unterminated_comment pos with
      | Error error_info -> raise (CompilerError error_info)
      | Ok _ -> failwith "Impossible: lex_error should always return Error")
  | Some '*' when state.position + 1 < state.length && state.input.[state.position + 1] = ')' ->
      skip_whitespace_and_comments (advance (advance state))
  | Some _ -> skip_comment (advance state)

(** 跳过中文注释 *)
and skip_chinese_comment state =
  match current_char state with
  | None ->
      let pos =
        { Compiler_errors.line = state.current_line; column = state.current_column; filename = state.filename }
      in
      (match lex_error Constants.ErrorMessages.unterminated_chinese_comment pos with
      | Error error_info -> raise (CompilerError error_info)
      | Ok _ -> failwith "Impossible: lex_error should always return Error")
  | Some c when Char.code c = 0xEF && state.position + 2 < state.length ->
      if state.input.[state.position + 1] = '\xBC' && state.input.[state.position + 2] = '\x89' then
        skip_whitespace_and_comments (advance (advance (advance state)))
      else skip_chinese_comment (advance state)
  | Some _ -> skip_chinese_comment (advance state)

(** 读取字符串字面量 *)
let read_string_literal state =
  let buffer = Buffer.create (Constants.BufferSizes.default_buffer ()) in
  let rec read_chars current_state =
    match current_char current_state with
    | None ->
        let pos =
          {
            Compiler_errors.line = current_state.current_line;
            column = current_state.current_column;
            filename = current_state.filename;
          }
        in
        (match lex_error Constants.ErrorMessages.unterminated_string pos with
        | Error error_info -> raise (CompilerError error_info)
        | Ok _ -> failwith "Impossible: lex_error should always return Error")
    | Some c
      when Char.code c = 0xE3
           && ChinesePunctuation.is_string_end current_state.input current_state.position ->
        (* 找到』- 字符串结束 *)
        let final_state = advance (advance (advance current_state)) in
        (LiteralToken (Literals.StringToken (Buffer.contents buffer)), final_state)
    | Some c ->
        Buffer.add_char buffer c;
        read_chars (advance current_state)
  in
  read_chars state

(** 读取引用标识符 *)
let read_quoted_identifier state =
  let buffer = Buffer.create (Constants.BufferSizes.default_buffer ()) in
  let rec read_chars current_state =
    match current_char current_state with
    | None ->
        let pos =
          {
            Compiler_errors.line = current_state.current_line;
            column = current_state.current_column;
            filename = current_state.filename;
          }
        in
        (match lex_error Constants.ErrorMessages.unterminated_quoted_identifier pos with
        | Error error_info -> raise (CompilerError error_info)
        | Ok _ -> failwith "Impossible: lex_error should always return Error")
    | Some c
      when Char.code c = 0xE3
           && ChinesePunctuation.is_right_quote current_state.input current_state.position ->
        (* 找到」- 标识符结束 *)
        let final_state = advance (advance (advance current_state)) in
        let identifier = Buffer.contents buffer in
        (IdentifierToken (Identifiers.QuotedIdentifierToken identifier), final_state)
    | Some c when is_letter_or_chinese c || is_digit c || c = '_' ->
        Buffer.add_char buffer c;
        read_chars (advance current_state)
    | Some c ->
        let pos =
          {
            Compiler_errors.line = current_state.current_line;
            column = current_state.current_column;
            filename = current_state.filename;
          }
        in
        let error_msg = Constants.ErrorMessages.invalid_char_in_quoted_identifier ^ " '" ^ String.make 1 c ^ "'" in
        (match lex_error error_msg pos with
        | Error error_info -> raise (CompilerError error_info)
        | Ok _ -> failwith "Impossible: lex_error should always return Error")
  in
  read_chars state

(** 读取数字 *)
let read_number state =
  let buffer = Buffer.create (Constants.BufferSizes.default_buffer ()) in
  let rec read_digits current_state has_dot =
    match current_char current_state with
    | Some c when is_digit c ->
        Buffer.add_char buffer c;
        read_digits (advance current_state) has_dot
    | Some '.' when not has_dot ->
        Buffer.add_char buffer '.';
        read_digits (advance current_state) true
    | _ ->
        let number_str = Buffer.contents buffer in
        let token =
          if has_dot then LiteralToken (Literals.FloatToken (float_of_string number_str))
          else LiteralToken (Literals.IntToken (int_of_string number_str))
        in
        (token, current_state)
  in
  read_digits state false

(** 读取中文数字 *)
let read_chinese_number state =
  let buffer = Buffer.create (Constants.BufferSizes.default_buffer ()) in
  let rec read_chinese_digits current_state =
    match next_utf8_char current_state.input current_state.position with
    | Some (char, next_pos) when is_chinese_digit_char char ->
        Buffer.add_string buffer char;
        read_chinese_digits
          {
            current_state with
            position = next_pos;
            current_column = current_state.current_column + 1;
          }
    | _ ->
        let chinese_number = Buffer.contents buffer in
        (LiteralToken (Literals.ChineseNumberToken chinese_number), current_state)
  in
  read_chinese_digits state

(** 中文标点符号识别 *)
let recognize_chinese_punctuation state pos =
  if state.position + 2 >= state.length then None
  else
    let c1 = Char.code state.input.[state.position] in
    let c2 = Char.code state.input.[state.position + 1] in
    let c3 = Char.code state.input.[state.position + 2] in

    let advance_3 =
      { state with position = state.position + 3; current_column = state.current_column + 1 }
    in

    match (c1, c2, c3) with
    | 0xE3, 0x80, 0x82 -> Some (DelimiterToken Delimiters.ChinesePipe, pos, advance_3) (* 。 *)
    | 0xEF, 0xBC, 0x88 -> Some (DelimiterToken Delimiters.ChineseLeftParen, pos, advance_3) (* （ *)
    | 0xEF, 0xBC, 0x89 -> Some (DelimiterToken Delimiters.ChineseRightParen, pos, advance_3) (* ） *)
    | 0xEF, 0xBC, 0x8C -> Some (DelimiterToken Delimiters.ChineseComma, pos, advance_3) (* ， *)
    | 0xEF, 0xBC, 0x9A -> Some (DelimiterToken Delimiters.ChineseColon, pos, advance_3) (* ： *)
    | 0xEF, 0xBC, 0x9B -> Some (DelimiterToken Delimiters.ChineseSemicolon, pos, advance_3) (* ； *)
    | 0xEF, 0xBD, 0x9C -> Some (DelimiterToken Delimiters.ChinesePipe, pos, advance_3) (* ｜ *)
    | _ -> None

(** 主要的词法分析函数 *)
let next_token state =
  let state = skip_whitespace_and_comments state in
  let pos =
    { Compiler_errors.line = state.current_line; column = state.current_column; filename = state.filename }
  in

  match current_char state with
  | None -> (SpecialToken Special.EOF, pos, state)
  | Some '\n' -> (SpecialToken Special.Newline, pos, advance state)
  | _ -> (
      (* 首先尝试识别中文标点符号 *)
      match recognize_chinese_punctuation state pos with
      | Some result -> result
      | None -> (
          (* 尝试关键字匹配 *)
          let keyword_state =
            {
              Keyword_matcher.input = state.input;
              position = state.position;
              length = state.length;
              current_line = state.current_line;
              current_column = state.current_column;
              filename = state.filename;
            }
          in
          match Keyword_matcher.match_keyword keyword_state with
          | Some (keyword_token, keyword_len) ->
              let new_state =
                {
                  state with
                  position = state.position + keyword_len;
                  current_column = state.current_column + keyword_len;
                }
              in
              (KeywordToken keyword_token, pos, new_state)
          | None -> (
              (* 处理其他token *)
              match current_char state with
              | Some c
                when Char.code c = 0xE3
                     && ChinesePunctuation.is_string_start state.input state.position ->
                  (* 『 - 字符串开始 *)
                  let skip_state =
                    {
                      state with
                      position = state.position + 3;
                      current_column = state.current_column + 1;
                    }
                  in
                  let token, new_state = read_string_literal skip_state in
                  (token, pos, new_state)
              | Some c
                when Char.code c = 0xE3
                     && ChinesePunctuation.is_left_quote state.input state.position ->
                  (* 「 - 引用标识符开始 *)
                  let skip_state =
                    {
                      state with
                      position = state.position + 3;
                      current_column = state.current_column + 1;
                    }
                  in
                  let token, new_state = read_quoted_identifier skip_state in
                  (token, pos, new_state)
              | Some c when is_digit c ->
                  (* 数字 *)
                  let token, new_state = read_number state in
                  (token, pos, new_state)
              | Some c when is_chinese_char c -> (
                  (* 检查是否为中文数字 *)
                  match next_utf8_char state.input state.position with
                  | Some (char, _) when is_chinese_digit_char char ->
                      let token, new_state = read_chinese_number state in
                      (token, pos, new_state)
                  | _ ->
                      (* 其他中文字符 - 必须在「」中 *)
                      (match lex_error Constants.ErrorMessages.identifiers_must_be_quoted pos with
                      | Error error_info -> raise (CompilerError error_info)
                      | Ok _ -> failwith "Impossible: lex_error should always return Error"))
              | Some c when (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') ->
                  (* ASCII字母 - 只能是关键字 *)
                  (match lex_error Constants.ErrorMessages.ascii_letters_as_keywords_only pos with
                  | Error error_info -> raise (CompilerError error_info)
                  | Ok _ -> failwith "Impossible: lex_error should always return Error")
              | Some c ->
                  (* 禁用的ASCII符号 *)
                  let error_msg = Constants.ErrorMessages.ascii_symbols_disabled ^ " '" ^ String.make 1 c ^ "'" in
                  (match lex_error error_msg pos with
                  | Error error_info -> raise (CompilerError error_info)
                  | Ok _ -> failwith "Impossible: lex_error should always return Error")
              | None ->
                  (* 这种情况应该不会发生，但为了完整性处理 *)
                  (SpecialToken Special.EOF, pos, state))))

(** 词法分析主函数 *)
let tokenize input filename =
  let rec analyze state acc =
    let token, pos, new_state = next_token state in
    let positioned_token = (token, pos) in
    match token with
    | SpecialToken Special.EOF -> List.rev (positioned_token :: acc)
    | SpecialToken Special.Newline -> analyze new_state (positioned_token :: acc)
    | _ -> analyze new_state (positioned_token :: acc)
  in
  let initial_state = create_lexer_state input filename in
  analyze initial_state []
