(** 具体诗词形式评价器模块 - 包含各种诗词体裁的专门评价函数 *)

open Artistic_types
open Poetry_standards
open Artistic_evaluators
open Evaluation_framework

(** 五言律诗艺术性评价函数 *)
let evaluate_wuyan_lushi verses =
  (* 验证诗词格式 *)
  if Array.length verses != 8 then create_error_evaluation verses "五言律诗必须为八句，当前句数不符合要求"
  else
    (* 使用通用框架计算各项得分 *)
    let verse_combined = String.concat "\n" (Array.to_list verses) in
    let rhyme_score = evaluate_rhyme_harmony verse_combined in
    let tone_score =
      calculate_tone_scores verses (Some (Array.of_list wuyan_lushi_standards.tone_pattern))
    in
    let parallelism_score = calculate_parallelism_scores verses [ (2, 3); (4, 5) ] in
    let imagery_score = evaluate_imagery verse_combined in
    let rhythm_score = evaluate_rhythm verse_combined in
    let elegance_score = evaluate_elegance verse_combined in

    (* 五言律诗权重配置 *)
    let weights =
      {
        rhyme_weight = 0.3;
        tone_weight = 0.3;
        parallelism_weight = 0.25;
        imagery_weight = 0.1;
        rhythm_weight = 0.03;
        elegance_weight = 0.02;
      }
    in

    let scores =
      (rhyme_score, tone_score, parallelism_score, imagery_score, rhythm_score, elegance_score)
    in
    let overall_grade = calculate_overall_grade weights scores in
    let suggestions = [ "五言律诗讲究格律严谨，颔联、颈联必须对仗"; "韵脚通常在第二、四、六、八句"; "意境要深远，情景交融，体现文人雅士风范" ] in

    { (create_evaluation_result verse_combined scores suggestions) with overall_grade }

(** 七言绝句艺术性评价函数 *)
let evaluate_qiyan_jueju verses =
  (* 验证诗词格式 *)
  if Array.length verses != 4 then create_error_evaluation verses "七言绝句必须为四句，当前句数不符合要求"
  else
    (* 使用通用框架计算各项得分 *)
    let verse_combined = String.concat "\n" (Array.to_list verses) in
    let rhyme_score = evaluate_rhyme_harmony verse_combined in
    let tone_score =
      calculate_tone_scores verses (Some (Array.of_list qiyan_jueju_standards.tone_pattern))
    in
    let parallelism_score = calculate_parallelism_scores verses [ (2, 3) ] in
    let imagery_score = evaluate_imagery verse_combined in
    let rhythm_score = evaluate_rhythm verse_combined in
    let elegance_score = evaluate_elegance verse_combined in

    (* 七言绝句权重配置 *)
    let weights =
      {
        rhyme_weight = 0.25;
        tone_weight = 0.25;
        parallelism_weight = 0.2;
        imagery_weight = 0.15;
        rhythm_weight = 0.1;
        elegance_weight = 0.05;
      }
    in

    let scores =
      (rhyme_score, tone_score, parallelism_score, imagery_score, rhythm_score, elegance_score)
    in
    let overall_grade = calculate_overall_grade weights scores in
    let suggestions = [ "七言绝句要起承转合，四句成篇"; "第二、四句通常押韵"; "语言要精炼，意象要鲜明，情感要真挚" ] in

    { (create_evaluation_result verse_combined scores suggestions) with overall_grade }

(** 四言骈体评价专用函数 *)
let evaluate_siyan_pianti verses =
  if Array.length verses > 0 then
    let verse = verses.(0) in
    let rhyme_score = evaluate_rhyme_harmony verse in
    let tone_score = evaluate_tonal_balance verse None in
    let imagery_score = evaluate_imagery verse in
    let rhythm_score = evaluate_rhythm verse in
    let elegance_score = evaluate_elegance verse in

    let scores =
      {
        rhyme_harmony = rhyme_score;
        tonal_balance = tone_score;
        parallelism = 0.0;
        imagery = imagery_score;
        rhythm = rhythm_score;
        elegance = elegance_score;
      }
    in

    {
      verse;
      rhyme_score;
      tone_score;
      parallelism_score = 0.0;
      imagery_score;
      rhythm_score;
      elegance_score;
      overall_grade = determine_overall_grade scores;
      suggestions = [ "四言骈体注重音韵和谐，用词典雅" ];
    }
  else create_error_evaluation verses "输入内容为空"

(** 词牌格律评价专用函数 *)
let evaluate_cipai _cipai_type verses =
  {
    verse = String.concat "\n" (Array.to_list verses);
    rhyme_score = 0.5;
    tone_score = 0.5;
    parallelism_score = 0.5;
    imagery_score = 0.5;
    rhythm_score = 0.5;
    elegance_score = 0.5;
    overall_grade = Fair;
    suggestions = [ "词牌格律评价功能正在开发中" ];
  }

(** 现代诗评价专用函数 *)
let evaluate_modern_poetry verses =
  let verse_combined = String.concat "\n" (Array.to_list verses) in
  let imagery_score = evaluate_imagery verse_combined in
  let rhythm_score = evaluate_rhythm verse_combined in
  let elegance_score = evaluate_elegance verse_combined in

  let overall_score = (imagery_score *. 0.4) +. (rhythm_score *. 0.3) +. (elegance_score *. 0.3) in
  let overall_grade =
    if overall_score >= 0.8 then Excellent
    else if overall_score >= 0.65 then Good
    else if overall_score >= 0.45 then Fair
    else Poor
  in

  {
    verse = verse_combined;
    rhyme_score = 0.0;
    tone_score = 0.0;
    parallelism_score = 0.0;
    imagery_score;
    rhythm_score;
    elegance_score;
    overall_grade;
    suggestions = [ "现代诗注重意象表达和情感传达"; "语言要有节奏感，但不拘泥于传统格律"; "追求个性化的表达方式和独特的艺术效果" ];
  }

(** 四言排律评价：专门评价四言排律的对偶结构 *)
let evaluate_siyan_parallel_prose verses =
  if Array.length verses mod 2 <> 0 then create_error_evaluation verses "四言排律要求句数为偶数，以便形成对仗"
  else
    let total_verses = Array.length verses in
    let parallelism_pairs =
      Array.to_list (Array.init (total_verses / 2) (fun i -> (i * 2, (i * 2) + 1)))
    in

    let verse_combined = String.concat "\n" (Array.to_list verses) in
    let rhyme_score = evaluate_rhyme_harmony verse_combined in
    let tone_score =
      calculate_tone_scores verses (Some (Array.of_list [ siyan_standards.tone_pattern ]))
    in
    let parallelism_score = calculate_parallelism_scores verses parallelism_pairs in
    let imagery_score = evaluate_imagery verse_combined in
    let rhythm_score = evaluate_rhythm verse_combined in
    let elegance_score = evaluate_elegance verse_combined in

    (* 四言排律权重配置 - 高度重视对仗 *)
    let weights =
      {
        rhyme_weight = 0.2;
        tone_weight = 0.25;
        parallelism_weight = 0.35;
        (* 对仗是核心 *)
        imagery_weight = 0.1;
        rhythm_weight = 0.05;
        elegance_weight = 0.05;
      }
    in

    let scores =
      (rhyme_score, tone_score, parallelism_score, imagery_score, rhythm_score, elegance_score)
    in
    let overall_grade = calculate_overall_grade weights scores in
    let suggestions = [ "四言排律要求每两句对仗，结构严整"; "用词要典雅工整，避免重复和生硬"; "意境要统一，通过对仗展现诗意之美" ] in

    { (create_evaluation_result verse_combined scores suggestions) with overall_grade }
