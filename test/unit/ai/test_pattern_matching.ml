(* AI模块测试 - 模式匹配测试 *)
open Ai.Pattern_matching

(* 从生产代码中提取的测试函数 *)
let test_pattern_matching () =
  let test_cases =
    [ "创建一个递归函数计算阶乘"; "处理列表中的每个元素"; "使用条件判断检查数值"; "匹配不同的情况并处理"; "实现快速排序算法"; "定义状态机处理事件" ]
  in

  List.iter
    (fun input ->
      Printf.printf "\n=== 模式匹配测试: %s ===\n" input;
      let matches = find_best_patterns input 3 in
      List.iteri
        (fun i m ->
          Printf.printf "\n%d. %s\n" (i + 1) (format_pattern_match m);
          Printf.printf "生成代码:\n%s\n" (generate_code_from_pattern m))
        matches;

      Printf.printf "\n--- 代码意图分析 ---\n";
      Printf.printf "%s\n" (analyze_code_intent input))
    test_cases

(* 运行测试 *)
let () = test_pattern_matching ()
