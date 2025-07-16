(** 骆言类型推断模块接口 - Chinese Programming Language Type Inference Interface *)

open Ast
open Core_types

val infer_type : env -> expr -> type_subst * typ
(** 主要的类型推断函数 *)

val show_expr_type : env -> expr -> unit
(** 显示表达式的类型 *)

val show_program_types : stmt list -> unit
(** 显示程序中所有变量的类型信息 *)
