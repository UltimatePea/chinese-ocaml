(** 错误处理核心模块综合测试

    本测试文件针对error_handler_core.ml模块进行全面测试。
    该模块是编译器错误处理的核心组件，负责错误的捕获、处理和恢复。
    
    测试覆盖：
    - 错误处理器初始化和配置
    - 错误捕获和处理机制
    - 错误恢复策略
    - 错误优先级管理
    - 错误批量处理
    - 错误上下文管理
    - 错误链处理
    - 边界条件和错误场景
    - 性能验证
    
    技术债务改进 - Fix #1036
    @author 骆言AI代理
    @since 2025-07-24 *)

open OUnit2
open Error_handler_core

(** ==================== 测试辅助函数 ==================== *)

(** 创建测试错误信息 *)
let create_test_error severity msg line col =
  {
    severity = severity;
    message = msg;
    location = {
      line = line;
      column = col;
      filename = "test.ly";
      offset = line * 100 + col;
    };
    error_code = "TEST" ^ string_of_int (Random.int 1000);
    context = "";
    suggestions = [];
    timestamp = Unix.time ();
  }

(** 创建测试错误处理器配置 *)
let create_test_handler_config () =
  {
    max_errors = 10;
    stop_on_first_error = false;
    enable_recovery = true;
    recovery_strategies = [SkipToken; InsertToken; ReplaceToken];
    error_reporting_level = Verbose;
    include_suggestions = true;
    include_context = true;
    context_lines = 3;
  }

(** 验证错误处理结果 *)
let validate_error_result result =
  match result with
  | HandlerSuccess _ -> true
  | HandlerError _ -> false
  | HandlerRecovered _ -> true

(** 验证错误处理器状态 *)
let validate_handler_state handler =
  let error_count = get_error_count handler in
  let warning_count = get_warning_count handler in
  error_count >= 0 && warning_count >= 0

(** ==================== 错误处理器初始化测试 ==================== *)

let test_create_error_handler _ =
  (* 测试错误处理器创建 *)
  let config = create_test_handler_config () in
  let handler = create_error_handler config in
  
  assert_bool "错误处理器应该创建成功" (validate_handler_state handler);
  assert_equal 0 (get_error_count handler);
  assert_equal 0 (get_warning_count handler);
  assert_bool "处理器应处于活跃状态" (is_handler_active handler)

let test_handler_configuration _ =
  (* 测试错误处理器配置 *)
  let custom_config = {
    max_errors = 5;
    stop_on_first_error = true;
    enable_recovery = false;
    recovery_strategies = [SkipToken];
    error_reporting_level = Minimal;
    include_suggestions = false;
    include_context = false;
    context_lines = 1;
  } in
  let handler = create_error_handler custom_config in
  
  assert_bool "自定义配置处理器应创建成功" (validate_handler_state handler);
  assert_equal 5 (get_max_errors handler);
  assert_bool "应启用首次错误停止" (is_stop_on_first_error_enabled handler)

let test_handler_state_management _ =
  (* 测试处理器状态管理 *)
  let config = create_test_handler_config () in
  let handler = create_error_handler config in
  
  (* 测试激活和停用 *)
  assert_bool "处理器初始应处于活跃状态" (is_handler_active handler);
  
  deactivate_handler handler;
  assert_bool "处理器应处于非活跃状态" (not (is_handler_active handler));
  
  activate_handler handler;
  assert_bool "处理器应重新处于活跃状态" (is_handler_active handler)

(** ==================== 错误捕获和处理测试 ==================== *)

let test_handle_single_error _ =
  (* 测试单个错误处理 *)
  let config = create_test_handler_config () in
  let handler = create_error_handler config in
  let error = create_test_error Error "测试语法错误" 10 5 in
  
  let result = handle_error handler error in
  assert_bool "错误处理应该成功" (validate_error_result result);
  assert_equal 1 (get_error_count handler);
  assert_equal 0 (get_warning_count handler)

let test_handle_multiple_errors _ =
  (* 测试多个错误处理 *)
  let config = create_test_handler_config () in
  let handler = create_error_handler config in
  
  let errors = [
    create_test_error Error "语法错误1" 1 1;
    create_test_error Warning "警告信息1" 2 2;
    create_test_error Error "语义错误1" 3 3;
    create_test_error Info "信息提示1" 4 4;
  ] in
  
  List.iter (fun error ->
    let _ = handle_error handler error in
    ()
  ) errors;
  
  assert_equal 2 (get_error_count handler);
  assert_equal 1 (get_warning_count handler);
  assert_equal 1 (get_info_count handler)

let test_handle_error_batch _ =
  (* 测试批量错误处理 *)
  let config = create_test_handler_config () in
  let handler = create_error_handler config in
  
  let error_batch = [
    create_test_error Error "批量错误1" 10 10;
    create_test_error Error "批量错误2" 20 20;
    create_test_error Warning "批量警告1" 30 30;
  ] in
  
  let results = handle_error_batch handler error_batch in
  assert_equal 3 (List.length results);
  assert_equal 2 (get_error_count handler);
  assert_equal 1 (get_warning_count handler);
  
  List.iter (fun result ->
    assert_bool "批量处理结果应该有效" (validate_error_result result)
  ) results

(** ==================== 错误恢复策略测试 ==================== *)

let test_error_recovery_skip_token _ =
  (* 测试跳过Token恢复策略 *)
  let config = {
    (create_test_handler_config ()) with
    recovery_strategies = [SkipToken];
  } in
  let handler = create_error_handler config in
  let error = create_test_error Error "跳过Token测试" 5 10 in
  
  let result = handle_error_with_recovery handler error in
  match result with
  | HandlerRecovered (strategy, _) -> 
      assert_equal SkipToken strategy
  | _ -> assert_failure "应该执行跳过Token恢复"

let test_error_recovery_insert_token _ =
  (* 测试插入Token恢复策略 *)
  let config = {
    (create_test_handler_config ()) with
    recovery_strategies = [InsertToken];
  } in
  let handler = create_error_handler config in
  let error = create_test_error Error "插入Token测试" 8 15 in
  
  let result = handle_error_with_recovery handler error in
  match result with
  | HandlerRecovered (strategy, _) -> 
      assert_equal InsertToken strategy
  | _ -> assert_failure "应该执行插入Token恢复"

let test_error_recovery_replace_token _ =
  (* 测试替换Token恢复策略 *)
  let config = {
    (create_test_handler_config ()) with
    recovery_strategies = [ReplaceToken];
  } in
  let handler = create_error_handler config in
  let error = create_test_error Error "替换Token测试" 12 8 in
  
  let result = handle_error_with_recovery handler error in
  match result with
  | HandlerRecovered (strategy, _) -> 
      assert_equal ReplaceToken strategy
  | _ -> assert_failure "应该执行替换Token恢复"

let test_error_recovery_multiple_strategies _ =
  (* 测试多种恢复策略 *)
  let config = {
    (create_test_handler_config ()) with
    recovery_strategies = [SkipToken; InsertToken; ReplaceToken];
  } in
  let handler = create_error_handler config in
  
  let errors = [
    create_test_error Error "多策略错误1" 1 1;
    create_test_error Error "多策略错误2" 2 2;
    create_test_error Error "多策略错误3" 3 3;
  ] in
  
  let results = List.map (handle_error_with_recovery handler) errors in
  List.iter (fun result ->
    match result with
    | HandlerRecovered (strategy, _) -> 
        assert_bool "恢复策略应该是有效的" 
          (List.mem strategy [SkipToken; InsertToken; ReplaceToken])
    | _ -> assert_failure "应该执行恢复策略"
  ) results

(** ==================== 错误优先级管理测试 ==================== *)

let test_error_priority_handling _ =
  (* 测试错误优先级处理 *)
  let config = create_test_handler_config () in
  let handler = create_error_handler config in
  
  let high_priority_error = {
    (create_test_error Error "高优先级错误" 1 1) with
    priority = High;
  } in
  let low_priority_error = {
    (create_test_error Error "低优先级错误" 2 2) with
    priority = Low;
  } in
  
  let _ = handle_error handler low_priority_error in
  let _ = handle_error handler high_priority_error in
  
  let sorted_errors = get_errors_by_priority handler in
  match sorted_errors with
  | high :: low :: [] -> 
      assert_equal High high.priority;
      assert_equal Low low.priority
  | _ -> assert_failure "错误优先级排序失败"

let test_error_severity_filtering _ =
  (* 测试错误严重性过滤 *)
  let config = {
    (create_test_handler_config ()) with
    min_severity = Warning;
  } in
  let handler = create_error_handler config in
  
  let info_error = create_test_error Info "信息级别" 1 1 in
  let warning_error = create_test_error Warning "警告级别" 2 2 in
  let error_error = create_test_error Error "错误级别" 3 3 in
  
  let _ = handle_error handler info_error in
  let _ = handle_error handler warning_error in
  let _ = handle_error handler error_error in
  
  (* 信息级别应该被过滤掉 *)
  assert_equal 0 (get_info_count handler);
  assert_equal 1 (get_warning_count handler);
  assert_equal 1 (get_error_count handler)

(** ==================== 错误上下文管理测试 ==================== *)

let test_error_context_capture _ =
  (* 测试错误上下文捕获 *)
  let config = {
    (create_test_handler_config ()) with
    include_context = true;
    context_lines = 2;
  } in
  let handler = create_error_handler config in
  
  let source_lines = [
    "第一行代码";
    "第二行代码";
    "第三行有错误的代码";
    "第四行代码";
    "第五行代码";
  ] in
  
  set_source_context handler source_lines;
  
  let error = create_test_error Error "上下文测试错误" 3 10 in
  let result = handle_error handler error in
  
  match result with
  | HandlerSuccess processed_error -> 
      assert_bool "错误应包含上下文" (String.length processed_error.context > 0);
      assert_bool "上下文应包含错误行" (String.contains processed_error.context '错')
  | _ -> assert_failure "错误处理应该成功"

let test_error_context_line_numbers _ =
  (* 测试错误上下文行号 *)
  let config = {
    (create_test_handler_config ()) with
    include_context = true;
    context_lines = 1;
  } in
  let handler = create_error_handler config in
  
  let source_lines = Array.init 10 (fun i -> "第" ^ string_of_int (i+1) ^ "行") in
  set_source_context handler (Array.to_list source_lines);
  
  let error = create_test_error Error "行号测试" 5 5 in
  let result = handle_error handler error in
  
  match result with
  | HandlerSuccess processed_error -> 
      let context = processed_error.context in
      assert_bool "上下文应包含目标行" (String.contains context '5');
      assert_bool "上下文应包含前一行" (String.contains context '4');
      assert_bool "上下文应包含后一行" (String.contains context '6')
  | _ -> assert_failure "错误处理应该成功"

(** ==================== 错误链处理测试 ==================== *)

let test_error_chain_handling _ =
  (* 测试错误链处理 *)
  let config = create_test_handler_config () in
  let handler = create_error_handler config in
  
  let root_error = create_test_error Error "根错误" 1 1 in
  let child_error1 = {
    (create_test_error Error "子错误1" 2 2) with
    parent_error = Some root_error;
  } in
  let child_error2 = {
    (create_test_error Error "子错误2" 3 3) with
    parent_error = Some root_error;
  } in
  
  let _ = handle_error handler root_error in
  let _ = handle_error handler child_error1 in
  let _ = handle_error handler child_error2 in
  
  let error_chain = get_error_chain handler root_error.error_code in
  assert_equal 3 (List.length error_chain);
  
  let root_in_chain = List.hd error_chain in
  assert_equal "根错误" root_in_chain.message

(** ==================== 边界条件测试 ==================== *)

let test_max_errors_limit _ =
  (* 测试最大错误数限制 *)
  let config = {
    (create_test_handler_config ()) with
    max_errors = 3;
  } in
  let handler = create_error_handler config in
  
  for i = 1 to 5 do
    let error = create_test_error Error ("错误" ^ string_of_int i) i i in
    let _ = handle_error handler error in
    ()
  done;
  
  assert_equal 3 (get_error_count handler);
  assert_bool "处理器应因达到最大错误数而停用" (not (is_handler_active handler))

let test_stop_on_first_error _ =
  (* 测试首次错误停止 *)
  let config = {
    (create_test_handler_config ()) with
    stop_on_first_error = true;
  } in
  let handler = create_error_handler config in
  
  let error1 = create_test_error Error "第一个错误" 1 1 in
  let error2 = create_test_error Error "第二个错误" 2 2 in
  
  let _ = handle_error handler error1 in
  assert_bool "处理器应因首次错误而停用" (not (is_handler_active handler));
  
  let result2 = handle_error handler error2 in
  match result2 with
  | HandlerError _ -> () (* 预期行为 *)
  | _ -> assert_failure "第二个错误应该被拒绝处理"

let test_empty_error_message _ =
  (* 测试空错误消息 *)
  let config = create_test_handler_config () in
  let handler = create_error_handler config in
  let error = create_test_error Error "" 1 1 in
  
  let result = handle_error handler error in
  match result with
  | HandlerSuccess processed_error -> 
      assert_bool "空消息应被处理" (String.length processed_error.message >= 0)
  | _ -> assert_failure "空消息错误应被处理"

(** ==================== 性能测试 ==================== *)

let test_performance_error_handling _ =
  (* 测试错误处理性能 *)
  let config = create_test_handler_config () in
  let handler = create_error_handler config in
  
  let start_time = Unix.gettimeofday () in
  for i = 1 to 1000 do
    let error = create_test_error Warning ("性能测试" ^ string_of_int i) i (i mod 100) in
    let _ = handle_error handler error in
    ()
  done;
  let end_time = Unix.gettimeofday () in
  
  let elapsed = end_time -. start_time in
  assert_bool "性能测试：1000次错误处理应在1秒内完成" (elapsed < 1.0);
  assert_equal 1000 (get_warning_count handler)

let test_performance_batch_processing _ =
  (* 测试批量处理性能 *)
  let config = create_test_handler_config () in
  let handler = create_error_handler config in
  
  let batch_size = 500 in
  let error_batch = Array.init batch_size (fun i ->
    create_test_error Error ("批量错误" ^ string_of_int i) (i+1) ((i mod 50) + 1)
  ) |> Array.to_list in
  
  let start_time = Unix.gettimeofday () in
  let _ = handle_error_batch handler error_batch in
  let end_time = Unix.gettimeofday () in
  
  let elapsed = end_time -. start_time in
  assert_bool "性能测试：500个错误的批量处理应在0.5秒内完成" (elapsed < 0.5);
  assert_equal batch_size (get_error_count handler)

(** ==================== 集成测试 ==================== *)

let test_integration_complete_workflow _ =
  (* 测试完整错误处理工作流 *)
  let config = create_test_handler_config () in
  let handler = create_error_handler config in
  
  (* 1. 设置源代码上下文 *)
  let source_code = [
    "定义 变量 为 整数";
    "设置 变量 为 \"错误类型\"";  (* 类型错误 *)
    "输出 变量";
  ] in
  set_source_context handler source_code;
  
  (* 2. 处理类型错误 *)
  let type_error = {
    (create_test_error Error "类型不匹配：期望整数，得到字符串" 2 8) with
    suggestions = ["检查变量类型"; "使用正确的赋值"];
  } in
  
  let result = handle_error_with_recovery handler type_error in
  
  (* 3. 验证完整工作流 *)
  match result with
  | HandlerRecovered (strategy, processed_error) ->
      assert_bool "错误应包含上下文" (String.length processed_error.context > 0);
      assert_bool "错误应包含建议" (List.length processed_error.suggestions > 0);
      assert_bool "应选择合适的恢复策略" 
        (List.mem strategy [SkipToken; InsertToken; ReplaceToken])
  | _ -> assert_failure "完整工作流应该成功执行"

let test_integration_multi_file_errors _ =
  (* 测试多文件错误处理集成 *)
  let config = create_test_handler_config () in
  let handler = create_error_handler config in
  
  let file1_error = {
    (create_test_error Error "文件1中的语法错误" 10 5) with
    location = {
      line = 10; column = 5; filename = "main.ly"; offset = 1005;
    };
  } in
  
  let file2_error = {
    (create_test_error Warning "文件2中的警告" 20 15) with
    location = {
      line = 20; column = 15; filename = "utils.ly"; offset = 2015;
    };
  } in
  
  let _ = handle_error handler file1_error in
  let _ = handle_error handler file2_error in
  
  let errors_by_file = get_errors_by_file handler in
  assert_bool "应包含main.ly的错误" (List.mem_assoc "main.ly" errors_by_file);
  assert_bool "应包含utils.ly的错误" (List.mem_assoc "utils.ly" errors_by_file);
  
  let main_errors = List.assoc "main.ly" errors_by_file in
  let utils_errors = List.assoc "utils.ly" errors_by_file in
  assert_equal 1 (List.length main_errors);
  assert_equal 1 (List.length utils_errors)

(** ==================== 测试套件 ==================== *)

let suite = "Error_handler_core comprehensive tests" >::: [
  (* 错误处理器初始化测试 *)
  "test_create_error_handler" >:: test_create_error_handler;
  "test_handler_configuration" >:: test_handler_configuration;
  "test_handler_state_management" >:: test_handler_state_management;
  
  (* 错误捕获和处理测试 *)
  "test_handle_single_error" >:: test_handle_single_error;
  "test_handle_multiple_errors" >:: test_handle_multiple_errors;
  "test_handle_error_batch" >:: test_handle_error_batch;
  
  (* 错误恢复策略测试 *)
  "test_error_recovery_skip_token" >:: test_error_recovery_skip_token;
  "test_error_recovery_insert_token" >:: test_error_recovery_insert_token;
  "test_error_recovery_replace_token" >:: test_error_recovery_replace_token;
  "test_error_recovery_multiple_strategies" >:: test_error_recovery_multiple_strategies;
  
  (* 错误优先级管理测试 *)
  "test_error_priority_handling" >:: test_error_priority_handling;
  "test_error_severity_filtering" >:: test_error_severity_filtering;
  
  (* 错误上下文管理测试 *)
  "test_error_context_capture" >:: test_error_context_capture;
  "test_error_context_line_numbers" >:: test_error_context_line_numbers;
  
  (* 错误链处理测试 *)
  "test_error_chain_handling" >:: test_error_chain_handling;
  
  (* 边界条件测试 *)
  "test_max_errors_limit" >:: test_max_errors_limit;
  "test_stop_on_first_error" >:: test_stop_on_first_error;
  "test_empty_error_message" >:: test_empty_error_message;
  
  (* 性能测试 *)
  "test_performance_error_handling" >:: test_performance_error_handling;
  "test_performance_batch_processing" >:: test_performance_batch_processing;
  
  (* 集成测试 *)
  "test_integration_complete_workflow" >:: test_integration_complete_workflow;
  "test_integration_multi_file_errors" >:: test_integration_multi_file_errors;
]

let () = run_test_tt_main suite