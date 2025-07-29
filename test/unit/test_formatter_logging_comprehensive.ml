(** 骆言编译器日志格式化模块全面测试 - Stage 2.2: Specialized formatter tests
    
    本测试文件针对formatter_logging.ml提供全面的测试覆盖率，特别关注：
    - LogMessages模块的完整测试
    - CompilerMessages模块的测试
    - EnhancedLogMessages模块的测试
    - LoggingFormatter模块的测试
    - DebugFormatter模块的测试
    
    Author: Alpha, 主工作代理
    Fix #1692 - 测试覆盖率提升计划第二阶段
    @since 2025-07-29 *)

open Alcotest
open Yyocamlc_lib.Formatter_logging

(** 帮助函数：检查字符串是否包含子字符串 *)
let contains_substring s sub =
  try
    let _ = Str.search_forward (Str.regexp_string sub) s 0 in
    true
  with Not_found -> false


(** 测试LogMessages模块 *)
module Test_LogMessages = struct
  (** 测试基础日志级别 *)
  let test_basic_log_levels () =
    let debug_msg = LogMessages.debug "Parser" "解析开始" in
    check bool "调试消息包含DEBUG标识" true (contains_substring debug_msg "[DEBUG]");
    check bool "调试消息包含模块名" true (contains_substring debug_msg "Parser");
    check bool "调试消息包含消息内容" true (contains_substring debug_msg "解析开始");
    
    let info_msg = LogMessages.info "Compiler" "编译进度50%" in
    check bool "信息消息包含INFO标识" true (contains_substring info_msg "[INFO]");
    check bool "信息消息包含模块名" true (contains_substring info_msg "Compiler");
    check bool "信息消息包含消息内容" true (contains_substring info_msg "编译进度50%");
    
    let warning_msg = LogMessages.warning "TypeChecker" "类型推断失败" in
    check bool "警告消息包含WARNING标识" true (contains_substring warning_msg "[WARNING]");
    check bool "警告消息包含模块名" true (contains_substring warning_msg "TypeChecker");
    check bool "警告消息包含消息内容" true (contains_substring warning_msg "类型推断失败");
    
    let error_msg = LogMessages.error "CodeGen" "无效的操作码" in
    check bool "错误消息包含ERROR标识" true (contains_substring error_msg "[ERROR]");
    check bool "错误消息包含模块名" true (contains_substring error_msg "CodeGen");
    check bool "错误消息包含消息内容" true (contains_substring error_msg "无效的操作码");
    
    let trace_msg = LogMessages.trace "calculate" "计算表达式值" in
    check bool "追踪消息包含TRACE标识" true (contains_substring trace_msg "[TRACE]");
    check bool "追踪消息包含函数名" true (contains_substring trace_msg "calculate");
    check bool "追踪消息包含消息内容" true (contains_substring trace_msg "计算表达式值")

  (** 测试扩展日志类型 *)
  let test_extended_log_types () =
    let verbose_msg = LogMessages.verbose "Lexer" "Token详细信息" in
    check bool "详细消息包含VERBOSE标识" true (contains_substring verbose_msg "[VERBOSE]");
    check bool "详细消息包含模块名" true (contains_substring verbose_msg "Lexer");
    check bool "详细消息包含消息内容" true (contains_substring verbose_msg "Token详细信息");
    
    let fatal_msg = LogMessages.fatal "System" "内存不足" in
    check bool "致命消息包含FATAL标识" true (contains_substring fatal_msg "[FATAL]");
    check bool "致命消息包含模块名" true (contains_substring fatal_msg "System");
    check bool "致命消息包含消息内容" true (contains_substring fatal_msg "内存不足");
    
    let perf_msg = LogMessages.perf "Optimizer" "死代码消除" 150 in
    check bool "性能消息包含PERF标识" true (contains_substring perf_msg "[PERF]");
    check bool "性能消息包含模块名" true (contains_substring perf_msg "Optimizer");
    check bool "性能消息包含操作名" true (contains_substring perf_msg "死代码消除");
    check bool "性能消息包含耗时" true (contains_substring perf_msg "150ms")

  (** 测试结构化日志 *)
  let test_structured_log () =
    let structured = LogMessages.structured_log "INFO" "Database" "连接" "连接成功" in
    check bool "结构化日志包含级别" true (contains_substring structured "[INFO]");
    check bool "结构化日志包含模块名" true (contains_substring structured "Database");
    check bool "结构化日志包含操作名" true (contains_substring structured "连接");
    check bool "结构化日志包含详情" true (contains_substring structured "连接成功");
    check bool "结构化日志包含分隔符" true (contains_substring structured "::");
    
    let no_details = LogMessages.structured_log "ERROR" "Network" "请求" "" in
    check bool "无详情结构化日志包含模块名" true (contains_substring no_details "Network");
    check bool "无详情结构化日志包含操作名" true (contains_substring no_details "请求");
    check bool "无详情结构化日志不包含短横线" false (contains_substring no_details " - ")
end

(** 测试CompilerMessages模块 *)
module Test_CompilerMessages = struct
  (** 测试基础编译消息 *)
  let test_basic_compiler_messages () =
    let compiling = CompilerMessages.compiling_file "main.ml" in
    check bool "编译文件消息包含文件名" true (contains_substring compiling "main.ml");
    check bool "编译文件消息包含正在编译" true (contains_substring compiling "正在编译");
    
    let complete = CompilerMessages.compilation_complete "output.c" in
    check bool "编译完成消息包含文件名" true (contains_substring complete "output.c");
    check bool "编译完成消息包含完成标识" true (contains_substring complete "编译完成");
    
    let failed = CompilerMessages.compilation_failed "error.ml" "语法错误" in
    check bool "编译失败消息包含文件名" true (contains_substring failed "error.ml");
    check bool "编译失败消息包含错误信息" true (contains_substring failed "语法错误");
    check bool "编译失败消息包含失败标识" true (contains_substring failed "编译失败")

  (** 测试符号禁用消息 *)
  let test_unsupported_symbol_message () =
    let symbol_msg = CompilerMessages.unsupported_chinese_symbol "§" in
    check bool "符号禁用消息包含符号" true (contains_substring symbol_msg "§");
    check bool "符号禁用消息包含禁用标识" true (contains_substring symbol_msg "禁用");
    check bool "符号禁用消息包含支持的符号示例" true (contains_substring symbol_msg "「」");
    check bool "符号禁用消息包含非支持标识" true (contains_substring symbol_msg "非支持")

  (** 测试扩展编译状态 *)
  let test_extended_compilation_status () =
    let parsing_start = CompilerMessages.parsing_start "source.ml" in
    check bool "解析开始消息包含文件名" true (contains_substring parsing_start "source.ml");
    check bool "解析开始消息包含解析标识" true (contains_substring parsing_start "语法分析");
    
    let parsing_complete = CompilerMessages.parsing_complete "parsed.ml" in
    check bool "解析完成消息包含完成标识" true (contains_substring parsing_complete "完成");
    
    let type_check_start = CompilerMessages.type_checking_start "types.ml" in
    check bool "类型检查开始消息包含类型检查标识" true (contains_substring type_check_start "类型检查");
    
    let type_check_complete = CompilerMessages.type_checking_complete "checked.ml" in
    check bool "类型检查完成消息包含完成标识" true (contains_substring type_check_complete "完成");
    
    let codegen_start = CompilerMessages.code_generation_start "generate.ml" in
    check bool "代码生成开始消息包含代码生成标识" true (contains_substring codegen_start "代码生成");
    
    let codegen_complete = CompilerMessages.code_generation_complete "generated.c" in
    check bool "代码生成完成消息包含完成标识" true (contains_substring codegen_complete "完成")

  (** 测试编译阶段和进度 *)
  let test_compilation_phase_and_progress () =
    let phase = CompilerMessages.compilation_phase "优化" "optimize.ml" in
    check bool "编译阶段消息包含阶段名" true (contains_substring phase "优化");
    check bool "编译阶段消息包含文件名" true (contains_substring phase "optimize.ml");
    check bool "编译阶段消息包含阶段标识" true (contains_substring phase "编译阶段");
    
    let progress = CompilerMessages.compilation_progress 3 10 "progress.ml" in
    check bool "编译进度消息包含当前数" true (contains_substring progress "3");
    check bool "编译进度消息包含总数" true (contains_substring progress "10");
    check bool "编译进度消息包含文件名" true (contains_substring progress "progress.ml");
    check bool "编译进度消息包含进度标识" true (contains_substring progress "编译进度");
    check bool "编译进度消息包含方括号格式" true (contains_substring progress "[3/10]")
end

(** 测试EnhancedLogMessages模块 *)
module Test_EnhancedLogMessages = struct
  (** 测试增强编译状态消息 *)
  let test_enhanced_compilation_messages () =
    let compiling = EnhancedLogMessages.compiling_file "enhanced.ml" in
    check bool "增强编译消息包含文件名" true (contains_substring compiling "enhanced.ml");
    check bool "增强编译消息包含正在编译" true (contains_substring compiling "正在编译");
    
    let complete_stats = EnhancedLogMessages.compilation_complete_stats 5 12.5 in
    check bool "编译完成统计包含文件数" true (contains_substring complete_stats "5");
    check bool "编译完成统计包含耗时" true (contains_substring complete_stats "12.5");
    check bool "编译完成统计包含秒单位" true (contains_substring complete_stats "秒")

  (** 测试操作状态消息 *)
  let test_operation_status_messages () =
    let op_start = EnhancedLogMessages.operation_start "类型推断" in
    check bool "操作开始消息包含操作名" true (contains_substring op_start "类型推断");
    check bool "操作开始消息包含开始标识" true (contains_substring op_start "开始");
    
    let op_complete = EnhancedLogMessages.operation_complete "语法分析" 2.3 in
    check bool "操作完成消息包含操作名" true (contains_substring op_complete "语法分析");
    check bool "操作完成消息包含完成标识" true (contains_substring op_complete "完成");
    check bool "操作完成消息包含耗时" true (contains_substring op_complete "2.3");
    check bool "操作完成消息包含耗时单位" true (contains_substring op_complete "秒");
    
    let op_failed = EnhancedLogMessages.operation_failed "代码生成" 1.8 "内存不足" in
    check bool "操作失败消息包含操作名" true (contains_substring op_failed "代码生成");
    check bool "操作失败消息包含失败标识" true (contains_substring op_failed "失败");
    check bool "操作失败消息包含耗时" true (contains_substring op_failed "1.8");
    check bool "操作失败消息包含错误信息" true (contains_substring op_failed "内存不足")

  (** 测试时间戳格式化 *)
  let test_timestamp_formatting () =
    let timestamp = EnhancedLogMessages.format_timestamp 2025 7 29 14 30 45 in
    check bool "时间戳包含年份" true (contains_substring timestamp "2025");
    check bool "时间戳包含月份" true (contains_substring timestamp "07");
    check bool "时间戳包含日期" true (contains_substring timestamp "29");
    check bool "时间戳包含小时" true (contains_substring timestamp "14");
    check bool "时间戳包含分钟" true (contains_substring timestamp "30");
    check bool "时间戳包含秒" true (contains_substring timestamp "45");
    check bool "时间戳格式正确" true (contains_substring timestamp "2025-07-29 14:30:45");
    
    let single_digit = EnhancedLogMessages.format_timestamp 2025 1 5 8 9 3 in
    check bool "单位数时间戳包含前导零" true (contains_substring single_digit "01");
    check bool "单位数时间戳包含前导零日期" true (contains_substring single_digit "05");
    check bool "单位数时间戳包含前导零小时" true (contains_substring single_digit "08");
    check bool "单位数时间戳包含前导零分钟" true (contains_substring single_digit "09");
    check bool "单位数时间戳包含前导零秒" true (contains_substring single_digit "03")

  (** 测试日志条目格式化 *)
  let test_log_entry_formatting () =
    let log_entry = EnhancedLogMessages.format_log_entry "2025-07-29 14:30:45" "[Parser]" "\027[32m" "INFO" "解析成功" "\027[0m" in
    check bool "日志条目包含时间戳" true (contains_substring log_entry "2025-07-29");
    check bool "日志条目包含模块标识" true (contains_substring log_entry "[Parser]");
    check bool "日志条目包含级别" true (contains_substring log_entry "[INFO]");
    check bool "日志条目包含消息" true (contains_substring log_entry "解析成功");
    
    let simple_entry = EnhancedLogMessages.format_simple_log_entry "14:30:45" "[Lexer]" "" "DEBUG" "Token生成" in
    check bool "简单日志条目包含时间" true (contains_substring simple_entry "14:30:45");
    check bool "简单日志条目包含模块" true (contains_substring simple_entry "[Lexer]");
    check bool "简单日志条目包含级别" true (contains_substring simple_entry "DEBUG")

  (** 测试增强日志消息 *)
  let test_enhanced_log_messages () =
    let debug_enhanced = EnhancedLogMessages.debug_enhanced "Compiler" "编译" "开始编译main.ml" in
    check bool "增强调试消息包含DEBUG标识" true (contains_substring debug_enhanced "[DEBUG]");
    check bool "增强调试消息包含模块名" true (contains_substring debug_enhanced "Compiler");
    check bool "增强调试消息包含操作" true (contains_substring debug_enhanced "编译");
    check bool "增强调试消息包含详情" true (contains_substring debug_enhanced "开始编译main.ml");
    
    let info_enhanced = EnhancedLogMessages.info_enhanced "Parser" "解析" "语法树构建完成" in
    check bool "增强信息消息包含INFO标识" true (contains_substring info_enhanced "[INFO]");
    check bool "增强信息消息包含模块名" true (contains_substring info_enhanced "Parser");
    
    let warning_enhanced = EnhancedLogMessages.warning_enhanced "TypeChecker" "检查" "类型不匹配警告" in
    check bool "增强警告消息包含WARNING标识" true (contains_substring warning_enhanced "[WARNING]");
    
    let error_enhanced = EnhancedLogMessages.error_enhanced "CodeGen" "生成" "无法生成目标代码" in
    check bool "增强错误消息包含ERROR标识" true (contains_substring error_enhanced "[ERROR]")

  (** 测试性能和内存日志 *)
  let test_performance_and_memory_logs () =
    let perf_start = EnhancedLogMessages.performance_start "编译优化" in
    check bool "性能开始消息包含PERF-START标识" true (contains_substring perf_start "[PERF-START]");
    check bool "性能开始消息包含操作名" true (contains_substring perf_start "编译优化");
    
    let perf_end = EnhancedLogMessages.performance_end "语法分析" 250 in
    check bool "性能结束消息包含PERF-END标识" true (contains_substring perf_end "[PERF-END]");
    check bool "性能结束消息包含操作名" true (contains_substring perf_end "语法分析");
    check bool "性能结束消息包含耗时" true (contains_substring perf_end "250ms");
    
    let memory_usage = EnhancedLogMessages.memory_usage "类型检查" 64 8 in
    check bool "内存使用消息包含MEMORY标识" true (contains_substring memory_usage "[MEMORY]");
    check bool "内存使用消息包含操作名" true (contains_substring memory_usage "类型检查");
    check bool "内存使用消息包含堆内存" true (contains_substring memory_usage "64MB");
    check bool "内存使用消息包含栈内存" true (contains_substring memory_usage "8MB")

  (** 测试开发者和系统日志 *)
  let test_developer_and_system_logs () =
    let dev_checkpoint = EnhancedLogMessages.dev_checkpoint "parser_init" "解析器初始化完成" in
    check bool "开发检查点包含DEV-CHECKPOINT标识" true (contains_substring dev_checkpoint "[DEV-CHECKPOINT]");
    check bool "开发检查点包含检查点名" true (contains_substring dev_checkpoint "parser_init");
    check bool "开发检查点包含数据" true (contains_substring dev_checkpoint "解析器初始化完成");
    
    let dev_assertion = EnhancedLogMessages.dev_assertion "is_valid_token" true in
    check bool "开发断言包含DEV-ASSERT标识" true (contains_substring dev_assertion "[DEV-ASSERT]");
    check bool "开发断言包含断言名" true (contains_substring dev_assertion "is_valid_token");
    check bool "开发断言包含结果" true (contains_substring dev_assertion "true");
    
    let system_resource = EnhancedLogMessages.system_resource "垃圾回收" "内存" "95% 使用率" in
    check bool "系统资源包含SYSTEM标识" true (contains_substring system_resource "[SYSTEM]");
    check bool "系统资源包含操作名" true (contains_substring system_resource "垃圾回收");
    check bool "系统资源包含资源类型" true (contains_substring system_resource "内存");
    check bool "系统资源包含使用情况" true (contains_substring system_resource "95% 使用率");
    
    let system_event = EnhancedLogMessages.system_event "编译器启动" "版本 1.0.0" in
    check bool "系统事件包含SYSTEM-EVENT标识" true (contains_substring system_event "[SYSTEM-EVENT]");
    check bool "系统事件包含事件类型" true (contains_substring system_event "编译器启动");
    check bool "系统事件包含详情" true (contains_substring system_event "版本 1.0.0")

  (** 测试测试日志 *)
  let test_test_logs () =
    let test_start = EnhancedLogMessages.test_start "test_parser" in
    check bool "测试开始包含TEST-START标识" true (contains_substring test_start "[TEST-START]");
    check bool "测试开始包含测试名" true (contains_substring test_start "test_parser");
    
    let test_pass = EnhancedLogMessages.test_pass "test_lexer" in
    check bool "测试通过包含TEST-PASS标识" true (contains_substring test_pass "[TEST-PASS]");
    check bool "测试通过包含测试名" true (contains_substring test_pass "test_lexer");
    
    let test_fail = EnhancedLogMessages.test_fail "test_codegen" "空指针异常" in
    check bool "测试失败包含TEST-FAIL标识" true (contains_substring test_fail "[TEST-FAIL]");
    check bool "测试失败包含测试名" true (contains_substring test_fail "test_codegen");
    check bool "测试失败包含原因" true (contains_substring test_fail "空指针异常");
    
    let test_summary = EnhancedLogMessages.test_suite_summary 50 45 5 in
    check bool "测试汇总包含TEST-SUMMARY标识" true (contains_substring test_summary "[TEST-SUMMARY]");
    check bool "测试汇总包含总计" true (contains_substring test_summary "总计: 50");
    check bool "测试汇总包含通过数" true (contains_substring test_summary "通过: 45");
    check bool "测试汇总包含失败数" true (contains_substring test_summary "失败: 5")
end

(** 测试LoggingFormatter模块 *)
module Test_LoggingFormatter = struct
  (** 测试时间戳格式化 *)
  let test_timestamp_formatting () =
    let timestamp = LoggingFormatter.format_timestamp 2025 7 29 14 30 45 in
    check bool "时间戳包含年份" true (contains_substring timestamp "2025");
    check bool "时间戳包含月份零填充" true (contains_substring timestamp "-07-");
    check bool "时间戳包含日期零填充" true (contains_substring timestamp "-29");
    check bool "时间戳包含小时零填充" true (contains_substring timestamp " 14:");
    check bool "时间戳包含分钟零填充" true (contains_substring timestamp ":30:");
    check bool "时间戳包含秒零填充" true (contains_substring timestamp ":45");
    
    let single_digits = LoggingFormatter.format_timestamp 2025 1 5 8 9 3 in
    check bool "单位数月份添加前导零" true (contains_substring single_digits "-01-");
    check bool "单位数日期添加前导零" true (contains_substring single_digits "-05");
    check bool "单位数小时添加前导零" true (contains_substring single_digits " 08:");
    check bool "单位数分钟添加前导零" true (contains_substring single_digits ":09:");
    check bool "单位数秒添加前导零" true (contains_substring single_digits ":03")

  (** 测试基础日志条目格式化 *)
  let test_basic_log_entry_formatting () =
    let log_entry = LoggingFormatter.format_log_entry "INFO" "系统启动成功" in
    check bool "日志条目包含级别" true (contains_substring log_entry "[INFO]");
    check bool "日志条目包含消息" true (contains_substring log_entry "系统启动成功");
    check bool "日志条目包含方括号" true (contains_substring log_entry "[INFO] ");
    
    let simple_entry = LoggingFormatter.format_simple_log_entry "ERROR" "连接失败" in
    check bool "简单日志条目包含级别" true (contains_substring simple_entry "[ERROR]");
    check bool "简单日志条目包含消息" true (contains_substring simple_entry "连接失败");
    
    let log_level = LoggingFormatter.format_log_level "DEBUG" in
    check string "日志级别格式化" "[DEBUG]" log_level

  (** 测试迁移信息格式化 *)
  let test_migration_formatting () =
    let migration_info = LoggingFormatter.format_migration_info "数据库升级" "完成" in
    check bool "迁移信息包含操作名" true (contains_substring migration_info "数据库升级");
    check bool "迁移信息包含状态" true (contains_substring migration_info "完成");
    check bool "迁移信息包含迁移标识" true (contains_substring migration_info "迁移");
    
    let legacy_log = LoggingFormatter.format_legacy_log "OldSystem" "兼容性检查" in
    check bool "传统日志包含LEGACY标识" true (contains_substring legacy_log "[LEGACY]");
    check bool "传统日志包含模块名" true (contains_substring legacy_log "OldSystem");
    check bool "传统日志包含消息" true (contains_substring legacy_log "兼容性检查");
    
    let core_log = LoggingFormatter.format_core_log_message "Engine" "核心初始化" in
    check bool "核心日志包含CORE标识" true (contains_substring core_log "[CORE]");
    check bool "核心日志包含组件名" true (contains_substring core_log "Engine");
    check bool "核心日志包含内容" true (contains_substring core_log "核心初始化")

  (** 测试上下文格式化 *)
  let test_context_formatting () =
    let context_pair = LoggingFormatter.format_context_pair "user_id" "12345" in
    check string "上下文键值对格式化" "user_id=12345" context_pair;
    
    let context_pairs = ["user_id=12345"; "session=abc123"; "ip=192.168.1.1"] in
    let context_group = LoggingFormatter.format_context_group context_pairs in
    check bool "上下文组包含方括号开始" true (contains_substring context_group " [");
    check bool "上下文组包含方括号结束" true (contains_substring context_group "]");
    check bool "上下文组包含用户ID" true (contains_substring context_group "user_id=12345");
    check bool "上下文组包含逗号分隔" true (contains_substring context_group ", ")

  (** 测试迁移进度和建议 *)
  let test_migration_progress_and_suggestions () =
    let progress = LoggingFormatter.format_migration_progress 20 15 75.0 in
    check bool "迁移进度包含总文件数" true (contains_substring progress "总文件数: 20");
    check bool "迁移进度包含已迁移数" true (contains_substring progress "已迁移: 15");
    check bool "迁移进度包含待迁移数" true (contains_substring progress "待迁移: 5");
    check bool "迁移进度包含进度百分比" true (contains_substring progress "进度: 75");
    
    let suggestions = LoggingFormatter.format_migration_suggestions "核心解析器" "类型系统" "工具模块" in
    check bool "迁移建议包含优先级模块" true (contains_substring suggestions "核心解析器");
    check bool "迁移建议包含核心模块" true (contains_substring suggestions "类型系统");
    check bool "迁移建议包含其他模块" true (contains_substring suggestions "工具模块");
    check bool "迁移建议包含建议顺序标题" true (contains_substring suggestions "建议迁移顺序")

  (** 测试多行日志和分隔符 *)
  let test_multiline_and_separators () =
    let lines = ["第一行详情"; "第二行详情"; "第三行详情"] in
    let multiline = LoggingFormatter.format_multiline_log "INFO" "详细报告" lines in
    check bool "多行日志包含级别" true (contains_substring multiline "[INFO]");
    check bool "多行日志包含标题" true (contains_substring multiline "详细报告");
    check bool "多行日志包含第一行" true (contains_substring multiline "第一行详情");
    check bool "多行日志包含缩进" true (contains_substring multiline "  第一行详情");
    
    let separator = LoggingFormatter.log_separator 10 "=" in
    check int "分隔符长度正确" 10 (String.length separator);
    check bool "分隔符字符正确" true (String.for_all (fun c -> c = '=') separator);
    
    let section_header = LoggingFormatter.log_section_header "系统启动" in
    check bool "段落标题包含标题文本" true (contains_substring section_header "系统启动");
    check bool "段落标题包含分隔符" true (contains_substring section_header "=")

  (** 测试JSON和调试格式化 *)
  let test_json_and_debug_formatting () =
    let json_log = LoggingFormatter.format_json_log_entry "INFO" "2025-07-29T14:30:45Z" "Parser" "解析完成" in
    check bool "JSON日志包含级别字段" true (contains_substring json_log "\"level\":\"INFO\"");
    check bool "JSON日志包含时间戳字段" true (contains_substring json_log "\"timestamp\":");
    check bool "JSON日志包含模块字段" true (contains_substring json_log "\"module\":\"Parser\"");
    check bool "JSON日志包含消息字段" true (contains_substring json_log "\"message\":\"解析完成\"");
    check bool "JSON日志格式正确" true (String.get json_log 0 = '{' && String.get json_log (String.length json_log - 1) = '}');
    
    let debug_context = LoggingFormatter.format_debug_context "parse_expression" [("token", "IDENTIFIER"); ("position", "line:5")] in
    check bool "调试上下文包含函数名" true (contains_substring debug_context "parse_expression");
    check bool "调试上下文包含DEBUG-CONTEXT标识" true (contains_substring debug_context "[DEBUG-CONTEXT]");
    check bool "调试上下文包含变量名" true (contains_substring debug_context "token=IDENTIFIER");
    check bool "调试上下文包含大括号" true (contains_substring debug_context "{");
    
    let error_stack = LoggingFormatter.format_error_stack "空指针异常" ["main.ml:42"; "parser.ml:158"; "lexer.ml:92"] in
    check bool "错误堆栈包含错误消息" true (contains_substring error_stack "空指针异常");
    check bool "错误堆栈包含ERROR标识" true (contains_substring error_stack "[ERROR]");
    check bool "错误堆栈包含第一帧" true (contains_substring error_stack "at main.ml:42");
    check bool "错误堆栈包含缩进" true (contains_substring error_stack "  at ")
end

(** 测试DebugFormatter模块 *)
module Test_DebugFormatter = struct
  (** 测试变量状态格式化 *)
  let test_variable_state_formatting () =
    let var_state = DebugFormatter.format_variable_state "counter" "int" "42" in
    check bool "变量状态包含变量名" true (contains_substring var_state "counter");
    check bool "变量状态包含类型" true (contains_substring var_state "int");
    check bool "变量状态包含值" true (contains_substring var_state "42");
    check bool "变量状态格式正确" true (contains_substring var_state "counter: int = 42");
    
    let variables = [("x", "int", "10"); ("y", "string", "hello"); ("z", "bool", "true")] in
    let var_list = DebugFormatter.format_variable_list variables in
    check bool "变量列表包含第一个变量" true (contains_substring var_list "x: int = 10");
    check bool "变量列表包含第二个变量" true (contains_substring var_list "y: string = hello");
    check bool "变量列表包含第三个变量" true (contains_substring var_list "z: bool = true")

  (** 测试函数调用追踪 *)
  let test_function_call_tracing () =
    let func_call = DebugFormatter.format_function_call "calculate" ["x"; "y"; "z"] "int" in
    check bool "函数调用包含函数名" true (contains_substring func_call "calculate");
    check bool "函数调用包含参数" true (contains_substring func_call "x, y, z");
    check bool "函数调用包含返回类型" true (contains_substring func_call "-> int");
    check bool "函数调用包含括号" true (contains_substring func_call "(");
    
    let calls = ["main() -> unit"; "parse(input) -> ast"; "compile(ast) -> code"] in
    let call_stack = DebugFormatter.format_call_stack calls in
    check bool "调用栈包含第一个调用" true (contains_substring call_stack "1. main() -> unit");
    check bool "调用栈包含第二个调用" true (contains_substring call_stack "2. parse(input) -> ast");
    check bool "调用栈包含第三个调用" true (contains_substring call_stack "3. compile(ast) -> code");
    check bool "调用栈包含编号" true (contains_substring call_stack "1. ")

  (** 测试表达式求值追踪 *)
  let test_expression_evaluation_tracing () =
    let expr_eval = DebugFormatter.format_expression_eval "x + y" "15" in
    check bool "表达式求值包含表达式" true (contains_substring expr_eval "x + y");
    check bool "表达式求值包含结果" true (contains_substring expr_eval "15");
    check bool "表达式求值包含箭头" true (contains_substring expr_eval "=>");
    
    let steps = ["x + y"; "10 + 5"; "15"] in
    let step_eval = DebugFormatter.format_step_by_step_eval steps in
    check bool "逐步求值包含第一步" true (contains_substring step_eval "步骤 1: x + y");
    check bool "逐步求值包含第二步" true (contains_substring step_eval "步骤 2: 10 + 5");
    check bool "逐步求值包含第三步" true (contains_substring step_eval "步骤 3: 15");
    check bool "逐步求值包含步骤编号" true (contains_substring step_eval "步骤 ")

  (** 测试AST节点格式化 *)
  let test_ast_node_formatting () =
    let ast_node = DebugFormatter.format_ast_node "BinaryOp" "Add(Var(x), Const(5))" in
    check bool "AST节点包含节点类型" true (contains_substring ast_node "BinaryOp");
    check bool "AST节点包含节点内容" true (contains_substring ast_node "Add(Var(x), Const(5))");
    check bool "AST节点包含括号" true (contains_substring ast_node "(");
    
    let nodes = ["Program"; "  Function(main)"; "    Block"; "      Return(0)"] in
    let ast_tree = DebugFormatter.format_ast_tree nodes 0 in
    check bool "AST树包含第一个节点" true (contains_substring ast_tree "Program");
    check bool "AST树包含缩进节点" true (contains_substring ast_tree "  Function(main)");
    
    let indented_nodes = ["If"; "Condition"; "ThenBranch"] in
    let indented_tree = DebugFormatter.format_ast_tree indented_nodes 2 in
    check bool "缩进AST树包含额外缩进" true (contains_substring indented_tree "    If");
    check bool "缩进AST树缩进正确" true (contains_substring indented_tree "    Condition")
end

let () =
  run "骆言日志格式化模块全面测试"
    [
      ( "日志消息基础",
        [
          test_case "基础日志级别" `Quick Test_LogMessages.test_basic_log_levels;
          test_case "扩展日志类型" `Quick Test_LogMessages.test_extended_log_types;
          test_case "结构化日志" `Quick Test_LogMessages.test_structured_log;
        ] );
      ( "编译器消息",
        [
          test_case "基础编译消息" `Quick Test_CompilerMessages.test_basic_compiler_messages;
          test_case "符号禁用消息" `Quick Test_CompilerMessages.test_unsupported_symbol_message;
          test_case "扩展编译状态" `Quick Test_CompilerMessages.test_extended_compilation_status;
          test_case "编译阶段和进度" `Quick Test_CompilerMessages.test_compilation_phase_and_progress;
        ] );
      ( "增强日志消息",
        [
          test_case "增强编译状态消息" `Quick Test_EnhancedLogMessages.test_enhanced_compilation_messages;
          test_case "操作状态消息" `Quick Test_EnhancedLogMessages.test_operation_status_messages;
          test_case "时间戳格式化" `Quick Test_EnhancedLogMessages.test_timestamp_formatting;
          test_case "日志条目格式化" `Quick Test_EnhancedLogMessages.test_log_entry_formatting;
          test_case "增强日志消息" `Quick Test_EnhancedLogMessages.test_enhanced_log_messages;
          test_case "性能和内存日志" `Quick Test_EnhancedLogMessages.test_performance_and_memory_logs;
          test_case "开发者和系统日志" `Quick Test_EnhancedLogMessages.test_developer_and_system_logs;
          test_case "测试日志" `Quick Test_EnhancedLogMessages.test_test_logs;
        ] );
      ( "日志格式化器",
        [
          test_case "时间戳格式化" `Quick Test_LoggingFormatter.test_timestamp_formatting;
          test_case "基础日志条目格式化" `Quick Test_LoggingFormatter.test_basic_log_entry_formatting;
          test_case "迁移信息格式化" `Quick Test_LoggingFormatter.test_migration_formatting;
          test_case "上下文格式化" `Quick Test_LoggingFormatter.test_context_formatting;
          test_case "迁移进度和建议" `Quick Test_LoggingFormatter.test_migration_progress_and_suggestions;
          test_case "多行日志和分隔符" `Quick Test_LoggingFormatter.test_multiline_and_separators;
          test_case "JSON和调试格式化" `Quick Test_LoggingFormatter.test_json_and_debug_formatting;
        ] );
      ( "调试格式化器",
        [
          test_case "变量状态格式化" `Quick Test_DebugFormatter.test_variable_state_formatting;
          test_case "函数调用追踪" `Quick Test_DebugFormatter.test_function_call_tracing;
          test_case "表达式求值追踪" `Quick Test_DebugFormatter.test_expression_evaluation_tracing;
          test_case "AST节点格式化" `Quick Test_DebugFormatter.test_ast_node_formatting;
        ] );
    ]