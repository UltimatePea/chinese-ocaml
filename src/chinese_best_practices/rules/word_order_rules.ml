(** 中文语序检查规则 - 骆言中文编程最佳实践 *)

open Chinese_best_practices_types.Severity_types

type word_order_rule = {
  pattern : string;  (** 正则表达式模式 *)
  description : string;  (** 问题描述 *)
  suggestion : string;  (** 改进建议 *)
  severity : severity;  (** 严重程度 *)
  category : string;  (** 规则类别 *)
}
(** 中文语序检查规则类型 *)

(** 中文语序检查规则集合 *)
let word_order_rules =
  [
    (* 动宾语序 *)
    {
      pattern = "计算.*的.*值";
      description = "动宾分离";
      suggestion = "值的计算";
      severity = Info;
      category = "动宾语序";
    };
    {
      pattern = "获取.*的.*长度";
      description = "动宾分离";
      suggestion = "长度的获取";
      severity = Info;
      category = "动宾语序";
    };
    (* 修饰语位置 *)
    {
      pattern = "非常.*快速.*的";
      description = "修饰语冗余";
      suggestion = "快速的";
      severity = Style;
      category = "修饰语位置";
    };
    {
      pattern = "最.*重要.*的";
      description = "修饰语冗余";
      suggestion = "重要的";
      severity = Style;
      category = "修饰语位置";
    };
    (* 条件表达式语序 *)
    {
      pattern = "如果.*的话.*那么";
      description = "条件表达式冗余";
      suggestion = "如果...那么";
      severity = Warning;
      category = "条件表达式";
    };
    {
      pattern = "当.*的时候";
      description = "时间表达式冗余";
      suggestion = "当...时";
      severity = Warning;
      category = "条件表达式";
    };
  ]

(** 根据类别获取规则 *)
let get_rules_by_category category =
  List.filter (fun rule -> rule.category = category) word_order_rules

(** 获取所有规则类别 *)
let get_all_categories () =
  word_order_rules |> List.map (fun rule -> rule.category) |> List.sort_uniq String.compare

(** 根据严重程度获取规则 *)
let get_rules_by_severity min_severity =
  let severity_level = function Error -> 4 | Warning -> 3 | Style -> 2 | Info -> 1 in
  let min_level = severity_level min_severity in
  List.filter (fun rule -> severity_level rule.severity >= min_level) word_order_rules
