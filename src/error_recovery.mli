(** 骆言错误恢复模块接口 - Chinese Programming Language Error Recovery Module Interface *)

type error_recovery_config = {
  enabled : bool;
  type_conversion : bool;
  spell_correction : bool;
  parameter_adaptation : bool;
  log_level : string; (* "quiet" | "normal" | "verbose" | "debug" *)
  collect_statistics : bool;
}
(** 错误恢复配置类型 *)

type recovery_statistics = {
  mutable total_errors : int;
  mutable type_conversions : int;
  mutable spell_corrections : int;
  mutable parameter_adaptations : int;
  mutable variable_suggestions : int;
  mutable or_else_fallbacks : int;
}
(** 错误恢复统计类型 *)

val default_recovery_config : error_recovery_config
(** 默认错误恢复配置 *)

val recovery_stats : recovery_statistics
(** 全局错误恢复统计 *)

val get_recovery_config : unit -> error_recovery_config
(** 获取全局错误恢复配置 *)

val set_recovery_config : error_recovery_config -> unit
(** 设置全局错误恢复配置 *)

val set_log_level : string -> unit
(** 设置日志级别 *)

val levenshtein_distance : string -> string -> int
(** 计算字符串间的编辑距离（Levenshtein距离） *)

val get_available_vars : (string * 'a) list -> string list
(** 从环境中获取可用变量列表 *)

val find_closest_var : string -> string list -> string option
(** 查找最接近的变量名 *)

val log_recovery : string -> unit
(** 记录错误恢复信息 *)

val log_recovery_type : string -> string -> unit
(** 记录特定类型的错误恢复信息 *)

val show_recovery_statistics : unit -> unit
(** 显示错误恢复统计信息 *)

val reset_recovery_statistics : unit -> unit
(** 重置错误恢复统计信息 *)

val enable_recovery : unit -> unit
(** 启用错误恢复功能 *)

val disable_recovery : unit -> unit
(** 禁用错误恢复功能 *)
