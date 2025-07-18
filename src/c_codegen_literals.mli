(** 骆言C代码生成器字面量模块 - C Code Generator Literals Module *)

open Ast

val gen_literal_and_vars : C_codegen_context.codegen_context -> expr -> string
(** 生成基本字面量和变量表达式代码 *)