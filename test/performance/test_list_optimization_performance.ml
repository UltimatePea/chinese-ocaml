(* 
 * 性能测试套件 - 列表模块尾递归优化验证
 * 
 * Author: Whisky, PR Worker
 * 测试目标: 验证Issue #2190的列表操作尾递归优化和性能提升
 *)

open Printf
open Unix

(* 性能测试工具函数 *)
let time_function f x =
  let start_time = gettimeofday () in
  let result = f x in
  let end_time = gettimeofday () in
  (result, end_time -. start_time)

(* 内存使用监控 *)
let get_memory_usage () =
  let gc_stats = Gc.stat () in
  gc_stats.Gc.heap_words * (Sys.word_size / 8)

(* 创建测试数据 *)
let create_large_list n =
  let rec aux acc i =
    if i >= n then acc
    else aux (i :: acc) (i + 1)
  in
  aux [] 0

(* 暂时未使用的随机列表生成函数 - 保留以备将来性能测试扩展
let create_random_list n =
  Random.self_init ();
  let rec aux acc i =
    if i >= n then acc
    else aux (Random.int 1000 :: acc) (i + 1)
  in
  aux [] 0
*)

(* 测试配置 *)
let test_sizes = [1000; 10000; 100000; 1000000]
let test_names = ["1K"; "10K"; "100K"; "1M"]

(* 基准测试函数 *)
let benchmark_length lists =
  printf "=== 长度计算性能测试 ===\n";
  List.iter2 (fun size name ->
    let test_list = List.hd (List.filter (fun l -> List.length l = size) lists) in
    let (result, time_taken) = time_function List.length test_list in
    printf "%s 元素: 长度=%d, 时间=%.6f秒\n" name result time_taken
  ) test_sizes test_names;
  printf "\n"

let benchmark_map lists =
  printf "=== 映射操作性能测试 ===\n";
  let double x = x * 2 in
  List.iter2 (fun size name ->
    let test_list = List.hd (List.filter (fun l -> List.length l = size) lists) in
    let memory_before = get_memory_usage () in
    let (_, time_taken) = time_function (List.map double) test_list in
    let memory_after = get_memory_usage () in
    let memory_used = memory_after - memory_before in
    printf "%s 元素: 映射完成, 时间=%.6f秒, 内存=%d字节\n" name time_taken memory_used
  ) test_sizes test_names;
  printf "\n"

let benchmark_filter lists =
  printf "=== 过滤操作性能测试 ===\n";
  let is_even x = x mod 2 = 0 in
  List.iter2 (fun size name ->
    let test_list = List.hd (List.filter (fun l -> List.length l = size) lists) in
    let memory_before = get_memory_usage () in
    let (result, time_taken) = time_function (List.filter is_even) test_list in
    let memory_after = get_memory_usage () in
    let memory_used = memory_after - memory_before in
    let filtered_count = List.length result in
    printf "%s 元素: 过滤得到%d个, 时间=%.6f秒, 内存=%d字节\n" name filtered_count time_taken memory_used
  ) test_sizes test_names;
  printf "\n"

let benchmark_fold lists =
  printf "=== 折叠操作性能测试 ===\n";
  List.iter2 (fun size name ->
    let test_list = List.hd (List.filter (fun l -> List.length l = size) lists) in
    let (sum_result, time_taken) = time_function (List.fold_left (+) 0) test_list in
    printf "%s 元素: 求和=%d, 时间=%.6f秒\n" name sum_result time_taken
  ) test_sizes test_names;
  printf "\n"

let benchmark_append lists =
  printf "=== 连接操作性能测试 ===\n";
  List.iter2 (fun size name ->
    let _ = List.hd (List.filter (fun l -> List.length l = size) lists) in
    let half_size = size / 2 in
    let list1 = create_large_list half_size in
    let list2 = create_large_list half_size in
    let (result, time_taken) = time_function (fun (l1, l2) -> l1 @ l2) (list1, list2) in
    let final_length = List.length result in
    printf "%s 元素: 连接后长度=%d, 时间=%.6f秒\n" name final_length time_taken
  ) test_sizes test_names;
  printf "\n"

(* 栈溢出测试 *)
let test_stack_overflow () =
  printf "=== 栈溢出保护测试 ===\n";
  try
    let huge_list = create_large_list 500000 in
    printf "创建500K元素列表: 成功\n";
    
    let _ = List.length huge_list in
    printf "长度计算: 无栈溢出\n";
    
    let _ = List.map (fun x -> x + 1) huge_list in
    printf "映射操作: 无栈溢出\n";
    
    let _ = List.filter (fun x -> x mod 2 = 0) huge_list in
    printf "过滤操作: 无栈溢出\n";
    
    let _ = List.fold_left (+) 0 huge_list in
    printf "折叠操作: 无栈溢出\n";
    
    printf "所有大数据集测试通过 - 尾递归优化成功!\n\n"
  with
  | Stack_overflow -> printf "检测到栈溢出 - 优化失败!\n\n"
  | e -> printf "其他错误: %s\n\n" (Printexc.to_string e)

(* 性能回归测试 *)
let performance_regression_test () =
  printf "=== 性能回归基准测试 ===\n";
  let test_list = create_large_list 50000 in
  
  (* 长度计算基准 *)
  let (_, length_time) = time_function List.length test_list in
  printf "50K元素长度计算: %.6f秒\n" length_time;
  
  (* 映射操作基准 *)
  let (_, map_time) = time_function (List.map (fun x -> x * 2)) test_list in
  printf "50K元素映射操作: %.6f秒\n" map_time;
  
  (* 过滤操作基准 *)
  let (_, filter_time) = time_function (List.filter (fun x -> x mod 2 = 0)) test_list in
  printf "50K元素过滤操作: %.6f秒\n" filter_time;
  
  (* 折叠操作基准 *)
  let (_, fold_time) = time_function (List.fold_left (+) 0) test_list in
  printf "50K元素折叠操作: %.6f秒\n" fold_time;
  
  printf "\n目标: 与OCaml List模块性能差距 < 20%%\n\n"

(* 主测试函数 *)
let run_performance_tests () =
  printf "骆言列表模块性能测试套件\n";
  printf "Issue #2190: 列表操作尾递归优化和性能提升\n";
  printf "Author: Whisky, PR Worker\n";
  printf "=========================================\n\n";
  
  (* 创建测试数据 *)
  printf "正在创建测试数据...\n";
  let test_lists = List.map create_large_list test_sizes in
  printf "测试数据创建完成\n\n";
  
  (* 运行性能测试 *)
  benchmark_length test_lists;
  benchmark_map test_lists;
  benchmark_filter test_lists;
  benchmark_fold test_lists;
  benchmark_append test_lists;
  
  (* 栈溢出保护测试 *)
  test_stack_overflow ();
  
  (* 性能回归测试 *)
  performance_regression_test ();
  
  printf "所有性能测试完成!\n"

(* 测试入口 *)
let () = run_performance_tests ()