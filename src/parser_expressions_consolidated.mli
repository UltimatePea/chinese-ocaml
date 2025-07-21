(** 骆言语法分析器表达式解析主模块接口 - 整合版
   
    技术债务重构 - Fix #796
    @author 骆言AI代理
    @version 4.0 (整合版)
    @since 2025-07-21
*)

open Ast
open Lexer
open Parser_utils

(** ==================== 核心表达式解析接口 ==================== *)

(** 主表达式解析函数 - 公共API
    这是最高层的表达式解析函数，支持所有类型的表达式
*)
val parse_expression : parser_state -> expr * parser_state

(** ==================== 运算符表达式解析 ==================== *)

(** 解析赋值表达式 *)
val parse_assignment_expression : parser_state -> expr * parser_state

(** 解析否则返回表达式 *)
val parse_or_else_expression : parser_state -> expr * parser_state

(** 解析逻辑或表达式 *)
val parse_or_expression : parser_state -> expr * parser_state

(** 解析逻辑与表达式 *)
val parse_and_expression : parser_state -> expr * parser_state

(** 解析比较表达式 *)
val parse_comparison_expression : parser_state -> expr * parser_state

(** 解析算术表达式 *)
val parse_arithmetic_expression : parser_state -> expr * parser_state

(** 解析乘除表达式 *)
val parse_multiplicative_expression : parser_state -> expr * parser_state

(** 解析一元表达式 *)
val parse_unary_expression : parser_state -> expr * parser_state

(** 解析基础表达式 *)
val parse_primary_expression : parser_state -> expr * parser_state

(** ==================== 后缀表达式解析 ==================== *)

(** 解析后缀表达式 *)
val parse_postfix_expression : expr -> parser_state -> expr * parser_state

(** ==================== 结构化表达式解析 ==================== *)

(** 解析条件表达式 *)
val parse_conditional_expression : parser_state -> expr * parser_state

(** 解析匹配表达式 *)
val parse_match_expression : parser_state -> expr * parser_state

(** 解析函数表达式 *)
val parse_function_expression : parser_state -> expr * parser_state

(** 解析let表达式 *)
val parse_let_expression : parser_state -> expr * parser_state

(** 解析数组表达式 *)
val parse_array_expression : parser_state -> expr * parser_state

(** 解析记录表达式 *)
val parse_record_expression : parser_state -> expr * parser_state

(** 解析try表达式 *)
val parse_try_expression : parser_state -> expr * parser_state

(** 解析raise表达式 *)
val parse_raise_expression : parser_state -> expr * parser_state

(** 解析ref表达式 *)
val parse_ref_expression : parser_state -> expr * parser_state

(** 解析组合表达式 *)
val parse_combine_expression : parser_state -> expr * parser_state

(** ==================== 自然语言表达式解析 ==================== *)

(** 解析自然语言函数定义 *)
val parse_natural_function_definition : parser_state -> expr * parser_state

(** 解析自然语言函数体 *)
val parse_natural_function_body : string -> parser_state -> expr * parser_state

(** 解析自然语言条件表达式 *)
val parse_natural_conditional : string -> parser_state -> expr * parser_state

(** 解析自然语言表达式 *)
val parse_natural_expression : string -> parser_state -> expr * parser_state

(** 解析自然语言算术表达式 *)
val parse_natural_arithmetic_expression : string -> parser_state -> expr * parser_state

(** 解析自然语言算术表达式尾部 *)
val parse_natural_arithmetic_tail : expr -> string -> parser_state -> expr * parser_state

(** 解析自然语言基础表达式 *)
val parse_natural_primary : string -> parser_state -> expr * parser_state

(** 解析自然语言标识符模式 *)
val parse_natural_identifier_patterns : string -> string -> parser_state -> expr * parser_state

(** 解析自然语言输入模式 *)
val parse_natural_input_patterns : string -> parser_state -> expr * parser_state

(** 解析自然语言比较模式 *)
val parse_natural_comparison_patterns : string -> parser_state -> expr * parser_state

(** 解析自然语言算术延续表达式 *)
val parse_natural_arithmetic_continuation : expr -> string -> parser_state -> expr * parser_state

(** ==================== 工具函数 ==================== *)

(** 解析函数调用或变量 *)
val parse_function_call_or_variable : string -> parser_state -> expr * parser_state

(** 解析标签参数 *)
val parse_label_param : parser_state -> string * parser_state

(** 解析记录更新字段 *)
val parse_record_updates : parser_state -> (string * expr) list * parser_state

(** 解析模块表达式 *)
val parse_module_expression : parser_state -> expr * parser_state

(** 跳过换行符辅助函数 *)
val skip_newlines : parser_state -> parser_state

(** ==================== 系统函数 ==================== *)

(** 验证向后兼容性 *)
val verify_backward_compatibility : unit -> unit