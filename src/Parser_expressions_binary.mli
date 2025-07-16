(** 骆言语法分析器二元运算符解析模块接口 *)

open Ast
open Parser_utils

(** 解析逻辑或表达式 *)
val parse_or_expr : 
  (parser_state -> expr * parser_state) -> 
  (parser_state -> expr * parser_state)

(** 解析逻辑与表达式 *)
val parse_and_expr : 
  (parser_state -> expr * parser_state) -> 
  (parser_state -> expr * parser_state)

(** 解析比较表达式 *)
val parse_comparison_expr : 
  (parser_state -> expr * parser_state) -> 
  (parser_state -> expr * parser_state)

(** 解析加法和减法表达式 *)
val parse_arithmetic_expr : 
  (parser_state -> expr * parser_state) -> 
  (parser_state -> expr * parser_state)

(** 解析乘法、除法和取模表达式 *)
val parse_multiplicative_expr : 
  (parser_state -> expr * parser_state) -> 
  (parser_state -> expr * parser_state)

(** 解析一元表达式 *)
val parse_unary_expr : 
  (parser_state -> expr * parser_state) -> 
  (parser_state -> expr * parser_state)

(** 解析后缀表达式 *)
val parse_postfix_expr : 
  (parser_state -> expr * parser_state) -> 
  (parser_state -> expr * parser_state)