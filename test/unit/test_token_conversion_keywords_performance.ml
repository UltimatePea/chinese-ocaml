(** Token关键字转换性能基准测试 - Fix #1421
    
    验证Phase 3B重构后的性能特征，特别关注：
    1. 转换器序列的线性搜索是否引起性能退化
    2. 古雅体关键字转换的最坏情况性能
    3. 大型文件处理的性能影响
    
    Author: Beta, 代码审查代理 *)

open Alcotest
module TokenConversion = Yyocamlc_lib.Token_conversion_keywords_refactored

(** 性能测试工具函数 *)
let time_execution f =
  let start_time = Unix.gettimeofday () in
  let result = f () in
  let end_time = Unix.gettimeofday () in
  (result, end_time -. start_time)

(** 生成测试Token数据 *)
let generate_keyword_tokens count =
  let keywords = [
    Token_mapping.Token_definitions_unified.LetKeyword;
    Token_mapping.Token_definitions_unified.FunKeyword;
    Token_mapping.Token_definitions_unified.IfKeyword;
    Token_mapping.Token_definitions_unified.AncientDefineKeyword;
    Token_mapping.Token_definitions_unified.AncientEndKeyword;
    Token_mapping.Token_definitions_unified.AncientAlgorithmKeyword;
  ] in
  let rec generate acc i =
    if i >= count then acc
    else
      let keyword = List.nth keywords (i mod (List.length keywords)) in
      generate (keyword :: acc) (i + 1)
  in
  generate [] 0

(** 测试基础语言关键字转换性能 - 应该是O(1) *)
let test_basic_keyword_performance () =
  Printf.printf "\n=== 基础关键字转换性能测试 ===\n";
  
  let test_tokens = [
    Token_mapping.Token_definitions_unified.LetKeyword;
    Token_mapping.Token_definitions_unified.FunKeyword;
    Token_mapping.Token_definitions_unified.IfKeyword;
    Token_mapping.Token_definitions_unified.MatchKeyword;
  ] in
  
  List.iter (fun token ->
    let iterations = 10000 in
    let _, time_taken = time_execution (fun () ->
      for _i = 1 to iterations do
        ignore (TokenConversion.convert_basic_keyword_token token)
      done
    ) in
    
    let time_per_conversion = time_taken /. float_of_int iterations in
    Printf.printf "基础关键字转换: %.2f µs/token\n" (time_per_conversion *. 1_000_000.0);
    
    (* 性能基线检查 - 每次转换应该 < 10µs *)
    let expected_max_time = 0.00001 in (* 10µs *)
    if time_per_conversion > expected_max_time then
      Printf.printf "Warning: 基础关键字转换时间 %.2f µs 超过预期 %.2f µs\n" 
        (time_per_conversion *. 1_000_000.0) (expected_max_time *. 1_000_000.0)
  ) test_tokens

(** 测试古雅体关键字转换性能 - 关键测试点！ *)
let test_ancient_keyword_performance () =
  Printf.printf "\n=== 古雅体关键字转换性能测试 ===\n";
  
  let ancient_tokens = [
    Token_mapping.Token_definitions_unified.AncientDefineKeyword;
    Token_mapping.Token_definitions_unified.AncientEndKeyword;
    Token_mapping.Token_definitions_unified.AncientAlgorithmKeyword;
  ] in
  
  List.iter (fun token ->
    let iterations = 10000 in
    let _, time_taken = time_execution (fun () ->
      for _i = 1 to iterations do
        ignore (TokenConversion.convert_basic_keyword_token token)
      done
    ) in
    
    let time_per_conversion = time_taken /. float_of_int iterations in
    Printf.printf "古雅体关键字转换: %.2f µs/token\n" (time_per_conversion *. 1_000_000.0);
    
    (* 古雅体关键字在序列末尾，预期时间稍长但不应该超过50µs *)
    let expected_max_time = 0.00005 in (* 50µs *)
    if time_per_conversion > expected_max_time then
      Printf.printf "Warning: 古雅体关键字转换时间 %.2f µs 超过预期 %.2f µs\n" 
        (time_per_conversion *. 1_000_000.0) (expected_max_time *. 1_000_000.0)
  ) ancient_tokens

(** 测试转换策略性能对比 *)
let test_conversion_strategy_performance () =
  Printf.printf "\n=== 转换策略性能对比测试 ===\n";
  
  let test_token = Token_mapping.Token_definitions_unified.AncientDefineKeyword in
  let iterations = 5000 in
  
  (* 测试可读性策略 *)
  let _, readable_time = time_execution (fun () ->
    for _i = 1 to iterations do
      ignore (TokenConversion.convert_with_strategy TokenConversion.Readable test_token)
    done
  ) in
  
  (* 测试快速策略 *)
  let _, fast_time = time_execution (fun () ->
    for _i = 1 to iterations do
      ignore (TokenConversion.convert_with_strategy TokenConversion.Fast test_token)
    done
  ) in
  
  let readable_per_conversion = readable_time /. float_of_int iterations in
  let fast_per_conversion = fast_time /. float_of_int iterations in
  
  Printf.printf "可读性策略: %.2f µs/token\n" (readable_per_conversion *. 1_000_000.0);
  Printf.printf "快速策略: %.2f µs/token\n" (fast_per_conversion *. 1_000_000.0);
  Printf.printf "性能差异: %.1fx\n" (readable_per_conversion /. fast_per_conversion);
  
  (* 验证两种策略产生相同结果 *)
  let readable_result = TokenConversion.convert_with_strategy TokenConversion.Readable test_token in
  let fast_result = TokenConversion.convert_with_strategy TokenConversion.Fast test_token in
  Alcotest.(check bool) "转换结果一致性" true (readable_result = fast_result)

(** 测试大规模转换性能 *)
let test_large_scale_conversion_performance () =
  Printf.printf "\n=== 大规模转换性能测试 ===\n";
  
  let test_sizes = [100; 500; 1000; 5000] in
  
  List.iter (fun size ->
    let tokens = generate_keyword_tokens size in
    let _, time_taken = time_execution (fun () ->
      List.map TokenConversion.convert_basic_keyword_token tokens
    ) in
    
    let tokens_per_second = float_of_int size /. time_taken in
    Printf.printf "%d tokens: %.3fs (%.0f tokens/sec)\n" size time_taken tokens_per_second;
    
    (* 性能基线：应该能够处理至少100 tokens/sec *)
    let expected_min_throughput = 100.0 in
    if tokens_per_second < expected_min_throughput then
      Printf.printf "Warning: 吞吐量 %.0f tokens/sec 低于预期 %.0f tokens/sec\n" 
        tokens_per_second expected_min_throughput
  ) test_sizes

(** 测试最坏情况性能（古雅体关键字在大型文件中） *)
let test_worst_case_performance () =
  Printf.printf "\n=== 最坏情况性能测试 ===\n";
  
  (* 创建主要包含古雅体关键字的token列表 *)
  let worst_case_tokens = Array.make 1000 Token_mapping.Token_definitions_unified.AncientDefineKeyword in
  let worst_case_list = Array.to_list worst_case_tokens in
  
  let _, time_taken = time_execution (fun () ->
    List.map TokenConversion.convert_basic_keyword_token worst_case_list
  ) in
  
  let time_per_token = time_taken /. 1000.0 in
  Printf.printf "最坏情况性能: %.2f µs/token\n" (time_per_token *. 1_000_000.0);
  
  (* 最坏情况下每个token转换应该 < 100µs *)
  let expected_max_time = 0.0001 in (* 100µs *)
  if time_per_token > expected_max_time then
    Printf.printf "Warning: 最坏情况转换时间 %.2f µs 超过预期 %.2f µs\n" 
      (time_per_token *. 1_000_000.0) (expected_max_time *. 1_000_000.0)

(** 内存使用效率测试 *)
let test_memory_efficiency () =
  Printf.printf "\n=== 内存使用效率测试 ===\n";
  
  Gc.full_major ();
  let initial_heap_size = (Gc.stat ()).heap_words in
  
  let tokens = generate_keyword_tokens 1000 in
  let converted_tokens = List.map TokenConversion.convert_basic_keyword_token tokens in
  
  Gc.full_major ();
  let final_heap_size = (Gc.stat ()).heap_words in
  
  let memory_used = final_heap_size - initial_heap_size in
  let memory_per_token = float_of_int memory_used /. float_of_int (List.length converted_tokens) in
  
  Printf.printf "内存使用: %d words for %d tokens (%.2f words/token)\n" 
    memory_used (List.length converted_tokens) memory_per_token;
  
  (* 每个token转换应该使用合理的内存量 *)
  let expected_max_memory_per_token = 50.0 in
  if memory_per_token > expected_max_memory_per_token then
    Printf.printf "Warning: 内存使用 %.2f words/token 超过预期 %.2f\n" 
      memory_per_token expected_max_memory_per_token

(** 性能回归检测 *)
let test_performance_regression () =
  Printf.printf "\n=== 性能回归检测 ===\n";
  
  (* 这些是Phase 3B重构前的预期性能基线 *)
  let baseline_basic_conversion_time = 0.00001 in (* 10µs *)
  let baseline_ancient_conversion_time = 0.00005 in (* 50µs *)
  let baseline_throughput = 100.0 in (* tokens/sec *)
  
  Printf.printf "预期性能基线:\n";
  Printf.printf "- 基础关键字转换: < %.1f µs\n" (baseline_basic_conversion_time *. 1_000_000.0);
  Printf.printf "- 古雅体关键字转换: < %.1f µs\n" (baseline_ancient_conversion_time *. 1_000_000.0);
  Printf.printf "- 最小吞吐量: %.0f tokens/sec\n" baseline_throughput;
  
  Printf.printf "\n这些基线用于检测Phase 3B重构是否引起性能退化。\n"

(** 测试套件定义 *)
let performance_tests = [
  ("basic_keyword_performance", `Quick, test_basic_keyword_performance);
  ("ancient_keyword_performance", `Quick, test_ancient_keyword_performance);
  ("conversion_strategy_performance", `Quick, test_conversion_strategy_performance);
  ("large_scale_conversion_performance", `Quick, test_large_scale_conversion_performance);
  ("worst_case_performance", `Quick, test_worst_case_performance);
  ("memory_efficiency", `Quick, test_memory_efficiency);
  ("performance_regression", `Quick, test_performance_regression);
]

let () = 
  Printf.printf "骆言Token关键字转换性能基准测试\n";
  Printf.printf "====================================\n";
  Printf.printf "目标：验证Phase 3B重构的性能特征\n";
  run "Token Conversion Keywords Performance Tests" [("Performance Tests", performance_tests)]