(** 骆言诗词艺术评价引擎接口 - 统一艺术性分析核心
    
    Author: Whisky, PR Worker - Issue #2084 Phase 3 艺术评价系统整合
    Date: 2025-08-04
    
    本模块接口定义了统一的艺术评价功能。 *)

open Poetry_types_unified.Unified_poetry_types

(** === 核心艺术评价接口 === *)

(** 评价单个诗句的艺术性 *)
val evaluate_verse : string -> artistic_report

(** 评价整首诗的艺术性 *)
val evaluate_poem : string list -> artistic_scores

(** === 验证接口 === *)

(** 验证艺术报告的有效性 *)
val validate_report : artistic_report -> bool

(** 验证艺术分数的有效性 *)
val validate_scores : artistic_scores -> bool

(** === 配置接口 === *)

(** 获取评价权重配置 *)
val get_evaluation_weights : unit -> artistic_scores