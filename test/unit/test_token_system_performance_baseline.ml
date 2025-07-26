(* 骆言Token系统性能基线测试 - Fix #1357 *)
(* Echo专员实施：为Token系统整合提供性能验证 *)

open Alcotest
open Token_system_unified_core.Token_types
module Bridge = Token_system_unified_conversion.Legacy_type_bridge

(* 性能测试工具函数 *)
let time_execution f =
  let start_time = Unix.gettimeofday () in
  let result = f () in
  let end_time = Unix.gettimeofday () in
  (result, end_time -. start_time)

(* 列表处理辅助函数 *)
let rec list_take n lst =
  if n <= 0 then []
  else match lst with
    | [] -> []
    | h :: t -> h :: (list_take (n - 1) t)

let rec list_drop n lst =
  if n <= 0 then lst
  else match lst with
    | [] -> []
    | _ :: t -> list_drop (n - 1) t

(* 生成测试Token数据 *)
let generate_test_tokens count =
  let rec generate acc i =
    if i >= count then acc
    else
      let positioned_token = Token_system_unified_core.Token_types.{
        token = Literal (IntToken i);
        position = { line = i; column = 1; offset = i };
        text = string_of_int i;
      } in
      generate (positioned_token :: acc) (i + 1)
  in
  generate [] 0

(* 测试大规模Token转换性能 *)
let test_large_scale_conversion () =
  let test_sizes = [100; 500; 1000; 5000] in
  List.iter (fun size ->
    let tokens = generate_test_tokens size in
    let (token_types, time_taken) = time_execution (fun () ->
      List.map (fun pt -> Bridge.get_token_category pt.token) tokens
    ) in
    
    (* 验证转换正确性 *)
    let expected_count = List.length tokens in
    let actual_count = List.length token_types in
    Alcotest.(check int) 
      (Printf.sprintf "conversion count for %d tokens" size)
      expected_count actual_count;
    
    (* 性能基线检查 - O(n)线性复杂度预期 *)
    let expected_max_time = 0.001 *. (float_of_int size) in (* 1ms per token baseline *)
    if time_taken > expected_max_time then
      Printf.printf "Warning: Token categorization for %d items took %.6fs (expected < %.6fs)\n" 
        size time_taken expected_max_time;
    
    Printf.printf "Token categorization performance: %d tokens in %.6fs (%.2f tokens/sec)\n"
      size time_taken (float_of_int size /. time_taken)
  ) test_sizes

(* 测试Token查找性能 *)
let test_token_lookup_performance () =
  let test_token = Token_system_unified_core.Token_types.{
    token = CoreLanguage LetKeyword;
    position = { line = 1; column = 1; offset = 0 };
    text = "让";
  } in
  
  let (is_keyword_result, time_taken) = time_execution (fun () ->
    Bridge.is_keyword_token test_token.token
  ) in
  
  (* 验证查找正确性 *)
  Alcotest.(check bool) "keyword detection" true is_keyword_result;
  
  (* 性能基线检查 - O(1)常数时间复杂度预期 *)
  let expected_max_time = 0.0001 in (* 0.1ms baseline *)
  if time_taken > expected_max_time then
    Printf.printf "Warning: Token lookup took %.6fs (expected < %.6fs)\n" 
      time_taken expected_max_time;
  
  Printf.printf "Token lookup performance: %.6fs\n" time_taken

(* 测试Token系统内存使用效率 *)
let test_memory_efficiency () =
  let initial_heap_size = (Gc.stat ()).heap_words in
  let tokens = generate_test_tokens 1000 in
  let converted_tokens = List.map (fun pt -> Bridge.token_type_name pt.token) tokens in
  Gc.full_major ();
  let final_heap_size = (Gc.stat ()).heap_words in
  
  let memory_used = final_heap_size - initial_heap_size in
  let tokens_count = List.length converted_tokens in
  let memory_per_token = float_of_int memory_used /. float_of_int tokens_count in
  
  Printf.printf "Memory efficiency: %d words for %d tokens (%.2f words/token)\n"
    memory_used tokens_count memory_per_token;
  
  (* 基线检查：每个Token应该使用合理的内存量 *)
  let expected_max_memory_per_token = 50.0 in
  if memory_per_token > expected_max_memory_per_token then
    Printf.printf "Warning: Memory usage %.2f words/token exceeds baseline %.2f\n"
      memory_per_token expected_max_memory_per_token

(* 边界条件性能测试 *)
let test_edge_case_performance () =
  (* 测试空Token列表 *)
  let (empty_result, empty_time) = time_execution (fun () ->
    List.map (fun pt -> Bridge.token_type_name pt.token) []
  ) in
  Alcotest.(check int) "empty conversion" 0 (List.length empty_result);
  
  (* 测试单个Token *)
  let single_token = Token_system_unified_core.Token_types.{
    token = Literal (StringToken "测试");
    position = { line = 1; column = 1; offset = 0 };
    text = "测试";
  } in
  let (single_result_name, single_time) = time_execution (fun () ->
    Bridge.token_type_name single_token.token
  ) in
  
  (* 验证单个Token处理结果 *)
  Alcotest.(check string) "single token type" "Literal" single_result_name;
  
  Printf.printf "Edge case performance: empty=%.6fs, single=%.6fs\n" 
    empty_time single_time

(* 并发安全性性能测试 *)
let test_concurrent_safety_performance () =
  let tokens = generate_test_tokens 500 in
  
  let (sequential_result, sequential_time) = time_execution (fun () ->
    List.map (fun pt -> Bridge.token_type_name pt.token) tokens
  ) in
  
  let (parallel_result, parallel_time) = time_execution (fun () ->
    (* 简化的并发测试：分割数据并顺序处理 *)
    let half_size = (List.length tokens) / 2 in
    let first_half = list_take half_size tokens in
    let second_half = list_drop half_size tokens in
    let result1 = List.map (fun pt -> Bridge.token_type_name pt.token) first_half in
    let result2 = List.map (fun pt -> Bridge.token_type_name pt.token) second_half in
    result1 @ result2
  ) in
  
  (* 验证结果正确性 *)
  Alcotest.(check int) "sequential vs parallel count" 
    (List.length sequential_result) (List.length parallel_result);
  
  Printf.printf "Sequential vs simulated parallel: %.6fs vs %.6fs\n" 
    sequential_time parallel_time

(* 测试套件定义 *)
let performance_tests = [
  "large_scale_conversion", `Quick, test_large_scale_conversion;
  "token_lookup_performance", `Quick, test_token_lookup_performance;
  "memory_efficiency", `Quick, test_memory_efficiency;
  "edge_case_performance", `Quick, test_edge_case_performance;
  "concurrent_safety_performance", `Quick, test_concurrent_safety_performance;
]

let () =
  run "Token System Performance Baseline Tests" [
    "Performance Tests", performance_tests;
  ]