(** 骆言C代码生成器异常处理模块 - C Code Generator Exception Handling Module *)

open Ast

val gen_exception_handling : (C_codegen_context.codegen_context -> expr -> string) -> C_codegen_context.codegen_context -> expr -> string
(** 生成异常处理表达式代码 *)

val gen_advanced_control_flow : (C_codegen_context.codegen_context -> expr -> string) -> C_codegen_context.codegen_context -> expr -> string
(** 生成高级控制流表达式代码 *)