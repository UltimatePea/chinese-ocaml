(** 骆言编译器错误消息格式化模块全面测试 - Stage 2.1: Core formatter tests
    
    本测试文件针对formatter_errors.ml提供全面的测试覆盖率，特别关注：
    - ErrorMessages模块的完整测试
    - ErrorHandling模块的测试
    - EnhancedErrorMessages模块的测试
    - ErrorHandlingFormatter模块的测试
    
    Author: Alpha, 主工作代理
    Fix #1692 - 测试覆盖率提升计划第二阶段
    @since 2025-07-29 *)

open Alcotest
open Yyocamlc_lib.Formatter_errors

(** 帮助函数：检查字符串是否包含子字符串 *)
let contains_substring s sub =
  try
    let _ = Str.search_forward (Str.regexp_string sub) s 0 in
    true
  with Not_found -> false


(** 测试ErrorMessages模块 *)
module Test_ErrorMessages = struct
  (** 测试变量相关错误 *)
  let test_variable_errors () =
    let undefined_result = ErrorMessages.undefined_variable "counter" in
    check bool "未定义变量错误包含变量名" true (contains_substring undefined_result "counter");
    
    let already_defined = ErrorMessages.variable_already_defined "existing_var" in
    check bool "变量已定义错误包含变量名" true (contains_substring already_defined "existing_var");
    
    let suggestion = ErrorMessages.variable_suggestion "conter" ["counter"; "center"; "current"] in
    check bool "变量建议包含错误变量名" true (contains_substring suggestion "conter");
    check bool "变量建议包含可用变量" true (contains_substring suggestion "counter");
    check bool "变量建议使用中文分隔符" true (contains_substring suggestion "、")

  (** 测试函数相关错误 *)
  let test_function_errors () =
    let not_found = ErrorMessages.function_not_found "missing_func" in
    check bool "函数未找到错误包含函数名" true (contains_substring not_found "missing_func");
    
    let param_mismatch = ErrorMessages.function_param_count_mismatch "add" 2 3 in
    check bool "参数数量不匹配包含函数名" true (contains_substring param_mismatch "add");
    check bool "参数数量不匹配包含期望数量" true (contains_substring param_mismatch "2");
    check bool "参数数量不匹配包含实际数量" true (contains_substring param_mismatch "3");
    
    let simple_mismatch = ErrorMessages.function_param_count_mismatch_simple 1 4 in
    check bool "简单参数不匹配包含期望数量" true (contains_substring simple_mismatch "1");
    check bool "简单参数不匹配包含实际数量" true (contains_substring simple_mismatch "4");
    
    let needs_params = ErrorMessages.function_needs_params "multiply" 2 1 in
    check bool "函数需要参数包含函数名" true (contains_substring needs_params "multiply");
    check bool "函数需要参数包含期望数量" true (contains_substring needs_params "2");
    check bool "函数需要参数包含实际数量" true (contains_substring needs_params "1");
    
    let excess_params = ErrorMessages.function_excess_params "print" 1 3 in
    check bool "函数多余参数包含函数名" true (contains_substring excess_params "print");
    check bool "函数多余参数包含期望数量" true (contains_substring excess_params "1");
    check bool "函数多余参数包含实际数量" true (contains_substring excess_params "3")

  (** 测试类型相关错误 *)
  let test_type_errors () =
    let type_mismatch = ErrorMessages.type_mismatch "int" "string" in
    check bool "类型不匹配包含期望类型" true (contains_substring type_mismatch "int");
    check bool "类型不匹配包含实际类型" true (contains_substring type_mismatch "string");
    
    let detailed_mismatch = ErrorMessages.type_mismatch_detailed "bool" "int" "函数返回值" in
    check bool "详细类型不匹配包含上下文" true (contains_substring detailed_mismatch "函数返回值");
    
    let unknown_type = ErrorMessages.unknown_type "UnknownType" in
    check bool "未知类型错误包含类型名" true (contains_substring unknown_type "UnknownType");
    
    let invalid_operation = ErrorMessages.invalid_type_operation "division" in
    check bool "无效类型操作包含操作名" true (contains_substring invalid_operation "division");
    
    let invalid_arg = ErrorMessages.invalid_argument_type "string" "int" in
    check bool "无效参数类型包含期望类型" true (contains_substring invalid_arg "string");
    check bool "无效参数类型包含实际类型" true (contains_substring invalid_arg "int")

  (** 测试Token和语法错误 *)
  let test_token_and_syntax_errors () =
    let unexpected = ErrorMessages.unexpected_token "SEMICOLON" in
    check bool "意外Token包含Token名称" true (contains_substring unexpected "SEMICOLON");
    
    let expected = ErrorMessages.expected_token "IDENTIFIER" "NUMBER" in
    check bool "期望Token包含期望值" true (contains_substring expected "IDENTIFIER");
    check bool "期望Token包含实际值" true (contains_substring expected "NUMBER");
    
    let syntax_err = ErrorMessages.syntax_error "缺少右括号" in
    check bool "语法错误包含消息" true (contains_substring syntax_err "缺少右括号")

  (** 测试文件操作错误 *)
  let test_file_operation_errors () =
    let not_found = ErrorMessages.file_not_found "test.ml" in
    check bool "文件未找到包含文件名" true (contains_substring not_found "test.ml");
    
    let read_error = ErrorMessages.file_read_error "config.txt" in
    check bool "文件读取错误包含文件名" true (contains_substring read_error "config.txt");
    
    let write_error = ErrorMessages.file_write_error "output.c" in
    check bool "文件写入错误包含文件名" true (contains_substring write_error "output.c");
    
    let operation_error = ErrorMessages.file_operation_error "复制" "source.ml" in
    check bool "文件操作错误包含操作名" true (contains_substring operation_error "复制");
    check bool "文件操作错误包含文件名" true (contains_substring operation_error "source.ml")

  (** 测试模块和配置错误 *)
  let test_module_and_config_errors () =
    let module_not_found = ErrorMessages.module_not_found "Utils" in
    check bool "模块未找到包含模块名" true (contains_substring module_not_found "Utils");
    
    let member_not_found = ErrorMessages.member_not_found "List" "fold_right" in
    check bool "成员未找到包含模块名" true (contains_substring member_not_found "List");
    check bool "成员未找到包含成员名" true (contains_substring member_not_found "fold_right");
    
    let config_parse = ErrorMessages.config_parse_error "JSON格式错误" in
    check bool "配置解析错误包含消息" true (contains_substring config_parse "JSON格式错误");
    
    let invalid_config = ErrorMessages.invalid_config_value "timeout" "abc" in
    check bool "无效配置值包含键" true (contains_substring invalid_config "timeout");
    check bool "无效配置值包含值" true (contains_substring invalid_config "abc")

  (** 测试通用错误 *)
  let test_generic_errors () =
    let invalid_op = ErrorMessages.invalid_operation "除零" in
    check bool "无效操作包含操作名" true (contains_substring invalid_op "除零");
    
    let pattern_match = ErrorMessages.pattern_match_failure "Option" in
    check bool "模式匹配失败包含类型" true (contains_substring pattern_match "Option");
    
    let generic = ErrorMessages.generic_error "数据库" "连接失败" in
    check bool "通用错误包含上下文" true (contains_substring generic "数据库");
    check bool "通用错误包含消息" true (contains_substring generic "连接失败");
    
    let compilation = ErrorMessages.compilation_error "词法分析" "无效字符" in
    check bool "编译错误包含阶段" true (contains_substring compilation "词法分析");
    check bool "编译错误包含消息" true (contains_substring compilation "无效字符");
    
    let runtime = ErrorMessages.runtime_error "数组访问" "索引越界" in
    check bool "运行时错误包含操作" true (contains_substring runtime "数组访问");
    check bool "运行时错误包含消息" true (contains_substring runtime "索引越界");
    
    let spell_correction = ErrorMessages.variable_spell_correction "conter" "counter" in
    check bool "拼写纠正包含原名称" true (contains_substring spell_correction "conter");
    check bool "拼写纠正包含纠正名称" true (contains_substring spell_correction "counter")
end

(** 测试ErrorHandling模块 *)
module Test_ErrorHandling = struct
  (** 测试安全操作错误 *)
  let test_safe_operation_errors () =
    let safe_error = ErrorHandling.safe_operation_error "parse_int" "输入格式无效" in
    check bool "安全操作错误包含函数名" true (contains_substring safe_error "parse_int");
    check bool "安全操作错误包含消息" true (contains_substring safe_error "输入格式无效");
    
    let unexpected = ErrorHandling.unexpected_error_format "divide" "Division by zero" in
    check bool "未预期错误包含函数名" true (contains_substring unexpected "divide");
    check bool "未预期错误包含错误字符串" true (contains_substring unexpected "Division by zero")

  (** 测试词法和解析错误 *)
  let test_lexical_and_parse_errors () =
    let lexical = ErrorHandling.lexical_error "无效的数字格式" in
    check bool "词法错误包含详情" true (contains_substring lexical "无效的数字格式");
    
    let lexical_char = ErrorHandling.lexical_error_with_char "@" in
    check bool "词法字符错误包含字符" true (contains_substring lexical_char "@");
    
    let parse_err = ErrorHandling.parse_error "缺少分号" in
    check bool "解析错误包含详情" true (contains_substring parse_err "缺少分号");
    
    let parse_syntax = ErrorHandling.parse_error_syntax "if expression" in
    check bool "解析语法错误包含语法" true (contains_substring parse_syntax "if expression");
    
    let parse_failure = ErrorHandling.parse_failure_with_token "表达式" "IDENTIFIER" "类型不匹配" in
    check bool "解析失败包含表达式类型" true (contains_substring parse_failure "表达式");
    check bool "解析失败包含Token" true (contains_substring parse_failure "IDENTIFIER");
    check bool "解析失败包含错误消息" true (contains_substring parse_failure "类型不匹配")

  (** 测试运行时错误 *)
  let test_runtime_errors () =
    let runtime = ErrorHandling.runtime_error "栈溢出" in
    check bool "运行时错误包含详情" true (contains_substring runtime "栈溢出");
    
    let arithmetic = ErrorHandling.runtime_arithmetic_error "除零操作" in
    check bool "运行时算术错误包含详情" true (contains_substring arithmetic "除零操作")

  (** 测试带位置的错误 *)
  let test_positional_errors () =
    let with_position = ErrorHandling.error_with_position "语法错误" "main.ml" 42 in
    check bool "带位置错误包含消息" true (contains_substring with_position "语法错误");
    check bool "带位置错误包含文件名" true (contains_substring with_position "main.ml");
    check bool "带位置错误包含行号" true (contains_substring with_position "42");
    
    let lexical_pos = ErrorHandling.lexical_error_with_position "test.ml" 15 "无效标识符" in
    check bool "带位置词法错误包含文件名" true (contains_substring lexical_pos "test.ml");
    check bool "带位置词法错误包含行号" true (contains_substring lexical_pos "15");
    check bool "带位置词法错误包含消息" true (contains_substring lexical_pos "无效标识符")

  (** 测试通用错误类别和参数验证 *)
  let test_generic_categories_and_validation () =
    let with_detail = ErrorHandling.error_with_detail "类型错误" "int vs string" in
    check bool "带详情错误包含错误类型" true (contains_substring with_detail "类型错误");
    check bool "带详情错误包含详情" true (contains_substring with_detail "int vs string");
    
    let category = ErrorHandling.category_error "解析" "缺少右括号" in
    check bool "类别错误包含类别" true (contains_substring category "解析");
    check bool "类别错误包含详情" true (contains_substring category "缺少右括号");
    
    let simple_category = ErrorHandling.simple_category_error "编译" in
    check bool "简单类别错误包含类别" true (contains_substring simple_category "编译");
    
    let invalid_arg = ErrorHandling.invalid_argument "count" "positive integer" "negative value" in
    check bool "无效参数包含参数名" true (contains_substring invalid_arg "count");
    check bool "无效参数包含期望值" true (contains_substring invalid_arg "positive integer");
    check bool "无效参数包含实际值" true (contains_substring invalid_arg "negative value");
    
    let null_arg = ErrorHandling.null_argument_error "filename" in
    check bool "空参数错误包含参数名" true (contains_substring null_arg "filename")

  (** 测试边界检查和状态错误 *)
  let test_boundary_and_state_errors () =
    let out_of_bounds = ErrorHandling.index_out_of_bounds 10 5 in
    check bool "索引越界包含索引" true (contains_substring out_of_bounds "10");
    check bool "索引越界包含长度" true (contains_substring out_of_bounds "5");
    
    let array_bounds = ErrorHandling.array_bounds_error 8 3 in
    check bool "数组边界错误包含索引" true (contains_substring array_bounds "8");
    check bool "数组边界错误包含大小" true (contains_substring array_bounds "3");
    
    let invalid_state = ErrorHandling.invalid_state "已连接" "已断开" in
    check bool "无效状态包含期望状态" true (contains_substring invalid_state "已连接");
    check bool "无效状态包含当前状态" true (contains_substring invalid_state "已断开");
    
    let not_supported = ErrorHandling.operation_not_supported "多线程操作" in
    check bool "操作不支持包含操作名" true (contains_substring not_supported "多线程操作")

  (** 测试资源错误 *)
  let test_resource_errors () =
    let exhausted = ErrorHandling.resource_exhausted "内存" in
    check bool "资源耗尽包含资源名" true (contains_substring exhausted "内存");
    
    let not_available = ErrorHandling.resource_not_available "网络连接" in
    check bool "资源不可用包含资源名" true (contains_substring not_available "网络连接")
end

(** 测试EnhancedErrorMessages模块 *)
module Test_EnhancedErrorMessages = struct
  (** 测试增强的变量和模块错误 *)
  let test_enhanced_variable_and_module_errors () =
    let undefined_enhanced = EnhancedErrorMessages.undefined_variable_enhanced "variable" in
    check bool "增强未定义变量包含变量名" true (contains_substring undefined_enhanced "variable");
    
    let defined_enhanced = EnhancedErrorMessages.variable_already_defined_enhanced "existing" in
    check bool "增强变量已定义包含变量名" true (contains_substring defined_enhanced "existing");
    
    let module_member = EnhancedErrorMessages.module_member_not_found "String" "capitalize" in
    check bool "模块成员未找到包含模块名" true (contains_substring module_member "String");
    check bool "模块成员未找到包含成员名" true (contains_substring module_member "capitalize");
    
    let file_enhanced = EnhancedErrorMessages.file_not_found_enhanced "missing.txt" in
    check bool "增强文件未找到包含文件名" true (contains_substring file_enhanced "missing.txt")

  (** 测试Token相关增强错误 *)
  let test_enhanced_token_errors () =
    let token_expectation = EnhancedErrorMessages.token_expectation_error "SEMICOLON" "COMMA" in
    check bool "Token期望错误包含期望值" true (contains_substring token_expectation "SEMICOLON");
    check bool "Token期望错误包含实际值" true (contains_substring token_expectation "COMMA");
    
    let unexpected_token = EnhancedErrorMessages.unexpected_token_error "EOF" in
    check bool "意外Token错误包含Token" true (contains_substring unexpected_token "EOF")

  (** 测试代码生成和数据结构错误 *)
  let test_codegen_and_data_structure_errors () =
    let codegen = EnhancedErrorMessages.codegen_error "优化" "表达式" "无法内联" in
    check bool "代码生成错误包含阶段" true (contains_substring codegen "优化");
    check bool "代码生成错误包含表达式类型" true (contains_substring codegen "表达式");
    check bool "代码生成错误包含详情" true (contains_substring codegen "无法内联");
    
    let unsupported = EnhancedErrorMessages.unsupported_feature "闭包" "当前版本" in
    check bool "不支持的特性包含特性名" true (contains_substring unsupported "闭包");
    check bool "不支持的特性包含上下文" true (contains_substring unsupported "当前版本");
    
    let empty_collection = EnhancedErrorMessages.empty_collection "head" in
    check bool "空集合错误包含操作" true (contains_substring empty_collection "head");
    
    let duplicate_key = EnhancedErrorMessages.duplicate_key "username" in
    check bool "重复键错误包含键名" true (contains_substring duplicate_key "username")

  (** 测试解析和类型系统错误 *)
  let test_parsing_and_type_system_errors () =
    let parser_state = EnhancedErrorMessages.parser_state_error "表达式解析" "错误恢复" in
    check bool "解析器状态错误包含期望状态" true (contains_substring parser_state "表达式解析");
    check bool "解析器状态错误包含当前状态" true (contains_substring parser_state "错误恢复");
    
    let lexer_error = EnhancedErrorMessages.lexer_error "第15列" "?" in
    check bool "词法分析错误包含位置" true (contains_substring lexer_error "第15列");
    check bool "词法分析错误包含字符" true (contains_substring lexer_error "?");
    
    let type_inference = EnhancedErrorMessages.type_inference_failure "x + y" in
    check bool "类型推断失败包含表达式" true (contains_substring type_inference "x + y");
    
    let circular_dependency = EnhancedErrorMessages.circular_type_dependency "Node" in
    check bool "循环类型依赖包含类型名" true (contains_substring circular_dependency "Node")

  (** 测试执行错误 *)
  let test_execution_errors () =
    let timeout = EnhancedErrorMessages.execution_timeout "矩阵计算" in
    check bool "执行超时包含操作" true (contains_substring timeout "矩阵计算");
    
    let memory_limit = EnhancedErrorMessages.memory_limit_exceeded "大数组处理" in
    check bool "内存限制超出包含操作" true (contains_substring memory_limit "大数组处理")
end

(** 测试ErrorHandlingFormatter模块 *)
module Test_ErrorHandlingFormatter = struct
  (** 测试基础错误格式化 *)
  let test_basic_error_formatting () =
    let statistics = ErrorHandlingFormatter.format_error_statistics "语法" 5 in
    check bool "错误统计包含错误类型" true (contains_substring statistics "语法");
    check bool "错误统计包含数量" true (contains_substring statistics "5");
    
    let message = ErrorHandlingFormatter.format_error_message "类型错误" "int expected, got string" in
    check bool "错误消息包含错误类型" true (contains_substring message "类型错误");
    check bool "错误消息包含详情" true (contains_substring message "int expected, got string");
    
    let recovery = ErrorHandlingFormatter.format_recovery_info "跳过当前语句" in
    check bool "恢复信息包含恢复操作" true (contains_substring recovery "跳过当前语句");
    
    let context = ErrorHandlingFormatter.format_error_context "main.ml" 25 in
    check bool "错误上下文包含源信息" true (contains_substring context "main.ml");
    check bool "错误上下文包含行号" true (contains_substring context "25");
    
    let unified = ErrorHandlingFormatter.format_unified_error "解析错误" "缺少分号" in
    check bool "统一错误格式化包含类别" true (contains_substring unified "解析错误");
    check bool "统一错误格式化包含消息" true (contains_substring unified "缺少分号")

  (** 测试建议和提示格式化 *)
  let test_suggestions_and_hints () =
    let suggestion = ErrorHandlingFormatter.format_error_suggestion 1 "检查变量名拼写" in
    check bool "错误建议包含编号" true (contains_substring suggestion "1");
    check bool "错误建议包含建议文本" true (contains_substring suggestion "检查变量名拼写");
    
    let hint = ErrorHandlingFormatter.format_error_hint 2 "使用类型注解可以避免此错误" in
    check bool "错误提示包含编号" true (contains_substring hint "2");
    check bool "错误提示包含提示文本" true (contains_substring hint "使用类型注解可以避免此错误");
    
    let confidence = ErrorHandlingFormatter.format_confidence_score 85 in
    check bool "置信度包含百分比" true (contains_substring confidence "85%");
    check bool "置信度包含AI标识" true (contains_substring confidence "AI置信度")

  (** 测试异常和调试格式化 *)
  let test_exception_and_debug_formatting () =
    let exception_msg = ErrorHandlingFormatter.format_exception "NullPointerException" "访问空引用" in
    check bool "异常信息包含异常类型" true (contains_substring exception_msg "NullPointerException");
    check bool "异常信息包含消息" true (contains_substring exception_msg "访问空引用");
    
    let stack_trace = ErrorHandlingFormatter.format_stack_trace ["main.ml:15"; "utils.ml:42"; "lib.ml:98"] in
    check bool "堆栈跟踪包含第一帧" true (contains_substring stack_trace "main.ml:15");
    check bool "堆栈跟踪包含其他帧" true (contains_substring stack_trace "utils.ml:42");
    
    let warning = ErrorHandlingFormatter.warning_message "类型" "隐式转换可能导致精度丢失" in
    check bool "警告消息包含类别" true (contains_substring warning "类型");
    check bool "警告消息包含消息内容" true (contains_substring warning "隐式转换可能导致精度丢失");
    
    let deprecation = ErrorHandlingFormatter.deprecation_warning "old_function" "new_function" in
    check bool "弃用警告包含旧特性" true (contains_substring deprecation "old_function");
    check bool "弃用警告包含新特性" true (contains_substring deprecation "new_function");
    
    let debug_trace = ErrorHandlingFormatter.debug_trace "解析表达式" "当前Token: IDENTIFIER" in
    check bool "调试追踪包含操作" true (contains_substring debug_trace "解析表达式");
    check bool "调试追踪包含详情" true (contains_substring debug_trace "当前Token: IDENTIFIER");
    
    let perf_warning = ErrorHandlingFormatter.performance_warning "排序算法" 1000 1500 in
    check bool "性能警告包含操作" true (contains_substring perf_warning "排序算法");
    check bool "性能警告包含阈值" true (contains_substring perf_warning "1000");
    check bool "性能警告包含实际值" true (contains_substring perf_warning "1500")
end

let () =
  run "骆言错误消息格式化模块全面测试"
    [
      ( "错误消息基础",
        [
          test_case "变量相关错误" `Quick Test_ErrorMessages.test_variable_errors;
          test_case "函数相关错误" `Quick Test_ErrorMessages.test_function_errors;
          test_case "类型相关错误" `Quick Test_ErrorMessages.test_type_errors;
          test_case "Token和语法错误" `Quick Test_ErrorMessages.test_token_and_syntax_errors;
          test_case "文件操作错误" `Quick Test_ErrorMessages.test_file_operation_errors;
          test_case "模块和配置错误" `Quick Test_ErrorMessages.test_module_and_config_errors;
          test_case "通用错误" `Quick Test_ErrorMessages.test_generic_errors;
        ] );
      ( "错误处理",
        [
          test_case "安全操作错误" `Quick Test_ErrorHandling.test_safe_operation_errors;
          test_case "词法和解析错误" `Quick Test_ErrorHandling.test_lexical_and_parse_errors;
          test_case "运行时错误" `Quick Test_ErrorHandling.test_runtime_errors;
          test_case "带位置的错误" `Quick Test_ErrorHandling.test_positional_errors;
          test_case "通用错误类别和参数验证" `Quick Test_ErrorHandling.test_generic_categories_and_validation;
          test_case "边界检查和状态错误" `Quick Test_ErrorHandling.test_boundary_and_state_errors;
          test_case "资源错误" `Quick Test_ErrorHandling.test_resource_errors;
        ] );
      ( "增强错误消息",
        [
          test_case "增强的变量和模块错误" `Quick Test_EnhancedErrorMessages.test_enhanced_variable_and_module_errors;
          test_case "Token相关增强错误" `Quick Test_EnhancedErrorMessages.test_enhanced_token_errors;
          test_case "代码生成和数据结构错误" `Quick Test_EnhancedErrorMessages.test_codegen_and_data_structure_errors;
          test_case "解析和类型系统错误" `Quick Test_EnhancedErrorMessages.test_parsing_and_type_system_errors;
          test_case "执行错误" `Quick Test_EnhancedErrorMessages.test_execution_errors;
        ] );
      ( "错误处理格式化器",
        [
          test_case "基础错误格式化" `Quick Test_ErrorHandlingFormatter.test_basic_error_formatting;
          test_case "建议和提示格式化" `Quick Test_ErrorHandlingFormatter.test_suggestions_and_hints;
          test_case "异常和调试格式化" `Quick Test_ErrorHandlingFormatter.test_exception_and_debug_formatting;
        ] );
    ]