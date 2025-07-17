(** 骆言语义分析语句 - Chinese Programming Language Semantic Statements *)

open Ast
open Types
open Semantic_context

(** 语义错误异常 *)
exception SemanticError of string

(** 分析语句 *)
val analyze_statement : semantic_context -> stmt -> (semantic_context * typ option)

(** 分析多个语句 *)
val analyze_statements : semantic_context -> stmt list -> (semantic_context * typ option list)

(** 分析程序 *)
val analyze_program : semantic_context -> program -> semantic_context