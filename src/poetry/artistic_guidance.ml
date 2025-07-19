(* 诗词艺术指导模块 - 评价报告生成和改进建议
   从artistic_evaluation.ml中提取的指导和建议功能
*)

open Artistic_types
open Artistic_evaluators

(** 生成改进建议：根据评价结果提供具体的改进建议 *)
let generate_improvement_suggestions report =
  let suggestions = ref [] in

  if report.rhyme_score < 0.6 then suggestions := "建议调整韵脚，使音韵更加和谐" :: !suggestions;

  if report.tone_score < 0.6 then suggestions := "建议调整平仄搭配，使声调更加平衡" :: !suggestions;

  if report.parallelism_score < 0.6 then suggestions := "建议加强对仗工整度，使结构更加对称" :: !suggestions;

  if report.imagery_score < 0.6 then suggestions := "建议丰富意象表达，使诗句更有深度" :: !suggestions;

  if report.rhythm_score < 0.6 then suggestions := "建议调整节奏感，使诗句更有韵律美" :: !suggestions;

  if report.elegance_score < 0.6 then suggestions := "建议使用更雅致的词汇，提升诗句品味" :: !suggestions;

  if !suggestions = [] then [ "诗句已达较高水准，可在细节上继续打磨" ] else List.rev !suggestions

(** 全面艺术性评价：为诗句提供全面的艺术性分析 *)
let comprehensive_artistic_evaluation verse expected_pattern =
  let rhyme_score = evaluate_rhyme_harmony verse in
  let tone_score = evaluate_tonal_balance verse expected_pattern in
  let parallelism_score = 0.7 in
  (* 单句评价，暂设默认值 *)
  let imagery_score = evaluate_imagery verse in
  let rhythm_score = evaluate_rhythm verse in
  let elegance_score = evaluate_elegance verse in

  let scores =
    {
      rhyme_harmony = rhyme_score;
      tonal_balance = tone_score;
      parallelism = parallelism_score;
      imagery = imagery_score;
      rhythm = rhythm_score;
      elegance = elegance_score;
    }
  in

  let overall_grade = determine_overall_grade scores in

  let initial_report =
    {
      verse;
      rhyme_score;
      tone_score;
      parallelism_score;
      imagery_score;
      rhythm_score;
      elegance_score;
      overall_grade;
      suggestions = [];
    }
  in

  let suggestions = generate_improvement_suggestions initial_report in

  { initial_report with suggestions }

(** 增强版全面艺术性评价：提供更详细的分析报告 *)
let enhanced_comprehensive_artistic_evaluation verse =
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
      (* 单句无对仗 *)
      imagery = imagery_score;
      rhythm = rhythm_score;
      elegance = elegance_score;
    }
  in

  let overall_grade = determine_overall_grade scores in

  let detailed_suggestions =
    let basic_suggestions = ref [] in

    (* 根据具体得分给出详细建议 *)
    if rhyme_score < 0.4 then basic_suggestions := "韵律和谐度较低，建议选择协调的韵母组合" :: !basic_suggestions
    else if rhyme_score < 0.7 then basic_suggestions := "韵律基本和谐，可进一步优化音韵搭配" :: !basic_suggestions;

    if tone_score < 0.4 then basic_suggestions := "声调平衡需要改善，注意平仄相间的节奏" :: !basic_suggestions
    else if tone_score < 0.7 then basic_suggestions := "声调搭配尚可，可追求更丰富的音调变化" :: !basic_suggestions;

    if imagery_score < 0.4 then basic_suggestions := "意象表达不够深刻，建议融入更多诗意元素" :: !basic_suggestions
    else if imagery_score < 0.7 then basic_suggestions := "意象有一定深度，可进一步提升意境层次" :: !basic_suggestions;

    if rhythm_score < 0.4 then basic_suggestions := "节奏感需要改善，注意字数和声调的协调" :: !basic_suggestions
    else if rhythm_score < 0.7 then basic_suggestions := "节奏基本流畅，可追求更优美的韵律节拍" :: !basic_suggestions;

    if elegance_score < 0.4 then basic_suggestions := "用词雅致度有待提升，建议采用更典雅的表达" :: !basic_suggestions
    else if elegance_score < 0.7 then basic_suggestions := "用词较为雅致，可进一步提升文学品味" :: !basic_suggestions;

    if !basic_suggestions = [] then [ "诗句各方面表现优秀，已达到较高的艺术水准" ] else List.rev !basic_suggestions
  in

  {
    verse;
    rhyme_score;
    tone_score;
    parallelism_score = 0.0;
    imagery_score;
    rhythm_score;
    elegance_score;
    overall_grade;
    suggestions = detailed_suggestions;
  }

(** 诗词评论：根据诗词类型提供专业评论 *)
let poetic_critique verse poetry_type =
  let base_evaluation = enhanced_comprehensive_artistic_evaluation verse in

  let type_specific_suggestions =
    match poetry_type with
    | WuYanLuShi -> [ "五言律诗要求平仄严格，颔联颈联必须对仗"; "意境要深远含蓄，体现古典诗词的意蕴"; "用词要典雅精炼，避免俗语白话" ]
    | QiYanJueJu -> [ "七言绝句讲究起承转合，四句各有功能"; "第二第四句通常押韵，营造音韵美感"; "语言要简洁有力，意象要鲜明生动" ]
    | _ -> [ "根据所选诗词体裁特点进行创作" ]
  in

  { base_evaluation with suggestions = base_evaluation.suggestions @ type_specific_suggestions }

(** 诗词美学指导：提供针对特定诗词类型的美学指导 *)
let poetic_aesthetics_guidance verse poetry_type =
  let evaluation = poetic_critique verse poetry_type in

  let aesthetic_principles =
    match poetry_type with
    | WuYanLuShi -> [ "五言律诗追求'含蓄蕴藉'的美学效果"; "通过精炼的五言表达深刻的思想情感"; "格律严谨是基础，意境深远是目标" ]
    | QiYanJueJu -> [ "七言绝句体现'言有尽而意无穷'的艺术特色"; "在有限的篇幅内创造无限的想象空间"; "追求自然流畅而又工整优美的表达" ]
    | SiYanPianTi -> [ "四言骈体注重音韵和谐与对偶工整"; "体现汉语的韵律美和结构美"; "用词要典雅古朴，体现传统文化底蕴" ]
    | ModernPoetry -> [ "现代诗重视个性化表达和创新性"; "在传承中创新，在创新中传承"; "注重情感的真挚表达和艺术的独特性" ]
    | _ -> [ "根据诗词体裁特点追求相应的美学效果" ]
  in

  { evaluation with suggestions = evaluation.suggestions @ aesthetic_principles }
