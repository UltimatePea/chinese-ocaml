(** 骆言C代码生成器结构化数据模块 - C Code Generator Structured Data Module *)

open Ast
open C_codegen_context

val gen_structured_data : (C_codegen_context.codegen_context -> expr -> string) -> C_codegen_context.codegen_context -> expr -> string
(** 生成结构化数据表达式代码 *)