(** 编译器配置模块接口
    
    定义编译器的各种配置选项和预设配置，避免模块间的循环依赖。
*)

(** 编译器选项类型定义 *)
type compile_options = {
  show_tokens : bool;        (** 显示词法分析结果 *)
  show_ast : bool;           (** 显示抽象语法树 *)
  show_types : bool;         (** 显示类型推导结果 *)
  check_only : bool;         (** 仅进行语法和类型检查，不生成代码 *)
  quiet_mode : bool;         (** 静默模式，减少输出信息 *)
  filename : string option;  (** 输入文件名 *)
  recovery_mode : bool;      (** 错误恢复模式，尝试继续解析 *)
  log_level : string;        (** 日志级别 *)
  compile_to_c : bool;       (** 编译到C代码 *)
  c_output_file : string option;  (** C代码输出文件名 *)
}

(** 默认编译选项
    
    提供编译器的标准配置，适用于大多数普通编译任务。
*)
val default_options : compile_options

(** 测试模式编译选项
    
    专为单元测试设计的配置，输出结果但不输出编译过程信息。
*)
val test_options : compile_options

(** 静默模式编译选项
    
    最小化输出的配置，适用于批量处理或脚本自动化场景。
*)
val quiet_options : compile_options