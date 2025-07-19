(** 编译器配置模块接口 - 避免循环依赖 *)

type compile_options = {
  show_tokens : bool;
  show_ast : bool;
  show_types : bool;
  check_only : bool;
  quiet_mode : bool;
  filename : string option;
  recovery_mode : bool;
  log_level : string;
  compile_to_c : bool;
  c_output_file : string option;
}
(** 编译器选项 *)

val default_options : compile_options
(** 默认编译选项 *)

val quiet_options : compile_options
(** 静默模式编译选项 *)
