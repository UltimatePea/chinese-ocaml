(** 骆言语义分析错误处理 - Chinese Programming Language Semantic Error Handling *)

open Ast
open Types
open Semantic_context

(** 语义错误异常 *)
exception SemanticError of string

(** 错误恢复策略 *)
type error_recovery_strategy =
  | SkipAndContinue
  | InsertDefault of typ
  | ReplaceWith of expr
  | AbortAnalysis

(** 添加错误到上下文 *)
val add_error : semantic_context -> string -> semantic_context

(** 获取错误列表 *)
val get_errors : semantic_context -> string list

(** 清空错误列表 *)
val clear_errors : semantic_context -> semantic_context

(** 检查是否有错误 *)
val has_errors : semantic_context -> bool

(** 格式化错误信息 *)
val format_error_message : string -> string

(** 格式化所有错误 *)
val format_all_errors : semantic_context -> string list

(** 错误恢复处理 *)
val handle_error_recovery : semantic_context -> string -> error_recovery_strategy -> semantic_context

(** 创建类型错误 *)
val create_type_error : string -> string

(** 创建符号错误 *)
val create_symbol_error : string -> string

(** 创建作用域错误 *)
val create_scope_error : string -> string

(** 创建模式匹配错误 *)
val create_pattern_error : string -> string

(** 创建函数调用错误 *)
val create_function_call_error : string -> string