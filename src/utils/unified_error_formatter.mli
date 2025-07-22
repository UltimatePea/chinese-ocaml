(** 骆言编译器统一错误格式化器接口 *)

(** 统一错误格式化器模块 *)
module Unified_error_formatter : sig
  val undefined_variable : string -> string
  (** 变量和模块相关错误 *)

  val module_not_found : string -> string
  val member_not_found : string -> string -> string
  val variable_already_defined : string -> string

  val empty_scope_stack : string
  (** 常量错误消息 *)

  val empty_variable_name : string
  val unterminated_comment : string
  val unterminated_chinese_comment : string
  val unterminated_string : string
  val unterminated_quoted_identifier : string
  val invalid_char_in_quoted_identifier : string

  val ascii_symbols_disabled : string
  (** 符号和数字相关错误 *)

  val fullwidth_numbers_disabled : string
  val arabic_numbers_disabled : string
  val unsupported_chinese_symbol : string
  val identifiers_must_be_quoted : string
  val ascii_letters_as_keywords_only : string

  val type_mismatch : string -> string -> string
  (** 类型相关错误 *)

  val unknown_type : string -> string
  val invalid_type_operation : string -> string
  val type_mismatch_info : string -> string

  val function_not_found : string -> string
  (** 函数相关错误 *)

  val invalid_argument_count : int -> int -> string
  val invalid_argument_type : string -> string -> string
  val function_param_mismatch : string -> int -> int -> string

  val unexpected_token : string -> string
  (** 解析器错误 *)

  val expected_token : string -> string -> string
  val syntax_error : string -> string
  val parse_failure : string -> string -> string

  val json_parse_error : string -> string
  (** 专用解析错误 *)

  val json_parse_failure : string -> string
  val test_case_parse_error : string -> string
  val config_parse_error : string -> string
  val config_list_parse_error : string -> string
  val comprehensive_test_parse_error : string -> string
  val summary_items_parse_error : string -> string

  val ancient_list_syntax_error : string
  (** 古雅体语法相关错误 *)

  val division_by_zero : string
  (** 运行时错误 *)

  val stack_overflow : string
  val out_of_memory : string
  val invalid_operation : string -> string

  val file_not_found : string -> string
  (** 文件I/O错误 *)

  val file_read_error : string -> string
  val file_write_error : string -> string
  val file_operation_error : string -> string -> string

  val unknown_checker_type : string -> string
  (** 检查器错误 *)

  val unexpected_exception : exn -> string
  (** 通用异常处理 *)

  val generic_error : string -> string -> string
  val empty_json_failure : exn -> string
  val error_type_mismatch : exn -> string

  val unsupported_char_error : string -> string
  (** 通用错误模板 *)

  val format_position : string -> int -> int -> string
  (** 位置相关错误格式化 *)

  val format_position_no_col : string -> int -> string
  val position_error : string -> int -> int -> string -> string
  val line_col_error : int -> int -> string -> string

  (** 测试相关错误消息 *)
  module Test_errors : sig
    val should_produce_error : string -> string
    val wrong_error_type : string -> exn -> string

    val structure_validation_failure : exn -> string
    (** 韵律相关测试错误 *)

    val classification_test_failure : exn -> string
    val uniqueness_test_failure : exn -> string

    val character_found_message : string -> string
    (** 字符相关测试消息 *)

    val character_should_exist : string -> string
    val character_should_not_exist : string -> string
    val character_rhyme_group : string -> string
    val character_rhyme_match : string -> string -> bool -> string

    val unicode_processing_message : string -> string
    (** Unicode测试消息 *)

    val unicode_test_failure : exn -> string
    val simplified_recognition : string -> string
    val traditional_recognition : string -> string
    val traditional_simplified_failure : exn -> string

    val large_data_failure : exn -> string
    (** 性能测试消息 *)

    val query_performance_failure : exn -> string
    val memory_usage_failure : exn -> string
    val long_name_failure : exn -> string
    val special_char_failure : exn -> string
    val error_recovery_failure : exn -> string

    val score_range_message : string -> string -> string
    (** 艺术性评价测试消息 *)
  end

  val invalid_config_value : string -> string -> string
  (** 配置相关错误 *)

  val format_key_value : string -> string -> string
  (** 复合格式化函数 *)

  val format_context_info : int -> string -> string
  val format_triple_with_dash : string -> string -> string -> string
  val format_category_error : string -> string -> string
end

include module type of Unified_error_formatter
(** 导出主要函数到顶层 *)
