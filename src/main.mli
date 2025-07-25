(** 骆言编译器主程序接口 - Chinese Programming Language Compiler Main Interface *)

(** {1 概述}

    本模块是骆言编译器的主程序入口，提供命令行接口和交互式模式。 支持多种编译选项和调试功能，是骆言编译器与用户交互的核心接口。

    主要功能：
    - 命令行参数解析
    - 交互式解释器模式
    - 编译选项配置
    - 用户帮助系统

    @author 骆言编程团队
    @version 1.0
    @since 2025-07-19 *)

(** {2 交互式模式} *)

val interactive_mode : unit -> unit
(** 启动交互式模式

    进入骆言交互式解释器，用户可以逐行输入代码进行实时编译和执行。 支持以下交互命令：
    - {:quit} - 退出解释器
    - {:help} - 显示帮助信息
    - 或直接输入骆言表达式进行求值

    @raise End_of_file 当输入流结束时正常退出
    @raise e 当表达式求值发生错误时记录错误并继续运行 *)

(** {3 帮助系统} *)

val show_help : unit -> unit
(** 显示程序帮助信息

    输出骆言编译器的使用说明，包括：
    - 支持的命令行选项
    - 各选项的详细说明
    - 使用示例
    - 编译模式介绍 *)

(** {4 命令行参数处理} *)

val parse_args :
  string list ->
  Yyocamlc_lib.Compile_options.compile_options ->
  Yyocamlc_lib.Compile_options.compile_options
(** 解析命令行参数列表

    递归解析命令行参数，构建编译选项配置。支持的选项包括：
    - [-tokens] - 显示词元列表
    - [-ast] - 显示抽象语法树
    - [-types] - 显示类型信息
    - [-check] - 仅进行语法和类型检查
    - [-verbose] - 详细日志模式
    - [-debug] - 调试日志模式
    - [-c] - 编译到C代码
    - [-o file] - 指定C输出文件名
    - [-i] - 交互式模式
    - [-h, -help] - 显示帮助信息

    @param arg_list 命令行参数列表
    @param options 当前编译选项配置
    @return 更新后的编译选项配置
    @raise Sys_error 当遇到无效参数时退出程序 *)

(** {5 程序说明}

    本模块是骆言编译器的用户接口层，负责：

    1. **命令行界面**: 提供直观的命令行选项和参数解析 2. **交互模式**: 支持实时的代码输入和执行反馈 3. **错误处理**: 优雅地处理用户输入错误和系统异常 4.
    **帮助系统**: 为用户提供完整的使用指导

    设计原则：
    - 用户友好的中文提示信息
    - 渐进式的错误恢复机制
    - 灵活的编译选项组合
    - 清晰的操作反馈 *)
