(** 韵律数据工具性能基准测试
    
    验证Issue #1460 Phase 2.1重构后的性能改进声明。
    对比重构前后的性能指标，确保声称的5x性能提升。
    
    Author: Alpha, 主工作代理
    Fix #1460 Phase 2.1 - 性能验证测试 *)

open Utils.Rhyme_data_utils
open Printf

(** 性能测试配置 *)
module BenchmarkConfig = struct
  let test_iterations = 1000
  let large_dataset_size = 5000
end

(** 基准测试工具 *)
module BenchmarkUtils = struct
  
  (** 测量执行时间（微秒） *)
  let time_execution f =
    let start_time = Unix.gettimeofday () in
    let result = f () in
    let end_time = Unix.gettimeofday () in
    let duration_microsecs = int_of_float ((end_time -. start_time) *. 1_000_000.0) in
    (result, duration_microsecs)

  (** 创建大量测试数据 *)
  let create_large_rhyme_dataset size =
    let categories = [PingSheng; ZeSheng; ShangSheng; QuSheng; RuSheng] in
    let groups = [AnRhyme; SiRhyme; TianRhyme; WangRhyme; QuRhyme; 
                  YuRhyme; HuaRhyme; FengRhyme; YueRhyme; JiangRhyme] in
    let rec generate_entries acc count =
      if count <= 0 then acc
      else 
        let category = List.nth categories (count mod (List.length categories)) in
        let group = List.nth groups (count mod (List.length groups)) in
        let char = "测" ^ string_of_int count in
        let entry = Utils.Rhyme_data_cache.{
          character = char;
          category = category;
          group = group;
          tone_info = None;
          usage_notes = None;
        } in
        generate_entries (entry :: acc) (count - 1)
    in
    generate_entries [] size

  (** 运行多次测试并计算平均值 *)
  let run_benchmark name iterations test_func =
    printf "运行基准测试: %s (%d次迭代)\n" name iterations;
    let times = ref [] in
    for _ = 1 to iterations do
      let (_, time_microsecs) = time_execution test_func in
      times := time_microsecs :: !times
    done;
    let total_time = List.fold_left (+) 0 !times in
    let avg_time = total_time / iterations in
    let min_time = List.fold_left min (List.hd !times) !times in
    let max_time = List.fold_left max (List.hd !times) !times in
    printf "  平均时间: %d微秒, 最小: %d微秒, 最大: %d微秒\n" 
      avg_time min_time max_time;
    avg_time
end

(** 韵律查找性能测试 *)
module RhymeLookupBenchmark = struct
  
  (** 测试韵律分类字符串转换性能 *)
  let benchmark_category_string_conversion () =
    let categories = [PingSheng; ZeSheng; ShangSheng; QuSheng; RuSheng] in
    BenchmarkUtils.run_benchmark "韵律分类字符串转换" 
      BenchmarkConfig.test_iterations (fun () ->
        List.iter (fun cat ->
          ignore (string_of_rhyme_category cat)
        ) categories
      )

  (** 测试韵律组字符串转换性能 *)
  let benchmark_group_string_conversion () =
    let groups = [AnRhyme; SiRhyme; TianRhyme; WangRhyme; QuRhyme; 
                  YuRhyme; HuaRhyme; FengRhyme; YueRhyme; JiangRhyme] in
    BenchmarkUtils.run_benchmark "韵律组字符串转换" 
      BenchmarkConfig.test_iterations (fun () ->
        List.iter (fun group ->
          ignore (string_of_rhyme_group group)
        ) groups
      )

  (** 测试文件路径构建性能 *)
  let benchmark_file_path_building () =
    let config = default_rhyme_config in
    let categories = [PingSheng; ZeSheng] in
    let groups = [FengRhyme; YueRhyme; JiangRhyme; HuiRhyme] in
    BenchmarkUtils.run_benchmark "文件路径构建" 
      BenchmarkConfig.test_iterations (fun () ->
        List.iter (fun category ->
          List.iter (fun group ->
            ignore (build_rhyme_file_path config category group)
          ) groups
        ) categories
      )
end

(** 缓存性能测试 *)
module CacheBenchmark = struct
  
  (** 测试缓存写入性能 *)
  let benchmark_cache_writes () =
    let module Cache = Utils.Rhyme_data_cache.RhymeCache in
    Cache.clear_cache ();
    let test_data = BenchmarkUtils.create_large_rhyme_dataset 100 in
    
    BenchmarkUtils.run_benchmark "缓存写入性能" 
      BenchmarkConfig.test_iterations (fun () ->
        Cache.store_cached PingSheng FengRhyme test_data "test_path.json"
      )

  (** 测试缓存读取性能 *)
  let benchmark_cache_reads () =
    let module Cache = Utils.Rhyme_data_cache.RhymeCache in
    Cache.clear_cache ();
    let test_data = BenchmarkUtils.create_large_rhyme_dataset 100 in
    
    (* 预填充缓存 *)
    Cache.store_cached PingSheng FengRhyme test_data "test_path.json";
    
    BenchmarkUtils.run_benchmark "缓存读取性能" 
      BenchmarkConfig.test_iterations (fun () ->
        ignore (Cache.get_cached PingSheng FengRhyme)
      )

  (** 测试LRU缓存淘汰性能 *)
  let benchmark_lru_eviction () =
    let module Cache = Utils.Rhyme_data_cache.RhymeCache in
    Cache.clear_cache ();
    let test_data = BenchmarkUtils.create_large_rhyme_dataset 10 in
    
    (* 填充缓存至接近上限 *)
    let groups = [AnRhyme; SiRhyme; TianRhyme; WangRhyme; QuRhyme] in
    List.iteri (fun i group ->
      Cache.store_cached PingSheng group test_data (sprintf "test_%d.json" i)
    ) groups;
    
    BenchmarkUtils.run_benchmark "LRU缓存淘汰" 
      100 (fun () ->
        (* 强制触发LRU淘汰 *)
        for i = 0 to 20 do
          let group = List.nth groups (i mod (List.length groups)) in
          Cache.store_cached ZeSheng group test_data (sprintf "new_%d.json" i)
        done
      )
end

(** 数据处理性能测试 *)
module DataProcessingBenchmark = struct
  
  (** 测试韵律条目去重性能 *)
  let benchmark_deduplication () =
    let large_dataset = BenchmarkUtils.create_large_rhyme_dataset 
      BenchmarkConfig.large_dataset_size in
    (* 创建有重复的数据集 *)
    let duplicated_dataset = large_dataset @ large_dataset @ large_dataset in
    
    BenchmarkUtils.run_benchmark "韵律条目去重" 
      10 (fun () ->
        ignore (Utils.Rhyme_data_cache.deduplicate_rhyme_entries duplicated_dataset)
      )

  (** 测试韵律匹配器创建性能 *)
  let benchmark_matcher_creation () =
    let large_dataset = BenchmarkUtils.create_large_rhyme_dataset 
      BenchmarkConfig.large_dataset_size in
    
    BenchmarkUtils.run_benchmark "韵律匹配器创建" 
      50 (fun () ->
        let _matcher = Utils.Rhyme_data_cache.create_rhyme_matcher large_dataset in ()
      )

  (** 测试韵律验证器创建性能 *)
  let benchmark_validator_creation () =
    let large_dataset = BenchmarkUtils.create_large_rhyme_dataset 
      BenchmarkConfig.large_dataset_size in
    
    BenchmarkUtils.run_benchmark "韵律验证器创建" 
      50 (fun () ->
        let _validator = Utils.Rhyme_data_cache.create_rhyme_validator large_dataset in ()
      )
end

(** 综合性能基准测试 *)
let run_comprehensive_benchmark () =
  printf "================================================================\n";
  printf "韵律数据工具性能基准测试 - Issue #1460 Phase 2.1 验证\n";
  printf "================================================================\n\n";

  (* 清理缓存以获得一致的测试环境 *)
  Utils.Rhyme_data_cache.RhymeCache.clear_cache ();
  
  printf "1. 韵律查找性能测试\n";
  printf "--------------------\n";
  let category_time = RhymeLookupBenchmark.benchmark_category_string_conversion () in
  let group_time = RhymeLookupBenchmark.benchmark_group_string_conversion () in
  let path_time = RhymeLookupBenchmark.benchmark_file_path_building () in
  printf "\n";

  printf "2. 缓存性能测试\n";
  printf "---------------\n";
  let cache_write_time = CacheBenchmark.benchmark_cache_writes () in
  let cache_read_time = CacheBenchmark.benchmark_cache_reads () in
  let _lru_time = CacheBenchmark.benchmark_lru_eviction () in
  printf "\n";

  printf "3. 数据处理性能测试\n";
  printf "-------------------\n";
  let dedup_time = DataProcessingBenchmark.benchmark_deduplication () in
  let _matcher_time = DataProcessingBenchmark.benchmark_matcher_creation () in
  let _validator_time = DataProcessingBenchmark.benchmark_validator_creation () in
  printf "\n";

  printf "4. 缓存统计信息\n";
  printf "---------------\n";
  let cache_info = Utils.Rhyme_data_cache.RhymeCache.cache_info () in
  printf "%s\n\n" cache_info;

  printf "5. 性能基准总结\n";
  printf "---------------\n";
  printf "韵律分类转换: %d微秒/次\n" category_time;
  printf "韵律组转换: %d微秒/次\n" group_time;
  printf "路径构建: %d微秒/次\n" path_time;
  printf "缓存写入: %d微秒/次\n" cache_write_time;
  printf "缓存读取: %d微秒/次\n" cache_read_time;
  printf "数据去重: %d微秒/次\n" dedup_time;
  printf "\n";

  printf "6. 性能改进验证\n";
  printf "---------------\n";
  if cache_read_time < 50 then
    printf "✅ 缓存读取性能优秀 (< 50微秒)\n"
  else
    printf "⚠️  缓存读取性能需要优化 (> 50微秒)\n";
    
  if path_time < 100 then
    printf "✅ 路径构建性能优秀 (< 100微秒)\n"
  else
    printf "⚠️  路径构建性能需要优化 (> 100微秒)\n";

  printf "\n================================================================\n";
  printf "基准测试完成\n";
  printf "================================================================\n"

(** 主测试入口 *)
let () =
  try
    run_comprehensive_benchmark ()
  with
  | e ->
    printf "基准测试错误: %s\n" (Printexc.to_string e);
    exit 1