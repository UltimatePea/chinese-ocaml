(** 骆言编译器核心配置模块接口 *)

type t = {
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

val default : t
(** 默认编译器配置 *)

val get : unit -> t
(** 获取当前编译器配置 *)

val set : t -> unit
(** 设置编译器配置 *)

val update_buffer_size : int -> unit
(** 更新编译器配置字段 *)

val update_compilation_timeout : float -> unit
val update_output_directory : string -> unit
val update_temp_directory : string -> unit
val update_c_compiler : string -> unit
val update_optimization_level : int -> unit

val load_from_env : unit -> unit
(** 从环境变量加载编译器配置 *)
