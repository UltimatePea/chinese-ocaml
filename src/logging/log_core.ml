(** 骆言日志系统核心模块 - 基础类型、配置和工具函数 - Printf.sprintf统一化Phase 2 *)

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
let global_config =
  {
    current_level = INFO;
    show_timestamps = false;
    show_module_name = true;
    show_colors = true;
    output_channel = stdout;
    error_channel = stderr;
  }

(** {1 级别转换函数} *)

(** 获取日志级别的数字表示 *)
let level_to_int = function DEBUG -> 0 | INFO -> 1 | WARN -> 2 | ERROR -> 3 | QUIET -> 4

(** 获取日志级别的中文字符串表示 *)
let level_to_string = function
  | DEBUG -> "调试"
  | INFO -> "信息"
  | WARN -> "警告"
  | ERROR -> "错误"
  | QUIET -> "静默"

(** 获取日志级别的颜色码 *)
let level_to_color = function
  | DEBUG -> "\027[36m" (* 青色 *)
  | INFO -> "\027[32m" (* 绿色 *)
  | WARN -> "\027[33m" (* 黄色 *)
  | ERROR -> "\027[31m" (* 红色 *)
  | QUIET -> ""

(** {1 配置函数} *)

(** 设置日志级别 *)
let set_level level = global_config.current_level <- level

(** 获取当前日志级别 *)
let get_level () = global_config.current_level

(** 设置是否显示时间戳 *)
let set_show_timestamps enabled = global_config.show_timestamps <- enabled

(** 设置是否显示模块名 *)
let set_show_module_name enabled = global_config.show_module_name <- enabled

(** 设置是否显示颜色 *)
let set_show_colors enabled = global_config.show_colors <- enabled

(** 设置输出通道 *)
let set_output_channel channel = global_config.output_channel <- channel

(** 设置错误输出通道 *)
let set_error_channel channel = global_config.error_channel <- channel

(** {1 工具函数} *)

(** 获取当前时间戳 *)
let get_timestamp () =
  let time = Unix.time () in
  let tm = Unix.localtime time in
  (* Local format_unix_time implementation - Printf.sprintf统一化Phase 2 *)
  let pad_int n width =
    let s = string_of_int n in
    let len = String.length s in
    if len >= width then s
    else String.make (width - len) '0' ^ s
  in
  String.concat "" [ 
    pad_int (tm.Unix.tm_year + 1900) 4; "-";
    pad_int (tm.Unix.tm_mon + 1) 2; "-";
    pad_int tm.Unix.tm_mday 2; " ";
    pad_int tm.Unix.tm_hour 2; ":";
    pad_int tm.Unix.tm_min 2; ":";
    pad_int tm.Unix.tm_sec 2
  ]

(** 判断是否应该输出此级别的日志 *)
let should_log level = level_to_int level >= level_to_int global_config.current_level

(** 格式化日志消息 *)
let format_message level module_name message =
  let timestamp = if global_config.show_timestamps then "[" ^ get_timestamp () ^ "] " else "" in
  let module_part = if global_config.show_module_name then "[" ^ module_name ^ "] " else "" in
  let level_str = level_to_string level in
  let color = if global_config.show_colors then level_to_color level else "" in
  let reset = if global_config.show_colors then "\027[0m" else "" in
  (* Local format_log_entry implementation - Printf.sprintf统一化Phase 2 *)
  String.concat "" [ timestamp; module_part; color; "["; level_str; "] "; message; reset ]

(** {1 核心日志函数} *)

(** 核心日志函数 *)
let log_internal level module_name message =
  if should_log level then (
    let formatted = format_message level module_name message in
    let output_ch =
      match level with
      | ERROR -> global_config.error_channel
      | WARN -> global_config.error_channel
      | _ -> global_config.output_channel
    in
    Printf.fprintf output_ch "%s\n" formatted;
    flush output_ch)

(** {1 基础日志函数} *)

(** 记录调试信息 *)
let debug module_name msg = log_internal DEBUG module_name msg

(** 记录一般信息 *)
let info module_name msg = log_internal INFO module_name msg

(** 记录警告信息 *)
let warn module_name msg = log_internal WARN module_name msg

(** 记录错误信息 *)
let error module_name msg = log_internal ERROR module_name msg

(** {1 格式化日志函数} *)

(** 格式化记录调试信息 *)
let debugf module_name fmt = Printf.ksprintf (debug module_name) fmt

(** 格式化记录一般信息 *)
let infof module_name fmt = Printf.ksprintf (info module_name) fmt

(** 格式化记录警告信息 *)
let warnf module_name fmt = Printf.ksprintf (warn module_name) fmt

(** 格式化记录错误信息 *)
let errorf module_name fmt = Printf.ksprintf (error module_name) fmt

(** {1 条件日志函数} *)

(** 有条件记录调试信息 *)
let debug_if condition module_name msg = if condition then debug module_name msg

(** 有条件记录一般信息 *)
let info_if condition module_name msg = if condition then info module_name msg

(** 有条件记录警告信息 *)
let warn_if condition module_name msg = if condition then warn module_name msg

(** 有条件记录错误信息 *)
let error_if condition module_name msg = if condition then error module_name msg

(** {1 模块日志器} *)

(** 创建模块专用日志器 *)
let create_module_logger module_name =
  let debug msg = debug module_name msg in
  let info msg = info module_name msg in
  let warn msg = warn module_name msg in
  let error msg = error module_name msg in
  (debug, info, warn, error)

(** 初始化模块日志器（别名） *)
let init_module_logger = create_module_logger

(** {1 性能监控} *)

(** 性能测量辅助函数 *)
let time_operation module_name operation_name f =
  let start_time = Unix.gettimeofday () in
  (* Local operation message implementations - Printf.sprintf统一化Phase 2 *)
  debug module_name (String.concat "" [ "开始 "; operation_name ]);
  try
    let result = f () in
    let end_time = Unix.gettimeofday () in
    let duration = end_time -. start_time in
    info module_name (String.concat "" [ "完成 "; operation_name; " (耗时: "; string_of_float duration; "秒)" ]);
    result
  with e ->
    let end_time = Unix.gettimeofday () in
    let duration = end_time -. start_time in
    error module_name
      (String.concat "" [ "失败 "; operation_name; " (耗时: "; string_of_float duration; "秒): "; Printexc.to_string e ]);
    raise e

(** {1 初始化函数} *)

(** 从环境变量初始化日志配置 *)
let init_from_env () =
  (* 设置日志级别 *)
  (try
     let level_str = Sys.getenv "LUOYAN_LOG_LEVEL" in
     let level =
       match String.lowercase_ascii level_str with
       | "debug" -> DEBUG
       | "info" -> INFO
       | "warn" | "warning" -> WARN
       | "error" -> ERROR
       | "quiet" -> QUIET
       | _ -> INFO
     in
     set_level level
   with Not_found -> ());

  (* 设置时间戳显示 *)
  (try
     let show_timestamps = Sys.getenv "LUOYAN_LOG_TIMESTAMPS" = "true" in
     set_show_timestamps show_timestamps
   with Not_found -> ());

  (* 设置模块名显示 *)
  (try
     let show_module = Sys.getenv "LUOYAN_LOG_MODULE" = "true" in
     set_show_module_name show_module
   with Not_found -> ());

  (* 设置颜色显示 *)
  try
    let show_colors = Sys.getenv "LUOYAN_LOG_COLORS" = "true" in
    set_show_colors show_colors
  with Not_found -> ()

(** 初始化日志系统 *)
let init () =
  init_from_env ();
  info "UnifiedLogging" "统一日志系统已初始化"

(** {1 快速设置函数} *)

(** 设置为调试模式 *)
let enable_debug () =
  set_level DEBUG;
  set_show_timestamps true;
  info "UnifiedLogging" "已启用调试模式"

(** 设置为静默模式 *)
let enable_quiet () =
  set_level QUIET;
  info "UnifiedLogging" "已启用静默模式"

(** 设置为详细模式 *)
let enable_verbose () =
  set_level DEBUG;
  set_show_timestamps true;
  set_show_module_name true;
  info "UnifiedLogging" "已启用详细模式"
