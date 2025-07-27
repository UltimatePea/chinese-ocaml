(** 简单韵律性能基准测试 - 修复 Issue #1463
    
    验证简化后的韵律模块相比原版本的性能改善
    
    Author: Alpha, 主工作代理
    Fix #1463 - 添加性能基准测试验证
    CI rebuild trigger: 2025-07-27 *)

open Utils.Rhyme_data_utils

(** 测试数据 *)
let sample_characters = ["春"; "花"; "秋"; "月"; "风"; "雨"; "雪"; "云"]
let test_entries = create_rhyme_entries sample_characters PingSheng FengRhyme

(** 简单基准测试工具 *)
let benchmark name iterations test_fn =
  let start_time = Unix.gettimeofday () in
  for _i = 1 to iterations do
    ignore (test_fn ())
  done;
  let end_time = Unix.gettimeofday () in
  let duration = end_time -. start_time in
  Printf.printf "%s: %d 次迭代耗时 %.6f 秒 (%.6f 秒/次)\n" 
    name iterations duration (duration /. float_of_int iterations)

(** 测试韵律匹配器性能 *)
let test_rhyme_matcher_performance () =
  let matcher = create_rhyme_matcher test_entries in
  benchmark "韵律匹配器" 10000 (fun () ->
    List.iter (fun char -> ignore (matcher char)) sample_characters
  )

(** 测试韵律验证器性能 *)
let test_rhyme_validator_performance () =
  let validator = create_rhyme_validator test_entries in
  benchmark "韵律验证器" 10000 (fun () ->
    List.iter (fun char -> ignore (validator char)) sample_characters
  )

(** 测试简单缓存性能 *)
let test_simple_cache_performance () =
  let (get, put, _stats) = create_simple_cache 10 in
  benchmark "简单缓存操作" 10000 (fun () ->
    List.iteri (fun i char ->
      put i char;
      ignore (get i)
    ) sample_characters
  )

(** 测试数据分析性能 *)
let test_analyze_performance () =
  benchmark "韵律数据分析" 1000 (fun () ->
    ignore (analyze_rhyme_data test_entries)
  )

(** 主测试函数 *)
let run_performance_tests () =
  Printf.printf "=== 简化韵律模块性能基准测试 ===\n";
  Printf.printf "测试数据: %d 个字符, %d 个韵律条目\n" 
    (List.length sample_characters) (List.length test_entries);
  Printf.printf "\n";
  
  test_rhyme_matcher_performance ();
  test_rhyme_validator_performance ();
  test_simple_cache_performance ();
  test_analyze_performance ();
  
  Printf.printf "\n=== 性能测试完成 ===\n";
  Printf.printf "备注: 简化版本去除了全局状态，使用更简单的算法\n";
  Printf.printf "预期: 内存使用减少，无全局状态安全风险\n"

let () = run_performance_tests ()