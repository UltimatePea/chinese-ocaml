(** 骆言语义分析表达式 - Chinese Programming Language Semantic Expressions *)

open Ast
open Types
open Semantic_context

exception SemanticError of string
(** 语义错误异常 *)

val analyze_expression : semantic_context -> expr -> semantic_context * typ option
(** 分析表达式 *)

val check_expression_semantics : semantic_context -> expr -> semantic_context
(** 检查表达式语义 *)

val check_basic_expressions : semantic_context -> expr -> semantic_context
(** 检查基本表达式语义 *)

val check_control_flow_expressions : semantic_context -> expr -> semantic_context
(** 检查控制流表达式语义 *)

val check_function_expressions : semantic_context -> expr -> semantic_context
(** 检查函数表达式语义 *)

val check_data_expressions : semantic_context -> expr -> semantic_context
(** 检查数据表达式语义 *)

val check_pattern_semantics : semantic_context -> pattern -> semantic_context
(** 检查模式语义 *)
