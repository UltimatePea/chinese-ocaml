(** 骆言编译器核心模块接口 - Chinese Programming Language Compiler Core Interface *)

(** 编译选项配置类型 *)
type compile_options = {
  show_tokens: bool;          (** 显示词法分析的词元 *)
  show_ast: bool;             (** 显示抽象语法树 *)
  show_types: bool;           (** 显示类型推断信息 *)
  check_only: bool;           (** 仅进行语法和语义检查，不执行 *)
  quiet_mode: bool;           (** 安静模式，减少输出 *)
  filename: string option;    (** 输入文件名 *)
  recovery_mode: bool;        (** 启用错误恢复模式 *)
  log_level: string;          (** 错误恢复日志级别: "quiet", "normal", "verbose", "debug" *)
  compile_to_c: bool;         (** 编译到C代码 *)
  c_output_file: string option; (** C输出文件名 *)
}

(** 默认编译选项 *)
val default_options : compile_options

(** 安静模式编译选项（用于测试） *)
val quiet_options : compile_options

(** 编译字符串
    @param options 编译选项配置
    @param input_content 要编译的源代码字符串
    @return 编译是否成功
*)
val compile_string : compile_options -> string -> bool

(** 编译文件
    @param options 编译选项配置  
    @param filename 要编译的文件路径
    @return 编译是否成功
*)
val compile_file : compile_options -> string -> bool