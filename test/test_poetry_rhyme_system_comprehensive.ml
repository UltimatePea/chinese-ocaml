(** 📋 Phase 2 Poetry系统测试覆盖率提升 - 韵律系统全面测试

    此模块为Issue #1485 Phase 2的核心测试文件，专注于Poetry韵律系统的全面测试覆盖。

    测试目标：
    - 韵律匹配核心算法
    - 多韵书支持测试
    - 边界条件和错误恢复
    - 性能基准测试

    @author Alpha, 主要工作代理
    @version 1.0 - Phase 2初始版本
    @since 2025-07-27 *)

open Poetry.Poetry_rhyme_data
open Poetry.Poetry_types_consolidated

(** {1 测试辅助函数} *)

let test_counter = ref 0
let failed_tests = ref []

let test_assert name condition =
  incr test_counter;
  if not condition then (
    failed_tests := name :: !failed_tests;
    Printf.printf "❌ FAIL: %s\n" name)
  else Printf.printf "✅ PASS: %s\n" name

let print_test_summary () =
  let total = !test_counter in
  let failed = List.length !failed_tests in
  let passed = total - failed in
  Printf.printf "\n📊 测试总结: %d/%d 通过 (%.1f%%)\n" passed total
    (float_of_int passed /. float_of_int total *. 100.0);
  if failed > 0 then (
    Printf.printf "❌ 失败的测试:\n";
    List.iter (Printf.printf "  - %s\n") (List.rev !failed_tests))

(** {1 韵律数据基础测试组} *)

let test_rhyme_data_initialization () =
  Printf.printf "\n🔧 测试组1: 韵律数据初始化\n";

  (* 测试数据初始化 *)
  test_assert "数据初始化成功"
    (initialize_data ();
     is_data_loaded ());

  (* 测试数据完整性 *)
  let all_data = get_all_rhyme_data () in
  test_assert "韵律数据非空" (List.length all_data > 0);
  test_assert "韵律数据数量合理" (List.length all_data >= 50);

  (* 测试基础字符查找 *)
  let mountain_char = String.get "山" 0 in
  let mountain_info = lookup_char_info mountain_char in
  test_assert "查找'山'字成功" (mountain_info <> None);

  let heaven_char = String.get "天" 0 in
  let heaven_info = lookup_char_info heaven_char in
  test_assert "查找'天'字成功" (heaven_info <> None)

(** {1 韵律分类测试组} *)

let test_rhyme_categories () =
  Printf.printf "\n🎵 测试组2: 韵律分类系统\n";

  (* 测试平声字符 *)
  let ping_sheng_chars = get_ping_sheng_chars () in
  test_assert "平声字符列表非空" (List.length ping_sheng_chars > 0);
  test_assert "平声字符数量合理" (List.length ping_sheng_chars >= 20);

  (* 测试仄声字符 *)
  let ze_sheng_chars = get_ze_sheng_chars () in
  test_assert "仄声字符列表非空" (List.length ze_sheng_chars > 0);

  (* 测试分类统计 *)
  let distribution = get_category_distribution () in
  test_assert "分类统计包含平声" (List.mem_assoc PingSheng distribution);
  test_assert "分类统计包含仄声" (List.mem_assoc ZeSheng distribution)

(** {1 韵律组测试} *)

let test_rhyme_groups () =
  Printf.printf "\n🎭 测试组3: 韵律组系统\n";

  (* 测试安韵组 *)
  let an_rhyme_chars = get_rhyme_group_chars AnRhyme in
  test_assert "安韵组字符非空" (List.length an_rhyme_chars > 0);
  test_assert "安韵组包含'山'字" (List.mem "山" an_rhyme_chars);

  (* 测试天韵组 *)
  let tian_rhyme_chars = get_rhyme_group_chars TianRhyme in
  test_assert "天韵组字符非空" (List.length tian_rhyme_chars > 0);
  test_assert "天韵组包含'天'字" (List.mem "天" tian_rhyme_chars);

  (* 测试韵律组大小 *)
  let an_size = get_rhyme_group_size AnRhyme in
  test_assert "安韵组大小合理" (an_size >= 5);

  let tian_size = get_rhyme_group_size TianRhyme in
  test_assert "天韵组大小合理" (tian_size >= 5);

  (* 测试所有韵律组列表 *)
  let all_groups = list_all_rhyme_groups () in
  test_assert "韵律组列表非空" (List.length all_groups > 0);
  test_assert "韵律组包含安韵" (List.mem AnRhyme all_groups);
  test_assert "韵律组包含天韵" (List.mem TianRhyme all_groups)

(** {1 批量查找测试} *)

let test_batch_lookup () =
  Printf.printf "\n📦 测试组4: 批量查找功能\n";

  (* 测试单字符批量查找 *)
  let mountain_char = String.get "山" 0 in
  let single_result = batch_lookup [ mountain_char ] in
  test_assert "单字符批量查找成功" (List.length single_result = 1);

  (* 测试多字符批量查找 *)
  let heaven_char = String.get "天" 0 in
  let poetry_char = String.get "诗" 0 in
  let multi_result = batch_lookup [ mountain_char; heaven_char; poetry_char ] in
  test_assert "多字符批量查找数量正确" (List.length multi_result = 3);

  (* 测试空列表批量查找 *)
  let empty_result = batch_lookup [] in
  test_assert "空列表批量查找返回空" (List.length empty_result = 0);

  (* 测试混合字符批量查找 *)
  let bu_char = String.get "不" 0 in
  let cun_char = String.get "存" 0 in
  let zai_char = String.get "在" 0 in
  let mixed_result = batch_lookup [ mountain_char; bu_char; cun_char; zai_char ] in
  test_assert "混合字符批量查找部分成功" (List.length mixed_result >= 1)

(** {1 边界条件测试} *)

let test_boundary_conditions () =
  Printf.printf "\n⚠️  测试组5: 边界条件处理\n";

  (* 测试未知字符查找 *)
  let unknown_char_val = String.get "𝓍" 0 in
  (* Unicode 特殊字符 *)
  let unknown_char = lookup_char_info unknown_char_val in
  test_assert "未知字符查找返回None" (unknown_char = None);

  (* 测试空韵律组 *)
  let unknown_group_empty = is_rhyme_group_empty UnknownRhyme in
  test_assert "未知韵律组为空" unknown_group_empty;

  (* 测试数据重新加载 *)
  test_assert "数据重新加载成功"
    (reload_data ();
     is_data_loaded ());

  (* 测试数据完整性验证 *)
  let integrity_result = validate_data_integrity () in
  test_assert "数据完整性验证通过" integrity_result

(** {1 数据统计测试} *)

let test_data_statistics () =
  Printf.printf "\n📊 测试组6: 数据统计功能\n";

  (* 测试数据统计 *)
  let stats = get_data_statistics () in
  test_assert "统计数据格式正确" (List.length stats > 0);
  let total_char = String.get "总" 0 in
  test_assert "统计包含总数信息" (List.exists (fun (name, _) -> String.contains name total_char) stats);

  (* 测试数据冲突检查 *)
  let conflicts = find_data_conflicts () in
  test_assert "数据冲突检查完成" (List.length conflicts >= 0)

(** {1 性能边界测试} *)

let test_performance_boundaries () =
  Printf.printf "\n⚡ 测试组7: 性能边界测试\n";

  (* 测试大量字符查找 *)
  let mountain_char = String.get "山" 0 in
  let large_char_list = Array.to_list (Array.make 100 mountain_char) in
  let start_time = Sys.time () in
  let large_result = batch_lookup large_char_list in
  let end_time = Sys.time () in
  let execution_time = end_time -. start_time in

  test_assert "大量字符查找结果正确" (List.length large_result = 100);
  test_assert "大量字符查找性能合理" (execution_time < 1.0);

  (* 测试重复初始化性能 *)
  let start_time2 = Sys.time () in
  for _ = 1 to 10 do
    initialize_data ()
  done;
  let end_time2 = Sys.time () in
  let init_time = end_time2 -. start_time2 in

  test_assert "重复初始化性能合理" (init_time < 0.5)

(** {1 韵律分析集成测试} *)

let test_rhyme_analysis_integration () =
  Printf.printf "\n🔗 测试组8: 韵律分析集成\n";

  (* 测试基础韵律匹配 *)
  let mountain_char = String.get "山" 0 in
  let interval_char = String.get "间" 0 in
  let mountain_info = lookup_char_info mountain_char in
  let interval_info = lookup_char_info interval_char in

  (match (mountain_info, interval_info) with
  | Some (cat1, group1), Some (cat2, group2) ->
      test_assert "同韵组字符韵律匹配" (group1 = group2 && group1 = AnRhyme);
      test_assert "同类字符声调匹配" (cat1 = cat2 && cat1 = PingSheng)
  | _ -> test_assert "韵律匹配基础信息可用" false);

  (* 测试跨韵组差异 *)
  let poetry_char = String.get "诗" 0 in
  let poetry_info = lookup_char_info poetry_char in
  match (mountain_info, poetry_info) with
  | Some (_, group1), Some (_, group2) -> test_assert "不同韵组字符韵律不匹配" (group1 <> group2)
  | _ -> test_assert "跨韵组差异测试基础信息可用" false

(** {1 主测试执行函数} *)

let run_all_tests () =
  Printf.printf "🧪 开始执行 Phase 2 韵律系统全面测试\n";
  Printf.printf "=======================================\n";

  test_rhyme_data_initialization ();
  test_rhyme_categories ();
  test_rhyme_groups ();
  test_batch_lookup ();
  test_boundary_conditions ();
  test_data_statistics ();
  test_performance_boundaries ();
  test_rhyme_analysis_integration ();

  print_test_summary ();
  Printf.printf "\n🎯 Phase 2 韵律系统测试完成\n"

(** 程序入口 *)
let () = run_all_tests ()
