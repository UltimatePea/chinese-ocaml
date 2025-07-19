(** 智能代码重构建议功能测试 *)

open Yyocamlc_lib.Ast
open Yyocamlc_lib.Refactoring_analyzer
open Yyocamlc_lib.Refactoring_analyzer_types

(* 测试辅助函数 *)
let run_test test_name test_func =
  try
    test_func ();
    Printf.printf "✅ %s\n" test_name;
    true
  with e ->
    Printf.printf "❌ %s: %s\n" test_name (Printexc.to_string e);
    false

(* 测试命名质量分析 *)
let test_naming_analysis () =
  let suggestions = Naming.analyze_naming_quality "userName" in
  assert (List.length suggestions > 0);

  let suggestions2 = Naming.analyze_naming_quality "用户姓名" in
  assert (List.length suggestions2 = 0);

  let suggestions3 = Naming.analyze_naming_quality "x" in
  assert (List.length suggestions3 > 0);

  let suggestions4 = Naming.analyze_naming_quality "user用户" in
  assert (List.length suggestions4 > 0)

(* 测试函数复杂度分析 *)
let test_function_complexity () =
  let context = empty_context in

  (* 简单函数 - 不应该触发建议 *)
  let simple_expr = BinaryOpExpr (make_int 1, Add, make_int 2) in
  let suggestion = Complexity.analyze_function_complexity "简单函数" simple_expr context in
  assert (suggestion = None);

  (* 复杂函数 - 应该触发建议 *)
  let complex_expr =
    CondExpr
      ( BinaryOpExpr (make_var "x", Gt, make_int 0),
        CondExpr
          ( BinaryOpExpr (make_var "x", Lt, make_int 10),
            CondExpr
              ( BinaryOpExpr (make_var "x", Neq, make_int 5),
                FunCallExpr (make_var "处理", [ make_var "x" ]),
                make_int 0 ),
            make_int 1 ),
        make_int (-1) )
  in
  let suggestion = Complexity.analyze_function_complexity "复杂函数" complex_expr context in
  assert (suggestion <> None)

(* 测试表达式分析 *)
let test_expression_analysis () =
  let context = empty_context in

  (* 测试变量命名建议 *)
  let expr = VarExpr "temp" in
  let suggestions = analyze_expression expr context in
  assert (List.length suggestions > 0);

  (* 测试Let表达式 *)
  let let_expr = LetExpr ("userName", make_string "张三", make_var "userName") in
  let suggestions = analyze_expression let_expr context in
  assert (List.length suggestions > 0)

(* 测试重复代码检测 *)
let test_duplication_detection () =
  let exprs =
    [
      BinaryOpExpr (make_var "a", Add, make_var "b");
      BinaryOpExpr (make_var "c", Add, make_var "d");
      BinaryOpExpr (make_var "e", Add, make_var "f");
      BinaryOpExpr (make_var "g", Add, make_var "h");
    ]
  in
  let suggestions = Duplication.detect_code_duplication exprs in
  assert (List.length suggestions > 0)

(* 测试性能提示 *)
let test_performance_hints () =
  let context = empty_context in

  (* 测试大量分支的匹配表达式 *)
  let branches =
    Array.to_list (Array.make 15 { pattern = WildcardPattern; guard = None; expr = make_int 1 })
  in
  let match_expr = MatchExpr (make_var "值", branches) in
  let suggestions = Performance.analyze_performance_hints match_expr context in
  assert (List.length suggestions > 0)

(* 测试程序分析 *)
let test_program_analysis () =
  let program =
    [
      LetStmt ("userName", make_string "张三");
      LetStmt ("userAge", make_int 25);
      RecLetStmt
        ( "复杂函数",
          CondExpr
            ( BinaryOpExpr (make_var "x", Gt, make_int 0),
              CondExpr
                ( BinaryOpExpr (make_var "x", Lt, make_int 10),
                  FunCallExpr (make_var "处理", [ make_var "x" ]),
                  make_int 0 ),
              make_int (-1) ) );
    ]
  in

  let suggestions = analyze_program program in
  assert (List.length suggestions > 0);

  (* 测试报告生成 *)
  let report = generate_refactoring_report suggestions in
  assert (String.length report > 0);
  Printf.printf "\n📋 示例重构报告:\n%s\n" report

(* 测试建议格式化 *)
let test_suggestion_formatting () =
  let suggestion =
    {
      suggestion_type = NamingImprovement "改进建议";
      message = "变量名建议改进";
      confidence = 0.85;
      location = Some "函数内部";
      suggested_fix = Some "使用更描述性的名称";
    }
  in

  let formatted = format_suggestion suggestion in
  assert (String.length formatted > 0)

(* 测试上下文更新 *)
let test_context_management () =
  let context = empty_context in
  let new_context =
    { context with current_function = Some "测试函数"; nesting_level = 2; expression_count = 5 }
  in

  assert (new_context.current_function = Some "测试函数");
  assert (new_context.nesting_level = 2);
  assert (new_context.expression_count = 5)

(* 主测试函数 *)
let run_all_tests () =
  Printf.printf "🧪 开始智能代码重构建议功能测试...\n\n";

  let tests =
    [
      ("命名质量分析", test_naming_analysis);
      ("函数复杂度分析", test_function_complexity);
      ("表达式分析", test_expression_analysis);
      ("重复代码检测", test_duplication_detection);
      ("性能提示", test_performance_hints);
      ("程序分析", test_program_analysis);
      ("建议格式化", test_suggestion_formatting);
      ("上下文管理", test_context_management);
    ]
  in

  let results = List.map (fun (name, test_func) -> run_test name test_func) tests in
  let passed = List.filter (fun x -> x) results |> List.length in
  let total = List.length results in

  Printf.printf "\n🎉 智能代码重构建议功能测试完成！\n";
  Printf.printf "📊 测试统计:\n";
  Printf.printf "   • 通过: %d/%d\n" passed total;
  Printf.printf "   • 失败: %d/%d\n" (total - passed) total;

  if passed = total then Printf.printf "   • 状态: ✅ 所有测试通过\n"
  else Printf.printf "   • 状态: ❌ 部分测试失败\n";

  passed = total

(* 运行测试 *)
let () =
  let success = run_all_tests () in
  exit (if success then 0 else 1)
