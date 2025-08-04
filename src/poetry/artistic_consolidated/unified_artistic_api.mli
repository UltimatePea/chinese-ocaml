(** 骆言诗词统一艺术评价API接口 - Issue #2084 Phase 3 艺术评价系统整合完成
    
    Author: Whisky, PR Worker - Poetry模块架构整合
    Date: 2025-08-04
    
    本模块接口定义了统一的艺术评价系统API，是艺术评价功能的单一入口点。 *)

open Poetry_types_unified.Unified_poetry_types

(** === 子模块接口 === *)

(** 艺术评价核心引擎 *)
module Engine : sig
  val evaluate_verse : string -> artistic_report
  val evaluate_poem : string list -> artistic_scores
  val validate_report : artistic_report -> bool
  val validate_scores : artistic_scores -> bool
  val get_evaluation_weights : unit -> artistic_scores
end

(** 形式评价器 *)
module FormEvaluators : sig
  val evaluate_by_form : poetry_form -> string list -> artistic_scores
  val get_form_suggestions : poetry_form -> string list -> string list
end

(** === 一体化评价接口 === *)

(** 智能艺术评价：自动识别形式并评价 -> (识别形式, 评价分数, 评价结果) *)
val smart_artistic_evaluation : string list -> (poetry_form * artistic_scores * artistic_evaluation_result)

(** 快速艺术质量检查 *)
val quick_quality_check : string -> string

(** 批量艺术评价 *)
val batch_artistic_evaluation : string list list -> (string list * poetry_form * artistic_scores * artistic_evaluation_result) list

(** 对比评价：比较两组诗句 -> (简要对比, 详细对比, (分数1, 分数2)) *)
val comparative_evaluation : string list -> string list -> (string * string * (artistic_scores * artistic_scores))

(** === 改进指导接口 === *)

(** 个性化改进建议生成 -> (指导报告, 建议列表) *)
val generate_improvement_guidance : string list -> evaluation_grade -> (string * string list)

(** === 系统管理接口 === *)

(** 生成系统状态报告 *)
val system_status_report : unit -> string

(** 性能基准测试 *)
val performance_benchmark : unit -> string

(** 模块完整性检查 *)
val module_integrity_check : unit -> string

(** === 向后兼容接口 === *)

(** 兼容原 artistic_engine_unified 接口 *)
val evaluate_artistic : string -> artistic_report
val evaluate_poem_artistic : string list -> artistic_scores

(** 兼容原 artistic_evaluators 接口 *)
val get_artistic_scores : string list -> artistic_scores

(** 兼容原 form_evaluators 接口 *)
val evaluate_form : poetry_form -> string list -> artistic_scores