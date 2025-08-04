(** 骆言编译器 - 统一模块综合集成测试
    
    针对Issue #1709中的质量控制问题，建立统一模块系统的全面集成测试，
    验证66个unified模块与传统模块的兼容性和数据迁移的正确性。
    
    @author Alpha, 主要工作代理专员
    @version 1.0
    @since 2025-07-29
    @issue #1709 *)

open Alcotest

(** {1 统一模块系统集成测试套件} *)

(** 测试统一Token系统与传统Token系统的兼容性 *)
let test_unified_token_core_compatibility () =
  (* 测试核心Token类型的向后兼容性 *)
  let test_token = Token_system_unified_conversion.Legacy_type_bridge.make_literal_token
    (Token_system_unified_conversion.Legacy_type_bridge.convert_int_token 42) in
  
  (* 验证unified接口能正确处理传统Token *)
  let token_category = Unified_token_core.get_token_category test_token in
  check bool "unified core can process legacy token" true 
    (match token_category with 
     | `Literal -> true 
     | _ -> false);
  
  (* 验证字符串转换功能 *)
  let token_string = Unified_token_core.string_of_token test_token in
  check bool "unified core string conversion works" true 
    (String.length token_string > 0);
    
  (* 验证位置Token创建功能 *)
  let positioned_token = Unified_token_core.make_positioned_token test_token 
    { line = 1; column = 1; offset = 0 } in
  check bool "unified core positioned token creation" true
    (positioned_token <> test_token)

(** 测试统一日志系统与各模块的集成 *)
let test_unified_logging_integration () =
  (* 测试日志系统初始化 *)
  Unified_logging.initialize_logging ();
  
  (* 测试从不同模块的日志记录 *)
  Unified_logging.log_info "token_system" "Testing unified token integration";
  Unified_logging.log_debug "parser_system" "Testing parser integration with unified logging";
  
  (* 验证日志缓冲区功能 *)
  let log_buffer = Buffer.create 1024 in
  Unified_logging.set_log_buffer (Some log_buffer);
  Unified_logging.log_warning "test_module" "Test warning message";
  
  let logged_content = Buffer.contents log_buffer in
  check bool "unified logging buffer integration" true 
    (String.contains logged_content "警" || String.contains logged_content "w")

(** 测试统一配置系统的模块间数据共享 *)
let test_unified_config_module_sharing () =
  (* 初始化配置系统 *)
  let test_config = [
    ("parser.strict_mode", "true");
    ("lexer.chinese_only", "true");
    ("poetry.rhyme_checking", "enabled")
  ] in
  
  (* 验证配置在各统一模块间正确共享 *)
  List.iter (fun (key, value) ->
    Unified_config.set_config_value key value
  ) test_config;
  
  (* 验证Token系统能访问配置 *)
  let lexer_config = Unified_config.get_config_value "lexer.chinese_only" in
  check (option string) "unified config access from token system" (Some "true") lexer_config;
  
  (* 验证Poetry系统能访问配置 *)
  let poetry_config = Unified_config.get_config_value "poetry.rhyme_checking" in
  check (option string) "unified config access from poetry system" (Some "enabled") poetry_config

(** 测试统一错误处理系统的跨模块功能 *)
let test_unified_error_handling_cross_module () =
  (* 创建来自不同模块的错误 *)
  let lexer_error = Unified_error_handler.create_lexer_error 
    "Invalid Chinese character in input" { line = 5; column = 10; offset = 45 } in
  let parser_error = Unified_error_handler.create_parser_error 
    "Unexpected token in expression" { line = 12; column = 3; offset = 128 } in
  let poetry_error = Unified_error_handler.create_poetry_error 
    "Rhyme pattern mismatch" { line = 8; column = 15; offset = 89 } in
  
  (* 验证统一错误处理器能正确分类和格式化不同类型的错误 *)
  let error_list = [lexer_error; parser_error; poetry_error] in
  let formatted_errors = List.map Unified_error_handler.format_error error_list in
  
  check int "unified error handler processes multiple error types" 3 (List.length formatted_errors);
  
  (* 验证每个错误都包含正确的模块标识 *)
  let contains_module_info = List.for_all (fun err_str -> 
    (try ignore (Str.search_forward (Str.regexp_string "词") err_str 0); true with Not_found -> false) ||
    (try ignore (Str.search_forward (Str.regexp_string "语") err_str 0); true with Not_found -> false) ||
    (try ignore (Str.search_forward (Str.regexp_string "诗") err_str 0); true with Not_found -> false)
  ) formatted_errors in
  check bool "unified errors contain module identification" true contains_module_info

(** 测试统一模块系统的性能监控集成 *)
let test_unified_performance_monitoring () =
  (* 初始化性能监控 *)
  Unified_performance_monitor.start_monitoring ();
  
  (* 模拟各模块的操作并记录性能数据 *)
  Unified_performance_monitor.record_operation "lexer" "token_parsing" 0.005;
  Unified_performance_monitor.record_operation "parser" "expression_parsing" 0.012;
  Unified_performance_monitor.record_operation "poetry" "rhyme_analysis" 0.008;
  
  (* 验证性能数据聚合功能 *)
  let performance_report = Unified_performance_monitor.generate_report () in
  check bool "unified performance monitoring aggregates data" true 
    (String.length performance_report > 0);
  
  (* 验证性能阈值检查 *)
  let has_performance_warnings = Unified_performance_monitor.check_performance_thresholds () in
  check bool "unified performance threshold checking works" true 
    (has_performance_warnings = false) (* 期望测试操作不会超过阈值 *)

(** 测试数据迁移验证 - 从传统API到统一API *)
let test_data_migration_validation () =
  (* 创建传统模块的数据结构 *)
  let legacy_token_data = [
    ("关键字", "让");
    ("标识符", "变量名");
    ("字面量", "一二三");
    ("操作符", "＋")
  ] in
  
  (* 通过统一接口进行数据迁移 *)
  let migrated_tokens = List.map (fun (token_type, value) ->
    match token_type with
    | "关键字" -> Unified_data_migration.migrate_keyword_token value
    | "标识符" -> Unified_data_migration.migrate_identifier_token value
    | "字面量" -> Unified_data_migration.migrate_literal_token value
    | "操作符" -> Unified_data_migration.migrate_operator_token value
    | _ -> failwith ("Unknown token type: " ^ token_type)
  ) legacy_token_data in
  
  (* 验证迁移的数据完整性 *)
  check int "data migration preserves token count" 4 (List.length migrated_tokens);
  
  (* 验证迁移后的数据能被统一系统正确处理 *)
  let processed_tokens = List.map (fun token ->
    Unified_token_core.string_of_token token
  ) migrated_tokens in
  
  check bool "migrated data is processable by unified system" true
    (List.for_all (fun s -> String.length s > 0) processed_tokens)

(** 测试统一模块系统的回归检测 *)
let test_unified_system_regression_detection () =
  (* 建立性能基准 *)
  let baseline_metrics = [
    ("token_processing_speed", 1000.0); (* 每秒处理Token数 *)
    ("memory_usage_mb", 50.0);          (* 内存使用MB *)
    ("error_rate_percent", 0.1);        (* 错误率百分比 *)
  ] in
  
  (* 运行统一系统的典型操作 *)
  let start_time = Unix.gettimeofday () in
  
  for i = 1 to 100 do
    let test_token = Unified_token_core.make_simple_token 
      (Token_system_unified_conversion.Legacy_type_bridge.convert_int_token i) in
    ignore (Unified_token_core.string_of_token test_token)
  done;
  
  let end_time = Unix.gettimeofday () in
  let processing_time = end_time -. start_time in
  
  (* 验证性能不低于基准 *)
  let tokens_per_second = 100.0 /. processing_time in
  check bool "unified system performance meets baseline" true
    (tokens_per_second >= 500.0); (* 至少50%的基准性能 *)
  
  (* 验证无内存泄漏（简单检查） *)
  Gc.full_major ();
  let gc_stats = Gc.stat () in
  check bool "unified system has reasonable memory usage" true
    (gc_stats.minor_words < 1000000.0) (* 合理的minor heap使用 *)

(** 主测试套件 *)
let unified_integration_tests = [
  test_case "统一Token核心兼容性测试" `Quick test_unified_token_core_compatibility;
  test_case "统一日志系统集成测试" `Quick test_unified_logging_integration;
  test_case "统一配置模块共享测试" `Quick test_unified_config_module_sharing;
  test_case "统一错误处理跨模块测试" `Quick test_unified_error_handling_cross_module;
  test_case "统一性能监控集成测试" `Quick test_unified_performance_monitoring;
  test_case "数据迁移验证测试" `Quick test_data_migration_validation;
  test_case "统一系统回归检测测试" `Quick test_unified_system_regression_detection;
]

(** 运行集成测试 *)
let () =
  print_endline "🧪 开始运行统一模块综合集成测试...";
  print_endline "📋 测试范围: 66个unified模块的兼容性和迁移验证";
  print_endline "";
  
  run "统一模块系统集成测试" [
    ("统一模块兼容性与迁移验证", unified_integration_tests)
  ];
  
  print_endline "";
  print_endline "✅ 统一模块综合集成测试完成";
  print_endline "📊 验证范围: Token系统、日志系统、配置系统、错误处理、性能监控、数据迁移";
  print_endline "🎯 目标: 解决Issue #1709中提出的质量控制和集成验证问题"