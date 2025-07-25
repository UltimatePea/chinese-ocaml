(** 骆言编译器日志格式化模块接口

    本模块专注于日志和调试信息的格式化，提供统一的日志格式化接口。 包含不同级别的日志消息、编译器状态信息、性能日志和调试追踪功能。

    从unified_formatter.ml中拆分而来，专注于日志记录过程中的格式化需求。

    @author 骆言AI代理
    @version 1.0
    @since 2025-07-22 *)

(** 基础日志消息格式化模块 *)
module LogMessages : sig
  val debug : string -> string -> string
  (** 标准日志级别 *)

  val info : string -> string -> string
  val warning : string -> string -> string
  val error : string -> string -> string
  val trace : string -> string -> string

  val verbose : string -> string -> string
  (** 扩展日志级别 *)

  val fatal : string -> string -> string
  val perf : string -> string -> int -> string

  val structured_log : string -> string -> string -> string -> string
  (** 结构化日志 *)
end

(** 编译器状态消息格式化模块 *)
module CompilerMessages : sig
  val compiling_file : string -> string
  (** 基础编译状态 *)

  val compilation_complete : string -> string
  val compilation_failed : string -> string -> string

  val unsupported_chinese_symbol : string -> string
  (** 符号处理消息 *)

  val parsing_start : string -> string
  (** 详细编译阶段 *)

  val parsing_complete : string -> string
  val type_checking_start : string -> string
  val type_checking_complete : string -> string
  val code_generation_start : string -> string
  val code_generation_complete : string -> string

  val compilation_phase : string -> string -> string
  (** 编译进度 *)

  val compilation_progress : int -> int -> string -> string
end

(** 增强日志消息模块 *)
module EnhancedLogMessages : sig
  val compiling_file : string -> string
  (** 编译状态增强消息 *)

  val compilation_complete_stats : int -> float -> string

  val operation_start : string -> string
  (** 操作状态消息 *)

  val operation_complete : string -> float -> string
  val operation_failed : string -> float -> string -> string

  val format_timestamp : int -> int -> int -> int -> int -> int -> string
  (** 时间戳格式化 *)

  val format_unix_time : Unix.tm -> string

  val format_log_entry : string -> string -> string -> string -> string -> string -> string
  (** 完整日志消息格式化 *)

  val format_simple_log_entry : string -> string -> string -> string -> string -> string

  val debug_enhanced : string -> string -> string -> string
  (** 带模块名的日志消息增强 *)

  val info_enhanced : string -> string -> string -> string
  val warning_enhanced : string -> string -> string -> string
  val error_enhanced : string -> string -> string -> string

  val performance_start : string -> string
  (** 性能日志 *)

  val performance_end : string -> int -> string
  val memory_usage : string -> int -> int -> string

  val dev_checkpoint : string -> string -> string
  (** 开发者日志 *)

  val dev_assertion : string -> bool -> string

  val system_resource : string -> string -> string -> string
  (** 系统日志 *)

  val system_event : string -> string -> string

  val test_start : string -> string
  (** 测试日志 *)

  val test_pass : string -> string
  val test_fail : string -> string -> string
  val test_suite_summary : int -> int -> int -> string
end

(** 日志格式化器模块 *)
module LoggingFormatter : sig
  val format_timestamp : int -> int -> int -> int -> int -> int -> string
  (** 时间戳格式化 *)

  val format_log_entry : string -> string -> string
  (** 基础日志条目格式化 *)

  val format_simple_log_entry : string -> string -> string

  val format_log_level : string -> string
  (** 日志级别格式化 *)

  val format_migration_info : string -> string -> string
  (** 迁移信息格式化 *)

  val format_legacy_log : string -> string -> string
  (** 传统日志格式化 *)

  val format_core_log_message : string -> string -> string
  (** 核心日志消息格式化 *)

  val format_context_pair : string -> string -> string
  (** 上下文格式化 *)

  val format_context_group : string list -> string

  val format_migration_progress : int -> int -> float -> string
  (** 迁移进度报告格式化 *)

  val format_migration_suggestions : string -> string -> string -> string

  val format_multiline_log : string -> string -> string list -> string
  (** 多行日志格式化 *)

  val log_separator : int -> string -> string
  (** 日志分隔符和标题 *)

  val log_section_header : string -> string

  val format_json_log_entry : string -> string -> string -> string -> string
  (** 结构化日志JSON格式 *)

  val format_debug_context : string -> (string * string) list -> string
  (** 调试信息格式化 *)

  val format_error_stack : string -> string list -> string
  (** 错误堆栈格式化 *)
end

(** 调试格式化器模块 *)
module DebugFormatter : sig
  val format_variable_state : string -> string -> string -> string
  (** 变量状态格式化 *)

  val format_variable_list : (string * string * string) list -> string

  val format_function_call : string -> string list -> string -> string
  (** 函数调用追踪 *)

  val format_call_stack : string list -> string

  val format_expression_eval : string -> string -> string
  (** 表达式求值追踪 *)

  val format_step_by_step_eval : string list -> string

  val format_ast_node : string -> string -> string
  (** AST节点格式化 *)

  val format_ast_tree : string list -> int -> string
end
