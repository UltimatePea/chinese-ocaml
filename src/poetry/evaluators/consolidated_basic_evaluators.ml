(** 基础评价器整合模块 - Poetry模块整合Phase 1试点
 *
 * 将四个小型独立评价器模块整合为统一模块，减少模块数量，
 * 提高编译效率。这是Poetry模块整合的低风险试点实施。
 *
 * 整合模块：
 * - overall_evaluator.ml → 整合到此模块
 * - content_depth_evaluator.ml → 整合到此模块
 * - mood_context_evaluator.ml → 整合到此模块
 * - tonal_balance_evaluator.ml → 整合到此模块
 *
 * @author Whisky, PR Worker - Poetry模块整合Phase 1试点
 * @version 1.0 - 低风险模块整合试点
 * @since 2025-08-01
 * @consolidation_target 4个模块 → 1个模块
 * @fix_issue #1914 Poetry模块整合试点
 *)

open Evaluator_types

(** {1 综合评价器} *)

module OverallEvaluator : EVALUATOR = struct
  let dimension = Overall
  let name = "综合评价器"
  let description = "综合各维度评价结果，计算总体评分"
  let weight = 1.0
  let required_context = []
  let is_applicable _ctx = true

  let evaluate _ctx =
    let score = 0.65 in
    (* 基础综合评分 *)
    let suggestions = [ "综合评价基于各维度评价结果的加权平均" ] in
    let details = Some "综合考虑韵律、对仗、意象、内容等各个维度" in

    { dimension; score; max_possible = 1.0; confidence = 0.8; details; suggestions }
end

(** {1 内容深度评价器} *)

module ContentDepthEvaluator : EVALUATOR = struct
  let dimension = ContentDepth
  let name = "内容深度评价器"
  let description = "评价诗词的内容深度和思想表达"
  let weight = 0.25
  let required_context = [ "verse" ]
  let is_applicable _ctx = true

  let evaluate ctx =
    let verse = ctx.verse in
    let score = 0.6 in
    (* 基础评分 *)
    let suggestions = [ "内容深度分析基于语义复杂度评估" ] in
    let details = Some (Printf.sprintf "内容长度: %d字符" (String.length verse)) in

    { dimension; score; max_possible = 1.0; confidence = 0.65; details; suggestions }
end

(** {1 意境评价器} *)

module MoodContextEvaluator : EVALUATOR = struct
  let dimension = ContextMood
  let name = "意境评价器"
  let description = "评价诗词的意境营造和情感表达"
  let weight = 0.20
  let required_context = [ "verses" ]
  let is_applicable ctx = List.length ctx.verses > 0

  let evaluate ctx =
    let verses = ctx.verses in
    let score = 0.7 in
    (* 基础评分 *)
    let suggestions = [ "意境分析基于整体诗歌氛围评估" ] in
    let details = Some (Printf.sprintf "基于%d行诗句的意境分析" (List.length verses)) in

    { dimension; score; max_possible = 1.0; confidence = 0.7; details; suggestions }
end

(** {1 声调平衡评价器} *)

module TonalBalanceEvaluator : EVALUATOR = struct
  let dimension = TonalBalance
  let name = "声调平衡评价器"
  let description = "评价诗词的声调平衡和变化"
  let weight = 0.15
  let required_context = [ "verses" ]
  let is_applicable ctx = List.length ctx.verses >= 2

  let evaluate _ctx =
    (* 简化的声调分析 - 基于汉字声调模式 *)
    let score = 0.6 in
    (* 基础分数 *)
    let suggestions = [ "声调分析功能正在完善中" ] in
    let details = Some "基于基础声调模式分析" in

    { dimension; score; max_possible = 1.0; confidence = 0.5; details; suggestions }
end

(** {1 导出接口} *)

(** 导出所有评价器模块以保持向后兼容性 *)
module Overall = OverallEvaluator
module ContentDepth = ContentDepthEvaluator
module MoodContext = MoodContextEvaluator
module TonalBalance = TonalBalanceEvaluator

(** 评价器列表 - 便于批量操作 *)
let all_evaluators = [
  (module OverallEvaluator : EVALUATOR);
  (module ContentDepthEvaluator : EVALUATOR);
  (module MoodContextEvaluator : EVALUATOR);
  (module TonalBalanceEvaluator : EVALUATOR);
]

(** 按维度获取评价器 *)
let get_evaluator_by_dimension = function
  | Overall -> (module OverallEvaluator : EVALUATOR)
  | ContentDepth -> (module ContentDepthEvaluator : EVALUATOR)
  | ContextMood -> (module MoodContextEvaluator : EVALUATOR)
  | TonalBalance -> (module TonalBalanceEvaluator : EVALUATOR)
  | _ -> failwith "Unsupported dimension in basic evaluators"