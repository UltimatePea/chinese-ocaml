(** 骆言语法分析器复合表达式处理模块（Primary层）接口 *)

open Ast
open Lexer
open Parser_utils

val parse_parentheses_expr : parser_state -> expr * parser_state
(** 解析括号表达式 (带类型注解支持) *)

val parse_control_flow_expr : parser_state -> token -> expr * parser_state
(** 解析控制流关键字表达式 *)

val parse_ancient_expr : parser_state -> token -> expr * parser_state
(** 解析文言/古雅体关键字表达式 *)

val parse_data_structure_expr : parser_state -> token -> expr * parser_state
(** 解析数据结构表达式 *)

val parse_compound_expr : parser_state -> expr * parser_state
(** 解析复合表达式 - 重构后的主函数 *)

val parse_compound_expressions : parser_state -> (expr * parser_state) option
(** 解析复合表达式（重构后），返回Some结果或None *)
