(** Token转换器性能测试
    验证查找表优化的性能提升
    
    Author: Alpha, 主要工作代理
    Date: 2025-07-27 *)

open Yyocamlc_lib.Token_converter_unified

(** 创建测试数据集 *)
let test_tokens = [
  (* 基础关键字 *)
  "让"; "let"; "函数"; "fun"; "在"; "in"; "递归"; "rec";
  "类型"; "type"; "私有"; "private"; "并且"; "and"; "作为"; "as";
  (* 类型关键字 *)
  "整数"; "int"; "浮点数"; "float"; "字符串"; "string"; "布尔"; "bool";
  "单元"; "unit"; "列表"; "list"; "数组"; "array"; "选项"; "option";
  (* 控制流关键字 *)
  "如果"; "if"; "那么"; "then"; "否则"; "else"; "匹配"; "match";
  "与"; "with"; "当"; "when"; "尝试"; "try";
  (* 操作符 *)
  "+"; "-"; "*"; "/"; "%"; "**"; "="; "<>"; "!="; "<"; "<="; ">";
  ">="; "&&"; "||"; "not"; "非"; ":="; "!"; "ref"; "引用";
  (* 分隔符 *)
  "("; ")"; "{"; "}"; "["; "]"; ";"; ","; "."; ":"; "::";
  (* 一些无效tokens用于测试错误路径 *)
  "未知关键字"; "invalid_operator"; "不存在";
]

(** 测量执行时间 *)
let time_it f =
  let start = Sys.time () in
  let result = f () in
  let time_taken = Sys.time () -. start in
  (result, time_taken)

(** 批量转换测试 *)
let batch_convert_test tokens iterations =
  let rec loop i acc =
    if i <= 0 then acc
    else
      let results = List.map (fun token -> convert token) tokens in
      loop (i - 1) (results @ acc)
  in
  loop iterations []

(** 性能基准测试 *)
let performance_benchmark () =
  let iterations = 10000 in
  
  Printf.printf "=== Token转换器性能基准测试 ===\n";
  Printf.printf "测试数据: %d个tokens\n" (List.length test_tokens);
  Printf.printf "迭代次数: %d\n" iterations;
  Printf.printf "总转换操作: %d\n\n" (List.length test_tokens * iterations);
  
  (* 执行基准测试 *)
  let (results, time_taken) = time_it (fun () ->
    batch_convert_test test_tokens iterations
  ) in
  
  let total_ops = List.length test_tokens * iterations in
  let ops_per_second = float_of_int total_ops /. time_taken in
  
  Printf.printf "执行时间: %.4f 秒\n" time_taken;
  Printf.printf "转换速度: %.0f 操作/秒\n" ops_per_second;
  Printf.printf "平均每次转换: %.2f 微秒\n" (time_taken *. 1_000_000.0 /. float_of_int total_ops);
  
  (* 验证结果正确性 - 取第一批结果进行验证 *)
  let rec take n lst = 
    if n <= 0 then [] 
    else match lst with [] -> [] | h :: t -> h :: take (n-1) t in
  let first_batch = take (List.length test_tokens) results in
  let successful_conversions = List.fold_left (fun acc result ->
    match result with Some _ -> acc + 1 | None -> acc
  ) 0 first_batch in
  
  Printf.printf "\n结果验证:\n";
  Printf.printf "成功转换: %d/%d (%.1f%%)\n" 
    successful_conversions 
    (List.length test_tokens)
    (100.0 *. float_of_int successful_conversions /. float_of_int (List.length test_tokens));
  
  Printf.printf "\n=== 性能测试完成 ===\n"

(** 单元测试 *)
let unit_tests () =
  Printf.printf "=== 优化后功能验证测试 ===\n";
  
  (* 测试基础关键字转换 *)
  let test_cases = [
    ("让", "BasicKeyword");
    ("函数", "BasicKeyword");
    ("整数", "TypeKeyword");
    ("如果", "ControlKeyword");
    ("有", "ClassicalKeyword");
    ("+", "OperatorToken");
    ("(", "DelimiterToken");
    ("42", "IntToken");
    ("不存在的token", "None");
  ] in
  
  List.iteri (fun i (input, expected_type) ->
    let result = convert input in
    let result_str = match result with
      | Some (BasicKeyword _) -> "BasicKeyword"
      | Some (TypeKeyword _) -> "TypeKeyword"
      | Some (ControlKeyword _) -> "ControlKeyword"
      | Some (ClassicalKeyword _) -> "ClassicalKeyword"
      | Some (OperatorToken _) -> "OperatorToken"
      | Some (DelimiterToken _) -> "DelimiterToken"
      | Some (IntToken _) -> "IntToken"
      | Some _ -> "Other"
      | None -> "None"
    in
    
    let status = if result_str = expected_type then "✓" else "✗" in
    Printf.printf "%s 测试 %d: '%s' -> %s (期望: %s)\n" 
      status (i + 1) input result_str expected_type
  ) test_cases;
  
  Printf.printf "\n=== 功能验证测试完成 ===\n\n"

(** 主测试函数 *)
let () =
  unit_tests ();
  performance_benchmark ()