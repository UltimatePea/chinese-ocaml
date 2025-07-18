(** 骆言语义分析上下文 - Chinese Programming Language Semantic Context *)

open Ast
open Types
open Compiler_errors

(** 初始化模块日志器 *)
let[@warning "-32"] log_info, log_error = Logger_utils.init_info_error_loggers "SemanticContext"

type symbol_entry = {
  symbol_name : string;
  symbol_type : typ;
  is_mutable : bool;
  definition_pos : int; (* 简化版位置信息 *)
}
(** 符号表条目 *)

module SymbolTable = Map.Make (String)
(** 符号表模块 *)

type symbol_table_t = symbol_entry SymbolTable.t
(** 符号表类型 *)

type scope_stack = symbol_table_t list
(** 作用域栈 *)

module TypeDefTable = Map.Make (String)
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

(** 创建初始上下文 *)
let create_initial_context () =
  {
    scope_stack = [ SymbolTable.empty ];
    current_function_return_type = None;
    error_list = [];
    macros = [];
    type_definitions = TypeDefTable.empty;
  }

(** 创建符号表条目的辅助函数 *)
let create_symbol_entry name symbol_type =
  { symbol_name = name; symbol_type; is_mutable = false; definition_pos = 0 }

(** 进入新作用域 *)
let enter_scope context = { context with scope_stack = SymbolTable.empty :: context.scope_stack }

(** 退出作用域 *)
let exit_scope context =
  match context.scope_stack with
  | [] -> (
      let pos = { filename = "<semantic>"; line = 262; column = 0 } in
      match semantic_error "尝试退出空作用域栈" (Some pos) with
      | Error error_info -> raise (CompilerError error_info)
      | Ok _ -> failwith "不应该到达此处")
  | _ :: rest_scopes -> { context with scope_stack = rest_scopes }

(** 在当前作用域中添加符号 *)
let add_symbol context symbol_name symbol_type is_mutable =
  match context.scope_stack with
  | [] -> (
      let pos = { filename = "<semantic>"; line = 268; column = 0 } in
      match semantic_error "空作用域栈" (Some pos) with
      | Error error_info -> raise (CompilerError error_info)
      | Ok _ -> failwith "不应该到达此处")
  | current_scope :: rest_scopes ->
      if SymbolTable.mem symbol_name current_scope then
        { context with error_list = ("符号重复定义: " ^ symbol_name) :: context.error_list }
      else
        let new_entry = { symbol_name; symbol_type; is_mutable; definition_pos = 0 (* 简化版 *) } in
        let new_current_scope = SymbolTable.add symbol_name new_entry current_scope in
        { context with scope_stack = new_current_scope :: rest_scopes }

(** 添加类型定义 *)
let add_type_definition context type_name typ =
  let new_type_definitions = TypeDefTable.add type_name typ context.type_definitions in
  { context with type_definitions = new_type_definitions }

(** 查找类型定义 *)
let lookup_type_definition context type_name =
  try Some (TypeDefTable.find type_name context.type_definitions) with Not_found -> None

(** 符号查找 *)
let rec lookup_symbol scope_stack symbol_name =
  match scope_stack with
  | [] -> None
  | current_scope :: rest_scopes ->
      if SymbolTable.mem symbol_name current_scope then
        Some (SymbolTable.find symbol_name current_scope)
      else lookup_symbol rest_scopes symbol_name

(** 将符号表转换为环境 *)
let symbol_table_to_env symbol_table =
  SymbolTable.fold (fun key entry acc -> (key, entry.symbol_type) :: acc) symbol_table []
