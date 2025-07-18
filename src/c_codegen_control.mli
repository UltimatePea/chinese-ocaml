(** 骆言C代码生成器控制流模块 - C Code Generator Control Flow Module *)

open Ast

val gen_control_flow : (C_codegen_context.codegen_context -> expr -> string) -> (C_codegen_context.codegen_context -> string -> pattern -> string) -> C_codegen_context.codegen_context -> expr -> string
(** 生成控制流表达式代码 *)