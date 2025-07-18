(** 骆言C代码生成器模式匹配模块 - C Code Generator Patterns Module *)

open Ast

val gen_pattern_check : C_codegen_context.codegen_context -> string -> pattern -> string
(** 生成模式检查代码 *)
