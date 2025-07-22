(** 骆言语法分析器运算符表达式解析模块接口 - 整合版

    技术债务重构 - Fix #796
    @author 骆言AI代理
    @version 3.0 (整合版)
    @since 2025-07-21 *)

open Ast
open Parser_utils

(** ==================== 核心解析函数 ==================== *)

val parse_assignment_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析赋值表达式 *)

val parse_or_else_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析否则返回表达式 *)

val parse_or_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析逻辑或表达式 *)

val parse_and_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析逻辑与表达式 *)

val parse_comparison_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析比较表达式 *)

val parse_arithmetic_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析算术表达式（加法和减法） *)

val parse_multiplicative_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析乘除表达式 *)

val parse_unary_expression :
  (parser_state -> expr * parser_state) ->
  (parser_state -> expr * parser_state) ->
  parser_state ->
  expr * parser_state
(** 解析一元表达式 *)

val parse_postfix_expression :
  (parser_state -> expr * parser_state) -> expr -> parser_state -> expr * parser_state
(** 解析后缀表达式 *)

(** ==================== 优先级链构建 ==================== *)

val create_operator_precedence_chain :
  (parser_state -> expr * parser_state) ->
  (parser_state -> expr * parser_state)
  * ((* parse_expression *)
     parser_state ->
    expr * parser_state)
  * ((* parse_or_else_expr *)
     parser_state ->
    expr * parser_state)
  * ((* parse_or_expr *)
     parser_state ->
    expr * parser_state)
  * ((* parse_and_expr *)
     parser_state ->
    expr * parser_state)
  * ((* parse_comparison_expr *)
     parser_state ->
    expr * parser_state)
  * ((* parse_arithmetic_expr *)
     parser_state ->
    expr * parser_state)
  * ((* parse_multiplicative_expr *)
     parser_state ->
    expr * parser_state)
(** 建立完整的运算符优先级解析链
    @param parse_primary_expr 基础表达式解析器
    @return 包含所有优先级层次的解析器元组 *)
(* parse_unary_expr *)

(** ==================== 向后兼容性接口 ==================== *)

val create_standard_operator_parsers :
  (parser_state -> expr * parser_state) ->
  (parser_state -> expr * parser_state)
  * (parser_state -> expr * parser_state)
  * (parser_state -> expr * parser_state)
  * (parser_state -> expr * parser_state)
  * (parser_state -> expr * parser_state)
  * (parser_state -> expr * parser_state)
  * (parser_state -> expr * parser_state)
  * (parser_state -> expr * parser_state)
(** 向后兼容：创建标准运算符解析器链 *)

val parse_arithmetic_only :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 向后兼容：单独的算术表达式解析器 *)

val parse_logical_only :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 向后兼容：单独的逻辑表达式解析器 *)

(** ==================== 工具函数 ==================== *)

val create_binary_operator_parser :
  binary_op list -> (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 通用二元运算符解析器 *)
