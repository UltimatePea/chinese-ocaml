(* 音韵分析模块 - 骆言诗词编程特性
   盖古之诗者，音韵为要。声韵调谐，方称佳构。
   此模块为音韵分析的主要协调模块，整合各子模块功能。
   凡诗词编程，必先通音韵，后成文章。
*)

(* 导入子模块 *)
open Rhyme_types

(* open Rhyme_matching *)
(* open Rhyme_pattern *)
open Rhyme_scoring

(* 简单的UTF-8字符列表转换函数 *)
let utf8_to_char_list s =
  let rec aux acc i =
    if i >= String.length s then List.rev acc else aux (String.make 1 s.[i] :: acc) (i + 1)
  in
  aux [] 0

(* 重新导出核心函数，保持向后兼容性 *)

(* 音韵匹配相关函数 *)
let find_rhyme_info = Rhyme_matching.find_rhyme_info
let detect_rhyme_category = Rhyme_matching.detect_rhyme_category
let detect_rhyme_category_by_string = Rhyme_matching.detect_rhyme_category_by_string
let detect_rhyme_group = Rhyme_matching.detect_rhyme_group
let chars_rhyme = Rhyme_matching.chars_rhyme
let suggest_rhyme_characters = Rhyme_matching.suggest_rhyme_characters

(* 韵律模式相关函数 *)
let extract_rhyme_ending = Rhyme_pattern.extract_rhyme_ending
let validate_rhyme_consistency = Rhyme_pattern.validate_rhyme_consistency
let validate_rhyme_scheme = Rhyme_pattern.validate_rhyme_scheme
let analyze_rhyme_pattern = Rhyme_pattern.analyze_rhyme_pattern

let generate_rhyme_report verse =
  let rhyme_ending = extract_rhyme_ending verse in
  let rhyme_group =
    match rhyme_ending with
    | Some char -> Rhyme_matching.detect_rhyme_group char
    | None -> UnknownRhyme
  in
  let rhyme_category =
    match rhyme_ending with
    | Some char -> Rhyme_matching.detect_rhyme_category char
    | None -> PingSheng
  in
  let chars = utf8_to_char_list verse in
  let char_analysis =
    List.map
      (fun char_str ->
        let char = if String.length char_str > 0 then char_str.[0] else '?' in
        (char, Rhyme_matching.detect_rhyme_category char, Rhyme_matching.detect_rhyme_group char))
      chars
  in
  { Rhyme_types.verse; rhyme_ending; rhyme_group; rhyme_category; char_analysis }

let analyze_poem_rhyme verses =
  let verse_reports = List.map generate_rhyme_report verses in
  let rhyme_groups = List.map (fun report -> report.Rhyme_types.rhyme_group) verse_reports in
  let rhyme_categories = List.map (fun report -> report.Rhyme_types.rhyme_category) verse_reports in
  let rhyme_quality = evaluate_rhyme_quality verses in
  let rhyme_consistency = validate_rhyme_consistency verses in
  {
    Rhyme_types.verses;
    verse_reports;
    rhyme_groups;
    rhyme_categories;
    rhyme_quality;
    rhyme_consistency;
  }

let suggest_rhyme_improvements = Rhyme_pattern.suggest_rhyme_improvements
let detect_rhyme_pattern = Rhyme_pattern.detect_rhyme_pattern
let validate_specific_pattern = Rhyme_pattern.validate_specific_pattern
let identify_pattern_type = Rhyme_pattern.identify_pattern_type
let common_patterns = Rhyme_pattern.common_patterns

(* 韵律评分相关函数 *)
let evaluate_rhyme_quality = Rhyme_scoring.evaluate_rhyme_quality
let evaluate_rhyme_diversity = Rhyme_scoring.evaluate_rhyme_diversity
let evaluate_rhyme_regularity = Rhyme_scoring.evaluate_rhyme_regularity
let evaluate_rhyme_harmony = Rhyme_scoring.evaluate_rhyme_harmony
let evaluate_rhyme_completeness = Rhyme_scoring.evaluate_rhyme_completeness
let generate_comprehensive_score = Rhyme_scoring.generate_comprehensive_score
let score_to_grade = Rhyme_scoring.score_to_grade
let grade_to_string = Rhyme_scoring.grade_to_string
let generate_improvement_suggestions = Rhyme_scoring.generate_improvement_suggestions
let quick_quality_check = Rhyme_scoring.quick_quality_check
let compare_rhyme_quality = Rhyme_scoring.compare_rhyme_quality

(* 类型定义直接使用 Rhyme_types 中的定义 *)

(* 直接使用 Rhyme_scoring 中的类型定义 *)

(* 直接使用 Rhyme_scoring 中的类型定义 *)

(* 高级分析函数：整合多个模块功能 *)

(* 综合分析结果类型 *)
type comprehensive_analysis = {
  rhyme_analysis : poem_rhyme_analysis;
  score_report : rhyme_score_report;
  suggestions : string list;
  grade : score_grade;
  grade_description : string;
}

(* 综合诗词分析：结合韵律分析和评分功能 *)
let comprehensive_poem_analysis verses =
  let rhyme_analysis = analyze_poem_rhyme verses in
  let score_report = generate_comprehensive_score verses in
  let suggestions = generate_improvement_suggestions score_report in
  let grade = score_to_grade score_report.overall_quality in
  let grade_str = grade_to_string grade in

  { rhyme_analysis; score_report; suggestions; grade; grade_description = grade_str }

(* 智能韵律建议：基于分析结果提供智能建议 *)
let smart_rhyme_suggestions verses =
  let analysis = comprehensive_poem_analysis verses in
  let base_suggestions = analysis.suggestions in
  let rhyme_groups = analysis.rhyme_analysis.Rhyme_types.rhyme_groups in

  (* 根据韵组分布提供具体建议 *)
  let group_suggestions =
    if List.length (List.sort_uniq compare rhyme_groups) > 3 then [ "建议减少韵组数量，保持韵律统一性" ]
    else if List.length (List.sort_uniq compare rhyme_groups) < 2 then [ "建议适当增加韵律变化，避免过于单调" ]
    else []
  in

  base_suggestions @ group_suggestions

(* 快速诊断结果类型 *)
type quick_diagnosis = {
  consistency : bool;
  quality_score : float;
  quality_grade : string;
  pattern_type : string option;
  diagnosis : string;
}

(* 快速韵律诊断：提供快速的韵律问题诊断 *)
let quick_rhyme_diagnosis verses =
  let consistency = validate_rhyme_consistency verses in
  let quality_score, quality_grade = quick_quality_check verses in
  let pattern_type = identify_pattern_type verses in

  let diagnosis =
    if not consistency then "韵律不一致，建议统一韵脚"
    else if quality_score < 0.6 then "韵律质量较差，建议重新调整"
    else if quality_score < 0.8 then "韵律质量一般，可以进一步优化"
    else "韵律质量良好"
  in

  { consistency; quality_score; quality_grade; pattern_type; diagnosis }

(* 韵律优化建议：针对特定韵律问题提供优化建议 *)
let optimize_rhyme_suggestions verses target_quality =
  let current_quality = evaluate_rhyme_quality verses in
  let gap = target_quality -. current_quality in

  if gap <= 0.0 then []
  else
    let suggestions = ref [] in

    if gap > 0.3 then suggestions := "建议重新设计整体韵律结构" :: !suggestions;

    if gap > 0.2 then suggestions := "建议优化韵脚选择，提高韵律和谐度" :: !suggestions;

    if gap > 0.1 then suggestions := "建议调整个别韵脚，增强韵律一致性" :: !suggestions;

    List.rev !suggestions

(* 韵律学习指导结果类型 *)
type learning_guide = {
  basic_concepts : string list;
  verse_examples : string list;
  analysis_summary : comprehensive_analysis;
  learning_tips : string list;
}

(* 韵律学习辅助：为学习者提供韵律学习指导 *)
let rhyme_learning_guide verses =
  let analysis = comprehensive_poem_analysis verses in
  let basic_concepts =
    [
      "韵脚：每句诗末尾的字符，用于押韵";
      "韵组：音韵相近的字符分组，同组内字符可以押韵";
      "韵类：按声调分类，包括平声、仄声、上声、去声、入声";
      "韵律模式：诗词的押韵格式，如ABAB、AABB等";
    ]
  in

  let verse_examples =
    List.mapi
      (fun i verse ->
        let report = generate_rhyme_report verse in
        let ending_str =
          match report.Rhyme_types.rhyme_ending with Some char -> String.make 1 char | None -> "无"
        in
        Yyocamlc_lib.Unified_formatter.PoetryFormatting.verse_analysis (i + 1) verse ending_str
          (Rhyme_types.rhyme_group_to_string report.Rhyme_types.rhyme_group))
      verses
  in

  {
    basic_concepts;
    verse_examples;
    analysis_summary = analysis;
    learning_tips = [ "多读古诗词，培养韵律感"; "掌握常用韵组，便于押韵"; "练习识别韵律模式"; "注意平仄搭配的重要性" ];
  }

(* 导出函数：模块接口导出
   开放接口，供外部调用。音韵分析，皆可得之。
*)
let () = ()
