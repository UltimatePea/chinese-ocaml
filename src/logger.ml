(** 统一日志系统 - 替代散布在各模块中的 Printf.printf 调用 *)

(** 日志级别 *)
type log_level =
  | DEBUG (* 调试信息 *)
  | INFO (* 一般信息 *)
  | WARN (* 警告信息 *)
  | ERROR (* 错误信息 *)
  | QUIET (* 静默模式 *)

type log_config = {
  mutable current_level : log_level;
  mutable show_timestamps : bool;
  mutable show_module_name : bool;
  mutable output_channel : out_channel;
}
(** 日志配置 *)

(** 全局日志配置 *)
let global_config =
  {
    current_level = INFO;
    show_timestamps = false;
    show_module_name = true;
    output_channel = stdout;
  }

(** 获取日志级别的数字表示 *)
let level_to_int = function DEBUG -> 0 | INFO -> 1 | WARN -> 2 | ERROR -> 3 | QUIET -> 4

(** 获取日志级别的字符串表示 *)
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

(** 颜色重置码 *)
let reset_color = "\027[0m"

(** 设置日志级别 *)
let set_level level = global_config.current_level <- level

(** 获取当前日志级别 *)
let get_level () = global_config.current_level

(** 设置是否显示时间戳 *)
let set_show_timestamps enabled = global_config.show_timestamps <- enabled

(** 设置是否显示模块名 *)
let set_show_module_name enabled = global_config.show_module_name <- enabled

(** 设置输出通道 *)
let set_output_channel channel = global_config.output_channel <- channel

(** 获取当前时间戳 *)
let get_timestamp () =
  let time = Unix.time () in
  let tm = Unix.localtime time in
  Printf.sprintf "%04d-%02d-%02d %02d:%02d:%02d" (tm.tm_year + 1900) (tm.tm_mon + 1) tm.tm_mday
    tm.tm_hour tm.tm_min tm.tm_sec

(** 格式化日志消息 *)
let format_message level module_name message =
  let timestamp = if global_config.show_timestamps then "[" ^ get_timestamp () ^ "] " else "" in
  let module_part = if global_config.show_module_name then "[" ^ module_name ^ "] " else "" in
  let level_str = level_to_string level in
  let color = level_to_color level in
  Printf.sprintf "%s%s%s%s[%s] %s%s" timestamp module_part color level_str level_str message
    reset_color

(** 核心日志函数 *)
let log_internal level module_name message =
  if level_to_int level >= level_to_int global_config.current_level then (
    let formatted = format_message level module_name message in
    Printf.fprintf global_config.output_channel "%s\n" formatted;
    flush global_config.output_channel)

(** 模块专用日志函数 *)
let create_module_logger module_name =
  let debug msg = log_internal DEBUG module_name msg in
  let info msg = log_internal INFO module_name msg in
  let warn msg = log_internal WARN module_name msg in
  let error msg = log_internal ERROR module_name msg in
  (debug, info, warn, error)

(** 通用日志函数 *)
let debug module_name msg = log_internal DEBUG module_name msg

let info module_name msg = log_internal INFO module_name msg
let warn module_name msg = log_internal WARN module_name msg
let error module_name msg = log_internal ERROR module_name msg

(** 格式化日志函数 *)
let debugf module_name fmt = Printf.ksprintf (debug module_name) fmt

let infof module_name fmt = Printf.ksprintf (info module_name) fmt
let warnf module_name fmt = Printf.ksprintf (warn module_name) fmt
let errorf module_name fmt = Printf.ksprintf (error module_name) fmt

(** 条件日志函数 *)
let debug_if condition module_name msg = if condition then debug module_name msg

let info_if condition module_name msg = if condition then info module_name msg
let warn_if condition module_name msg = if condition then warn module_name msg
let error_if condition module_name msg = if condition then error module_name msg

(** 性能测量辅助函数 *)
let time_operation module_name operation_name f =
  let start_time = Unix.gettimeofday () in
  debug module_name (Printf.sprintf "开始 %s" operation_name);
  try
    let result = f () in
    let end_time = Unix.gettimeofday () in
    let duration = end_time -. start_time in
    info module_name (Printf.sprintf "完成 %s (耗时: %.3f秒)" operation_name duration);
    result
  with e ->
    let end_time = Unix.gettimeofday () in
    let duration = end_time -. start_time in
    error module_name
      (Printf.sprintf "失败 %s (耗时: %.3f秒): %s" operation_name duration (Printexc.to_string e));
    raise e

(** 简便的模块级初始化函数 *)
let init_module_logger module_name = create_module_logger module_name

(** 从环境变量初始化日志配置 *)
let init_from_env () =
  try
    let level_str = Sys.getenv "LUOYAN_LOG_LEVEL" in
    let level =
      match String.lowercase_ascii level_str with
      | "debug" -> DEBUG
      | "info" -> INFO
      | "warn" -> WARN
      | "error" -> ERROR
      | "quiet" -> QUIET
      | _ -> INFO
    in
    set_level level
  with Not_found -> (
    ();

    try
      let show_timestamps = Sys.getenv "LUOYAN_LOG_TIMESTAMPS" = "true" in
      set_show_timestamps show_timestamps
    with Not_found -> (
      ();

      try
        let show_module = Sys.getenv "LUOYAN_LOG_MODULE" = "true" in
        set_show_module_name show_module
      with Not_found -> ()))

(** 初始化日志系统 *)
let init () = init_from_env ()

(** 统一输出接口 - 替代散布各处的 print_endline 和 print_string *)

(** 用户输出 - 程序执行结果等面向用户的信息 *)
let print_user_output message =
  Printf.fprintf global_config.output_channel "%s\n" message;
  flush global_config.output_channel

(** 编译器消息 - 编译过程中的提示信息 *)
let print_compiler_message message =
  if level_to_int global_config.current_level <= level_to_int INFO then (
    Printf.fprintf global_config.output_channel "[编译器] %s\n" message;
    flush global_config.output_channel)

(** 调试信息输出 *)
let print_debug_info message =
  if level_to_int global_config.current_level <= level_to_int DEBUG then (
    Printf.fprintf global_config.output_channel "[调试] %s\n" message;
    flush global_config.output_channel)

(** 不换行的用户输出 - 用于提示符等 *)
let print_user_prompt message =
  Printf.fprintf global_config.output_channel "%s" message;
  flush global_config.output_channel
