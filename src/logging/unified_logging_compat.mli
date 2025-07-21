(** 骆言统一日志系统 - 模块化重构后的兼容性包装器 *)

(** 重新导出类型以保持兼容性 *)
type log_level = Log_core.log_level = DEBUG | INFO | WARN | ERROR | QUIET

type log_config = Log_core.log_config = {
  mutable current_level : log_level;
  mutable show_timestamps : bool;
  mutable show_module_name : bool;
  mutable show_colors : bool;
  mutable output_channel : out_channel;
  mutable error_channel : out_channel;
}

val global_config : log_config
(** 重新导出核心配置和函数 *)

val level_to_int : log_level -> int
val level_to_string : log_level -> string
val level_to_color : log_level -> string
val set_level : log_level -> unit
val get_level : unit -> log_level
val set_show_timestamps : bool -> unit
val set_show_module_name : bool -> unit
val set_show_colors : bool -> unit
val set_output_channel : out_channel -> unit
val set_error_channel : out_channel -> unit
val get_timestamp : unit -> string
val should_log : log_level -> bool
val format_message : log_level -> string -> string -> string
val log_internal : log_level -> string -> string -> unit

val debug : string -> string -> unit
(** 重新导出基础日志函数 *)

val info : string -> string -> unit
val warn : string -> string -> unit
val error : string -> string -> unit
val debugf : string -> ('a, unit, string, unit) format4 -> 'a
val infof : string -> ('a, unit, string, unit) format4 -> 'a
val warnf : string -> ('a, unit, string, unit) format4 -> 'a
val errorf : string -> ('a, unit, string, unit) format4 -> 'a
val debug_if : bool -> string -> string -> unit
val info_if : bool -> string -> string -> unit
val warn_if : bool -> string -> string -> unit
val error_if : bool -> string -> string -> unit

val create_module_logger :
  string -> (string -> unit) * (string -> unit) * (string -> unit) * (string -> unit)

val init_module_logger :
  string -> (string -> unit) * (string -> unit) * (string -> unit) * (string -> unit)

val time_operation : string -> string -> (unit -> 'a) -> 'a

val init_from_env : unit -> unit
(** 重新导出初始化函数 *)

val init : unit -> unit
val enable_debug : unit -> unit
val enable_quiet : unit -> unit
val enable_verbose : unit -> unit

module Messages : module type of Log_messages
(** 重新导出消息模块 *)

module UserOutput : module type of Log_output
(** 重新导出用户输出模块 *)

module Legacy : module type of Log_legacy
(** 重新导出兼容性模块 *)
