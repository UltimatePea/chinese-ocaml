(** 不同诗词形式评价模块 - 针对特定诗词体裁的评价函数

    此模块整合了诗词形式分发器功能，消除poetry_form_dispatch.ml的重复。 Poetry模块技术债务清理：合并2个小文件为1个统一模块。

    Author: Alpha, 主要工作代理 - 技术债务清理
    @since 2025-07-29 - Fix #1744 Poetry模块整合优化 *)

open Poetry_types_consolidated

(* 重新导出各专门模块的功能以保持向后兼容 *)

(* 导出评价框架相关功能 *)
module EvaluationFramework = Evaluation_framework

(* 类型转换函数：从新的unified类型转换为旧的接口类型 *)
let convert_artistic_evaluation_to_report evaluation verses_text =
  let extract_score dimension_list dim default_score =
    match List.find_opt (fun ds -> ds.Poetry_artistic.Artistic_evaluators.dimension = dim) dimension_list with
    | Some ds -> ds.score
    | None -> default_score
  in
  let open Poetry_artistic.Artistic_evaluators in
  {
    verses = String.concat "\n" (Array.to_list verses_text);
    rhyme_score = extract_score evaluation.dimension_scores RhymeHarmony 0.5;
    tone_score = extract_score evaluation.dimension_scores TonalBalance 0.5;
    parallelism_score = extract_score evaluation.dimension_scores Parallelism 0.5;
    imagery_score = extract_score evaluation.dimension_scores Imagery 0.5;
    rhythm_score = extract_score evaluation.dimension_scores Rhythm 0.5;
    elegance_score = extract_score evaluation.dimension_scores Elegance 0.5;
    overall_grade = (match evaluation.quality_grade with 
      | `Excellent -> Excellent 
      | `Good -> Good 
      | `Fair -> Fair 
      | `Poor -> Poor);
    detailed_feedback = String.concat "; " evaluation.improvement_suggestions;
    suggestions = evaluation.improvement_suggestions;
  }

(* 导出所有具体评价函数 - 现在从统一的artistic库中获取 *)
let evaluate_wuyan_lushi verses = 
  convert_artistic_evaluation_to_report (Poetry_artistic.Artistic_evaluators.evaluate_wuyan_lushi (String.concat "\n" (Array.to_list verses))) verses
let evaluate_qiyan_jueju verses = 
  convert_artistic_evaluation_to_report (Poetry_artistic.Artistic_evaluators.evaluate_qiyan_jueju (String.concat "\n" (Array.to_list verses))) verses
let evaluate_siyan_parallel_prose verses = 
  convert_artistic_evaluation_to_report (Poetry_artistic.Artistic_evaluators.evaluate_siyan_parallel_prose (String.concat "\n" (Array.to_list verses))) verses
(* 注意：evaluate_siyan_pianti, evaluate_cipai, evaluate_modern_poetry 
   需要在统一库中实现或使用通用评价函数 *)
let evaluate_siyan_pianti verses = 
  convert_artistic_evaluation_to_report (Poetry_artistic.Artistic_evaluators.evaluate_poetry_by_form "siyan_pianti" (String.concat "\n" (Array.to_list verses))) verses
let evaluate_cipai cipai_type verses = 
  let _ = cipai_type in (* ignore cipai_type for now *)
  convert_artistic_evaluation_to_report (Poetry_artistic.Artistic_evaluators.evaluate_poetry_by_form "cipai" (String.concat "\n" (Array.to_list verses))) verses
let evaluate_modern_poetry verses = 
  convert_artistic_evaluation_to_report (Poetry_artistic.Artistic_evaluators.evaluate_poetry_by_form "modern" (String.concat "\n" (Array.to_list verses))) verses

(* 诗词形式分发功能 - 整合自poetry_form_dispatch.ml *)
let evaluate_poetry_by_form poetry_form verses =
  match poetry_form with
  | WuYanLuShi -> evaluate_wuyan_lushi verses
  | QiYanJueJu -> evaluate_qiyan_jueju verses
  | SiYanPianTi -> evaluate_siyan_pianti verses
  | CiPai cipai_type -> evaluate_cipai cipai_type verses
  | ModernPoetry -> evaluate_modern_poetry verses
  | SiYanParallelProse -> evaluate_siyan_parallel_prose verses
