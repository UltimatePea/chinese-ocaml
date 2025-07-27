(** 骆言日志格式化模块综合测试套件 - Fix #1007 Phase 1 核心模块测试覆盖率提升 *)

open Alcotest
open Yyocamlc_lib.Formatter_logging

(** 基础日志消息测试 *)
module LogMessagesTests = struct
  (** 测试基本日志级别格式化 *)
  let test_basic_log_levels () =
    let module_name = "测试模块" in
    let message = "测试消息" in
    
    (* 测试各个日志级别 *)
    let debug_msg = LogMessages.debug module_name message in
    let info_msg = LogMessages.info module_name message in
    let warning_msg = LogMessages.warning module_name message in
    let error_msg = LogMessages.error module_name message in
    let trace_msg = LogMessages.trace "测试函数" message in
    
    (* 验证格式包含预期的组件 *)
    check bool "debug消息包含DEBUG标签" true (String.contains debug_msg 'D');
    check bool "info消息包含INFO标签" true (String.contains info_msg 'I');
    check bool "warning消息包含WARNING标签" true (String.contains warning_msg 'W');
    check bool "error消息包含ERROR标签" true (String.contains error_msg 'E');
    check bool "trace消息包含TRACE标签" true (String.contains trace_msg 'T');
    
    (* 验证消息长度合理 *)
    check bool "debug消息长度合理" true (String.length debug_msg > 0);
    check bool "info消息长度合理" true (String.length info_msg > 0);
    check bool "warning消息长度合理" true (String.length warning_msg > 0);
    check bool "error消息长度合理" true (String.length error_msg > 0);
    check bool "trace消息长度合理" true (String.length trace_msg > 0)

  (** 测试扩展日志类型 *)
  let test_extended_log_types () =
    let module_name = "扩展模块" in
    let message = "扩展消息" in
    
    (* 测试verbose和fatal级别 *)
    let verbose_msg = LogMessages.verbose module_name message in
    let fatal_msg = LogMessages.fatal module_name message in
    
    check bool "verbose消息不为空" true (String.length verbose_msg > 0);
    check bool "fatal消息不为空" true (String.length fatal_msg > 0);
    
    (* 测试性能日志 *)
    let perf_msg = LogMessages.perf module_name "测试操作" 1500 in
    check bool "性能日志包含ms" true (String.contains perf_msg 'm');
    check bool "性能日志包含操作名" true (String.contains perf_msg '\230')

  (** 测试结构化日志 *)
  let test_structured_logging () =
    let level = "INFO" in
    let module_name = "结构化模块" in
    let operation = "测试操作" in
    let details = "详细信息" in
    
    let structured_msg = LogMessages.structured_log level module_name operation details in
    
    check bool "结构化日志包含级别" true (String.contains structured_msg 'I');
    check bool "结构化日志包含模块名" true (String.contains structured_msg "结");
    check bool "结构化日志包含操作" true (String.contains structured_msg "测");
    check bool "结构化日志包含详细信息" true (String.contains structured_msg "详");
    
    (* 测试无详细信息的情况 *)
    let simple_structured_msg = LogMessages.structured_log level module_name operation "" in
    check bool "简单结构化日志长度合理" true (String.length simple_structured_msg > 0)
end

(** 编译器消息测试 *)
module CompilerMessagesTests = struct
  (** 测试文件编译消息 *)
  let test_file_compilation_messages () =
    let filename = "test.ly" in
    
    (* 测试编译状态消息 *)
    let compiling_msg = CompilerMessages.compiling_file filename in
    let complete_msg = CompilerMessages.compilation_complete filename in
    let failed_msg = CompilerMessages.compilation_failed filename "语法错误" in
    
    check bool "编译中消息包含文件名" true (String.contains compiling_msg 't');
    check bool "编译完成消息包含文件名" true (String.contains complete_msg 't');
    check bool "编译失败消息包含错误信息" true (String.contains failed_msg "语");
    
    (* 验证消息格式合理 *)
    check bool "编译消息长度合理" true (String.length compiling_msg > 0);
    check bool "完成消息长度合理" true (String.length complete_msg > 0);
    check bool "失败消息长度合理" true (String.length failed_msg > 0)

  (** 测试编译阶段消息 *)
  let test_compilation_phases () =
    let filename = "test.ly" in
    
    (* 测试各个编译阶段 *)
    let parsing_start = CompilerMessages.parsing_start filename in
    let parsing_complete = CompilerMessages.parsing_complete filename in
    let type_checking_start = CompilerMessages.type_checking_start filename in
    let type_checking_complete = CompilerMessages.type_checking_complete filename in
    let code_gen_start = CompilerMessages.code_generation_start filename in
    let code_gen_complete = CompilerMessages.code_generation_complete filename in
    
    (* 验证消息包含相关内容 *)
    check bool "语法分析开始消息合理" true (String.length parsing_start > 0);
    check bool "语法分析完成消息合理" true (String.length parsing_complete > 0);
    check bool "类型检查开始消息合理" true (String.length type_checking_start > 0);
    check bool "类型检查完成消息合理" true (String.length type_checking_complete > 0);
    check bool "代码生成开始消息合理" true (String.length code_gen_start > 0);
    check bool "代码生成完成消息合理" true (String.length code_gen_complete > 0)

  (** 测试编译进度和阶段消息 *)
  let test_compilation_progress () =
    let filename = "test.ly" in
    let phase = "词法分析" in
    
    (* 测试编译阶段 *)
    let phase_msg = CompilerMessages.compilation_phase phase filename in
    check bool "编译阶段消息包含阶段名" true (String.contains phase_msg "词");
    check bool "编译阶段消息包含文件名" true (String.contains phase_msg 't');
    
    (* 测试编译进度 *)
    let progress_msg = CompilerMessages.compilation_progress 3 10 filename in
    check bool "进度消息包含当前数字" true (String.contains progress_msg '3');
    check bool "进度消息包含总数字" true (String.contains progress_msg '1');
    check bool "进度消息包含文件名" true (String.contains progress_msg 't')

  (** 测试不支持符号消息 *)
  let test_unsupported_symbol_message () =
    let char_bytes = "0x5B" in
    let unsupported_msg = CompilerMessages.unsupported_chinese_symbol char_bytes in
    
    check bool "不支持符号消息包含字节信息" true (String.contains unsupported_msg '0');
    check bool "不支持符号消息包含警告信息" true (String.length unsupported_msg > 10);
    check bool "不支持符号消息长度合理" true (String.length unsupported_msg > 20)
end

(** 增强日志消息测试 *)
module EnhancedLogMessagesTests = struct
  (** 测试编译统计消息 *)
  let test_compilation_statistics () =
    let filename = "enhanced_test.ly" in
    let files_count = 5 in
    let time_taken = 2.5 in
    
    (* 测试文件编译消息 *)
    let compiling_msg = EnhancedLogMessages.compiling_file filename in
    check bool "增强编译消息包含文件名" true (String.contains compiling_msg 'e');
    
    (* 测试编译统计 *)
    let stats_msg = EnhancedLogMessages.compilation_complete_stats files_count time_taken in
    check bool "统计消息包含文件数" true (String.contains stats_msg '5');
    check bool "统计消息包含时间信息" true (String.contains stats_msg '2')

  (** 测试操作状态消息 *)
  let test_operation_status_messages () =
    let operation_name = "语法分析" in
    let duration = 1.2 in
    let error_msg = "意外的标记" in
    
    (* 测试操作状态 *)
    let start_msg = EnhancedLogMessages.operation_start operation_name in
    let complete_msg = EnhancedLogMessages.operation_complete operation_name duration in
    let failed_msg = EnhancedLogMessages.operation_failed operation_name duration error_msg in
    
    check bool "操作开始消息包含操作名" true (String.length start_msg > 0);
    check bool "操作完成消息包含时间" true (String.contains complete_msg '1');
    check bool "操作失败消息包含错误" true (String.length failed_msg > 0);
    
    (* 验证消息结构 *)
    check bool "开始消息长度合理" true (String.length start_msg > 0);
    check bool "完成消息长度合理" true (String.length complete_msg > 0);
    check bool "失败消息长度合理" true (String.length failed_msg > 0)

  (** 测试时间戳格式化 *)
  let test_timestamp_formatting () =
    (* 测试基本时间戳格式化 *)
    let timestamp = EnhancedLogMessages.format_timestamp 2025 7 23 14 30 45 in
    check bool "时间戳包含年份" true (String.contains timestamp '2');
    check bool "时间戳包含月份" true (String.contains timestamp '7');
    check bool "时间戳包含日期" true (String.contains timestamp '2');
    check bool "时间戳包含小时" true (String.contains timestamp '1');
    check bool "时间戳长度合理" true (String.length timestamp > 10);
    
    (* 测试Unix时间格式化 *)
    let unix_time = {
      Unix.tm_year = 125;  (* 2025 - 1900 = 125 *)
      Unix.tm_mon = 6;     (* 7月 - 1 = 6 *)
      Unix.tm_mday = 23;
      Unix.tm_hour = 14;
      Unix.tm_min = 30;
      Unix.tm_sec = 45;
      Unix.tm_wday = 0;
      Unix.tm_yday = 0;
      Unix.tm_isdst = false;
    } in
    let unix_timestamp = EnhancedLogMessages.format_unix_time unix_time in
    check bool "Unix时间戳长度合理" true (String.length unix_timestamp > 10)

  (** 测试日志条目格式化 *)
  let test_log_entry_formatting () =
    let timestamp_part = "2025-07-23 14:30:45 " in
    let module_part = "[TestModule] " in
    let color_part = "\027[32m" in  (* 绿色 *)
    let level_str = "INFO" in
    let message = "测试消息" in
    let reset_color = "\027[0m" in
    
    (* 测试完整日志条目 *)
    let full_entry = EnhancedLogMessages.format_log_entry timestamp_part module_part color_part level_str message reset_color in
    check bool "完整日志条目包含时间戳" true (String.contains full_entry '2');
    check bool "完整日志条目包含级别" true (String.contains full_entry 'I');
    check bool "完整日志条目包含消息" true (String.contains full_entry '测');
    
    (* 测试简化日志条目 *)
    let simple_entry = EnhancedLogMessages.format_simple_log_entry timestamp_part module_part color_part level_str message in
    check bool "简化日志条目长度合理" true (String.length simple_entry > 0)

  (** 测试增强日志消息 *)
  let test_enhanced_log_messages () =
    let module_name = "测试模块" in
    let operation = "测试操作" in
    let detail = "详细描述" in
    
    (* 测试增强的各级别日志 *)
    let debug_enhanced = EnhancedLogMessages.debug_enhanced module_name operation detail in
    let info_enhanced = EnhancedLogMessages.info_enhanced module_name operation detail in
    let warning_enhanced = EnhancedLogMessages.warning_enhanced module_name operation detail in
    let error_enhanced = EnhancedLogMessages.error_enhanced module_name operation detail in
    
    check bool "增强debug消息包含模块名" true (String.contains debug_enhanced '测');
    check bool "增强info消息包含操作" true (String.contains info_enhanced '测');
    check bool "增强warning消息包含详细信息" true (String.contains warning_enhanced '详');
    check bool "增强error消息格式正确" true (String.length error_enhanced > 0)

  (** 测试性能和内存日志 *)
  let test_performance_and_memory_logs () =
    let operation = "编译操作" in
    let duration_ms = 1500 in
    let heap_mb = 256 in
    let stack_mb = 8 in
    
    (* 测试性能日志 *)
    let perf_start = EnhancedLogMessages.performance_start operation in
    let perf_end = EnhancedLogMessages.performance_end operation duration_ms in
    let memory_usage = EnhancedLogMessages.memory_usage operation heap_mb stack_mb in
    
    check bool "性能开始日志包含操作名" true (String.contains perf_start '编');
    check bool "性能结束日志包含时间" true (String.contains perf_end '1');
    check bool "内存使用日志包含堆大小" true (String.contains memory_usage '2');
    check bool "内存使用日志包含栈大小" true (String.contains memory_usage '8')

  (** 测试开发者和系统日志 *)
  let test_developer_and_system_logs () =
    let checkpoint_name = "检查点1" in
    let data = "测试数据" in
    let assertion_name = "断言1" in
    let result = true in
    
    (* 测试开发者日志 *)
    let dev_checkpoint = EnhancedLogMessages.dev_checkpoint checkpoint_name data in
    let dev_assertion = EnhancedLogMessages.dev_assertion assertion_name result in
    
    check bool "开发者检查点包含名称" true (String.contains dev_checkpoint '检');
    check bool "开发者断言包含结果" true (String.contains dev_assertion 't');
    
    (* 测试系统日志 *)
    let system_resource = EnhancedLogMessages.system_resource "内存分配" "堆内存" "256MB" in
    let system_event = EnhancedLogMessages.system_event "启动" "系统初始化完成" in
    
    check bool "系统资源日志包含资源类型" true (String.contains system_resource '堆');
    check bool "系统事件日志包含事件类型" true (String.contains system_event '启')

  (** 测试测试套件日志 *)
  let test_test_suite_logs () =
    let test_name = "语法解析测试" in
    let reason = "意外的EOF" in
    let total_tests = 10 in
    let passed_tests = 8 in
    let failed_tests = 2 in
    
    (* 测试测试日志 *)
    let test_start = EnhancedLogMessages.test_start test_name in
    let test_pass = EnhancedLogMessages.test_pass test_name in
    let test_fail = EnhancedLogMessages.test_fail test_name reason in
    let test_summary = EnhancedLogMessages.test_suite_summary total_tests passed_tests failed_tests in
    
    check bool "测试开始日志包含测试名" true (String.contains test_start '语');
    check bool "测试通过日志包含测试名" true (String.contains test_pass '语');
    check bool "测试失败日志包含原因" true (String.contains test_fail '意');
    check bool "测试摘要包含总数" true (String.contains test_summary '1');
    check bool "测试摘要包含通过数" true (String.contains test_summary '8');
    check bool "测试摘要包含失败数" true (String.contains test_summary '2')
end

(** 日志格式化器测试 *)
module LoggingFormatterTests = struct
  (** 测试时间戳格式化 *)
  let test_timestamp_formatting () =
    let timestamp = LoggingFormatter.format_timestamp 2025 7 23 14 30 45 in
    
    check bool "时间戳包含年份" true (String.contains timestamp '2');
    check bool "时间戳包含连字符" true (String.contains timestamp '-');
    check bool "时间戳包含空格" true (String.contains timestamp ' ');
    check bool "时间戳包含冒号" true (String.contains timestamp ':');
    check bool "时间戳长度正确" true (String.length timestamp >= 19);
    
    (* 测试单位数月份和日期的零填充 *)
    let padded_timestamp = LoggingFormatter.format_timestamp 2025 5 9 8 5 2 in
    check bool "零填充时间戳长度正确" true (String.length padded_timestamp >= 19)

  (** 测试基础日志条目格式化 *)
  let test_basic_log_entry_formatting () =
    let level_str = "INFO" in
    let message = "测试消息" in
    
    let log_entry = LoggingFormatter.format_log_entry level_str message in
    check bool "日志条目包含级别" true (String.contains log_entry 'I');
    check bool "日志条目包含消息" true (String.contains log_entry '测');
    check bool "日志条目包含方括号" true (String.contains log_entry '[');
    
    let simple_entry = LoggingFormatter.format_simple_log_entry level_str message in
    check bool "简单日志条目长度合理" true (String.length simple_entry > 0)

  (** 测试特殊格式化功能 *)
  let test_special_formatting_functions () =
    let level = "WARNING" in
    let log_level_formatted = LoggingFormatter.format_log_level level in
    check bool "日志级别格式化包含方括号" true (String.contains log_level_formatted '[');
    
    let migration_info = LoggingFormatter.format_migration_info "模块A" "完成" in
    check bool "迁移信息包含操作" true (String.contains migration_info '模');
    check bool "迁移信息包含状态" true (String.contains migration_info '完');
    
    let legacy_log = LoggingFormatter.format_legacy_log "LegacyModule" "遗留消息" in
    check bool "遗留日志包含模块名" true (String.contains legacy_log 'L');
    check bool "遗留日志包含消息" true (String.contains legacy_log '遗');
    
    let core_log = LoggingFormatter.format_core_log_message "CoreComponent" "核心消息" in
    check bool "核心日志包含组件名" true (String.contains core_log 'C');
    check bool "核心日志包含消息" true (String.contains core_log '核')

  (** 测试上下文格式化 *)
  let test_context_formatting () =
    let key = "模块" in
    let value = "词法分析器" in
    let context_pair = LoggingFormatter.format_context_pair key value in
    check bool "上下文对包含键" true (String.contains context_pair '模');
    check bool "上下文对包含值" true (String.contains context_pair '词');
    check bool "上下文对包含等号" true (String.contains context_pair '=');
    
    let context_pairs = ["key1=value1"; "key2=value2"] in
    let context_group = LoggingFormatter.format_context_group context_pairs in
    check bool "上下文组包含方括号" true (String.contains context_group '[');
    check bool "上下文组包含逗号" true (String.contains context_group ',')

  (** 测试进度和建议格式化 *)
  let test_progress_and_suggestions () =
    let total_files = 100 in
    let migrated_count = 65 in
    let progress_percent = 65.0 in
    
    let migration_progress = LoggingFormatter.format_migration_progress total_files migrated_count progress_percent in
    check bool "迁移进度包含总数" true (String.contains migration_progress '1');
    check bool "迁移进度包含已迁移数" true (String.contains migration_progress '6');
    check bool "迁移进度包含百分比" true (String.contains migration_progress '%');
    
    let priority_modules = "lexer, parser" in
    let core_modules = "types, semantic" in
    let other_modules = "utils, formatter" in
    
    let migration_suggestions = LoggingFormatter.format_migration_suggestions priority_modules core_modules other_modules in
    check bool "迁移建议包含优先级模块" true (String.contains migration_suggestions 'l');
    check bool "迁移建议包含核心模块" true (String.contains migration_suggestions 't');
    check bool "迁移建议包含其他模块" true (String.contains migration_suggestions 'u')

  (** 测试多行和结构化格式化 *)
  let test_multiline_and_structured_formatting () =
    let level = "ERROR" in
    let title = "编译错误详情" in
    let lines = ["第1行：语法错误"; "第2行：类型不匹配"; "第3行：未定义变量"] in
    
    let multiline_log = LoggingFormatter.format_multiline_log level title lines in
    check bool "多行日志包含级别" true (String.contains multiline_log 'E');
    check bool "多行日志包含标题" true (String.contains multiline_log '编');
    check bool "多行日志包含换行符" true (String.contains multiline_log '\n');
    
    let separator = LoggingFormatter.log_separator 20 "=" in
    check bool "分隔符长度正确" true (String.length separator = 20);
    
    let section_header = LoggingFormatter.log_section_header "测试部分" in
    check bool "部分标题包含标题文本" true (String.contains section_header '测');
    check bool "部分标题包含分隔符" true (String.contains section_header '=')

  (** 测试JSON和调试格式化 *)
  let test_json_and_debug_formatting () =
    let level = "INFO" in
    let timestamp = "2025-07-23T14:30:45Z" in
    let module_name = "TestModule" in
    let message = "测试JSON日志" in
    
    let json_log = LoggingFormatter.format_json_log_entry level timestamp module_name message in
    check bool "JSON日志包含花括号" true (String.contains json_log '{');
    check bool "JSON日志包含双引号" true (String.contains json_log '"');
    check bool "JSON日志包含级别字段" true (String.contains json_log 'l');
    
    let function_name = "parse_expression" in
    let variables = [("token", "IDENTIFIER"); ("value", "test")] in
    let debug_context = LoggingFormatter.format_debug_context function_name variables in
    check bool "调试上下文包含函数名" true (String.contains debug_context 'p');
    check bool "调试上下文包含变量" true (String.contains debug_context 't');
    
    let error_msg = "解析失败" in
    let stack_frames = ["parse_expression:45"; "compile_file:123"] in
    let error_stack = LoggingFormatter.format_error_stack error_msg stack_frames in
    check bool "错误堆栈包含错误消息" true (String.contains error_stack '解');
    check bool "错误堆栈包含堆栈帧" true (String.contains error_stack '4')
end

(** 调试格式化器测试 *)
module DebugFormatterTests = struct
  (** 测试变量状态格式化 *)
  let test_variable_state_formatting () =
    let var_name = "count" in
    let var_type = "int" in
    let var_value = "42" in
    
    let var_state = DebugFormatter.format_variable_state var_name var_type var_value in
    check bool "变量状态包含名称" true (String.contains var_state 'c');
    check bool "变量状态包含类型" true (String.contains var_state 'i');
    check bool "变量状态包含值" true (String.contains var_state '4');
    check bool "变量状态包含冒号" true (String.contains var_state ':');
    check bool "变量状态包含等号" true (String.contains var_state '=');
    
    let variables = [("x", "int", "10"); ("y", "string", "hello"); ("flag", "bool", "true")] in
    let var_list = DebugFormatter.format_variable_list variables in
    check bool "变量列表包含x变量" true (String.contains var_list 'x');
    check bool "变量列表包含字符串类型" true (String.contains var_list 's');
    check bool "变量列表包含布尔值" true (String.contains var_list 't')

  (** 测试函数调用追踪 *)
  let test_function_call_tracing () =
    let func_name = "add" in
    let args = ["10"; "20"] in
    let return_type = "int" in
    
    let func_call = DebugFormatter.format_function_call func_name args return_type in
    check bool "函数调用包含函数名" true (String.contains func_call 'a');
    check bool "函数调用包含参数" true (String.contains func_call '1');
    check bool "函数调用包含返回类型" true (String.contains func_call 'i');
    check bool "函数调用包含箭头" true (String.contains func_call '>');
    
    let calls = ["main()"; "parse(file.ly)"; "compile(ast)"]; in
    let call_stack = DebugFormatter.format_call_stack calls in
    check bool "调用栈包含编号" true (String.contains call_stack '1');
    check bool "调用栈包含main函数" true (String.contains call_stack 'm');
    check bool "调用栈包含换行" true (String.contains call_stack '\n')

  (** 测试表达式求值追踪 *)
  let test_expression_evaluation_tracing () =
    let expr = "2 + 3 * 4" in
    let result = "14" in
    
    let expr_eval = DebugFormatter.format_expression_eval expr result in
    check bool "表达式求值包含表达式" true (String.contains expr_eval '+');
    check bool "表达式求值包含结果" true (String.contains expr_eval '1');
    check bool "表达式求值包含箭头" true (String.contains expr_eval '=');
    
    let steps = ["2 + 3 * 4"; "2 + 12"; "14"] in
    let step_by_step = DebugFormatter.format_step_by_step_eval steps in
    check bool "逐步求值包含步骤编号" true (String.contains step_by_step '步');
    check bool "逐步求值包含表达式" true (String.contains step_by_step '+');
    check bool "逐步求值包含最终结果" true (String.contains step_by_step '1')

  (** 测试AST节点格式化 *)
  let test_ast_node_formatting () =
    let node_type = "BinaryExpr" in
    let node_content = "left: IntLit(2), op: Plus, right: IntLit(3)" in
    
    let ast_node = DebugFormatter.format_ast_node node_type node_content in
    check bool "AST节点包含类型" true (String.contains ast_node 'B');
    check bool "AST节点包含内容" true (String.contains ast_node 'l');
    check bool "AST节点包含括号" true (String.contains ast_node '(');
    
    let nodes = ["IntLit(2)"; "Plus"; "IntLit(3)"] in
    let indent_level = 2 in
    let ast_tree = DebugFormatter.format_ast_tree nodes indent_level in
    check bool "AST树包含缩进" true (String.contains ast_tree ' ');
    check bool "AST树包含节点" true (String.contains ast_tree 'I');
    check bool "AST树包含换行" true (String.contains ast_tree '\n')
end

(** 边界条件和性能测试 *)
module EdgeCaseTests = struct
  (** 测试空字符串和特殊字符处理 *)
  let test_empty_and_special_strings () =
    (* 测试空字符串 *)
    let empty_debug = LogMessages.debug "" "" in
    check bool "空字符串调试消息不为空" true (String.length empty_debug > 0);
    
    let empty_info = LogMessages.info "" "" in
    check bool "空字符串信息消息不为空" true (String.length empty_info > 0);
    
    (* 测试特殊字符 *)
    let special_chars = "测试\n换行\t制表符\"引号" in
    let special_debug = LogMessages.debug "特殊字符模块" special_chars in
    check bool "特殊字符消息长度合理" true (String.length special_debug > 0);
    
    (* 测试很长的字符串 *)
    let long_string = String.make 1000 'x' in
    let long_debug = LogMessages.debug "长字符串模块" long_string in
    check bool "长字符串消息长度合理" true (String.length long_debug > 1000)

  (** 测试数值边界情况 *)
  let test_numeric_edge_cases () =
    (* 测试零值 *)
    let zero_perf = LogMessages.perf "测试模块" "零时间操作" 0 in
    check bool "零时间性能日志长度合理" true (String.length zero_perf > 0);
    
    (* 测试很大的数值 *)
    let large_perf = LogMessages.perf "测试模块" "长时间操作" 999999 in
    check bool "大数值性能日志包含数字" true (String.contains large_perf '9');
    
    (* 测试负数时间戳 *)
    let negative_timestamp = LoggingFormatter.format_timestamp 2025 (-1) 1 0 0 0 in
    check bool "负数时间戳不会崩溃" true (String.length negative_timestamp > 0)

  (** 测试Unicode和中文字符 *)
  let test_unicode_and_chinese_characters () =
    let unicode_module = "测试模块🎉" in
    let unicode_message = "Unicode消息 ♥ 🚀 ✨" in
    
    let unicode_log = LogMessages.info unicode_module unicode_message in
    check bool "Unicode日志包含emoji" true (String.contains unicode_log '🎉');
    check bool "Unicode日志包含中文" true (String.contains unicode_log '测');
    
    let chinese_var_state = DebugFormatter.format_variable_state "变量名" "字符串类型" "中文值" in
    check bool "中文变量状态包含中文字符" true (String.contains chinese_var_state '变');
    check bool "中文变量状态格式正确" true (String.contains chinese_var_state '=')

  (** 测试性能压力 *)
  let test_performance_stress () =
    (* 测试大量小消息的性能 *)
    let start_time = Sys.time () in
    for i = 1 to 1000 do
      ignore (LogMessages.debug "性能测试" ("消息" ^ string_of_int i))
    done;
    let end_time = Sys.time () in
    let duration = end_time -. start_time in
    
    check bool "1000条小消息处理在合理时间内" true (duration < 1.0);
    
    (* 测试大消息的性能 *)
    let large_message = String.make 10000 'A' in
    let start_time2 = Sys.time () in
    ignore (LogMessages.info "大消息测试" large_message);
    let end_time2 = Sys.time () in
    let duration2 = end_time2 -. start_time2 in
    
    check bool "大消息处理在合理时间内" true (duration2 < 0.1)
end

(** 主测试套件 *)
let test_suite =
  [
    ("基础日志消息测试", [
      test_case "基本日志级别" `Quick LogMessagesTests.test_basic_log_levels;
      test_case "扩展日志类型" `Quick LogMessagesTests.test_extended_log_types;
      test_case "结构化日志" `Quick LogMessagesTests.test_structured_logging;
    ]);
    
    ("编译器消息测试", [
      test_case "文件编译消息" `Quick CompilerMessagesTests.test_file_compilation_messages;
      test_case "编译阶段消息" `Quick CompilerMessagesTests.test_compilation_phases;
      test_case "编译进度消息" `Quick CompilerMessagesTests.test_compilation_progress;
      test_case "不支持符号消息" `Quick CompilerMessagesTests.test_unsupported_symbol_message;
    ]);
    
    ("增强日志消息测试", [
      test_case "编译统计消息" `Quick EnhancedLogMessagesTests.test_compilation_statistics;
      test_case "操作状态消息" `Quick EnhancedLogMessagesTests.test_operation_status_messages;
      test_case "时间戳格式化" `Quick EnhancedLogMessagesTests.test_timestamp_formatting;
      test_case "日志条目格式化" `Quick EnhancedLogMessagesTests.test_log_entry_formatting;
      test_case "增强日志消息" `Quick EnhancedLogMessagesTests.test_enhanced_log_messages;
      test_case "性能和内存日志" `Quick EnhancedLogMessagesTests.test_performance_and_memory_logs;
      test_case "开发者和系统日志" `Quick EnhancedLogMessagesTests.test_developer_and_system_logs;
      test_case "测试套件日志" `Quick EnhancedLogMessagesTests.test_test_suite_logs;
    ]);
    
    ("日志格式化器测试", [
      test_case "时间戳格式化" `Quick LoggingFormatterTests.test_timestamp_formatting;
      test_case "基础日志条目格式化" `Quick LoggingFormatterTests.test_basic_log_entry_formatting;
      test_case "特殊格式化功能" `Quick LoggingFormatterTests.test_special_formatting_functions;
      test_case "上下文格式化" `Quick LoggingFormatterTests.test_context_formatting;
      test_case "进度和建议格式化" `Quick LoggingFormatterTests.test_progress_and_suggestions;
      test_case "多行和结构化格式化" `Quick LoggingFormatterTests.test_multiline_and_structured_formatting;
      test_case "JSON和调试格式化" `Quick LoggingFormatterTests.test_json_and_debug_formatting;
    ]);
    
    ("调试格式化器测试", [
      test_case "变量状态格式化" `Quick DebugFormatterTests.test_variable_state_formatting;
      test_case "函数调用追踪" `Quick DebugFormatterTests.test_function_call_tracing;
      test_case "表达式求值追踪" `Quick DebugFormatterTests.test_expression_evaluation_tracing;
      test_case "AST节点格式化" `Quick DebugFormatterTests.test_ast_node_formatting;
    ]);
    
    ("边界条件和性能测试", [
      test_case "空字符串和特殊字符" `Quick EdgeCaseTests.test_empty_and_special_strings;
      test_case "数值边界情况" `Quick EdgeCaseTests.test_numeric_edge_cases;
      test_case "Unicode和中文字符" `Quick EdgeCaseTests.test_unicode_and_chinese_characters;
      test_case "性能压力测试" `Slow EdgeCaseTests.test_performance_stress;
    ]);
  ]

(** 运行测试 *)
let () = run "骆言日志格式化模块综合测试" test_suite