(* 韵律评分系统模块 - 骆言诗词编程特性
   专司韵律质量之评定，衡量诗词之工拙。
   盖诗词有工拙之分，韵律有高低之别。
   此模块实现韵律质量评估、和谐程度分析等功能。
*)

(* 导入韵母类型定义 *)
open Rhyme_types

(* 检测押韵质量：评估韵脚的和谐程度
   押韵有工拙之分，此函评估韵脚和谐程度。
*)
let evaluate_rhyme_quality verses =
  let rhyme_endings = List.filter_map Rhyme_pattern.extract_rhyme_ending verses in
  let rhyme_groups = List.map Rhyme_matching.detect_rhyme_group rhyme_endings in
  let rhyme_categories = List.map Rhyme_matching.detect_rhyme_category rhyme_endings in

  let unique_groups = List.sort_uniq compare rhyme_groups in
  let unique_categories = List.sort_uniq compare rhyme_categories in

  let group_consistency =
    if List.length unique_groups <= 1 then 1.0
    else if List.length unique_groups = 2 then 0.7
    else 0.4
  in

  let category_consistency =
    if List.length unique_categories <= 1 then 1.0
    else if List.length unique_categories = 2 then 0.8
    else 0.5
  in

  (* 综合评分 *)
  (group_consistency +. category_consistency) /. 2.0

(* 韵律丰富度评分：评估韵律的多样性
   韵律过于单调或过于复杂都会影响美感。
*)
let evaluate_rhyme_diversity verses =
  let rhyme_endings = List.filter_map Rhyme_pattern.extract_rhyme_ending verses in
  let rhyme_groups = List.map Rhyme_matching.detect_rhyme_group rhyme_endings in
  let unique_groups = List.sort_uniq compare rhyme_groups in
  let total_verses = List.length verses in
  let unique_count = List.length unique_groups in

  (* 理想的韵律多样性是适中的 *)
  if total_verses <= 2 then 1.0
  else if unique_count = 1 then 0.8 (* 单一韵律，较为单调 *)
  else if unique_count = 2 then 1.0 (* 双韵律，较为理想 *)
  else if unique_count <= total_verses / 2 then 0.9 (* 适度多样 *)
  else 0.6 (* 过于复杂 *)

(* 韵律规整度评分：评估韵律的规整程度
   传统诗词讲究韵律规整，如律诗、绝句等。
*)
let evaluate_rhyme_regularity verses =
  let pattern = Rhyme_pattern.detect_rhyme_pattern verses in
  let pattern_type = Rhyme_pattern.identify_pattern_type verses in

  match pattern_type with
  | Some _ -> 1.0 (* 符合传统韵律模式 *)
  | None ->
      (* 检查是否有基本的韵律规律 *)
      let pattern_length = List.length pattern in
      if pattern_length <= 2 then 0.7
      else
        let rec check_alternating = function
          | [] | [ _ ] -> true
          | a :: b :: rest -> a <> b && check_alternating (b :: rest)
        in
        if check_alternating pattern then 0.8 (* 交替韵律 *) else 0.5 (* 无明显规律 *)

(* 韵律协调度评分：评估韵律的协调程度
   检查平仄搭配、声调搭配等。
*)
let evaluate_rhyme_harmony verses =
  let rhyme_endings = List.filter_map Rhyme_pattern.extract_rhyme_ending verses in
  let rhyme_categories = List.map Rhyme_matching.detect_rhyme_category rhyme_endings in

  (* 检查平仄搭配 *)
  let ping_count = List.length (List.filter (fun cat -> cat = PingSheng) rhyme_categories) in
  let ze_count =
    List.length
      (List.filter (fun cat -> cat = ZeSheng || cat = ShangSheng || cat = QuSheng) rhyme_categories)
  in
  let ru_count = List.length (List.filter (fun cat -> cat = RuSheng) rhyme_categories) in

  let total = ping_count + ze_count + ru_count in
  if total = 0 then 1.0
  else
    let ping_ratio = float_of_int ping_count /. float_of_int total in

    (* 理想的平仄搭配应该相对均衡 *)
    if ping_ratio >= 0.3 && ping_ratio <= 0.7 then 1.0
    else if ping_ratio >= 0.2 && ping_ratio <= 0.8 then 0.8
    else 0.6

(* 韵律完整度评分：评估韵律的完整程度
   检查是否有缺失的韵脚、不完整的韵律等。
*)
let evaluate_rhyme_completeness verses =
  let rhyme_endings = List.filter_map Rhyme_pattern.extract_rhyme_ending verses in
  let total_verses = List.length verses in
  let rhymed_verses = List.length rhyme_endings in

  if total_verses = 0 then 1.0
  else
    let completeness_ratio = float_of_int rhymed_verses /. float_of_int total_verses in
    if completeness_ratio >= 0.9 then 1.0
    else if completeness_ratio >= 0.8 then 0.9
    else if completeness_ratio >= 0.7 then 0.8
    else if completeness_ratio >= 0.5 then 0.7
    else 0.5

(* 韵律评分详细报告类型 *)
type rhyme_score_report = {
  overall_quality : float;
  diversity_score : float;
  regularity_score : float;
  harmony_score : float;
  completeness_score : float;
  consistency_score : float;
  verse_count : int;
  rhymed_count : int;
  pattern_type : string option;
}

(* 生成综合韵律评分报告：对诗词进行全面的韵律评估
   如考官评卷，细致入微。多维度评估，给出综合评分。
*)
let generate_comprehensive_score verses =
  let quality_score = evaluate_rhyme_quality verses in
  let diversity_score = evaluate_rhyme_diversity verses in
  let regularity_score = evaluate_rhyme_regularity verses in
  let harmony_score = evaluate_rhyme_harmony verses in
  let completeness_score = evaluate_rhyme_completeness verses in
  let consistency_score = if Rhyme_pattern.validate_rhyme_consistency verses then 1.0 else 0.5 in

  let verse_count = List.length verses in
  let rhymed_count = List.length (List.filter_map Rhyme_pattern.extract_rhyme_ending verses) in
  let pattern_type = Rhyme_pattern.identify_pattern_type verses in

  (* 加权平均计算综合评分 *)
  let weights = [ 0.25; 0.15; 0.2; 0.15; 0.15; 0.1 ] in
  let scores =
    [
      quality_score;
      diversity_score;
      regularity_score;
      harmony_score;
      completeness_score;
      consistency_score;
    ]
  in
  let weighted_sum =
    List.fold_left2 (fun acc weight score -> acc +. (weight *. score)) 0.0 weights scores
  in

  {
    overall_quality = weighted_sum;
    diversity_score;
    regularity_score;
    harmony_score;
    completeness_score;
    consistency_score;
    verse_count;
    rhymed_count;
    pattern_type;
  }

(* 评分等级定义 *)
type score_grade =
  | Excellent (* 优秀 - 90分以上 *)
  | Good (* 良好 - 80-90分 *)
  | Average (* 一般 - 70-80分 *)
  | Poor (* 较差 - 60-70分 *)
  | VeryPoor (* 很差 - 60分以下 *)

(* 将评分转换为等级 *)
let score_to_grade score =
  let percentage = score *. 100.0 in
  if percentage >= 90.0 then Excellent
  else if percentage >= 80.0 then Good
  else if percentage >= 70.0 then Average
  else if percentage >= 60.0 then Poor
  else VeryPoor

(* 等级转换为字符串 *)
let grade_to_string = function
  | Excellent -> "优秀"
  | Good -> "良好"
  | Average -> "一般"
  | Poor -> "较差"
  | VeryPoor -> "很差"

(* 生成评分建议：根据评分结果提供改进建议 *)
let generate_improvement_suggestions report =
  let suggestions = ref [] in

  if report.consistency_score < 0.8 then suggestions := "建议统一韵脚，保持韵律一致性" :: !suggestions;

  if report.regularity_score < 0.7 then suggestions := "建议采用传统韵律格式，如绝句、律诗等" :: !suggestions;

  if report.harmony_score < 0.7 then suggestions := "建议注意平仄搭配，增强韵律和谐感" :: !suggestions;

  if report.completeness_score < 0.8 then suggestions := "建议为每句诗添加适当的韵脚字符" :: !suggestions;

  if report.diversity_score < 0.6 then suggestions := "建议适当增加韵律变化，避免过于单调" :: !suggestions;

  if report.overall_quality < 0.6 then suggestions := "建议重新审视整体韵律结构，考虑大幅调整" :: !suggestions;

  List.rev !suggestions

(* 快速韵律质量检查：提供快速的韵律质量评估 *)
let quick_quality_check verses =
  let score = evaluate_rhyme_quality verses in
  let grade = score_to_grade score in
  let grade_str = grade_to_string grade in
  (score, grade_str)

(* 韵律质量比较：比较两组诗词的韵律质量 *)
let compare_rhyme_quality verses1 verses2 =
  let score1 = evaluate_rhyme_quality verses1 in
  let score2 = evaluate_rhyme_quality verses2 in
  if score1 > score2 then 1 else if score1 < score2 then -1 else 0
