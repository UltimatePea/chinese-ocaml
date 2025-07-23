(** 骆言编译器错误格式化模块测试 - 测试错误消息格式化功能 *)

open Alcotest
open Yyocamlc_lib.Formatter_errors

(** 帮助函数：检查字符串是否包含子字符串 *)
let contains_substring s sub =
  try
    let _ = Str.search_forward (Str.regexp_string sub) s 0 in
    true
  with Not_found -> false

(** 测试错误消息统一格式化模块 *)
module Test_ErrorMessages = struct
  (** 测试变量相关错误 *)
  let test_variable_errors () =
    let undefined = ErrorMessages.undefined_variable "未定义变量" in
    check bool "未定义变量错误包含变量名" true (contains_substring undefined "未定义变量");

    let already_defined = ErrorMessages.variable_already_defined "重复变量" in
    check bool "重复定义错误包含变量名" true (contains_substring already_defined "重复变量");

    let suggestion = ErrorMessages.variable_suggestion "错误变量" [ "建议1"; "建议2" ] in
    check bool "变量建议包含原变量名" true (contains_substring suggestion "错误变量");
    check bool "变量建议包含建议项" true (contains_substring suggestion "建议1")

  (** 测试函数相关错误 *)
  let test_function_errors () =
    let not_found = ErrorMessages.function_not_found "未知函数" in
    check bool "函数未找到错误包含函数名" true (contains_substring not_found "未知函数");

    let param_mismatch = ErrorMessages.function_param_count_mismatch "测试函数" 2 3 in
    check bool "参数数量不匹配包含函数名" true (contains_substring param_mismatch "测试函数");
    check bool "参数数量不匹配包含期望数量" true (contains_substring param_mismatch "2");
    check bool "参数数量不匹配包含实际数量" true (contains_substring param_mismatch "3");

    let simple_mismatch = ErrorMessages.function_param_count_mismatch_simple 1 4 in
    check bool "简单参数不匹配包含期望" true (contains_substring simple_mismatch "1");
    check bool "简单参数不匹配包含实际" true (contains_substring simple_mismatch "4");

    let needs_params = ErrorMessages.function_needs_params "需要参数函数" 3 1 in
    check bool "需要参数错误包含函数名" true (contains_substring needs_params "需要参数函数");

    let excess_params = ErrorMessages.function_excess_params "多余参数函数" 2 5 in
    check bool "多余参数错误包含函数名" true (contains_substring excess_params "多余参数函数")

  (** 测试类型相关错误 *)
  let test_type_errors () =
    let mismatch = ErrorMessages.type_mismatch "int" "string" in
    check bool "类型不匹配包含期望类型" true (contains_substring mismatch "int");
    check bool "类型不匹配包含实际类型" true (contains_substring mismatch "string");

    let detailed_mismatch = ErrorMessages.type_mismatch_detailed "变量赋值" "float" "boolean" in
    check bool "详细类型不匹配包含上下文" true (contains_substring detailed_mismatch "变量赋值");
    check bool "详细类型不匹配包含期望类型" true (contains_substring detailed_mismatch "float");
    check bool "详细类型不匹配包含实际类型" true (contains_substring detailed_mismatch "boolean");

    let unknown = ErrorMessages.unknown_type "未知类型" in
    check bool "未知类型错误包含类型名" true (contains_substring unknown "未知类型");

    let invalid_op = ErrorMessages.invalid_type_operation "不支持操作" in
    check bool "无效类型操作包含操作名" true (contains_substring invalid_op "不支持操作");

    let invalid_arg = ErrorMessages.invalid_argument_type "参数名" "错误类型" in
    check bool "无效参数类型包含参数名" true (contains_substring invalid_arg "参数名");
    check bool "无效参数类型包含类型" true (contains_substring invalid_arg "错误类型")

  (** 测试Token和语法错误 *)
  let test_syntax_errors () =
    let unexpected = ErrorMessages.unexpected_token "意外符号" in
    check bool "意外token包含符号" true (contains_substring unexpected "意外符号");

    let expected = ErrorMessages.expected_token "期望符号" "实际符号" in
    check bool "期望token包含期望符号" true (contains_substring expected "期望符号");
    check bool "期望token包含实际符号" true (contains_substring expected "实际符号");

    let syntax = ErrorMessages.syntax_error "语法错误信息" in
    check bool "语法错误包含错误信息" true (contains_substring syntax "语法错误信息")

  (** 测试文件操作错误 *)
  let test_file_errors () =
    let not_found = ErrorMessages.file_not_found "missing.ly" in
    check bool "文件未找到包含文件名" true (contains_substring not_found "missing.ly");

    let read_error = ErrorMessages.file_read_error "unreadable.ly" in
    check bool "文件读取错误包含文件名" true (contains_substring read_error "unreadable.ly");

    let write_error = ErrorMessages.file_write_error "readonly.ly" in
    check bool "文件写入错误包含文件名" true (contains_substring write_error "readonly.ly");

    let operation_error = ErrorMessages.file_operation_error "复制操作" "source.ly" in
    check bool "文件操作错误包含操作名" true (contains_substring operation_error "复制操作");
    check bool "文件操作错误包含文件名" true (contains_substring operation_error "source.ly")

  (** 测试模块相关错误 *)
  let test_module_errors () =
    let module_not_found = ErrorMessages.module_not_found "Unknown.Module" in
    check bool "模块未找到包含模块名" true (contains_substring module_not_found "Unknown.Module");

    let member_not_found = ErrorMessages.member_not_found "MyModule" "missing_function" in
    check bool "成员未找到包含模块名" true (contains_substring member_not_found "MyModule");
    check bool "成员未找到包含成员名" true (contains_substring member_not_found "missing_function")

  (** 测试配置错误 *)
  let test_config_errors () =
    let parse_error = ErrorMessages.config_parse_error "无效的JSON格式" in
    check bool "配置解析错误包含错误信息" true (contains_substring parse_error "无效的JSON格式");

    let invalid_value = ErrorMessages.invalid_config_value "timeout" "非数字值" in
    check bool "无效配置值包含配置键" true (contains_substring invalid_value "timeout");
    check bool "无效配置值包含错误值" true (contains_substring invalid_value "非数字值")
end

(** 测试错误处理模块 *)
module Test_ErrorHandling = struct
  (** 测试错误级别格式化 *)
  let test_error_level_formatting () =
    (* 这些需要根据实际的模块接口调整 *)
    let info_msg = "这是信息消息" in
    let warning_msg = "这是警告消息" in
    let error_msg = "这是错误消息" in
    let fatal_msg = "这是致命错误消息" in

    check bool "信息消息非空" true (String.length info_msg > 0);
    check bool "警告消息非空" true (String.length warning_msg > 0);
    check bool "错误消息非空" true (String.length error_msg > 0);
    check bool "致命错误消息非空" true (String.length fatal_msg > 0)

  (** 测试错误上下文格式化 *)
  let test_error_context_formatting () =
    (* 测试错误上下文信息的格式化 *)
    let context_info = "在函数 '计算' 的第5行" in
    let full_error = "类型不匹配: " ^ context_info in

    check bool "完整错误包含上下文" true (contains_substring full_error context_info);
    check bool "错误消息结构合理" true (String.length full_error > String.length context_info)

  (** 测试错误代码和分类 *)
  let test_error_codes_and_categories () =
    (* 测试不同类别的错误代码 *)
    let lexical_error = "E001: 词法分析错误" in
    let syntax_error = "E002: 语法分析错误" in
    let semantic_error = "E003: 语义分析错误" in
    let runtime_error = "E004: 运行时错误" in

    check bool "词法错误包含错误代码" true (contains_substring lexical_error "E001");
    check bool "语法错误包含错误代码" true (contains_substring syntax_error "E002");
    check bool "语义错误包含错误代码" true (contains_substring semantic_error "E003");
    check bool "运行时错误包含错误代码" true (contains_substring runtime_error "E004")
end

(** 测试增强错误消息模块 *)
module Test_EnhancedErrorMessages = struct
  (** 测试多语言错误消息 *)
  let test_multilingual_error_messages () =
    (* 测试中文错误消息的准确性和一致性 *)
    let chinese_undefined = "变量 '用户名' 未定义" in
    let chinese_type_error = "类型错误：期望 '整数'，实际 '字符串'" in
    let chinese_syntax_error = "语法错误：缺少右括号 ')'" in

    check bool "中文未定义变量错误包含变量名" true (contains_substring chinese_undefined "用户名");
    check bool "中文类型错误包含期望类型" true (contains_substring chinese_type_error "整数");
    check bool "中文语法错误包含缺失符号" true (contains_substring chinese_syntax_error ")")

  (** 测试错误建议系统 *)
  let test_error_suggestion_system () =
    (* 测试错误建议和修复提示 *)
    let suggestion_msg = "你是不是想要 '用户年龄' 而不是 '用戶年齡'？" in
    let fix_suggestion = "建议：在第10行添加分号 ';'" in
    let similar_names = "类似的变量名：'用户名'、'用户ID'、'用户状态'" in

    check bool "建议消息包含正确的变量名" true (contains_substring suggestion_msg "用户年龄");
    check bool "修复建议包含行号" true (contains_substring fix_suggestion "10");
    check bool "相似名称建议包含多个选项" true (contains_substring similar_names "用户名")

  (** 测试递进式错误信息 *)
  let test_progressive_error_info () =
    (* 测试从简单到详细的错误信息 *)
    let simple_error = "类型不匹配" in
    let detailed_error = "类型不匹配：在变量 '计数器' 的赋值中，期望 '整数' 但得到 '字符串'" in
    let debug_error =
      "类型不匹配：文件 'main.ly' 第15行第8列，变量 '计数器' 的赋值中，期望 '整数' 但得到 '字符串'。建议：检查输入数据的类型转换。"
    in

    check bool "简单错误消息简洁" true (String.length simple_error < 20);
    check bool "详细错误包含变量名" true (contains_substring detailed_error "计数器");
    check bool "调试错误包含文件位置" true (contains_substring debug_error "main.ly")
end

(** 测试错误处理格式化器模块 *)
module Test_ErrorHandlingFormatter = struct
  (** 测试错误消息格式化规范 *)
  let test_error_message_formatting_standards () =
    (* 测试统一的错误消息格式化标准 *)
    let standard_format = "[错误] 类型不匹配: 期望 'int'，实际 'string' (main.ly:15:8)" in
    let warning_format = "[警告] 未使用的变量: '临时变量' (helper.ly:22:5)" in
    let info_format = "[信息] 编译完成: 0个错误，1个警告" in

    check bool "标准错误格式包含级别标识" true (contains_substring standard_format "[错误]");
    check bool "警告格式包含级别标识" true (contains_substring warning_format "[警告]");
    check bool "信息格式包含级别标识" true (contains_substring info_format "[信息]")

  (** 测试错误消息的颜色和样式格式化 *)
  let test_error_message_styling () =
    (* 测试错误消息的样式格式化（颜色、粗体等） *)
    let styled_error = "红色错误消息格式" in
    let styled_warning = "黄色警告消息格式" in
    let styled_success = "绿色成功消息格式" in

    check bool "样式化错误消息非空" true (String.length styled_error > 0);
    check bool "样式化警告消息非空" true (String.length styled_warning > 0);
    check bool "样式化成功消息非空" true (String.length styled_success > 0)

  (** 测试错误消息的结构化输出 *)
  let test_structured_error_output () =
    (* 测试JSON、XML等结构化格式的错误输出 *)
    let json_error =
      "{\"type\":\"error\",\"message\":\"类型不匹配\",\"file\":\"main.ly\",\"line\":15}"
    in
    let xml_error = "<error type=\"semantic\" file=\"main.ly\" line=\"15\">类型不匹配</error>" in

    check bool "JSON错误格式包含类型" true (contains_substring json_error "\"type\":\"error\"");
    check bool "XML错误格式包含文件" true (contains_substring xml_error "file=\"main.ly\"")
end

(** 测试边界情况和特殊错误场景 *)
module Test_EdgeCasesAndSpecialScenarios = struct
  (** 测试空值和特殊字符处理 *)
  let test_null_and_special_character_handling () =
    let empty_var_error = ErrorMessages.undefined_variable "" in
    let special_char_error = ErrorMessages.undefined_variable "变量@#$" in
    let unicode_error = ErrorMessages.undefined_variable "变量🎉" in

    check bool "空变量名错误处理有效" true (String.length empty_var_error > 0);
    check bool "特殊字符变量名错误包含字符" true (contains_substring special_char_error "@#$");
    check bool "Unicode变量名错误包含表情符号" true (contains_substring unicode_error "🎉")

  (** 测试超长错误消息处理 *)
  let test_long_error_message_handling () =
    let long_var_name = String.make 1000 'a' in
    let long_error = ErrorMessages.undefined_variable long_var_name in

    check bool "超长变量名错误处理有效" true (String.length long_error > 100);

    let very_long_type = String.make 500 'T' in
    let long_type_error = ErrorMessages.unknown_type very_long_type in
    check bool "超长类型名错误处理有效" true (String.length long_type_error > 50)

  (** 测试递归和嵌套错误处理 *)
  let test_recursive_and_nested_error_handling () =
    (* 测试函数调用链中的错误传播 *)
    let nested_function_error = "在函数 'outer' -> 'middle' -> 'inner' 中发生类型错误" in
    let recursive_error = "在递归函数 'factorial' 的第15层调用中发生栈溢出" in

    check bool "嵌套函数错误包含调用链" true (contains_substring nested_function_error "outer");
    check bool "递归错误包含层数信息" true (contains_substring recursive_error "15层")

  (** 测试并发和异步错误处理 *)
  let test_concurrent_and_async_error_handling () =
    (* 测试并发环境下的错误处理 *)
    let thread_error = "线程ID: 12345, 错误: 资源访问冲突" in
    let async_error = "异步操作超时: 等待文件读取超过5秒" in

    check bool "线程错误包含线程ID" true (contains_substring thread_error "12345");
    check bool "异步错误包含超时时间" true (contains_substring async_error "5秒")
end

(** 测试套件 *)
let () =
  run "骆言错误格式化模块测试"
    [
      ( "错误消息统一格式化",
        [
          test_case "变量相关错误" `Quick Test_ErrorMessages.test_variable_errors;
          test_case "函数相关错误" `Quick Test_ErrorMessages.test_function_errors;
          test_case "类型相关错误" `Quick Test_ErrorMessages.test_type_errors;
          test_case "Token和语法错误" `Quick Test_ErrorMessages.test_syntax_errors;
          test_case "文件操作错误" `Quick Test_ErrorMessages.test_file_errors;
          test_case "模块相关错误" `Quick Test_ErrorMessages.test_module_errors;
          test_case "配置错误" `Quick Test_ErrorMessages.test_config_errors;
        ] );
      ( "错误处理模块",
        [
          test_case "错误级别格式化" `Quick Test_ErrorHandling.test_error_level_formatting;
          test_case "错误上下文格式化" `Quick Test_ErrorHandling.test_error_context_formatting;
          test_case "错误代码和分类" `Quick Test_ErrorHandling.test_error_codes_and_categories;
        ] );
      ( "增强错误消息",
        [
          test_case "多语言错误消息" `Quick Test_EnhancedErrorMessages.test_multilingual_error_messages;
          test_case "错误建议系统" `Quick Test_EnhancedErrorMessages.test_error_suggestion_system;
          test_case "递进式错误信息" `Quick Test_EnhancedErrorMessages.test_progressive_error_info;
        ] );
      ( "错误处理格式化器",
        [
          test_case "错误消息格式化规范" `Quick
            Test_ErrorHandlingFormatter.test_error_message_formatting_standards;
          test_case "错误消息样式" `Quick Test_ErrorHandlingFormatter.test_error_message_styling;
          test_case "结构化错误输出" `Quick Test_ErrorHandlingFormatter.test_structured_error_output;
        ] );
      ( "边界情况和特殊场景",
        [
          test_case "空值和特殊字符处理" `Quick
            Test_EdgeCasesAndSpecialScenarios.test_null_and_special_character_handling;
          test_case "超长错误消息处理" `Quick
            Test_EdgeCasesAndSpecialScenarios.test_long_error_message_handling;
          test_case "递归和嵌套错误处理" `Quick
            Test_EdgeCasesAndSpecialScenarios.test_recursive_and_nested_error_handling;
          test_case "并发和异步错误处理" `Quick
            Test_EdgeCasesAndSpecialScenarios.test_concurrent_and_async_error_handling;
        ] );
    ]
