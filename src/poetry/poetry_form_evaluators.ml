(** 骆言诗词形式评价器模块
    
    此模块提供针对不同诗词形式的专用评价器。
    从原poetry_artistic_core.ml模块中提取诗体专用评价功能。
    
    主要功能：
    - 四言骈体专项评价
    - 五言律诗专项评价  
    - 七言绝句专项评价
    - 通用诗词形式评价
    - 传统品评风格
    
    Author: Beta, Code Reviewer
    @since 2025-07-25 - 技术债务重构Phase 3 *)

open Poetry_types_consolidated

(** {1 诗词形式专项评价函数} *)

let evaluate_siyan_parallel_prose verses =
  let verse_count = Array.length verses in
  if verse_count < 2 then
    Poetry_evaluation_engine.comprehensive_artistic_evaluation (if verse_count > 0 then verses.(0) else "") None
  else
    (* 四言骈体要求两两对仗 *)
    let total_score = ref 0.0 in
    let pair_count = verse_count / 2 in
    
    for i = 0 to pair_count - 1 do
      let left = verses.(i * 2) in
      let right = if i * 2 + 1 < verse_count then verses.(i * 2 + 1) else "" in
      let parallelism_score = Poetry_evaluation_engine.evaluate_parallelism left right in
      total_score := !total_score +. parallelism_score
    done;
    
    let avg_parallelism = !total_score /. float_of_int pair_count in
    let first_verse = verses.(0) in
    let base_report = Poetry_evaluation_engine.comprehensive_artistic_evaluation first_verse None in
    
    { base_report with 
      parallelism_score = avg_parallelism;
      overall_grade = Poetry_evaluation_engine.determine_overall_grade {
        rhyme_harmony = base_report.rhyme_score;
        tonal_balance = base_report.tone_score;
        parallelism = avg_parallelism;
        imagery = base_report.imagery_score;
        rhythm = base_report.rhythm_score;
        elegance = base_report.elegance_score;
      }
    }

let evaluate_wuyan_lushi verses =
  let verse_count = Array.length verses in
  if verse_count <> 8 then
    Poetry_evaluation_engine.comprehensive_artistic_evaluation (if verse_count > 0 then verses.(0) else "") None
  else
    (* 五言律诗：颔联(2,3)和颈联(4,5)必须对仗 *)
    let parallelism_score = 
      let score1 = Poetry_evaluation_engine.evaluate_parallelism verses.(2) verses.(3) in
      let score2 = Poetry_evaluation_engine.evaluate_parallelism verses.(4) verses.(5) in
      (score1 +. score2) /. 2.0
    in
    
    (* 评价整体韵律 - 取首句为代表 *)
    let base_report = Poetry_evaluation_engine.comprehensive_artistic_evaluation verses.(0) None in
    
    { base_report with 
      parallelism_score;
      overall_grade = Poetry_evaluation_engine.determine_overall_grade {
        rhyme_harmony = base_report.rhyme_score;
        tonal_balance = base_report.tone_score;
        parallelism = parallelism_score;
        imagery = base_report.imagery_score;
        rhythm = base_report.rhythm_score;
        elegance = base_report.elegance_score;
      }
    }

let evaluate_qiyan_jueju verses =
  let verse_count = Array.length verses in
  if verse_count <> 4 then
    Poetry_evaluation_engine.comprehensive_artistic_evaluation (if verse_count > 0 then verses.(0) else "") None
  else
    (* 七言绝句主要评价韵律和意境 *)
    let combined_verse = String.concat "" (Array.to_list verses) in
    Poetry_evaluation_engine.comprehensive_artistic_evaluation combined_verse None

let evaluate_poetry_by_form form verses =
  match form with
  | SiYanPianTi | SiYanParallelProse -> evaluate_siyan_parallel_prose verses
  | WuYanLuShi -> evaluate_wuyan_lushi verses
  | QiYanJueJu -> evaluate_qiyan_jueju verses
  | CiPai _ | ModernPoetry -> 
    let combined = String.concat "" (Array.to_list verses) in
    Poetry_evaluation_engine.comprehensive_artistic_evaluation combined None

(** {1 传统诗词品评函数} *)

let poetic_critique verse form =
  let base_report = Poetry_evaluation_engine.comprehensive_artistic_evaluation verse None in
  let critique_suggestions = match form with
    | SiYanPianTi | SiYanParallelProse ->
      ["骈体之美在于对仗工整，声韵和谐"]
    | WuYanLuShi ->
      ["律诗之妙在于格律严谨，意境深远"]  
    | QiYanJueJu ->
      ["绝句之巧在于起承转合，言简意赅"]
    | _ ->
      ["诗词之道，在于意境与声韵并重"]
  in
  { base_report with suggestions = critique_suggestions }

let poetic_aesthetics_guidance verse form =
  let base_report = Poetry_evaluation_engine.comprehensive_artistic_evaluation verse None in
  let guidance = match form with
    | SiYanPianTi | SiYanParallelProse ->
      ["注重对偶工整"; "追求声律和谐"; "用词典雅得体"]
    | WuYanLuShi ->
      ["遵循格律规范"; "中间两联对仗"; "首尾呼应"]
    | QiYanJueJu ->
      ["起句立意"; "承句发展"; "转句生变"; "合句收束"]
    | _ ->
      ["意境为先"; "声韵和谐"; "用词精练"]
  in
  { base_report with suggestions = guidance }

(** {1 高阶艺术性分析函数} *)

let analyze_artistic_progression verses =
  Array.map (fun verse ->
    let report = Poetry_evaluation_engine.comprehensive_artistic_evaluation verse None in
    Poetry_analysis_utils.calculate_overall_score report
  ) verses |> Array.to_list

let compare_artistic_quality verse1 verse2 =
  let report1 = Poetry_evaluation_engine.comprehensive_artistic_evaluation verse1 None in
  let report2 = Poetry_evaluation_engine.comprehensive_artistic_evaluation verse2 None in
  let score1 = Poetry_analysis_utils.calculate_overall_score report1 in
  let score2 = Poetry_analysis_utils.calculate_overall_score report2 in
  if score1 > score2 then 1
  else if score1 < score2 then -1
  else 0

let detect_artistic_flaws verse =
  let report = Poetry_evaluation_engine.comprehensive_artistic_evaluation verse None in
  Poetry_analysis_utils.detect_artistic_flaws verse report