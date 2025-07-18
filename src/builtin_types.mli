(** 骆言内置类型转换函数模块接口 - Chinese Programming Language Builtin Type Conversion Functions Module Interface

    这个模块提供了骆言编程语言的类型转换相关内置函数，包括基本数据类型 之间的相互转换功能。类型转换是程序中数据处理的重要组成部分， 为不同类型数据的交互和表示提供标准化接口。

    该模块的主要功能包括：
    - 数值类型转换（整数、浮点数）
    - 字符串与数值类型的相互转换
    - 布尔值的字符串表示
    - 安全的转换错误处理

    所有类型转换函数都包含适当的错误处理，确保转换的安全性和可靠性。

    @author 骆言项目组
    @since 0.1.0 *)

open Value_operations

val int_to_string_function : runtime_value list -> runtime_value
(** 整数转字符串

    @param args 参数列表，包含[整数]
    @return 整数的字符串表示

    将整数值转换为其十进制字符串表示。

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当参数不是整数类型时 *)

val float_to_string_function : runtime_value list -> runtime_value
(** 浮点数转字符串

    @param args 参数列表，包含[浮点数]
    @return 浮点数的字符串表示

    将浮点数值转换为其字符串表示，使用OCaml的标准格式。

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当参数不是浮点数类型时 *)

val string_to_int_function : runtime_value list -> runtime_value
(** 字符串转整数

    @param args 参数列表，包含[字符串]
    @return 解析得到的整数值

    将字符串解析为整数值，支持标准的整数格式。

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当参数不是字符串类型时
    @raise RuntimeError 当字符串无法解析为整数时 *)

val string_to_float_function : runtime_value list -> runtime_value
(** 字符串转浮点数

    @param args 参数列表，包含[字符串]
    @return 解析得到的浮点数值

    将字符串解析为浮点数值，支持标准的浮点数格式。

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当参数不是字符串类型时
    @raise RuntimeError 当字符串无法解析为浮点数时 *)

val int_to_float_function : runtime_value list -> runtime_value
(** 整数转浮点数

    @param args 参数列表，包含[整数]
    @return 转换后的浮点数值

    将整数值转换为等价的浮点数值，这是一个无损转换。

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当参数不是整数类型时 *)

val float_to_int_function : runtime_value list -> runtime_value
(** 浮点数转整数

    @param args 参数列表，包含[浮点数]
    @return 转换后的整数值

    将浮点数值转换为整数值，使用截断（向零取整）方式。 这可能是有损转换，小数部分会被丢弃。

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当参数不是浮点数类型时 *)

val bool_to_string_function : runtime_value list -> runtime_value
(** 布尔值转字符串

    @param args 参数列表，包含[布尔值]
    @return 布尔值的中文字符串表示

    将布尔值转换为中文字符串表示：
    - true → "真"
    - false → "假"

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当参数不是布尔类型时 *)

val type_conversion_functions : (string * runtime_value) list
(** 类型转换相关内置函数表

    包含所有类型转换函数的名称和实现的映射表，用于函数查找和调用。

    包含的函数：
    - "整数转字符串": 整数到字符串的转换
    - "浮点数转字符串": 浮点数到字符串的转换
    - "字符串转整数": 字符串到整数的转换
    - "字符串转浮点数": 字符串到浮点数的转换
    - "整数转浮点数": 整数到浮点数的转换
    - "浮点数转整数": 浮点数到整数的转换
    - "布尔值转字符串": 布尔值到字符串的转换 *)
