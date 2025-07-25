(** 骆言字符串格式化模块综合测试 - String Formatter Module Comprehensive Tests
    
    测试覆盖范围：
    - CCodegen模块：C代码生成格式化工具
    - ErrorMessages模块：错误消息格式化工具 
    - LogMessages模块：日志格式化工具
    - General模块：通用格式化工具
    
    @version 1.0
    @since 2025-07-25 技术债务改进：新增string_formatter模块测试覆盖 *)

open Alcotest
open Yyocamlc_lib.String_formatter

(** 测试CCodegen模块 - C代码生成格式化功能 *)
module TestCCodegen = struct

  (** 测试函数调用格式化 *)
  let test_format_function_call () =
    let result = CCodegen.format_function_call "test_func" ["arg1"; "arg2"] in
    check string "函数调用格式化正确" "test_func(arg1, arg2)" result

  (** 测试二元运算格式化 *)
  let test_format_binary_op () =
    let result = CCodegen.format_binary_op "add" "left_val" "right_val" in
    check string "二元运算格式化正确" "add(left_val, right_val)" result

  (** 测试一元运算格式化 *)
  let test_format_unary_op () =
    let result = CCodegen.format_unary_op "negate" "operand_val" in
    check string "一元运算格式化正确" "negate(operand_val)" result

  (** 测试变量绑定格式化 *)
  let test_format_var_binding () =
    let result = CCodegen.format_var_binding "var_name" "var_value" in
    check string "变量绑定格式化正确" "luoyan_env_bind(env, \"var_name\", var_value);" result

  (** 测试字符串字面量格式化 *)
  let test_format_string_literal () =
    let result = CCodegen.format_string_literal "test" in
    check string "字符串字面量格式化正确" "luoyan_string(\"test\")" result

  (** 测试整数字面量格式化 *)
  let test_format_int_literal () =
    let result = CCodegen.format_int_literal 42 in
    check string "整数字面量格式化正确" "luoyan_int(42)" result

  (** 测试浮点数字面量格式化 *)
  let test_format_float_literal () =
    let result = CCodegen.format_float_literal 3.14 in
    check string "浮点数字面量格式化正确" "luoyan_float(3.14)" result

  (** 测试布尔字面量格式化 - true *)
  let test_format_bool_literal_true () =
    let result = CCodegen.format_bool_literal true in
    check string "布尔true字面量格式化正确" "luoyan_bool(true)" result

  (** 测试布尔字面量格式化 - false *)
  let test_format_bool_literal_false () =
    let result = CCodegen.format_bool_literal false in
    check string "布尔false字面量格式化正确" "luoyan_bool(false)" result

  (** 测试单元字面量格式化 *)
  let test_format_unit_literal () =
    let result = CCodegen.format_unit_literal () in
    check string "单元字面量格式化正确" "luoyan_unit()" result

  (** 测试等值比较格式化 *)
  let test_format_equality_check () =
    let result = CCodegen.format_equality_check "expr_var" "value" in
    check string "等值比较格式化正确" "luoyan_equals(expr_var, value)" result

  (** 测试let表达式格式化 *)
  let test_format_let_expr () =
    let result = CCodegen.format_let_expr "variable" "value_code" "body_code" in
    check string "let表达式格式化正确" "luoyan_let(\"variable\", value_code, body_code)" result

  (** 测试函数定义格式化 *)
  let test_format_function_def () =
    let result = CCodegen.format_function_def "func_name" "param1" in
    check string "函数定义格式化正确" "luoyan_function_create(func_name_impl_param1, env, \"func_name\")" result

  (** 测试模式匹配格式化 *)
  let test_format_pattern_match () =
    let result = CCodegen.format_pattern_match "expr_var" in
    check string "模式匹配格式化正确" "luoyan_pattern_match(expr_var)" result

  (** 测试变量表达式格式化 *)
  let test_format_var_expr () =
    let result = CCodegen.format_var_expr "expr_var" "expr_code" in
    check string "变量表达式格式化正确" "({ luoyan_value_t* expr_var = expr_code; luoyan_match(expr_var); })" result

  (** 测试边界条件 - 空参数列表 *)
  let test_format_function_call_empty_args () =
    let result = CCodegen.format_function_call "empty_func" [] in
    check string "空参数函数调用格式化正确" "empty_func()" result

  (** 测试边界条件 - 特殊字符转义 *)
  let test_format_string_literal_special_chars () =
    let result = CCodegen.format_string_literal "test\"quote\\newline\n" in
    let expected = "luoyan_string(\"test\\\"quote\\\\newline\\n\")" in
    check string "特殊字符字符串字面量转义正确" expected result

end

(** 测试ErrorMessages模块 - 错误消息格式化功能 *)
module TestErrorMessages = struct

  (** 测试参数数量不匹配错误格式化 *)
  let test_format_param_count_mismatch () =
    let result = ErrorMessages.format_param_count_mismatch 3 2 in
    check string "参数数量不匹配错误格式化正确" "函数期望3个参数，提供了2个" result

  (** 测试参数缺失填充消息格式化 *)
  let test_format_missing_params_filled () =
    let result = ErrorMessages.format_missing_params_filled 5 3 2 in
    check string "参数缺失填充消息格式化正确" "函数期望5个参数，提供了3个，用默认值填充缺失的2个参数" result

  (** 测试多余参数忽略消息格式化 *)
  let test_format_extra_params_ignored () =
    let result = ErrorMessages.format_extra_params_ignored 3 5 2 in
    check string "多余参数忽略消息格式化正确" "函数期望3个参数，提供了5个，忽略多余的2个参数" result

  (** 测试意外词元错误格式化 *)
  let test_format_unexpected_token () =
    let result = ErrorMessages.format_unexpected_token "INVALID_TOKEN" in
    check string "意外词元错误格式化正确" "意外的词元: INVALID_TOKEN" result

  (** 测试语法错误格式化 *)
  let test_format_syntax_error () =
    let result = ErrorMessages.format_syntax_error "缺少分号" "第42行" in
    check string "语法错误格式化正确" "语法错误: 缺少分号 (位置: 第42行)" result

  (** 测试类型错误格式化 *)
  let test_format_type_error () =
    let result = ErrorMessages.format_type_error "整数" "字符串" in
    check string "类型错误格式化正确" "类型错误: 期望 整数，实际 字符串" result

  (** 测试边界条件 - 零参数情况 *)
  let test_format_param_count_mismatch_zero () =
    let result = ErrorMessages.format_param_count_mismatch 0 1 in
    check string "零参数数量不匹配错误格式化正确" "函数期望0个参数，提供了1个" result

end

(** 测试LogMessages模块 - 日志格式化功能 *)
module TestLogMessages = struct

  (** 测试调试消息格式化 *)
  let test_format_debug_message () =
    let result = LogMessages.format_debug_message "TestModule" "这是调试消息" in
    check string "调试消息格式化正确" "[DEBUG] TestModule: 这是调试消息" result

  (** 测试信息消息格式化 *)
  let test_format_info_message () =
    let result = LogMessages.format_info_message "InfoModule" "这是信息消息" in
    check string "信息消息格式化正确" "[INFO] InfoModule: 这是信息消息" result

  (** 测试警告消息格式化 *)
  let test_format_warning_message () =
    let result = LogMessages.format_warning_message "WarnModule" "这是警告消息" in
    check string "警告消息格式化正确" "[WARNING] WarnModule: 这是警告消息" result

  (** 测试错误消息格式化 *)
  let test_format_error_message () =
    let result = LogMessages.format_error_message "ErrorModule" "这是错误消息" in
    check string "错误消息格式化正确" "[ERROR] ErrorModule: 这是错误消息" result

  (** 测试边界条件 - 空模块名 *)
  let test_format_debug_message_empty_module () =
    let result = LogMessages.format_debug_message "" "消息内容" in
    check string "空模块名调试消息格式化正确" "[DEBUG] : 消息内容" result

  (** 测试边界条件 - 空消息内容 *)
  let test_format_info_message_empty_content () =
    let result = LogMessages.format_info_message "Module" "" in
    check string "空消息内容信息消息格式化正确" "[INFO] Module: " result

end

(** 测试General模块 - 通用格式化功能 *)
module TestGeneral = struct

  (** 测试标识符格式化 *)
  let test_format_identifier () =
    let result = General.format_identifier "测试标识符" in
    check string "标识符格式化正确" "「测试标识符」" result

  (** 测试函数签名格式化 *)
  let test_format_function_signature () =
    let result = General.format_function_signature "test_func" ["param1"; "param2"] in
    check string "函数签名格式化正确" "test_func(param1, param2)" result

  (** 测试类型签名格式化 *)
  let test_format_type_signature () =
    let result = General.format_type_signature "List" ["String"; "Int"] in
    check string "类型签名格式化正确" "List<String, Int>" result

  (** 测试模块路径格式化 *)
  let test_format_module_path () =
    let result = General.format_module_path ["Root"; "SubModule"; "LeafModule"] in
    check string "模块路径格式化正确" "Root.SubModule.LeafModule" result

  (** 测试列表格式化 *)
  let test_format_list () =
    let result = General.format_list ["item1"; "item2"; "item3"] ", " in
    check string "列表格式化正确" "item1, item2, item3" result

  (** 测试键值对格式化 *)
  let test_format_key_value () =
    let result = General.format_key_value "键名" "键值" in
    check string "键值对格式化正确" "键名: 键值" result

  (** 测试边界条件 - 空列表格式化 *)
  let test_format_list_empty () =
    let result = General.format_list [] ", " in
    check string "空列表格式化正确" "" result

  (** 测试边界条件 - 单元素列表格式化 *)
  let test_format_list_single () =
    let result = General.format_list ["唯一元素"] ", " in
    check string "单元素列表格式化正确" "唯一元素" result

  (** 测试边界条件 - 空类型参数列表 *)
  let test_format_type_signature_empty_params () =
    let result = General.format_type_signature "SimpleType" [] in
    check string "无类型参数类型签名格式化正确" "SimpleType<>" result

  (** 测试边界条件 - 单层模块路径 *)
  let test_format_module_path_single () =
    let result = General.format_module_path ["RootModule"] in
    check string "单层模块路径格式化正确" "RootModule" result

end

(** 集成测试 - 测试模块间协作 *)
module TestIntegration = struct

  (** 测试CCodegen与ErrorMessages的协作 *)
  let test_codegen_error_integration () =
    let func_call = CCodegen.format_function_call "failing_func" ["arg"] in
    let error_msg = ErrorMessages.format_unexpected_token func_call in
    let expected = "意外的词元: failing_func(arg)" in
    check string "代码生成与错误消息集成正确" expected error_msg

  (** 测试LogMessages与General的协作 *)
  let test_log_general_integration () =
    let module_path = General.format_module_path ["Logger"; "Formatter"] in
    let log_msg = LogMessages.format_info_message module_path "模块加载完成" in
    let expected = "[INFO] Logger.Formatter: 模块加载完成" in
    check string "日志与通用格式化集成正确" expected log_msg

  (** 测试复杂格式化场景 *)
  let test_complex_formatting_scenario () =
    let identifier = General.format_identifier "复杂函数" in
    let params = General.format_list ["参数1"; "参数2"] ", " in
    let func_sig = General.format_function_signature identifier [params] in
    let log_entry = LogMessages.format_debug_message "ComplexModule" func_sig in
    let expected = "[DEBUG] ComplexModule: 「复杂函数」(参数1, 参数2)" in
    check string "复杂格式化场景正确" expected log_entry

end

(** 性能测试 - 确保格式化操作的效率 *)
module TestPerformance = struct

  (** 测试大量字符串连接的性能 *)
  let test_large_string_concatenation () =
    let large_list = List.init 1000 (fun i -> "item_" ^ string_of_int i) in
    let result = General.format_list large_list ", " in
    check bool "大量字符串连接完成" true (String.length result > 0)

  (** 测试重复格式化操作 *)
  let test_repeated_formatting () =
    let results = List.init 100 (fun i -> 
      CCodegen.format_function_call ("func_" ^ string_of_int i) ["arg1"; "arg2"]
    ) in
    check int "重复格式化操作完成" 100 (List.length results)

end

(** 测试套件主函数 *)
let () =
  run "骆言字符串格式化模块综合测试"
    [
      (* CCodegen模块测试 *)
      ( "CCodegen模块测试",
        [
          test_case "函数调用格式化" `Quick TestCCodegen.test_format_function_call;
          test_case "二元运算格式化" `Quick TestCCodegen.test_format_binary_op;
          test_case "一元运算格式化" `Quick TestCCodegen.test_format_unary_op;
          test_case "变量绑定格式化" `Quick TestCCodegen.test_format_var_binding;
          test_case "字符串字面量格式化" `Quick TestCCodegen.test_format_string_literal;
          test_case "整数字面量格式化" `Quick TestCCodegen.test_format_int_literal;
          test_case "浮点数字面量格式化" `Quick TestCCodegen.test_format_float_literal;
          test_case "布尔true字面量格式化" `Quick TestCCodegen.test_format_bool_literal_true;
          test_case "布尔false字面量格式化" `Quick TestCCodegen.test_format_bool_literal_false;
          test_case "单元字面量格式化" `Quick TestCCodegen.test_format_unit_literal;
          test_case "等值比较格式化" `Quick TestCCodegen.test_format_equality_check;
          test_case "let表达式格式化" `Quick TestCCodegen.test_format_let_expr;
          test_case "函数定义格式化" `Quick TestCCodegen.test_format_function_def;
          test_case "模式匹配格式化" `Quick TestCCodegen.test_format_pattern_match;
          test_case "变量表达式格式化" `Quick TestCCodegen.test_format_var_expr;
          test_case "空参数函数调用格式化" `Quick TestCCodegen.test_format_function_call_empty_args;
          test_case "特殊字符字符串字面量格式化" `Quick TestCCodegen.test_format_string_literal_special_chars;
        ] );

      (* ErrorMessages模块测试 *)
      ( "ErrorMessages模块测试",
        [
          test_case "参数数量不匹配错误格式化" `Quick TestErrorMessages.test_format_param_count_mismatch;
          test_case "参数缺失填充消息格式化" `Quick TestErrorMessages.test_format_missing_params_filled;
          test_case "多余参数忽略消息格式化" `Quick TestErrorMessages.test_format_extra_params_ignored;
          test_case "意外词元错误格式化" `Quick TestErrorMessages.test_format_unexpected_token;
          test_case "语法错误格式化" `Quick TestErrorMessages.test_format_syntax_error;
          test_case "类型错误格式化" `Quick TestErrorMessages.test_format_type_error;
          test_case "零参数数量不匹配错误格式化" `Quick TestErrorMessages.test_format_param_count_mismatch_zero;
        ] );

      (* LogMessages模块测试 *)
      ( "LogMessages模块测试",
        [
          test_case "调试消息格式化" `Quick TestLogMessages.test_format_debug_message;
          test_case "信息消息格式化" `Quick TestLogMessages.test_format_info_message;
          test_case "警告消息格式化" `Quick TestLogMessages.test_format_warning_message;
          test_case "错误消息格式化" `Quick TestLogMessages.test_format_error_message;
          test_case "空模块名调试消息格式化" `Quick TestLogMessages.test_format_debug_message_empty_module;
          test_case "空消息内容信息消息格式化" `Quick TestLogMessages.test_format_info_message_empty_content;
        ] );

      (* General模块测试 *)
      ( "General模块测试",
        [
          test_case "标识符格式化" `Quick TestGeneral.test_format_identifier;
          test_case "函数签名格式化" `Quick TestGeneral.test_format_function_signature;
          test_case "类型签名格式化" `Quick TestGeneral.test_format_type_signature;
          test_case "模块路径格式化" `Quick TestGeneral.test_format_module_path;
          test_case "列表格式化" `Quick TestGeneral.test_format_list;
          test_case "键值对格式化" `Quick TestGeneral.test_format_key_value;
          test_case "空列表格式化" `Quick TestGeneral.test_format_list_empty;
          test_case "单元素列表格式化" `Quick TestGeneral.test_format_list_single;
          test_case "无类型参数类型签名格式化" `Quick TestGeneral.test_format_type_signature_empty_params;
          test_case "单层模块路径格式化" `Quick TestGeneral.test_format_module_path_single;
        ] );

      (* 集成测试 *)
      ( "集成测试",
        [
          test_case "代码生成与错误消息集成" `Quick TestIntegration.test_codegen_error_integration;
          test_case "日志与通用格式化集成" `Quick TestIntegration.test_log_general_integration;
          test_case "复杂格式化场景" `Quick TestIntegration.test_complex_formatting_scenario;
        ] );

      (* 性能测试 *)
      ( "性能测试",
        [
          test_case "大量字符串连接性能" `Quick TestPerformance.test_large_string_concatenation;
          test_case "重复格式化操作性能" `Quick TestPerformance.test_repeated_formatting;
        ] );
    ]