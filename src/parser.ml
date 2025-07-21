(** 骆言语法分析器 - Chinese Programming Language Parser *)

open Ast
(** 导入基础模块 *)

open Lexer
open Compiler_errors

(** 位置转换函数 *)
let lexer_pos_to_compiler_pos (pos : Lexer.position) : Compiler_errors.position =
  { filename = pos.filename; line = pos.line; column = pos.column }

type parser_state = Parser_utils.parser_state
(** 导出核心类型和异常 *)

exception SyntaxError = Parser_utils.SyntaxError

(** 主要入口点函数 *)

(** 解析表达式 - 主要入口点 *)
let parse_expression = Parser_expressions_consolidated.parse_expression

(** 解析语句 - 主要入口点 *)
let parse_statement = Parser_statements.parse_statement

(** 解析程序 - 主要入口点 *)
let parse_program = Parser_statements.parse_program

(** 基础工具函数转发 *)
let create_parser_state = Parser_utils.create_parser_state

let current_token = Parser_utils.current_token
let advance_parser = Parser_utils.advance_parser
let expect_token = Parser_utils.expect_token
let parse_identifier = Parser_utils.parse_identifier

(** 跳过换行符辅助函数 *)
let rec skip_newlines state =
  let token, _pos = current_token state in
  if token = Newline then skip_newlines (advance_parser state) else state

(** 跳过可选的语句终结符 *)
let _skip_optional_statement_terminator state =
  let token, _ = current_token state in
  if Parser_utils.is_semicolon token || token = AlsoKeyword then advance_parser state else state

(** 解析宏参数 *)
let rec _parse_macro_params acc state =
  let token, _ = current_token state in
  match token with
  | RightParen -> (List.rev acc, state)
  | QuotedIdentifierToken param_name -> (
      let state1 = advance_parser state in
      let state2 = expect_token state1 Colon in
      let token, _ = current_token state2 in
      match token with
      | QuotedIdentifierToken "表达式" ->
          let state3 = advance_parser state2 in
          let new_param = ExprParam param_name in
          let next_token, _ = current_token state3 in
          if next_token = Comma then
            let state4 = advance_parser state3 in
            _parse_macro_params (new_param :: acc) state4
          else _parse_macro_params (new_param :: acc) state3
      | QuotedIdentifierToken "语句" ->
          let state3 = advance_parser state2 in
          let new_param = StmtParam param_name in
          let next_token, _ = current_token state3 in
          if next_token = Comma then
            let state4 = advance_parser state3 in
            _parse_macro_params (new_param :: acc) state4
          else _parse_macro_params (new_param :: acc) state3
      | QuotedIdentifierToken "类型" ->
          let state3 = advance_parser state2 in
          let new_param = TypeParam param_name in
          let next_token, _ = current_token state3 in
          if next_token = Comma then
            let state4 = advance_parser state3 in
            _parse_macro_params (new_param :: acc) state4
          else _parse_macro_params (new_param :: acc) state3
      | _ -> (
          let pos = lexer_pos_to_compiler_pos (snd (current_token state2)) in
          match syntax_error "期望宏参数类型：表达式、语句或类型" pos with
          | Error error_info ->
              raise
                (Parser_utils.SyntaxError
                   (Compiler_errors.format_error_info error_info, snd (current_token state2)))
          | Ok _ -> assert false (* 不可达代码：syntax_error总是返回Error *)))
  | _ -> (
      let pos = lexer_pos_to_compiler_pos (snd (current_token state)) in
      match syntax_error "期望宏参数名" pos with
      | Error error_info ->
          raise
            (Parser_utils.SyntaxError
               (Compiler_errors.format_error_info error_info, snd (current_token state)))
      | Ok _ -> assert false (* 不可达代码：syntax_error总是返回Error *))

(** 解析自然语言函数定义 *)
let _parse_natural_function_definition state =
  (* 调用新的模块化函数 *)
  Parser_natural_functions.parse_natural_function_definition ~expect_token ~parse_identifier
    ~skip_newlines ~parse_expr:parse_expression state
