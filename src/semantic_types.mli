(** 骆言语义分析类型管理 - Chinese Programming Language Semantic Types *)

open Ast
open Types
open Semantic_context

val resolve_type_expr : semantic_context -> type_expr -> typ
(** 解析类型表达式为类型 *)

val add_algebraic_type :
  semantic_context -> string -> (string * type_expr option) list -> semantic_context
(** 添加代数数据类型 *)

val symbol_table_to_env : symbol_table_t -> Types.env
(** 将符号表转换为类型环境 *)

val build_type_env : scope_stack -> Types.env
(** 从作用域栈构建类型环境 *)
