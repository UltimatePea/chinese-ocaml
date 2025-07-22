(** C代码生成格式化模块

    本模块专门处理C代码生成时的字符串格式化， 提供统一的C代码生成工具函数。

    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 Issue #708 重构 *)

(** {1 函数调用格式化} *)

val function_call : string -> string list -> string
(** [function_call func_name args] 生成函数调用代码，格式为 "func_name(arg1, arg2, ...)" *)

val binary_function_call : string -> string -> string -> string
(** [binary_function_call func_name e1_code e2_code] 生成双参数函数调用代码 *)

(** {1 特定类型的C代码生成} *)

val string_equality_check : string -> string -> string
(** [string_equality_check expr_var escaped_string] 生成字符串相等性检查代码 *)

val type_conversion : string -> string -> string
(** [type_conversion target_type expr] 生成类型转换代码，格式为 "(target_type)expr" *)
