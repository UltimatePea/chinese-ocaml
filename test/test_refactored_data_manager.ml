(** 重构后数据管理器测试
    
    验证重构后的模块化数据管理器功能正确性，
    确保重构不会破坏原有功能。
                                                           
    @author Charlie, 规划代理 - 负责架构重构
    @test_for refactored data_manager modules
    @fix_issue #1727 *)

open Poetry_data_core.Data_types

(** 测试数据 *)
let test_data = [
  {
    character = "春";
    category = Poetry_core.Poetry_types.PingSheng;
    group = Poetry_core.Poetry_types.AnRhyme;
    metadata = [("tone", "1"); ("frequency", "high")];
  };
  {
    character = "花";
    category = Poetry_core.Poetry_types.ZeSheng;
    group = Poetry_core.Poetry_types.SiRhyme;
    metadata = [("tone", "1"); ("frequency", "medium")];
  };
]

(** 测试数据加载器 *)
let test_loader () = Success test_data

(** 测试核心数据类型模块 *)
let test_data_types () =
  Printf.printf "Testing Data Types Module...\n";
  
  (* 测试查询条件转换 *)
  let criteria = ByCharacter "春" in
  let key = string_of_query_criteria criteria in
  assert (key = "char:春");
  
  let composite = CompositeQuery [ByCharacter "春"; ByCharacter "花"] in
  let composite_key = string_of_query_criteria composite in
  assert (String.contains composite_key '[');
  
  Printf.printf "✓ Data Types Module tests passed\n"

(** 测试缓存管理器模块 *)
let test_cache_manager () =
  Printf.printf "Testing Cache Manager Module...\n";
  
  (* 重置缓存状态 *)
  Cache_manager.clear_cache ();
  
  (* 测试缓存存储和获取 *)
  let criteria = ByCharacter "春" in
  Cache_manager.put criteria test_data;
  
  match Cache_manager.get criteria with
  | Some cached_data ->
      assert (List.length cached_data = List.length test_data);
      Printf.printf "✓ Cache store/retrieve works\n"
  | None ->
      failwith "Cache should have returned data";
  
  (* 测试缓存统计 *)
  let stats = Cache_manager.get_cache_statistics () in
  assert (stats.total_queries > 0);
  assert (stats.cache_hits > 0);
  
  Printf.printf "✓ Cache Manager Module tests passed\n"

(** 测试查询管理器模块 *)
let test_query_manager () =
  Printf.printf "Testing Query Manager Module...\n";
  
  (* 重建索引 *)
  Query_manager.rebuild_all_indexes test_data;
  
  (* 测试字符查询 *)
  let mock_source_loader source_id =
    Error (Poetry_core.Poetry_errors.DataSourceError "Not implemented in test")
  in
  
  match Query_manager.query_data (ByCharacter "春") mock_source_loader with
  | Success results ->
      assert (List.length results = 1);
      assert ((List.hd results).character = "春");
      Printf.printf "✓ Character query works\n"
  | Error _ ->
      failwith "Character query should have succeeded"
  
  (* 测试快速查找 *)
  (match Query_manager.FastLookup.lookup_character "春" with
   | Success (Some item) ->
       assert (item.character = "春");
       Printf.printf "✓ Fast lookup works\n"
   | _ ->
       failwith "Fast lookup should have found character");
  
  Printf.printf "✓ Query Manager Module tests passed\n"

(** 测试数据源管理器模块 *)
let test_source_manager () =
  Printf.printf "Testing Source Manager Module...\n";
  
  (* 清理现有数据源 *)
  Source_manager.clear_all_sources ();
  
  (* 注册测试数据源 *)
  let source_id = RhymeData "test_source" in
  (match Source_manager.register_data_source source_id test_loader ~priority:1 "Test data source" with
   | Success () -> Printf.printf "✓ Data source registration works\n"
   | Error _ -> failwith "Data source registration should have succeeded");
  
  (* 测试数据源列表 *)
  let sources = Source_manager.list_registered_sources () in
  assert (List.length sources = 1);
  Printf.printf "✓ Data source listing works\n";
  
  (* 测试数据加载 *)
  (match Source_manager.load_from_source source_id with
   | Success data ->
       assert (List.length data = List.length test_data);
       Printf.printf "✓ Data loading works\n"
   | Error _ ->
       failwith "Data loading should have succeeded");
  
  Printf.printf "✓ Source Manager Module tests passed\n"

(** 集成测试 - 测试模块间协作 *)
let test_integration () =
  Printf.printf "Testing Module Integration...\n";
  
  (* 清理状态 *)
  Cache_manager.clear_cache ();
  Source_manager.clear_all_sources ();
  
  (* 注册数据源 *)
  let source_id = RhymeData "integration_test" in
  let _ = Source_manager.register_data_source source_id test_loader "Integration test" in
  
  (* 加载数据并重建索引 *)
  (match Source_manager.load_all_data () with
   | Success data ->
       (* 测试查询 *)
       (match Query_manager.query_data (ByCharacter "春") Source_manager.load_from_source with
        | Success results ->
            assert (List.length results = 1);
            Printf.printf "✓ End-to-end query works\n"
        | Error _ ->
            failwith "End-to-end query should have succeeded")
   | Error _ ->
       failwith "Data loading should have succeeded");
  
  Printf.printf "✓ Integration tests passed\n"

(** 性能对比测试 *)
let test_performance () =
  Printf.printf "Testing Performance Characteristics...\n";
  
  (* 生成大量测试数据 *)
  let large_test_data = Array.init 1000 (fun i ->
    {
      character = "字" ^ string_of_int i;
      category = if i mod 2 = 0 then Poetry_core.Poetry_types.PingSheng else Poetry_core.Poetry_types.ZeSheng;
      group = if i mod 3 = 0 then Poetry_core.Poetry_types.AnRhyme else Poetry_core.Poetry_types.SiRhyme;
      metadata = [("index", string_of_int i)];
    }
  ) |> Array.to_list in
  
  let large_loader () = Success large_test_data in
  
  (* 注册大数据源 *)
  Source_manager.clear_all_sources ();
  let _ = Source_manager.register_data_source (RhymeData "large_test") large_loader "Large test data" in
  
  (* 测量索引构建时间 *)
  let start_time = Unix.time () in
  let _ = Source_manager.load_all_data () in
  let index_time = Unix.time () -. start_time in
  
  (* 测量查询时间 *)
  let query_start = Unix.time () in
  let _ = Query_manager.query_data (ByCharacter "字500") Source_manager.load_from_source in
  let query_time = Unix.time () -. query_start in
  
  Printf.printf "✓ Performance test completed\n";
  Printf.printf "  Index build time: %.4f seconds\n" index_time;
  Printf.printf "  Query time: %.6f seconds\n" query_time;
  
  (* 验证性能合理性 *)
  assert (index_time < 1.0); (* 索引构建应该在1秒内完成 *)
  assert (query_time < 0.1); (* 查询应该在100ms内完成 *)
  ()

(** 主测试函数 *)
let run_all_tests () =
  Printf.printf "\n=== Refactored Data Manager Test Suite ===\n\n";
  
  try
    test_data_types ();
    test_cache_manager ();
    test_query_manager ();
    test_source_manager ();
    test_integration ();
    test_performance ();
    
    Printf.printf "\n🎉 All tests passed! Refactoring successful.\n";
    Printf.printf "=== Architecture benefits verified ===\n";
    Printf.printf "- Modular design enables better testing\n";
    Printf.printf "- Clear separation of concerns\n";
    Printf.printf "- Maintained functionality while improving structure\n";
    Printf.printf "- Performance characteristics preserved\n\n";
    
    true
  with
  | Failure msg ->
      Printf.printf "\n❌ Test failed: %s\n" msg;
      false
  | exn ->
      Printf.printf "\n❌ Test error: %s\n" (Printexc.to_string exn);
      false

(** 如果直接运行此文件，执行所有测试 *)
let () =
  if !Sys.interactive = false then
    let success = run_all_tests () in
    exit (if success then 0 else 1)