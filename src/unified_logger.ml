(** 统一日志系统 - 消除项目中的printf重复调用 Phase 5.1 重构: Printf.sprintf 依赖消除完成
    @version 5.1 - Printf.sprintf 依赖消除完成
    @since 2025-07-24 Issue #1044 Printf.sprintf Phase 5 *)

open Printf
open Unified_formatter.LoggingFormatter

(** 基础日志级别 *)
type log_level = Debug | Info | Warning | Error

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
  let level_priority = function Debug -> 0 | Info -> 1 | Warning -> 2 | Error -> 3 in
  level_priority level >= level_priority !current_log_level

(** 格式化时间戳 *)
let format_timestamp timestamp =
  let tm = Unix.localtime timestamp in
  Unified_formatter.EnhancedLogMessages.format_unix_time tm

(** 基础日志输出函数 *)
let log_with_level level module_name message =
  if should_log level then
    let timestamp = Unix.gettimeofday () in
    let time_str = format_timestamp timestamp in
    let level_str = string_of_level level in
    let formatted = format_log_entry level_str (module_name ^ ": " ^ message) in
    let formatted_with_time = "[" ^ time_str ^ "] " ^ formatted in
    match level with
    | Error -> eprintf "%s\n%!" formatted_with_time
    | Warning -> eprintf "%s\n%!" formatted_with_time
    | _ -> printf "%s\n%!" formatted_with_time

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
    let undefined_variable var_name = Unified_formatter.ErrorMessages.undefined_variable var_name

    let function_arity_mismatch func_name expected actual =
      Unified_formatter.ErrorMessages.function_param_count_mismatch func_name expected actual

    let type_mismatch expected actual =
      Unified_formatter.ErrorMessages.type_mismatch expected actual

    let file_not_found filename = Unified_formatter.ErrorMessages.file_not_found filename

    let module_member_not_found mod_name member_name =
      Unified_formatter.ErrorMessages.member_not_found mod_name member_name
  end

  (** 编译器消息模块 *)
  module Compiler = struct
    let compiling_file filename = Unified_formatter.CompilerMessages.compiling_file filename

    let compilation_complete files_count time_taken =
      Unified_formatter.EnhancedLogMessages.compilation_complete_stats files_count time_taken

    let analysis_stats total_functions duplicate_functions =
      Unified_formatter.General.format_key_value
        ("分析统计: 总函数 " ^ string_of_int total_functions ^ " 个")
        ("重复函数 " ^ string_of_int duplicate_functions ^ " 个")
  end

  (** C代码生成消息模块 *)
  module Codegen = struct
    let luoyan_int i = Unified_formatter.CCodegen.luoyan_int i
    let luoyan_string s = Unified_formatter.CCodegen.luoyan_string s

    let luoyan_call func_code arg_count args_code =
      Unified_formatter.CCodegen.luoyan_call func_code arg_count args_code

    let luoyan_bool b = Unified_formatter.CCodegen.luoyan_bool b
    let luoyan_float f = Unified_formatter.CCodegen.luoyan_float f
  end

  (** 调试消息模块 *)
  module Debug = struct
    let variable_value var_name value = Unified_formatter.General.format_key_value var_name value

    let function_call func_name args =
      Unified_formatter.General.format_function_signature func_name args

    let type_inference expr type_result =
      Unified_formatter.General.format_key_value ("类型推断: " ^ expr) type_result

    let infer_calls count = "推断调用: " ^ string_of_int count
  end

  (** 位置信息模块 *)
  module Position = struct
    let format_position filename line column =
      Unified_formatter.Position.format_position filename line column

    let format_error_with_position error_type position message =
      Unified_formatter.Position.format_error_with_position position error_type message
  end
end

(** 结构化日志模块 *)
module Structured = struct
  let log_with_context level module_name message context =
    let context_str =
      if context = [] then ""
      else
        let pairs = List.map (fun (k, v) -> format_context_pair k v) context in
        format_context_group pairs
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
    infof "Performance" "编译完成: %d文件, 耗时%.2f秒, 内存%dMB" files_compiled total_time memory_used

  let cache_stats ~hits ~misses ~hit_rate =
    infof "Cache" "缓存统计: 命中%d次, 未命中%d次, 命中率%.1f%%" hits misses hit_rate

  let parsing_time filename time_ms = infof "Parser" "解析 %s 耗时: %.2fms" filename time_ms
end

(** 用户输出模块 - 用于替代直接的打印输出 *)
module UserOutput = struct
  let success message = printf "✅ %s\n%!" message
  let warning message = printf "⚠️  %s\n%!" message
  let error message = eprintf "❌ %s\n%!" message
  let info message = printf "ℹ️  %s\n%!" message
  let progress message = printf "🔄 %s\n%!" message
end

(** 兼容性函数 - 用于逐步迁移 *)
module Legacy = struct
  (** 替代Unified_logging.Legacy.printf的函数 *)
  let printf fmt = ksprintf (info "Legacy") fmt

  (** 替代Unified_logging.Legacy.eprintf的函数 *)
  let eprintf fmt = ksprintf (error "Legacy") fmt

  (** 替代Printf.sprintf - 使用Base_formatter消除Printf.sprintf依赖
      这个函数被弃用，建议使用Utils.Base_formatter中的具体格式化函数 *)
  let sprintf _fmt = failwith "sprintf已弃用，请使用Utils.Base_formatter中的具体格式化函数"
end
