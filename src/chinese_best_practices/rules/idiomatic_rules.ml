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

(** 中文地道性检查规则集合 *)
let idiomatic_rules =
  [
    (* 计算机术语地道化 *)
    {
      pattern = "数据结构";
      description = "不够地道的表达: 数据结构";
      suggestion = "更地道的表达: 数据架构";
      severity = Info;
      category = "技术术语";
    };
    {
      pattern = "算法实现";
      description = "不够地道的表达: 算法实现";
      suggestion = "更地道的表达: 算法设计";
      severity = Info;
      category = "技术术语";
    };
    {
      pattern = "程序逻辑";
      description = "不够地道的表达: 程序逻辑";
      suggestion = "更地道的表达: 程序思路";
      severity = Info;
      category = "技术术语";
    };
    (* 动作表达地道化 *)
    {
      pattern = "执行操作";
      description = "不够地道的表达: 执行操作";
      suggestion = "更地道的表达: 进行操作";
      severity = Style;
      category = "动作表达";
    };
    {
      pattern = "进行计算";
      description = "不够地道的表达: 进行计算";
      suggestion = "更地道的表达: 计算";
      severity = Style;
      category = "动作表达";
    };
    {
      pattern = "完成任务";
      description = "不够地道的表达: 完成任务";
      suggestion = "更地道的表达: 完成工作";
      severity = Style;
      category = "动作表达";
    };
    (* 条件表达地道化 *)
    {
      pattern = "如果条件满足";
      description = "不够地道的表达: 如果条件满足";
      suggestion = "更地道的表达: 如果满足条件";
      severity = Warning;
      category = "条件表达";
    };
    {
      pattern = "当情况发生";
      description = "不够地道的表达: 当情况发生";
      suggestion = "更地道的表达: 当发生情况";
      severity = Warning;
      category = "条件表达";
    };
  ]

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
