(** 骆言内置I/O函数模块接口 - Chinese Programming Language Builtin I/O Functions Module Interface

    这个模块提供了骆言编程语言的输入输出相关内置函数，包括控制台 输入输出、文件读写、目录操作等基础I/O功能。I/O操作是程序与外部 环境交互的重要渠道，为数据处理和系统集成提供基础支持。

    该模块的主要功能包括：
    - 控制台输入输出（打印、读取）
    - 文件系统操作（读写文件、检查存在性）
    - 目录操作（列出目录内容）
    - 统一的错误处理和异常安全

    所有I/O函数都包含适当的错误处理，确保文件操作的安全性和可靠性。

    @author 骆言项目组
    @since 0.1.0 *)

open Value_operations

val print_function : runtime_value list -> runtime_value
(** 打印函数

    @param args 参数列表，包含[要打印的值]
    @return 单元值

    支持打印任意类型的值：
    - 字符串：直接打印内容
    - 其他类型：自动转换为字符串表示后打印

    输出通过Logger模块处理，确保与日志系统的统一性。

    @raise RuntimeError 当参数数量不正确时 *)

val read_function : runtime_value list -> runtime_value
(** 从控制台读取一行输入

    @param args 参数列表（应为空或包含单元值）
    @return 读取的字符串值

    从标准输入读取一行文本，去除末尾的换行符。 支持无参数调用或传入单元值。

    @raise RuntimeError 当传入非单元值参数时 *)

val read_file_function : runtime_value list -> runtime_value
(** 读取文件内容

    @param args 参数列表，包含[文件名]
    @return 文件内容的字符串值

    读取指定文件的全部内容并返回为字符串。 自动处理文件打开、读取和关闭操作。

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当文件名不是字符串时
    @raise RuntimeError 当文件不存在或无法读取时 *)

val write_file_function : runtime_value list -> runtime_value
(** 写入文件函数（柯里化）

    @param args 参数列表，包含[文件名]
    @return 返回一个新函数，接受文件内容并执行写入

    这是一个柯里化函数： 1. 第一次调用传入文件名 2. 返回的函数接受要写入的内容，执行文件写入操作

    写入操作会覆盖现有文件内容。自动处理文件创建、写入和关闭。

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当文件名或内容不是字符串时
    @raise RuntimeError 当文件无法写入时 *)

val file_exists_function : runtime_value list -> runtime_value
(** 检查文件是否存在

    @param args 参数列表，包含[文件名]
    @return 表示文件是否存在的布尔值

    检查指定路径的文件或目录是否存在。

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当文件名不是字符串时 *)

val list_directory_function : runtime_value list -> runtime_value
(** 列出目录内容

    @param args 参数列表，包含[目录名]
    @return 包含目录中所有文件和子目录名称的列表

    返回指定目录中所有文件和子目录的名称列表。 不包含特殊目录项（如 "." 和 ".."）。

    @raise RuntimeError 当参数数量不正确时
    @raise TypeError 当目录名不是字符串时
    @raise RuntimeError 当目录不存在或无法访问时 *)

val io_functions : (string * runtime_value) list
(** I/O相关内置函数表

    包含所有输入输出操作函数的名称和实现的映射表，用于函数查找和调用。

    包含的函数：
    - "打印": 输出值到控制台
    - "读取": 从控制台读取输入
    - "读取文件": 读取文件内容
    - "写入文件": 写入内容到文件
    - "文件存在": 检查文件存在性
    - "列出目录": 列出目录内容 *)
