(** Data Loader Performance Comparison Benchmark
    
    验证PR #1763中声称的性能改进：
    - 内存使用减少30-40%
    - 加载性能提升20-30%
    
    Author: Charlie, 规划代理
    Created: 2025-07-30
*)

open Printf
open Alcotest

(* Import benchmark infrastructure *)
open Performance.Benchmark_core
open Performance.Benchmark_memory

(** Test configuration for performance comparison *)
let test_configs = [
  { name = "small_dataset"; iterations = 100; data_size = 10; description = "小数据集测试" };
  { name = "medium_dataset"; iterations = 50; data_size = 100; description = "中等数据集测试" };
  { name = "large_dataset"; iterations = 10; data_size = 1000; description = "大数据集测试" };
]

(** Sample data generation for consistent testing *)
let generate_sample_poetry_data size =
  let base_poems = [
    "春眠不觉晓，处处闻啼鸟";
    "举头望明月，低头思故乡";
    "白日依山尽，黄河入海流";
    "飞流直下三千尺，疑是银河落九天";
    "两个黄鹂鸣翠柳，一行白鹭上青天";
  ] in
  let rec expand acc remaining =
    if remaining <= 0 then acc
    else
      let poem = List.nth base_poems (remaining mod (List.length base_poems)) in
      expand (poem :: acc) (remaining - 1)
  in
  expand [] size

(** Legacy data loader simulation *)
module LegacyDataLoader = struct
  let hash_table = Hashtbl.create 32
  
  let load_poetry_data data =
    List.iter (fun poem ->
      let key = "poem_" ^ (string_of_int (Hashtbl.length hash_table)) in
      Hashtbl.replace hash_table key poem
    ) data;
    Hashtbl.fold (fun k v acc -> (k, v) :: acc) hash_table []
    
  
  let clear_cache () = Hashtbl.clear hash_table
end

(** New unified data engine (from current PR) *)
module UnifiedDataEngine = struct
  (* Simulate the new unified data engine behavior *)
  let cache = ref []
  let source_registry = Hashtbl.create 16
  
  let register_source name data =
    Hashtbl.replace source_registry name data
    
  let load_poetry_data data =
    let source_name = "poetry_source_" ^ (string_of_int (List.length !cache)) in
    register_source source_name data;
    let processed_data = List.mapi (fun i poem ->
      let key = source_name ^ "_" ^ (string_of_int i) in
      (key, poem)
    ) data in
    cache := processed_data @ !cache;
    processed_data
    
  
  let clear_cache () = 
    cache := [];
    Hashtbl.clear source_registry
end

(** Performance measurement functions *)
let measure_loading_performance loader_func data config =
  let start_time = Sys.time () in
  let result = ref [] in
  
  for _i = 1 to config.iterations do
    result := loader_func data;
  done;
  
  let end_time = Sys.time () in
  let total_time = end_time -. start_time in
  let avg_time = total_time /. (float_of_int config.iterations) in
  
  BenchmarkCore.create_metric 
    (config.name ^ "_loading") 
    avg_time 
    config.iterations

let measure_memory_usage loader_func data config =
  let initial_memory = MemoryMonitor.get_memory_usage () in
  let _ = loader_func data in
  Gc.full_major ();
  let final_memory = MemoryMonitor.get_memory_usage () in
  let memory_used = max 0 (final_memory - initial_memory) in
  
  BenchmarkCore.create_metric 
    (config.name ^ "_memory") 
    0.0 
    ~memory_usage:memory_used 
    1

(** Individual test cases *)
let test_loading_performance_comparison config () =
  let sample_data = generate_sample_poetry_data config.data_size in
  
  (* Test legacy loader *)
  LegacyDataLoader.clear_cache ();
  let legacy_metric = measure_loading_performance 
    LegacyDataLoader.load_poetry_data sample_data config in
  
  (* Test unified engine *)
  UnifiedDataEngine.clear_cache ();
  let unified_metric = measure_loading_performance 
    UnifiedDataEngine.load_poetry_data sample_data config in
  
  (* Calculate performance improvement *)
  let performance_ratio = legacy_metric.execution_time /. unified_metric.execution_time in
  let improvement_percentage = (performance_ratio -. 1.0) *. 100.0 in
  
  printf "📊 %s 加载性能对比:\n" config.description;
  printf "   Legacy: %.6f秒/次, Unified: %.6f秒/次\n" 
    legacy_metric.execution_time unified_metric.execution_time;
  printf "   性能改进: %.2f%% (声称目标: 20-30%%)\n" improvement_percentage;
  
  (* Verify if claimed improvement is achieved *)
  if improvement_percentage >= 20.0 then
    printf "   ✅ 性能改进目标达成\n"
  else
    printf "   ❌ 性能改进未达目标 (实际: %.2f%%, 目标: ≥20%%)\n" improvement_percentage

let test_memory_usage_comparison config () =
  let sample_data = generate_sample_poetry_data config.data_size in
  
  (* Test legacy loader memory usage *)
  LegacyDataLoader.clear_cache ();
  Gc.full_major ();
  let legacy_metric = measure_memory_usage 
    LegacyDataLoader.load_poetry_data sample_data config in
  
  (* Test unified engine memory usage *)
  UnifiedDataEngine.clear_cache ();
  Gc.full_major ();
  let unified_metric = measure_memory_usage 
    UnifiedDataEngine.load_poetry_data sample_data config in
  
  let legacy_memory = match legacy_metric.memory_usage with
    | Some mem -> mem | None -> 0 in
  let unified_memory = match unified_metric.memory_usage with
    | Some mem -> mem | None -> 0 in
  
  (* Calculate memory reduction *)
  let memory_reduction = if legacy_memory > 0 then
    (float_of_int (legacy_memory - unified_memory)) /. (float_of_int legacy_memory) *. 100.0
  else 0.0 in
  
  printf "💾 %s 内存使用对比:\n" config.description;
  printf "   Legacy: %d bytes, Unified: %d bytes\n" legacy_memory unified_memory;
  printf "   内存减少: %.2f%% (声称目标: 30-40%%)\n" memory_reduction;
  
  (* Verify if claimed reduction is achieved *)
  if memory_reduction >= 30.0 then
    printf "   ✅ 内存优化目标达成\n"
  else
    printf "   ❌ 内存优化未达目标 (实际: %.2f%%, 目标: ≥30%%)\n" memory_reduction

(** Comprehensive performance validation *)
let run_comprehensive_performance_validation () =
  printf "\n🔬 数据加载器性能对比基准测试\n";
  printf "====================================\n";
  printf "测试目标: 验证PR #1763的性能声称\n";
  printf "- 内存使用减少30-40%%\n";
  printf "- 加载性能提升20-30%%\n\n";
  
  List.iter (fun config ->
    printf "\n--- %s ---\n" config.description;
    test_loading_performance_comparison config ();
    test_memory_usage_comparison config ();
  ) test_configs;
  
  printf "\n📈 测试完成。\n";
  printf "注意: 此基准测试模拟了新旧数据加载器的行为差异\n";
  printf "实际性能可能因数据集和使用模式而异。\n"

(** Memory leak detection test *)
let test_memory_leak_detection () =
  printf "\n🔍 内存泄漏检测测试\n";
  let sample_data = generate_sample_poetry_data 50 in
  
  (* Test legacy loader for memory leaks *)
  LegacyDataLoader.clear_cache ();
  printf "Legacy loader 内存泄漏检测: ";
  let initial_mem = MemoryMonitor.get_memory_usage () in
  for _i = 1 to 100 do
    ignore (LegacyDataLoader.load_poetry_data sample_data);
  done;
  Gc.full_major ();
  let final_mem = MemoryMonitor.get_memory_usage () in
  let legacy_leak = final_mem - initial_mem in
  printf "%d bytes\n" legacy_leak;
  
  (* Test unified engine for memory leaks *)
  UnifiedDataEngine.clear_cache ();
  printf "Unified engine 内存泄漏检测: ";
  let initial_mem2 = MemoryMonitor.get_memory_usage () in
  for _i = 1 to 100 do
    ignore (UnifiedDataEngine.load_poetry_data sample_data);
  done;
  Gc.full_major ();
  let final_mem2 = MemoryMonitor.get_memory_usage () in
  let unified_leak = final_mem2 - initial_mem2 in
  printf "%d bytes\n" unified_leak;
  
  if unified_leak < legacy_leak then
    printf "✅ Unified engine 内存管理更优\n"
  else
    printf "⚠️  需要检查unified engine的内存管理\n"

(** Alcotest test cases *)
let performance_comparison_tests = [
  test_case "小数据集性能对比" `Quick (fun () -> 
    test_loading_performance_comparison (List.hd test_configs) ()
  );
  test_case "中等数据集性能对比" `Quick (fun () -> 
    test_loading_performance_comparison (List.nth test_configs 1) ()
  );
  test_case "内存泄漏检测" `Quick (fun () ->
    test_memory_leak_detection ()
  );
]

(** Main benchmark runner *)
let run_all_benchmarks () =
  run_comprehensive_performance_validation ();
  test_memory_leak_detection ()

(** Export test suite for integration *)
let () =
  let test_suites = [
    ("数据加载器性能对比", performance_comparison_tests);
  ] in
  
  printf "\n🚀 运行数据加载器性能基准测试...\n";
  run_all_benchmarks ();
  
  (* Run alcotest suite if this is executed directly *)
  if not !Sys.interactive then
    Alcotest.run "数据加载器性能验证" test_suites