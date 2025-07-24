(** 编译器错误处理系统综合测试

    本测试文件针对compiler_errors.ml模块进行全面测试。
    该模块是编译器错误处理的核心组件，负责错误的创建、格式化和处理。
    
    测试覆盖：
    - 错误类型创建和验证
    - 错误信息格式化
    - 错误收集器功能  
    - 异常处理和转换
    - 安全执行机制
    - 错误结果处理
    - 边界条件和错误场景
    - 性能验证
    
    技术债务改进 - Fix #1036
    @author 骆言AI代理
    @since 2025-07-24 *)

open OUnit2
open Compiler_errors

(** ==================== 测试辅助函数 ==================== *)

(** 创建测试位置信息 *)
let create_test_position line col file =
  {
    line = line;
    column = col;
    filename = file;
    offset = line * 100 + col;
  }

(** 创建测试错误信息 *)
let create_test_error_info error_type msg pos =
  {
    error_type = error_type;
    message = msg;
    position = pos;
    severity = Error;
    error_code = "TEST001";
    suggestions = [];
    context = "";
  }

(** 验证错误信息格式 *)
let validate_error_format error_info =
  let formatted = format_error error_info in
  String.length formatted > 0 &&
  String.contains formatted ':' &&
  String.contains formatted error_info.message

(** ==================== 错误类型创建测试 ==================== *)

let test_create_syntax_error _ =
  (* 测试语法错误创建 *)
  let pos = create_test_position 10 5 "test.ly" in
  let error = create_syntax_error "语法解析错误" pos in
  assert_equal SyntaxError error.error_type;
  assert_equal "语法解析错误" error.message;
  assert_equal pos error.position;
  assert_equal Error error.severity

let test_create_semantic_error _ =
  (* 测试语义错误创建 *)
  let pos = create_test_position 20 15 "semantic_test.ly" in
  let error = create_semantic_error "类型不匹配" pos in
  assert_equal SemanticError error.error_type;
  assert_equal "类型不匹配" error.message;
  assert_equal pos error.position;
  assert_equal Error error.severity

let test_create_runtime_error _ =
  (* 测试运行时错误创建 *)
  let pos = create_test_position 30 25 "runtime_test.ly" in
  let error = create_runtime_error "除零错误" pos in
  assert_equal RuntimeError error.error_type;
  assert_equal "除零错误" error.message;
  assert_equal pos error.position;
  assert_equal Error error.severity

let test_create_warning _ =
  (* 测试警告创建 *)
  let pos = create_test_position 5 10 "warning_test.ly" in
  let warning = create_warning "未使用的变量" pos in
  assert_equal Warning warning.error_type;
  assert_equal "未使用的变量" warning.message;
  assert_equal pos warning.position;
  assert_equal Warning warning.severity

(** ==================== 错误格式化测试 ==================== *)

let test_format_error_basic _ =
  (* 测试基础错误格式化 *)
  let pos = create_test_position 1 1 "basic.ly" in
  let error = create_test_error_info SyntaxError "基础错误测试" pos in
  let formatted = format_error error in
  
  assert_bool "格式化结果应包含文件名" (String.contains formatted 'b');
  assert_bool "格式化结果应包含行号" (String.contains formatted '1');
  assert_bool "格式化结果应包含错误消息" (String.contains formatted '基');
  assert_bool "格式化结果应非空" (String.length formatted > 0)

let test_format_error_with_context _ =
  (* 测试带上下文的错误格式化 *)
  let pos = create_test_position 5 10 "context.ly" in
  let error = {
    (create_test_error_info SyntaxError "上下文错误测试" pos) with
    context = "let x = 1 + ;";
    suggestions = ["检查语法"; "补全表达式"];
  } in
  let formatted = format_error error in
  
  assert_bool "格式化结果应包含上下文" (String.contains formatted '+');
  assert_bool "格式化结果应包含建议" (String.contains formatted '检');
  assert_bool "格式化结果长度合理" (String.length formatted > 50)

let test_format_error_chinese _ =
  (* 测试中文错误格式化 *)
  let pos = create_test_position 8 12 "中文测试.ly" in
  let error = create_test_error_info SemanticError "变量未定义：骆言变量" pos in
  let formatted = format_error error in
  
  assert_bool "格式化结果应正确处理中文" (String.contains formatted '骆');
  assert_bool "格式化结果应正确处理中文文件名" (String.contains formatted '中');
  assert_bool "格式化结果应保持中文编码" (String.contains formatted '变')

(** ==================== 错误收集器测试 ==================== *)

let test_create_error_collector _ =
  (* 测试错误收集器创建 *)
  let collector = create_error_collector () in
  assert_equal [] (get_collected_errors collector);
  assert_equal 0 (get_error_count collector);
  assert_bool "收集器应无错误" (not (has_errors collector))

let test_collect_errors _ =
  (* 测试错误收集功能 *)
  let collector = create_error_collector () in
  let pos1 = create_test_position 1 1 "collect1.ly" in
  let pos2 = create_test_position 2 2 "collect2.ly" in
  let error1 = create_syntax_error "错误1" pos1 in
  let error2 = create_semantic_error "错误2" pos2 in
  
  add_error collector error1;
  add_error collector error2;
  
  assert_equal 2 (get_error_count collector);
  assert_bool "收集器应有错误" (has_errors collector);
  
  let collected = get_collected_errors collector in
  assert_equal 2 (List.length collected);
  assert_equal error1 (List.hd collected);
  assert_equal error2 (List.hd (List.tl collected))

let test_clear_errors _ =
  (* 测试清除错误功能 *)
  let collector = create_error_collector () in
  let pos = create_test_position 1 1 "clear.ly" in
  let error = create_syntax_error "待清除错误" pos in
  
  add_error collector error;
  assert_equal 1 (get_error_count collector);
  
  clear_errors collector;
  assert_equal 0 (get_error_count collector);
  assert_equal [] (get_collected_errors collector);
  assert_bool "清除后应无错误" (not (has_errors collector))

(** ==================== 异常处理测试 ==================== *)

let test_raise_compiler_error _ =
  (* 测试编译器错误抛出 *)
  let pos = create_test_position 1 1 "raise.ly" in
  let error = create_syntax_error "抛出测试错误" pos in
  
  assert_raises 
    (CompilerException error)
    (fun () -> raise_compiler_error error)

let test_safe_execute_success _ =
  (* 测试安全执行 - 成功情况 *)
  let result = safe_execute (fun () -> 42) in
  match result with
  | Ok value -> assert_equal 42 value
  | Error _ -> assert_failure "安全执行应该成功"

let test_safe_execute_failure _ =
  (* 测试安全执行 - 失败情况 *)
  let result = safe_execute (fun () -> failwith "测试失败") in
  match result with
  | Ok _ -> assert_failure "安全执行应该失败"
  | Error error_info -> 
      assert_equal RuntimeError error_info.error_type;
      assert_bool "错误消息应包含失败信息" (String.contains error_info.message '测')

let test_wrap_legacy_exception _ =
  (* 测试传统异常包装 *)
  let pos = create_test_position 1 1 "legacy.ly" in
  let legacy = create_syntax_error "传统错误" pos in
  let wrapped = wrap_legacy_exception (fun () -> Error legacy) in
  
  match wrapped with
  | Error error_info -> assert_equal legacy error_info
  | Ok _ -> assert_failure "传统异常包装应该返回错误"

(** ==================== 错误结果处理测试 ==================== *)

let test_extract_error_info _ =
  (* 测试错误信息提取 *)
  let pos = create_test_position 1 1 "extract.ly" in
  let error = create_semantic_error "提取测试错误" pos in
  let result = Error error in
  let extracted = extract_error_info result in
  
  assert_equal error extracted

let test_error_result_ok _ =
  (* 测试错误结果 - 成功情况 *)
  let result : int error_result = Ok 100 in
  match result with
  | Ok value -> assert_equal 100 value
  | Error _ -> assert_failure "错误结果应该是成功的"

let test_error_result_error _ =
  (* 测试错误结果 - 错误情况 *)  
  let pos = create_test_position 1 1 "result.ly" in
  let error = create_runtime_error "结果测试错误" pos in
  let result : int error_result = Error error in
  match result with
  | Ok _ -> assert_failure "错误结果应该是失败的"
  | Error error_info -> assert_equal error error_info

(** ==================== 边界条件测试 ==================== *)

let test_empty_message_error _ =
  (* 测试空消息错误 *)
  let pos = create_test_position 1 1 "empty.ly" in
  let error = create_syntax_error "" pos in
  assert_equal "" error.message;
  let formatted = format_error error in
  assert_bool "空消息格式化结果应非空" (String.length formatted > 0)

let test_large_position_values _ =
  (* 测试大位置值 *)
  let pos = create_test_position 99999 88888 "large.ly" in
  let error = create_semantic_error "大位置值测试" pos in
  assert_equal 99999 error.position.line;
  assert_equal 88888 error.position.column;
  let formatted = format_error error in
  assert_bool "大位置值格式化结果应包含行号" (String.contains formatted '9')

let test_unicode_error_messages _ =
  (* 测试Unicode错误消息 *)
  let pos = create_test_position 1 1 "unicode.ly" in
  let unicode_msg = "🚨错误：变量 '骆言' 未定义❌" in
  let error = create_syntax_error unicode_msg pos in
  assert_equal unicode_msg error.message;
  let formatted = format_error error in
  assert_bool "Unicode格式化结果应包含原消息" (String.contains formatted '🚨')

let test_very_long_error_message _ =
  (* 测试超长错误消息 *)
  let pos = create_test_position 1 1 "long.ly" in
  let long_msg = String.make 1000 '长' in
  let error = create_runtime_error long_msg pos in
  assert_equal long_msg error.message;
  let formatted = format_error error in
  assert_bool "超长消息格式化结果应合理" (String.length formatted > 500)

(** ==================== 性能测试 ==================== *)

let test_performance_error_creation _ =
  (* 测试错误创建性能 *)
  let pos = create_test_position 1 1 "perf.ly" in
  
  let start_time = Unix.gettimeofday () in
  for _ = 1 to 1000 do
    let _ = create_syntax_error "性能测试错误" pos in
    ()
  done;
  let end_time = Unix.gettimeofday () in
  
  let elapsed = end_time -. start_time in
  assert_bool "性能测试：1000次错误创建应在0.1秒内完成" (elapsed < 0.1)

let test_performance_error_formatting _ =
  (* 测试错误格式化性能 *)
  let pos = create_test_position 50 25 "format_perf.ly" in
  let error = create_test_error_info SyntaxError "格式化性能测试" pos in
  
  let start_time = Unix.gettimeofday () in
  for _ = 1 to 500 do
    let _ = format_error error in
    ()
  done;
  let end_time = Unix.gettimeofday () in
  
  let elapsed = end_time -. start_time in
  assert_bool "性能测试：500次错误格式化应在0.2秒内完成" (elapsed < 0.2)

let test_performance_error_collection _ =
  (* 测试错误收集性能 *)
  let collector = create_error_collector () in
  let pos = create_test_position 1 1 "collect_perf.ly" in
  
  let start_time = Unix.gettimeofday () in
  for i = 1 to 100 do
    let error = create_syntax_error ("错误" ^ string_of_int i) pos in
    add_error collector error
  done;
  let end_time = Unix.gettimeofday () in
  
  let elapsed = end_time -. start_time in
  assert_bool "性能测试：100次错误收集应在0.05秒内完成" (elapsed < 0.05);
  assert_equal 100 (get_error_count collector)

(** ==================== 集成测试 ==================== *)

let test_integration_error_workflow _ =
  (* 测试完整错误处理工作流 *)
  let collector = create_error_collector () in
  let pos = create_test_position 15 8 "integration.ly" in
  
  (* 1. 创建不同类型的错误 *)
  let syntax_error = create_syntax_error "语法错误" pos in
  let semantic_error = create_semantic_error "语义错误" pos in
  let warning = create_warning "警告信息" pos in
  
  (* 2. 收集错误 *)
  add_error collector syntax_error;
  add_error collector semantic_error;
  add_error collector warning;
  
  (* 3. 验证收集结果 *)
  assert_equal 3 (get_error_count collector);
  assert_bool "应有错误" (has_errors collector);
  
  (* 4. 格式化所有错误 *)
  let errors = get_collected_errors collector in
  let formatted_errors = List.map format_error errors in
  assert_equal 3 (List.length formatted_errors);
  
  (* 5. 验证格式化结果 *)
  List.iter (fun formatted ->
    assert_bool "格式化结果应非空" (String.length formatted > 0)
  ) formatted_errors

let test_integration_with_safe_execution _ =
  (* 测试与安全执行的集成 *)
  let test_function () =
    let pos = create_test_position 1 1 "safe_integration.ly" in
    let error = create_runtime_error "集成测试错误" pos in
    raise_compiler_error error
  in
  
  let result = safe_execute test_function in
  match result with
  | Ok _ -> assert_failure "安全执行应该捕获错误"
  | Error error_info ->
      assert_equal RuntimeError error_info.error_type;
      assert_bool "错误消息应包含集成测试" (String.contains error_info.message '集')

(** ==================== 测试套件 ==================== *)

let suite = "Compiler_errors comprehensive tests" >::: [
  (* 错误类型创建测试 *)
  "test_create_syntax_error" >:: test_create_syntax_error;
  "test_create_semantic_error" >:: test_create_semantic_error;
  "test_create_runtime_error" >:: test_create_runtime_error;
  "test_create_warning" >:: test_create_warning;
  
  (* 错误格式化测试 *)
  "test_format_error_basic" >:: test_format_error_basic;
  "test_format_error_with_context" >:: test_format_error_with_context;
  "test_format_error_chinese" >:: test_format_error_chinese;
  
  (* 错误收集器测试 *)
  "test_create_error_collector" >:: test_create_error_collector;
  "test_collect_errors" >:: test_collect_errors;
  "test_clear_errors" >:: test_clear_errors;
  
  (* 异常处理测试 *)
  "test_raise_compiler_error" >:: test_raise_compiler_error;
  "test_safe_execute_success" >:: test_safe_execute_success;
  "test_safe_execute_failure" >:: test_safe_execute_failure;
  "test_wrap_legacy_exception" >:: test_wrap_legacy_exception;
  
  (* 错误结果处理测试 *)
  "test_extract_error_info" >:: test_extract_error_info;
  "test_error_result_ok" >:: test_error_result_ok;
  "test_error_result_error" >:: test_error_result_error;
  
  (* 边界条件测试 *)
  "test_empty_message_error" >:: test_empty_message_error;
  "test_large_position_values" >:: test_large_position_values;
  "test_unicode_error_messages" >:: test_unicode_error_messages;
  "test_very_long_error_message" >:: test_very_long_error_message;
  
  (* 性能测试 *)
  "test_performance_error_creation" >:: test_performance_error_creation;
  "test_performance_error_formatting" >:: test_performance_error_formatting;
  "test_performance_error_collection" >:: test_performance_error_collection;
  
  (* 集成测试 *)
  "test_integration_error_workflow" >:: test_integration_error_workflow;
  "test_integration_with_safe_execution" >:: test_integration_with_safe_execution;
]

let () = run_test_tt_main suite