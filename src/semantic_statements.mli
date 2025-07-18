(** 骆言语义分析语句 - Chinese Programming Language Semantic Statements *)

open Ast
open Types
open Semantic_context

exception SemanticError of string
(** 语义错误异常 *)

val analyze_statement : semantic_context -> stmt -> semantic_context * typ option
(** 分析语句 *)

val analyze_statements : semantic_context -> stmt list -> semantic_context * typ option list
(** 分析多个语句 *)

val analyze_program : semantic_context -> program -> semantic_context
(** 分析程序 *)
