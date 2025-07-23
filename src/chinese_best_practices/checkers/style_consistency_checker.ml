(** 中文编程风格一致性检查器 - 骆言中文编程最佳实践 *)

open Chinese_best_practices_types.Practice_types
open Chinese_best_practices_types.Severity_types
open Utils.Base_formatter

type style_rule = { pattern : string; issue : string; suggestion : string; severity : severity }
(** 风格一致性检查规则 *)

(** 预定义的风格一致性规则 *)
let style_consistency_rules =
  [
    (* 变量命名风格 *)
    { pattern = "「.*」.*「.*」"; issue = "引用符号使用"; suggestion = "保持一致的引用符号风格"; severity = Style };
    { pattern = "让.*=.*让.*="; issue = "变量定义风格"; suggestion = "保持一致的变量定义间距"; severity = Style };
    (* 函数定义风格 *)
    { pattern = "函数.*→.*函数.*→"; issue = "函数定义风格"; suggestion = "保持一致的函数定义格式"; severity = Style };
    { pattern = "递归.*让.*递归.*让"; issue = "递归标记风格"; suggestion = "保持一致的递归标记使用"; severity = Style };
    (* 注释风格 *)
    { pattern = "「.*」.*//"; issue = "注释风格混用"; suggestion = "统一使用中文注释风格"; severity = Warning };
  ]

(** 通用违规收集函数，消除重复的规则检查模式 *)
let collect_violations code rules =
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
            violation = InconsistentStyle ("风格检查", rule.issue, rule.suggestion);
            severity = rule.severity;
            message = concat_strings [ "风格不一致: "; rule.issue ];
            suggestion = rule.suggestion;
            confidence = 0.75;
            ai_friendly = true;
          }
          :: !violations)
    rules;
  !violations

(** 编程风格一致性检查 *)
let check_style_consistency code = collect_violations code style_consistency_rules

(** 检查特定类别的风格问题 *)
let check_category code category =
  let contains_substring str substr =
    try
      let _ = Str.search_forward (Str.regexp_string substr) str 0 in
      true
    with Not_found -> false
  in

  let category_rules =
    match category with
    | "variable_naming" ->
        List.filter
          (fun rule -> contains_substring rule.issue "引" || contains_substring rule.issue "变")
          style_consistency_rules
    | "function_definition" ->
        List.filter
          (fun rule -> contains_substring rule.issue "函" || contains_substring rule.issue "递")
          style_consistency_rules
    | "comment_style" ->
        List.filter (fun rule -> contains_substring rule.issue "注") style_consistency_rules
    | _ -> style_consistency_rules
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
            violation = InconsistentStyle ("风格检查", rule.issue, rule.suggestion);
            severity = rule.severity;
            message = concat_strings [ "风格不一致: "; rule.issue ];
            suggestion = rule.suggestion;
            confidence = 0.75;
            ai_friendly = true;
          }
          :: !violations)
    category_rules;

  !violations

(** 获取支持的检查类别 *)
let get_supported_categories () = [ "variable_naming"; "function_definition"; "comment_style" ]

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
      style_consistency_rules
  in

  collect_violations code severity_rules
