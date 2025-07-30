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

(** 提取韵脚字符 *)
  let extract_final_char verse =
    let trimmed = String.trim verse in
    if String.length trimmed > 0 then
      let len = String.length trimmed in
      let rec find_last_char pos =
        if pos <= 0 then None
        else
          let byte = Char.code trimmed.[pos] in
          if byte < 0x80 then (* ASCII *)
            if pos = len - 1 then Some (String.sub trimmed pos 1) else find_last_char (pos - 1)
          else if byte land 0xC0 = 0x80 then (* UTF-8续字节 *)
            find_last_char (pos - 1)
          else (* UTF-8起始字节 *)
            let char_len =
              if byte land 0xE0 = 0xC0 then 2
              else if byte land 0xF0 = 0xE0 then 3
              else if byte land 0xF8 = 0xF0 then 4
              else 1
            in
            if pos + char_len = len then Some (String.sub trimmed pos char_len)
            else find_last_char (pos - 1)
      in
      find_last_char (len - 1)
    else None

  (** 计算韵律多样性 *)
  let calculate_rhyme_diversity rhyme_chars =
    let unique_chars =
      let rec unique acc = function
        | [] -> List.rev acc
        | h :: t -> if List.mem h acc then unique acc t else unique (h :: acc) t
      in
      unique [] rhyme_chars
    in
    let unique_count = List.length unique_chars in
    let rhyme_count = List.length rhyme_chars in
    (float_of_int unique_count /. float_of_int rhyme_count, unique_count, rhyme_count)

  (** 计算韵律评分 *)
  let calculate_rhyme_score rhyme_diversity rhyme_count unique_count =
    if rhyme_diversity >= 0.25 && rhyme_diversity <= 0.75 then
      let base_score = 0.8 in
      let repetition_bonus = if rhyme_count > unique_count then 0.1 else 0.0 in
      min 1.0 (base_score +. repetition_bonus)
    else if rhyme_diversity >= 0.15 && rhyme_diversity <= 0.85 then 0.6
    else if rhyme_diversity = 1.0 then 0.3
    else if rhyme_diversity <= 0.1 then 0.4
    else 0.5

  (** 生成韵律评价反馈 *)
  let generate_rhyme_feedback rhyme_score rhyme_chars rhyme_diversity =
    let rhyme_details =
      Printf.sprintf "韵脚字符: [%s], 韵律多样性: %.1f%%" (String.concat "; " rhyme_chars)
        (rhyme_diversity *. 100.0)
    in
    if rhyme_score >= 0.7 then
      (["韵律安排良好，音韵和谐自然"], Some rhyme_details)
    else if rhyme_score >= 0.5 then
      (["韵律基本合理，可进一步优化押韵效果"], Some (rhyme_details ^ "，建议适度调整"))
    else
      (["建议改善韵脚安排，增强音韵协调性"], Some (rhyme_details ^ "，韵律需要优化"))

  let evaluate ctx =
    let verses = ctx.verses in
    let score = ref 0.3 in
    let suggestions = ref [] in
    let details = ref None in
    let verse_count = List.length verses in

    if verse_count >= 2 then
      let filter_map f lst =
        List.fold_right (fun x acc -> match f x with Some y -> y :: acc | None -> acc) lst []
      in
      let rhyme_chars = filter_map extract_final_char verses in
      let rhyme_count = List.length rhyme_chars in

      if rhyme_count >= 2 then (
        let rhyme_diversity, unique_count, rhyme_count = calculate_rhyme_diversity rhyme_chars in
        let rhyme_score = calculate_rhyme_score rhyme_diversity rhyme_count unique_count in
        score := !score +. (rhyme_score *. 0.5);
        let new_suggestions, new_details = generate_rhyme_feedback rhyme_score rhyme_chars rhyme_diversity in
        suggestions := new_suggestions @ !suggestions;
        details := new_details
      ) else (
        suggestions := ["提取韵脚字符较少，韵律分析受限"] @ !suggestions;
        details := Some "建议使用更多包含中文字符的诗句"
      )
    else (
      suggestions := ["诗句数量较少，韵律分析有限"] @ !suggestions;
      details := Some "需要至少2行诗句进行韵律分析"
    );

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
