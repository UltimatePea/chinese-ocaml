(** 骆言编译器 - Chinese Programming Language Compiler *)

(** {1 编译选项配置} *)

type compile_options = {
  show_tokens : bool;  (** 是否显示词法分析结果 *)
  show_ast : bool;  (** 是否显示AST *)
  show_types : bool;  (** 是否显示类型信息 *)
  check_only : bool;  (** 是否只进行检查而不执行 *)
  quiet_mode : bool;  (** 是否静默模式 *)
  filename : string option;  (** 输入文件名 *)
  recovery_mode : bool;  (** 是否启用错误恢复 *)
  log_level : string;  (** 错误恢复日志级别 *)
  compile_to_c : bool;  (** 是否编译到C代码 *)
  c_output_file : string option;  (** C代码输出文件名 *)
}
(** 编译选项 *)

(** {1 预定义编译选项} *)

val default_options : compile_options
(** 默认编译选项 *)

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
