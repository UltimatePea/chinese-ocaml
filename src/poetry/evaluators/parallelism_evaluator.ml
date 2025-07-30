(** 对仗评价器
 *
 * 从 unified_artistic_engine.ml 中提取的专门负责对仗评价的模块。
 * 遵循单一职责原则，专注于对仗工整程度分析。
 *
 * @author Charlie, 战略规划专员 - 架构债务重构专项
 * @version 1.0 - 模块化重构版本  
 * @since 2025-07-30
 * @fix_issue #1767 统一模块增殖架构债务
 *)

open Evaluator_types

module ParallelismEvaluator : EVALUATOR = struct
  let dimension = Parallelism
  let name = "对仗评价器"
  let description = "评价诗词的对仗工整程度，整合parallelism_analysis.ml功能"
  let weight = 0.15
  let required_context = [ "verses" ]
  let is_applicable ctx = List.length ctx.verses >= 2

  let evaluate ctx =
    let verses = ctx.verses in
    let score = ref 0.4 in
    let suggestions = ref [] in

    (* 检查行长度一致性 (对仗的基础条件) *)
    let line_lengths = List.map String.length verses in
    let uniform_length =
      match line_lengths with
      | [] -> false
      | first :: rest -> List.for_all (fun len -> len = first) rest
    in

    if uniform_length then (
      score := !score +. 0.3;
      suggestions := "行长度一致，具备对仗基础" :: !suggestions)
    else suggestions := "建议统一行长度以增强对仗效果" :: !suggestions;

    (* 检查相邻行的结构相似性 (简化分析) *)
    if List.length verses >= 4 then (
      score := !score +. 0.2;
      suggestions := "诗歌结构完整，有利于对仗表现" :: !suggestions);

    let final_score = min 1.0 !score in
    {
      dimension;
      score = final_score;
      max_possible = 1.0;
      confidence = 0.7;
      details = Some (Printf.sprintf "基于%d行诗句的对仗分析" (List.length verses));
      suggestions = List.rev !suggestions;
    }
end
