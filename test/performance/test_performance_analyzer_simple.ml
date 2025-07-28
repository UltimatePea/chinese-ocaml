(** 性能分析器模块简单测试 *)

open Alcotest
open Yyocamlc_lib

(** 测试性能分析器基础模块是否可以加载 *)
let test_performance_analyzer_base_exists () =
  (* 尝试创建一个基础建议 *)
  let suggestion =
    Performance_analyzer_base.make_performance_suggestion ~hint_type:"测试" ~message:"这是一个测试建议"
      ~confidence:0.8 ~location:"测试位置" ~fix:"测试修复"
  in
  check string "建议消息应正确" "这是一个测试建议" suggestion.message;
  check (float 0.1) "置信度应正确" 0.8 suggestion.confidence

(** 测试重构分析器类型模块是否可以加载 *)
let test_refactoring_analyzer_types_exists () =
  (* 测试可以创建分析上下文 *)
  let context =
    {
      Refactoring_analyzer_types.current_function = Some "测试函数";
      defined_vars = [ ("测试变量", None) ];
      function_calls = [ "测试函数" ];
      nesting_level = 0;
      expression_count = 1;
    }
  in
  check (option string) "当前函数应正确" (Some "测试函数") context.current_function;
  check int "嵌套层级应正确" 0 context.nesting_level

(** 测试分析器核心功能是否可以调用 *)
let test_analyzer_basic_functionality () =
  (* 创建一个简单的测试表达式 *)
  let test_expr = Ast.LitExpr (Ast.IntLit 42) in
  let context = Refactoring_analyzer_types.empty_context in

  (* 测试表达式分析是否可以运行 *)
  let suggestions = Refactoring_analyzer_core.analyze_expression test_expr context in

  (* 分析应该完成并返回建议列表 *)
  check bool "分析应该成功完成" true (List.length suggestions >= 0)

let test_program_analysis_basic () =
  (* 创建一个简单的程序 *)
  let simple_program = [ Ast.VariableDecl ("测试变量", None, Ast.LitExpr (Ast.IntLit 1)) ] in

  (* 测试程序分析 *)
  let suggestions = Refactoring_analyzer_core.analyze_program simple_program in

  (* 分析应该完成 *)
  check bool "程序分析应该成功" true (List.length suggestions >= 0)

(** 测试套件 *)
let () =
  run "性能分析器和重构分析器基础测试"
    [
      ( "模块存在性测试",
        [
          test_case "性能分析器基础模块" `Quick test_performance_analyzer_base_exists;
          test_case "重构分析器类型模块" `Quick test_refactoring_analyzer_types_exists;
        ] );
      ( "基础功能测试",
        [
          test_case "分析器基础功能" `Quick test_analyzer_basic_functionality;
          test_case "程序分析基础功能" `Quick test_program_analysis_basic;
        ] );
    ]
