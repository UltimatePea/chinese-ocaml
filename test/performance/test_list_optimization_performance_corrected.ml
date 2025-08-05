(* 
 * 性能测试套件 - 骆言列表操作尾递归优化验证 (修正版)
 * 
 * Author: Whisky, PR Worker  
 * 测试目标: 验证Issue #2190的骆言列表操作尾递归优化和性能提升
 * 修复: pr-critic-delta指出的错误 - 测试骆言函数而非OCaml stdlib
 *)

open Printf
open Unix
open Yyocamlc_lib.Value_operations
open Yyocamlc_lib.Builtin_collections

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

(* 创建骆言列表值 *)
let create_luoyan_list n =
  let rec aux acc i =
    if i >= n then acc
    else aux (IntValue i :: acc) (i + 1)
  in
  ListValue (aux [] 0)

(* 从骆言函数表获取函数 *)
let get_luoyan_function name =
  try 
    List.assoc name collection_functions
  with Not_found ->
    failwith ("Function not found: " ^ name)

(* 执行骆言函数 *)
let call_luoyan_function func args =
  match func with
  | BuiltinFunctionValue f -> f args
  | _ -> failwith "Not a builtin function"

(* 测试配置 *)
let test_sizes = [1000; 10000; 100000; 1000000]
let test_names = ["1K"; "10K"; "100K"; "1M"]

(* 基准测试函数 *)
let benchmark_length lists =
  printf "=== 骆言长度计算性能测试 ===\n";
  let length_func = get_luoyan_function "长度" in
  List.iter2 (fun size name ->
    let test_list = List.hd (List.filter (fun l -> 
      match l with ListValue lst -> List.length lst = size | _ -> false) lists) in
    let (result, time_taken) = time_function (call_luoyan_function length_func) [test_list] in
    match result with
    | IntValue len -> printf "%s 元素: 长度=%d, 时间=%.6f秒\n" name len time_taken
    | _ -> printf "%s 元素: 长度计算错误\n" name
  ) test_sizes test_names;
  printf "\n"

let benchmark_map lists =
  printf "=== 骆言映射操作性能测试 ===\n";
  let map_func = get_luoyan_function "映射" in
  (* 创建简单的乘法函数 *)
  let double_func = BuiltinFunctionValue (fun args -> 
    match args with
    | [IntValue x] -> IntValue (x * 2)
    | _ -> failwith "double function expects one integer argument") in
  
  List.iter2 (fun size name ->
    let test_list = List.hd (List.filter (fun l -> 
      match l with ListValue lst -> List.length lst = size | _ -> false) lists) in
    let memory_before = get_memory_usage () in
    let (_, time_taken) = time_function (fun _ ->
      let partial_map = call_luoyan_function map_func [double_func] in
      call_luoyan_function partial_map [test_list]
    ) () in
    let memory_after = get_memory_usage () in
    let memory_used = memory_after - memory_before in
    printf "%s 元素: 映射完成, 时间=%.6f秒, 内存=%d字节\n" name time_taken memory_used
  ) test_sizes test_names;
  printf "\n"

let benchmark_filter lists =
  printf "=== 骆言过滤操作性能测试 ===\n";
  let filter_func = get_luoyan_function "过滤" in
  (* 创建简单的偶数判断函数 *)
  let is_even_func = BuiltinFunctionValue (fun args -> 
    match args with
    | [IntValue x] -> BoolValue (x mod 2 = 0)
    | _ -> failwith "is_even function expects one integer argument") in
  
  List.iter2 (fun size name ->
    let test_list = List.hd (List.filter (fun l -> 
      match l with ListValue lst -> List.length lst = size | _ -> false) lists) in
    let memory_before = get_memory_usage () in
    let (result, time_taken) = time_function (fun _ ->
      let partial_filter = call_luoyan_function filter_func [is_even_func] in
      call_luoyan_function partial_filter [test_list]
    ) () in
    let memory_after = get_memory_usage () in
    let memory_used = memory_after - memory_before in
    let filtered_count = match result with
      | ListValue lst -> List.length lst
      | _ -> 0 in
    printf "%s 元素: 过滤得到%d个, 时间=%.6f秒, 内存=%d字节\n" name filtered_count time_taken memory_used
  ) test_sizes test_names;
  printf "\n"

let benchmark_fold lists =
  printf "=== 骆言折叠操作性能测试 ===\n";
  let fold_func = get_luoyan_function "折叠" in
  (* 创建简单的加法函数 *)
  let add_func = BuiltinFunctionValue (fun args -> 
    match args with
    | [IntValue a; IntValue b] -> IntValue (a + b)
    | _ -> failwith "add function expects two integer arguments") in
  
  List.iter2 (fun size name ->
    let test_list = List.hd (List.filter (fun l -> 
      match l with ListValue lst -> List.length lst = size | _ -> false) lists) in
    let (result, time_taken) = time_function (fun _ ->
      let partial_fold = call_luoyan_function fold_func [add_func] in
      let partial_fold2 = call_luoyan_function partial_fold [IntValue 0] in
      call_luoyan_function partial_fold2 [test_list]
    ) () in
    let sum_result = match result with
      | IntValue sum -> sum
      | _ -> 0 in
    printf "%s 元素: 求和=%d, 时间=%.6f秒\n" name sum_result time_taken
  ) test_sizes test_names;
  printf "\n"

let benchmark_append _lists =
  printf "=== 骆言连接操作性能测试 ===\n";
  let concat_func = get_luoyan_function "连接" in
  
  List.iter2 (fun size name ->
    let half_size = size / 2 in
    let list1 = create_luoyan_list half_size in
    let list2 = create_luoyan_list half_size in
    let (result, time_taken) = time_function (fun _ ->
      let partial_concat = call_luoyan_function concat_func [list1] in
      call_luoyan_function partial_concat [list2]
    ) () in
    let final_length = match result with
      | ListValue lst -> List.length lst
      | _ -> 0 in
    printf "%s 元素: 连接后长度=%d, 时间=%.6f秒\n" name final_length time_taken
  ) test_sizes test_names;
  printf "\n"

(* 栈溢出测试 *)
let test_stack_overflow () =
  printf "=== 骆言栈溢出保护测试 ===\n";
  try
    let huge_list = create_luoyan_list 500000 in
    printf "创建500K元素列表: 成功\n";
    
    let length_func = get_luoyan_function "长度" in
    let _ = call_luoyan_function length_func [huge_list] in
    printf "长度计算: 无栈溢出\n";
    
    let map_func = get_luoyan_function "映射" in
    let inc_func = BuiltinFunctionValue (fun args -> 
      match args with [IntValue x] -> IntValue (x + 1) | _ -> failwith "inc error") in
    let partial_map = call_luoyan_function map_func [inc_func] in
    let _ = call_luoyan_function partial_map [huge_list] in
    printf "映射操作: 无栈溢出\n";
    
    let filter_func = get_luoyan_function "过滤" in
    let is_even_func = BuiltinFunctionValue (fun args -> 
      match args with [IntValue x] -> BoolValue (x mod 2 = 0) | _ -> failwith "even error") in
    let partial_filter = call_luoyan_function filter_func [is_even_func] in
    let _ = call_luoyan_function partial_filter [huge_list] in
    printf "过滤操作: 无栈溢出\n";
    
    let fold_func = get_luoyan_function "折叠" in
    let add_func = BuiltinFunctionValue (fun args -> 
      match args with [IntValue a; IntValue b] -> IntValue (a + b) | _ -> failwith "add error") in
    let partial_fold = call_luoyan_function fold_func [add_func] in
    let partial_fold2 = call_luoyan_function partial_fold [IntValue 0] in
    let _ = call_luoyan_function partial_fold2 [huge_list] in
    printf "折叠操作: 无栈溢出\n";
    
    printf "所有大数据集测试通过 - 骆言尾递归优化成功!\n\n"
  with
  | Stack_overflow -> printf "检测到栈溢出 - 优化失败!\n\n"
  | e -> printf "其他错误: %s\n\n" (Printexc.to_string e)

(* 性能回归测试 *)
let performance_regression_test () =
  printf "=== 骆言性能回归基准测试 ===\n";
  let test_list = create_luoyan_list 50000 in
  
  (* 长度计算基准 *)
  let length_func = get_luoyan_function "长度" in
  let (_, length_time) = time_function (call_luoyan_function length_func) [test_list] in
  printf "50K元素长度计算: %.6f秒\n" length_time;
  
  (* 映射操作基准 *)
  let map_func = get_luoyan_function "映射" in
  let double_func = BuiltinFunctionValue (fun args -> 
    match args with [IntValue x] -> IntValue (x * 2) | _ -> failwith "double error") in
  let (_, map_time) = time_function (fun _ ->
    let partial_map = call_luoyan_function map_func [double_func] in
    call_luoyan_function partial_map [test_list]
  ) () in
  printf "50K元素映射操作: %.6f秒\n" map_time;
  
  (* 过滤操作基准 *)
  let filter_func = get_luoyan_function "过滤" in
  let is_even_func = BuiltinFunctionValue (fun args -> 
    match args with [IntValue x] -> BoolValue (x mod 2 = 0) | _ -> failwith "even error") in
  let (_, filter_time) = time_function (fun _ ->
    let partial_filter = call_luoyan_function filter_func [is_even_func] in
    call_luoyan_function partial_filter [test_list]
  ) () in
  printf "50K元素过滤操作: %.6f秒\n" filter_time;
  
  (* 折叠操作基准 *)
  let fold_func = get_luoyan_function "折叠" in
  let add_func = BuiltinFunctionValue (fun args -> 
    match args with [IntValue a; IntValue b] -> IntValue (a + b) | _ -> failwith "add error") in
  let (_, fold_time) = time_function (fun _ ->
    let partial_fold = call_luoyan_function fold_func [add_func] in
    let partial_fold2 = call_luoyan_function partial_fold [IntValue 0] in
    call_luoyan_function partial_fold2 [test_list]
  ) () in
  printf "50K元素折叠操作: %.6f秒\n" fold_time;
  
  printf "\n目标: 验证骆言列表操作的尾递归优化效果\n\n"

(* 主测试函数 *)
let run_performance_tests () =
  printf "骆言列表模块性能测试套件 (修正版)\n";
  printf "Issue #2190: 列表操作尾递归优化和性能提升\n";
  printf "Author: Whisky, PR Worker\n";
  printf "修复: 测试骆言内置函数而非OCaml stdlib\n";
  printf "=========================================\n\n";
  
  (* 创建测试数据 *)
  printf "正在创建测试数据...\n";
  let test_lists = List.map create_luoyan_list test_sizes in
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
  
  printf "所有骆言性能测试完成!\n"

(* 测试入口 *)
let () = run_performance_tests ()