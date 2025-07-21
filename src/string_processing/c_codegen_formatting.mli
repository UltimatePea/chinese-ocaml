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

(** {1 环境操作代码生成} *)

val env_bind : string -> string -> string
(** [env_bind var_name expr_code] 生成环境绑定代码 *)

val env_lookup : string -> string
(** [env_lookup var_name] 生成环境查找代码 *)

(** {1 运行时类型包装} *)

val luoyan_int : int -> string
(** [luoyan_int i] 生成整数包装代码 *)

val luoyan_float : float -> string
(** [luoyan_float f] 生成浮点数包装代码 *)

val luoyan_string : string -> string
(** [luoyan_string s] 生成字符串包装代码 *)

val luoyan_bool : bool -> string
(** [luoyan_bool b] 生成布尔值包装代码 *)

val luoyan_unit : unit -> string
(** [luoyan_unit ()] 生成unit包装代码 *)

(** {1 C语言头文件包含} *)

val include_header : string -> string
(** [include_header header] 生成系统头文件包含代码 *)

val include_local_header : string -> string
(** [include_local_header header] 生成本地头文件包含代码 *)

(** {1 递归函数处理} *)

val recursive_binding : string -> string -> string
(** [recursive_binding var_name expr_code] 生成递归函数绑定代码 *)

(** {1 C语言控制结构} *)

val if_statement : string -> string -> string option -> string
(** [if_statement condition then_code else_code_opt] 生成if语句代码，支持可选的else分支 *)

(** {1 C语言表达式格式化} *)

val assignment : string -> string -> string
(** [assignment var_name expr] 生成赋值语句 *)

val return_statement : string -> string
(** [return_statement expr] 生成return语句 *)

val function_declaration : string -> string -> string list -> string
(** [function_declaration return_type func_name params] 生成函数声明代码 *)
