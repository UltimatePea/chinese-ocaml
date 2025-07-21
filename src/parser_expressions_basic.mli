(** 骆言语法分析器基础表达式解析模块接口

    本模块提供基础表达式解析功能的接口定义 *)

open Ast
open Parser_utils

val parse_assignment_expression :
  (parser_state -> expr * parser_state) ->
  (parser_state -> expr * parser_state) ->
  parser_state ->
  expr * parser_state
(** 解析赋值表达式
    @param parse_expression 主表达式解析函数
    @param parse_or_else_expression 或表达式解析函数
    @param state 解析器状态
    @return 解析结果表达式和新状态 *)

val parse_unary_expression :
  (parser_state -> expr * parser_state) ->
  (parser_state -> expr * parser_state) ->
  parser_state ->
  expr * parser_state
(** 解析一元表达式
    @param parse_unary_expression_rec 递归一元表达式解析函数
    @param parse_primary_expression 基础表达式解析函数
    @param state 解析器状态
    @return 解析结果表达式和新状态 *)

val parse_literal_expressions :
  (string -> parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析字面量表达式（整数、浮点数、字符串、布尔值）
    @param parse_function_call_or_variable 函数调用或变量解析函数
    @param state 解析器状态
    @return 解析结果表达式和新状态 *)

val parse_compound_expressions :
  (parser_state -> expr * parser_state) ->
  (string -> parser_state -> expr * parser_state) ->
  (expr -> parser_state -> expr * parser_state) ->
  (parser_state -> expr * parser_state) ->
  (parser_state -> expr * parser_state) ->
  (parser_state -> expr * parser_state) ->
  (parser_state -> expr * parser_state) ->
  parser_state ->
  expr * parser_state
(** 解析复合表达式（数组、记录、模块等）
    @param parse_expression 主表达式解析函数
    @param parse_function_call_or_variable 函数调用或变量解析函数
    @param parse_postfix_expression 后缀表达式解析函数
    @param parse_array_expression 数组表达式解析函数
    @param parse_record_expression 记录表达式解析函数
    @param parse_combine_expression 组合表达式解析函数
    @param parse_module_expression 模块表达式解析函数
    @param state 解析器状态
    @return 解析结果表达式和新状态 *)

val parse_keyword_expressions :
  (parser_state -> expr * parser_state) ->
  (string -> parser_state -> expr * parser_state) ->
  (parser_state -> expr * parser_state) ->
  parser_state ->
  expr * parser_state
(** 解析关键字表达式（标签、数值等特殊关键字）
    @param parse_expression 主表达式解析函数
    @param parse_function_call_or_variable 函数调用或变量解析函数
    @param parse_primary_expression 基础表达式解析函数
    @param state 解析器状态
    @return 解析结果表达式和新状态 *)

val parse_poetry_expressions : parser_state -> expr * parser_state
(** 解析古典诗词表达式
    @param state 解析器状态
    @return 解析结果表达式和新状态 *)
