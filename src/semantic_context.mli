(** 骆言语义分析上下文 - Chinese Programming Language Semantic Context *)

open Ast
open Types

type symbol_entry = {
  symbol_name : string;
  symbol_type : typ;
  is_mutable : bool;
  definition_pos : int;
}
(** 符号表条目 *)

module SymbolTable : Map.S with type key = string
(** 符号表模块 *)

type symbol_table_t = symbol_entry SymbolTable.t
(** 符号表类型 *)

type scope_stack = symbol_table_t list
(** 作用域栈 *)

module TypeDefTable : Map.S with type key = string
(** 类型定义表模块 *)

type type_def_table = typ TypeDefTable.t
(** 类型定义表 *)

type semantic_context = {
  scope_stack : scope_stack;
  current_function_return_type : typ option;
  error_list : string list;
  macros : (string * macro_def) list;
  type_definitions : type_def_table;
}
(** 语义分析上下文 *)

val create_initial_context : unit -> semantic_context
(** 创建初始上下文 *)

val create_symbol_entry : string -> typ -> symbol_entry
(** 创建符号表条目的辅助函数 *)

val enter_scope : semantic_context -> semantic_context
(** 进入新作用域 *)

val exit_scope : semantic_context -> semantic_context
(** 退出作用域 *)

val add_symbol : semantic_context -> string -> typ -> bool -> semantic_context
(** 在当前作用域中添加符号 *)

val add_type_definition : semantic_context -> string -> typ -> semantic_context
(** 添加类型定义 *)

val lookup_type_definition : semantic_context -> string -> typ option
(** 查找类型定义 *)

val lookup_symbol : scope_stack -> string -> symbol_entry option
(** 符号查找 *)

val symbol_table_to_env : symbol_table_t -> (string * typ) list
(** 将符号表转换为环境 *)
