(** 骆言编译器 - Chinese Programming Language Compiler *)

(** {1 编译选项配置} *)

type compile_options = Compile_options.compile_options
(** 编译选项 *)

(** {1 预定义编译选项} *)

val default_options : compile_options
(** 默认编译选项 *)

val test_options : compile_options
(** 测试模式编译选项 - 输出结果但不输出编译过程信息 *)

val quiet_options : compile_options
(** 安静模式编译选项 - 主要用于测试 *)

(** {1 编译函数} *)

val compile_string : compile_options -> string -> bool
(** 编译字符串源代码
    @param options 编译选项
    @param source 源代码字符串
    @return 编译成功返回 true，失败返回 false *)

val compile_file : compile_options -> string -> bool
(** 编译文件
    @param options 编译选项
    @param filename 文件名
    @return 编译成功返回 true，失败返回 false *)
