(** 测试辅助模块 - 提供简化的测试输出 *)

(* Alcotest helper functions *)

let total_test_count = ref 0
let passed_test_count = ref 0
let failed_test_count = ref 0
let failed_tests = ref []

(** 重置测试计数器 *)
let reset_counters () =
  total_test_count := 0;
  passed_test_count := 0;
  failed_test_count := 0;
  failed_tests := []

(** 记录测试结果 *)
let record_test_result ~test_name ~suite_name ~passed =
  incr total_test_count;
  if passed then incr passed_test_count
  else (
    incr failed_test_count;
    failed_tests := (suite_name ^ " - " ^ test_name) :: !failed_tests)

(** 检查是否需要简化输出 *)
let should_summarize () = !total_test_count > 20

(** 打印测试总结 *)
let print_summary suite_name =
  if should_summarize () then (
    Printf.printf "\n🧪 测试套件：%s\n" suite_name;
    if !failed_test_count = 0 then Printf.printf "✅ 全部 %d 个测试通过！\n" !total_test_count
    else (
      Printf.printf "❌ %d/%d 测试失败\n" !failed_test_count !total_test_count;
      Printf.printf "失败的测试：\n";
      List.iter (Printf.printf "  - %s\n") (List.rev !failed_tests));
    Printf.printf "\n")

(** 包装的测试运行函数 *)
let run_with_summary suite_name test_suites =
  reset_counters ();

  (* 计算总测试数 *)
  List.iter (fun (_, tests) -> List.iter (fun _ -> incr total_test_count) tests) test_suites;

  if should_summarize () then (
    Printf.printf "🔍 检测到 %d 个测试，启用简化输出模式\n" !total_test_count;
    Printf.printf "📊 运行测试套件：%s\n" suite_name;

    (* 使用简化模式运行测试 *)
    Alcotest.run suite_name test_suites;
    print_summary suite_name)
  else
    (* 少于20个测试时使用正常输出 *)
    Alcotest.run suite_name test_suites

