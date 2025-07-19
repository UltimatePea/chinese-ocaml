(** 中文编程最佳实践检查协调器 - 骆言中文编程最佳实践 *)

open Chinese_best_practices_types.Severity_types
module MLC = Chinese_best_practices_checkers.Mixed_language_checker
module WOC = Chinese_best_practices_checkers.Word_order_checker
module IC = Chinese_best_practices_checkers.Idiomatic_checker
module SCC = Chinese_best_practices_checkers.Style_consistency_checker
module CSC = Chinese_best_practices_checkers.Classical_style_checker
module AFC = Chinese_best_practices_checkers.Ai_friendly_checker
module VR = Chinese_best_practices_reporters.Violation_reporter

type check_config = {
  enable_mixed_language : bool;
  enable_word_order : bool;
  enable_idiomatic : bool;
  enable_style_consistency : bool;
  enable_classical_style : bool;
  enable_ai_friendly : bool;
  min_severity : severity;
}
(** 检查配置 *)

(** 默认检查配置 *)
let default_config =
  {
    enable_mixed_language = true;
    enable_word_order = true;
    enable_idiomatic = true;
    enable_style_consistency = true;
    enable_classical_style = true;
    enable_ai_friendly = true;
    min_severity = Info;
  }

(** 执行基础检查（已模块化的部分） *)
let run_basic_checks code config =
  let all_violations = ref [] in

  (* 中英文混用检查 *)
  (if config.enable_mixed_language then
     let violations = MLC.detect_mixed_language_patterns code in
     all_violations := violations @ !all_violations);

  (* 中文语序检查 *)
  (if config.enable_word_order then
     let violations = WOC.check_chinese_word_order code in
     all_violations := violations @ !all_violations);

  (* 地道性检查 *)
  (if config.enable_idiomatic then
     let violations = IC.check_idiomatic_chinese code in
     all_violations := violations @ !all_violations);

  (* 风格一致性检查 *)
  (if config.enable_style_consistency then
     let violations = SCC.check_style_consistency code in
     all_violations := violations @ !all_violations);

  (* 古雅体适用性检查 *)
  (if config.enable_classical_style then
     let violations = CSC.check_classical_style_appropriateness code in
     all_violations := violations @ !all_violations);

  (* AI友好性检查 *)
  (if config.enable_ai_friendly then
     let violations = AFC.check_ai_friendly_patterns code in
     all_violations := violations @ !all_violations);

  !all_violations

(** 过滤违规结果 *)
let filter_violations violations config =
  let severity_level = function Error -> 4 | Warning -> 3 | Style -> 2 | Info -> 1 in
  let min_level = severity_level config.min_severity in
  List.filter (fun result -> severity_level result.severity >= min_level) violations

(** 综合最佳实践检查（基础版） *)
let comprehensive_practice_check ?(config = default_config) code =
  let violations = run_basic_checks code config in
  let filtered_violations = filter_violations violations config in
  VR.generate_practice_report filtered_violations

(** 检查单个类别 *)
let check_single_category code category checker_type =
  match checker_type with
  | "mixed_language" -> MLC.check_category code category
  | "word_order" -> WOC.check_category code category
  | "idiomatic" -> IC.check_category code category
  | "style_consistency" -> SCC.check_category code category
  | "classical_style" -> CSC.check_category code category
  | "ai_friendly" -> AFC.check_category code category
  | _ -> []

(** 获取支持的检查器类型 *)
let get_supported_checker_types () =
  [
    "mixed_language";
    "word_order";
    "idiomatic";
    "style_consistency";
    "classical_style";
    "ai_friendly";
  ]

(** 获取检查器支持的类别 *)
let get_checker_categories checker_type =
  match checker_type with
  | "mixed_language" -> MLC.get_supported_categories ()
  | "word_order" -> WOC.get_supported_categories ()
  | "idiomatic" -> IC.get_supported_categories ()
  | "style_consistency" -> SCC.get_supported_categories ()
  | "classical_style" -> CSC.get_supported_categories ()
  | "ai_friendly" -> AFC.get_supported_categories ()
  | _ -> []
