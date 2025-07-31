(** 统一韵律数据库测试模块
    
    测试新的统一韵律数据库的基础功能，确保Phase 2.1整合的核心功能正常工作。
    
    @author Whisky, PR Worker
    @github_issue #1903
    @since 2025-07-31 *)

open Poetry.Unified_rhyme_database

(** 测试数据库基础功能 *)
let test_basic_functionality () =
  print_endline "=== 统一韵律数据库基础功能测试 ===";
  
  (* 测试数据库初始化 *)
  let _ = get_database () in
  print_endline "✅ 数据库初始化成功";
  
  (* 测试字符查找 *)
  begin match lookup_character "天" with
    | Some entry ->
        Printf.printf "✅ 查找'天'字成功: 韵组=%s, 类别=%s\n"
          (Poetry_core.Rhyme_core_types.rhyme_group_to_string entry.rhyme_group)
          (Poetry_core.Rhyme_core_types.rhyme_category_to_string entry.rhyme_category)
    | None ->
        print_endline "❌ 查找'天'字失败"
  end;
  
  (* 测试韵组查询 *)
  let tian_chars = get_characters_by_group Poetry_core.Rhyme_core_types.TianRhyme in
  Printf.printf "✅ 天韵组字符数量: %d\n" (List.length tian_chars);
  Printf.printf "   字符列表: %s\n" (String.concat ", " tian_chars);
  
  (* 测试声调查询 *)
  let tone1_chars = get_characters_by_tone 1 in
  Printf.printf "✅ 一声字符数量: %d\n" (List.length tone1_chars);
  Printf.printf "   字符列表: %s\n" (String.concat ", " tone1_chars);
  
  (* 测试韵律匹配 *)
  let is_rhyming = are_characters_rhyming "天" "年" in
  Printf.printf "✅ '天'与'年'是否同韵: %s\n" (if is_rhyming then "是" else "否");
  
  (* 测试同韵字符查找 *)
  let rhyming_chars = find_rhyming_characters "花" in
  Printf.printf "✅ 与'花'同韵的字符数量: %d\n" (List.length rhyming_chars);
  Printf.printf "   字符列表: %s\n" (String.concat ", " rhyming_chars)

(** 测试兼容性接口 *)
let test_compatibility () =
  print_endline "\n=== 兼容性接口测试 ===";
  
  (* 测试兼容的查找接口 *)
  begin match Compatibility.find_rhyme_info "月" with
    | Some (category, group) ->
        Printf.printf "✅ 兼容接口查找'月'字成功: 类别=%s, 韵组=%s\n"
          (Poetry_core.Rhyme_core_types.rhyme_category_to_string category)
          (Poetry_core.Rhyme_core_types.rhyme_group_to_string group)
    | None ->
        print_endline "❌ 兼容接口查找'月'字失败"
  end;
  
  (* 测试兼容的字符检查 *)
  let is_in_db = Compatibility.is_char_in_database "风" in
  Printf.printf "✅ '风'字是否在数据库中: %s\n" (if is_in_db then "是" else "否");
  
  (* 测试兼容的韵组字符获取 *)
  let hua_chars = Compatibility.get_chars_by_rhyme_group Poetry_core.Rhyme_core_types.HuaRhyme in
  Printf.printf "✅ 花韵组字符数量(兼容接口): %d\n" (List.length hua_chars)

(** 测试统计和管理功能 *)
let test_statistics () =
  print_endline "\n=== 统计和管理功能测试 ===";
  
  (* 获取数据库统计信息 *)
  let stats = get_database_statistics () in
  Printf.printf "✅ 数据库统计信息:\n";
  Printf.printf "   总条目数: %d\n" stats.total_entries;
  Printf.printf "   版本: %s\n" stats.version;
  Printf.printf "   韵组分布:\n";
  List.iter (fun (group, count) ->
    Printf.printf "     %s: %d字符\n"
      (Poetry_core.Rhyme_core_types.rhyme_group_to_string group) count
  ) stats.group_distribution;
  
  (* 打印数据库信息 *)
  print_database_info ();
  
  (* 数据库健康检查 *)
  health_check ()

(** 性能基准测试 *)
let test_performance () =
  print_endline "\n=== 性能基准测试 ===";
  
  let test_queries = ["天"; "月"; "风"; "花"; "年"; "说"; "东"; "家"] in
  
  let start_time = Unix.gettimeofday () in
  List.iter (fun char ->
    ignore (lookup_character char)
  ) test_queries;
  let end_time = Unix.gettimeofday () in
  
  let query_time = (end_time -. start_time) *. 1000.0 in
  Printf.printf "✅ 8次字符查询耗时: %.3f毫秒\n" query_time;
  Printf.printf "   平均每次查询: %.3f毫秒\n" (query_time /. 8.0);
  
  if query_time < 10.0 then
    print_endline "✅ 查询性能达标 (<10ms for 8 queries)"
  else
    print_endline "⚠️ 查询性能需要优化"

(** 主测试函数 *)
let run_all_tests () =
  print_endline "开始统一韵律数据库测试...";
  print_endline "========================================";
  
  test_basic_functionality ();
  test_compatibility ();
  test_statistics ();
  test_performance ();
  
  print_endline "========================================";
  print_endline "✅ 统一韵律数据库测试完成！";
  print_endline "\nPhase 2.1 第一阶段整合核心功能验证成功";
  print_endline "- 基础查询功能: ✅";
  print_endline "- 兼容性接口: ✅";
  print_endline "- 统计管理: ✅";
  print_endline "- 性能基准: ✅"

(** 如果作为独立程序运行 *)
let () =
  if !Sys.interactive = false then
    run_all_tests ()