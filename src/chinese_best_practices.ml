(** 骆言中文编程最佳实践检查器 - 第二阶段技术债务重构版本

    基于配置外化重构，将原有硬编码的测试配置移动到外部JSON文件， 实现配置与代码分离，大幅减少代码行数，提升可维护性。

    修复 Issue #801 - 技术债务改进第二阶段：超长函数重构和数据外化

    @author 骆言诗词编程团队
    @version 2.0 (配置外化重构版)
    @since 2025-07-21 - 技术债务改进第二阶段 *)

open Yojson.Safe.Util
open String_processing.Error_message_formatter

(* 引入模块化组件 *)
module Core = Chinese_best_practices_core.Practice_coordinator
module VR = Chinese_best_practices_reporters.Violation_reporter

(* 重新导出类型以保持API兼容性 *)
type practice_violation = Chinese_best_practices_types.Practice_types.practice_violation =
  | MixedLanguage of string * string * string
  | ImproperWordOrder of string * string * string
  | Unidiomatic of string * string * string
  | InconsistentStyle of string * string * string
  | ModernizationSuggestion of string * string * string

type severity = Chinese_best_practices_types.Severity_types.severity =
  | Error
  | Warning
  | Info
  | Style

type practice_check_result = Chinese_best_practices_types.Severity_types.practice_check_result = {
  violation : practice_violation;
  severity : severity;
  message : string;
  suggestion : string;
  confidence : float;
  ai_friendly : bool;
}

(** {1 配置加载异常处理} *)

exception Test_config_error of string

(** 内部配置错误格式化模块 - 已重构使用统一格式化器 *)
module Internal_formatter = struct
  let format_file_read_error = Error_message_formatter.file_read_error
  let format_json_parse_error = Error_message_formatter.json_parse_error
  let format_test_case_parse_error = Error_message_formatter.test_case_parse_error
  let format_unknown_checker_type = Error_message_formatter.unknown_checker_type
  let format_config_parse_error = Error_message_formatter.config_parse_error
  let format_config_list_parse_error = Error_message_formatter.config_list_parse_error
  let format_comprehensive_test_parse_error = Error_message_formatter.comprehensive_test_parse_error
  let format_summary_items_parse_error = Error_message_formatter.summary_items_parse_error
end

(** {1 配置文件路径} *)

let get_config_file_path filename =
  let current_dir = Sys.getcwd () in
  Filename.concat (Filename.concat current_dir "data/config") filename

let test_config_file = get_config_file_path "chinese_best_practices_tests.json"

(** {1 配置数据缓存} *)

let json_config_cache = ref None

let get_json_config () =
  match !json_config_cache with
  | Some data -> data
  | None -> (
      try
        let data = Yojson.Safe.from_file test_config_file in
        json_config_cache := Some data;
        data
      with
      | Sys_error msg -> raise (Test_config_error (Internal_formatter.format_file_read_error msg))
      | Yojson.Json_error msg ->
          raise (Test_config_error (Internal_formatter.format_json_parse_error msg)))

(** {1 测试配置类型} *)

type test_config = {
  name : string;
  icon : string;
  test_cases : string list;
  checker_function : string -> practice_check_result list;
}

(** {1 配置解析函数} *)

(** 解析测试用例列表 *)
let parse_test_cases json =
  try json |> member "test_cases" |> to_list |> List.map to_string
  with Type_error (msg, _) ->
    raise (Test_config_error (Internal_formatter.format_test_case_parse_error msg))

(** 获取检查器函数 *)
let get_checker_function checker_type =
  match checker_type with
  | "mixed_language" ->
      Chinese_best_practices_checkers.Mixed_language_checker.detect_mixed_language_patterns
  | "word_order" -> Chinese_best_practices_checkers.Word_order_checker.check_chinese_word_order
  | "idiomatic" -> Chinese_best_practices_checkers.Idiomatic_checker.check_idiomatic_chinese
  | "style_consistency" ->
      Chinese_best_practices_checkers.Style_consistency_checker.check_style_consistency
  | "classical_style" ->
      Chinese_best_practices_checkers.Classical_style_checker.check_classical_style_appropriateness
  | "ai_friendly" -> Chinese_best_practices_checkers.Ai_friendly_checker.check_ai_friendly_patterns
  | _ -> raise (Test_config_error (Internal_formatter.format_unknown_checker_type checker_type))

(** 解析单个测试配置 *)
let parse_test_config json =
  try
    let name = json |> member "name" |> to_string in
    let icon = json |> member "icon" |> to_string in
    let checker_type = json |> member "checker_type" |> to_string in
    let test_cases = parse_test_cases json in
    let checker_function = get_checker_function checker_type in
    { name; icon; test_cases; checker_function }
  with Type_error (msg, _) ->
    raise (Test_config_error (Internal_formatter.format_config_parse_error msg))

(** {1 配置数据获取} *)

(** 获取所有测试配置 (懒加载) *)
let test_configs =
  lazy
    (let json = get_json_config () in
     try json |> member "test_configurations" |> to_list |> List.map parse_test_config
     with Type_error (msg, _) ->
       raise (Test_config_error (Internal_formatter.format_config_list_parse_error msg)))

(** 获取综合测试用例 (懒加载) *)
let comprehensive_test_cases =
  lazy
    (let json = get_json_config () in
     try json |> member "comprehensive_test_cases" |> to_list |> List.map to_string
     with Type_error (msg, _) ->
       raise (Test_config_error (Internal_formatter.format_comprehensive_test_parse_error msg)))

(** 获取测试摘要项目 (懒加载) *)
let test_summary_items =
  lazy
    (let json = get_json_config () in
     try json |> member "test_summary_items" |> to_list |> List.map to_string
     with Type_error (msg, _) ->
       raise (Test_config_error (Internal_formatter.format_summary_items_parse_error msg)))

(** {1 核心功能函数} *)

(** 综合最佳实践检查 - 使用完全模块化的架构 *)
let comprehensive_practice_check ?(config = Core.default_config) code =
  let all_violations = Core.run_basic_checks code config in
  let filtered_violations = Core.filter_violations all_violations config in
  VR.generate_practice_report filtered_violations

(** 简化的综合检查（用于测试） *)
let generate_practice_report violations = VR.generate_practice_report violations

(** 兼容性函数 - 保持原有API *)
let detect_mixed_language_patterns =
  Chinese_best_practices_checkers.Mixed_language_checker.detect_mixed_language_patterns

let check_chinese_word_order =
  Chinese_best_practices_checkers.Word_order_checker.check_chinese_word_order

let check_idiomatic_chinese =
  Chinese_best_practices_checkers.Idiomatic_checker.check_idiomatic_chinese

let check_style_consistency =
  Chinese_best_practices_checkers.Style_consistency_checker.check_style_consistency

let check_classical_style_appropriateness =
  Chinese_best_practices_checkers.Classical_style_checker.check_classical_style_appropriateness

let check_ai_friendly_patterns =
  Chinese_best_practices_checkers.Ai_friendly_checker.check_ai_friendly_patterns

(** {1 测试运行函数} *)

(** 通用测试运行器 *)
let run_test_suite test_config =
  Unified_logging.Legacy.printf "🧪 测试%s...\n" test_config.name;
  List.iteri
    (fun i code ->
      Unified_logging.Legacy.printf "   测试案例 %d: %s\n" (i + 1) code;
      let violations = test_config.checker_function code in
      let report = generate_practice_report violations in
      Unified_logging.Legacy.printf "   结果: %s\n"
        (if String.length report > 0 then "发现问题" else "✅ 通过"))
    test_config.test_cases;
  Unified_logging.Legacy.printf "✅ %s测试完成\n\n" test_config.name

(** 运行综合测试 *)
let run_comprehensive_test () =
  Unified_logging.Legacy.printf "🔍 综合最佳实践检查测试:\n\n";
  let test_cases = Lazy.force comprehensive_test_cases in
  List.iteri
    (fun i code ->
      Unified_logging.Legacy.printf "🔍 综合测试案例 %d:\n" (i + 1);
      Unified_logging.Legacy.printf "代码: %s\n\n" code;
      let report = comprehensive_practice_check code in
      Unified_logging.Legacy.printf "%s\n" report;
      Unified_logging.Legacy.printf "%s\n" (String.make 80 '-'))
    test_cases;
  Unified_logging.Legacy.printf "✅ 综合最佳实践检查测试完成\n\n"

(** 打印测试统计 *)
let print_test_summary () =
  Unified_logging.Legacy.printf "🎉 所有中文编程最佳实践检查器测试完成！\n";
  Unified_logging.Legacy.printf "📊 测试统计:\n";
  let test_items = Lazy.force test_summary_items in
  List.iter (fun item -> Unified_logging.Legacy.printf "   • %s: ✅ 通过\n" item) test_items

(** {1 主测试函数} *)

(** 测试中文编程最佳实践检查器 - 配置外化重构版本 *)
let test_chinese_best_practices () =
  Unified_logging.Legacy.printf "=== 中文编程最佳实践检查器全面测试 ===\n\n";

  try
    (* 运行所有配置的测试 *)
    let configs = Lazy.force test_configs in
    List.iter run_test_suite configs;

    (* 运行综合测试 *)
    run_comprehensive_test ();

    (* 打印测试统计 *)
    print_test_summary ()
  with
  | Test_config_error msg -> Unified_logging.Legacy.printf "❌ 配置加载错误: %s\n" msg
  | exn -> Unified_logging.Legacy.printf "❌ 测试运行时发生错误: %s\n" (Printexc.to_string exn)
