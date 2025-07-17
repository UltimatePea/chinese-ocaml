(** 骆言语义分析类型管理 - Chinese Programming Language Semantic Types *)

open Ast
open Types
open Semantic_context

(** 解析类型表达式为类型 *)
val resolve_type_expr : semantic_context -> type_expr -> typ

(** 添加代数数据类型 *)
val add_algebraic_type : semantic_context -> string -> (string * type_expr option) list -> semantic_context

(** 将符号表转换为类型环境 *)
val symbol_table_to_env : symbol_table_t -> Types.env

(** 从作用域栈构建类型环境 *)
val build_type_env : scope_stack -> Types.env