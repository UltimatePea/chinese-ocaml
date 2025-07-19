(** 骆言统一日志系统接口 - 消除项目中的printf调用重复 *)

(** {1 日志级别定义} *)

(** 日志级别 *)
type log_level =
  | DEBUG  (** 调试级别 - 详细的调试信息 *)
  | INFO   (** 信息级别 - 一般性信息 *)
  | WARN   (** 警告级别 - 警告信息 *)
  | ERROR  (** 错误级别 - 错误信息 *)
  | QUIET  (** 静默级别 - 不输出任何日志 *)

(** {1 日志配置} *)

type log_config = {
  mutable current_level : log_level;        (** 当前日志级别 *)
  mutable show_timestamps : bool;          (** 是否显示时间戳 *)
  mutable show_module_name : bool;         (** 是否显示模块名 *)
  mutable show_colors : bool;              (** 是否显示颜色 *)
  mutable output_channel : out_channel;    (** 输出通道 *)
  mutable error_channel : out_channel;     (** 错误输出通道 *)
}

(** {1 配置函数} *)

val set_level : log_level -> unit
(** 设置日志级别 *)

val get_level : unit -> log_level
(** 获取当前日志级别 *)

val set_show_timestamps : bool -> unit
(** 设置是否显示时间戳 *)

val set_show_module_name : bool -> unit
(** 设置是否显示模块名 *)

val set_show_colors : bool -> unit
(** 设置是否显示颜色 *)

val set_output_channel : out_channel -> unit
(** 设置输出通道 *)

val set_error_channel : out_channel -> unit
(** 设置错误输出通道 *)

(** {1 基础日志函数} *)

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

(** {1 性能监控} *)

val time_operation : string -> string -> (unit -> 'a) -> 'a
(** 测量操作执行时间并记录
    @param module_name 模块名
    @param operation_name 操作名
    @param f 要执行的函数
    @return 函数执行结果 *)

(** {1 专门的消息模块} *)

module Messages : sig
  (** 错误消息模块 *)
  module Error : sig
    val undefined_variable : string -> string
    val function_arity_mismatch : string -> int -> int -> string
    val type_mismatch : string -> string -> string
    val file_not_found : string -> string
    val module_member_not_found : string -> string -> string
  end
  
  (** 编译器消息模块 *)
  module Compiler : sig
    val compiling_file : string -> string
    val compilation_complete : int -> float -> string
    val analysis_stats : int -> int -> string
  end

  (** 调试消息模块 *)
  module Debug : sig
    val variable_value : string -> string -> string
    val function_call : string -> string list -> string
    val type_inference : string -> string -> string
  end
end

(** {1 用户输出模块} *)

module UserOutput : sig
  val success : string -> unit
  (** 成功消息 *)
  
  val warning : string -> unit
  (** 警告消息 *)
  
  val error : string -> unit
  (** 错误消息 *)
  
  val info : string -> unit
  (** 信息消息 *)
  
  val progress : string -> unit
  (** 进度消息 *)

  val print_user_output : string -> unit
  (** 用户输出 - 程序执行结果等面向用户的信息 *)

  val print_compiler_message : string -> unit
  (** 编译器消息 - 编译过程中的提示信息 *)

  val print_debug_info : string -> unit
  (** 调试信息输出 *)

  val print_user_prompt : string -> unit
  (** 不换行的用户输出 - 用于提示符等 *)
end

(** {1 兼容性模块} *)

module Legacy : sig
  val printf : ('a, unit, string, unit) format4 -> 'a
  (** 替代Printf.printf的函数 *)
  
  val eprintf : ('a, unit, string, unit) format4 -> 'a
  (** 替代Printf.eprintf的函数 *)
  
  val print_endline : string -> unit
  (** 替代print_endline的函数 *)
  
  val print_string : string -> unit
  (** 替代print_string的函数 *)
  
  val sprintf : ('a, unit, string) format -> 'a
  (** 保持Printf.sprintf原有行为 *)
end

(** {1 初始化函数} *)

val init_from_env : unit -> unit
(** 从环境变量初始化日志配置 *)

val init : unit -> unit
(** 初始化日志系统 *)

(** {1 快速设置函数} *)

val enable_debug : unit -> unit
(** 设置为调试模式 *)

val enable_quiet : unit -> unit
(** 设置为静默模式 *)

val enable_verbose : unit -> unit
(** 设置为详细模式 *)