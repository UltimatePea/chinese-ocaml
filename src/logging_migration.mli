(** 日志系统迁移工具模块接口文件 - 帮助从旧日志系统平滑迁移到统一日志系统 *)

(** {1 迁移兼容性模块接口} *)

(** 兼容 Logger 模块的函数 *)
module Logger_compat : sig
  include module type of Unified_logging
  (** 包含 Unified_logging 的所有功能 *)

  (** 兼容旧的 log_level 类型 *)
  type old_log_level = DEBUG | INFO | WARN | ERROR | QUIET

  val convert_level : old_log_level -> Unified_logging.log_level
  (** 将旧的日志级别转换为新的日志级别 *)

  val set_level : old_log_level -> unit
  (** 兼容旧的设置函数 *)

  type old_log_config = {
    mutable current_level : old_log_level;
    mutable show_timestamps : bool;
    mutable show_module_name : bool;
    mutable output_channel : out_channel;
  }
  (** 兼容旧的日志配置类型 *)

  val print_user_output : string -> unit
  (** 兼容旧的输出函数 *)

  val print_compiler_message : string -> unit
  val print_debug_info : string -> unit
  val print_user_prompt : string -> unit
end

(** 兼容 Unified_logger 模块的函数 *)
module Unified_logger_compat : sig
  (** 兼容旧的日志级别类型 *)
  type old_log_level = Debug | Info | Warning | Error

  val convert_level : old_log_level -> Unified_logging.log_level
  (** 将旧的日志级别转换为新的日志级别 *)

  val debug : string -> string -> unit
  (** 兼容旧的基础日志函数 *)

  val info : string -> string -> unit
  val warning : string -> string -> unit
  val error : string -> string -> unit

  val debugf : string -> ('a, unit, string, unit) format4 -> 'a
  (** 兼容旧的格式化日志函数 *)

  val infof : string -> ('a, unit, string, unit) format4 -> 'a
  val warningf : string -> ('a, unit, string, unit) format4 -> 'a
  val errorf : string -> ('a, unit, string, unit) format4 -> 'a

  val set_log_level : old_log_level -> unit
  (** 兼容旧的设置函数 *)

  module Messages : module type of Unified_logging.Messages
  (** 兼容旧的消息模块 *)

  (** 兼容旧的结构化日志模块 *)
  module Structured : sig
    val log_with_context : old_log_level -> string -> string -> (string * string) list -> unit
    (** 带上下文的日志记录函数 *)

    val debugf_ctx : string -> (string * string) list -> ('a, unit, string, unit) format4 -> 'a
    (** 带上下文的格式化日志函数 *)

    val infof_ctx : string -> (string * string) list -> ('a, unit, string, unit) format4 -> 'a
    val warningf_ctx : string -> (string * string) list -> ('a, unit, string, unit) format4 -> 'a
    val errorf_ctx : string -> (string * string) list -> ('a, unit, string, unit) format4 -> 'a
  end

  (** 兼容旧的性能监控模块 *)
  module Performance : sig
    val compilation_stats : files_compiled:int -> total_time:float -> memory_used:int -> unit
    (** 编译统计信息 *)

    val cache_stats : hits:int -> misses:int -> hit_rate:float -> unit
    (** 缓存统计信息 *)

    val parsing_time : string -> float -> unit
    (** 解析时间统计 *)
  end

  module UserOutput : module type of Unified_logging.UserOutput
  (** 兼容旧的用户输出模块 *)

  module Legacy : module type of Unified_logging.Legacy
  (** 兼容旧的兼容性模块 *)
end

(** Logger_utils 兼容性模块 *)
module Logger_utils_compat : sig
  type logger_func = string -> unit
  (** 日志器函数类型 *)

  val init_all_loggers : string -> logger_func * logger_func * logger_func * logger_func
  (** 初始化所有级别的日志器 *)

  val init_info_error_loggers : string -> logger_func * logger_func
  (** 初始化信息和错误级别的日志器 *)

  val init_debug_error_loggers : string -> logger_func * logger_func
  (** 初始化调试和错误级别的日志器 *)

  val init_info_warn_error_loggers : string -> logger_func * logger_func * logger_func
  (** 初始化信息、警告和错误级别的日志器 *)

  val init_debug_info_error_loggers : string -> logger_func * logger_func * logger_func
  (** 初始化调试、信息和错误级别的日志器 *)

  val init_debug_info_loggers : string -> logger_func * logger_func
  (** 初始化调试和信息级别的日志器 *)

  val init_info_logger : string -> logger_func
  (** 只初始化信息级别的日志器 *)

  val init_error_logger : string -> logger_func
  (** 只初始化错误级别的日志器 *)

  val init_debug_logger : string -> logger_func
  (** 只初始化调试级别的日志器 *)

  val init_no_logger : string -> unit
  (** 不保存任何日志器引用，仅进行初始化 *)

  val init_module_logger : string -> logger_func * logger_func * logger_func * logger_func
  (** 兼容性函数 *)

  val infer_module_name : string -> string
  (** 自动模块名推断函数 *)

  val smart_init : string -> logger_func * logger_func
  (** 智能初始化函数 *)
end

(** {1 迁移助手函数接口} *)

val is_module_migrated : string -> bool
(** 检查模块是否已迁移到统一日志系统 *)

val create_migration_report : string list -> string
(** 为模块创建迁移报告 *)

val suggest_migration_order : string list -> string
(** 生成迁移建议 *)
