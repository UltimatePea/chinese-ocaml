(* AI模块测试 - 代码补全测试 *)
open Ai.Code_completion

(* 从生产代码中提取的测试函数 *)
let test_code_completion () =
  let context = create_default_context () in
  let context = update_context context "用户列表" "列表" in
  let context = update_context context "计算结果" "整数" in
  let context = add_function_to_context context "自定义函数" [ "参数1"; "参数2" ] "字符串" in

  let test_cases =
    [
      ("让 ", 3, "变量定义");
      ("函数 ", 3, "函数定义");
      ("匹配 列表 与", 7, "模式匹配");
      ("如果 ", 3, "条件表达式");
      ("打", 1, "函数调用");
      ("用", 1, "变量引用");
    ]
  in

  List.iter
    (fun (input, cursor_pos, description) ->
      Printf.printf "\n=== 上下文感知补全测试: '%s' (位置: %d) - %s ===\n" input cursor_pos description;
      let completions = complete_code input cursor_pos context in
      Printf.printf "🔍 语法上下文: %s\n"
        (match analyze_syntax_context input cursor_pos with
        | GlobalContext -> "全局上下文"
        | FunctionDefContext -> "函数定义上下文"
        | FunctionBodyContext -> "函数体上下文"
        | PatternMatchContext -> "模式匹配上下文"
        | ConditionalContext -> "条件表达式上下文"
        | ListContext -> "列表上下文"
        | RecordContext -> "记录类型上下文"
        | VariableDefContext -> "变量定义上下文"
        | ParameterContext _ -> "参数上下文");
      Printf.printf "✅ 获得 %d 个补全建议\n" (List.length completions);
      (if List.length completions > 0 then
         let best = List.hd completions in
         Printf.printf "   最佳建议: %s (评分: %.2f)\n" best.display_text best.score);

      (* 显示前3个补全结果 *)
      let take_n n lst =
        let rec aux acc n = function
          | [] -> List.rev acc
          | h :: t when n > 0 -> aux (h :: acc) (n - 1) t
          | _ -> List.rev acc
        in
        aux [] n lst
      in
      let top_3 = take_n 3 completions in
      List.iteri (fun i c -> Printf.printf "%d. %s\n" (i + 1) (format_completion c)) top_3;

      (* 测试意图补全 *)
      Printf.printf "\n--- 意图补全 ---\n";
      let intent_completions = intent_based_completion input in
      List.iteri
        (fun i c -> Printf.printf "%d. %s\n" (i + 1) (format_completion c))
        intent_completions)
    test_cases

(* 运行测试 *)
let () = test_code_completion ()