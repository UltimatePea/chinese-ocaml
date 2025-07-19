(* 诗词艺术指导模块接口 *)

open Artistic_types

(** 生成改进建议 *)
val generate_improvement_suggestions : artistic_report -> string list

(** 全面艺术性评价 *)
val comprehensive_artistic_evaluation : string -> bool list option -> artistic_report

(** 增强版全面艺术性评价 *)
val enhanced_comprehensive_artistic_evaluation : string -> artistic_report

(** 诗词评论 *)
val poetic_critique : string -> poetry_form -> artistic_report

(** 诗词美学指导 *)
val poetic_aesthetics_guidance : string -> poetry_form -> artistic_report