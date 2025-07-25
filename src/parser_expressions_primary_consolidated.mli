(** 骆言语法分析器基础表达式解析模块接口 - 整合版

    本模块整合了原有的多个细分基础表达式模块的接口。

    技术债务重构 - Fix #796
    @author 骆言AI代理
    @version 3.0 (整合版)
    @since 2025-07-21 *)

open Ast
open Parser_utils

(** ==================== 主解析函数 ==================== *)

val parse_primary_expr :
  (parser_state -> expr * parser_state) ->
  (parser_state -> expr * parser_state) ->
  (parser_state -> expr * parser_state) ->
  parser_state ->
  expr * parser_state
(** 解析基础表达式 - 统一入口函数
    @param parse_expression 表达式解析器函数
    @param parse_array_expression 数组表达式解析器函数
    @param parse_record_expression 记录表达式解析器函数
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)

(** ==================== 后缀表达式解析 ==================== *)

(* 后缀表达式解析已迁移到 Parser_expressions_calls 模块 *)

(** ==================== 向后兼容性函数 ==================== *)

val parse_function_call_or_variable : string -> parser_state -> expr * parser_state
(** 向后兼容：解析函数调用或变量 - 委派给函数调用解析模块
    @param name 标识符名称
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)

(** ==================== 分类解析函数 ==================== *)

val parse_literal_expr : parser_state -> expr * parser_state
(** 解析字面量表达式
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)

(* 标识符表达式解析已迁移到 Parser_expressions_identifiers 模块 *)
(* 函数参数解析已迁移到 Parser_expressions_calls 模块 *)

(* 类型关键字表达式解析已迁移到 Parser_expressions_identifiers 模块 *)

val parse_tag_expr : (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析标签表达式
    @param parse_primary_expression 基础表达式解析器函数
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)

val parse_poetry_expr : parser_state -> expr * parser_state
(** 解析诗词表达式
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)

val parse_ancient_expr :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析古雅体表达式
    @param parse_expression 表达式解析器函数
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)
