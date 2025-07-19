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
  val list_operation_error : string -> string
end

(** 转换和类型转换格式化 *)
module Conversions : sig
  val type_conversion : string -> string -> string
  val casting_error : string -> string -> string
end
