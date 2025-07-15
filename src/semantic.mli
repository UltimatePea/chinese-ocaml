(** 骆言语义分析器接口 - Chinese Programming Language Semantic Analyzer Interface *)

open Ast
open Types

(** 语义错误异常 *)
exception SemanticError of string

(** 符号表条目类型 *)
type symbol_entry = {
  symbol_name : string;     (** 符号名称 *)
  symbol_type : typ;        (** 符号类型 *)
  is_mutable : bool;        (** 是否可变 *)
  definition_pos : int;     (** 定义位置 *)
}

(** 符号表类型 *)
type symbol_table_t

(** 作用域栈类型 *)
type scope_stack = symbol_table_t list

(** 类型定义表类型 *)
type type_def_table

(** 语义分析上下文类型 *)
type semantic_context = {
  scope_stack: scope_stack;                     (** 作用域栈 *)
  current_function_return_type: typ option;     (** 当前函数返回类型 *)
  error_list: string list;                      (** 错误列表 *)
  macros: (string * macro_def) list;           (** 宏定义列表 *)
  type_definitions: type_def_table;            (** 类型定义表 *)
}

(** 创建初始语义分析上下文 *)
val create_initial_context : unit -> semantic_context

(** 向上下文添加内置函数 *)
val add_builtin_functions : semantic_context -> semantic_context

(** 进入新作用域 *)
val enter_scope : semantic_context -> semantic_context

(** 退出当前作用域 *)
val exit_scope : semantic_context -> semantic_context

(** 在当前作用域中添加符号 *)
val add_symbol : semantic_context -> string -> typ -> bool -> semantic_context

(** 添加类型定义到上下文 *)
val add_type_definition : semantic_context -> string -> typ -> semantic_context

(** 查找类型定义 *)
val lookup_type_definition : semantic_context -> string -> typ option

(** 解析类型表达式为具体类型 *)
val resolve_type_expr : semantic_context -> type_expr -> typ

(** 添加代数数据类型及其构造器 *)
val add_algebraic_type : semantic_context -> string -> (string * type_expr option) list -> semantic_context

(** 在作用域栈中查找符号 *)
val lookup_symbol : scope_stack -> string -> symbol_entry option

(** 将符号表转换为类型环境 *)
val symbol_table_to_env : symbol_table_t -> Types.env

(** 分析表达式的语义和类型 *)
val analyze_expression : semantic_context -> expr -> semantic_context * typ option

(** 检查表达式的语义正确性 *)
val check_expression_semantics : semantic_context -> expr -> semantic_context

(** 检查模式匹配的语义 *)
val check_pattern_semantics : semantic_context -> pattern -> semantic_context

(** 分析语句的语义和类型 *)
val analyze_statement : semantic_context -> stmt -> semantic_context * typ option

(** 分析整个程序的语义 *)
val analyze_program : stmt list -> (string, string list) result

(** 类型检查程序入口函数 *)
val type_check : stmt list -> bool

(** 安静模式类型检查（用于测试） *)
val type_check_quiet : stmt list -> bool

(** 获取表达式的类型 *)
val get_expression_type : semantic_context -> expr -> typ option