(** 骆言编译器统一配置管理模块接口 - 重构版本 *)

type compiler_config = Config_modules.Compiler_config.t
(** 重新导出配置类型 *)

type runtime_config = Config_modules.Runtime_config.t

val default_compiler_config : compiler_config
(** 向后兼容：默认配置 *)

val default_runtime_config : runtime_config

val compiler_config : compiler_config ref
(** 向后兼容：配置引用 *)

val runtime_config : runtime_config ref

val get_compiler_config : unit -> compiler_config
(** 向后兼容：配置访问函数 *)

val get_runtime_config : unit -> runtime_config
val set_compiler_config : compiler_config -> unit
val set_runtime_config : runtime_config -> unit

val parse_boolean_env_var : string -> bool
(** 环境变量解析辅助函数 - 向后兼容 *)

val parse_positive_int_env_var : string -> int option
val parse_positive_float_env_var : string -> float option
val parse_non_empty_string_env_var : string -> string option
val parse_int_range_env_var : string -> int -> int -> int option
val parse_enum_env_var : string -> string list -> string option

val env_var_mappings : (string * (string -> unit)) list
(** 环境变量映射 - 向后兼容 *)

val load_from_env : unit -> unit
(** 从环境变量加载配置 - 向后兼容 *)

val load_from_file : string -> bool
(** 配置加载功能 *)

val init_config : ?config_file:string -> unit -> unit
val validate_config : unit -> string list

val print_config : unit -> unit
(** 向后兼容：打印当前配置 *)

(** 向后兼容：便捷的配置获取函数 *)
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

module Compiler : module type of Config_modules.Compiler_config
(** 新增：模块化配置访问接口 *)

module Runtime : module type of Config_modules.Runtime_config
