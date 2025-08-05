(** 诗词艺术评估报告模块 - Phase 1-C 模块化重构
 *
 * 此模块包含报告生成、格式化和输出功能
 * 从 artistic_evaluators.ml 中提取的报告相关功能
 *
 * @author Whisky, PR Worker - Phase 1-C 模块化重构
 * @refactors Issue #2171 - Phase 1-C 代码重构现代化
 *)

open Artistic_core
open Artistic_config

(** {1 反馈生成函数} *)

(** 生成韵律评价反馈 *)
let generate_rhyme_feedback rhyme_score rhyme_chars rhyme_diversity =
  let rhyme_details =
    Printf.sprintf "韵脚字符: [%s], 韵律多样性: %.1f%%" (String.concat "; " rhyme_chars)
      (rhyme_diversity *. 100.0)
  in
  let suggestions, details =
    if rhyme_score >= 0.7 then ([ "韵律安排良好，音韵和谐自然" ], Some rhyme_details)
    else if rhyme_score >= 0.5 then ([ "韵律基本合理，可进一步优化押韵效果" ], Some (rhyme_details ^ "，建议适度调整"))
    else ([ "建议改善韵脚安排，增强音韵协调性" ], Some (rhyme_details ^ "，韵律需要优化"))
  in
  (suggestions, details)

(** 生成形式美反馈 *)
let generate_form_beauty_feedback verse_count avg_length structural_score =
  let base_feedback = Printf.sprintf "基于%d行诗句的形式美分析，平均行长%d字" verse_count avg_length in
  let suggestions =
    if structural_score >= 0.9 then [ base_feedback ^ "，形式结构优美" ]
    else if structural_score >= 0.7 then [ base_feedback ^ "，形式较为协调" ]
    else [ base_feedback ^ "，建议调整诗句结构以增强形式美感" ]
  in
  (suggestions, Some "形式美评价基于诗歌结构和布局协调性")

(** 生成对仗评价反馈 *)
let generate_parallelism_feedback left_verse right_verse score =
  let suggestions =
    if score >= 0.8 then [ Printf.sprintf "对仗工整，「%s」与「%s」相对和谐" left_verse right_verse ]
    else if score >= 0.6 then [ Printf.sprintf "对仗基本合理，可进一步优化「%s」与「%s」的对称性" left_verse right_verse ]
    else [ Printf.sprintf "建议改善「%s」与「%s」的对仗关系" left_verse right_verse ]
  in
  let details = Some (Printf.sprintf "对仗分析: 评分%.2f，基于结构和长度对称性" score) in
  (suggestions, details)

(** 生成意象评价反馈 *)
let generate_imagery_feedback _verse found_keywords keyword_count =
  let keywords_str = String.concat "、" found_keywords in
  let suggestions =
    if keyword_count >= 3 then [ Printf.sprintf "意象丰富，包含「%s」等意象词汇，营造了良好的诗意氛围" keywords_str ]
    else if keyword_count >= 1 then [ Printf.sprintf "包含「%s」等意象，可适当增加更多意象词汇增强表现力" keywords_str ]
    else [ "建议增加具体的意象词汇，如山水、花鸟、季节等，以增强诗意表达" ]
  in
  let details = Some (Printf.sprintf "检测到%d个意象关键词: %s" keyword_count keywords_str) in
  (suggestions, details)

(** {1 综合报告生成} *)

(** 分析诗词优势 *)
let analyze_strengths dimension_scores =
  let high_scores = List.filter (fun score -> score.score >= 0.7) dimension_scores in
  let strength_descriptions =
    List.map
      (fun score ->
        match score.dimension with
        | RhymeHarmony -> "韵律和谐"
        | TonalBalance -> "声调平衡"
        | FormBeauty -> "形式优美"
        | Parallelism -> "对仗工整"
        | Imagery -> "意象丰富"
        | Rhythm -> "节奏流畅"
        | Elegance -> "雅致优雅"
        | ContentDepth -> "内容深刻"
        | _ -> "整体协调")
      high_scores
  in

  let limited_strengths =
    if List.length strength_descriptions > ReportConfig.max_strengths_count then
      list_take ReportConfig.max_strengths_count strength_descriptions
    else strength_descriptions
  in
  limited_strengths

(** 分析诗词弱点 *)
let analyze_weaknesses dimension_scores =
  let low_scores = List.filter (fun score -> score.score < 0.5) dimension_scores in
  let weakness_descriptions =
    List.map
      (fun score ->
        match score.dimension with
        | RhymeHarmony -> "韵律协调性有待提升"
        | TonalBalance -> "声调变化需要改善"
        | FormBeauty -> "诗歌形式结构需要调整"
        | Parallelism -> "对仗工整性需要加强"
        | Imagery -> "意象表达可以更加丰富"
        | Rhythm -> "节奏韵律需要优化"
        | Elegance -> "雅致程度可以提升"
        | ContentDepth -> "内容深度有待增强"
        | _ -> "整体协调性需要改善")
      low_scores
  in

  let limited_weaknesses =
    if List.length weakness_descriptions > ReportConfig.max_weaknesses_count then
      list_take ReportConfig.max_weaknesses_count weakness_descriptions
    else weakness_descriptions
  in
  limited_weaknesses

(** 生成综合改进建议 *)
let generate_improvement_suggestions dimension_scores context =
  let all_suggestions =
    List.fold_left (fun acc score -> acc @ score.suggestions) [] dimension_scores
  in

  (* 根据诗词形式添加特定建议 *)
  let form_specific_suggestions =
    match context.poem_type with
    | Some "五言绝句" | Some "七言绝句" -> [ "绝句应注重意境营造和韵律音响效果" ]
    | Some "五言律诗" | Some "七言律诗" -> [ "律诗应重视对仗工整和平仄协调" ]
    | Some "自由体诗" -> [ "自由体诗应突出意象创新和情感表达" ]
    | _ -> []
  in

  let combined_suggestions = all_suggestions @ form_specific_suggestions in
  let unique_suggestions =
    let rec remove_duplicates acc = function
      | [] -> List.rev acc
      | h :: t -> if List.mem h acc then remove_duplicates acc t else remove_duplicates (h :: acc) t
    in
    remove_duplicates [] combined_suggestions
  in

  if List.length unique_suggestions > ReportConfig.max_suggestions_count then
    list_take ReportConfig.max_suggestions_count unique_suggestions
  else unique_suggestions

(** {1 报告格式化} *)

(** 格式化维度评分显示 *)
let format_dimension_score score =
  let dimension_name =
    match score.dimension with
    | RhymeHarmony -> "韵律和谐"
    | TonalBalance -> "声调平衡"
    | FormBeauty -> "形式美感"
    | Parallelism -> "对仗工整"
    | Imagery -> "意象深度"
    | Rhythm -> "节奏韵律"
    | Elegance -> "雅致程度"
    | ContentDepth -> "内容深度"
    | _ -> "其他维度"
  in

  let score_text = Printf.sprintf "%.2f" score.score in
  let confidence_text =
    if ReportConfig.include_confidence_scores then Printf.sprintf " (置信度: %.2f)" score.confidence
    else ""
  in

  Printf.sprintf "%s: %s%s" dimension_name score_text confidence_text

(** 格式化质量等级显示 *)
let format_quality_grade = function
  | `Excellent -> "优秀"
  | `Good -> "良好"
  | `Fair -> "一般"
  | `Poor -> "较差"

(** 格式化艺术水平显示 *)
let format_artistic_level = function
  | `Master -> "大师级"
  | `Advanced -> "高级"
  | `Intermediate -> "中级"
  | `Beginner -> "初级"

(** {1 完整报告生成} *)

(** 创建评价元数据 *)
let create_evaluation_metadata context =
  let base_metadata =
    [
      ("evaluation_time", string_of_float (Unix.time ()));
      ("version", "Phase 1-C 模块化版本");
      ("verse_count", string_of_int (List.length context.verses));
    ]
  in

  let form_metadata =
    match context.poem_type with Some form -> [ ("detected_form", form) ] | None -> []
  in

  let context_metadata =
    match context.author with Some author -> [ ("author", author) ] | None -> []
  in

  base_metadata @ form_metadata @ context_metadata @ context.metadata

(** 生成完整艺术评价报告 *)
let generate_comprehensive_report dimension_scores context overall_score =
  let strengths = analyze_strengths dimension_scores in
  let weaknesses = analyze_weaknesses dimension_scores in
  let improvement_suggestions = generate_improvement_suggestions dimension_scores context in
  let artistic_level = Artistic_metrics_new.determine_artistic_level overall_score in
  let quality_grade =
    let scores =
      {
        Artistic_metrics_new.rhyme_harmony = 0.7;
        tonal_balance = 0.6;
        parallelism = 0.7;
        imagery = 0.8;
        rhythm = 0.7;
        elegance = 0.6;
      }
    in
    Artistic_metrics_new.determine_overall_grade scores
  in

  let evaluation_metadata =
    if ReportConfig.include_metadata then create_evaluation_metadata context else []
  in

  {
    overall_score;
    dimension_scores;
    strengths;
    weaknesses;
    improvement_suggestions;
    artistic_level;
    quality_grade;
    evaluation_metadata;
  }

(** {1 报告输出格式} *)

(** 生成文本格式报告 *)
let generate_text_report evaluation =
  let buffer = Buffer.create 1024 in

  Buffer.add_string buffer "=== 诗词艺术评价报告 ===\n\n";
  Buffer.add_string buffer (Printf.sprintf "综合评分: %.2f\n" evaluation.overall_score);
  Buffer.add_string buffer
    (Printf.sprintf "艺术水平: %s\n" (format_artistic_level evaluation.artistic_level));
  Buffer.add_string buffer
    (Printf.sprintf "质量等级: %s\n\n" (format_quality_grade evaluation.quality_grade));

  Buffer.add_string buffer "维度评分详情:\n";
  List.iter
    (fun score -> Buffer.add_string buffer ("  " ^ format_dimension_score score ^ "\n"))
    evaluation.dimension_scores;

  if List.length evaluation.strengths > 0 then (
    Buffer.add_string buffer "\n优势特点:\n";
    List.iter
      (fun strength -> Buffer.add_string buffer ("  + " ^ strength ^ "\n"))
      evaluation.strengths);

  if List.length evaluation.weaknesses > 0 then (
    Buffer.add_string buffer "\n需要改进:\n";
    List.iter
      (fun weakness -> Buffer.add_string buffer ("  - " ^ weakness ^ "\n"))
      evaluation.weaknesses);

  if List.length evaluation.improvement_suggestions > 0 then (
    Buffer.add_string buffer "\n改进建议:\n";
    List.iter
      (fun suggestion -> Buffer.add_string buffer ("  → " ^ suggestion ^ "\n"))
      evaluation.improvement_suggestions);

  Buffer.contents buffer

(** 生成简洁摘要报告 *)
let generate_summary_report evaluation =
  Printf.sprintf "评分: %.2f | 水平: %s | 等级: %s | 优势: %s" evaluation.overall_score
    (format_artistic_level evaluation.artistic_level)
    (format_quality_grade evaluation.quality_grade)
    (String.concat "、" (list_take 2 evaluation.strengths))
