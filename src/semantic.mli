(** 骆言语义分析器接口 - Chinese Programming Language Semantic Analyzer Interface *)

open Ast
open Types

(** 语义错误异常 *)
exception SemanticError of string

(** 符号表条目类型 *)
type symbol_entry = {
  symbol_name: string;
  symbol_type: typ;
  is_mutable: bool;
  definition_pos: int;
}

(** 符号表模块接口 *)
module SymbolTable : Map.S with type key = string

(** 符号表类型 *)
type symbol_table_t = symbol_entry SymbolTable.t

(** 作用域栈类型 *)
type scope_stack = symbol_table_t list

(** 语义分析上下文类型 *)
type semantic_context = {
  scope_stack: scope_stack;
  current_function_return_type: typ option;
  error_list: string list;
  macros: (string * macro_def) list;
}

(** 创建初始语义分析上下文 *)
val create_initial_context : unit -> semantic_context

(** 添加内置函数到上下文 *)
val add_builtin_functions : semantic_context -> semantic_context

(** 进入新作用域 *)
val enter_scope : semantic_context -> semantic_context

(** 退出作用域 *)
val exit_scope : semantic_context -> semantic_context

(** 在当前作用域中添加符号 *)
val add_symbol : semantic_context -> string -> typ -> bool -> semantic_context

(** 查找符号 *)
val lookup_symbol : scope_stack -> string -> symbol_entry option

(** 分析表达式 
    @param context 语义分析上下文
    @param expr 要分析的表达式
    @return 更新后的上下文和推断的类型（如果成功）
*)
val analyze_expression : semantic_context -> expr -> semantic_context * typ option

(** 检查表达式语义 *)
val check_expression_semantics : semantic_context -> expr -> semantic_context

(** 检查模式语义 *)
val check_pattern_semantics : semantic_context -> pattern -> semantic_context

(** 分析语句 
    @param context 语义分析上下文
    @param stmt 要分析的语句
    @return 更新后的上下文和推断的类型（如果成功）
*)
val analyze_statement : semantic_context -> stmt -> semantic_context * typ option

(** 分析整个程序
    @param program 要分析的程序（语句列表）
    @return 分析结果（Ok表示成功，Error包含错误列表）
*)
val analyze_program : program -> (string, string list) result

(** 类型检查入口函数
    @param program 要检查的程序
    @return 检查是否成功
*)
val type_check : program -> bool

(** 安静模式类型检查（用于测试）
    @param program 要检查的程序  
    @return 检查是否成功
*)
val type_check_quiet : program -> bool

(** 获取表达式类型
    @param context 语义分析上下文
    @param expr 要获取类型的表达式
    @return 表达式的类型（如果推断成功）
*)
val get_expression_type : semantic_context -> expr -> typ option