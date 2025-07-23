(** 骆言编译器错误消息格式化模块接口

    本模块专注于错误消息的统一格式化，提供一致的错误处理和消息生成功能。 包含编译过程中的各种错误类型：语法错误、类型错误、运行时错误和文件操作错误。

    从unified_formatter.ml中拆分而来，专注于错误消息的标准化格式化。

    @author 骆言AI代理
    @version 1.0
    @since 2025-07-22 *)

(** 错误消息统一格式化模块 *)
module ErrorMessages : sig
  val undefined_variable : string -> string
  (** 变量相关错误 *)

  val variable_already_defined : string -> string
  val variable_suggestion : string -> string list -> string

  val function_not_found : string -> string
  (** 函数相关错误 *)

  val function_param_count_mismatch : string -> int -> int -> string
  val function_param_count_mismatch_simple : int -> int -> string
  val function_needs_params : string -> int -> int -> string
  val function_excess_params : string -> int -> int -> string

  val type_mismatch : string -> string -> string
  (** 类型相关错误 *)

  val type_mismatch_detailed : string -> string -> string -> string
  val unknown_type : string -> string
  val invalid_type_operation : string -> string
  val invalid_argument_type : string -> string -> string

  val unexpected_token : string -> string
  (** Token和语法错误 *)

  val expected_token : string -> string -> string
  val syntax_error : string -> string

  val file_not_found : string -> string
  (** 文件操作错误 *)

  val file_read_error : string -> string
  val file_write_error : string -> string
  val file_operation_error : string -> string -> string

  val module_not_found : string -> string
  (** 模块相关错误 *)

  val member_not_found : string -> string -> string

  val config_parse_error : string -> string
  (** 配置错误 *)

  val invalid_config_value : string -> string -> string

  val invalid_operation : string -> string
  (** 操作错误 *)

  val pattern_match_failure : string -> string

  val generic_error : string -> string -> string
  (** 通用错误 *)

  val compilation_error : string -> string -> string
  val runtime_error : string -> string -> string

  val variable_spell_correction : string -> string -> string
  (** 变量拼写纠正消息 *)
end

(** 错误处理模块 *)
module ErrorHandling : sig
  val safe_operation_error : string -> string -> string
  (** 安全操作错误 *)

  val unexpected_error_format : string -> string -> string

  val lexical_error : string -> string
  (** 词法错误格式化 *)

  val lexical_error_with_char : string -> string

  val parse_error : string -> string
  (** 解析错误格式化 *)

  val parse_error_syntax : string -> string
  val parse_failure_with_token : string -> string -> string -> string

  val runtime_error : string -> string
  (** 运行时错误格式化 *)

  val runtime_arithmetic_error : string -> string

  val error_with_position : string -> string -> int -> string
  (** 带位置的错误格式化 *)

  val lexical_error_with_position : string -> int -> string -> string

  val error_with_detail : string -> string -> string
  (** 通用错误类别格式化 *)

  val category_error : string -> string -> string
  val simple_category_error : string -> string

  val invalid_argument : string -> string -> string -> string
  (** 参数验证 *)

  val null_argument_error : string -> string

  val index_out_of_bounds : int -> int -> string
  (** 边界检查 *)

  val array_bounds_error : int -> int -> string

  val invalid_state : string -> string -> string
  (** 状态错误 *)

  val operation_not_supported : string -> string

  val resource_exhausted : string -> string
  (** 资源错误 *)

  val resource_not_available : string -> string
end

(** 增强错误消息模块 *)
module EnhancedErrorMessages : sig
  val undefined_variable_enhanced : string -> string
  (** 变量相关增强错误 *)

  val variable_already_defined_enhanced : string -> string

  val module_member_not_found : string -> string -> string
  (** 模块相关增强错误 *)

  val file_not_found_enhanced : string -> string
  (** 文件相关增强错误 *)

  val token_expectation_error : string -> string -> string
  (** Token相关增强错误 *)

  val unexpected_token_error : string -> string

  val codegen_error : string -> string -> string -> string
  (** 代码生成错误 *)

  val unsupported_feature : string -> string -> string

  val empty_collection : string -> string
  (** 数据结构错误 *)

  val duplicate_key : string -> string

  val parser_state_error : string -> string -> string
  (** 解析错误 *)

  val lexer_error : string -> string -> string

  val type_inference_failure : string -> string
  (** 类型系统错误 *)

  val circular_type_dependency : string -> string

  val execution_timeout : string -> string
  (** 执行错误 *)

  val memory_limit_exceeded : string -> string
end

(** 错误处理格式化器模块 *)
module ErrorHandlingFormatter : sig
  val format_error_statistics : string -> int -> string
  (** 错误统计格式化 *)

  val format_error_message : string -> string -> string
  (** 错误消息和上下文组合格式化 *)

  val format_recovery_info : string -> string
  (** 错误恢复信息格式化 *)

  val format_error_context : string -> int -> string
  (** 错误上下文格式化 *)

  val format_unified_error : string -> string -> string
  (** 统一错误格式化 *)

  val format_error_suggestion : int -> string -> string
  (** 错误建议格式化 *)

  val format_error_hint : int -> string -> string
  (** 错误提示格式化 *)

  val format_confidence_score : int -> string
  (** AI置信度格式化 *)

  val format_exception : string -> string -> string
  (** 异常信息格式化 *)

  val format_stack_trace : string list -> string

  val warning_message : string -> string -> string
  (** 警告消息 *)

  val deprecation_warning : string -> string -> string

  val debug_trace : string -> string -> string
  (** 调试信息 *)

  val performance_warning : string -> int -> int -> string
end
