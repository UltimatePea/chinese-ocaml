(* 诗词综合评价器模块接口 *)

open Artistic_evaluator_types

(* 综合评价器 *)
module ComprehensiveEvaluator : sig
  (* 所有评价器列表 *)
  val evaluators : (module EVALUATOR) list

  (* 执行全维度评价 *)
  val evaluate_all : evaluation_context -> evaluation_result list

  (* 计算综合评分 *)
  val calculate_overall_score : evaluation_result list -> float

  (* 生成评价报告 *)
  val generate_report : evaluation_context -> evaluation_result list -> string
end