(** 骆言内置函数错误处理模块接口 - Chinese Programming Language Builtin Functions Error Handling Module Interface

    这个模块提供了骆言编程语言内置函数的统一错误处理机制，包括参数
    验证、类型检查、边界检查等安全性保障功能。错误处理是语言运行时
    安全性的基础，确保所有内置函数调用的正确性和可靠性。

    该模块的主要功能包括：
    - 参数数量和类型的验证
    - 统一的错误消息格式和报告
    - 类型安全的值提取函数
    - 专门的边界和有效性检查

    所有错误处理函数都提供清晰的中文错误消息，便于开发者理解和调试。

    @author 骆言项目组
    @since 0.1.0
*)

open Value_operations

val runtime_error : string -> 'a
(** 抛出运行时错误
    
    @param msg 错误消息
    @raises RuntimeError 总是抛出运行时错误
    
    用于在内置函数中抛出统一格式的运行时错误，提供一致的错误处理接口。 *)

val check_args_count : int -> int -> string -> unit
(** 检查参数数量是否正确
    
    @param expected_count 期望的参数数量
    @param actual_count 实际的参数数量
    @param function_name 函数名称（用于错误消息）
    
    @raise RuntimeError 当参数数量不匹配时 *)

val check_single_arg : runtime_value list -> string -> runtime_value
(** 检查并提取单个参数
    
    @param args 参数列表
    @param function_name 函数名称（用于错误消息）
    @return 单个参数值
    
    @raise RuntimeError 当参数数量不是1时 *)

val check_double_args : runtime_value list -> string -> runtime_value * runtime_value
(** 检查并提取两个参数
    
    @param args 参数列表
    @param function_name 函数名称（用于错误消息）
    @return 两个参数值的元组
    
    @raise RuntimeError 当参数数量不是2时 *)

val check_no_args : runtime_value list -> string -> unit
(** 检查参数列表为空
    
    @param args 参数列表
    @param function_name 函数名称（用于错误消息）
    
    @raise RuntimeError 当参数列表不为空时 *)

val expect_string : runtime_value -> string -> string
(** 期望并提取字符串值
    
    @param value 要检查的运行时值
    @param function_name 函数名称（用于错误消息）
    @return 提取的字符串
    
    @raise RuntimeError 当值不是字符串类型时 *)

val expect_int : runtime_value -> string -> int
(** 期望并提取整数值
    
    @param value 要检查的运行时值
    @param function_name 函数名称（用于错误消息）
    @return 提取的整数
    
    @raise RuntimeError 当值不是整数类型时 *)

val expect_float : runtime_value -> string -> float
(** 期望并提取浮点数值
    
    @param value 要检查的运行时值
    @param function_name 函数名称（用于错误消息）
    @return 提取的浮点数
    
    @raise RuntimeError 当值不是浮点数类型时 *)

val expect_bool : runtime_value -> string -> bool
(** 期望并提取布尔值
    
    @param value 要检查的运行时值
    @param function_name 函数名称（用于错误消息）
    @return 提取的布尔值
    
    @raise RuntimeError 当值不是布尔类型时 *)

val expect_list : runtime_value -> string -> runtime_value list
(** 期望并提取列表值
    
    @param value 要检查的运行时值
    @param function_name 函数名称（用于错误消息）
    @return 提取的列表
    
    @raise RuntimeError 当值不是列表类型时 *)

val expect_array : runtime_value -> string -> runtime_value array
(** 期望并提取数组值
    
    @param value 要检查的运行时值
    @param function_name 函数名称（用于错误消息）
    @return 提取的数组
    
    @raise RuntimeError 当值不是数组类型时 *)

val expect_builtin_function : runtime_value -> string -> (runtime_value list -> runtime_value)
(** 期望并提取内置函数值
    
    @param value 要检查的运行时值
    @param function_name 函数名称（用于错误消息）
    @return 提取的内置函数
    
    @raise RuntimeError 当值不是内置函数类型时 *)

val expect_number : runtime_value -> string -> runtime_value
(** 期望数值类型（整数或浮点数）
    
    @param value 要检查的运行时值
    @param function_name 函数名称（用于错误消息）
    @return 原始的数值类型值
    
    @raise RuntimeError 当值不是数值类型时 *)

val expect_string_or_list : runtime_value -> string -> runtime_value
(** 期望字符串或列表类型
    
    @param value 要检查的运行时值
    @param function_name 函数名称（用于错误消息）
    @return 原始的字符串或列表值
    
    @raise RuntimeError 当值不是字符串或列表类型时 *)

val expect_nonempty_list : runtime_value -> string -> runtime_value list
(** 期望并提取非空列表值
    
    @param value 要检查的运行时值
    @param function_name 函数名称（用于错误消息）
    @return 提取的非空列表
    
    @raise RuntimeError 当值不是列表类型或列表为空时 *)

val handle_file_error : string -> string -> (unit -> 'a) -> 'a
(** 处理文件操作错误
    
    @param operation 操作描述（如"读取"、"写入"）
    @param filename 文件名
    @param f 要执行的文件操作函数
    @return 操作结果
    
    @raise RuntimeError 当文件操作失败时，提供友好的错误消息 *)

val handle_higher_order_error : string -> 'a
(** 处理高阶函数错误
    
    @param function_name 函数名称
    @raises RuntimeError 总是抛出不支持用户定义函数的错误
    
    用于高阶函数中处理用户定义函数参数的情况。 *)

val check_array_bounds : int -> int -> string -> unit
(** 检查数组索引边界
    
    @param index 要检查的索引
    @param array_length 数组长度
    @param function_name 函数名称（用于错误消息）
    
    @raise RuntimeError 当索引超出数组边界时 *)

val expect_non_negative : runtime_value -> string -> int
(** 期望并提取非负整数值
    
    @param value 要检查的运行时值
    @param function_name 函数名称（用于错误消息）
    @return 提取的非负整数
    
    @raise RuntimeError 当值不是整数类型或为负数时 *)