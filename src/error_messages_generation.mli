(** 错误消息生成模块接口 - Error Message Generation Module Interface *)

val type_mismatch_error : Types.typ -> Types.typ -> string
(** 生成详细的类型不匹配错误消息
    @param expected_type 期望的类型
    @param actual_type 实际的类型
    @return 格式化的错误消息字符串 *)

val undefined_variable_error : string -> string list -> string
(** 生成未定义变量的建议错误消息
    @param var_name 未定义的变量名
    @param available_vars 当前作用域中可用的变量名列表
    @return 格式化的错误消息字符串，包含可用变量的建议 *)

val function_arity_error : int -> int -> string
(** 生成函数调用参数不匹配的详细错误消息
    @param expected_count 期望的参数数量
    @param actual_count 实际提供的参数数量
    @return 格式化的错误消息字符串 *)

val pattern_match_error : Types.typ -> string
(** 生成模式匹配失败的详细错误消息
    @param value_type 值的类型
    @return 格式化的错误消息字符串 *)
