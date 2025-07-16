(** 骆言编译器统一配置管理模块接口 *)

type compiler_config = {
  buffer_size : int;
  large_buffer_size : int;
  report_buffer_size : int;
  utf8_char_buffer_size : int;
  compilation_timeout : float;
  test_timeout : float;
  output_directory : string;
  temp_directory : string;
  runtime_directory : string;
  default_c_output : string;
  temp_file_prefix : string;
  c_compiler : string;
  c_compiler_flags : string list;
  optimization_level : int;
  debug_symbols : bool;
  default_hashtable_size : int;
  large_hashtable_size : int;
  max_iterations : int;
  confidence_threshold : float;
}
(** 编译器配置类型定义 *)

type runtime_config = {
  debug_mode : bool;
  verbose_logging : bool;
  log_level : string;
  error_recovery : bool;
  max_error_count : int;
  continue_on_error : bool;
  show_suggestions : bool;
  colored_output : bool;
  spell_correction : bool;
  type_inference : bool;
  auto_completion : bool;
  code_formatting : bool;
}
(** 运行时配置类型定义 *)

val default_compiler_config : compiler_config
(** 默认编译器配置 *)

val default_runtime_config : runtime_config
(** 默认运行时配置 *)

val get_compiler_config : unit -> compiler_config
(** 配置获取函数 *)

val get_runtime_config : unit -> runtime_config

val set_compiler_config : compiler_config -> unit
(** 配置设置函数 *)

val set_runtime_config : runtime_config -> unit

val load_from_env : unit -> unit
(** 从环境变量加载配置 *)

val load_from_file : string -> bool
(** 从配置文件加载配置 *)

val init_config : ?config_file:string -> unit -> unit
(** 配置初始化 *)

val validate_config : unit -> string list
(** 配置验证 *)

val print_config : unit -> unit
(** 打印当前配置 *)

(** 便捷的配置获取函数模块 *)
module Get : sig
  val buffer_size : unit -> int
  val large_buffer_size : unit -> int
  val compilation_timeout : unit -> float
  val output_directory : unit -> string
  val temp_directory : unit -> string
  val c_compiler : unit -> string
  val c_compiler_flags : unit -> string list
  val optimization_level : unit -> int
  val debug_mode : unit -> bool
  val verbose_logging : unit -> bool
  val error_recovery : unit -> bool
  val max_error_count : unit -> int
  val continue_on_error : unit -> bool
  val show_suggestions : unit -> bool
  val colored_output : unit -> bool
  val spell_correction : unit -> bool
  val hashtable_size : unit -> int
  val large_hashtable_size : unit -> int
end
