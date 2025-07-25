(** 骆言语法分析器函数调用表达式解析模块接口

    本模块专门处理函数调用相关的表达式解析，包括：
    - 函数参数解析（单个参数和参数列表）
    - 函数调用表达式解析
    - 后缀表达式解析（方法调用、字段访问、数组索引）
    - 函数调用与变量引用的区分逻辑

    技术债务改进：大型模块重构优化 Phase 2.3 - Fix #1050
    @author 骆言AI代理
    @version 1.0
    @since 2025-07-24 *)

open Lexer

(** ==================== 函数参数解析 ==================== *)

(** 解析单个参数表达式的辅助函数
    @param parse_expr 表达式解析器函数
    @param token 当前token
    @param current_state 当前解析状态
    @return (参数表达式, 新的解析状态) *)
val parse_single_argument : 
  (Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state) ->
  token -> Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state

(** 递归收集参数的辅助函数
    @param parse_expr 表达式解析器函数
    @param args 已收集的参数列表（倒序）
    @param current_state 当前解析状态
    @return (参数列表, 新的解析状态) *)
val collect_function_arguments : 
  (Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state) ->
  Ast.expr list -> Parser_utils.parser_state -> Ast.expr list * Parser_utils.parser_state

(** 解析函数参数列表
    @param parse_expr 表达式解析器函数
    @param state 当前解析状态
    @return (参数列表, 新的解析状态) *)
val parse_function_arguments : 
  (Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state) ->
  Parser_utils.parser_state -> Ast.expr list * Parser_utils.parser_state

(** ==================== 函数调用表达式解析 ==================== *)

(** 决定是函数调用还是变量引用的辅助函数
    @param parse_expr 表达式解析器函数
    @param name 标识符名称
    @param state 当前解析状态
    @return (表达式, 新的解析状态) *)
val parse_function_call_or_variable : 
  (Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state) ->
  string -> Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state


(** ==================== 辅助函数 ==================== *)

(** 检查是否为函数调用的参数token
    @param token 待检查的token
    @return 是否为参数token *)
val is_function_argument_token : token -> bool

(** 向后兼容性：解析基本参数表达式 - 委派给字面量解析模块
    @param state 当前解析状态
    @return (参数表达式, 新的解析状态) *)
val parse_basic_argument_expr : Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state

(** ==================== 辅助解析函数 ==================== *)

(** 解析函数调用相关的表达式 - 用于括号表达式中的函数调用处理
    @param parse_expr 表达式解析器函数
    @param name 函数名
    @param state 当前解析状态
    @return (表达式, 新的解析状态) *)
val parse_function_call_context : 
  (Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state) ->
  string -> Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state

(** 安全的函数调用解析 - 带错误处理
    @param parse_expr 表达式解析器函数
    @param name 函数名
    @param state 当前解析状态
    @return (表达式, 新的解析状态)
    @raise Parser_utils.SyntaxError 当解析失败时 *)
val parse_function_call_safe : 
  (Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state) ->
  string -> Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state

(** 安全的后缀表达式解析 - 带错误处理
    @param parse_expr 表达式解析器函数
    @param expr 基础表达式
    @param state 当前解析状态
    @return (后缀表达式, 新的解析状态)
    @raise Parser_utils.SyntaxError 当解析失败时 *)
val parse_postfix_expr_safe : 
  (Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state) ->
  Ast.expr -> Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state