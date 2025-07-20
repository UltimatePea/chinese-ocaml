(** 骆言编译器运行时配置模块接口 *)

(** 运行时配置类型定义 *)
type t = {
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

(** 默认运行时配置 *)
val default : t

(** 获取当前运行时配置 *)
val get : unit -> t

(** 设置运行时配置 *)
val set : t -> unit

(** 更新运行时配置字段 *)
val update_debug_mode : bool -> unit
val update_verbose_logging : bool -> unit
val update_log_level : string -> unit
val update_max_error_count : int -> unit
val update_colored_output : bool -> unit

(** 从环境变量加载运行时配置 *)
val load_from_env : unit -> unit