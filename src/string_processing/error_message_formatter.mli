(** 骆言编译器通用错误消息格式化器接口 - 第九阶段代码重复消除 *)

(** 通用错误消息格式化器 *)
module Error_message_formatter : sig
  val file_not_found : string -> string
  (** 文件操作错误 *)

  val file_read_error : string -> string
  val file_write_error : string -> string
  val file_operation_error : string -> string -> string

  val type_mismatch : string -> string
  (** 类型相关错误 *)

  val unknown_type : string -> string
  val invalid_type_operation : string -> string

  val parse_failure : string -> string -> string
  (** 解析错误 *)

  val json_parse_error : string -> string
  val test_case_parse_error : string -> string
  val config_parse_error : string -> string
  val config_list_parse_error : string -> string
  val comprehensive_test_parse_error : string -> string
  val summary_items_parse_error : string -> string

  val unknown_checker_type : string -> string
  (** 检查器错误 *)

  val unexpected_exception : exn -> string
  (** 通用异常处理 *)

  val generic_error : string -> string -> string

  val undefined_variable : string -> string
  (** 变量相关错误 *)

  val variable_already_defined : string -> string

  val function_not_found : string -> string
  (** 函数相关错误 *)

  val function_param_mismatch : string -> int -> int -> string

  val module_not_found : string -> string
  (** 模块相关错误 *)

  val member_not_found : string -> string -> string

  val invalid_operation : string -> string
  (** 操作错误 *)

  val pattern_match_failure : string -> string
end
