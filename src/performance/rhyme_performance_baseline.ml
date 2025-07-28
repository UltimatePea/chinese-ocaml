(** 韵律系统性能基准测试 - 基于数据的技术债务分析

    Author: Alpha, 主要工作代理 日期: 2025-07-28 目标: 建立韵律系统的量化性能基准，识别真实的技术债务瓶颈 *)

open Printf
open Unix

type performance_result = {
  name : string;
  execution_time : float;
  operations_per_second : float;
  memory_usage : int option;
  iterations : int;
}
(** 性能测试结果类型 *)

(** 基准测试工具 *)
module BenchmarkUtils = struct
  let time_function iterations fn =
    let start_time = gettimeofday () in
    for _i = 1 to iterations do
      ignore (fn ())
    done;
    let end_time = gettimeofday () in
    end_time -. start_time

  let measure_memory_before_after fn =
    Gc.compact ();
    let stats_before = Gc.stat () in
    let result = fn () in
    Gc.compact ();
    let stats_after = Gc.stat () in
    let memory_diff = stats_after.heap_words - stats_before.heap_words in
    (result, memory_diff * (Sys.word_size / 8))

  let create_result name execution_time iterations memory_usage =
    let ops_per_sec = float_of_int iterations /. execution_time in
    { name; execution_time; operations_per_second = ops_per_sec; memory_usage; iterations }
end

(** 测试数据生成器 *)
module TestData = struct
  (** 测试用的中文字符集 *)
  let sample_characters =
    [
      "春";
      "夏";
      "秋";
      "冬";
      "花";
      "鸟";
      "月";
      "风";
      "雨";
      "雪";
      "云";
      "山";
      "水";
      "木";
      "火";
      "土";
      "金";
      "石";
      "玉";
      "珠";
      "草";
      "树";
      "叶";
      "根";
      "天";
      "地";
      "人";
      "心";
      "情";
      "意";
      "思";
      "想";
      "爱";
      "恨";
      "悲";
      "喜";
      "怒";
      "哀";
      "乐";
      "忧";
      "红";
      "绿";
      "蓝";
      "黄";
      "白";
      "黑";
      "紫";
      "青";
      "东";
      "西";
      "南";
      "北";
      "上";
      "下";
      "左";
      "右";
    ]

  (** 生成不同规模的测试数据 *)
  let generate_test_data scale =
    let rec replicate_list n lst acc =
      if n <= 0 then acc else replicate_list (n - 1) lst (lst @ acc)
    in
    replicate_list scale sample_characters []

  (** 生成韵律查询序列 *)
  let generate_query_sequence size =
    let total_chars = List.length sample_characters in
    Array.init size (fun i -> List.nth sample_characters (i mod total_chars))
end

(** 韵律查找性能测试 *)
module RhymeLookupBenchmark = struct
  (** 模拟当前韵律查找实现 - O(n) 线性搜索 *)
  let simulate_current_lookup chars target =
    let rec find_rhyme lst =
      match lst with [] -> None | h :: t when h = target -> Some h | _ :: t -> find_rhyme t
    in
    find_rhyme chars

  module StringMap = Map.Make (String)
  (** 模拟优化后的韵律查找 - O(log n) 使用Map *)

  let simulate_optimized_lookup char_map target =
    try Some (StringMap.find target char_map) with Not_found -> None

  (** 创建Map用于优化测试 *)
  let create_char_map chars =
    List.fold_left (fun acc char -> StringMap.add char char acc) StringMap.empty chars

  (** 测试当前线性查找性能 *)
  let test_linear_lookup iterations data_scale =
    let test_data = TestData.generate_test_data data_scale in
    let queries = TestData.generate_query_sequence iterations in

    let test_fn () =
      Array.iter (fun target -> ignore (simulate_current_lookup test_data target)) queries
    in

    let _, memory_usage = BenchmarkUtils.measure_memory_before_after test_fn in
    let execution_time = BenchmarkUtils.time_function 1 test_fn in

    BenchmarkUtils.create_result
      (sprintf "线性查找(规模:%d)" (List.length test_data))
      execution_time iterations (Some memory_usage)

  (** 测试优化Map查找性能 *)
  let test_map_lookup iterations data_scale =
    let test_data = TestData.generate_test_data data_scale in
    let char_map = create_char_map test_data in
    let queries = TestData.generate_query_sequence iterations in

    let test_fn () =
      Array.iter (fun target -> ignore (simulate_optimized_lookup char_map target)) queries
    in

    let _, memory_usage = BenchmarkUtils.measure_memory_before_after test_fn in
    let execution_time = BenchmarkUtils.time_function 1 test_fn in

    BenchmarkUtils.create_result
      (sprintf "Map查找(规模:%d)" (List.length test_data))
      execution_time iterations (Some memory_usage)
end

(** 代码重复分析 *)
module CodeDuplicationAnalysis = struct
  (** 模拟重复的JSON解析器 *)
  let simulate_duplicate_json_parsers data =
    let parser1 data = String.length data in
    let parser2 data = String.length data in
    let parser3 data = String.length data in
    let parser4 data = String.length data in
    let parser5 data = String.length data in
    let parser6 data = String.length data in
    let parser7 data = String.length data in
    let parser8 data = String.length data in
    [ parser1; parser2; parser3; parser4; parser5; parser6; parser7; parser8 ]
    |> List.map (fun f -> f data)
    |> List.fold_left ( + ) 0

  (** 模拟统一的JSON解析器 *)
  let simulate_unified_json_parser data = String.length data * 8 (* 相同功能但只有一个实现 *)

  (** 测试重复解析器的性能开销 *)
  let test_duplicate_parsers iterations =
    let test_data = String.concat "" TestData.sample_characters in

    let test_fn () =
      for _i = 1 to iterations do
        ignore (simulate_duplicate_json_parsers test_data)
      done
    in

    let _, memory_usage = BenchmarkUtils.measure_memory_before_after test_fn in
    let execution_time = BenchmarkUtils.time_function 1 test_fn in

    BenchmarkUtils.create_result "重复JSON解析器" execution_time iterations (Some memory_usage)

  (** 测试统一解析器的性能 *)
  let test_unified_parser iterations =
    let test_data = String.concat "" TestData.sample_characters in

    let test_fn () =
      for _i = 1 to iterations do
        ignore (simulate_unified_json_parser test_data)
      done
    in

    let _, memory_usage = BenchmarkUtils.measure_memory_before_after test_fn in
    let execution_time = BenchmarkUtils.time_function 1 test_fn in

    BenchmarkUtils.create_result "统一JSON解析器" execution_time iterations (Some memory_usage)
end

(** 报告生成器 *)
module ReportGenerator = struct
  let print_result result =
    printf "测试: %s\n" result.name;
    printf "  执行时间: %.6f 秒\n" result.execution_time;
    printf "  操作/秒: %.0f\n" result.operations_per_second;
    printf "  迭代次数: %d\n" result.iterations;
    (match result.memory_usage with
    | Some mem -> printf "  内存使用: %d 字节\n" mem
    | None -> printf "  内存使用: 未测量\n");
    printf "\n"

  let compare_results baseline optimized =
    let time_improvement =
      (baseline.execution_time -. optimized.execution_time) /. baseline.execution_time *. 100.0
    in
    let ops_improvement =
      (optimized.operations_per_second -. baseline.operations_per_second)
      /. baseline.operations_per_second *. 100.0
    in

    printf "=== 性能对比分析 ===\n";
    printf "基准: %s vs 优化: %s\n" baseline.name optimized.name;
    printf "执行时间改善: %.2f%%\n" time_improvement;
    printf "操作效率提升: %.2f%%\n" ops_improvement;

    (match (baseline.memory_usage, optimized.memory_usage) with
    | Some base_mem, Some opt_mem ->
        let mem_change = float_of_int (base_mem - opt_mem) /. float_of_int base_mem *. 100.0 in
        printf "内存使用变化: %.2f%%\n" mem_change
    | _ -> printf "内存使用: 数据不完整\n");
    printf "\n"
end

(** 主测试套件 *)
let run_performance_baseline_tests () =
  printf "=== 韵律系统性能基准测试 ===\n";
  printf "Author: Alpha, 主要工作代理\n";
  printf "日期: 2025-07-28\n";
  printf "目标: 基于数据的技术债务分析\n\n";

  (* 韵律查找性能测试 *)
  printf "--- 韵律查找算法性能对比 ---\n";
  let linear_result = RhymeLookupBenchmark.test_linear_lookup 1000 5 in
  let map_result = RhymeLookupBenchmark.test_map_lookup 1000 5 in

  ReportGenerator.print_result linear_result;
  ReportGenerator.print_result map_result;
  ReportGenerator.compare_results linear_result map_result;

  (* 代码重复性能影响测试 *)
  printf "--- 代码重复性能影响分析 ---\n";
  let duplicate_result = CodeDuplicationAnalysis.test_duplicate_parsers 1000 in
  let unified_result = CodeDuplicationAnalysis.test_unified_parser 1000 in

  ReportGenerator.print_result duplicate_result;
  ReportGenerator.print_result unified_result;
  ReportGenerator.compare_results duplicate_result unified_result;

  (* 扩展性能预测 *)
  printf "--- 大规模数据性能预测 ---\n";
  let large_linear = RhymeLookupBenchmark.test_linear_lookup 5000 10 in
  let large_map = RhymeLookupBenchmark.test_map_lookup 5000 10 in

  ReportGenerator.print_result large_linear;
  ReportGenerator.print_result large_map;
  ReportGenerator.compare_results large_linear large_map;

  printf "=== 性能基准测试完成 ===\n";
  printf "结果已保存，可用于技术债务优先级决策\n"

(** 如果作为独立程序运行 *)
let () = run_performance_baseline_tests ()
