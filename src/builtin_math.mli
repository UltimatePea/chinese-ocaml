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

(** Issue #2189 数学模块核心功能完善 - 新增函数接口 *)

val sin_function : runtime_value list -> runtime_value
(** 计算正弦值 (使用泰勒级数) *)

val cos_function : runtime_value list -> runtime_value
(** 计算余弦值 (使用泰勒级数) *)

val tan_function : runtime_value list -> runtime_value
(** 计算正切值 *)

(** Issue #2189 新增反三角函数接口 *)

val asin_function : runtime_value list -> runtime_value
(** 计算反正弦值 - asin(x) 定义域 [-1, 1] 值域 [-π/2, π/2] *)

val acos_function : runtime_value list -> runtime_value
(** 计算反余弦值 - acos(x) 定义域 [-1, 1] 值域 [0, π] *)

val atan_function : runtime_value list -> runtime_value
(** 计算反正切值 - atan(x) 定义域 (-∞, ∞) 值域 (-π/2, π/2) *)

val mean_function : runtime_value list -> runtime_value
(** 计算数列平均值 *)

val variance_function : runtime_value list -> runtime_value
(** 计算数列方差 *)

val standard_deviation_function : runtime_value list -> runtime_value
(** 计算数列标准差 *)

val median_function : runtime_value list -> runtime_value
(** 计算数列中位数 *)

val optimized_prime_function : runtime_value list -> runtime_value
(** 优化的素数判断 *)

val prime_factorization_function : runtime_value list -> runtime_value
(** 质因数分解 *)

val euler_phi_function : runtime_value list -> runtime_value
(** 欧拉φ函数 - 计算小于等于n且与n互质的正整数个数 *)

val pi_constant : runtime_value list -> runtime_value
(** 圆周率常量 *)

val e_constant : runtime_value list -> runtime_value
(** 自然对数底常量 *)

val euler_constant : runtime_value list -> runtime_value
(** 欧拉常数 *)

val golden_ratio_constant : runtime_value list -> runtime_value
(** 黄金比例常量 *)

val math_functions : (string * runtime_value) list
(** 增强的数学相关内置函数表 - Issue #2189

    包含所有数学操作函数的名称和实现的映射表，用于函数查找和调用。

    总计21个函数（满足Issue #2189要求的20+函数）：

    包含的函数：
    - 基础函数 (4): "范围", "求和", "最大值", "最小值"
    - 三角函数 (3): "正弦", "余弦", "正切"
    - 反三角函数 (3): "反正弦", "反余弦", "反正切"
    - 统计函数 (4): "平均值", "方差", "标准差", "中位数"
    - 数论函数 (3): "素数优化判断", "质因数分解", "欧拉函数"
    - 数学常量 (4): "圆周率", "自然对数底", "欧拉常数", "黄金比例"

    Author: Whisky, PR Worker *)
