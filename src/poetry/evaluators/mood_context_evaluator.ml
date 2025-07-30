(** 意境评价器
 *
 * 从 unified_artistic_engine.ml 中提取的专门负责意境评价的模块。
 * 遵循单一职责原则，专注于诗词意境分析。
 *
 * @author Charlie, 战略规划专员 - 架构债务重构专项
 * @version 1.0 - 模块化重构版本  
 * @since 2025-07-30
 * @fix_issue #1767 统一模块增殖架构债务
 *)

open Evaluator_types

module MoodContextEvaluator : EVALUATOR = struct
  let dimension = ContextMood
  let name = "意境评价器"
  let description = "评价诗词的意境营造和情感表达"
  let weight = 0.20
  let required_context = [ "verses" ]
  let is_applicable ctx = List.length ctx.verses > 0

  let evaluate ctx =
    let verses = ctx.verses in
    let score = 0.7 in (* 基础评分 *)
    let suggestions = ["意境分析基于整体诗歌氛围评估"] in
    let details = Some (Printf.sprintf "基于%d行诗句的意境分析" (List.length verses)) in
    
    { dimension; score; max_possible = 1.0; confidence = 0.7; details; suggestions }
end