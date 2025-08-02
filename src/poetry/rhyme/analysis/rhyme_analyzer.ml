(** 骆言韵律分析统一模块 - Phase 1整合版本
    
    Author: Whisky, PR Worker
    Date: 2025-08-02
    Issue: #2084 Poetry模块架构整合计划
    
    此模块整合了以下分散的韵律分析模块：
    - analysis/rhyme_checker.ml (韵律检查器)
    - data/rhyme_analysis.ml (数据分析)
    - rhyme_helpers.ml (辅助工具)
    - rhyme_scoring.ml (评分算法)
    - parallelism_analysis.ml (对仗分析)
    
    整合目标: 5个分析文件 → 1个统一分析模块
    *)

open Poetry_core.Poetry_types

(** {1 分析结果类型} *)

type rhyme_pattern_analysis = {
  verse: string;
  rhyme_pattern: string;
  rhyme_consistency: float;
  dominant_groups: rhyme_group list;
  pattern_description: string;
}

type parallelism_analysis = {
  verse1: string;
  verse2: string;
  parallelism_score: float;
  structure_match: bool;
  tonal_contrast: bool;
  semantic_parallel: bool;
  improvement_suggestions: string list;
}

type comprehensive_rhyme_analysis = {
  verses: string list;
  verse_analyses: verse_rhyme_analysis list;
  overall_pattern: rhyme_pattern_analysis;
  parallelism_pairs: parallelism_analysis list;
  final_score: float;
  quality_assessment: string;
}

(** {2 分析配置} *)

type analysis_config = {
  strict_pattern_check: bool;
  require_tonal_contrast: bool;
  parallelism_weight: float;
  consistency_weight: float;
  pattern_weight: float;
}

let default_analysis_config = {
  strict_pattern_check = false;
  require_tonal_contrast = true;
  parallelism_weight = 0.3;
  consistency_weight = 0.4;
  pattern_weight = 0.3;
}

(** {3 核心韵律分析功能} *)

(** 分析诗句的韵律模式 *)
let analyze_verse_pattern ?(config = default_analysis_config) verse =
  let (verse_analysis : verse_rhyme_analysis) = Poetry_rhyme_core.Rhyme_engine.analyze_verse_rhyme verse in
  
  let pattern_chars = List.map (fun (char_info : char_rhyme_info) -> 
    if is_ping_sheng char_info.rhyme_category then "○" else "●"
  ) verse_analysis.char_analysis in
  
  let rhyme_pattern = String.concat "" pattern_chars in
  
  (* 根据配置调整一致性评分权重 *)
  let consistency = 
    if config.strict_pattern_check then
      verse_analysis.rhyme_quality_score *. 0.9  (* 严格模式下降低分数 *)
    else
      verse_analysis.rhyme_quality_score
  in
  
  let dominant_groups = [verse_analysis.dominant_rhyme_group] in
  
  let pattern_description = 
    let base_desc = match String.length rhyme_pattern with
    | 4 -> "四言格律"
    | 5 -> "五言格律"
    | 7 -> "七言格律"
    | n -> Printf.sprintf "%d言格律" n
    in
    if config.strict_pattern_check then base_desc ^ " (严格模式)" else base_desc
  in
  
  {
    verse;
    rhyme_pattern;
    rhyme_consistency = consistency;
    dominant_groups;
    pattern_description;
  }

(** 分析两句诗的对仗关系 *)
let analyze_parallelism ?(config = default_analysis_config) verse1 verse2 =
  let (analysis1 : verse_rhyme_analysis) = Poetry_rhyme_core.Rhyme_engine.analyze_verse_rhyme verse1 in
  let (analysis2 : verse_rhyme_analysis) = Poetry_rhyme_core.Rhyme_engine.analyze_verse_rhyme verse2 in
  
  (* 结构匹配检查 *)
  let char_count1 = List.length analysis1.char_analysis in
  let char_count2 = List.length analysis2.char_analysis in
  let structure_match = char_count1 = char_count2 in
  
  (* 声调对比检查 - 根据配置决定是否要求声调对比 *)
  let tonal_contrast = 
    if structure_match then
      let pairs = List.combine analysis1.char_analysis analysis2.char_analysis in
      let contrast_count = List.fold_left (fun acc ((char1 : char_rhyme_info), (char2 : char_rhyme_info)) ->
        if (is_ping_sheng char1.rhyme_category && is_ze_sheng char2.rhyme_category) ||
           (is_ze_sheng char1.rhyme_category && is_ping_sheng char2.rhyme_category) then
          acc + 1
        else acc
      ) 0 pairs in
      let contrast_ratio = float_of_int contrast_count /. float_of_int char_count1 in
      if config.require_tonal_contrast then contrast_ratio > 0.7 else contrast_ratio > 0.5
    else false
  in
  
  (* 语义对仗检查 (简化版本) *)
  let semantic_parallel = structure_match (* 简化为结构匹配 *) in
  
  (* 计算对仗分数 - 根据配置权重调整 *)
  let structure_score = if structure_match then 1.0 else 0.0 in
  let tonal_score = if tonal_contrast then 1.0 else 0.0 in
  let semantic_score = if semantic_parallel then 1.0 else 0.0 in
  
  (* 应用配置权重 *)
  let weighted_tonal_score = tonal_score *. (if config.require_tonal_contrast then 1.2 else 1.0) in
  let parallelism_score = (structure_score +. weighted_tonal_score +. semantic_score) /. 3.0 in
  
  (* 改进建议 *)
  let suggestions = 
    let acc = [] in
    let acc = if not structure_match then "建议保持相同字数" :: acc else acc in
    let acc = if not tonal_contrast then "建议注意平仄对比" :: acc else acc in
    let acc = if not semantic_parallel then "建议加强语义对仗" :: acc else acc in
    acc
  in
  
  {
    verse1;
    verse2;
    parallelism_score;
    structure_match;
    tonal_contrast;
    semantic_parallel;
    improvement_suggestions = suggestions;
  }

(** {4 综合分析功能} *)

(** 对整首诗进行综合韵律分析 *)
let analyze_poem_comprehensive ?(config = default_analysis_config) verses =
  let verse_analyses = List.map (fun verse -> (Poetry_rhyme_core.Rhyme_engine.analyze_verse_rhyme verse : verse_rhyme_analysis)) verses in
  
  (* 分析整体韵律模式 *)
  let overall_pattern = 
    let first_verse = List.hd verses in
    analyze_verse_pattern ~config first_verse
  in
  
  (* 分析对仗关系 *)
  let parallelism_pairs = 
    let rec analyze_pairs vs acc =
      match vs with
      | [] | [_] -> acc
      | v1 :: v2 :: rest ->
          let parallel = analyze_parallelism ~config v1 v2 in
          analyze_pairs rest (parallel :: acc)
    in
    analyze_pairs verses []
  in
  
  (* 计算综合分数 *)
  let consistency_score = 
    List.fold_left (fun acc analysis -> 
      acc +. analysis.rhyme_quality_score
    ) 0.0 verse_analyses /. float_of_int (List.length verse_analyses)
  in
  
  let parallelism_score = 
    if List.length parallelism_pairs > 0 then
      List.fold_left (fun acc parallel -> 
        acc +. parallel.parallelism_score
      ) 0.0 parallelism_pairs /. float_of_int (List.length parallelism_pairs)
    else 0.0
  in
  
  let pattern_score = overall_pattern.rhyme_consistency in
  
  let final_score = 
    (consistency_score *. config.consistency_weight) +.
    (parallelism_score *. config.parallelism_weight) +.
    (pattern_score *. config.pattern_weight)
  in
  
  (* 质量评估 *)
  let quality_assessment = 
    if final_score >= 0.9 then "上品 - 韵律完美，格律工整"
    else if final_score >= 0.7 then "中品 - 韵律良好，略有改进空间"
    else if final_score >= 0.5 then "下品 - 韵律尚可，需要调整"
    else "不入流 - 韵律混乱，需要重新修改"
  in
  
  {
    verses;
    verse_analyses;
    overall_pattern;
    parallelism_pairs;
    final_score;
    quality_assessment;
  }

(** {5 专项分析功能} *)

(** 分析韵脚一致性 *)
let analyze_rhyme_consistency verses =
  let endings = List.filter_map (fun verse ->
    if String.length verse > 0 then
      let last_char = String.sub verse (String.length verse - 1) 1 in
      Poetry_rhyme_core.Rhyme_engine.find_rhyme_info last_char
    else None
  ) verses in
  
  if List.length endings < 2 then 0.0
  else
    let first_ending = List.hd endings in
    let consistent_count = List.fold_left (fun acc (ending : Poetry_rhyme_core.Rhyme_engine.rhyme_lookup_result) ->
      if ending.group = first_ending.group then acc + 1 else acc
    ) 0 endings in
    float_of_int consistent_count /. float_of_int (List.length endings)

(** 分析声调平衡度 *)
let analyze_tonal_balance verses =
  let all_chars = String.concat "" verses |> String.split_on_char ' ' 
                 |> List.filter (fun s -> s <> "") in
  
  let ping_count = ref 0 in
  let ze_count = ref 0 in
  
  List.iter (fun char ->
    let category = Poetry_rhyme_core.Rhyme_engine.detect_rhyme_category char in
    if is_ping_sheng category then incr ping_count
    else if is_ze_sheng category then incr ze_count
  ) all_chars;
  
  let total = !ping_count + !ze_count in
  if total = 0 then 0.0
  else
    let balance = min !ping_count !ze_count in
    float_of_int balance /. float_of_int total *. 2.0

(** {6 诊断和建议功能} *)

(** 诊断韵律问题 *)
let diagnose_rhyme_issues analysis =
  let issues = ref [] in
  
  (* 检查韵律一致性 *)
  if analysis.final_score < 0.5 then
    issues := "整体韵律质量偏低" :: !issues;
  
  (* 检查对仗问题 *)
  List.iter (fun parallel ->
    if parallel.parallelism_score < 0.5 then
      let issue = Printf.sprintf "第%d句与第%d句对仗不工整" 1 2 in
      issues := issue :: !issues
  ) analysis.parallelism_pairs;
  
  (* 检查韵律模式 *)
  if analysis.overall_pattern.rhyme_consistency < 0.6 then
    issues := "韵律模式不够规整" :: !issues;
  
  !issues

(** 生成改进建议 *)
let generate_improvement_suggestions analysis =
  let suggestions = ref [] in
  
  if analysis.final_score < 0.7 then
    suggestions := "建议调整用词以提高韵律一致性" :: !suggestions;
  
  if List.length analysis.parallelism_pairs > 0 then (
    let avg_parallelism = List.fold_left (fun acc p -> acc +. p.parallelism_score) 0.0 analysis.parallelism_pairs 
                        /. float_of_int (List.length analysis.parallelism_pairs) in
    if avg_parallelism < 0.6 then
      suggestions := "建议加强对仗工整度" :: !suggestions
  );
  
  if analysis.overall_pattern.rhyme_consistency < 0.8 then
    suggestions := "建议统一韵组选择" :: !suggestions;
  
  !suggestions

(** {7 格式化输出功能} *)

(** 格式化分析报告 *)
let format_analysis_report analysis =
  let buffer = Buffer.create 1024 in
  
  Buffer.add_string buffer "=== 骆言韵律分析报告 ===\n\n";
  
  Buffer.add_string buffer "诗句内容:\n";
  List.iteri (fun i verse ->
    Buffer.add_string buffer (Printf.sprintf "%d. %s\n" (i+1) verse)
  ) analysis.verses;
  
  Buffer.add_string buffer (Printf.sprintf "\n综合评分: %.2f\n" analysis.final_score);
  Buffer.add_string buffer (Printf.sprintf "质量评估: %s\n\n" analysis.quality_assessment);
  
  Buffer.add_string buffer "韵律模式:\n";
  Buffer.add_string buffer (Printf.sprintf "模式: %s\n" analysis.overall_pattern.rhyme_pattern);
  Buffer.add_string buffer (Printf.sprintf "描述: %s\n\n" analysis.overall_pattern.pattern_description);
  
  if List.length analysis.parallelism_pairs > 0 then (
    Buffer.add_string buffer "对仗分析:\n";
    List.iter (fun parallel ->
      Buffer.add_string buffer (Printf.sprintf "对仗分数: %.2f\n" parallel.parallelism_score);
      Buffer.add_string buffer (Printf.sprintf "结构匹配: %b\n" parallel.structure_match);
      Buffer.add_string buffer (Printf.sprintf "声调对比: %b\n\n" parallel.tonal_contrast);
    ) analysis.parallelism_pairs
  );
  
  let issues = diagnose_rhyme_issues analysis in
  if List.length issues > 0 then (
    Buffer.add_string buffer "发现问题:\n";
    List.iter (fun issue ->
      Buffer.add_string buffer (Printf.sprintf "- %s\n" issue)
    ) issues;
    Buffer.add_string buffer "\n"
  );
  
  let suggestions = generate_improvement_suggestions analysis in
  if List.length suggestions > 0 then (
    Buffer.add_string buffer "改进建议:\n";
    List.iter (fun suggestion ->
      Buffer.add_string buffer (Printf.sprintf "- %s\n" suggestion)
    ) suggestions
  );
  
  Buffer.contents buffer

(** {8 向后兼容接口} *)

(** 兼容旧版本的分析接口 *)
let rhyme_check_verse = analyze_verse_pattern
let parallelism_check = analyze_parallelism  
let comprehensive_analysis = analyze_poem_comprehensive