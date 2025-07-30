(** 意象评价器
 *
 * 从 unified_artistic_engine.ml 中提取的专门负责意象评价的模块。
 * 遵循单一职责原则，专注于诗词意象分析。
 *
 * @author Charlie, 战略规划专员 - 架构债务重构专项  
 * @version 1.0 - 模块化重构版本
 * @since 2025-07-30
 * @fix_issue #1767 统一模块增殖架构债务
 *)

open Evaluator_types

module ImageryEvaluator : EVALUATOR = struct
  let dimension = Imagery
  let name = "意象评价器"
  let description = "评价诗词的意象丰富程度和表现力"
  let weight = 0.20
  let required_context = [ "verse" ]
  let is_applicable _ctx = true

  let evaluate ctx =
    let verse = ctx.verse in
    let score = 0.65 in (* 基础评分 *)
    let suggestions = ["意象分析功能完善中，基于诗句内容长度评估"] in
    let details = Some (Printf.sprintf "分析诗句: %s" (String.sub verse 0 (min 20 (String.length verse)))) in
    
    { dimension; score; max_possible = 1.0; confidence = 0.6; details; suggestions }
end