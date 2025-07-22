(** 骆言语法分析器结构化表达式解析模块接口 - 整合版

    技术债务重构 - Fix #796
    @author 骆言AI代理
    @version 3.0 (整合版)
    @since 2025-07-21 *)

open Ast
open Lexer
open Parser_utils

(** ==================== 数组表达式解析 ==================== *)

val parse_array_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析数组表达式
    @param parse_expr 表达式解析器函数
    @param state 当前解析器状态
    @return (数组表达式, 新的解析器状态) *)

(** ==================== 记录表达式解析 ==================== *)

val parse_record_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析记录表达式
    @param parse_expr 表达式解析器函数
    @param state 当前解析器状态
    @return (记录表达式, 新的解析器状态) *)

val parse_record_updates :
  (parser_state -> expr * parser_state) -> parser_state -> (string * expr) list * parser_state
(** 解析记录更新表达式
    @param parse_expr 表达式解析器函数
    @param state 当前解析器状态
    @return (字段更新列表, 新的解析器状态) *)

(** ==================== 函数调用表达式解析 ==================== *)

val parse_function_call_expression :
  (parser_state -> expr * parser_state) -> expr -> parser_state -> expr * parser_state
(** 解析函数调用表达式
    @param parse_expr 表达式解析器函数
    @param func_expr 函数表达式
    @param state 当前解析器状态
    @return (函数调用表达式, 新的解析器状态) *)

(** ==================== 匹配表达式解析 ==================== *)

val parse_match_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析匹配表达式
    @param parse_expr 表达式解析器函数
    @param state 当前解析器状态
    @return (匹配表达式, 新的解析器状态) *)

(** ==================== 条件表达式解析 ==================== *)

val parse_conditional_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析条件表达式
    @param parse_expr 表达式解析器函数
    @param state 当前解析器状态
    @return (条件表达式, 新的解析器状态) *)

(** ==================== 函数定义表达式解析 ==================== *)

val parse_function_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析函数表达式
    @param parse_expr 表达式解析器函数
    @param state 当前解析器状态
    @return (函数表达式, 新的解析器状态) *)

(** ==================== Let表达式解析 ==================== *)

val parse_let_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析let表达式
    @param parse_expr 表达式解析器函数
    @param state 当前解析器状态
    @return (let表达式, 新的解析器状态) *)

(** ==================== 异常处理表达式解析 ==================== *)

val parse_try_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析try表达式
    @param parse_expr 表达式解析器函数
    @param state 当前解析器状态
    @return (try表达式, 新的解析器状态) *)

val parse_raise_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析raise表达式
    @param parse_expr 表达式解析器函数
    @param state 当前解析器状态
    @return (raise表达式, 新的解析器状态) *)

(** ==================== 引用表达式解析 ==================== *)

val parse_ref_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析ref表达式
    @param parse_expr 表达式解析器函数
    @param state 当前解析器状态
    @return (ref表达式, 新的解析器状态) *)

(** ==================== 组合表达式解析 ==================== *)

val parse_combine_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析组合表达式
    @param parse_expr 表达式解析器函数
    @param state 当前解析器状态
    @return (组合表达式, 新的解析器状态) *)

(** ==================== 统一解析接口 ==================== *)

val parse_structured_expression :
  (parser_state -> expr * parser_state) -> token -> parser_state -> expr * parser_state
(** 解析结构化表达式 - 统一入口函数
    @param parse_expr 表达式解析器函数
    @param token 当前token
    @param state 当前解析器状态
    @return (结构化表达式, 新的解析器状态) *)
