(** 统一错误消息模板模块

    本模块提供了所有错误消息的统一格式化功能， 用于确保错误消息的一致性和可维护性。

    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 Issue #708 重构 *)

(** {1 函数参数错误模板} *)

val function_param_error : string -> int -> int -> string
(** [function_param_error function_name expected_count actual_count] 生成函数参数数量错误消息 *)

val function_param_type_error : string -> string -> string
(** [function_param_type_error function_name expected_type] 生成函数参数类型错误消息 *)

val function_single_param_error : string -> string
(** [function_single_param_error function_name] 生成期望单个参数的错误消息 *)

val function_double_param_error : string -> string
(** [function_double_param_error function_name] 生成期望两个参数的错误消息 *)

val function_no_param_error : string -> string
(** [function_no_param_error function_name] 生成不需要参数的错误消息 *)

(** {1 类型错误模板} *)

val type_mismatch_error : string -> string -> string
(** [type_mismatch_error expected_type actual_type] 生成类型不匹配错误消息 *)

val undefined_variable_error : string -> string
(** [undefined_variable_error var_name] 生成未定义变量错误消息 *)

val index_out_of_bounds_error : int -> int -> string
(** [index_out_of_bounds_error index length] 生成数组索引越界错误消息 *)

(** {1 文件操作错误模板} *)

val file_operation_error : string -> string -> string
(** [file_operation_error operation filename] 生成文件操作错误消息 *)

(** {1 通用功能错误模板} *)

val generic_function_error : string -> string -> string
(** [generic_function_error function_name error_desc] 生成通用函数错误消息 *)

