(** 中英文混用检查器 - 骆言中文编程最佳实践 *)

open Chinese_best_practices_types.Practice_types
open Chinese_best_practices_types.Severity_types
open Chinese_best_practices_rules.Mixed_language_rules

(** 检测中英文混用模式 *)
let detect_mixed_language_patterns code =
  let violations = ref [] in

  List.iter
    (fun rule ->
      if
        try
          let _ = Str.search_forward (Str.regexp rule.pattern) code 0 in
          true
        with Not_found -> false
      then
        let violation = MixedLanguage (rule.pattern, rule.description, rule.suggestion) in
        let result =
          {
            violation;
            severity = rule.severity;
            message = "检测到中英文混用: " ^ rule.description;
            suggestion = "建议改为: " ^ rule.suggestion;
            confidence = 0.8;
            ai_friendly = true;
          }
        in
        violations := result :: !violations)
    mixed_language_rules;

  !violations

(** 检查特定类别的中英文混用问题 *)
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
        let violation = MixedLanguage (rule.pattern, rule.description, rule.suggestion) in
        let result =
          {
            violation;
            severity = rule.severity;
            message = "检测到中英文混用: " ^ rule.description;
            suggestion = "建议改为: " ^ rule.suggestion;
            confidence = 0.8;
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
        let violation = MixedLanguage (rule.pattern, rule.description, rule.suggestion) in
        let result =
          {
            violation;
            severity = rule.severity;
            message = "检测到中英文混用: " ^ rule.description;
            suggestion = "建议改为: " ^ rule.suggestion;
            confidence = 0.8;
            ai_friendly = true;
          }
        in
        violations := result :: !violations)
    severity_rules;

  !violations
