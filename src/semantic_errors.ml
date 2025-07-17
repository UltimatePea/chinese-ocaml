(** 骆言语义分析错误处理 - Chinese Programming Language Semantic Error Handling *)

open Ast
open Types
open Semantic_context

(** 初始化模块日志器 *)
let log_info, log_error = Logger_utils.init_info_error_loggers "SemanticErrors"

(** 语义错误异常 *)
exception SemanticError of string

(** 错误恢复策略 *)
type error_recovery_strategy =
  | SkipAndContinue
  | InsertDefault of typ
  | ReplaceWith of expr
  | AbortAnalysis

(** 添加错误到上下文 *)
let add_error context error_msg =
  { context with error_list = error_msg :: context.error_list }

(** 获取错误列表 *)
let get_errors context =
  List.rev context.error_list

(** 清空错误列表 *)
let clear_errors context =
  { context with error_list = [] }

(** 检查是否有错误 *)
let has_errors context =
  context.error_list <> []

(** 格式化错误信息 *)
let format_error_message error_msg =
  "语义错误: " ^ error_msg

(** 格式化所有错误 *)
let format_all_errors context =
  List.map format_error_message (get_errors context)

(** 错误恢复处理 *)
let handle_error_recovery context error_msg recovery_strategy =
  match recovery_strategy with
  | SkipAndContinue ->
      add_error context error_msg
  | InsertDefault _typ ->
      log_info ("使用默认类型进行错误恢复: " ^ error_msg);
      add_error context error_msg
  | ReplaceWith _expr ->
      log_info ("使用替换表达式进行错误恢复: " ^ error_msg);
      add_error context error_msg
  | AbortAnalysis ->
      log_error ("终止分析: " ^ error_msg);
      raise (SemanticError error_msg)

(** 创建类型错误 *)
let create_type_error msg =
  "类型错误: " ^ msg

(** 创建符号错误 *)
let create_symbol_error msg =
  "符号错误: " ^ msg

(** 创建作用域错误 *)
let create_scope_error msg =
  "作用域错误: " ^ msg

(** 创建模式匹配错误 *)
let create_pattern_error msg =
  "模式匹配错误: " ^ msg

(** 创建函数调用错误 *)
let create_function_call_error msg =
  "函数调用错误: " ^ msg