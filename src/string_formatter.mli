(** 骆言字符串格式化工具模块接口 - String Formatting Utilities Interface *)

(** C代码生成格式化工具 *)
module CCodegen : sig
  (** 格式化函数调用 *)
  val format_function_call : string -> string list -> string

  (** 格式化二元运算 *)
  val format_binary_op : string -> string -> string -> string

  (** 格式化一元运算 *)
  val format_unary_op : string -> string -> string

  (** 格式化变量绑定 *)
  val format_var_binding : string -> string -> string

  (** 格式化字符串字面量 *)
  val format_string_literal : string -> string

  (** 格式化整数字面量 *)
  val format_int_literal : int -> string

  (** 格式化浮点数字面量 *)
  val format_float_literal : float -> string

  (** 格式化布尔字面量 *)
  val format_bool_literal : bool -> string

  (** 格式化单元字面量 *)
  val format_unit_literal : unit -> string

  (** 格式化等值比较 *)
  val format_equality_check : string -> string -> string

  (** 格式化let表达式 *)
  val format_let_expr : string -> string -> string -> string

  (** 格式化函数定义 *)
  val format_function_def : string -> string -> string

  (** 格式化模式匹配 *)
  val format_pattern_match : string -> string

  (** 格式化变量表达式 *)
  val format_var_expr : string -> string -> string
end

(** 错误消息格式化工具 *)
module ErrorMessages : sig
  (** 格式化参数数量不匹配错误 *)
  val format_param_count_mismatch : int -> int -> string

  (** 格式化参数缺失填充消息 *)
  val format_missing_params_filled : int -> int -> int -> string

  (** 格式化多余参数忽略消息 *)
  val format_extra_params_ignored : int -> int -> int -> string

  (** 格式化意外词元错误 *)
  val format_unexpected_token : string -> string

  (** 格式化语法错误 *)
  val format_syntax_error : string -> string -> string

  (** 格式化类型错误 *)
  val format_type_error : string -> string -> string
end

(** 日志格式化工具 *)
module LogMessages : sig
  (** 格式化调试消息 *)
  val format_debug_message : string -> string -> string

  (** 格式化信息消息 *)
  val format_info_message : string -> string -> string

  (** 格式化警告消息 *)
  val format_warning_message : string -> string -> string

  (** 格式化错误消息 *)
  val format_error_message : string -> string -> string
end

(** 通用格式化工具 *)
module General : sig
  (** 格式化标识符 *)
  val format_identifier : string -> string

  (** 格式化函数签名 *)
  val format_function_signature : string -> string list -> string

  (** 格式化类型签名 *)
  val format_type_signature : string -> string list -> string

  (** 格式化模块路径 *)
  val format_module_path : string list -> string

  (** 格式化列表 *)
  val format_list : string list -> string -> string

  (** 格式化键值对 *)
  val format_key_value : string -> string -> string
end