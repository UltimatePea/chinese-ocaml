(* 音韵分析模块 - 骆言诗词编程特性
   盖古之诗者，音韵为要。声韵调谐，方称佳构。
   此模块为音韵分析的主要协调模块，整合各子模块功能。
   凡诗词编程，必先通音韵，后成文章。
*)

(* 导入子模块 *)
open Rhyme_types
open Rhyme_matching
open Rhyme_pattern
open Rhyme_scoring

(* 简单的UTF-8字符列表转换函数 *)
let utf8_to_char_list s =
  let rec aux acc i =
    if i >= String.length s then List.rev acc
    else aux (String.make 1 s.[i] :: acc) (i + 1)
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
let rhyme_group_to_string = Rhyme_matching.rhyme_group_to_string
let rhyme_category_to_string = Rhyme_matching.rhyme_category_to_string

(* 韵律模式相关函数 *)
let extract_rhyme_ending = Rhyme_pattern.extract_rhyme_ending
let validate_rhyme_consistency = Rhyme_pattern.validate_rhyme_consistency
let validate_rhyme_scheme = Rhyme_pattern.validate_rhyme_scheme
let analyze_rhyme_pattern = Rhyme_pattern.analyze_rhyme_pattern
let generate_rhyme_report verse =
  let pattern_report = Rhyme_pattern.generate_rhyme_report verse in
  {
    verse = pattern_report.Rhyme_pattern.verse;
    rhyme_ending = pattern_report.Rhyme_pattern.rhyme_ending;
    rhyme_group = pattern_report.Rhyme_pattern.rhyme_group;
    rhyme_category = pattern_report.Rhyme_pattern.rhyme_category;
    char_analysis = pattern_report.Rhyme_pattern.char_analysis;
  }
let analyze_poem_rhyme verses =
  let pattern_analysis = Rhyme_pattern.analyze_poem_rhyme verses in
  {
    verses = pattern_analysis.Rhyme_pattern.verses;
    verse_reports = List.map (fun report -> {
      verse = report.Rhyme_pattern.verse;
      rhyme_ending = report.Rhyme_pattern.rhyme_ending;
      rhyme_group = report.Rhyme_pattern.rhyme_group;
      rhyme_category = report.Rhyme_pattern.rhyme_category;
      char_analysis = report.Rhyme_pattern.char_analysis;
    }) pattern_analysis.Rhyme_pattern.verse_reports;
    rhyme_groups = pattern_analysis.Rhyme_pattern.rhyme_groups;
    rhyme_categories = pattern_analysis.Rhyme_pattern.rhyme_categories;
    rhyme_quality = pattern_analysis.Rhyme_pattern.rhyme_quality;
    rhyme_consistency = pattern_analysis.Rhyme_pattern.rhyme_consistency;
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

(* 重新导出类型定义 *)
type rhyme_analysis_report = {
  verse : string;
  rhyme_ending : char option;
  rhyme_group : rhyme_group;
  rhyme_category : rhyme_category;
  char_analysis : (char * rhyme_category * rhyme_group) list;
}

type poem_rhyme_analysis = {
  verses : string list;
  verse_reports : rhyme_analysis_report list;
  rhyme_groups : rhyme_group list;
  rhyme_categories : rhyme_category list;
  rhyme_quality : float;
  rhyme_consistency : bool;
}

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

type score_grade = 
  | Excellent    (* 优秀 - 90分以上 *)
  | Good         (* 良好 - 80-90分 *)
  | Average      (* 一般 - 70-80分 *)
  | Poor         (* 较差 - 60-70分 *)
  | VeryPoor     (* 很差 - 60分以下 *)

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
  let pattern_analysis = Rhyme_pattern.analyze_poem_rhyme verses in
  let score_report = Rhyme_scoring.generate_comprehensive_score verses in
  let suggestions = Rhyme_scoring.generate_improvement_suggestions score_report in
  let grade = Rhyme_scoring.score_to_grade score_report.overall_quality in
  let grade_str = Rhyme_scoring.grade_to_string grade in
  
  (* Convert types to match our interface *)
  let rhyme_analysis = {
    verses = pattern_analysis.Rhyme_pattern.verses;
    verse_reports = List.map (fun report -> {
      verse = report.Rhyme_pattern.verse;
      rhyme_ending = report.Rhyme_pattern.rhyme_ending;
      rhyme_group = report.Rhyme_pattern.rhyme_group;
      rhyme_category = report.Rhyme_pattern.rhyme_category;
      char_analysis = report.Rhyme_pattern.char_analysis;
    }) pattern_analysis.Rhyme_pattern.verse_reports;
    rhyme_groups = pattern_analysis.Rhyme_pattern.rhyme_groups;
    rhyme_categories = pattern_analysis.Rhyme_pattern.rhyme_categories;
    rhyme_quality = pattern_analysis.Rhyme_pattern.rhyme_quality;
    rhyme_consistency = pattern_analysis.Rhyme_pattern.rhyme_consistency;
  } in
  
  let score_report_converted = {
    overall_quality = score_report.overall_quality;
    diversity_score = score_report.diversity_score;
    regularity_score = score_report.regularity_score;
    harmony_score = score_report.harmony_score;
    completeness_score = score_report.completeness_score;
    consistency_score = score_report.consistency_score;
    verse_count = score_report.verse_count;
    rhymed_count = score_report.rhymed_count;
    pattern_type = score_report.pattern_type;
  } in
  
  let grade_converted = match grade with
    | Rhyme_scoring.Excellent -> Excellent
    | Rhyme_scoring.Good -> Good
    | Rhyme_scoring.Average -> Average
    | Rhyme_scoring.Poor -> Poor
    | Rhyme_scoring.VeryPoor -> VeryPoor
  in
  
  {
    rhyme_analysis = rhyme_analysis;
    score_report = score_report_converted;
    suggestions = suggestions;
    grade = grade_converted;
    grade_description = grade_str;
  }

(* 智能韵律建议：基于分析结果提供智能建议 *)
let smart_rhyme_suggestions verses =
  let analysis = comprehensive_poem_analysis verses in
  let base_suggestions = analysis.suggestions in
  let rhyme_groups = analysis.rhyme_analysis.rhyme_groups in
  
  (* 根据韵组分布提供具体建议 *)
  let group_suggestions = 
    if List.length (List.sort_uniq compare rhyme_groups) > 3 then
      ["建议减少韵组数量，保持韵律统一性"]
    else if List.length (List.sort_uniq compare rhyme_groups) < 2 then
      ["建议适当增加韵律变化，避免过于单调"]
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
  
  {
    consistency = consistency;
    quality_score = quality_score;
    quality_grade = quality_grade;
    pattern_type = pattern_type;
    diagnosis = diagnosis;
  }

(* 韵律优化建议：针对特定韵律问题提供优化建议 *)
let optimize_rhyme_suggestions verses target_quality =
  let current_quality = evaluate_rhyme_quality verses in
  let gap = target_quality -. current_quality in
  
  if gap <= 0.0 then []
  else
    let suggestions = ref [] in
    
    if gap > 0.3 then
      suggestions := "建议重新设计整体韵律结构" :: !suggestions;
    
    if gap > 0.2 then
      suggestions := "建议优化韵脚选择，提高韵律和谐度" :: !suggestions;
    
    if gap > 0.1 then
      suggestions := "建议调整个别韵脚，增强韵律一致性" :: !suggestions;
    
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
  let basic_concepts = [
    "韵脚：每句诗末尾的字符，用于押韵";
    "韵组：音韵相近的字符分组，同组内字符可以押韵";
    "韵类：按声调分类，包括平声、仄声、上声、去声、入声";
    "韵律模式：诗词的押韵格式，如ABAB、AABB等";
  ] in
  
  let verse_examples = List.mapi (fun i verse ->
    let report = generate_rhyme_report verse in
    let ending_str = match report.rhyme_ending with
      | Some char -> String.make 1 char
      | None -> "无"
    in
    Printf.sprintf "第%d句：%s，韵脚：%s，韵组：%s" 
      (i + 1) verse ending_str (rhyme_group_to_string report.rhyme_group)
  ) verses in
  
  {
    basic_concepts = basic_concepts;
    verse_examples = verse_examples;
    analysis_summary = analysis;
    learning_tips = [
      "多读古诗词，培养韵律感";
      "掌握常用韵组，便于押韵";
      "练习识别韵律模式";
      "注意平仄搭配的重要性";
    ];
  }

(* 导出函数：模块接口导出
   开放接口，供外部调用。音韵分析，皆可得之。
*)
let () = ()