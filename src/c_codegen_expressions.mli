(** 骆言C代码生成器表达式模块接口 (重构版) - Chinese Programming Language C Code Generator Expression Module
    Interface (Refactored) *)

open Ast
open C_codegen_context

val gen_expr : codegen_context -> expr -> string
(** 生成表达式代码 *)

val gen_pattern_check : codegen_context -> string -> pattern -> string
(** 生成模式检查代码 *)
