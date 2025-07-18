(** 骆言内置工具函数模块接口 - Chinese Programming Language Builtin Utility Functions Module Interface

    这个模块提供了骆言编程语言的实用工具相关内置函数，包括文件过滤、 注释处理、字符串清理等辅助功能。工具函数为语言的文本处理和 代码分析功能提供基础支持，特别是针对骆言语言特有的语法特性。

    该模块的主要功能包括：
    - 文件类型过滤（针对特定扩展名）
    - 注释清理（支持多种注释格式）
    - 字符串内容过滤（支持中文和英文字符串）
    - 文本预处理工具

    这些工具函数主要用于代码分析、文档处理和语言特性支持。

    @author 骆言项目组
    @since 0.1.0 *)

open Value_operations

val filter_ly_files_function : runtime_value list -> runtime_value
(** 过滤.ly文件

    @param args 参数列表，包含[文件名列表]
    @return 过滤后只包含.ly扩展名文件的列表

    从给定的文件名列表中筛选出扩展名为.ly的文件。 这个函数专门用于处理骆言语言源文件的识别。

    筛选条件：
    - 文件名必须是字符串类型
    - 文件名长度至少3个字符
    - 文件名以".ly"结尾

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当参数不是列表类型时 *)

val remove_hash_comment_function : runtime_value list -> runtime_value
(** 移除井号注释

    @param args 参数列表，包含[字符串行]
    @return 移除井号注释后的字符串

    从给定的字符串中移除井号（#）开始的行尾注释。 处理单行的井号注释，保留注释符号之前的内容。

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当参数不是字符串类型时 *)

val remove_double_slash_comment_function : runtime_value list -> runtime_value
(** 移除双斜杠注释

    @param args 参数列表，包含[字符串行]
    @return 移除双斜杠注释后的字符串

    从给定的字符串中移除双斜杠（//）开始的行尾注释。 处理C风格的单行注释，保留注释符号之前的内容。

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当参数不是字符串类型时 *)

val remove_block_comments_function : runtime_value list -> runtime_value
(** 移除块注释

    @param args 参数列表，包含[字符串行]
    @return 移除块注释后的字符串

    从给定的字符串中移除块注释（/* ... */）。 处理C风格的多行注释，可能跨越多行或在行内出现。

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当参数不是字符串类型时 *)

val remove_luoyan_strings_function : runtime_value list -> runtime_value
(** 移除骆言字符串

    @param args 参数列表，包含[字符串行]
    @return 移除骆言字符串常量后的字符串

    从给定的字符串中移除骆言语言特有的字符串常量。 这个函数用于代码分析时排除字符串内容的干扰。

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当参数不是字符串类型时 *)

val remove_english_strings_function : runtime_value list -> runtime_value
(** 移除英文字符串

    @param args 参数列表，包含[字符串行]
    @return 移除英文字符串常量后的字符串

    从给定的字符串中移除标准的英文字符串常量（双引号包围）。 这个函数用于代码分析时排除字符串内容的干扰。

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当参数不是字符串类型时 *)

val utility_functions : (string * runtime_value) list
(** 工具函数相关内置函数表

    包含所有实用工具函数的名称和实现的映射表，用于函数查找和调用。

    包含的函数：
    - "过滤ly文件": 过滤.ly扩展名文件
    - "移除井号注释": 移除#注释
    - "移除双斜杠注释": 移除//注释
    - "移除块注释": 移除/* */注释
    - "移除骆言字符串": 移除骆言字符串常量
    - "移除英文字符串": 移除英文字符串常量 *)
