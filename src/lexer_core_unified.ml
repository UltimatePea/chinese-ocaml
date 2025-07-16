(** 骆言词法分析器核心模块 - 统一错误处理版本 *)

open Token_types
open Utf8_utils
open Compiler_errors
open Lexer_error_adapter

type lexer_state = Lexer_core.lexer_state
(** 重新导出类型定义 *)

(** 统一错误处理的词法分析函数 *)

(** 创建词法分析器状态 *)
let create_lexer_state = Lexer_core.create_lexer_state

(** 获取当前字符 *)
let current_char = Lexer_core.current_char

(** 前进状态 *)
let advance = Lexer_core.advance

(** 跳过空白字符和注释 - 使用统一错误处理 *)
let rec skip_whitespace_and_comments state =
  match current_char state with
  | None -> LexOk state
  | Some c when is_whitespace c -> skip_whitespace_and_comments (advance state)
  | Some '(' when state.position + 1 < state.length && state.input.[state.position + 1] = '*' ->
      skip_comment (advance (advance state))
  | Some c when Char.code c = 0xEF && state.position + 2 < state.length ->
      (* 检查中文注释 *)
      if state.input.[state.position + 1] = '\xBC' && state.input.[state.position + 2] = '\x88' then
        skip_chinese_comment (advance (advance (advance state)))
      else LexOk state
  | _ -> LexOk state

(** 跳过注释 - 使用统一错误处理 *)
and skip_comment state =
  match current_char state with
  | None ->
      let pos =
        { line = state.current_line; column = state.current_column; filename = state.filename }
      in
      LexError (extract_error_info (LexErrorHandler.unterminated_comment pos))
  | Some '*' when state.position + 1 < state.length && state.input.[state.position + 1] = ')' ->
      skip_whitespace_and_comments (advance (advance state))
  | Some _ -> skip_comment (advance state)

(** 跳过中文注释 - 使用统一错误处理 *)
and skip_chinese_comment state =
  match current_char state with
  | None ->
      let pos =
        { line = state.current_line; column = state.current_column; filename = state.filename }
      in
      LexError (extract_error_info (LexErrorHandler.unterminated_chinese_comment pos))
  | Some c when Char.code c = 0xEF && state.position + 2 < state.length ->
      if state.input.[state.position + 1] = '\xBC' && state.input.[state.position + 2] = '\x89' then
        skip_whitespace_and_comments (advance (advance (advance state)))
      else skip_chinese_comment (advance state)
  | Some _ -> skip_chinese_comment (advance state)

(** 读取字符串字面量 - 使用统一错误处理 *)
let read_string_literal state =
  let buffer = Buffer.create (Constants.BufferSizes.default_buffer ()) in
  let rec read_chars current_state =
    match current_char current_state with
    | None ->
        let pos =
          {
            line = current_state.current_line;
            column = current_state.current_column;
            filename = current_state.filename;
          }
        in
        LexError (extract_error_info (LexErrorHandler.unterminated_string pos))
    | Some '"' ->
        let token = String (Buffer.contents buffer) in
        let pos =
          { line = state.current_line; column = state.current_column; filename = state.filename }
        in
        LexOk (token, pos, advance current_state)
    | Some '\\' -> (
        let next_state = advance current_state in
        match current_char next_state with
        | None ->
            let pos =
              {
                line = next_state.current_line;
                column = next_state.current_column;
                filename = next_state.filename;
              }
            in
            LexError (extract_error_info (LexErrorHandler.unterminated_string pos))
        | Some 'n' ->
            Buffer.add_char buffer '\n';
            read_chars (advance next_state)
        | Some 't' ->
            Buffer.add_char buffer '\t';
            read_chars (advance next_state)
        | Some 'r' ->
            Buffer.add_char buffer '\r';
            read_chars (advance next_state)
        | Some '\\' ->
            Buffer.add_char buffer '\\';
            read_chars (advance next_state)
        | Some '"' ->
            Buffer.add_char buffer '"';
            read_chars (advance next_state)
        | Some c ->
            Buffer.add_char buffer c;
            read_chars (advance next_state))
    | Some c ->
        Buffer.add_char buffer c;
        read_chars (advance current_state)
  in
  read_chars (advance state)

(** 读取引用标识符 - 使用统一错误处理 *)
let read_quoted_identifier state =
  let buffer = Buffer.create (Constants.BufferSizes.default_buffer ()) in
  let rec read_chars current_state =
    match current_char current_state with
    | None ->
        let pos =
          {
            line = current_state.current_line;
            column = current_state.current_column;
            filename = current_state.filename;
          }
        in
        LexError (extract_error_info (LexErrorHandler.unterminated_quoted_identifier pos))
    | Some c when String.equal (String.make 1 c) "」" ->
        let identifier = Buffer.contents buffer in
        let token = Identifier identifier in
        let pos =
          { line = state.current_line; column = state.current_column; filename = state.filename }
        in
        LexOk (token, pos, advance current_state)
    | Some c ->
        Buffer.add_char buffer c;
        read_chars (advance current_state)
  in
  read_chars (advance state)

(** 包装原始词法分析函数以支持统一错误处理 *)
let safe_tokenize input filename = safe_lex_operation (fun () -> Lexer_core.tokenize input filename)

(** 兼容性函数：将统一错误处理结果转换为异常 *)
let tokenize_with_exceptions input filename =
  match safe_tokenize input filename with
  | LexOk tokens -> tokens
  | LexError error_info -> raise (CompilerError error_info)

(** 错误恢复式词法分析 *)
let tokenize_with_recovery input filename =
  let state = create_lexer_state input filename in
  let rec collect_tokens acc current_state =
    match skip_whitespace_and_comments current_state with
    | LexError error_info ->
        (* 尝试错误恢复 *)
        let recovery_context =
          Error_handler.create_context ~source_file:filename ~function_name:"tokenize_with_recovery"
            ~module_name:"Lexer_core_unified" ()
        in
        let enhanced_error = Error_handler.handle_error ~context:recovery_context error_info in
        if Error_handler.attempt_recovery enhanced_error then
          (* 跳过当前字符继续尝试 *)
          let recovered_state = advance current_state in
          collect_tokens acc recovered_state
        else
          (* 无法恢复，返回到目前为止的tokens和错误 *)
          (List.rev acc, Some error_info)
    | LexOk state -> (
        if state.position >= state.length then (List.rev acc, None)
        else
          (* 这里应该调用具体的token解析逻辑 *)
          (* 为了简化，我们暂时使用原始的tokenize函数 *)
          let remaining_tokens =
            safe_lex_operation (fun () ->
                Lexer_core.tokenize
                  (String.sub input state.position (state.length - state.position))
                  filename)
          in
          match remaining_tokens with
          | LexOk tokens -> (List.rev acc @ tokens, None)
          | LexError error_info -> (List.rev acc, Some error_info))
  in
  collect_tokens [] state

(** 分析错误模式并提供建议 *)
let analyze_error_pattern error_info =
  match error_info.error with
  | LexError (msg, pos) ->
      let suggestions =
        if String.contains msg "未终止" then [ "检查配对的符号"; "确保正确关闭语法结构" ]
        else if String.contains msg "引用" then [ "检查标识符是否正确使用引用语法"; "确保「」配对" ]
        else [ "检查源代码语法"; "参考语言文档" ]
      in
      { error_info with suggestions = error_info.suggestions @ suggestions }
  | _ -> error_info
