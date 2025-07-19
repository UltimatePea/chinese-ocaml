(** 中文语序检查规则接口 *)

open Chinese_best_practices_types.Severity_types

type word_order_rule = {
  pattern : string;  (** 正则表达式模式 *)
  description : string;  (** 问题描述 *)
  suggestion : string;  (** 改进建议 *)
  severity : severity;  (** 严重程度 *)
  category : string;  (** 规则类别 *)
}
(** 中文语序检查规则类型 *)

val word_order_rules : word_order_rule list
(** 中文语序检查规则集合 *)

val get_rules_by_category : string -> word_order_rule list
(** 根据类别获取规则 *)

val get_all_categories : unit -> string list
(** 获取所有规则类别 *)

val get_rules_by_severity : severity -> word_order_rule list
(** 根据严重程度获取规则 *)
