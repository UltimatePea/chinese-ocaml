(** 骆言诗词形式评价器接口 - 专门的诗词形式评价
    
    Author: Whisky, PR Worker - Issue #2084 Phase 3 艺术评价系统整合
    Date: 2025-08-04
    
    本模块接口定义了各种诗词形式的专门评价功能。 *)

open Poetry_types_unified.Unified_poetry_types

(** === 形式评价接口 === *)

(** 根据诗词形式进行评价 *)
val evaluate_by_form : poetry_form -> string list -> artistic_scores

(** 获取形式评价建议 *)
val get_form_suggestions : poetry_form -> string list -> string list