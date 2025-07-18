(** 骆言语法分析器二元运算符解析模块 - Binary Operator Parser *)

open Ast
open Lexer
open Parser_utils
open Parser_expressions_utils

(** 解析逻辑或表达式 *)
let parse_or_expr next_level_parser state = create_binary_parser [ Or ] next_level_parser state

(** 解析逻辑与表达式 *)
let parse_and_expr next_level_parser state = create_binary_parser [ And ] next_level_parser state

(** 解析比较表达式 *)
let parse_comparison_expr next_level_parser state =
  create_binary_parser [ Eq; Neq; Lt; Le; Gt; Ge ] next_level_parser state

(** 解析加法和减法表达式 *)
let parse_arithmetic_expr next_level_parser state =
  create_binary_parser [ Add; Sub ] next_level_parser state

(** 解析乘法、除法和取模表达式 *)
let parse_multiplicative_expr next_level_parser state =
  create_binary_parser [ Mul; Div; Mod ] next_level_parser state

(** 解析一元表达式 *)
let parse_unary_expr next_level_parser state =
  let token, _ = current_token state in
  match token with
  | NotKeyword ->
      let state1 = advance_parser state in
      let expr, state2 = next_level_parser state1 in
      (UnaryOpExpr (Not, expr), state2)
  | Minus ->
      let state1 = advance_parser state in
      let expr, state2 = next_level_parser state1 in
      (UnaryOpExpr (Neg, expr), state2)
  | _ -> next_level_parser state

(** 解析后缀表达式 *)
let parse_postfix_expr next_level_parser state =
  let rec parse_tail expr state =
    let token, _ = current_token state in
    match token with
    | LeftBracket ->
        (* 数组或列表索引 *)
        let state1 = advance_parser state in
        let index_expr, state2 = next_level_parser state1 in
        let state3 =
          match current_token state2 with
          | RightBracket, _ -> advance_parser state2
          | _, pos -> 
              let compiler_pos = { Compiler_errors.filename = pos.filename; line = pos.line; column = pos.column } in
              let error_info = Compiler_errors.make_error_info 
                (Compiler_errors.SyntaxError ("期望 ']'", compiler_pos))
              in
              raise (Compiler_errors.CompilerError error_info)
        in
        let new_expr = ArrayAccessExpr (expr, index_expr) in
        parse_tail new_expr state3
    | Dot ->
        (* 记录字段访问 *)
        let state1 = advance_parser state in
        let field_name, state2 = parse_identifier state1 in
        let new_expr = FieldAccessExpr (expr, field_name) in
        parse_tail new_expr state2
    | _ -> (expr, state)
  in
  let expr, state1 = next_level_parser state in
  parse_tail expr state1
