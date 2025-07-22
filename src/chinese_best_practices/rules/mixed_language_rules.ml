(** 中英文混用检测规则 - 骆言中文编程最佳实践 *)

open Chinese_best_practices_types.Severity_types

type mixed_language_rule = {
  pattern : string;  (** 正则表达式模式 *)
  description : string;  (** 问题描述 *)
  suggestion : string;  (** 改进建议 *)
  severity : severity;  (** 严重程度 *)
  category : string;  (** 规则类别 *)
}
(** 中英文混用模式规则类型 *)

(** 混用语言规则构建器 *)
module MixedLanguageRuleBuilder = struct
  let create_rule pattern description suggestion severity category =
    { pattern; description; suggestion; severity; category }

  let keyword_mixing_rules =
    [
      ("if.*那么", "if条件判断", "如果条件判断", Error);
      ("for.*循环", "for循环结构", "循环结构", Warning);
      ("function.*函数", "function函数定义", "函数定义", Warning);
      ("return.*返回", "return返回语句", "返回语句", Warning);
    ]

  let naming_convention_rules =
    [
      ("让.*[a-zA-Z]+.*=", "变量名使用英文", "使用中文变量名", Style);
      ("函数.*[a-zA-Z]+.*→", "函数名使用英文", "使用中文函数名", Style);
    ]

  let comment_style_rules =
    [ ("//.*[一-龯]", "英文注释符配中文", "使用中文注释符「」", Info); ("/\\*.*[一-龯]", "英文注释符配中文", "使用中文注释符「」", Info) ]

  let create_keyword_rules () =
    List.map
      (fun (pattern, desc, sugg, sev) -> create_rule pattern desc sugg sev "关键字混用")
      keyword_mixing_rules

  let create_naming_rules () =
    List.map
      (fun (pattern, desc, sugg, sev) -> create_rule pattern desc sugg sev "命名规范")
      naming_convention_rules

  let create_comment_rules () =
    List.map
      (fun (pattern, desc, sugg, sev) -> create_rule pattern desc sugg sev "注释风格")
      comment_style_rules
end

(** 所有混用语言规则合并 *)
let mixed_language_rules =
  MixedLanguageRuleBuilder.create_keyword_rules ()
  @ MixedLanguageRuleBuilder.create_naming_rules ()
  @ MixedLanguageRuleBuilder.create_comment_rules ()

(** 根据类别获取规则 *)
let get_rules_by_category category =
  List.filter (fun rule -> rule.category = category) mixed_language_rules

(** 获取所有规则类别 *)
let get_all_categories () =
  mixed_language_rules |> List.map (fun rule -> rule.category) |> List.sort_uniq String.compare

(** 根据严重程度获取规则 *)
let get_rules_by_severity min_severity =
  let severity_level = function Error -> 4 | Warning -> 3 | Style -> 2 | Info -> 1 in
  let min_level = severity_level min_severity in
  List.filter (fun rule -> severity_level rule.severity >= min_level) mixed_language_rules
