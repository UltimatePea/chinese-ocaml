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

(** {1 报告类型定义} *)

(** 报告格式类型 *)
type report_format = 
  | TextReport      (** 纯文本报告 *)
  | HtmlReport      (** HTML格式报告 *)
  | JsonReport      (** JSON格式报告 *)
  | XmlReport       (** XML格式报告 *)
  | MarkdownReport  (** Markdown格式报告 *)

(** 报告详细程度 *)
type report_detail_level = 
  | Brief           (** 简要报告 *)
  | Standard        (** 标准报告 *)
  | Detailed        (** 详细报告 *)
  | Comprehensive   (** 全面报告 *)

(** 报告配置 *)
type report_config = {
  format : report_format;                     (** 报告格式 *)
  detail_level : report_detail_level;         (** 详细程度 *)
  include_charts : bool;                      (** 是否包含图表 *)
  include_metadata : bool;                    (** 是否包含元数据 *)
  custom_sections : string list;             (** 自定义章节 *)
  template_name : string option;             (** 模板名称 *)
}

(** 报告章节 *)
type report_section = {
  title : string;                (** 章节标题 *)
  content : string;              (** 章节内容 *)
  subsections : report_section list; (** 子章节 *)
  metadata : (string * string) list; (** 章节元数据 *)
}

(** 完整报告 *)
type complete_report = {
  title : string;                    (** 报告标题 *)
  summary : string;                  (** 报告摘要 *)
  sections : report_section list;    (** 报告章节 *)
  generated_at : float;              (** 生成时间 *)
  config : report_config;            (** 生成配置 *)
  statistics : (string * string) list; (** 统计信息 *)
}

(** {1 全局状态管理} *)

(** 报告模板存储 *)
let report_templates = ref []

(** 报告样式存储 *)
let report_styles = ref []

(** 报告配置存储 *)
let saved_configs = ref []

(** {1 辅助函数} *)


(** {1 报告格式化} *)

(** 格式化维度评分显示 *)
let format_dimension_score score =
  let dimension_name = match score.dimension with
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
    if ReportConfig.include_confidence_scores 
    then Printf.sprintf " (置信度: %.2f)" score.confidence
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



(** {1 报告输出格式} *)

(** 生成文本格式报告 *)
let generate_text_report evaluation =
  let buffer = Buffer.create 1024 in
  
  Buffer.add_string buffer "=== 诗词艺术评价报告 ===\n\n";
  Buffer.add_string buffer (Printf.sprintf "综合评分: %.2f\n" evaluation.overall_score);
  Buffer.add_string buffer (Printf.sprintf "艺术水平: %s\n" (format_artistic_level evaluation.artistic_level));
  Buffer.add_string buffer (Printf.sprintf "质量等级: %s\n\n" (format_quality_grade evaluation.quality_grade));
  
  Buffer.add_string buffer "维度评分详情:\n";
  List.iter (fun score ->
    Buffer.add_string buffer ("  " ^ format_dimension_score score ^ "\n")
  ) evaluation.dimension_scores;
  
  if List.length evaluation.strengths > 0 then (
    Buffer.add_string buffer "\n优势特点:\n";
    List.iter (fun strength ->
      Buffer.add_string buffer ("  + " ^ strength ^ "\n")
    ) evaluation.strengths
  );
  
  if List.length evaluation.weaknesses > 0 then (
    Buffer.add_string buffer "\n需要改进:\n";
    List.iter (fun weakness ->
      Buffer.add_string buffer ("  - " ^ weakness ^ "\n")
    ) evaluation.weaknesses
  );
  
  if List.length evaluation.improvement_suggestions > 0 then (
    Buffer.add_string buffer "\n改进建议:\n";
    List.iter (fun suggestion ->
      Buffer.add_string buffer ("  → " ^ suggestion ^ "\n")
    ) evaluation.improvement_suggestions
  );
  
  Buffer.contents buffer

(** 生成简洁摘要报告 *)
let generate_summary_report evaluation =
  Printf.sprintf "评分: %.2f | 水平: %s | 等级: %s | 优势: %s" 
    evaluation.overall_score
    (format_artistic_level evaluation.artistic_level)
    (format_quality_grade evaluation.quality_grade)
    (String.concat "、" (list_take 2 evaluation.strengths))

(** {1 基础报告生成} *)

(** 生成评估报告 *)
let generate_evaluation_report evaluation config =
  let summary = generate_summary_report evaluation in
  let main_section = {
    title = "评估详情";
    content = generate_text_report evaluation;
    subsections = [];
    metadata = [];
  } in
  {
    title = "诗词艺术评估报告";
    summary;
    sections = [main_section];
    generated_at = Unix.time ();
    config;
    statistics = [("dimension_count", string_of_int (List.length evaluation.dimension_scores))];
  }

(** 生成简要摘要 *)
let generate_brief_summary evaluation =
  generate_summary_report evaluation

(** 生成详细分析 *)
let generate_detailed_analysis evaluation =
  let default_config = {
    format = TextReport;
    detail_level = Detailed;
    include_charts = false;
    include_metadata = true;
    custom_sections = [];
    template_name = None;
  } in
  generate_evaluation_report evaluation default_config

(** {1 格式化输出} *)

(** 格式化为文本 *)
let format_as_text (report : complete_report) =
  let buffer = Buffer.create 1024 in
  Buffer.add_string buffer ("=== " ^ report.title ^ " ===\n\n");
  Buffer.add_string buffer (report.summary ^ "\n\n");
  List.iter (fun (sect : report_section) ->
    Buffer.add_string buffer (sect.title ^ ":\n");
    Buffer.add_string buffer (sect.content ^ "\n\n");
  ) report.sections;
  Buffer.contents buffer

(** 格式化为HTML *)
let format_as_html report =
  let buffer = Buffer.create 2048 in
  Buffer.add_string buffer "<!DOCTYPE html>\n<html>\n<head>\n";
  Buffer.add_string buffer ("<title>" ^ report.title ^ "</title>\n");
  Buffer.add_string buffer "</head>\n<body>\n";
  Buffer.add_string buffer ("<h1>" ^ report.title ^ "</h1>\n");
  Buffer.add_string buffer ("<p>" ^ report.summary ^ "</p>\n");
  List.iter (fun (section : report_section) ->
    Buffer.add_string buffer ("<h2>" ^ section.title ^ "</h2>\n");
    Buffer.add_string buffer ("<div>" ^ section.content ^ "</div>\n");
  ) report.sections;
  Buffer.add_string buffer "</body>\n</html>\n";
  Buffer.contents buffer

(** 格式化为JSON *)
let format_as_json report =
  let escape_json s = 
    let s = Str.global_replace (Str.regexp "\"") "\\\"" s in
    let s = Str.global_replace (Str.regexp "\n") "\\n" s in
    s
  in
  let buffer = Buffer.create 2048 in
  Buffer.add_string buffer "{\n";
  Buffer.add_string buffer ("  \"title\": \"" ^ escape_json report.title ^ "\",\n");
  Buffer.add_string buffer ("  \"summary\": \"" ^ escape_json report.summary ^ "\",\n");
  Buffer.add_string buffer "  \"sections\": [\n";
  let section_strings = List.map (fun (section : report_section) ->
    "    {\n" ^
    "      \"title\": \"" ^ escape_json section.title ^ "\",\n" ^
    "      \"content\": \"" ^ escape_json section.content ^ "\"\n" ^
    "    }"
  ) report.sections in
  Buffer.add_string buffer (String.concat ",\n" section_strings);
  Buffer.add_string buffer "\n  ],\n";
  Buffer.add_string buffer ("  \"generated_at\": " ^ string_of_float report.generated_at ^ "\n");
  Buffer.add_string buffer "}\n";
  Buffer.contents buffer

(** 格式化为Markdown *)
let format_as_markdown report =
  let buffer = Buffer.create 1024 in
  Buffer.add_string buffer ("# " ^ report.title ^ "\n\n");
  Buffer.add_string buffer (report.summary ^ "\n\n");
  List.iter (fun (section : report_section) ->
    Buffer.add_string buffer ("## " ^ section.title ^ "\n\n");
    Buffer.add_string buffer (section.content ^ "\n\n");
  ) report.sections;
  Buffer.contents buffer

(** {1 专门报告类型} *)

(** 生成维度分析报告 *)
let generate_dimension_analysis_report dimension_scores config =
  let sections = List.map (fun score ->
    {
      title = format_dimension_score score;
      content = String.concat "; " score.suggestions;
      subsections = [];
      metadata = [];
    }
  ) dimension_scores in
  {
    title = "维度分析报告";
    summary = Printf.sprintf "分析了%d个评价维度" (List.length dimension_scores);
    sections;
    generated_at = Unix.time ();
    config;
    statistics = [("dimension_count", string_of_int (List.length dimension_scores))];
  }

(** 生成比较报告 *)
let generate_comparison_report evaluations config =
  let comparison_content = String.concat "\n" (List.mapi (fun i eval ->
    Printf.sprintf "评价%d: 总分%.2f, 水平%s" (i+1) eval.overall_score 
      (format_artistic_level eval.artistic_level)
  ) evaluations) in
  let main_section = {
    title = "比较分析";
    content = comparison_content;
    subsections = [];
    metadata = [];
  } in
  {
    title = "比较分析报告";
    summary = Printf.sprintf "比较了%d个评价结果" (List.length evaluations);
    sections = [main_section];
    generated_at = Unix.time ();
    config;
    statistics = [("evaluation_count", string_of_int (List.length evaluations))];
  }

(** 生成趋势报告 *)
let generate_trend_report historical_data config =
  let trend_content = String.concat "\n" (List.map (fun (time, eval) ->
    Printf.sprintf "时间%.0f: 评分%.2f" time eval.overall_score
  ) historical_data) in
  let main_section = {
    title = "趋势分析";
    content = trend_content;
    subsections = [];
    metadata = [];
  } in
  {
    title = "趋势分析报告";
    summary = Printf.sprintf "分析了%d个时间点的数据" (List.length historical_data);
    sections = [main_section];
    generated_at = Unix.time ();
    config;
    statistics = [("data_points", string_of_int (List.length historical_data))];
  }

(** {1 模板管理} *)

(** 注册报告模板 *)
let register_report_template template_name template_content =
  report_templates := (template_name, template_content) :: !report_templates

(** 获取报告模板 *)
let get_report_template template_name =
  try
    Some (List.assoc template_name !report_templates)
  with Not_found -> None

(** 应用模板 *)
let apply_report_template template_name data =
  match get_report_template template_name with
  | None -> "Template not found"
  | Some template ->
      List.fold_left (fun acc (key, value) ->
        let pattern = "{" ^ key ^ "}" in
        Str.global_replace (Str.regexp_string pattern) value acc
      ) template data

(** 列出可用模板 *)
let list_available_templates () =
  List.map fst !report_templates

(** {1 图表与可视化} *)

(** 生成评分雷达图数据 *)
let generate_radar_chart_data dimension_scores =
  List.map (fun score ->
    let dimension_name = match score.dimension with
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
    (dimension_name, score.score)
  ) dimension_scores

(** 生成趋势图数据 *)
let generate_trend_chart_data historical_scores =
  List.mapi (fun i (_time, score) ->
    (Printf.sprintf "时间点%d" i, score)
  ) historical_scores

(** 生成分布图数据 *)
let generate_distribution_chart_data scores =
  (* 简化实现：按分数区间统计 *)
  let count_in_range min_score max_score =
    List.length (List.filter (fun score -> score >= min_score && score < max_score) scores)
  in
  [
    ("0-0.2", count_in_range 0.0 0.2);
    ("0.2-0.4", count_in_range 0.2 0.4);
    ("0.4-0.6", count_in_range 0.4 0.6);
    ("0.6-0.8", count_in_range 0.6 0.8);
    ("0.8-1.0", count_in_range 0.8 1.0);
  ]

(** {1 批量报告处理} *)

(** 批量生成报告 *)
let batch_generate_reports evaluations config =
  List.map (fun eval -> generate_evaluation_report eval config) evaluations

(** 合并多个报告 *)
let merge_reports reports merge_config =
  let all_sections = List.flatten (List.map (fun report -> report.sections) reports) in
  {
    title = "合并报告";
    summary = Printf.sprintf "合并了%d个独立报告" (List.length reports);
    sections = all_sections;
    generated_at = Unix.time ();
    config = merge_config;
    statistics = [("merged_reports", string_of_int (List.length reports))];
  }

(** {1 报告统计与分析} *)

(** 分析报告质量 *)
let analyze_report_quality report =
  let section_count = List.length report.sections in
  let avg_content_length = 
    if section_count > 0 then
      let total_length = List.fold_left (fun acc section -> 
        acc + String.length section.content
      ) 0 report.sections in
      float_of_int total_length /. float_of_int section_count
    else 0.0
  in
  [
    ("completeness", if section_count > 0 then 1.0 else 0.0);
    ("detail_level", avg_content_length /. 100.0);
    ("structure_quality", if String.length report.summary > 10 then 0.8 else 0.4);
  ]

(** 计算报告统计信息 *)
let calculate_report_statistics report =
  let section_count = List.length report.sections in
  let total_content_length = List.fold_left (fun acc section ->
    acc + String.length section.content
  ) 0 report.sections in
  [
    ("章节数量", string_of_int section_count);
    ("总内容长度", string_of_int total_content_length);
    ("摘要长度", string_of_int (String.length report.summary));
    ("生成时间", string_of_float report.generated_at);
  ]

(** {1 导出与保存} *)

(** 导出报告到文件 *)
let export_report_to_file report filename format =
  try
    let content = match format with
      | TextReport -> format_as_text report
      | HtmlReport -> format_as_html report
      | JsonReport -> format_as_json report
      | MarkdownReport -> format_as_markdown report
      | XmlReport -> format_as_text report  (* 简化：使用文本格式 *)
    in
    let oc = open_out filename in
    output_string oc content;
    close_out oc;
    true
  with _ -> false

(** 保存报告配置 *)
let save_report_config config config_name =
  saved_configs := (config_name, config) :: !saved_configs

(** 加载报告配置 *)
let load_report_config config_name =
  try
    Some (List.assoc config_name !saved_configs)
  with Not_found -> None

(** {1 报告样式管理} *)

(** 设置报告样式 *)
let set_report_style style_name style_config =
  report_styles := (style_name, style_config) :: !report_styles

(** 获取报告样式 *)
let get_report_style style_name =
  try
    Some (List.assoc style_name !report_styles)
  with Not_found -> None

(** 应用报告样式 *)
let apply_report_style report style_name =
  match get_report_style style_name with
  | None -> report  (* 如果样式不存在，返回原始报告 *)
  | Some style_config ->
      (* 简化实现：仅更新标题样式 *)
      let styled_title = 
        match List.assoc_opt "title_prefix" style_config with
        | Some prefix -> prefix ^ report.title
        | None -> report.title
      in
      { report with title = styled_title }