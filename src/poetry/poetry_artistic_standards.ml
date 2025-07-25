(** 骆言诗词艺术标准模块

    此模块定义各种诗词形式的艺术性评价标准和智能评价助手。 从原poetry_artistic_core.ml模块中提取标准定义和智能评价功能。

    主要功能：
    - 各种诗词形式的评价标准
    - 智能诗词形式检测
    - 自适应评价系统
    - 智能建议生成

    Author: Beta, Code Reviewer
    @since 2025-07-25 - 技术债务重构Phase 3 *)

open Poetry_types_consolidated
open Poetry_rhyme_core

(** {1 评价标准配置} *)

module ArtisticStandards = struct
  let siyan_standards =
    {
      char_count = 4;
      tone_pattern = [ true; false; true; false ];
      (* 简化的平仄模式 *)
      parallelism_required = true;
      rhythm_weight = 0.3;
    }

  let wuyan_lushi_standards : Poetry_types_consolidated.wuyan_lushi_standards =
    {
      line_count = 8;
      char_per_line = 5;
      rhyme_scheme = [| false; true; false; true; false; true; false; true |];
      parallelism_required = [| false; false; true; true; true; true; false; false |];
      tone_pattern = [];
      (* 简化版本暂不实现详细平仄模式 *)
      rhythm_weight = 0.25;
    }

  let qiyan_jueju_standards =
    {
      line_count = 4;
      char_per_line = 7;
      rhyme_scheme = [| false; true; false; true |];
      parallelism_required = [| false; false; false; false |];
      tone_pattern = [];
      rhythm_weight = 0.2;
    }

  let get_standards_for_form = function
    | SiYanPianTi | SiYanParallelProse -> [ 0.2; 0.25; 0.3; 0.1; 0.1; 0.05 ]
    | WuYanLuShi -> [ 0.25; 0.25; 0.25; 0.1; 0.1; 0.05 ]
    | QiYanJueJu -> [ 0.3; 0.2; 0.1; 0.2; 0.15; 0.05 ]
    | _ -> [ 0.2; 0.2; 0.2; 0.2; 0.15; 0.05 ]
  (* 默认权重 *)
end

(** {1 智能评价助手} *)

module IntelligentEvaluator = struct
  let auto_detect_form verses =
    let verse_count = Array.length verses in
    if verse_count = 0 then ModernPoetry
    else
      let first_len = String.length verses.(0) in
      match (verse_count, first_len) with
      | 4, 7 -> QiYanJueJu
      | 8, 5 -> WuYanLuShi
      | _, 4 -> SiYanPianTi
      | _ -> ModernPoetry

  let adaptive_evaluation verses =
    let form = auto_detect_form verses in
    let report = Poetry_form_evaluators.evaluate_poetry_by_form form verses in
    {
      poem_text = Array.to_list verses;
      form;
      verse_summaries = [];
      (* 简化版本 *)
      overall_rhyme = analyze_poem_rhyme (Array.to_list verses);
      overall_artistic =
        {
          rhyme_harmony = report.rhyme_score;
          tonal_balance = report.tone_score;
          parallelism = report.parallelism_score;
          imagery = report.imagery_score;
          rhythm = report.rhythm_score;
          elegance = report.elegance_score;
        };
      final_grade = report.overall_grade;
      critique =
        (match report.overall_grade with
        | Excellent -> "艺术性优秀，达到很高水准"
        | Good -> "艺术性良好，有进一步提升空间"
        | Fair -> "艺术性一般，需要多方面改进"
        | Poor -> "艺术性较差，建议重新创作");
    }

  let smart_suggestions verses =
    let analysis = adaptive_evaluation verses in
    let base_suggestions =
      match analysis.final_grade with
      | Excellent -> [ "已达很高水准，可尝试更复杂的形式" ]
      | Good -> [ "整体不错，可在意象和用词上进一步提升" ]
      | Fair -> [ "需要加强韵律和平仄的把握" ]
      | Poor -> [ "建议从基础格律学起，多读经典作品" ]
    in

    let form_specific =
      match analysis.form with
      | SiYanPianTi -> [ "注重对仗的工整性" ]
      | WuYanLuShi -> [ "严格遵循律诗格律" ]
      | QiYanJueJu -> [ "注意起承转合的结构" ]
      | _ -> [ "发挥自由创作的优势" ]
    in

    base_suggestions @ form_specific
end
