(** AI代理编程友好性检查器 - 骆言中文编程最佳实践 *)

open Chinese_best_practices_types.Practice_types
open Chinese_best_practices_types.Severity_types
open Utils.Base_formatter

type ai_friendly_rule = {
  pattern : string;
  issue : string;
  suggestion : string;
  severity : severity;
}
(** AI友好性检查规则 *)

(** 预定义的AI友好性规则 *)
let ai_friendly_rules =
  [
    (* 清晰的意图表达 *)
    { pattern = "计算"; issue = "动作明确"; suggestion = "建议加上具体的计算对象"; severity = Info };
    { pattern = "处理"; issue = "动作模糊"; suggestion = "建议明确处理的内容和方式"; severity = Warning };
    { pattern = "操作"; issue = "动作模糊"; suggestion = "建议明确操作的对象和方法"; severity = Warning };
    (* 避免歧义表达 *)
    { pattern = "这个"; issue = "指代不明"; suggestion = "使用具体的名称"; severity = Warning };
    { pattern = "那个"; issue = "指代不明"; suggestion = "使用具体的名称"; severity = Warning };
    { pattern = "它"; issue = "指代不明"; suggestion = "使用具体的名称"; severity = Warning };
    (* 鼓励声明式表达 *)
    { pattern = "循环.*直到"; issue = "命令式表达"; suggestion = "考虑使用递归或高阶函数"; severity = Info };
    { pattern = "逐个.*处理"; issue = "命令式表达"; suggestion = "考虑使用映射或过滤函数"; severity = Info };
  ]

(** AI代理编程特征检查 *)
let check_ai_friendly_patterns code =
  let violations = ref [] in

  List.iter
    (fun rule ->
      if
        try
          let _ = Str.search_forward (Str.regexp_string rule.pattern) code 0 in
          true
        with Not_found -> false
      then
        violations :=
          {
            violation = Unidiomatic ("AI友好性检查", rule.issue, rule.suggestion);
            severity = rule.severity;
            message = concat_strings ["AI理解问题: "; rule.issue];
            suggestion = rule.suggestion;
            confidence = 0.9;
            ai_friendly = true;
          }
          :: !violations)
    ai_friendly_rules;

  !violations

(** 检查特定类别的AI友好性问题 *)
let check_category code category =
  let category_rules =
    match category with
    | "intent_clarity" ->
        List.filter (fun rule -> rule.issue = "动作明确" || rule.issue = "动作模糊") ai_friendly_rules
    | "ambiguity_avoidance" -> List.filter (fun rule -> rule.issue = "指代不明") ai_friendly_rules
    | "declarative_style" -> List.filter (fun rule -> rule.issue = "命令式表达") ai_friendly_rules
    | _ -> ai_friendly_rules
  in

  let violations = ref [] in
  List.iter
    (fun rule ->
      if
        try
          let _ = Str.search_forward (Str.regexp_string rule.pattern) code 0 in
          true
        with Not_found -> false
      then
        violations :=
          {
            violation = Unidiomatic ("AI友好性检查", rule.issue, rule.suggestion);
            severity = rule.severity;
            message = concat_strings ["AI理解问题: "; rule.issue];
            suggestion = rule.suggestion;
            confidence = 0.9;
            ai_friendly = true;
          }
          :: !violations)
    category_rules;

  !violations

(** 获取支持的检查类别 *)
let get_supported_categories () = [ "intent_clarity"; "ambiguity_avoidance"; "declarative_style" ]

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
      ai_friendly_rules
  in

  let violations = ref [] in
  List.iter
    (fun rule ->
      if
        try
          let _ = Str.search_forward (Str.regexp_string rule.pattern) code 0 in
          true
        with Not_found -> false
      then
        violations :=
          {
            violation = Unidiomatic ("AI友好性检查", rule.issue, rule.suggestion);
            severity = rule.severity;
            message = concat_strings ["AI理解问题: "; rule.issue];
            suggestion = rule.suggestion;
            confidence = 0.9;
            ai_friendly = true;
          }
          :: !violations)
    severity_rules;

  !violations
