(** 骆言统一日志系统 - 消除项目中的printf调用重复 *)

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

(** 全局日志配置 *)
let global_config = {
  current_level = INFO;
  show_timestamps = false;
  show_module_name = true;
  show_colors = true;
  output_channel = stdout;
  error_channel = stderr;
}

(** {1 级别转换函数} *)

(** 获取日志级别的数字表示 *)
let level_to_int = function 
  | DEBUG -> 0 | INFO -> 1 | WARN -> 2 | ERROR -> 3 | QUIET -> 4

(** 获取日志级别的中文字符串表示 *)
let level_to_string = function
  | DEBUG -> "调试"
  | INFO -> "信息"
  | WARN -> "警告"  
  | ERROR -> "错误"
  | QUIET -> "静默"

(** 获取日志级别的英文简写 *)
let level_to_short_string = function
  | DEBUG -> "DBG"
  | INFO -> "INF"
  | WARN -> "WRN"
  | ERROR -> "ERR"
  | QUIET -> "QUI"

(** 获取日志级别的颜色码 *)
let level_to_color = function
  | DEBUG -> Constants.Colors.debug_color   (* 青色 *)
  | INFO -> Constants.Colors.info_color     (* 绿色 *)
  | WARN -> Constants.Colors.warn_color     (* 黄色 *)
  | ERROR -> Constants.Colors.error_color   (* 红色 *)
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
  Printf.sprintf "%04d-%02d-%02d %02d:%02d:%02d"
    (tm.tm_year + 1900) (tm.tm_mon + 1) tm.tm_mday
    tm.tm_hour tm.tm_min tm.tm_sec

(** 判断是否应该输出此级别的日志 *)
let should_log level =
  level_to_int level >= level_to_int global_config.current_level

(** 格式化日志消息 *)
let format_message level module_name message =
  let timestamp = 
    if global_config.show_timestamps then 
      "[" ^ get_timestamp () ^ "] " 
    else "" 
  in
  let module_part = 
    if global_config.show_module_name then 
      "[" ^ module_name ^ "] " 
    else "" 
  in
  let level_str = level_to_string level in
  let color = if global_config.show_colors then level_to_color level else "" in
  let reset = if global_config.show_colors then Constants.Colors.reset else "" in
  Printf.sprintf "%s%s%s[%s] %s%s" 
    timestamp module_part color level_str message reset

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
    flush output_ch
  )

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
let debug_if condition module_name msg = 
  if condition then debug module_name msg

(** 有条件记录一般信息 *)
let info_if condition module_name msg = 
  if condition then info module_name msg

(** 有条件记录警告信息 *)
let warn_if condition module_name msg = 
  if condition then warn module_name msg

(** 有条件记录错误信息 *)
let error_if condition module_name msg = 
  if condition then error module_name msg

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
      (Printf.sprintf "失败 %s (耗时: %.3f秒): %s" 
         operation_name duration (Printexc.to_string e));
    raise e

(** {1 专门的消息模块} *)

module Messages = struct
  (** 错误消息模块 *)
  module Error = struct
    let undefined_variable var_name = 
      Printf.sprintf "未定义的变量: %s" var_name
      
    let function_arity_mismatch func_name expected actual =
      Printf.sprintf "函数「%s」参数数量不匹配: 期望 %d 个参数，但提供了 %d 个参数" 
        func_name expected actual
        
    let type_mismatch expected actual =
      Printf.sprintf "类型不匹配: 期望 %s，但得到 %s" expected actual
      
    let file_not_found filename =
      Printf.sprintf "文件未找到: %s" filename
      
    let module_member_not_found mod_name member_name =
      Printf.sprintf "模块 %s 中未找到成员: %s" mod_name member_name
  end
  
  (** 编译器消息模块 *)
  module Compiler = struct
    let compiling_file filename =
      Printf.sprintf "正在编译文件: %s" filename
      
    let compilation_complete files_count time_taken =
      Printf.sprintf "编译完成: %d 个文件，耗时 %.2f 秒" files_count time_taken
      
    let analysis_stats total_functions duplicate_functions =
      Printf.sprintf "分析统计: 总函数 %d 个，重复函数 %d 个" total_functions duplicate_functions
  end

  (** 调试消息模块 *)
  module Debug = struct
    let variable_value var_name value = 
      Printf.sprintf "变量 %s = %s" var_name value
      
    let function_call func_name args = 
      Printf.sprintf "调用函数 %s(%s)" func_name (String.concat ", " args)
      
    let type_inference expr type_result = 
      Printf.sprintf "类型推断: %s : %s" expr type_result
  end
end

(** {1 用户输出模块} *)

module UserOutput = struct
  (** 成功消息 *)
  let success message = 
    Printf.fprintf global_config.output_channel "✅ %s\n" message;
    flush global_config.output_channel
    
  (** 警告消息 *)
  let warning message = 
    Printf.fprintf global_config.output_channel "⚠️  %s\n" message;
    flush global_config.output_channel
    
  (** 错误消息 *)
  let error message = 
    Printf.fprintf global_config.error_channel "❌ %s\n" message;
    flush global_config.error_channel
    
  (** 信息消息 *)
  let info message = 
    Printf.fprintf global_config.output_channel "ℹ️  %s\n" message;
    flush global_config.output_channel
    
  (** 进度消息 *)
  let progress message = 
    Printf.fprintf global_config.output_channel "🔄 %s\n" message;
    flush global_config.output_channel

  (** 用户输出 - 程序执行结果等面向用户的信息 *)
  let print_user_output message =
    Printf.fprintf global_config.output_channel "%s\n" message;
    flush global_config.output_channel

  (** 编译器消息 - 编译过程中的提示信息 *)
  let print_compiler_message message =
    if should_log INFO then (
      Printf.fprintf global_config.output_channel "[编译器] %s\n" message;
      flush global_config.output_channel
    )

  (** 调试信息输出 *)
  let print_debug_info message =
    if should_log DEBUG then (
      Printf.fprintf global_config.output_channel "[调试] %s\n" message;
      flush global_config.output_channel
    )

  (** 不换行的用户输出 - 用于提示符等 *)
  let print_user_prompt message =
    Printf.fprintf global_config.output_channel "%s" message;
    flush global_config.output_channel
end

(** {1 兼容性模块} *)

module Legacy = struct
  (** 替代Printf.printf的函数 *)
  let printf fmt = Printf.ksprintf (info "Legacy") fmt
  
  (** 替代Printf.eprintf的函数 *)
  let eprintf fmt = Printf.ksprintf (error "Legacy") fmt
  
  (** 替代print_endline的函数 *)
  let print_endline message = info "Legacy" message
  
  (** 替代print_string的函数 *)
  let print_string message = 
    Printf.fprintf global_config.output_channel "%s" message;
    flush global_config.output_channel
  
  (** 保持Printf.sprintf原有行为 *)
  let sprintf = Printf.sprintf
end

(** {1 初始化函数} *)

(** 从环境变量初始化日志配置 *)
let init_from_env () =
  (* 设置日志级别 *)
  (try
    let level_str = Sys.getenv "LUOYAN_LOG_LEVEL" in
    let level = match String.lowercase_ascii level_str with
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
  (try
    let show_colors = Sys.getenv "LUOYAN_LOG_COLORS" = "true" in
    set_show_colors show_colors
  with Not_found -> ())

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