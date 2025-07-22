(** 中文地道性检查规则 - 骆言中文编程最佳实践 *)

open Chinese_best_practices_types.Severity_types

type idiomatic_rule = {
  pattern : string;  (** 正则表达式模式 *)
  description : string;  (** 问题描述 *)
  suggestion : string;  (** 改进建议 *)
  severity : severity;  (** 严重程度 *)
  category : string;  (** 规则类别 *)
}
(** 中文地道性检查规则类型 *)

(** 地道化规则构建器 *)
module IdiomaticRuleBuilder = struct
  let create_rule pattern suggestion severity category =
    {
      pattern;
      description = "不够地道的表达: " ^ pattern;
      suggestion = "更地道的表达: " ^ suggestion;
      severity;
      category;
    }

  let tech_terms = [ ("数据结构", "数据架构"); ("算法实现", "算法设计"); ("程序逻辑", "程序思路") ]

  let action_expressions = [ ("执行操作", "进行操作"); ("进行计算", "计算"); ("完成任务", "完成工作") ]

  let condition_expressions = [ ("如果条件满足", "如果满足条件"); ("当情况发生", "当发生情况") ]

  let create_tech_rules () =
    List.map (fun (pattern, suggestion) -> create_rule pattern suggestion Info "技术术语") tech_terms

  let create_action_rules () =
    List.map
      (fun (pattern, suggestion) -> create_rule pattern suggestion Style "动作表达")
      action_expressions

  let create_condition_rules () =
    List.map
      (fun (pattern, suggestion) -> create_rule pattern suggestion Warning "条件表达")
      condition_expressions
end

(** 所有地道化规则合并 *)
let idiomatic_rules =
  IdiomaticRuleBuilder.create_tech_rules ()
  @ IdiomaticRuleBuilder.create_action_rules ()
  @ IdiomaticRuleBuilder.create_condition_rules ()

(** 根据类别获取规则 *)
let get_rules_by_category category =
  List.filter (fun rule -> rule.category = category) idiomatic_rules

(** 获取所有规则类别 *)
let get_all_categories () =
  idiomatic_rules |> List.map (fun rule -> rule.category) |> List.sort_uniq String.compare

(** 根据严重程度获取规则 *)
let get_rules_by_severity min_severity =
  let severity_level = function Error -> 4 | Warning -> 3 | Style -> 2 | Info -> 1 in
  let min_level = severity_level min_severity in
  List.filter (fun rule -> severity_level rule.severity >= min_level) idiomatic_rules
