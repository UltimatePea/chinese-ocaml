(** 骆言内置集合操作函数模块接口 - Chinese Programming Language Builtin Collection Functions Module Interface

    这个模块提供了骆言编程语言的集合（列表、字符串）操作相关内置函数， 包括长度查询、连接、过滤、映射、折叠、排序等高阶函数功能。集合操作
    是函数式编程的核心特性，为数据处理和变换提供强大而优雅的抽象。

    该模块的主要功能包括：
    - 基础集合操作（长度、连接、反转）
    - 高阶函数操作（过滤、映射、折叠）
    - 集合查询和搜索功能
    - 排序和变换操作

    所有集合函数都支持列表操作，部分函数同时支持字符串操作， 提供一致的编程接口和体验。

    @author 骆言项目组
    @since 0.1.0 *)

open Value_operations

val length_function : runtime_value list -> runtime_value
(** 获取集合的长度

    @param args 参数列表，包含[集合]
    @return 表示集合长度的整数值

    支持的集合类型：
    - 列表：返回列表中元素的数量
    - 字符串：返回字符串中字符的数量

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当参数不是列表或字符串类型时 *)

val concat_function : runtime_value list -> runtime_value
(** 列表连接函数（柯里化）

    @param args 参数列表，包含[第一个列表]
    @return 返回一个新函数，接受第二个列表并返回连接结果

    这是一个柯里化函数： 1. 第一次调用传入第一个列表 2. 返回的函数接受第二个列表，返回连接后的新列表

    连接操作高效实现，保持元素顺序不变

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当参数不是列表类型时 *)

val filter_function : runtime_value list -> runtime_value
(** 列表过滤函数（柯里化）

    @param args 参数列表，包含[谓词函数]
    @return 返回一个新函数，接受列表并返回过滤后的结果

    这是一个柯里化函数： 1. 第一次调用传入谓词函数（接受单个元素，返回布尔值） 2. 返回的函数接受列表，返回满足谓词条件的元素组成的新列表

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当谓词不是函数或列表参数类型错误时 *)

val map_function : runtime_value list -> runtime_value
(** 列表映射函数（柯里化）

    @param args 参数列表，包含[变换函数]
    @return 返回一个新函数，接受列表并返回映射后的结果

    这是一个柯里化函数： 1. 第一次调用传入变换函数（接受单个元素，返回变换后的值） 2. 返回的函数接受列表，返回每个元素经过变换后组成的新列表

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当变换函数不是函数或列表参数类型错误时 *)

val fold_function : runtime_value list -> runtime_value
(** 列表折叠函数（柯里化）

    @param args 参数列表，包含[折叠函数]
    @return 返回一个新函数，接受初始值和列表，进行折叠计算

    这是一个柯里化函数，实现左折叠（fold_left）语义： 1. 第一次调用传入折叠函数（接受累积值和当前元素，返回新的累积值） 2. 返回的函数需要继续柯里化，依次接受初始值和列表

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当折叠函数不是函数或其他参数类型错误时 *)

val sort_function : runtime_value list -> runtime_value
(** 列表排序函数

    @param args 参数列表，包含[列表]
    @return 排序后的新列表

    使用默认的比较函数对列表元素进行排序，支持同质数据类型的列表。 返回一个新的已排序列表，不修改原列表。

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当参数不是列表或列表元素类型不一致时 *)

val reverse_function : runtime_value list -> runtime_value
(** 列表反转函数

    @param args 参数列表，包含[列表]
    @return 反转后的新列表

    返回将输入列表元素顺序完全颠倒后的新列表，不修改原列表。

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当参数不是列表类型时 *)

val contains_function : runtime_value list -> runtime_value
(** 集合包含检查函数（柯里化）

    @param args 参数列表，包含[集合]
    @return 返回一个新函数，接受要查找的元素并返回布尔结果

    这是一个柯里化函数： 1. 第一次调用传入要搜索的集合（列表或字符串） 2. 返回的函数接受要查找的元素，返回是否包含的布尔值

    支持的集合类型：
    - 列表：检查列表中是否包含指定元素
    - 字符串：检查字符串中是否包含指定字符（仅检查第一个字符）

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当参数不是列表或字符串类型时 *)

val collection_functions : (string * runtime_value) list
(** 集合操作相关内置函数表

    包含所有集合操作函数的名称和实现的映射表，用于函数查找和调用。

    包含的函数：
    - "长度": 获取集合长度
    - "连接": 连接两个列表
    - "过滤": 过滤列表元素
    - "映射": 映射变换列表
    - "折叠": 折叠计算列表
    - "排序": 排序列表
    - "反转": 反转列表
    - "包含": 检查包含关系 *)
