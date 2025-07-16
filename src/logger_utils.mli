(** 统一日志器初始化工具模块接口 *)

(** 
 * 本模块提供统一的日志器初始化接口，解决项目中日志器初始化代码重复问题
 *)

(** 日志器函数类型 *)
type logger_func = string -> unit

(** 初始化所有级别的日志器 (debug, info, warn, error) *)
val init_all_loggers : string -> logger_func * logger_func * logger_func * logger_func

(** 初始化信息和错误级别的日志器 *)
val init_info_error_loggers : string -> logger_func * logger_func

(** 初始化调试和错误级别的日志器 *)
val init_debug_error_loggers : string -> logger_func * logger_func

(** 初始化信息、警告和错误级别的日志器 *)
val init_info_warn_error_loggers : string -> logger_func * logger_func * logger_func

(** 初始化调试、信息和错误级别的日志器 *)
val init_debug_info_error_loggers : string -> logger_func * logger_func * logger_func

(** 初始化调试和信息级别的日志器 *)
val init_debug_info_loggers : string -> logger_func * logger_func

(** 只初始化信息级别的日志器 *)
val init_info_logger : string -> logger_func

(** 只初始化错误级别的日志器 *)
val init_error_logger : string -> logger_func

(** 只初始化调试级别的日志器 *)
val init_debug_logger : string -> logger_func

(** 不保存任何日志器引用，仅进行初始化 *)
val init_no_logger : string -> unit

(** 兼容性函数 - 保持与现有代码的兼容性 *)
val init_module_logger : string -> logger_func * logger_func * logger_func * logger_func

(** 
 * 自动模块名推断函数
 * 根据OCaml文件名自动推断模块名
 *)
val infer_module_name : string -> string

(** 
 * 智能初始化函数
 * 根据模块的常用日志级别自动选择合适的初始化函数
 *)
val smart_init : string -> logger_func * logger_func