(** 骆言内置数学函数模块接口 - Chinese Programming Language Builtin Math Functions Module Interface

    这个模块提供了骆言编程语言的数学运算相关内置函数，包括基础的 数值计算、统计函数、范围生成等数学操作功能。数学函数是编程语言 的基础组件，为数值计算和数据分析提供核心支持。

    该模块的主要功能包括：
    - 数值序列生成（范围函数）
    - 统计计算（求和、最大值、最小值）
    - 数值类型的自动转换和兼容性处理

    所有数学函数都支持整数和浮点数的混合运算，自动进行类型转换， 确保计算结果的正确性。

    @author 骆言项目组
    @since 0.1.0 *)

open Value_operations

val range_function : runtime_value list -> runtime_value
(** 生成指定范围内的整数序列

    @param args 参数列表，包含[起始值; 结束值]
    @return 包含范围内所有整数的列表值

    参数要求：
    - 第一个参数：整数，表示序列的起始值（包含）
    - 第二个参数：整数，表示序列的结束值（包含）

    如果起始值大于结束值，返回空列表。 生成的序列按升序排列，包含起始值和结束值。

    示例：范围(1, 5) 返回 [1; 2; 3; 4; 5]

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当参数不是整数类型时 *)

val sum_function : runtime_value list -> runtime_value
(** 计算数字列表的总和

    @param args 参数列表，包含[数字列表]
    @return 列表中所有数字的总和

    支持整数和浮点数的混合计算：
    - 纯整数列表：返回整数结果
    - 包含浮点数的列表：返回浮点数结果
    - 自动进行类型提升（整数→浮点数）

    空列表的总和为0。

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当参数不是列表或列表包含非数字元素时 *)

val max_function : runtime_value list -> runtime_value
(** 计算数字列表中的最大值

    @param args 参数列表，包含[数字列表]
    @return 列表中的最大值

    支持整数和浮点数的混合比较：
    - 自动进行类型转换确保比较的准确性
    - 返回值类型取决于参与比较的数值类型

    @raise RuntimeError 当参数数量不正确或列表为空时
    @raise TypeError 当参数不是列表或列表包含非数字元素时 *)

val min_function : runtime_value list -> runtime_value
(** 计算数字列表中的最小值

    @param args 参数列表，包含[数字列表]
    @return 列表中的最小值

    支持整数和浮点数的混合比较：
    - 自动进行类型转换确保比较的准确性
    - 返回值类型取决于参与比较的数值类型

    @raise RuntimeError 当参数数量不正确或列表为空时
    @raise TypeError 当参数不是列表或列表包含非数字元素时 *)

val math_functions : (string * runtime_value) list
(** 数学相关内置函数表

    包含所有数学操作函数的名称和实现的映射表，用于函数查找和调用。

    包含的函数：
    - "范围": 生成整数序列
    - "求和": 计算列表总和
    - "最大值": 查找最大值
    - "最小值": 查找最小值 *)
