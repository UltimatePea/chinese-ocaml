(** 中文地道性检查器 - 骆言中文编程最佳实践 *)

open Chinese_best_practices_types.Practice_types
open Chinese_best_practices_types.Severity_types
open Chinese_best_practices_rules.Idiomatic_rules

(** 检查中文地道性问题 *)
let check_idiomatic_chinese code =
  let violations = ref [] in

  List.iter
    (fun rule ->
      if
        try
          let _ = Str.search_forward (Str.regexp rule.pattern) code 0 in
          true
        with Not_found -> false
      then
        let violation = Unidiomatic (rule.pattern, rule.description, rule.suggestion) in
        let result =
          {
            violation;
            severity = rule.severity;
            message = rule.description;
            suggestion = rule.suggestion;
            confidence = 0.6;
            ai_friendly = true;
          }
        in
        violations := result :: !violations)
    idiomatic_rules;

  !violations

(** 检查特定类别的地道性问题 *)
let check_category code category =
  let category_rules = get_rules_by_category category in
  let violations = ref [] in

  List.iter
    (fun rule ->
      if
        try
          let _ = Str.search_forward (Str.regexp rule.pattern) code 0 in
          true
        with Not_found -> false
      then
        let violation = Unidiomatic (rule.pattern, rule.description, rule.suggestion) in
        let result =
          {
            violation;
            severity = rule.severity;
            message = rule.description;
            suggestion = rule.suggestion;
            confidence = 0.6;
            ai_friendly = true;
          }
        in
        violations := result :: !violations)
    category_rules;

  !violations

(** 获取支持的检查类别 *)
let get_supported_categories () = get_all_categories ()

(** 按严重程度过滤检查 *)
let check_with_severity_filter code min_severity =
  let severity_rules = get_rules_by_severity min_severity in
  let violations = ref [] in

  List.iter
    (fun rule ->
      if
        try
          let _ = Str.search_forward (Str.regexp rule.pattern) code 0 in
          true
        with Not_found -> false
      then
        let violation = Unidiomatic (rule.pattern, rule.description, rule.suggestion) in
        let result =
          {
            violation;
            severity = rule.severity;
            message = rule.description;
            suggestion = rule.suggestion;
            confidence = 0.6;
            ai_friendly = true;
          }
        in
        violations := result :: !violations)
    severity_rules;

  !violations
