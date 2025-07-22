(** 日志系统迁移工具模块 - 帮助从旧日志系统平滑迁移到统一日志系统 
    Phase 4 重构: 使用统一格式化器消除Printf.sprintf *)

(** {1 迁移兼容性函数} *)

(** 兼容 Logger 模块的函数 *)
module Logger_compat = struct
  include Unified_logging

  (** 兼容旧的 log_level 类型 *)
  type old_log_level = DEBUG | INFO | WARN | ERROR | QUIET

  (** 将旧的日志级别转换为新的日志级别 *)
  let convert_level = function
    | DEBUG -> Unified_logging.DEBUG
    | INFO -> Unified_logging.INFO
    | WARN -> Unified_logging.WARN
    | ERROR -> Unified_logging.ERROR
    | QUIET -> Unified_logging.QUIET

  (** 兼容旧的设置函数 *)
  let set_level old_level = Unified_logging.set_level (convert_level old_level)

  type old_log_config = {
    mutable current_level : old_log_level;
    mutable show_timestamps : bool;
    mutable show_module_name : bool;
    mutable output_channel : out_channel;
  }
  (** 兼容旧的日志配置类型 *)

  (** 兼容旧的输出函数 *)
  let print_user_output = Unified_logging.UserOutput.print_user_output

  let print_compiler_message = Unified_logging.UserOutput.print_compiler_message
  let print_debug_info = Unified_logging.UserOutput.print_debug_info
  let print_user_prompt = Unified_logging.UserOutput.print_user_prompt
end

(** 兼容 Unified_logger 模块的函数 *)
module Unified_logger_compat = struct
  (** 兼容旧的日志级别类型 *)
  type old_log_level = Debug | Info | Warning | Error

  (** 将旧的日志级别转换为新的日志级别 *)
  let convert_level = function
    | Debug -> Unified_logging.DEBUG
    | Info -> Unified_logging.INFO
    | Warning -> Unified_logging.WARN
    | Error -> Unified_logging.ERROR

  (** 兼容旧的基础日志函数 *)
  let debug = Unified_logging.debug

  let info = Unified_logging.info
  let warning = Unified_logging.warn
  let error = Unified_logging.error

  (** 兼容旧的格式化日志函数 *)
  let debugf = Unified_logging.debugf

  let infof = Unified_logging.infof
  let warningf = Unified_logging.warnf
  let errorf = Unified_logging.errorf

  (** 兼容旧的设置函数 *)
  let set_log_level old_level = Unified_logging.set_level (convert_level old_level)

  module Messages = Unified_logging.Messages
  (** 兼容旧的消息模块 *)

  (** 兼容旧的结构化日志模块 *)
  module Structured = struct
    let log_with_context level module_name message context =
      let context_str =
        if context = [] then ""
        else
          let pairs = List.map (fun (k, v) -> Unified_formatter.LoggingFormatter.format_context_pair k v) context in
          Unified_formatter.LoggingFormatter.format_context_group pairs
      in
      let full_message = message ^ context_str in
      match convert_level level with
      | DEBUG -> Unified_logging.debug module_name full_message
      | INFO -> Unified_logging.info module_name full_message
      | WARN -> Unified_logging.warn module_name full_message
      | ERROR -> Unified_logging.error module_name full_message
      | QUIET -> ()

    let debugf_ctx module_name context fmt =
      Printf.ksprintf (fun msg -> log_with_context Debug module_name msg context) fmt

    let infof_ctx module_name context fmt =
      Printf.ksprintf (fun msg -> log_with_context Info module_name msg context) fmt

    let warningf_ctx module_name context fmt =
      Printf.ksprintf (fun msg -> log_with_context Warning module_name msg context) fmt

    let errorf_ctx module_name context fmt =
      Printf.ksprintf (fun msg -> log_with_context Error module_name msg context) fmt
  end

  (** 兼容旧的性能监控模块 *)
  module Performance = struct
    let compilation_stats ~files_compiled ~total_time ~memory_used =
      Unified_logging.infof "Performance" "编译完成: %d文件, 耗时%.2f秒, 内存%dMB" files_compiled total_time
        memory_used

    let cache_stats ~hits ~misses ~hit_rate =
      Unified_logging.infof "Cache" "缓存统计: 命中%d次, 未命中%d次, 命中率%.1f%%" hits misses hit_rate

    let parsing_time filename time_ms =
      Unified_logging.infof "Parser" "解析 %s 耗时: %.2fms" filename time_ms
  end

  module UserOutput = Unified_logging.UserOutput
  (** 兼容旧的用户输出模块 *)

  module Legacy = Unified_logging.Legacy
  (** 兼容旧的兼容性模块 *)
end

(** Logger_utils 兼容性模块 *)
module Logger_utils_compat = struct
  type logger_func = string -> unit

  (** 初始化所有级别的日志器 *)
  let init_all_loggers module_name = Unified_logging.create_module_logger module_name

  (** 初始化信息和错误级别的日志器 *)
  let init_info_error_loggers module_name =
    let _, info, _, error = Unified_logging.create_module_logger module_name in
    (info, error)

  (** 初始化调试和错误级别的日志器 *)
  let init_debug_error_loggers module_name =
    let debug, _, _, error = Unified_logging.create_module_logger module_name in
    (debug, error)

  (** 初始化信息、警告和错误级别的日志器 *)
  let init_info_warn_error_loggers module_name =
    let _, info, warn, error = Unified_logging.create_module_logger module_name in
    (info, warn, error)

  (** 初始化调试、信息和错误级别的日志器 *)
  let init_debug_info_error_loggers module_name =
    let debug, info, _, error = Unified_logging.create_module_logger module_name in
    (debug, info, error)

  (** 初始化调试和信息级别的日志器 *)
  let init_debug_info_loggers module_name =
    let debug, info, _, _ = Unified_logging.create_module_logger module_name in
    (debug, info)

  (** 只初始化信息级别的日志器 *)
  let init_info_logger module_name =
    let _, info, _, _ = Unified_logging.create_module_logger module_name in
    info

  (** 只初始化错误级别的日志器 *)
  let init_error_logger module_name =
    let _, _, _, error = Unified_logging.create_module_logger module_name in
    error

  (** 只初始化调试级别的日志器 *)
  let init_debug_logger module_name =
    let debug, _, _, _ = Unified_logging.create_module_logger module_name in
    debug

  (** 不保存任何日志器引用，仅进行初始化 *)
  let init_no_logger module_name =
    let _ = Unified_logging.create_module_logger module_name in
    ()

  (** 兼容性函数 *)
  let init_module_logger = Unified_logging.create_module_logger

  (** 自动模块名推断函数 *)
  let infer_module_name filename =
    let basename = Filename.basename filename in
    let name_without_ext = Filename.remove_extension basename in
    let capitalized = String.capitalize_ascii name_without_ext in
    let convert_underscores str =
      let len = String.length str in
      let buffer = Buffer.create len in
      let rec loop i capitalize_next =
        if i >= len then Buffer.contents buffer
        else
          let c = str.[i] in
          if c = '_' then loop (i + 1) true
          else if capitalize_next then (
            Buffer.add_char buffer (Char.uppercase_ascii c);
            loop (i + 1) false)
          else (
            Buffer.add_char buffer c;
            loop (i + 1) false)
      in
      loop 0 false
    in
    convert_underscores capitalized

  (** 智能初始化函数 *)
  let smart_init module_name =
    match module_name with
    | "Main" | "Compiler" -> init_info_error_loggers module_name
    | "Parser" | "ParserPoetry" -> init_debug_error_loggers module_name
    | "Semantic" | "TypesInfer" -> init_info_error_loggers module_name
    | "Codegen" | "CCodegen" -> init_debug_error_loggers module_name
    | "ErrorRecovery" ->
        let _, info, error = init_debug_info_error_loggers module_name in
        (info, error)
    | _ -> init_info_error_loggers module_name
end

(** {1 迁移助手函数} *)

(** 检查模块是否已迁移到统一日志系统 *)
let is_module_migrated _module_name =
  (* 这里可以实现检查逻辑，比如检查是否还有直接的Printf调用 *)
  (* 暂时返回false，表示需要迁移 *)
  false

(** 为模块创建迁移报告 *)
let create_migration_report module_files =
  let total_files = List.length module_files in
  let migrated_count =
    List.fold_left (fun acc file -> if is_module_migrated file then acc + 1 else acc) 0 module_files
  in

  let progress_percent = 
    if total_files > 0 then float_of_int migrated_count /. float_of_int total_files *. 100.0
    else 0.0
  in
  Unified_formatter.LoggingFormatter.format_migration_progress total_files migrated_count progress_percent

(** 生成迁移建议 *)
let suggest_migration_order module_files =
  (* 按照依赖关系和重要性排序，建议迁移顺序 *)
  (* 这里可以实现更复杂的分析逻辑 *)
  let priority_modules = [ "Logger"; "Constants"; "Error_messages" ] in
  let core_modules = [ "Parser"; "Semantic"; "Codegen" ] in
  let other_modules =
    List.filter
      (fun m -> (not (List.mem m priority_modules)) && not (List.mem m core_modules))
      module_files
  in

  Unified_formatter.LoggingFormatter.format_migration_suggestions
    (String.concat ", " priority_modules)
    (String.concat ", " core_modules)
    (String.concat ", " other_modules)
