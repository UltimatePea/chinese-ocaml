(** 骆言日志系统核心模块 - 基础类型、配置和工具函数 *)

(** {1 日志级别定义} *)

(** 日志级别 *)
type log_level =
  | DEBUG  (** 调试级别 - 详细的调试信息 *)
  | INFO  (** 信息级别 - 一般性信息 *)
  | WARN  (** 警告级别 - 警告信息 *)
  | ERROR  (** 错误级别 - 错误信息 *)
  | QUIET  (** 静默级别 - 不输出任何日志 *)

(** {1 日志配置} *)

type log_config = {
  mutable current_level : log_level;  (** 当前日志级别 *)
  mutable show_timestamps : bool;  (** 是否显示时间戳 *)
  mutable show_module_name : bool;  (** 是否显示模块名 *)
  mutable show_colors : bool;  (** 是否显示颜色 *)
  mutable output_channel : out_channel;  (** 输出通道 *)
  mutable error_channel : out_channel;  (** 错误输出通道 *)
}

(** 全局日志配置 *)
val global_config : log_config

(** {1 级别转换函数} *)

(** 获取日志级别的数字表示 *)
val level_to_int : log_level -> int

(** 获取日志级别的中文字符串表示 *)
val level_to_string : log_level -> string

(** 获取日志级别的颜色码 *)
val level_to_color : log_level -> string

(** {1 配置函数} *)

(** 设置日志级别 *)
val set_level : log_level -> unit

(** 获取当前日志级别 *)
val get_level : unit -> log_level

(** 设置是否显示时间戳 *)
val set_show_timestamps : bool -> unit

(** 设置是否显示模块名 *)
val set_show_module_name : bool -> unit

(** 设置是否显示颜色 *)
val set_show_colors : bool -> unit

(** 设置输出通道 *)
val set_output_channel : out_channel -> unit

(** 设置错误输出通道 *)
val set_error_channel : out_channel -> unit

(** {1 工具函数} *)

(** 获取当前时间戳 *)
val get_timestamp : unit -> string

(** 判断是否应该输出此级别的日志 *)
val should_log : log_level -> bool

(** 格式化日志消息 *)
val format_message : log_level -> string -> string -> string

(** {1 核心日志函数} *)

(** 核心日志函数 *)
val log_internal : log_level -> string -> string -> unit

(** {1 基础日志函数} *)

(** 记录调试信息 *)
val debug : string -> string -> unit

(** 记录一般信息 *)
val info : string -> string -> unit

(** 记录警告信息 *)
val warn : string -> string -> unit

(** 记录错误信息 *)
val error : string -> string -> unit

(** {1 格式化日志函数} *)

(** 格式化记录调试信息 *)
val debugf : string -> ('a, unit, string, unit) format4 -> 'a

(** 格式化记录一般信息 *)
val infof : string -> ('a, unit, string, unit) format4 -> 'a

(** 格式化记录警告信息 *)
val warnf : string -> ('a, unit, string, unit) format4 -> 'a

(** 格式化记录错误信息 *)
val errorf : string -> ('a, unit, string, unit) format4 -> 'a

(** {1 条件日志函数} *)

(** 有条件记录调试信息 *)
val debug_if : bool -> string -> string -> unit

(** 有条件记录一般信息 *)
val info_if : bool -> string -> string -> unit

(** 有条件记录警告信息 *)
val warn_if : bool -> string -> string -> unit

(** 有条件记录错误信息 *)
val error_if : bool -> string -> string -> unit

(** {1 模块日志器} *)

(** 创建模块专用日志器 *)
val create_module_logger : string -> (string -> unit) * (string -> unit) * (string -> unit) * (string -> unit)

(** 初始化模块日志器（别名） *)
val init_module_logger : string -> (string -> unit) * (string -> unit) * (string -> unit) * (string -> unit)

(** {1 性能监控} *)

(** 性能测量辅助函数 *)
val time_operation : string -> string -> (unit -> 'a) -> 'a

(** {1 初始化函数} *)

(** 从环境变量初始化日志配置 *)
val init_from_env : unit -> unit

(** 初始化日志系统 *)
val init : unit -> unit

(** {1 快速设置函数} *)

(** 设置为调试模式 *)
val enable_debug : unit -> unit

(** 设置为静默模式 *)
val enable_quiet : unit -> unit

(** 设置为详细模式 *)
val enable_verbose : unit -> unit