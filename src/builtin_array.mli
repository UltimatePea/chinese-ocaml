(** 骆言内置数组操作函数模块接口 - Chinese Programming Language Builtin Array Functions Module Interface

    这个模块提供了骆言编程语言的数组操作相关内置函数，包括数组的创建、 访问、修改、转换等核心功能。数组是语言中重要的数据结构，支持随机访问 和就地修改，为高效的数据处理提供基础支持。

    该模块的主要功能包括：
    - 数组创建和初始化
    - 数组元素的读取和写入
    - 数组属性查询（如长度）
    - 数组与列表之间的转换
    - 数组的复制操作

    所有数组操作都包含边界检查和类型验证，确保运行时的安全性和正确性。

    @author 骆言项目组
    @since 0.1.0 *)

open Value_operations

val create_array_function : runtime_value list -> runtime_value
(** 创建指定大小的数组并初始化所有元素为指定值

    @param args 参数列表，包含[大小; 初始值]
    @return 新创建的数组值

    参数要求：
    - 第一个参数：非负整数，表示数组大小
    - 第二个参数：任意类型的值，作为数组元素的初始值

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当大小参数不是整数或为负数时 *)

val array_length_function : runtime_value list -> runtime_value
(** 获取数组的长度

    @param args 参数列表，包含[数组]
    @return 表示数组长度的整数值

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当参数不是数组类型时 *)

val copy_array_function : runtime_value list -> runtime_value
(** 创建数组的副本

    @param args 参数列表，包含[数组]
    @return 原数组的完整副本

    返回的数组是原数组的深拷贝，修改副本不会影响原数组。

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当参数不是数组类型时 *)

val array_get_function : runtime_value list -> runtime_value
(** 获取数组指定索引位置的元素

    @param args 参数列表，包含[数组; 索引]
    @return 指定位置的元素值

    参数要求：
    - 第一个参数：数组
    - 第二个参数：非负整数索引，必须在有效范围内

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当参数类型不正确时
    @raise IndexError 当索引超出数组边界时 *)

val array_set_function : runtime_value list -> runtime_value
(** 设置数组指定索引位置的元素值

    @param args 参数列表，包含[数组; 索引; 新值]
    @return 单元值（表示操作完成）

    参数要求：
    - 第一个参数：数组
    - 第二个参数：非负整数索引，必须在有效范围内
    - 第三个参数：任意类型的新值

    这是就地修改操作，会直接改变原数组的内容。

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当参数类型不正确时
    @raise IndexError 当索引超出数组边界时 *)

val array_to_list_function : runtime_value list -> runtime_value
(** 将数组转换为列表

    @param args 参数列表，包含[数组]
    @return 包含相同元素的列表值

    转换后的列表保持元素的原有顺序，但是列表是不可变的。

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当参数不是数组类型时 *)

val list_to_array_function : runtime_value list -> runtime_value
(** 将列表转换为数组

    @param args 参数列表，包含[列表]
    @return 包含相同元素的数组值

    转换后的数组保持元素的原有顺序，并且可以进行就地修改。

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当参数不是列表类型时 *)

val array_functions : (string * runtime_value) list
(** 数组相关内置函数表

    包含所有数组操作函数的名称和实现的映射表，用于函数查找和调用。

    包含的函数：
    - "创建数组": 创建新数组
    - "数组长度": 获取数组长度
    - "复制数组": 复制数组
    - "数组获取": 获取数组元素
    - "数组设置": 设置数组元素
    - "数组转列表": 数组转列表
    - "列表转数组": 列表转数组 *)
