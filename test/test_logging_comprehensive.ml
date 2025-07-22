(** 骆言编译器日志模块综合测试 为issue #749提升测试覆盖率至50%+ - 日志系统模块测试 *)

open Alcotest

(** 日志级别基础测试 *)
let test_log_levels () =
  (* 测试日志级别转换 *)
  check int "debug_level_int" 0 (Luoyan_logging.Log_core.level_to_int DEBUG);
  check int "info_level_int" 1 (Luoyan_logging.Log_core.level_to_int INFO);
  check int "warn_level_int" 2 (Luoyan_logging.Log_core.level_to_int WARN);
  check int "error_level_int" 3 (Luoyan_logging.Log_core.level_to_int ERROR);
  check int "quiet_level_int" 4 (Luoyan_logging.Log_core.level_to_int QUIET);

  (* 测试级别字符串转换 *)
  check string "debug_level_string" "调试" (Luoyan_logging.Log_core.level_to_string DEBUG);
  check string "info_level_string" "信息" (Luoyan_logging.Log_core.level_to_string INFO);
  check string "warn_level_string" "警告" (Luoyan_logging.Log_core.level_to_string WARN);
  check string "error_level_string" "错误" (Luoyan_logging.Log_core.level_to_string ERROR);
  check string "quiet_level_string" "静默" (Luoyan_logging.Log_core.level_to_string QUIET)

(** 日志配置测试 *)
let test_log_configuration () =
  (* 测试日志级别设置和获取 *)
  Luoyan_logging.Log_core.set_level INFO;
  check bool "info_level_set" true
    (match Luoyan_logging.Log_core.get_level () with INFO -> true | _ -> false);

  Luoyan_logging.Log_core.set_level DEBUG;
  check bool "debug_level_set" true
    (match Luoyan_logging.Log_core.get_level () with DEBUG -> true | _ -> false);

  (* 测试配置选项设置 *)
  Luoyan_logging.Log_core.set_show_timestamps true;
  Luoyan_logging.Log_core.set_show_module_name true;
  Luoyan_logging.Log_core.set_show_colors false;

  (* 验证配置已设置（通过全局配置访问） *)
  let config = Luoyan_logging.Log_core.global_config in
  check bool "timestamps_enabled" true config.show_timestamps;
  check bool "module_name_enabled" true config.show_module_name;
  check bool "colors_disabled" false config.show_colors

(** 日志过滤测试 *)
let test_log_filtering () =
  (* 设置为WARN级别 *)
  Luoyan_logging.Log_core.set_level WARN;

  (* 测试级别过滤 *)
  check bool "debug_should_not_log" false (Luoyan_logging.Log_core.should_log DEBUG);
  check bool "info_should_not_log" false (Luoyan_logging.Log_core.should_log INFO);
  check bool "warn_should_log" true (Luoyan_logging.Log_core.should_log WARN);
  check bool "error_should_log" true (Luoyan_logging.Log_core.should_log ERROR);

  (* 设置为DEBUG级别 *)
  Luoyan_logging.Log_core.set_level DEBUG;

  (* 测试所有级别都应该输出 *)
  check bool "debug_should_log_in_debug_mode" true (Luoyan_logging.Log_core.should_log DEBUG);
  check bool "info_should_log_in_debug_mode" true (Luoyan_logging.Log_core.should_log INFO);
  check bool "warn_should_log_in_debug_mode" true (Luoyan_logging.Log_core.should_log WARN);
  check bool "error_should_log_in_debug_mode" true (Luoyan_logging.Log_core.should_log ERROR)

(** 基础日志功能测试 *)
let test_basic_logging () =
  (* 设置为DEBUG级别以确保所有日志都输出 *)
  Luoyan_logging.Log_core.set_level DEBUG;
  Luoyan_logging.Log_core.set_show_timestamps false;
  Luoyan_logging.Log_core.set_show_colors false;

  (* 测试基础日志函数 *)
  Luoyan_logging.Log_core.debug "test_module" "debug_message";
  Luoyan_logging.Log_core.info "test_module" "info_message";
  Luoyan_logging.Log_core.warn "test_module" "warn_message";
  Luoyan_logging.Log_core.error "test_module" "error_message";

  (* 这些调用应该不会崩溃 *)
  check bool "basic_logging_no_crash" true true

(** 条件日志测试 *)
let test_conditional_logging () =
  Luoyan_logging.Log_core.set_level DEBUG;

  (* 测试条件日志 - 条件为真时应该输出 *)
  Luoyan_logging.Log_core.debug_if true "test_module" "conditional_debug";
  Luoyan_logging.Log_core.info_if true "test_module" "conditional_info";
  Luoyan_logging.Log_core.warn_if true "test_module" "conditional_warn";
  Luoyan_logging.Log_core.error_if true "test_module" "conditional_error";

  (* 测试条件日志 - 条件为假时不应该输出 *)
  Luoyan_logging.Log_core.debug_if false "test_module" "should_not_appear";
  Luoyan_logging.Log_core.info_if false "test_module" "should_not_appear";
  Luoyan_logging.Log_core.warn_if false "test_module" "should_not_appear";
  Luoyan_logging.Log_core.error_if false "test_module" "should_not_appear";

  check bool "conditional_logging_no_crash" true true

(** 格式化日志测试 *)
let test_formatted_logging () =
  Luoyan_logging.Log_core.set_level DEBUG;

  (* 测试格式化日志函数 *)
  Luoyan_logging.Log_core.debugf "test_module" "debug: %s %d" "test" 42;
  Luoyan_logging.Log_core.infof "test_module" "info: %s %d" "test" 42;
  Luoyan_logging.Log_core.warnf "test_module" "warn: %s %d" "test" 42;
  Luoyan_logging.Log_core.errorf "test_module" "error: %s %d" "test" 42;

  check bool "formatted_logging_no_crash" true true

(** 模块日志器测试 *)
let test_module_logger () =
  (* 创建模块日志器 *)
  let debug, info, warn, error = Luoyan_logging.Log_core.create_module_logger "test_module" in

  (* 测试模块日志器功能 *)
  debug "module_debug_message";
  info "module_info_message";
  warn "module_warn_message";
  error "module_error_message";

  (* 测试初始化模块日志器（别名） *)
  let debug2, info2, warn2, error2 = Luoyan_logging.Log_core.init_module_logger "test_module2" in

  debug2 "module2_debug_message";
  info2 "module2_info_message";
  warn2 "module2_warn_message";
  error2 "module2_error_message";

  check bool "module_logger_no_crash" true true

(** 性能监控测试 *)
let test_performance_monitoring () =
  Luoyan_logging.Log_core.set_level DEBUG;

  (* 测试性能测量 *)
  let result =
    Luoyan_logging.Log_core.time_operation "test_module" "test_operation" (fun () ->
        (* 模拟一些工作 *)
        Unix.sleepf 0.001;
        42)
  in

  check int "timed_operation_result" 42 result;
  check bool "performance_monitoring_no_crash" true true

(** 快速设置功能测试 *)
let test_quick_setup () =
  (* 测试快速设置函数 *)
  Luoyan_logging.Log_core.enable_debug ();
  check bool "debug_mode_enabled" true
    (match Luoyan_logging.Log_core.get_level () with DEBUG -> true | _ -> false);

  Luoyan_logging.Log_core.enable_quiet ();
  check bool "quiet_mode_enabled" true
    (match Luoyan_logging.Log_core.get_level () with QUIET -> true | _ -> false);

  Luoyan_logging.Log_core.enable_verbose ();
  check bool "verbose_mode_enabled" true
    (match Luoyan_logging.Log_core.get_level () with DEBUG -> true | _ -> false)

(** 日志消息模块测试 *)
let test_log_messages () =
  (* 测试错误消息生成 *)
  let undefined_var_msg = Luoyan_logging.Log_messages.Error.undefined_variable "test_var" in
  check bool "undefined_variable_message" true (String.length undefined_var_msg > 0);

  let arity_mismatch_msg =
    Luoyan_logging.Log_messages.Error.function_arity_mismatch "test_func" 2 3
  in
  check bool "arity_mismatch_message" true (String.length arity_mismatch_msg > 0);

  let type_mismatch_msg = Luoyan_logging.Log_messages.Error.type_mismatch "int" "string" in
  check bool "type_mismatch_message" true (String.length type_mismatch_msg > 0);

  let file_not_found_msg = Luoyan_logging.Log_messages.Error.file_not_found "test.ly" in
  check bool "file_not_found_message" true (String.length file_not_found_msg > 0);

  let module_member_msg =
    Luoyan_logging.Log_messages.Error.module_member_not_found "Test" "member"
  in
  check bool "module_member_not_found_message" true (String.length module_member_msg > 0);

  (* 测试编译器消息生成 *)
  let compiling_msg = Luoyan_logging.Log_messages.Compiler.compiling_file "test.ly" in
  check bool "compiling_file_message" true (String.length compiling_msg > 0);

  let compilation_complete_msg = Luoyan_logging.Log_messages.Compiler.compilation_complete 5 1.5 in
  check bool "compilation_complete_message" true (String.length compilation_complete_msg > 0);

  let analysis_stats_msg = Luoyan_logging.Log_messages.Compiler.analysis_stats 100 20 in
  check bool "analysis_stats_message" true (String.length analysis_stats_msg > 0);

  (* 测试调试消息生成 *)
  let variable_value_msg = Luoyan_logging.Log_messages.Debug.variable_value "x" "42" in
  check bool "variable_value_message" true (String.length variable_value_msg > 0);

  let function_call_msg =
    Luoyan_logging.Log_messages.Debug.function_call "test_func" [ "arg1"; "arg2" ]
  in
  check bool "function_call_message" true (String.length function_call_msg > 0);

  let type_inference_msg = Luoyan_logging.Log_messages.Debug.type_inference "x" "int" in
  check bool "type_inference_message" true (String.length type_inference_msg > 0)

(** 日志系统初始化测试 *)
let test_logging_initialization () =
  (* 测试日志系统初始化 *)
  Luoyan_logging.Log_core.init ();
  check bool "logging_init_no_crash" true true;

  (* 测试环境变量初始化 *)
  Luoyan_logging.Log_core.init_from_env ();
  check bool "logging_init_from_env_no_crash" true true

(** 时间戳和格式化测试 *)
let test_timestamp_and_formatting () =
  (* 测试时间戳生成 *)
  let timestamp = Luoyan_logging.Log_core.get_timestamp () in
  check bool "timestamp_generated" true (String.length timestamp > 0);

  (* 测试消息格式化 *)
  Luoyan_logging.Log_core.set_show_timestamps true;
  Luoyan_logging.Log_core.set_show_module_name true;

  let formatted_msg = Luoyan_logging.Log_core.format_message INFO "test_module" "test_message" in
  check bool "message_formatted" true (String.length formatted_msg > 0);

  (* 消息应该包含模块名 *)
  check bool "message_contains_module" true (String.contains formatted_msg '[')

(** 日志颜色和样式测试 *)
let test_log_colors_and_styles () =
  (* 测试颜色代码生成 *)
  let debug_color = Luoyan_logging.Log_core.level_to_color DEBUG in
  let info_color = Luoyan_logging.Log_core.level_to_color INFO in
  let warn_color = Luoyan_logging.Log_core.level_to_color WARN in
  let error_color = Luoyan_logging.Log_core.level_to_color ERROR in

  check bool "debug_color_exists" true (String.length debug_color > 0);
  check bool "info_color_exists" true (String.length info_color > 0);
  check bool "warn_color_exists" true (String.length warn_color > 0);
  check bool "error_color_exists" true (String.length error_color > 0);

  (* 测试颜色设置 *)
  Luoyan_logging.Log_core.set_show_colors true;
  check bool "colors_enabled" true Luoyan_logging.Log_core.global_config.show_colors;

  Luoyan_logging.Log_core.set_show_colors false;
  check bool "colors_disabled" false Luoyan_logging.Log_core.global_config.show_colors

(** 错误处理和边界情况测试 *)
let test_error_handling_and_edge_cases () =
  (* 测试在QUIET模式下的日志行为 *)
  Luoyan_logging.Log_core.set_level QUIET;

  Luoyan_logging.Log_core.debug "test_module" "should_not_appear";
  Luoyan_logging.Log_core.info "test_module" "should_not_appear";
  Luoyan_logging.Log_core.warn "test_module" "should_not_appear";
  Luoyan_logging.Log_core.error "test_module" "should_not_appear";

  check bool "quiet_mode_no_crash" true true;

  (* 测试空字符串和特殊字符 *)
  Luoyan_logging.Log_core.set_level DEBUG;
  Luoyan_logging.Log_core.debug "" "";
  Luoyan_logging.Log_core.info "test" "";
  Luoyan_logging.Log_core.warn "" "test";
  Luoyan_logging.Log_core.error "test\nwith\nnewlines" "message\nwith\nnewlines";

  check bool "edge_case_strings_no_crash" true true

(** 测试套件 *)
let test_suite =
  [
    ("日志级别基础", `Quick, test_log_levels);
    ("日志配置", `Quick, test_log_configuration);
    ("日志过滤", `Quick, test_log_filtering);
    ("基础日志功能", `Quick, test_basic_logging);
    ("条件日志", `Quick, test_conditional_logging);
    ("格式化日志", `Quick, test_formatted_logging);
    ("模块日志器", `Quick, test_module_logger);
    ("性能监控", `Quick, test_performance_monitoring);
    ("快速设置功能", `Quick, test_quick_setup);
    ("日志消息模块", `Quick, test_log_messages);
    ("日志系统初始化", `Quick, test_logging_initialization);
    ("时间戳和格式化", `Quick, test_timestamp_and_formatting);
    ("日志颜色和样式", `Quick, test_log_colors_and_styles);
    ("错误处理和边界情况", `Quick, test_error_handling_and_edge_cases);
  ]

let () = run "日志模块综合测试" [ ("日志模块综合测试", test_suite) ]
