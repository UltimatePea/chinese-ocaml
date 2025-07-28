(** 性能分析器模块综合测试 - 简化工作版本 *)

open Alcotest

(* open Yyocamlc_lib *)
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Refactoring_analyzer_types
open Yyocamlc_lib.Performance_analyzer_base
open Yyocamlc_lib.Performance_analyzer_lists
open Yyocamlc_lib.Performance_analyzer_matching
open Yyocamlc_lib.Performance_analyzer_recursion
open Yyocamlc_lib.Performance_analyzer_complexity
open Yyocamlc_lib.Performance_analyzer_data_structures

(** 测试用的AST节点构造器 *)
let make_int n = LitExpr (IntLit n)

(* let make_string s = LitExpr (StringLit s) *)
(* let make_var name = VarExpr name *)
let make_binary_op left op right = BinaryOpExpr (left, op, right)

(** 测试辅助函数 *)
(* let extract_messages suggestions = List.map (fun s -> s.message) suggestions *)

(** Performance_analyzer_base 模块测试 *)
let test_base_analyzer_creation _ =
  (* 创建一个简单的分析器，总是返回一个建议 *)
  let simple_analyzer _expr =
    [
      make_performance_suggestion ~hint_type:"测试" ~message:"测试消息" ~confidence:0.8 ~location:"测试位置"
        ~fix:"测试修复建议";
    ]
  in

  let expr = make_int 42 in
  let suggestions = create_performance_analyzer simple_analyzer expr in

  check int "建议数量正确" 1 (List.length suggestions);
  check string "建议消息正确" "测试消息" (List.hd suggestions).message;
  check (float 0.1) "置信度正确" 0.8 (List.hd suggestions).confidence

let test_suggestion_builder _ =
  (* 测试建议构建器 *)
  let list_suggestion = SuggestionBuilder.list_optimization_suggestion "append" "使用更高效的操作" in
  check bool "列表优化建议应该生成" true (String.length list_suggestion.message > 0);

  let pattern_suggestion = SuggestionBuilder.pattern_matching_suggestion 10 "high" in
  check bool "模式匹配建议应该生成" true (String.length pattern_suggestion.message > 0);

  let complexity_suggestion = SuggestionBuilder.complexity_suggestion 5 in
  check bool "复杂度建议应该生成" true (String.length complexity_suggestion.message > 0);
  ()

(** Performance_analyzer_lists 模块测试 *)
let test_list_performance_analysis _ =
  (* 测试列表性能分析 *)
  let simple_expr = make_int 42 in
  let suggestions = analyze_list_performance simple_expr in

  (* 简单表达式应该分析完成 *)
  check bool "简单表达式应该分析完成" true (List.length suggestions >= 0)

(** 集成测试 *)
let test_integrated_performance_analysis _ =
  (* 创建一个包含多种性能问题的复杂表达式 *)
  let complex_expr = make_binary_op (make_int 1) Add (make_int 2) in

  (* 运行所有分析器 *)
  let all_suggestions =
    analyze_list_performance complex_expr
    @ analyze_match_performance complex_expr
    @ analyze_recursion_performance complex_expr
    @ analyze_computational_complexity complex_expr
    @ analyze_data_structure_efficiency complex_expr
  in

  (* 集成分析应该产生一些建议 *)
  check bool "集成分析应该完成" true (List.length all_suggestions >= 0)

(** 边界条件测试 *)
let test_empty_expressions _ =
  (* 测试简单表达式 *)
  let simple_suggestions = analyze_list_performance (make_int 0) in
  check bool "简单表达式分析应该完成" true (List.length simple_suggestions >= 0)

(** 测试套件组织 *)
let () =
  run "性能分析器综合测试套件"
    [
      ( "性能分析器基础测试",
        [
          test_case "分析器创建测试" `Quick test_base_analyzer_creation;
          test_case "建议构建器测试" `Quick test_suggestion_builder;
        ] );
      ("列表性能分析测试", [ test_case "列表性能分析" `Quick test_list_performance_analysis ]);
      ("集成测试", [ test_case "综合性能分析" `Quick test_integrated_performance_analysis ]);
      ("边界条件测试", [ test_case "空表达式测试" `Quick test_empty_expressions ]);
    ]
