(** 骆言C代码生成器表达式模块接口 - Chinese Programming Language C Code Generator Expression Module Interface *)

open Ast
open C_codegen_context

(** 生成表达式代码 *)
val gen_expr : codegen_context -> expr -> string

(** 生成模式代码 *)
val gen_pattern : codegen_context -> pattern -> string

(** 生成基本字面量和变量表达式代码 *)
val gen_literal_and_vars : codegen_context -> expr -> string

(** 生成算术和逻辑运算表达式代码 *)
val gen_operations : codegen_context -> expr -> string

(** 生成内存和引用操作表达式代码 *)
val gen_memory_operations : codegen_context -> expr -> string

(** 生成集合和数组操作表达式代码 *)
val gen_collections : codegen_context -> expr -> string

(** 生成结构化数据表达式代码 *)
val gen_structured_data : codegen_context -> expr -> string

(** 生成控制流表达式代码 *)
val gen_control_flow : codegen_context -> expr -> string

(** 生成异常处理表达式代码 *)
val gen_exception_handling : codegen_context -> expr -> string

(** 生成高级控制流表达式代码 *)
val gen_advanced_control_flow : codegen_context -> expr -> string