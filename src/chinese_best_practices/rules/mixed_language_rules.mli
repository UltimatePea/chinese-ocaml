(** 中英文混用检测规则接口 *)

open Chinese_best_practices_types.Severity_types

type mixed_language_rule = {
  pattern : string;  (** 正则表达式模式 *)
  description : string;  (** 问题描述 *)
  suggestion : string;  (** 改进建议 *)
  severity : severity;  (** 严重程度 *)
  category : string;  (** 规则类别 *)
}
(** 中英文混用模式规则类型 *)

val mixed_language_rules : mixed_language_rule list
(** 中英文混用检测规则集合 *)

val get_rules_by_category : string -> mixed_language_rule list
(** 根据类别获取规则 *)

val get_all_categories : unit -> string list
(** 获取所有规则类别 *)

val get_rules_by_severity : severity -> mixed_language_rule list
(** 根据严重程度获取规则 *)
