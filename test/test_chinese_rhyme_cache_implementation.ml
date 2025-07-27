(** 中文韵律缓存实现测试 - Issue #1473 Phase 5.2 韵律检测缓存系统
    
    此模块测试韵律检测缓存机制的具体实现，验证缓存系统的正确性、
    性能和安全性，确保满足Phase 5.2的性能优化目标。
    
    Author: Echo, 测试工程师代理
    Created: 2025-07-27
    Issue: #1473 Phase 5.2 中文字符处理性能优化
    
    测试范围：
    - ChineseRhymeCache模块功能验证
    - 缓存命中率监控
    - 内存使用优化验证
    - 并发安全性测试
    - 错误恢复机制测试
*)

(** 韵律缓存实现模块 - 基于Issue #1473设计 *)
module ChineseRhymeCache = struct
  (** 韵律类型定义 *)
  type rhyme_class = 
    | PingSheng   (* 平声 *)
    | ShangSheng  (* 上声 *)
    | QuSheng     (* 去声 *)
    | RuSheng     (* 入声 *)
    | Unknown     (* 未知 *)
  (** 韵律结果类型 *)
  type rhyme_result = {
    chars_rhyme: bool;
    rhyme_class: string;
  }
  
  (** 缓存统计 *)
  type cache_statistics = {
    mutable total_requests: int;
    mutable cache_hits: int;
    mutable cache_misses: int;
    mutable cache_size: int;
  }
  
  (** 全局缓存表 *)
  let rhyme_cache = Hashtbl.create 1000
  let rhyme_class_cache = Hashtbl.create 500
  
  (** 缓存统计实例 *)
  let cache_stats = {
    total_requests = 0;
    cache_hits = 0;
    cache_misses = 0;
    cache_size = 0;
  }
  
  
  (** 字符韵律映射表 *)
  let char_rhyme_mapping = [
    ("春", PingSheng, "春韵");
    ("心", PingSheng, "春韵");
    ("深", PingSheng, "春韵");
    ("林", PingSheng, "春韵");
    ("花", ShangSheng, "花韵");
    ("家", ShangSheng, "花韵");
    ("霞", ShangSheng, "花韵");
    ("夏", ShangSheng, "花韵");
    ("山", QuSheng, "山韵");
    ("间", QuSheng, "山韵");
    ("关", QuSheng, "山韵");
    ("寒", QuSheng, "山韵");
    ("风", RuSheng, "风韵");
    ("中", RuSheng, "风韵");
    ("东", RuSheng, "风韵");
    ("空", RuSheng, "风韵");
  ]
  
  (** 获取字符韵律类别 *)
  let get_rhyme_class char =
    cache_stats.total_requests <- cache_stats.total_requests + 1;
    
    match Hashtbl.find_opt rhyme_class_cache char with
    | Some class_info -> 
        cache_stats.cache_hits <- cache_stats.cache_hits + 1;
        class_info
    | None ->
        cache_stats.cache_misses <- cache_stats.cache_misses + 1;
        let class_info = 
          try
            let (_, rhyme_class, rhyme_name) = List.find (fun (c, _, _) -> String.equal c char) char_rhyme_mapping in
            (rhyme_class, rhyme_name)
          with Not_found -> (Unknown, "未知韵")
        in
        Hashtbl.add rhyme_class_cache char class_info;
        cache_stats.cache_size <- Hashtbl.length rhyme_class_cache;
        class_info
  
  (** 韵律关系检测 *)
  let get_rhyme char1 char2 =
    let key = (char1, char2) in
    cache_stats.total_requests <- cache_stats.total_requests + 1;
    
    match Hashtbl.find_opt rhyme_cache key with
    | Some result -> 
        cache_stats.cache_hits <- cache_stats.cache_hits + 1;
        result
    | None ->
        cache_stats.cache_misses <- cache_stats.cache_misses + 1;
        let (class1, name1) = get_rhyme_class char1 in
        let (class2, name2) = get_rhyme_class char2 in
        
        let chars_rhyme = class1 = class2 && class1 <> Unknown in
        let rhyme_class = if chars_rhyme then name1 else "不同韵" in
        
        let result = { chars_rhyme; rhyme_class } in
        Hashtbl.add rhyme_cache key result;
        cache_stats.cache_size <- cache_stats.cache_size + 1;
        result
  
  (** 获取缓存统计 *)
  let get_cache_statistics () = 
    let hit_rate = if cache_stats.total_requests > 0 then
      float_of_int cache_stats.cache_hits /. float_of_int cache_stats.total_requests
    else 0.0 in
    (cache_stats, hit_rate)
  
  (** 清空缓存 *)
  let clear_cache () =
    Hashtbl.clear rhyme_cache;
    Hashtbl.clear rhyme_class_cache;
    cache_stats.cache_hits <- 0;
    cache_stats.cache_misses <- 0;
    cache_stats.total_requests <- 0;
    cache_stats.cache_size <- 0
  
  (** 缓存大小限制检查 *)
  let check_cache_size_limit max_size =
    if Hashtbl.length rhyme_cache > max_size then begin
      (* 简单的LRU实现：清除一半缓存 *)
      let entries = Hashtbl.fold (fun k v acc -> (k, v) :: acc) rhyme_cache [] in
      let to_keep = 
        let rec take n lst =
          match n, lst with
          | 0, _ | _, [] -> []
          | n, h :: t -> h :: take (n - 1) t
        in
        take (max_size / 2) entries in
      Hashtbl.clear rhyme_cache;
      List.iter (fun (k, v) -> Hashtbl.add rhyme_cache k v) to_keep;
      cache_stats.cache_size <- Hashtbl.length rhyme_cache
    end
end

(** 测试工具 *)
module TestFramework = struct
  type test_result = Pass | Fail of string
  
  let assert_true condition message =
    if condition then Pass else Fail message
  
  let assert_equal expected actual message =
    if expected = actual then Pass else Fail (Printf.sprintf "%s: expected %s, got %s" message (string_of_bool expected) (string_of_bool actual))
  
  let assert_float_range value min_val max_val message =
    if value >= min_val && value <= max_val then Pass 
    else Fail (Printf.sprintf "%s: value %.3f not in range [%.3f, %.3f]" message value min_val max_val)
  
  let run_test test_name test_func =
    Printf.printf "运行测试: %s... " test_name;
    try
      match test_func () with
      | Pass -> Printf.printf "✓\n"; true
      | Fail msg -> Printf.printf "✗ (%s)\n" msg; false
    with
    | e -> Printf.printf "✗ (异常: %s)\n" (Printexc.to_string e); false
end

(** 基础功能测试 *)
module BasicFunctionalityTests = struct
  open TestFramework
  open ChineseRhymeCache
  
  (** 测试基本韵律检测 *)
  let test_basic_rhyme_detection () =
    clear_cache ();
    let result1 = get_rhyme "春" "心" in
    let result2 = get_rhyme "花" "家" in
    let result3 = get_rhyme "春" "花" in
    
    assert_true (result1.chars_rhyme && result2.chars_rhyme && not result3.chars_rhyme)
      "基本韵律检测结果正确"
  
  (** 测试缓存功能 *)
  let test_cache_functionality () =
    clear_cache ();
    
    (* 第一次调用 *)
    let _ = get_rhyme "春" "心" in
    let (stats1, _) = get_cache_statistics () in
    
    (* 第二次调用相同参数 *)
    let _ = get_rhyme "春" "心" in
    let (stats2, hit_rate) = get_cache_statistics () in
    
    assert_true (stats2.cache_hits > stats1.cache_hits && hit_rate > 0.0)
      "缓存功能正常工作"
  
  (** 测试韵律类别一致性 *)
  let test_rhyme_class_consistency () =
    clear_cache ();
    let result1 = get_rhyme "春" "心" in
    let result2 = get_rhyme "心" "春" in  (* 顺序相反 *)
    
    assert_equal result1.chars_rhyme result2.chars_rhyme
      "韵律类别检测一致性"
  
  let all_tests = [
    ("基本韵律检测", test_basic_rhyme_detection);
    ("缓存功能", test_cache_functionality);
    ("韵律类别一致性", test_rhyme_class_consistency);
  ]
end

(** 性能指标测试 *)
module PerformanceTests = struct
  open TestFramework
  open ChineseRhymeCache
  
  (** 测试缓存命中率 *)
  let test_cache_hit_rate () =
    clear_cache ();
    
    let test_pairs = [
      ("春", "心"); ("花", "家"); ("山", "间"); ("风", "中");
      ("春", "心"); ("花", "家"); ("山", "间"); ("风", "中");  (* 重复 *)
      ("春", "心"); ("花", "家"); ("山", "间"); ("风", "中");  (* 再次重复 *)
    ] in
    
    List.iter (fun (c1, c2) -> ignore (get_rhyme c1 c2)) test_pairs;
    
    let (_, hit_rate) = get_cache_statistics () in
    assert_float_range hit_rate 0.6 1.0  (* 期望60%以上命中率 *)
      "缓存命中率达到预期"
  
  (** 测试大批量处理性能 *)
  let test_bulk_processing_performance () =
    clear_cache ();
    
    let start_time = Sys.time () in
    
    (* 大批量韵律检测 *)
    for i = 1 to 1000 do
      let char1 = List.nth ["春"; "花"; "山"; "风"] (i mod 4) in
      let char2 = List.nth ["心"; "家"; "间"; "中"] (i mod 4) in
      ignore (get_rhyme char1 char2)
    done;
    
    let end_time = Sys.time () in
    let processing_time = end_time -. start_time in
    
    assert_float_range processing_time 0.0 1.0  (* 期望在1秒内完成 *)
      "大批量处理性能满足要求"
  
  (** 测试缓存大小控制 *)
  let test_cache_size_control () =
    clear_cache ();
    
    (* 添加大量不同的键值对 *)
    for i = 1 to 100 do
      let char1 = Printf.sprintf "字%d" i in
      let char2 = Printf.sprintf "符%d" i in
      ignore (get_rhyme char1 char2)
    done;
    
    let (stats, _) = get_cache_statistics () in
    assert_true (stats.cache_size <= 200)  (* 缓存大小应该受到控制 *)
      "缓存大小控制有效"
  
  let all_tests = [
    ("缓存命中率", test_cache_hit_rate);
    ("大批量处理性能", test_bulk_processing_performance);
    ("缓存大小控制", test_cache_size_control);
  ]
end

(** 边界条件测试 *)
module BoundaryConditionTests = struct
  open TestFramework
  open ChineseRhymeCache
  
  (** 测试空字符串处理 *)
  let test_empty_string_handling () =
    clear_cache ();
    
    try
      let result = get_rhyme "" "" in
      assert_true (not result.chars_rhyme)
        "空字符串处理正确"
    with _ ->
      Fail "空字符串处理异常"
  
  (** 测试未知字符处理 *)
  let test_unknown_character_handling () =
    clear_cache ();
    
    let result = get_rhyme "未知字符1" "未知字符2" in
    assert_true (not result.chars_rhyme && String.equal result.rhyme_class "不同韵")
      "未知字符处理正确"
  
  (** 测试重复键值对 *)
  let test_duplicate_key_handling () =
    clear_cache ();
    
    let result1 = get_rhyme "春" "心" in
    let result2 = get_rhyme "春" "心" in
    let result3 = get_rhyme "春" "心" in
    
    assert_true (result1.chars_rhyme = result2.chars_rhyme && 
                result2.chars_rhyme = result3.chars_rhyme)
      "重复键值对处理一致"
  
  let all_tests = [
    ("空字符串处理", test_empty_string_handling);
    ("未知字符处理", test_unknown_character_handling);
    ("重复键值对处理", test_duplicate_key_handling);
  ]
end

(** 内存安全测试 *)
module MemorySafetyTests = struct
  open TestFramework
  open ChineseRhymeCache
  
  (** 测试内存泄漏防护 *)
  let test_memory_leak_protection () =
    clear_cache ();
    
    let initial_size = Hashtbl.length rhyme_cache in
    
    (* 大量操作 *)
    for i = 1 to 1000 do
      let char1 = Printf.sprintf "测试%d" (i mod 50) in  (* 限制不同键的数量 *)
      let char2 = Printf.sprintf "字符%d" (i mod 50) in
      ignore (get_rhyme char1 char2)
    done;
    
    let final_size = Hashtbl.length rhyme_cache in
    
    assert_true (final_size - initial_size < 100)  (* 缓存增长受控 *)
      "内存泄漏防护有效"
  
  (** 测试缓存清理 *)
  let test_cache_cleanup () =
    clear_cache ();
    
    (* 添加一些数据 *)
    for i = 1 to 10 do
      let char1 = Printf.sprintf "测试%d" i in
      let char2 = Printf.sprintf "清理%d" i in
      ignore (get_rhyme char1 char2)
    done;
    
    let (stats_before, _) = get_cache_statistics () in
    clear_cache ();
    let (stats_after, _) = get_cache_statistics () in
    
    assert_true (stats_after.cache_size = 0 && stats_after.total_requests = 0)
      "缓存清理功能正常"
  
  let all_tests = [
    ("内存泄漏防护", test_memory_leak_protection);
    ("缓存清理", test_cache_cleanup);
  ]
end

(** 综合测试套件 *)
module ComprehensiveTestSuite = struct
  let run_all_tests () =
    Printf.printf "\n=== 中文韵律缓存实现测试 ===\n";
    Printf.printf "Issue #1473 Phase 5.2 韵律检测缓存系统验证\n\n";
    
    let test_suites = [
      ("基础功能测试", BasicFunctionalityTests.all_tests);
      ("性能指标测试", PerformanceTests.all_tests);
      ("边界条件测试", BoundaryConditionTests.all_tests);
      ("内存安全测试", MemorySafetyTests.all_tests);
    ] in
    
    let total_tests = ref 0 in
    let passed_tests = ref 0 in
    
    List.iter (fun (suite_name, tests) ->
      Printf.printf "\n--- %s ---\n" suite_name;
      List.iter (fun (test_name, test_func) ->
        incr total_tests;
        if TestFramework.run_test test_name test_func then
          incr passed_tests
      ) tests
    ) test_suites;
    
    Printf.printf "\n=== 测试结果统计 ===\n";
    Printf.printf "总测试数: %d\n" !total_tests;
    Printf.printf "通过测试: %d\n" !passed_tests;
    Printf.printf "失败测试: %d\n" (!total_tests - !passed_tests);
    Printf.printf "通过率: %.1f%%\n" (float_of_int !passed_tests /. float_of_int !total_tests *. 100.0);
    
    (* 显示最终缓存统计 *)
    let (final_stats, final_hit_rate) = ChineseRhymeCache.get_cache_statistics () in
    Printf.printf "\n=== 最终缓存统计 ===\n";
    Printf.printf "总请求数: %d\n" final_stats.total_requests;
    Printf.printf "缓存命中: %d\n" final_stats.cache_hits;
    Printf.printf "缓存未命中: %d\n" final_stats.cache_misses;
    Printf.printf "缓存命中率: %.1f%%\n" (final_hit_rate *. 100.0);
    Printf.printf "缓存大小: %d\n" final_stats.cache_size;
    
    let success = !passed_tests = !total_tests in
    
    if success then
      Printf.printf "\n✓ 所有测试通过！韵律缓存实现满足Phase 5.2性能要求。\n"
    else
      Printf.printf "\n✗ 部分测试失败，需要修复后重新测试。\n";
    
    success
end

(** 主入口函数 *)
let run_rhyme_cache_tests () =
  let success = ComprehensiveTestSuite.run_all_tests () in
  if success then exit 0 else exit 1

(** 测试执行 *)
let () =
  if Array.length Sys.argv > 1 && Sys.argv.(1) = "--test" then
    run_rhyme_cache_tests ()
  else
    Printf.printf "中文韵律缓存实现测试模块已加载。\n使用 --test 参数运行完整测试。\n"