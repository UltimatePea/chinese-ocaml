(** 韵律和谐度评价器
 *
 * 从 unified_artistic_engine.ml 中提取的专门负责韵律和谐度评价的模块。
 * 遵循单一职责原则，专注于韵律和谐性分析。
 *
 * @author Charlie, 战略规划专员 - 架构债务重构专项
 * @version 1.0 - 模块化重构版本  
 * @since 2025-07-30
 * @fix_issue #1767 统一模块增殖架构债务
 *)

open Evaluator_types

module RhymeHarmonyEvaluator : EVALUATOR = struct
  let dimension = RhymeHarmony
  let name = "韵律和谐度评价器"
  let description = "评价诗词的韵律和谐程度，整合rhyme_*模块功能"
  let weight = 0.2
  let required_context = [ "verses" ]
  let is_applicable ctx = List.length ctx.verses >= 2

  let evaluate ctx =
    let verses = ctx.verses in
    let score = ref 0.5 in
    let suggestions = ref [] in
    let details = ref None in

    (* 简化的韵律分析 - 基于基础模式检测 *)
    let verse_count = List.length verses in
    if verse_count >= 2 then (
      (* 简单的韵脚分析：检查最后字符的相似性 *)
      let get_last_char s = if String.length s > 0 then s.[String.length s - 1] else ' ' in
      let last_chars = List.map get_last_char verses in
      let unique_chars = List.sort_uniq Char.compare last_chars in
      let rhyme_diversity = float_of_int (List.length unique_chars) /. float_of_int verse_count in

      (* 韵律评分：适当的重复表示押韵，过度重复或完全不重复都不好 *)
      let rhyme_score =
        if rhyme_diversity >= 0.3 && rhyme_diversity <= 0.7 then 0.8
        else if rhyme_diversity >= 0.2 && rhyme_diversity <= 0.8 then 0.6
        else 0.4
      in

      score := !score +. (rhyme_score *. 0.4);

      if rhyme_score >= 0.7 then (
        suggestions := [ "韵律安排较好，音韵和谐" ] @ !suggestions;
        details := Some (Printf.sprintf "韵律多样性: %.1f%%" (rhyme_diversity *. 100.0)))
      else (
        suggestions := [ "建议改善韵脚安排以增强音韵效果" ] @ !suggestions;
        details := Some (Printf.sprintf "韵律多样性: %.1f%%，可以优化" (rhyme_diversity *. 100.0))))
    else (
      suggestions := [ "诗句数量较少，韵律分析有限" ] @ !suggestions;
      details := Some "需要至少2行诗句进行韵律分析");

    let final_score = min 1.0 (max 0.0 !score) in
    {
      dimension;
      score = final_score;
      max_possible = 1.0;
      confidence = (if !details <> None then 0.8 else 0.3);
      details = !details;
      suggestions = List.rev !suggestions;
    }
end