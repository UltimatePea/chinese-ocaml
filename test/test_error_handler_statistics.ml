(** 错误统计模块测试套件
    
    验证error_handler_statistics.ml模块的错误统计和记录功能
    包括统计更新、历史记录、报告生成和系统初始化
    
    创建目的：提升错误处理模块测试覆盖率至60%以上 Fix #925 第二阶段 *)

open Alcotest
open Yyocamlc_lib.Error_handler_statistics
open Yyocamlc_lib.Compiler_errors
open Yyocamlc_lib.Error_handler_types

(** 测试辅助函数 *)
let create_test_position () = 
  { filename = "测试文件.ly"; line = 10; column = 5 }

let create_test_context () =
  create_context ~source_file:"test.ly" ~function_name:"test_func" 
    ~module_name:"Test" ~call_stack:["main"; "test_func"] ()

let create_error_by_severity severity msg =
  let pos = create_test_position () in
  make_error_info ~severity (SyntaxError (msg, pos))

let create_enhanced_error_by_severity severity msg =
  let context = create_test_context () in
  let base_error = create_error_by_severity severity msg in
  create_enhanced_error base_error context

(** 测试统计初始化和重置 *)
let test_statistics_initialization () =
  Printf.printf "测试统计初始化和重置功能...\n";
  
  (* 初始化统计系统 *)
  init_statistics ();
  
  (* 检查初始状态 *)
  check (int) "初始化后总错误数应为0" 0 global_stats.total_errors;
  check (int) "初始化后警告数应为0" 0 global_stats.warnings;
  check (int) "初始化后错误数应为0" 0 global_stats.errors;
  check (int) "初始化后严重错误数应为0" 0 global_stats.fatal_errors;
  check (int) "初始化后已恢复错误数应为0" 0 global_stats.recovered_errors;
  
  (* 验证开始时间设置 *)
  let current_time = Unix.time () in
  check (bool) "开始时间应该在合理范围内" true
    (abs_float (current_time -. global_stats.start_time) < 1.0);
  
  Printf.printf "统计初始化和重置测试完成\n"

(** 测试警告统计更新 *)
let test_warning_statistics () =
  Printf.printf "测试警告统计更新功能...\n";
  
  (* 重置统计 *)
  reset_statistics ();
  
  (* 创建警告错误 *)
  let warning_error = create_enhanced_error_by_severity Warning "这是一个警告" in
  
  (* 更新统计 *)
  update_statistics warning_error;
  
  (* 验证统计更新 *)
  check (int) "处理警告后总错误数应为1" 1 global_stats.total_errors;
  check (int) "处理警告后警告数应为1" 1 global_stats.warnings;
  check (int) "处理警告后错误数应为0" 0 global_stats.errors;
  check (int) "处理警告后严重错误数应为0" 0 global_stats.fatal_errors;
  
  Printf.printf "警告统计更新测试完成\n"

(** 测试普通错误统计更新 *)
let test_error_statistics () =
  Printf.printf "测试普通错误统计更新功能...\n";
  
  (* 重置统计 *)
  reset_statistics ();
  
  (* 创建普通错误 *)
  let normal_error = create_enhanced_error_by_severity Error "这是一个普通错误" in
  
  (* 更新统计 *)
  update_statistics normal_error;
  
  (* 验证统计更新 *)
  check (int) "处理普通错误后总错误数应为1" 1 global_stats.total_errors;
  check (int) "处理普通错误后警告数应为0" 0 global_stats.warnings;
  check (int) "处理普通错误后错误数应为1" 1 global_stats.errors;
  check (int) "处理普通错误后严重错误数应为0" 0 global_stats.fatal_errors;
  
  Printf.printf "普通错误统计更新测试完成\n"

(** 测试严重错误统计更新 *)
let test_fatal_error_statistics () =
  Printf.printf "测试严重错误统计更新功能...\n";
  
  (* 重置统计 *)
  reset_statistics ();
  
  (* 创建严重错误 *)
  let fatal_error = create_enhanced_error_by_severity Fatal "这是一个严重错误" in
  
  (* 更新统计 *)
  update_statistics fatal_error;
  
  (* 验证统计更新 *)
  check (int) "处理严重错误后总错误数应为1" 1 global_stats.total_errors;
  check (int) "处理严重错误后警告数应为0" 0 global_stats.warnings;
  check (int) "处理严重错误后错误数应为0" 0 global_stats.errors;
  check (int) "处理严重错误后严重错误数应为1" 1 global_stats.fatal_errors;
  
  Printf.printf "严重错误统计更新测试完成\n"

(** 测试混合错误统计更新 *)
let test_mixed_error_statistics () =
  Printf.printf "测试混合错误统计更新功能...\n";
  
  (* 重置统计 *)
  reset_statistics ();
  
  (* 创建不同类型的错误 *)
  let warning1 = create_enhanced_error_by_severity Warning "警告1" in
  let warning2 = create_enhanced_error_by_severity Warning "警告2" in
  let error1 = create_enhanced_error_by_severity Error "错误1" in
  let error2 = create_enhanced_error_by_severity Error "错误2" in
  let error3 = create_enhanced_error_by_severity Error "错误3" in
  let fatal = create_enhanced_error_by_severity Fatal "严重错误" in
  
  (* 更新统计 *)
  update_statistics warning1;
  update_statistics warning2;
  update_statistics error1;
  update_statistics error2;
  update_statistics error3;
  update_statistics fatal;
  
  (* 验证统计更新 *)
  check (int) "处理混合错误后总错误数应为6" 6 global_stats.total_errors;
  check (int) "处理混合错误后警告数应为2" 2 global_stats.warnings;
  check (int) "处理混合错误后错误数应为3" 3 global_stats.errors;
  check (int) "处理混合错误后严重错误数应为1" 1 global_stats.fatal_errors;
  
  Printf.printf "混合错误统计更新测试完成\n"

(** 测试错误历史记录功能 *)
let test_error_history_recording () =
  Printf.printf "测试错误历史记录功能...\n";
  
  (* 重置统计 *)
  reset_statistics ();
  
  (* 创建测试错误 *)
  let error1 = create_enhanced_error_by_severity Error "历史错误1" in
  let error2 = create_enhanced_error_by_severity Warning "历史错误2" in
  let error3 = create_enhanced_error_by_severity Fatal "历史错误3" in
  
  (* 记录错误到历史 *)
  record_error error1;
  record_error error2;
  record_error error3;
  
  (* 检查历史记录长度 *)
  let history_length = List.length !error_history in
  check (int) "错误历史记录数量应为3" 3 history_length;
  
  (* 检查最新错误是否在历史记录开头 *)
  let latest_error = List.hd !error_history in
  check (bool) "最新错误应该在历史记录开头" true
    (latest_error.base_error.message = "历史错误3");
  
  Printf.printf "错误历史记录测试完成\n"

(** 测试历史记录大小限制 *)
let test_history_size_limit () =
  Printf.printf "测试历史记录大小限制功能...\n";
  
  (* 重置统计 *)
  reset_statistics ();
  
  (* 设置较小的历史记录限制进行测试 *)
  max_history_size := 3;
  
  (* 记录超过限制数量的错误 *)
  for i = 1 to 5 do
    let error = create_enhanced_error_by_severity Error ("历史错误" ^ string_of_int i) in
    record_error error
  done;
  
  (* 检查历史记录长度是否被限制 *)
  let history_length = List.length !error_history in
  check (int) "历史记录长度应被限制为3" 3 history_length;
  
  (* 检查保留的是最新的错误 *)
  let latest_error = List.hd !error_history in
  check (bool) "应该保留最新的错误" true
    (latest_error.base_error.message = "历史错误5");
  
  Printf.printf "历史记录大小限制测试完成\n"

(** 测试错误报告生成 *)
let test_error_report_generation () =
  Printf.printf "测试错误报告生成功能...\n";
  
  (* 重置统计 *)
  reset_statistics ();
  
  (* 添加一些统计数据 *)
  let warning = create_enhanced_error_by_severity Warning "测试警告" in
  let error = create_enhanced_error_by_severity Error "测试错误" in
  let fatal = create_enhanced_error_by_severity Fatal "测试严重错误" in
  
  update_statistics warning;
  update_statistics error;
  update_statistics fatal;
  
  (* 模拟一些恢复的错误 *)
  global_stats.recovered_errors <- 1;
  
  (* 生成报告 *)
  let report = get_error_report () in
  
  (* 检查报告内容 *)
  check (bool) "报告应包含总错误数" true (String.contains report '3');
  check (bool) "报告应包含警告数" true (String.contains report '1');
  check (bool) "报告应包含错误数" true (String.contains report '1');
  check (bool) "报告应包含严重错误数" true (String.contains report '1');
  check (bool) "报告应包含已恢复错误数" true (String.contains report '1');
  check (bool) "报告应包含处理时间" true (Str.search_forward (Str.regexp "处理时间") report 0 >= 0);
  
  Printf.printf "错误报告生成测试完成\n"

(** 测试统计重置功能 *)
let test_statistics_reset () =
  Printf.printf "测试统计重置功能...\n";
  
  (* 添加一些统计数据 *)
  let error = create_enhanced_error_by_severity Error "测试错误" in
  update_statistics error;
  global_stats.recovered_errors <- 5;
  record_error error;
  
  (* 检查数据确实存在 *)
  check (bool) "重置前应有统计数据" true (global_stats.total_errors > 0);
  check (bool) "重置前应有历史记录" true (List.length !error_history > 0);
  
  (* 执行重置 *)
  reset_statistics ();
  
  (* 检查重置结果 *)
  check (int) "重置后总错误数应为0" 0 global_stats.total_errors;
  check (int) "重置后警告数应为0" 0 global_stats.warnings;
  check (int) "重置后错误数应为0" 0 global_stats.errors;
  check (int) "重置后严重错误数应为0" 0 global_stats.fatal_errors;
  check (int) "重置后已恢复错误数应为0" 0 global_stats.recovered_errors;
  check (int) "重置后历史记录应为空" 0 (List.length !error_history);
  
  Printf.printf "统计重置测试完成\n"

(** 测试边界条件和异常情况 *)
let test_edge_cases () =
  Printf.printf "测试边界条件和异常情况...\n";
  
  (* 重置统计 *)
  reset_statistics ();
  
  (* 测试大量错误处理 *)
  for i = 1 to 50 do
    let error = create_enhanced_error_by_severity Error ("大量错误" ^ string_of_int i) in
    update_statistics error
  done;
  
  check (int) "大量错误处理后总错误数应为50" 50 global_stats.total_errors;
  check (int) "大量错误处理后错误数应为50" 50 global_stats.errors;
  
  (* 测试历史记录设置为0的情况 *)
  max_history_size := 0;
  let test_error = create_enhanced_error_by_severity Warning "零大小历史测试" in
  record_error test_error;
  check (int) "历史记录大小为0时应该为空" 0 (List.length !error_history);
  
  (* 恢复默认历史大小 *)
  max_history_size := 100;
  
  Printf.printf "边界条件和异常情况测试完成\n"

(** 错误统计模块测试套件 *)
let () =
  run "Error_handler_statistics模块测试" [
    ("统计初始化", [ test_case "初始化和重置" `Quick test_statistics_initialization ]);
    ("警告统计", [ test_case "警告统计更新" `Quick test_warning_statistics ]);
    ("错误统计", [ test_case "普通错误统计更新" `Quick test_error_statistics ]);
    ("严重错误统计", [ test_case "严重错误统计更新" `Quick test_fatal_error_statistics ]);
    ("混合错误统计", [ test_case "混合错误统计更新" `Quick test_mixed_error_statistics ]);
    ("历史记录", [ test_case "错误历史记录" `Quick test_error_history_recording ]);
    ("历史大小限制", [ test_case "历史记录大小限制" `Quick test_history_size_limit ]);
    ("报告生成", [ test_case "错误报告生成" `Quick test_error_report_generation ]);
    ("统计重置", [ test_case "统计重置功能" `Quick test_statistics_reset ]);
    ("边界条件", [ test_case "边界和异常情况" `Quick test_edge_cases ]);
  ]