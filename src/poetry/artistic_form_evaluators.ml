(** 骆言诗词形式专项评价模块

    从poetry_artistic_core.ml重构而来，专门负责不同诗词形式的专项评价功能。

    @author 骆言技术债务清理团队 - Alpha Agent
    @version 1.0 - 重构版本
    @since 2025-07-25 *)

open Poetry_types_consolidated
open Artistic_core_evaluators

(** {1 改进建议生成} *)

(** 根据评价报告生成改进建议
    @param report 艺术性评价报告
    @return 改进建议列表 *)
let generate_improvement_suggestions report =
  let suggestions = ref [] in

  if report.rhyme_score < 0.6 then suggestions := "建议注意韵律和谐度，选择押韵字符" :: !suggestions;

  if report.tone_score < 0.6 then suggestions := "建议调整平仄搭配，增强声调平衡" :: !suggestions;

  if report.parallelism_score < 0.6 then suggestions := "建议工整对仗，注意字数和声调对应" :: !suggestions;

  if report.imagery_score < 0.6 then suggestions := "建议丰富意象，增加自然和情感元素" :: !suggestions;

  if report.rhythm_score < 0.6 then suggestions := "建议调整节奏感，适度变化声调" :: !suggestions;

  if report.elegance_score < 0.6 then suggestions := "建议提高雅致程度，使用更文雅的词汇" :: !suggestions;

  List.rev !suggestions

(** {1 诗词形式专项评价函数} *)

(** 评价四言骈体诗的艺术性
    @param verses 诗句数组
    @return 艺术性评价报告 *)
let evaluate_siyan_parallel_prose verses =
  let verse_count = Array.length verses in
  if verse_count < 2 then
    comprehensive_artistic_evaluation (if verse_count > 0 then verses.(0) else "") None
  else
    (* 四言骈体要求两两对仗 *)
    let total_score = ref 0.0 in
    let pair_count = verse_count / 2 in

    for i = 0 to pair_count - 1 do
      let left = verses.(i * 2) in
      let right = if (i * 2) + 1 < verse_count then verses.((i * 2) + 1) else "" in
      let parallelism_score = evaluate_parallelism left right in
      total_score := !total_score +. parallelism_score
    done;

    let avg_parallelism = !total_score /. float_of_int pair_count in
    let first_verse = verses.(0) in
    let base_report = comprehensive_artistic_evaluation first_verse None in

    {
      base_report with
      parallelism_score = avg_parallelism;
      overall_grade =
        determine_overall_grade
          {
            rhyme_harmony = base_report.rhyme_score;
            tonal_balance = base_report.tone_score;
            parallelism = avg_parallelism;
            imagery = base_report.imagery_score;
            rhythm = base_report.rhythm_score;
            elegance = base_report.elegance_score;
          };
    }

(** 评价五言律诗的艺术性
    @param verses 诗句数组（应为8句）
    @return 艺术性评价报告 *)
let evaluate_wuyan_lushi verses =
  let verse_count = Array.length verses in
  if verse_count <> 8 then
    comprehensive_artistic_evaluation (if verse_count > 0 then verses.(0) else "") None
  else
    (* 五言律诗：颔联(2,3)和颈联(4,5)必须对仗 *)
    let parallelism_score =
      let score1 = evaluate_parallelism verses.(2) verses.(3) in
      let score2 = evaluate_parallelism verses.(4) verses.(5) in
      (score1 +. score2) /. 2.0
    in

    (* 评价整体韵律 - 取首句为代表 *)
    let base_report = comprehensive_artistic_evaluation verses.(0) None in

    {
      base_report with
      parallelism_score;
      overall_grade =
        determine_overall_grade
          {
            rhyme_harmony = base_report.rhyme_score;
            tonal_balance = base_report.tone_score;
            parallelism = parallelism_score;
            imagery = base_report.imagery_score;
            rhythm = base_report.rhythm_score;
            elegance = base_report.elegance_score;
          };
    }

(** 评价七言绝句的艺术性
    @param verses 诗句数组（应为4句）
    @return 艺术性评价报告 *)
let evaluate_qiyan_jueju verses =
  let verse_count = Array.length verses in
  if verse_count <> 4 then
    comprehensive_artistic_evaluation (if verse_count > 0 then verses.(0) else "") None
  else
    (* 七言绝句主要评价韵律和意境 *)
    let combined_verse = String.concat "" (Array.to_list verses) in
    comprehensive_artistic_evaluation combined_verse None

(** 根据诗词形式评价艺术性
    @param form 诗词形式
    @param verses 诗句数组
    @return 艺术性评价报告 *)
let evaluate_poetry_by_form form verses =
  match form with
  | SiYanPianTi | SiYanParallelProse -> evaluate_siyan_parallel_prose verses
  | WuYanLuShi -> evaluate_wuyan_lushi verses
  | QiYanJueJu -> evaluate_qiyan_jueju verses
  | CiPai _ | ModernPoetry ->
      let combined = String.concat "" (Array.to_list verses) in
      comprehensive_artistic_evaluation combined None
