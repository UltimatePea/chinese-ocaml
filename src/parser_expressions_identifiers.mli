(** 骆言语法分析器标识符表达式解析模块接口

    本模块专门处理各种类型标识符表达式的解析，包括：
    - 普通标识符表达式（变量引用和函数调用）
    - 带引号的标识符
    - 特殊标识符
    - 数值关键字复合标识符
    - 其他关键字复合标识符
    - 类型关键字表达式

    此模块从 parser_expressions_primary_consolidated.ml 中提取而来，
    作为技术债务改进的一部分，用于优化代码组织结构。

    技术债务改进：大型模块重构优化 - Fix #1050
    @author 骆言AI代理
    @version 1.0
    @since 2025-07-24 *)

open Ast
open Parser_utils

(** ==================== 核心解析辅助函数 ==================== *)

val raise_parse_error : string -> Lexer.token -> exn -> parser_state -> 'a
(** 统一的错误处理辅助函数
    @param expr_type 表达式类型描述
    @param token 当前token
    @param exn 捕获的异常
    @param state 当前解析器状态
    @return 抛出格式化的解析错误 *)

val parse_single_argument :
  (parser_state -> expr * parser_state) -> Lexer.token -> parser_state -> expr * parser_state
(** 解析单个参数表达式的辅助函数
    @param parse_expr 表达式解析器函数
    @param token 当前token
    @param current_state 当前解析器状态
    @return (表达式, 新的解析器状态) *)

val collect_function_arguments :
  (parser_state -> expr * parser_state) -> expr list -> parser_state -> expr list * parser_state
(** 递归收集参数的辅助函数
    @param parse_expr 表达式解析器函数
    @param args 已收集的参数列表
    @param current_state 当前解析器状态
    @return (参数列表, 新的解析器状态) *)

val parse_function_arguments :
  (parser_state -> expr * parser_state) -> parser_state -> expr list * parser_state
(** 解析函数参数列表
    @param parse_expr 表达式解析器函数
    @param state 当前解析器状态
    @return (参数列表, 新的解析器状态) *)

val parse_function_call_or_variable :
  (parser_state -> expr * parser_state) -> string -> parser_state -> expr * parser_state
(** 决定是函数调用还是变量引用的辅助函数
    @param parse_expr 表达式解析器函数
    @param name 标识符名称
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)

(** ==================== 标识符表达式解析函数 ==================== *)

val parse_quoted_identifier :
  (parser_state -> expr * parser_state) -> string -> parser_state -> expr * parser_state
(** 处理带引号的标识符
    @param parse_expr 表达式解析器函数
    @param name 标识符名称
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)

val parse_special_identifier :
  (parser_state -> expr * parser_state) -> string -> parser_state -> expr * parser_state
(** 处理特殊标识符
    @param parse_expr 表达式解析器函数
    @param name 标识符名称
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)

val parse_number_keyword_identifier :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 处理数值关键字复合标识符
    @param parse_expr 表达式解析器函数
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)

val parse_keyword_compound_identifier :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 处理其他关键字复合标识符
    @param parse_expr 表达式解析器函数
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)

val parse_identifier_expr :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析标识符表达式（变量引用和函数调用）- 重构版本
    @param parse_expr 表达式解析器函数
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)

(** ==================== 类型关键字表达式解析 ==================== *)

val parse_type_keyword_expr : parser_state -> expr * parser_state
(** 解析类型关键字表达式
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)

(** ==================== 辅助解析函数 ==================== *)

val parse_identifier_exprs :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析标识符表达式辅助函数
    @param parse_expr 表达式解析器函数
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)

val parse_type_keyword_exprs : parser_state -> expr * parser_state
(** 解析类型关键字表达式辅助函数
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)

(** ==================== 标识符和类型关键字token检查函数 ==================== *)

val is_identifier_token : Lexer.token -> bool
(** 匹配标识符类型tokens
    @param token 需要检查的token
    @return 如果是标识符token则返回true *)

val is_type_keyword_token : Lexer.token -> bool
(** 匹配类型关键字tokens
    @param token 需要检查的token
    @return 如果是类型关键字token则返回true *)

(** ==================== 安全解析函数 ==================== *)

val parse_identifier_expr_safe :
  (parser_state -> expr * parser_state) -> Lexer.token -> parser_state -> expr * parser_state
(** 解析单个表达式类型 - 标识符（带错误处理）
    @param parse_expr 表达式解析器函数
    @param token 当前token
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)

val parse_type_keyword_expr_safe : Lexer.token -> parser_state -> expr * parser_state
(** 解析单个表达式类型 - 类型关键字（带错误处理）
    @param token 当前token
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)