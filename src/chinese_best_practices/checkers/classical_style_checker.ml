(** 中文古雅体适用性检查器 - 骆言中文编程最佳实践 *)

open Chinese_best_practices_types.Practice_types
open Chinese_best_practices_types.Severity_types
open Utils.Base_formatter

type classical_rule = { pattern : string; issue : string; suggestion : string; severity : severity }
(** 古雅体检查规则 *)

(** 预定义的古雅体适用性规则 *)
let classical_style_rules =
  [
    (* 过度使用古雅体 *)
    { pattern = "乃.*之.*也"; issue = "过度古雅"; suggestion = "使用现代表达"; severity = Warning };
    { pattern = "其.*者.*焉"; issue = "过度古雅"; suggestion = "使用现代表达"; severity = Warning };
    { pattern = "若.*则.*矣"; issue = "过度古雅"; suggestion = "如果...那么"; severity = Warning };
    (* 混合古今表达 *)
    { pattern = "设.*为.*值"; issue = "古今混用"; suggestion = "让...等于"; severity = Style };
    { pattern = "取.*之.*值"; issue = "古今混用"; suggestion = "获取...的值"; severity = Style };
    (* AI友好的现代化建议 *)
    { pattern = "凡.*皆.*也"; issue = "AI理解困难"; suggestion = "所有...都"; severity = Error };
    { pattern = "然则.*焉"; issue = "AI理解困难"; suggestion = "那么"; severity = Error };
  ]

(** 古雅体适用性检查 *)
let check_classical_style_appropriateness code =
  let violations = ref [] in

  List.iter
    (fun rule ->
      if
        try
          let _ = Str.search_forward (Str.regexp rule.pattern) code 0 in
          true
        with Not_found -> false
      then
        violations :=
          {
            violation = ModernizationSuggestion ("古雅体检查", rule.issue, rule.suggestion);
            severity = rule.severity;
            message = context_message_pattern "古雅体使用问题" rule.issue;
            suggestion = context_message_pattern "AI友好建议" rule.suggestion;
            confidence = 0.85;
            ai_friendly = true;
          }
          :: !violations)
    classical_style_rules;

  !violations

(** 检查特定类别的古雅体问题 *)
let check_category code category =
  let category_rules =
    match category with
    | "excessive_classical" -> List.filter (fun rule -> rule.issue = "过度古雅") classical_style_rules
    | "mixed_expression" -> List.filter (fun rule -> rule.issue = "古今混用") classical_style_rules
    | "ai_unfriendly" -> List.filter (fun rule -> rule.issue = "AI理解困难") classical_style_rules
    | _ -> classical_style_rules
  in

  let violations = ref [] in
  List.iter
    (fun rule ->
      if
        try
          let _ = Str.search_forward (Str.regexp rule.pattern) code 0 in
          true
        with Not_found -> false
      then
        violations :=
          {
            violation = ModernizationSuggestion ("古雅体检查", rule.issue, rule.suggestion);
            severity = rule.severity;
            message = context_message_pattern "古雅体使用问题" rule.issue;
            suggestion = context_message_pattern "AI友好建议" rule.suggestion;
            confidence = 0.85;
            ai_friendly = true;
          }
          :: !violations)
    category_rules;

  !violations

(** 获取支持的检查类别 *)
let get_supported_categories () = [ "excessive_classical"; "mixed_expression"; "ai_unfriendly" ]

(** 按严重程度过滤检查 *)
let check_with_severity_filter code min_severity =
  let severity_rules =
    List.filter
      (fun rule ->
        match (rule.severity, min_severity) with
        | Error, _ -> true
        | Warning, (Warning | Info | Style) -> true
        | Style, (Style | Info) -> true
        | Info, Info -> true
        | _ -> false)
      classical_style_rules
  in

  let violations = ref [] in
  List.iter
    (fun rule ->
      if
        try
          let _ = Str.search_forward (Str.regexp rule.pattern) code 0 in
          true
        with Not_found -> false
      then
        violations :=
          {
            violation = ModernizationSuggestion ("古雅体检查", rule.issue, rule.suggestion);
            severity = rule.severity;
            message = context_message_pattern "古雅体使用问题" rule.issue;
            suggestion = context_message_pattern "AI友好建议" rule.suggestion;
            confidence = 0.85;
            ai_friendly = true;
          }
          :: !violations)
    severity_rules;

  !violations
