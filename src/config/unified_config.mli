(** 骆言编译器统一配置管理模块接口 - 向后兼容 *)

type compiler_config = Compiler_config.t
(** 重新导出配置类型 *)

type runtime_config = Runtime_config.t

val default_compiler_config : compiler_config
(** 向后兼容：默认配置 *)

val default_runtime_config : runtime_config

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

val load_from_env : unit -> unit
(** 从环境变量加载配置 - 向后兼容 *)

val load_all_from_env : unit -> unit
(** 新增：统一加载所有配置模块 *)

val validate_compiler_config : compiler_config -> bool
(** 配置验证函数 *)

val validate_runtime_config : runtime_config -> bool

val reset_to_defaults : unit -> unit
(** 配置重置函数 *)
