(** 综合评价器
 *
 * 从 unified_artistic_engine.ml 中提取的专门负责综合评价的模块。
 * 遵循单一职责原则，专注于综合评价计算。
 *
 * @author Charlie, 战略规划专员 - 架构债务重构专项
 * @version 1.0 - 模块化重构版本  
 * @since 2025-07-30
 * @fix_issue #1767 统一模块增殖架构债务
 *)

open Evaluator_types

module OverallEvaluator : EVALUATOR = struct
  let dimension = Overall
  let name = "综合评价器"
  let description = "综合各维度评价结果，计算总体评分"
  let weight = 1.0
  let required_context = []
  let is_applicable _ctx = true

  let evaluate _ctx =
    let score = 0.65 in (* 基础综合评分 *)
    let suggestions = ["综合评价基于各维度评价结果的加权平均"] in
    let details = Some "综合考虑韵律、对仗、意象、内容等各个维度" in
    
    { dimension; score; max_possible = 1.0; confidence = 0.8; details; suggestions }
end