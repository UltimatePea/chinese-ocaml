(** 骆言日志系统 - Chinese Programming Language Logger *)

(** {1 日志级别定义} *)

(** 日志级别 *)
type log_level =
  | DEBUG  (** 调试级别 *)
  | INFO  (** 信息级别 *)
  | WARN  (** 警告级别 *)
  | ERROR  (** 错误级别 *)
  | QUIET  (** 静默级别 *)

(** {1 日志配置} *)

type log_config = {
  mutable current_level : log_level;  (** 日志级别 *)
  mutable show_timestamps : bool;  (** 是否显示时间戳 *)
  mutable show_module_name : bool;  (** 是否显示模块名 *)
  mutable output_channel : out_channel;  (** 输出通道 *)
}
(** 日志配置 *)

(** {1 日志配置函数} *)

val set_level : log_level -> unit
(** 设置日志级别 *)

val set_show_timestamps : bool -> unit
(** 设置是否显示时间戳 *)

val set_show_module_name : bool -> unit
(** 设置是否显示模块名 *)

val set_output_channel : out_channel -> unit
(** 设置输出通道 *)

(** {1 基础日志记录函数} *)

val debug : string -> string -> unit
(** 记录调试信息 *)

val info : string -> string -> unit
(** 记录一般信息 *)

val warn : string -> string -> unit
(** 记录警告信息 *)

val error : string -> string -> unit
(** 记录错误信息 *)

(** {1 格式化日志函数} *)

val debugf : string -> ('a, unit, string, unit) format4 -> 'a
(** 格式化记录调试信息 *)

val infof : string -> ('a, unit, string, unit) format4 -> 'a
(** 格式化记录一般信息 *)

val warnf : string -> ('a, unit, string, unit) format4 -> 'a
(** 格式化记录警告信息 *)

val errorf : string -> ('a, unit, string, unit) format4 -> 'a
(** 格式化记录错误信息 *)

(** {1 条件日志函数} *)

val debug_if : bool -> string -> string -> unit
(** 有条件记录调试信息 *)

val info_if : bool -> string -> string -> unit
(** 有条件记录一般信息 *)

val warn_if : bool -> string -> string -> unit
(** 有条件记录警告信息 *)

val error_if : bool -> string -> string -> unit
(** 有条件记录错误信息 *)

(** {1 模块日志器} *)

val create_module_logger :
  string -> (string -> unit) * (string -> unit) * (string -> unit) * (string -> unit)
(** 创建模块专用日志器，返回 (debug, info, warn, error) 四元组 *)

val init_module_logger :
  string -> (string -> unit) * (string -> unit) * (string -> unit) * (string -> unit)
(** 初始化模块日志器，返回 (debug, info, warn, error) 四元组 *)

(** {1 工具函数} *)

val time_operation : string -> string -> (unit -> 'a) -> 'a
(** 测量操作执行时间并记录
    @param module_name 模块名
    @param operation_name 操作名
    @param f 要执行的函数
    @return 函数执行结果 *)

(** {1 初始化函数} *)

val init_from_env : unit -> unit
(** 从环境变量初始化日志配置 *)

val init : unit -> unit
(** 初始化日志系统 *)
