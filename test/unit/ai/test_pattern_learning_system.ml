(* AI模块测试 - 模式学习系统测试 *)
open Ai.Pattern_learning_system

(* 从生产代码中提取的测试函数 *)
let test_pattern_learning_system () =
  Printf.printf "\n🧪 代码模式学习系统测试\n";
  Printf.printf "═══════════════════════════════════\n";

  (* 测试用例 *)
  let test_expressions =
    [
      SRecursiveFunctionDef
        ( "阶乘",
          [ "n" ],
          SIfThenElse
            ( SBinaryOp ("<=", SVariable "n", SLiteral "1"),
              SLiteral "1",
              SBinaryOp
                ( "*",
                  SVariable "n",
                  SFunctionCall ("阶乘", [ SBinaryOp ("-", SVariable "n", SLiteral "1") ]) ) ) );
      SIfThenElse (SBinaryOp (">", SVariable "年龄", SLiteral "18"), SLiteral "成年人", SLiteral "未成年人");
      SMatch
        ( SVariable "结果",
          [ ("成功", SVariable "值"); ("失败", SFunctionCall ("处理错误", [ SVariable "错误" ])) ] );
    ]
  in

  (* 从表达式学习模式 *)
  List.iteri
    (fun i expr ->
      Printf.printf "\n🔍 测试表达式 %d:\n" (i + 1);
      let pattern = extract_pattern expr in
      Printf.printf "   模式类型: %s\n"
        (match pattern.pattern_type with
        | FunctionPattern -> "函数模式"
        | ConditionalPattern -> "条件模式"
        | MatchPattern -> "匹配模式"
        | RecursionPattern -> "递归模式"
        | _ -> "其他模式");
      Printf.printf "   置信度: %.0f%%\n" (pattern.confidence *. 100.0);
      Printf.printf "   语义含义: %s\n" pattern.semantic_meaning;

      (* 计算复杂度 *)
      let complexity = calculate_complexity expr in
      Printf.printf "   复杂度指标:\n";
      Printf.printf "     - 圈复杂度: %d\n" complexity.cyclomatic_complexity;
      Printf.printf "     - 嵌套深度: %d\n" complexity.nesting_depth;
      Printf.printf "     - 函数长度: %d\n" complexity.function_length;

      (* 添加到模式库 *)
      pattern_store.patterns <- pattern :: pattern_store.patterns)
    test_expressions;

  (* 测试模式建议 *)
  Printf.printf "\n🎯 测试模式建议:\n";
  let suggestions = get_pattern_suggestions (List.hd test_expressions) in
  List.iteri
    (fun i suggestion ->
      Printf.printf "%d. %s (置信度: %.0f%%)\n" (i + 1)
        (match suggestion.pattern_type with
        | FunctionPattern -> "函数模式"
        | ConditionalPattern -> "条件模式"
        | RecursionPattern -> "递归模式"
        | _ -> "其他模式")
        (suggestion.confidence *. 100.0))
    suggestions;

  (* 导出学习统计 *)
  let stats = export_learning_data () in
  Printf.printf "\n%s\n" (format_learning_stats stats);

  Printf.printf "\n🎉 代码模式学习系统测试完成！\n"

(* 运行测试 *)
let () = test_pattern_learning_system ()