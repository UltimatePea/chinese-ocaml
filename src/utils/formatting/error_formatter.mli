(** 骆言统一错误格式化工具模块接口 - Unified Error Formatting Interface *)

(** 错误类型定义 *)
type error_severity = Fatal  (** 致命错误 *) | Error  (** 错误 *) | Warning  (** 警告 *) | Info  (** 信息 *)

type position_info = { filename : string; line : int; column : int option }
(** 位置信息类型 *)

(** 错误消息格式化工具 *)
module Message : sig
  val format_error : error_severity -> string -> string
  (** 格式化基本错误消息 *)

  val format_error_with_position : error_severity -> string -> position_info -> string
  (** 格式化带位置的错误消息 *)

  val format_lexical_error : string -> string -> string
  (** 格式化词法错误 *)

  val format_parse_error : string -> string -> string
  (** 格式化语法错误 *)

  val format_semantic_error : string -> string -> string
  (** 格式化语义错误 *)

  val format_type_error : string -> string -> string
  (** 格式化类型错误 *)

  val format_runtime_error : string -> string -> string
  (** 格式化运行时错误 *)
end

(** 错误恢复建议工具 *)
module Recovery : sig
  val suggest_recovery : string -> string list
  (** 生成错误恢复建议 *)

  val format_suggestions : string list -> string
  (** 格式化恢复建议 *)

  val combine_error_and_suggestions : string -> string list -> string
  (** 组合错误消息和建议 *)
end

(** 错误统计和报告工具 *)
module Statistics : sig
  type error_stats = { fatal_count : int; error_count : int; warning_count : int; info_count : int }
  (** 错误统计信息 *)

  val format_error_summary : error_stats -> string
  (** 格式化错误统计报告 *)

  val has_blocking_errors : error_stats -> bool
  (** 判断是否有阻塞性错误 *)
end

(** 用户友好的错误消息工具 *)
module UserFriendly : sig
  val make_user_friendly : string -> string
  (** 将技术错误消息转换为用户友好的描述 *)

  val add_solution_hint : string -> string -> string
  (** 添加解决方案提示 *)

  val format_detailed_report : string -> position_info option -> string list -> string
  (** 格式化详细错误报告 *)
end

(** 内部格式化辅助函数 *)
module Internal_formatter : sig
  val format_key_value : string -> string -> string
  val format_position : string -> int -> int -> string
  val format_position_no_col : string -> int -> string
  val format_context_info : int -> string -> string
  val format_triple_with_dash : string -> string -> string -> string
  val format_category_error : string -> string -> string

  (** 测试消息格式化器 - 第九阶段扩展 *)
  module Test_message_formatter : sig
    val json_parse_failure : string -> string
    (** JSON相关测试消息 *)

    val empty_json_failure : exn -> string
    val error_type_mismatch : exn -> string
    val should_produce_error : string -> string
    val wrong_error_type : string -> exn -> string

    val structure_validation_failure : exn -> string
    (** 韵律相关测试消息 *)

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

    val dimension_correct_message : string -> string -> string
    val evaluation_failure_message : string -> string -> string -> string
    val context_creation_message : string -> string
    val context_creation_failure : string -> string -> string
    val empty_poem_failure : string -> string
    val dimension_count_message : string -> string
    val complete_evaluation_failure : string -> string -> string
    val unicode_processing_message_with_feature : string -> string -> string
    val unicode_processing_failure : string -> string -> string -> string
    val long_poem_failure : string -> string
    val abnormal_char_failure : string -> string -> string
    val extreme_case_failure : string -> string -> string
    val abnormal_char_message : string -> string
    val extreme_case_message : string -> string

    val unexpected_exception : exn -> string
    (** 通用测试异常消息 *)
  end
end
