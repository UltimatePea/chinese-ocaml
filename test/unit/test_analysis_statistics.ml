(** 分析统计模块测试

    测试覆盖analysis_statistics.ml模块的所有核心功能 技术债务修复：提升关键编译器分析统计模块测试覆盖率 Fix #1620

    @author Alpha代理, 主要工作代理
    @version 1.0 - 首次实现完整测试覆盖
    @since 2025-07-28 Issue #1620 分析统计模块测试覆盖改进 *)

open Alcotest
open Yyocamlc_lib.Analysis_statistics
open Yyocamlc_lib.Refactoring_analyzer_types
open Yyocamlc_lib.Ast

(** 帮助函数：检查字符串是否包含子字符串 *)
let contains_substring str sub =
  try
    let _ = Str.search_forward (Str.regexp_string sub) str 0 in
    true
  with Not_found -> false

(** 帮助函数：创建测试用建议 *)
let create_test_suggestion suggestion_type message confidence location fix =
  { suggestion_type; message; confidence; location; suggested_fix = fix }

(** 帮助函数：创建命名改进建议 *)
let create_naming_suggestion message confidence location fix =
  create_test_suggestion (NamingImprovement "建议使用中文命名") message confidence location fix

(** 帮助函数：创建复杂度建议 *)
let create_complexity_suggestion complexity message confidence location fix =
  create_test_suggestion (FunctionComplexity complexity) message confidence location fix

(** 帮助函数：创建重复代码建议 *)
let create_duplication_suggestion duplicates message confidence location fix =
  create_test_suggestion (DuplicatedCode duplicates) message confidence location fix

(** 帮助函数：创建性能提示建议 *)
let create_performance_suggestion hint message confidence location fix =
  create_test_suggestion (PerformanceHint hint) message confidence location fix

(** 测试建议统计分析功能 *)
let test_get_suggestion_statistics () =
  (* 创建各种类型的建议用于测试 *)
  let naming_suggestion1 =
    create_naming_suggestion "英文命名建议1" 0.85 (Some "test1.ml:10") (Some "使用中文")
  in
  let naming_suggestion2 =
    create_naming_suggestion "英文命名建议2" 0.75 (Some "test2.ml:20") (Some "使用中文")
  in
  let complexity_suggestion =
    create_complexity_suggestion 18 "函数过于复杂" 0.90 (Some "func.ml:5") (Some "简化逻辑")
  in
  let duplication_suggestion =
    create_duplication_suggestion [ "func1"; "func2" ] "重复代码检测" 0.70 (Some "dup.ml:15")
      (Some "提取公共函数")
  in
  let performance_suggestion =
    create_performance_suggestion "列表操作优化" "性能改进建议" 0.80 (Some "perf.ml:25") (Some "使用更高效算法")
  in

  let suggestions =
    [
      naming_suggestion1;
      naming_suggestion2;
      complexity_suggestion;
      duplication_suggestion;
      performance_suggestion;
    ]
  in
  let ( total,
        (naming_count, complexity_count, duplication_count, performance_count),
        (high_count, medium_count, low_count) ) =
    get_suggestion_statistics suggestions
  in

  (* 验证总数统计 *)
  check int "建议总数应正确" 5 total;

  (* 验证按类型分类统计 *)
  check int "命名建议统计应正确" 2 naming_count;
  check int "复杂度建议统计应正确" 1 complexity_count;
  check int "重复代码建议统计应正确" 1 duplication_count;
  check int "性能建议统计应正确" 1 performance_count;

  (* 验证按优先级分类统计 (基于置信度) *)
  check int "高优先级建议统计应正确" 3 high_count;
  (* confidence >= 0.8: 0.85, 0.90, 0.80 = 3个 *)
  check int "中优先级建议统计应正确" 2 medium_count;
  (* 0.6 <= confidence < 0.8: 0.75, 0.70 *)
  check int "低优先级建议统计应正确" 0 low_count;

  (* confidence < 0.6: 无 *)

  (* 测试空列表情况 *)
  let empty_total, (en, ec, ed, ep), (eh, em, el) = get_suggestion_statistics [] in
  check int "空列表总数应为0" 0 empty_total;
  check int "空列表命名统计应为0" 0 en;
  check int "空列表复杂度统计应为0" 0 ec;
  check int "空列表重复代码统计应为0" 0 ed;
  check int "空列表性能统计应为0" 0 ep;
  check int "空列表高优先级统计应为0" 0 eh;
  check int "空列表中优先级统计应为0" 0 em;
  check int "空列表低优先级统计应为0" 0 el;

  (* 测试单一类型建议 *)
  let single_suggestions = [ naming_suggestion1 ] in
  let single_total, (sn, sc, sd, sp), (_, _, _) = get_suggestion_statistics single_suggestions in
  check int "单一建议总数应为1" 1 single_total;
  check int "单一命名建议统计应为1" 1 sn;
  check int "单一建议其他类型应为0" 0 sc;
  check int "单一建议其他类型应为0" 0 sd;
  check int "单一建议其他类型应为0" 0 sp

(** 测试快速质量检查功能 *)
let test_quick_quality_check () =
  (* 创建简单的测试程序 *)
  let test_program =
    [
      LetStmt ("variable", VarExpr "test");
      ExprStmt (VarExpr "x");
      RecLetStmt ("temp", FunExpr ([ "param" ], VarExpr "param"));
    ]
  in

  let report = quick_quality_check test_program in

  (* 验证报告包含关键信息 *)
  check bool "报告应包含标题" true (contains_substring report "📊");
  check bool "报告应包含代码质量检查信息" true (contains_substring report "代码质量快速检查");
  check bool "报告应包含总问题数信息" true (contains_substring report "总问题数");
  check bool "报告应包含高优先级信息" true (contains_substring report "高优先级");
  check bool "报告应包含命名问题信息" true (contains_substring report "命名问题");
  check bool "报告应包含复杂度问题信息" true (contains_substring report "复杂度问题");
  check bool "报告应包含重复代码信息" true (contains_substring report "重复代码");
  check bool "报告应包含性能问题信息" true (contains_substring report "性能问题");

  (* 测试空程序情况 *)
  let empty_program = [] in
  let empty_report = quick_quality_check empty_program in
  check bool "空程序报告应包含标题" true (contains_substring empty_report "📊");
  check bool "空程序报告应显示0个问题" true (contains_substring empty_report "总问题数: 0")

(** 测试置信度分类边界条件 *)
let test_confidence_boundary_conditions () =
  (* 创建边界置信度值的建议 *)
  let exact_high_boundary = create_naming_suggestion "高置信度边界" 0.8 None None in
  let exact_medium_boundary = create_naming_suggestion "中置信度边界" 0.6 None None in
  let just_below_high = create_naming_suggestion "略低于高置信度" 0.79 None None in
  let just_below_medium = create_naming_suggestion "略低于中置信度" 0.59 None None in
  let very_high = create_naming_suggestion "极高置信度" 1.0 None None in
  let very_low = create_naming_suggestion "极低置信度" 0.0 None None in

  let boundary_suggestions =
    [
      exact_high_boundary;
      exact_medium_boundary;
      just_below_high;
      just_below_medium;
      very_high;
      very_low;
    ]
  in
  let _, _, (high, medium, low) = get_suggestion_statistics boundary_suggestions in

  (* 验证边界条件分类 *)
  check int "高置信度边界处理应正确" 2 high;
  (* 0.8, 1.0 *)
  check int "中置信度边界处理应正确" 2 medium;
  (* 0.79, 0.6 *)
  check int "低置信度边界处理应正确" 2 low (* 0.59, 0.0 *)

(** 测试不同建议类型混合统计 *)
let test_mixed_suggestion_types () =
  (* 创建混合类型建议集合 *)
  let mixed_suggestions =
    [
      create_naming_suggestion "命名建议1" 0.9 None None;
      create_naming_suggestion "命名建议2" 0.7 None None;
      create_complexity_suggestion 10 "复杂度建议1" 0.85 None None;
      create_complexity_suggestion 20 "复杂度建议2" 0.6 None None;
      create_duplication_suggestion [ "a"; "b" ] "重复代码建议" 0.75 None None;
      create_performance_suggestion "优化建议" "性能建议1" 0.8 None None;
      create_performance_suggestion "缓存建议" "性能建议2" 0.5 None None;
    ]
  in

  let total, (naming, complexity, duplication, performance), (high, medium, low) =
    get_suggestion_statistics mixed_suggestions
  in

  (* 验证混合类型统计 *)
  check int "混合建议总数应正确" 7 total;
  check int "混合命名建议统计" 2 naming;
  check int "混合复杂度建议统计" 2 complexity;
  check int "混合重复代码建议统计" 1 duplication;
  check int "混合性能建议统计" 2 performance;

  (* 验证优先级分布 *)
  check int "混合高优先级统计" 3 high;
  (* 0.9, 0.85, 0.8 *)
  check int "混合中优先级统计" 3 medium;
  (* 0.7, 0.6, 0.75 *)
  check int "混合低优先级统计" 1 low (* 0.5 *)

(** 测试大量建议的性能和准确性 *)
let test_large_suggestion_set () =
  (* 创建大量建议用于性能测试 *)
  let large_suggestions = ref [] in
  for i = 1 to 100 do
    let confidence = float_of_int i /. 100.0 in
    let suggestion =
      create_naming_suggestion
        ("建议" ^ string_of_int i)
        confidence
        (Some ("file" ^ string_of_int i ^ ".ml"))
        (Some ("修复" ^ string_of_int i))
    in
    large_suggestions := suggestion :: !large_suggestions
  done;

  let total, (naming, complexity, duplication, performance), (high, medium, low) =
    get_suggestion_statistics !large_suggestions
  in

  (* 验证大量数据统计 *)
  check int "大量建议总数应正确" 100 total;
  check int "大量建议命名统计应正确" 100 naming;
  check int "大量建议其他类型应为0" 0 complexity;
  check int "大量建议其他类型应为0" 0 duplication;
  check int "大量建议其他类型应为0" 0 performance;

  (* 验证优先级分布 (confidence从0.01到1.00) *)
  check int "大量建议高优先级统计" 21 high;
  (* 0.80-1.00: 21个 *)
  check int "大量建议中优先级统计" 20 medium;
  (* 0.60-0.79: 20个 *)
  check int "大量建议低优先级统计" 59 low (* 0.01-0.59: 59个 *)

(** 测试极端情况处理 *)
let test_extreme_cases () =
  (* 测试极端置信度值 *)
  let extreme_high = create_naming_suggestion "极高置信度" 999.0 None None in
  let extreme_low = create_naming_suggestion "极低置信度" (-1.0) None None in
  let nan_confidence = create_naming_suggestion "NaN置信度" nan None None in

  let extreme_suggestions = [ extreme_high; extreme_low; nan_confidence ] in
  let total, _, (_, _, _) = get_suggestion_statistics extreme_suggestions in

  (* 验证极端情况处理 *)
  check int "极端情况总数应正确" 3 total;

  (* 测试建议类型为None的情况 - 这需要更复杂的设置，先跳过 *)
  (* 测试报告生成的健壮性 *)
  let extreme_program = [ LetStmt ("", VarExpr ""); ExprStmt (VarExpr "") ] in
  let extreme_report = quick_quality_check extreme_program in
  check bool "极端程序报告应包含基本结构" true (contains_substring extreme_report "📊")

(** 测试报告格式的国际化和中文支持 *)
let test_chinese_report_formatting () =
  let chinese_program =
    [ LetStmt ("变量名", VarExpr "测试"); RecLetStmt ("函数名", FunExpr ([ "参数" ], VarExpr "参数")) ]
  in

  let chinese_report = quick_quality_check chinese_program in

  (* 验证中文字符在报告中正确显示 *)
  check bool "报告应正确处理中文字符" true (contains_substring chinese_report "代码质量");
  check bool "报告应包含中文统计标签" true (contains_substring chinese_report "总问题数");
  check bool "报告应包含中文分类标签" true (contains_substring chinese_report "命名问题");

  (* 验证报告格式的一致性 *)
  check bool "报告应有一致的格式结构" true
    (contains_substring chinese_report "====" && contains_substring chinese_report "个\n")

(** 测试与其他模块集成的数据流 *)
let test_integration_data_flow () =
  (* 测试建议统计与analysis_engine模块的集成 *)
  let integration_program =
    [
      LetStmt ("variable", VarExpr "test");
      RecLetStmt ("function", FunExpr ([ "param" ], VarExpr "param"));
      ExprStmt (BinaryOpExpr (VarExpr "a", Add, VarExpr "b"));
    ]
  in

  let integration_report = quick_quality_check integration_program in

  (* 验证集成数据流的完整性 *)
  check bool "集成报告应包含分析结果" true (contains_substring integration_report "📊");
  check bool "集成数据应通过analysis_engine处理" true (String.length integration_report > 100);

  (* 确保有实际内容生成 *)

  (* 测试空输入的集成处理 *)
  let empty_integration_report = quick_quality_check [] in
  check bool "空输入集成应正常处理" true (contains_substring empty_integration_report "📊")

(** 测试套件定义 *)
let () =
  run "分析统计模块测试"
    [
      ("建议统计分析", [ test_case "get_suggestion_statistics基础功能" `Quick test_get_suggestion_statistics ]);
      ("快速质量检查", [ test_case "quick_quality_check基础功能" `Quick test_quick_quality_check ]);
      ("置信度边界条件", [ test_case "置信度分类边界处理" `Quick test_confidence_boundary_conditions ]);
      ("混合建议类型", [ test_case "不同类型建议混合统计" `Quick test_mixed_suggestion_types ]);
      ("大量数据处理", [ test_case "大量建议性能和准确性" `Quick test_large_suggestion_set ]);
      ("极端情况处理", [ test_case "各种极端情况健壮性" `Quick test_extreme_cases ]);
      ("中文报告格式", [ test_case "中文字符和格式化支持" `Quick test_chinese_report_formatting ]);
      ("模块集成测试", [ test_case "与其他模块数据流集成" `Quick test_integration_data_flow ]);
    ]
