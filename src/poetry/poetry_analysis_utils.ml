(** 骆言诗词分析工具模块

    此模块提供诗词艺术性分析所需的工具函数。 从原poetry_artistic_core.ml模块中提取分析工具相关功能。

    主要功能：
    - 高效子串搜索
    - 词汇计数分析
    - 改进建议生成

    Author: Beta, Code Reviewer
    @since 2025-07-25 - 技术债务重构Phase 3 *)

open Poetry_types_consolidated

(** {1 字符串处理工具} *)

(** 高效子串搜索：使用Boyer-Moore类似的优化思路 *)
let contains_substring text pattern =
  let text_len = String.length text in
  let pattern_len = String.length pattern in
  if pattern_len = 0 then true
  else if pattern_len > text_len then false
  else
    let rec search_from pos =
      if pos > text_len - pattern_len then false
      else
        let rec match_at start pattern_pos =
          if pattern_pos >= pattern_len then true
          else if text.[start + pattern_pos] = pattern.[pattern_pos] then
            match_at start (pattern_pos + 1)
          else false
        in
        if match_at pos 0 then true else search_from (pos + 1)
    in
    search_from 0

(** {1 词汇计数分析} *)

(** 高效计数函数：避免重复遍历和不必要的字符检查 *)
let count_imagery_words verse =
  let keywords = Lazy.force Poetry_data_loader.imagery_keywords in
  List.fold_left
    (fun count keyword -> if contains_substring verse keyword then count + 1 else count)
    0 keywords

let count_elegant_words verse =
  let words = Lazy.force Poetry_data_loader.elegant_words in
  List.fold_left
    (fun count word -> if contains_substring verse word then count + 1 else count)
    0 words

(** {1 改进建议生成} *)

let generate_improvement_suggestions report =
  let suggestions = ref [] in

  if report.rhyme_score < 0.6 then suggestions := "建议注意韵律和谐度，选择押韵字符" :: !suggestions;

  if report.tone_score < 0.6 then suggestions := "建议调整平仄搭配，增强声调平衡" :: !suggestions;

  if report.parallelism_score < 0.6 then suggestions := "建议工整对仗，注意字数和声调对应" :: !suggestions;

  if report.imagery_score < 0.6 then suggestions := "建议丰富意象，增加自然和情感元素" :: !suggestions;

  if report.rhythm_score < 0.6 then suggestions := "建议调整节奏感，适度变化声调" :: !suggestions;

  if report.elegance_score < 0.6 then suggestions := "建议提高雅致程度，使用更文雅的词汇" :: !suggestions;

  List.rev !suggestions

(** {1 高阶分析工具} *)

let detect_artistic_flaws _verse report =
  let flaws = ref [] in

  if report.rhyme_score < 0.5 then flaws := "韵律和谐度不足" :: !flaws;
  if report.tone_score < 0.5 then flaws := "平仄搭配不当" :: !flaws;
  if report.imagery_score < 0.5 then flaws := "意象贫乏" :: !flaws;
  if report.rhythm_score < 0.5 then flaws := "节奏感不强" :: !flaws;
  if report.elegance_score < 0.5 then flaws := "用词不够雅致" :: !flaws;

  List.rev !flaws

let calculate_overall_score report =
  let total =
    report.rhyme_score +. report.tone_score +. report.parallelism_score +. report.imagery_score
    +. report.rhythm_score +. report.elegance_score
  in
  total /. 6.0
