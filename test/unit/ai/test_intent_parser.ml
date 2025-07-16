(* AI模块测试 - 意图解析器测试 *)
open Ai.Intent_parser

(* 从生产代码中提取的测试函数 *)
let test_intent_parser () =
  let test_cases =
    [ "创建一个计算斐波那契数列的函数"; "实现阶乘计算函数"; "对列表中的所有元素乘以2"; "将列表从小到大排序"; "计算列表的长度"; "过滤出列表中的正数" ]
  in

  List.iter
    (fun input ->
      Printf.printf "\n=== 测试输入: %s ===\n" input;
      let suggestions = intelligent_completion input in
      Printf.printf "%s\n" (format_suggestions suggestions))
    test_cases

(* 运行测试 *)
let () = test_intent_parser ()