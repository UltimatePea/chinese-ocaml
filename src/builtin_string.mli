(** 骆言内置字符串处理函数模块接口 - Chinese Programming Language Builtin String Functions Module Interface

    这个模块提供了骆言编程语言的字符串处理相关内置函数，包括字符串的 连接、分割、搜索、匹配、变换等基础操作功能。字符串处理是现代编程语言 的核心功能之一，为文本处理和数据操作提供强大支持。

    该模块的主要功能包括：
    - 字符串连接和拆分操作
    - 字符串搜索和模式匹配
    - 字符串长度查询和反转变换
    - 支持正则表达式模式匹配

    所有字符串函数都进行严格的类型检查，确保操作的安全性和可靠性。

    @author 骆言项目组
    @since 0.1.0 *)

open Value_operations

val string_concat_function : runtime_value list -> runtime_value
(** 字符串连接函数（柯里化）

    @param args 参数列表，包含[第一个字符串]
    @return 返回一个新函数，接受第二个字符串并返回连接结果

    这是一个柯里化函数，支持部分应用： 1. 第一次调用传入第一个字符串，返回一个函数 2. 返回的函数接受第二个字符串，返回连接后的结果

    示例用法：(字符串连接 "你好") "世界" → "你好世界"

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当参数不是字符串类型时 *)

val string_contains_function : runtime_value list -> runtime_value
(** 字符串包含检查函数（柯里化）

    @param args 参数列表，包含[被搜索的字符串]
    @return 返回一个新函数，接受要查找的字符串并返回布尔结果

    这是一个柯里化函数： 1. 第一次调用传入被搜索的字符串 2. 返回的函数接受要查找的字符串，返回是否包含的布尔值

    注意：当前实现只检查第一个字符的包含关系

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当参数不是字符串类型时 *)

val string_split_function : runtime_value list -> runtime_value
(** 字符串分割函数（柯里化）

    @param args 参数列表，包含[要分割的字符串]
    @return 返回一个新函数，接受分隔符并返回分割后的列表

    这是一个柯里化函数： 1. 第一次调用传入要分割的字符串 2. 返回的函数接受分隔符字符串，返回分割后的字符串列表

    注意：分隔符只使用第一个字符

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当参数不是字符串类型时 *)

val string_match_function : runtime_value list -> runtime_value
(** 字符串正则匹配函数（柯里化）

    @param args 参数列表，包含[要匹配的字符串]
    @return 返回一个新函数，接受正则表达式并返回匹配结果

    这是一个柯里化函数： 1. 第一次调用传入要匹配的字符串 2. 返回的函数接受正则表达式模式，返回匹配成功与否的布尔值

    支持完整的OCaml Str模块正则表达式语法

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当参数不是字符串类型时
    @raise InvalidRegex 当正则表达式语法错误时 *)

val string_length_function : runtime_value list -> runtime_value
(** 获取字符串长度

    @param args 参数列表，包含[字符串]
    @return 表示字符串长度的整数值

    返回字符串中字符的数量（按字节计算）

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当参数不是字符串类型时 *)

val string_reverse_function : runtime_value list -> runtime_value
(** 字符串反转函数

    @param args 参数列表，包含[字符串]
    @return 反转后的字符串值

    返回将输入字符串字符顺序完全颠倒后的新字符串

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当参数不是字符串类型时 *)

val string_functions : (string * runtime_value) list
(** 字符串处理相关内置函数表

    包含所有字符串操作函数的名称和实现的映射表，用于函数查找和调用。

    包含的函数：
    - "字符串连接": 连接两个字符串
    - "字符串包含": 检查字符串包含关系
    - "字符串分割": 按分隔符分割字符串
    - "字符串匹配": 正则表达式匹配
    - "字符串长度": 获取字符串长度
    - "字符串反转": 反转字符串 *)
