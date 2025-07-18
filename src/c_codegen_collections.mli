(** 骆言C代码生成器集合模块 - C Code Generator Collections Module *)

open Ast
open C_codegen_context

val gen_collections : (C_codegen_context.codegen_context -> expr -> string) -> C_codegen_context.codegen_context -> expr -> string
(** 生成集合和数组操作表达式代码 *)