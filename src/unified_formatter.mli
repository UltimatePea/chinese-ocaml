(** 骆言编译器统一格式化工具接口 - Phase 15.4: 模式重复消除 *)

(** 错误消息统一格式化 *)
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

  val variable_spell_correction : string -> string -> string
  (** 变量拼写纠正消息 *)
end

(** 编译器状态消息格式化 *)
module CompilerMessages : sig
  val compiling_file : string -> string
  val compilation_complete : string -> string
  val compilation_failed : string -> string -> string
  val unsupported_chinese_symbol : string -> string
end

(** C代码生成格式化 *)
module CCodegen : sig
  val function_call : string -> string list -> string
  (** 函数调用 *)

  val binary_function_call : string -> string -> string -> string
  val unary_function_call : string -> string -> string

  val luoyan_call : string -> int -> string -> string
  (** 骆言特定格式 *)

  val luoyan_bind_var : string -> string -> string
  val luoyan_string : string -> string
  val luoyan_int : int -> string
  val luoyan_float : float -> string
  val luoyan_bool : bool -> string
  val luoyan_unit : unit -> string
  val luoyan_equals : string -> string -> string
  val luoyan_let : string -> string -> string -> string
  val luoyan_function_create : string -> string -> string
  val luoyan_pattern_match : string -> string
  val luoyan_var_expr : string -> string -> string

  val luoyan_env_bind : string -> string -> string
  (** 环境绑定格式化 *)

  val luoyan_function_create_with_args : string -> string -> string

  val luoyan_string_equality_check : string -> string -> string
  (** 字符串相等性检查 *)

  val compilation_start_message : string -> string
  (** 编译日志消息 *)

  val compilation_status_message : string -> string -> string

  val c_template_with_includes : string -> string -> string -> string
  (** C模板格式化 *)

  val luoyan_catch : string -> string
  (** 异常捕获格式化 - Phase 3新增 *)

  val luoyan_try_catch : string -> string -> string -> string
  (** try-catch块格式化 - Phase 3新增 *)

  val luoyan_raise : string -> string
  (** raise表达式格式化 - Phase 3新增 *)

  val luoyan_combine : string list -> string
  (** 表达式组合格式化 - Phase 3新增 *)

  val luoyan_match_constructor : string -> string -> string
  (** 构造器模式匹配格式化 - Phase 3新增 *)

  val luoyan_include_module : string -> string
  (** 模块包含格式化 - Phase 3新增 *)

  val c_statement : string -> string
  (** C语句格式化 - Phase 3新增 *)

  val c_statement_sequence : string -> string -> string  
  (** C语句序列格式化 - Phase 3新增 *)

  val c_statement_block : string list -> string
  (** C语句块格式化 - Phase 3新增 *)
end

(** 调试和日志格式化 *)
module LogMessages : sig
  val debug : string -> string -> string
  val info : string -> string -> string
  val warning : string -> string -> string
  val error : string -> string -> string
  val trace : string -> string -> string
end

(** 位置信息格式化 *)
module Position : sig
  val format_position : string -> int -> int -> string
  val format_error_with_position : string -> string -> string -> string
  val format_optional_position : (string * int * int) option -> string
end

(** 通用格式化工具 *)
module General : sig
  val format_identifier : string -> string
  val format_function_signature : string -> string list -> string
  val format_type_signature : string -> string list -> string
  val format_module_path : string list -> string
  val format_list : string list -> string -> string
  val format_key_value : string -> string -> string
  val format_chinese_list : string list -> string
  val format_variable_definition : string -> string
  val format_context_info : int -> string -> string
end

(** 索引和数组操作格式化 *)
module Collections : sig
  val index_out_of_bounds : int -> int -> string
  val array_access_error : string -> int -> string
  val array_bounds_error : int -> int -> string
  val list_operation_error : string -> string
end

(** 转换和类型转换格式化 *)
module Conversions : sig
  val type_conversion : string -> string -> string
  val casting_error : string -> string -> string
end

(** 错误处理和安全操作格式化 *)
module ErrorHandling : sig
  val safe_operation_error : string -> string -> string
  val unexpected_error_format : string -> string -> string

  val lexical_error : string -> string
  (** 词法错误格式化 *)

  val lexical_error_with_char : string -> string

  val parse_error : string -> string
  (** 解析错误格式化 *)

  val parse_error_syntax : string -> string
  
  val parse_failure_with_token : string -> string -> string -> string
  (** 解析失败错误格式化 - Phase 2专用模式 *)

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
end

(** Token格式化 - 第二阶段扩展 *)
module TokenFormatting : sig
  (** 基础Token类型格式化 *)
  val format_int_token : int -> string
  val format_float_token : float -> string
  val format_string_token : string -> string
  val format_identifier_token : string -> string
  val format_quoted_identifier_token : string -> string

  (** Token错误消息 *)
  val token_expectation : string -> string -> string
  val unexpected_token : string -> string

  (** 复合Token格式化 *)
  val format_keyword_token : string -> string
  val format_operator_token : string -> string
  val format_delimiter_token : string -> string
  val format_boolean_token : bool -> string

  (** 特殊Token格式化 *)
  val format_eof_token : unit -> string
  val format_newline_token : unit -> string
  val format_whitespace_token : unit -> string
  val format_comment_token : string -> string

  (** Token位置信息结合格式化 *)
  val format_token_with_position : string -> int -> int -> string
end

(** 增强错误消息 - 第二阶段扩展 *)
module EnhancedErrorMessages : sig
  (** 变量相关增强错误 *)
  val undefined_variable_enhanced : string -> string
  val variable_already_defined_enhanced : string -> string
  
  (** 模块相关增强错误 *)
  val module_member_not_found : string -> string -> string
  
  (** 文件相关增强错误 *)
  val file_not_found_enhanced : string -> string
  
  (** Token相关增强错误 *)
  val token_expectation_error : string -> string -> string
  val unexpected_token_error : string -> string
end

(** 增强位置信息 - 第二阶段扩展 *)
module EnhancedPosition : sig
  (** 基础位置格式化变体 *)
  val simple_line_col : int -> int -> string
  val parenthesized_line_col : int -> int -> string
  
  (** 范围位置格式化 *)
  val range_position : int -> int -> int -> int -> string
  
  (** 错误位置标记 *)
  val error_position_marker : int -> int -> string
  
  (** 与现有格式兼容的包装函数 *)
  val format_position_enhanced : string -> int -> int -> string
  val format_error_with_enhanced_position : string -> string -> string -> string
end

(** C代码生成增强 - 第二阶段扩展 *)
module EnhancedCCodegen : sig
  (** 类型转换 *)
  val type_cast : string -> string -> string
  
  (** 构造器匹配 *)
  val constructor_match : string -> string -> string
  
  (** 字符串相等性检查（转义版本）*)
  val string_equality_escaped : string -> string -> string
  
  (** 扩展的骆言函数调用 *)
  val luoyan_call_with_cast : string -> string -> string list -> string
  
  (** 复合C代码模式 *)
  val luoyan_conditional_binding : string -> string -> string -> string -> string
end

(** 诗词分析格式化 - Phase 3C 扩展 *)
module PoetryFormatting : sig
  (** 诗词评价报告 *)
  val evaluation_report : string -> string -> float -> string
  
  (** 韵组格式化 *)
  val rhyme_group : string -> string
  
  (** 字调错误 *)
  val tone_error : int -> string -> string -> string
  
  (** 诗句分析 *)
  val verse_analysis : int -> string -> string -> string -> string
  
  (** 诗词结构分析 *)
  val poetry_structure_analysis : string -> int -> int -> string

  (** Phase 3C 新增格式化函数 *)
  
  (** 文本长度信息格式化 *)
  val format_text_length_info : int -> string
  
  (** 分类统计项格式化 *)
  val format_category_count : string -> int -> string
  
  (** 韵组统计项格式化 *)
  val format_rhyme_group_count : string -> int -> string
  
  (** 字符查找错误格式化 *)
  val format_character_lookup_error : string -> string -> string
  
  (** 韵律数据统计格式化 *)
  val format_rhyme_data_stats : int -> int -> string
  
  (** 诗词评价详细报告格式化 *)
  val format_evaluation_detailed_report : string -> string -> float -> string -> string
  
  (** 评分维度格式化 *)
  val format_dimension_score : string -> float -> string
  
  (** 韵律验证错误格式化 *)
  val format_rhyme_validation_error : int -> string -> string
  
  (** 缓存管理错误格式化 *)
  val format_cache_duplicate_error : string -> int -> string
  
  (** 数据加载错误格式化 *)
  val format_data_loading_error : string -> string -> string
  
  (** 字符组查找错误格式化 *)
  val format_group_not_found_error : string -> string
  
  (** JSON解析错误格式化 *)
  val format_json_parse_error : string -> string -> string
  
  (** 灰韵组数据统计格式化 *)
  val format_hui_rhyme_stats : string -> int -> int -> string -> string
  
  (** 数据完整性验证格式化 *)
  val format_data_integrity_success : int -> string
  val format_data_integrity_failure : int -> int -> string
  val format_data_integrity_exception : string -> string
end

(** 编译和日志增强 - Printf.sprintf统一化阶段2 *)
module EnhancedLogMessages : sig
  (** 编译状态增强消息 *)
  val compiling_file : string -> string
  val compilation_complete_stats : int -> float -> string
  
  (** 操作状态消息 - Phase 2 统一的高频模式 *)
  val operation_start : string -> string
  val operation_complete : string -> float -> string
  val operation_failed : string -> float -> string -> string
  
  (** 时间戳格式化 - 统一日期时间格式 *)
  val format_timestamp : int -> int -> int -> int -> int -> int -> string
  val format_unix_time : Unix.tm -> string
  
  (** 完整日志消息格式化 *)
  val format_log_entry : string -> string -> string -> string -> string -> string -> string
  val format_simple_log_entry : string -> string -> string -> string -> string -> string
  
  (** 带模块名的日志消息增强 *)
  val debug_enhanced : string -> string -> string -> string
  val info_enhanced : string -> string -> string -> string
  val warning_enhanced : string -> string -> string -> string
  val error_enhanced : string -> string -> string -> string
end

(** 类型系统格式化 - Phase 3B 新增 *)
module TypeFormatter : sig
  (** 函数类型格式化 *)
  val format_function_type : string -> string -> string
  
  (** 列表类型格式化 *)
  val format_list_type : string -> string
  
  (** 构造类型格式化 *)
  val format_construct_type : string -> string list -> string
  
  (** 引用类型格式化 *)
  val format_reference_type : string -> string
  
  (** 数组类型格式化 *)
  val format_array_type : string -> string
  
  (** 类类型格式化 *)
  val format_class_type : string -> string -> string
  
  (** 元组类型格式化 *)
  val format_tuple_type : string list -> string
  
  (** 记录类型格式化 *)
  val format_record_type : string -> string
  
  (** 对象类型格式化 *)
  val format_object_type : string -> string
  
  (** 多态变体类型格式化 *)
  val format_variant_type : string -> string
end

(** 报告和统计格式化 *)
module ReportFormatting : sig
  val token_registry_stats : int -> int -> string -> string
  val category_count_item : string -> int -> string
  val token_compatibility_report : int -> string -> string
  val detailed_token_compatibility_report : int -> string -> string
end
