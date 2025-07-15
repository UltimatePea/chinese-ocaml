open Ai.Code_completion

(* 上下文感知智能补全测试 *)
let test_context_aware_completion () =
  Printf.printf "🧪 开始上下文感知智能补全测试...\n\n";

  let context = create_default_context () in
  let context = update_context context "用户列表" "列表" in
  let context = update_context context "计算结果" "整数" in
  let context = update_context context "用户名" "字符串" in
  let context = add_function_to_context context "自定义函数" [ "参数1"; "参数2" ] "字符串" in

  let test_cases =
    [
      ("让 ", 3, "变量定义上下文");
      ("函数 ", 3, "函数定义上下文");
      ("匹配 用户列表 与", 9, "模式匹配上下文");
      ("如果 计算结果 > 10 那", 15, "条件表达式上下文");
      ("打", 1, "函数调用上下文");
      ("[1; 2; 3] |> 列", 12, "列表操作上下文");
    ]
  in

  List.iteri
    (fun idx (input, cursor_pos, description) ->
      Printf.printf "🔍 测试 %d: %s\n" (idx + 1) description;
      Printf.printf "输入: '%s' (光标位置: %d)\n" input cursor_pos;

      let completions = complete_code input cursor_pos context in
      let syntax_ctx = analyze_syntax_context input cursor_pos in

      Printf.printf "语法上下文: %s\n"
        (match syntax_ctx with
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

      if List.length completions > 0 then (
        let best = List.hd completions in
        Printf.printf "   最佳建议: %s (评分: %.2f)\n" best.display_text best.score;

        (* 显示前3个结果 *)
        let take_n n lst =
          let rec aux acc n = function
            | [] -> List.rev acc
            | h :: t when n > 0 -> aux (h :: acc) (n - 1) t
            | _ -> List.rev acc
          in
          aux [] n lst
        in
        let top_3 = take_n 3 completions in
        List.iteri (fun i c -> Printf.printf "   %d. %s\n" (i + 1) (format_completion c)) top_3)
      else Printf.printf "⚠️ 未找到合适的补全建议\n";

      Printf.printf "\n")
    test_cases;

  Printf.printf "🎉 上下文感知智能补全测试完成！\n"

(* 参数建议测试 *)
let test_parameter_suggestions () =
  Printf.printf "\n🧪 开始参数建议测试...\n\n";

  let context = create_default_context () in

  let test_functions = [ "打印"; "字符串长度"; "列表头" ] in

  List.iter
    (fun func_name ->
      Printf.printf "🔍 测试函数: %s\n" func_name;
      let params = get_parameter_suggestions func_name context in
      Printf.printf "参数建议: [%s]\n" (String.concat "; " params);

      (* 测试函数调用补全 *)
      let input = func_name ^ " " in
      let completions = complete_code input (String.length input) context in
      Printf.printf "补全建议数量: %d\n" (List.length completions);
      Printf.printf "\n")
    test_functions;

  Printf.printf "🎉 参数建议测试完成！\n"

(* 语法上下文分析测试 *)
let test_syntax_context_analysis () =
  Printf.printf "\n🧪 开始语法上下文分析测试...\n\n";

  let test_cases =
    [
      ("让 变量名", "变量定义");
      ("函数 计算", "函数定义");
      ("函数 计算 参数 ->", "函数体");
      ("匹配 列表 与", "模式匹配");
      ("如果 条件", "条件表达式");
      ("[1; 2; 3]", "列表操作");
      ("", "全局");
    ]
  in

  List.iter
    (fun (input, expected_desc) ->
      let ctx = analyze_syntax_context input (String.length input) in
      let actual_desc =
        match ctx with
        | GlobalContext -> "全局"
        | FunctionDefContext -> "函数定义"
        | FunctionBodyContext -> "函数体"
        | PatternMatchContext -> "模式匹配"
        | ConditionalContext -> "条件表达式"
        | ListContext -> "列表操作"
        | VariableDefContext -> "变量定义"
        | _ -> "其他"
      in

      Printf.printf "输入: '%s' -> 预期: %s, 实际: %s %s\n" input expected_desc actual_desc
        (if expected_desc = actual_desc then "✅" else "❌"))
    test_cases;

  Printf.printf "\n🎉 语法上下文分析测试完成！\n"

(* 运行所有测试 *)
let () =
  test_context_aware_completion ();
  test_parameter_suggestions ();
  test_syntax_context_analysis ()
