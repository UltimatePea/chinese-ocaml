(** 骆言编译器日志格式化模块

    本模块专注于日志和调试信息的格式化，从unified_formatter.ml中拆分出来。 提供统一的日志格式化接口，消除Printf.sprintf依赖。

    重构目的：大型模块细化 - Fix #893
    @author 骆言AI代理
    @version 1.0
    @since 2025-07-22 *)

(* 引入基础格式化器，实现零Printf.sprintf依赖 *)
open Utils.Base_formatter

(** 调试和日志格式化 *)
module LogMessages = struct
  let debug module_name message =
    context_message_pattern "[DEBUG]" (context_message_pattern module_name message)

  let info module_name message =
    context_message_pattern "[INFO]" (context_message_pattern module_name message)

  let warning module_name message =
    context_message_pattern "[WARNING]" (context_message_pattern module_name message)

  let error module_name message =
    context_message_pattern "[ERROR]" (context_message_pattern module_name message)

  let trace func_name message =
    context_message_pattern "[TRACE]" (context_message_pattern func_name message)

  (** 扩展日志类型 *)
  let verbose module_name message =
    context_message_pattern "[VERBOSE]" (context_message_pattern module_name message)

  let fatal module_name message =
    context_message_pattern "[FATAL]" (context_message_pattern module_name message)

  let perf module_name operation duration_ms =
    context_message_pattern "[PERF]"
      (concat_strings [ module_name; " - "; operation; ": "; int_to_string duration_ms; "ms" ])

  (** 结构化日志 *)
  let structured_log level module_name operation details =
    concat_strings
      [
        "[";
        level;
        "] ";
        module_name;
        " :: ";
        operation;
        (if details <> "" then concat_strings [ " - "; details ] else "");
      ]
end

(** 编译器状态消息格式化 *)
module CompilerMessages = struct
  let compiling_file filename = context_message_pattern "正在编译文件" filename
  let compilation_complete filename = context_message_pattern "编译完成" filename
  let compilation_failed filename error = concat_strings [ "编译失败: "; filename; " - "; error ]

  (** 符号禁用消息 *)
  let unsupported_chinese_symbol char_bytes =
    concat_strings [ "非支持的中文符号已禁用，只支持「」『』：，。（）。禁用符号: "; char_bytes ]

  (** 扩展编译状态 *)
  let parsing_start filename = context_message_pattern "开始语法分析" filename

  let parsing_complete filename = context_message_pattern "语法分析完成" filename
  let type_checking_start filename = context_message_pattern "开始类型检查" filename
  let type_checking_complete filename = context_message_pattern "类型检查完成" filename
  let code_generation_start filename = context_message_pattern "开始代码生成" filename
  let code_generation_complete filename = context_message_pattern "代码生成完成" filename

  let compilation_phase phase filename =
    context_message_pattern (concat_strings [ "编译阶段: "; phase ]) filename

  let compilation_progress current total filename =
    concat_strings [ "编译进度 ["; int_to_string current; "/"; int_to_string total; "] "; filename ]
end

(** 增强日志消息模块 *)
module EnhancedLogMessages = struct
  (** 编译状态增强消息 *)
  let compiling_file filename = concat_strings [ "正在编译文件: "; filename ]

  let compilation_complete_stats files_count time_taken =
    concat_strings
      [ "编译完成: "; int_to_string files_count; " 个文件，耗时 "; float_to_string time_taken; " 秒" ]

  (** 操作状态消息 - Phase 2 统一的高频模式 *)
  let operation_start operation_name = concat_strings [ "开始 "; operation_name ]

  let operation_complete operation_name duration =
    concat_strings [ "完成 "; operation_name; " (耗时: "; float_to_string duration; "秒)" ]

  let operation_failed operation_name duration error_msg =
    concat_strings [ "失败 "; operation_name; " (耗时: "; float_to_string duration; "秒): "; error_msg ]

  (** 时间戳格式化 - 统一日期时间格式 *)
  let format_timestamp year month day hour min sec =
    let pad_int n width =
      let s = int_to_string n in
      let len = String.length s in
      if len >= width then s else String.make (width - len) '0' ^ s
    in
    concat_strings
      [
        pad_int year 4;
        "-";
        pad_int month 2;
        "-";
        pad_int day 2;
        " ";
        pad_int hour 2;
        ":";
        pad_int min 2;
        ":";
        pad_int sec 2;
      ]

  (** Unix时间结构格式化 *)
  let format_unix_time tm =
    format_timestamp (tm.Unix.tm_year + 1900) (tm.Unix.tm_mon + 1) tm.Unix.tm_mday tm.Unix.tm_hour
      tm.Unix.tm_min tm.Unix.tm_sec

  (** 完整日志消息格式化 - 支持时间戳、模块名、颜色 *)
  let format_log_entry timestamp_part module_part color_part level_str message reset_color =
    concat_strings
      [ timestamp_part; module_part; color_part; "["; level_str; "] "; message; reset_color ]

  (** 简化日志消息格式化（不含颜色重置） *)
  let format_simple_log_entry timestamp_part module_part color_part level_str message =
    concat_strings
      [ timestamp_part; module_part; color_part; level_str; "["; level_str; "] "; message ]

  (** 带模块名的日志消息增强 *)
  let debug_enhanced module_name operation detail =
    concat_strings [ "[DEBUG]["; module_name; "] "; operation; ": "; detail ]

  let info_enhanced module_name operation detail =
    concat_strings [ "[INFO]["; module_name; "] "; operation; ": "; detail ]

  let warning_enhanced module_name operation detail =
    concat_strings [ "[WARNING]["; module_name; "] "; operation; ": "; detail ]

  let error_enhanced module_name operation detail =
    concat_strings [ "[ERROR]["; module_name; "] "; operation; ": "; detail ]

  (** 性能日志 *)
  let performance_start operation = context_message_pattern "[PERF-START]" operation

  let performance_end operation duration_ms =
    concat_strings [ "[PERF-END] "; operation; " 耗时: "; int_to_string duration_ms; "ms" ]

  let memory_usage operation heap_mb stack_mb =
    concat_strings
      [
        "[MEMORY] ";
        operation;
        " - 堆内存: ";
        int_to_string heap_mb;
        "MB, 栈内存: ";
        int_to_string stack_mb;
        "MB";
      ]

  (** 开发者日志 *)
  let dev_checkpoint checkpoint_name data =
    concat_strings [ "[DEV-CHECKPOINT] "; checkpoint_name; ": "; data ]

  let dev_assertion assertion_name result =
    concat_strings [ "[DEV-ASSERT] "; assertion_name; " = "; bool_to_string result ]

  (** 系统日志 *)
  let system_resource operation resource_type usage =
    concat_strings [ "[SYSTEM] "; operation; " - "; resource_type; ": "; usage ]

  let system_event event_type details =
    concat_strings [ "[SYSTEM-EVENT] "; event_type; " - "; details ]

  (** 测试日志 *)
  let test_start test_name = context_message_pattern "[TEST-START]" test_name

  let test_pass test_name = context_message_pattern "[TEST-PASS]" test_name
  let test_fail test_name reason = concat_strings [ "[TEST-FAIL] "; test_name; " - "; reason ]

  let test_suite_summary total_tests passed_tests failed_tests =
    concat_strings
      [
        "[TEST-SUMMARY] 总计: ";
        int_to_string total_tests;
        ", 通过: ";
        int_to_string passed_tests;
        ", 失败: ";
        int_to_string failed_tests;
      ]
end

(** 日志格式化器 *)
module LoggingFormatter = struct
  (** 时间戳格式化 *)
  let format_timestamp year month day hour minute second =
    concat_strings
      [
        int_to_string year;
        "-";
        (if month < 10 then "0" else "");
        int_to_string month;
        "-";
        (if day < 10 then "0" else "");
        int_to_string day;
        " ";
        (if hour < 10 then "0" else "");
        int_to_string hour;
        ":";
        (if minute < 10 then "0" else "");
        int_to_string minute;
        ":";
        (if second < 10 then "0" else "");
        int_to_string second;
      ]

  (** 基础日志条目格式化 *)
  let format_log_entry level_str message = concat_strings [ "["; level_str; "] "; message ]

  let format_simple_log_entry level message = concat_strings [ "["; level; "] "; message ]

  (** 日志级别格式化 *)
  let format_log_level level = concat_strings [ "["; level; "]" ]

  (** 迁移信息格式化 *)
  let format_migration_info operation status = concat_strings [ "迁移"; operation; ": "; status ]

  (** 传统日志格式化 *)
  let format_legacy_log module_name message =
    concat_strings [ "[LEGACY]["; module_name; "] "; message ]

  (** 核心日志消息格式化 *)
  let format_core_log_message component_name log_content =
    concat_strings [ "[CORE]["; component_name; "] "; log_content ]

  (** 上下文键值对格式化 *)
  let format_context_pair key value = concat_strings [ key; "="; value ]

  (** 上下文组格式化 *)
  let format_context_group context_pairs =
    concat_strings [ " ["; String.concat ", " context_pairs; "]" ]

  (** 迁移进度报告格式化 *)
  let format_migration_progress total_files migrated_count progress_percent =
    concat_strings
      [
        "迁移进度报告:\n总文件数: ";
        int_to_string total_files;
        "\n已迁移: ";
        int_to_string migrated_count;
        "\n待迁移: ";
        int_to_string (total_files - migrated_count);
        "\n进度: ";
        float_to_string progress_percent;
        "%";
      ]

  (** 迁移建议格式化 *)
  let format_migration_suggestions priority_modules core_modules other_modules =
    concat_strings
      [
        "建议迁移顺序:\n1. 优先级模块: ";
        priority_modules;
        "\n2. 核心模块: ";
        core_modules;
        "\n3. 其他模块: ";
        other_modules;
      ]

  (** 多行日志格式化 *)
  let format_multiline_log level title lines =
    let header = concat_strings [ "["; level; "] "; title; ":" ] in
    let formatted_lines = List.map (fun line -> concat_strings [ "  "; line ]) lines in
    join_with_separator "\n" (header :: formatted_lines)

  (** 日志分隔符 *)
  let log_separator length char = String.make length (String.get char 0)

  let log_section_header title =
    let separator = log_separator 60 "=" in
    concat_strings [ separator; "\n"; title; "\n"; separator ]

  (** 结构化日志JSON格式 *)
  let format_json_log_entry level timestamp module_name message =
    concat_strings
      [
        "{\"level\":\"";
        level;
        "\",\"timestamp\":\"";
        timestamp;
        "\",\"module\":\"";
        module_name;
        "\",\"message\":\"";
        message;
        "\"}";
      ]

  (** 调试信息格式化 *)
  let format_debug_context function_name variables =
    let var_list = List.map (fun (name, value) -> concat_strings [ name; "="; value ]) variables in
    concat_strings
      [ "[DEBUG-CONTEXT] "; function_name; " {"; join_with_separator ", " var_list; "}" ]

  (** 错误堆栈格式化 *)
  let format_error_stack error_msg stack_frames =
    let header = concat_strings [ "[ERROR] "; error_msg ] in
    let formatted_frames = List.map (fun frame -> concat_strings [ "  at "; frame ]) stack_frames in
    join_with_separator "\n" (header :: formatted_frames)
end

(** 调试格式化器 *)
module DebugFormatter = struct
  (** 变量状态格式化 *)
  let format_variable_state var_name var_type var_value =
    concat_strings [ var_name; ": "; var_type; " = "; var_value ]

  let format_variable_list variables =
    let formatted_vars =
      List.map (fun (name, typ, value) -> format_variable_state name typ value) variables
    in
    join_with_separator "\n" formatted_vars

  (** 函数调用追踪 *)
  let format_function_call func_name args return_type =
    concat_strings [ func_name; "("; join_with_separator ", " args; ") -> "; return_type ]

  let format_call_stack calls =
    let numbered_calls =
      List.mapi (fun i call -> concat_strings [ int_to_string (i + 1); ". "; call ]) calls
    in
    join_with_separator "\n" numbered_calls

  (** 表达式求值追踪 *)
  let format_expression_eval expr result = concat_strings [ expr; " => "; result ]

  let format_step_by_step_eval steps =
    let numbered_steps =
      List.mapi (fun i step -> concat_strings [ "步骤 "; int_to_string (i + 1); ": "; step ]) steps
    in
    join_with_separator "\n" numbered_steps

  (** AST节点格式化 *)
  let format_ast_node node_type node_content = concat_strings [ node_type; "("; node_content; ")" ]

  let format_ast_tree nodes indent_level =
    let indent = String.make (indent_level * 2) ' ' in
    let formatted_nodes = List.map (fun node -> concat_strings [ indent; node ]) nodes in
    join_with_separator "\n" formatted_nodes
end
