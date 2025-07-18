(** 编译器配置模块 - 避免循环依赖 *)

(** 编译器选项 *)
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

(** 默认编译选项 *)
let default_options = {
  show_tokens = false;
  show_ast = false;
  show_types = false;
  check_only = false;
  quiet_mode = false;
  filename = None;
  recovery_mode = true;
  log_level = "normal";
  compile_to_c = false;
  c_output_file = None;
}

(** 静默模式编译选项 *)
let quiet_options = {
  show_tokens = false;
  show_ast = false;
  show_types = false;
  check_only = false;
  quiet_mode = true;
  filename = None;
  recovery_mode = true;
  log_level = "quiet";
  compile_to_c = false;
  c_output_file = None;
}