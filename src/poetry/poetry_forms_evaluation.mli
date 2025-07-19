(* 不同诗词形式评价模块接口 *)

open Artistic_types

val evaluate_wuyan_lushi : string array -> artistic_report
(** 五言律诗艺术性评价 *)

val evaluate_qiyan_jueju : string array -> artistic_report
(** 七言绝句艺术性评价 *)

val evaluate_siyan_pianti : string array -> artistic_report
(** 四言骈体评价 *)

val evaluate_cipai : string -> string array -> artistic_report
(** 词牌格律评价 *)

val evaluate_modern_poetry : string array -> artistic_report
(** 现代诗评价 *)

val evaluate_siyan_parallel_prose : string array -> artistic_report
(** 四言排律评价 *)

val evaluate_poetry_by_form : poetry_form -> string array -> artistic_report
(** 根据诗词形式选择相应的评价函数 *)
