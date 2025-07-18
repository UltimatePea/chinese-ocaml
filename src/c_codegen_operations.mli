(** 骆言C代码生成器操作表达式模块 - C Code Generator Operations Module *)

open Ast

val gen_operations : (C_codegen_context.codegen_context -> expr -> string) -> C_codegen_context.codegen_context -> expr -> string
(** 生成算术和逻辑运算表达式代码 *)

val gen_memory_operations : (C_codegen_context.codegen_context -> expr -> string) -> C_codegen_context.codegen_context -> expr -> string
(** 生成内存和引用操作表达式代码 *)