(** 统一日志系统 - 消除项目中的printf重复调用 *)

open Printf

(** 基础日志级别 *)
type log_level = 
  | Debug
  | Info  
  | Warning
  | Error

(** 将日志级别转换为字符串 *)
let string_of_level = function
  | Debug -> "DEBUG"
  | Info -> "INFO"
  | Warning -> "WARNING"
  | Error -> "ERROR"

(* 结构化日志条目类型已移除，暂时不需要 *)

(** 当前日志级别配置 *)
let current_log_level = ref Info

(** 设置日志级别 *)
let set_log_level level = current_log_level := level

(** 检查是否应该输出此级别的日志 *)
let should_log level =
  let level_priority = function
    | Debug -> 0 | Info -> 1 | Warning -> 2 | Error -> 3
  in
  level_priority level >= level_priority !current_log_level

(** 格式化时间戳 *)
let format_timestamp timestamp =
  let tm = Unix.localtime timestamp in
  sprintf "%04d-%02d-%02d %02d:%02d:%02d"
    (tm.tm_year + 1900) (tm.tm_mon + 1) tm.tm_mday
    tm.tm_hour tm.tm_min tm.tm_sec

(** 基础日志输出函数 *)
let log_with_level level module_name message =
  if should_log level then
    let timestamp = Unix.gettimeofday () in
    let time_str = format_timestamp timestamp in
    let level_str = string_of_level level in
    let formatted = sprintf "[%s] %s %s: %s" time_str level_str module_name message in
    match level with
    | Error -> eprintf "%s\n%!" formatted
    | Warning -> eprintf "%s\n%!" formatted  
    | _ -> printf "%s\n%!" formatted

(** 便捷的日志函数 *)
let debug module_name message = log_with_level Debug module_name message
let info module_name message = log_with_level Info module_name message  
let warning module_name message = log_with_level Warning module_name message
let error module_name message = log_with_level Error module_name message

(** 带格式化的日志函数 *)
let debugf module_name fmt = ksprintf (debug module_name) fmt
let infof module_name fmt = ksprintf (info module_name) fmt
let warningf module_name fmt = ksprintf (warning module_name) fmt
let errorf module_name fmt = ksprintf (error module_name) fmt

(** 专门的消息模块 *)
module Messages = struct
  (** 错误消息模块 *)
  module Error = struct
    let undefined_variable var_name = 
      sprintf "未定义的变量: %s" var_name
      
    let function_arity_mismatch func_name expected actual =
      sprintf "函数「%s」参数数量不匹配: 期望 %d 个参数，但提供了 %d 个参数" 
        func_name expected actual
        
    let type_mismatch expected actual =
      sprintf "类型不匹配: 期望 %s，但得到 %s" expected actual
      
    let file_not_found filename =
      sprintf "文件未找到: %s" filename
      
    let module_member_not_found mod_name member_name =
      sprintf "模块 %s 中未找到成员: %s" mod_name member_name
  end
  
  (** 编译器消息模块 *)
  module Compiler = struct
    let compiling_file filename =
      sprintf "正在编译文件: %s" filename
      
    let compilation_complete files_count time_taken =
      sprintf "编译完成: %d 个文件，耗时 %.2f 秒" files_count time_taken
      
    let analysis_stats total_functions duplicate_functions =
      sprintf "分析统计: 总函数 %d 个，重复函数 %d 个" total_functions duplicate_functions
  end
  
  (** C代码生成消息模块 *)
  module Codegen = struct
    let luoyan_int i = sprintf "luoyan_int(%dL)" i
    let luoyan_string s = sprintf "luoyan_string(\"%s\")" (String.escaped s)
    let luoyan_call func_code arg_count args_code =
      sprintf "luoyan_call(%s, %d, %s)" func_code arg_count args_code
    let luoyan_bool b = sprintf "luoyan_bool(%b)" b
    let luoyan_float f = sprintf "luoyan_float(%g)" f
  end
  
  (** 调试消息模块 *)
  module Debug = struct
    let variable_value var_name value = 
      sprintf "变量 %s = %s" var_name value
      
    let function_call func_name args = 
      sprintf "调用函数 %s(%s)" func_name (String.concat ", " args)
      
    let type_inference expr type_result = 
      sprintf "类型推断: %s : %s" expr type_result
      
    let infer_calls count =
      sprintf "推断调用: %d" count
  end
  
  (** 位置信息模块 *)
  module Position = struct
    let format_position filename line column =
      sprintf "%s:%d:%d" filename line column
      
    let format_error_with_position error_type position message =
      sprintf "%s %s: %s" error_type position message
  end
end

(** 结构化日志模块 *)
module Structured = struct
  let log_with_context level module_name message context =
    let context_str = 
      if context = [] then ""
      else
        let pairs = List.map (fun (k, v) -> sprintf "%s=%s" k v) context in
        sprintf " [%s]" (String.concat ", " pairs)
    in
    let full_message = message ^ context_str in
    log_with_level level module_name full_message
    
  let debugf_ctx module_name context fmt = 
    ksprintf (fun msg -> log_with_context Debug module_name msg context) fmt
  let infof_ctx module_name context fmt = 
    ksprintf (fun msg -> log_with_context Info module_name msg context) fmt
  let warningf_ctx module_name context fmt = 
    ksprintf (fun msg -> log_with_context Warning module_name msg context) fmt
  let errorf_ctx module_name context fmt = 
    ksprintf (fun msg -> log_with_context Error module_name msg context) fmt
end

(** 性能监控日志模块 *)
module Performance = struct
  let compilation_stats ~files_compiled ~total_time ~memory_used =
    infof "Performance" "编译完成: %d文件, 耗时%.2f秒, 内存%dMB" 
      files_compiled total_time memory_used
      
  let cache_stats ~hits ~misses ~hit_rate =
    infof "Cache" "缓存统计: 命中%d次, 未命中%d次, 命中率%.1f%%" 
      hits misses hit_rate
      
  let parsing_time filename time_ms =
    infof "Parser" "解析 %s 耗时: %.2fms" filename time_ms
end

(** 用户输出模块 - 用于替代直接的打印输出 *)
module UserOutput = struct
  let success message = 
    printf "✅ %s\n%!" message
    
  let warning message = 
    printf "⚠️  %s\n%!" message
    
  let error message = 
    eprintf "❌ %s\n%!" message
    
  let info message = 
    printf "ℹ️  %s\n%!" message
    
  let progress message = 
    printf "🔄 %s\n%!" message
end

(** 兼容性函数 - 用于逐步迁移 *)
module Legacy = struct
  (** 替代Printf.printf的函数 *)
  let printf fmt = ksprintf (info "Legacy") fmt
  
  (** 替代Printf.eprintf的函数 *)
  let eprintf fmt = ksprintf (error "Legacy") fmt
  
  (** 替代Printf.sprintf - 保持原有行为 *)
  let sprintf = Printf.sprintf
end