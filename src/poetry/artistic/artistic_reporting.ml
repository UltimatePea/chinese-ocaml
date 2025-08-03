(** 结果格式化和报告生成模块
 *
 * 提供多种格式的评估结果输出，包括文本、JSON、HTML等格式。
 * 此模块整合了结果展示和报告生成相关功能。
 *
 * @author Whisky, PR Worker - 诗词艺术评估模块整合实施
 * @version 1.0 - 模块整合版本
 * @since 2025-08-03
 * @fix_issue #2000 Poetry艺术评估模块整合实施
 *)

open Artistic_engine_unified

(** {1 报告格式类型} *)

(** 输出格式枚举 *)
type output_format = 
  | PlainText
  | JSON
  | HTML
  | Markdown
  | CSV
  | XML

(** 报告详细程度 *)
type detail_level =
  | Summary      (* 摘要 *)
  | Standard     (* 标准 *)
  | Detailed     (* 详细 *)
  | Comprehensive (* 全面 *)

(** 报告配置 *)
type report_config = {
  format : output_format;
  detail_level : detail_level;
  include_metadata : bool;
  include_recommendations : bool;
  chinese_output : bool;
  custom_template : string option;
}

(** {1 基础格式化函数} *)

(** 维度名称中文化 *)
let dimension_to_chinese (dim : evaluation_dimension) : string =
  match dim with
  | RhymeHarmony -> "韵律和谐"
  | TonalBalance -> "声调平衡"
  | MetricalForm -> "格律形式"
  | Parallelism -> "对仗工整"
  | Imagery -> "意象深度"
  | Rhythm -> "节奏感"
  | Elegance -> "典雅性"
  | ContentDepth -> "内容深度"
  | FormBeauty -> "形式美感"
  | SoundHarmony -> "声音和谐"
  | ContextMood -> "意境营造"
  | EmotionExpression -> "情感表达"
  | Innovation -> "创新性"
  | Overall -> "整体评价"

(** 分数等级化 *)
let score_to_grade (score : float) : string * string =
  if score >= 0.9 then ("优秀", "A")
  else if score >= 0.8 then ("良好", "B")
  else if score >= 0.7 then ("中等", "C")
  else if score >= 0.6 then ("及格", "D")
  else ("需要改进", "F")

(** 分数颜色映射（用于HTML输出） *)
let score_to_color (score : float) : string =
  if score >= 0.8 then "#28a745"      (* 绿色 *)
  else if score >= 0.6 then "#ffc107" (* 黄色 *)
  else "#dc3545"                       (* 红色 *)

(** {1 纯文本格式化} *)

module PlainTextFormatter = struct
  (** 格式化单个维度分数 *)
  let format_dimension_score (dim_score : dimension_score) : string =
    let (_grade_text, grade_letter) = score_to_grade dim_score.score in
    let dim_name = dimension_to_chinese dim_score.dimension in
    Printf.sprintf "  %s: %.2f (%s) - %s" 
      dim_name dim_score.score grade_letter dim_score.details

  (** 格式化完整评估结果 *)
  let format_evaluation_result (result : evaluation_result) (config : report_config) : string =
    let buffer = Buffer.create 1024 in
    
    Buffer.add_string buffer "=== 诗词艺术评估报告 ===\n\n";
    
    (* 总体评分 *)
    let (overall_grade, overall_letter) = score_to_grade result.overall_score in
    Buffer.add_string buffer (Printf.sprintf "总体评分: %.2f (%s) - %s\n" 
      result.overall_score overall_letter overall_grade);
    Buffer.add_string buffer (Printf.sprintf "加权评分: %.2f\n" result.weighted_score);
    Buffer.add_string buffer "\n";
    
    (* 各维度详细评分 *)
    Buffer.add_string buffer "各维度评分:\n";
    List.iter (fun dim_score ->
      Buffer.add_string buffer (format_dimension_score dim_score ^ "\n")
    ) result.dimension_scores;
    
    (* 元数据信息 *)
    if config.include_metadata then (
      Buffer.add_string buffer "\n评估信息:\n";
      Buffer.add_string buffer (Printf.sprintf "  评估耗时: %.4f 秒\n" result.evaluation_time);
      List.iter (fun (key, value) ->
        Buffer.add_string buffer (Printf.sprintf "  %s: %s\n" key value)
      ) result.metadata;
    );
    
    Buffer.contents buffer

  (** 格式化比较报告 *)
  let format_comparison_report (results : (string * evaluation_result) list) : string =
    let buffer = Buffer.create 2048 in
    
    Buffer.add_string buffer "=== 诗词评估比较报告 ===\n\n";
    
    (* 按总分排序 *)
    let sorted_results = List.sort (fun (_, r1) (_, r2) -> 
      compare r2.overall_score r1.overall_score
    ) results in
    
    Buffer.add_string buffer "排名\t诗句\t总分\t等级\n";
    Buffer.add_string buffer "----\t----\t----\t----\n";
    
    List.iteri (fun i (verse, result) ->
      let (_grade, letter) = score_to_grade result.overall_score in
      Buffer.add_string buffer (Printf.sprintf "%d\t%s\t%.2f\t%s\n" 
        (i+1) (String.sub verse 0 (min 10 (String.length verse))) result.overall_score letter)
    ) sorted_results;
    
    Buffer.contents buffer
end

(** {1 JSON格式化} *)

module JsonFormatter = struct
  (** 转义JSON字符串 *)
  let escape_json_string (s : string) : string =
    let buffer = Buffer.create (String.length s * 2) in
    String.iter (function
      | '"' -> Buffer.add_string buffer "\\\""
      | '\\' -> Buffer.add_string buffer "\\\\"
      | '\n' -> Buffer.add_string buffer "\\n"
      | '\r' -> Buffer.add_string buffer "\\r"
      | '\t' -> Buffer.add_string buffer "\\t"
      | c -> Buffer.add_char buffer c
    ) s;
    Buffer.contents buffer

  (** 格式化维度分数为JSON *)
  let dimension_score_to_json (dim_score : dimension_score) : string =
    let dim_name = dimension_to_chinese dim_score.dimension in
    Printf.sprintf "{\"dimension\":\"%s\",\"score\":%.3f,\"confidence\":%.3f,\"details\":\"%s\"}"
      (escape_json_string dim_name) dim_score.score dim_score.confidence (escape_json_string dim_score.details)

  (** 格式化评估结果为JSON *)
  let format_evaluation_result (result : evaluation_result) : string =
    let dimension_scores_json = String.concat "," 
      (List.map dimension_score_to_json result.dimension_scores) in
    
    let metadata_json = String.concat "," (List.map (fun (k, v) ->
      Printf.sprintf "\"%s\":\"%s\"" (escape_json_string k) (escape_json_string v)
    ) result.metadata) in
    
    Printf.sprintf "{\"overall_score\":%.3f,\"weighted_score\":%.3f,\"evaluation_time\":%.4f,\"dimension_scores\":[%s],\"metadata\":{%s}}"
      result.overall_score result.weighted_score result.evaluation_time dimension_scores_json metadata_json

  (** 格式化批量结果为JSON数组 *)
  let format_batch_results (results : (string * evaluation_result) list) : string =
    let results_json = String.concat "," (List.map (fun (verse, result) ->
      Printf.sprintf "{\"verse\":\"%s\",\"evaluation\":%s}" 
        (escape_json_string verse) (format_evaluation_result result)
    ) results) in
    Printf.sprintf "[%s]" results_json
end

(** {1 HTML格式化} *)

module HtmlFormatter = struct
  (** HTML模板头部 *)
  let html_header = {|
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>诗词艺术评估报告</title>
    <style>
        body { font-family: 'Microsoft YaHei', Arial, sans-serif; margin: 20px; }
        .report-header { background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
        .score-summary { display: flex; gap: 20px; margin: 20px 0; }
        .score-card { background: white; padding: 15px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); flex: 1; }
        .dimension-scores { margin: 20px 0; }
        .dimension-row { display: flex; align-items: center; margin: 10px 0; }
        .dimension-name { width: 120px; font-weight: bold; }
        .score-bar { flex: 1; height: 20px; background: #e9ecef; border-radius: 10px; margin: 0 10px; position: relative; }
        .score-fill { height: 100%; border-radius: 10px; }
        .score-text { width: 60px; text-align: right; font-weight: bold; }
        .metadata { background: #f8f9fa; padding: 15px; border-radius: 8px; margin-top: 20px; }
    </style>
</head>
<body>
|}

  let html_footer = {|
</body>
</html>
|}

  (** 格式化维度分数为HTML *)
  let format_dimension_score_html (dim_score : dimension_score) : string =
    let dim_name = dimension_to_chinese dim_score.dimension in
    let color = score_to_color dim_score.score in
    let percentage = int_of_float (dim_score.score *. 100.0) in
    
    Printf.sprintf {|
        <div class="dimension-row">
            <div class="dimension-name">%s</div>
            <div class="score-bar">
                <div class="score-fill" style="width: %d%%; background-color: %s;"></div>
            </div>
            <div class="score-text">%.2f</div>
        </div>
    |} dim_name percentage color dim_score.score

  (** 格式化评估结果为HTML *)
  let format_evaluation_result (result : evaluation_result) (config : report_config) : string =
    let buffer = Buffer.create 2048 in
    
    Buffer.add_string buffer html_header;
    
    (* 报告头部 *)
    Buffer.add_string buffer {|
    <div class="report-header">
        <h1>诗词艺术评估报告</h1>
    </div>
    |};
    
    (* 分数摘要 *)
    let (overall_grade, _) = score_to_grade result.overall_score in
    let overall_color = score_to_color result.overall_score in
    Buffer.add_string buffer (Printf.sprintf {|
    <div class="score-summary">
        <div class="score-card">
            <h3>总体评分</h3>
            <div style="font-size: 2em; color: %s; font-weight: bold;">%.2f</div>
            <div>%s</div>
        </div>
        <div class="score-card">
            <h3>加权评分</h3>
            <div style="font-size: 2em; color: %s; font-weight: bold;">%.2f</div>
        </div>
    </div>
    |} overall_color result.overall_score overall_grade overall_color result.weighted_score);
    
    (* 各维度评分 *)
    Buffer.add_string buffer {|
    <div class="dimension-scores">
        <h3>各维度评分</h3>
    |};
    
    List.iter (fun dim_score ->
      Buffer.add_string buffer (format_dimension_score_html dim_score)
    ) result.dimension_scores;
    
    Buffer.add_string buffer "</div>";
    
    (* 元数据 *)
    if config.include_metadata then (
      Buffer.add_string buffer {|
      <div class="metadata">
          <h3>评估信息</h3>
      |};
      Buffer.add_string buffer (Printf.sprintf "<p>评估耗时: %.4f 秒</p>" result.evaluation_time);
      List.iter (fun (key, value) ->
        Buffer.add_string buffer (Printf.sprintf "<p>%s: %s</p>" key value)
      ) result.metadata;
      Buffer.add_string buffer "</div>";
    );
    
    Buffer.add_string buffer html_footer;
    Buffer.contents buffer
end

(** {1 Markdown格式化} *)

module MarkdownFormatter = struct
  (** 格式化评估结果为Markdown *)
  let format_evaluation_result (result : evaluation_result) (config : report_config) : string =
    let buffer = Buffer.create 1024 in
    
    Buffer.add_string buffer "# 诗词艺术评估报告\n\n";
    
    (* 总体评分 *)
    let (overall_grade, _) = score_to_grade result.overall_score in
    Buffer.add_string buffer "## 评分摘要\n\n";
    Buffer.add_string buffer (Printf.sprintf "- **总体评分**: %.2f (%s)\n" result.overall_score overall_grade);
    Buffer.add_string buffer (Printf.sprintf "- **加权评分**: %.2f\n\n" result.weighted_score);
    
    (* 各维度评分 *)
    Buffer.add_string buffer "## 各维度评分\n\n";
    Buffer.add_string buffer "| 维度 | 分数 | 等级 | 说明 |\n";
    Buffer.add_string buffer "|------|------|------|------|\n";
    
    List.iter (fun dim_score ->
      let dim_name = dimension_to_chinese dim_score.dimension in
      let (_, grade_letter) = score_to_grade dim_score.score in
      Buffer.add_string buffer (Printf.sprintf "| %s | %.2f | %s | %s |\n"
        dim_name dim_score.score grade_letter dim_score.details)
    ) result.dimension_scores;
    
    Buffer.add_string buffer "\n";
    
    (* 元数据 *)
    if config.include_metadata then (
      Buffer.add_string buffer "## 评估信息\n\n";
      Buffer.add_string buffer (Printf.sprintf "- 评估耗时: %.4f 秒\n" result.evaluation_time);
      List.iter (fun (key, value) ->
        Buffer.add_string buffer (Printf.sprintf "- %s: %s\n" key value)
      ) result.metadata;
    );
    
    Buffer.contents buffer
end

(** {1 CSV格式化} *)

module CsvFormatter = struct
  (** 格式化评估结果为CSV *)
  let format_evaluation_result (result : evaluation_result) : string =
    let buffer = Buffer.create 512 in
    
    (* CSV头部 *)
    Buffer.add_string buffer "维度,分数,置信度,详情\n";
    
    (* 各维度数据 *)
    List.iter (fun dim_score ->
      let dim_name = dimension_to_chinese dim_score.dimension in
      Buffer.add_string buffer (Printf.sprintf "\"%s\",%.3f,%.3f,\"%s\"\n"
        dim_name dim_score.score dim_score.confidence dim_score.details)
    ) result.dimension_scores;
    
    (* 总体评分 *)
    Buffer.add_string buffer (Printf.sprintf "\"总体评分\",%.3f,1.0,\"整体评价结果\"\n" result.overall_score);
    
    Buffer.contents buffer

  (** 格式化批量结果为CSV *)
  let format_batch_results (results : (string * evaluation_result) list) : string =
    let buffer = Buffer.create 2048 in
    
    (* CSV头部 *)
    Buffer.add_string buffer "诗句,总体评分,韵律和谐,声调平衡,对仗工整,意象深度,形式美感\n";
    
    (* 数据行 *)
    List.iter (fun (verse, result) ->
      let scores = List.map (fun dim ->
        match List.find_opt (fun ds -> ds.dimension = dim) result.dimension_scores with
        | Some ds -> Printf.sprintf "%.3f" ds.score
        | None -> "0.000"
      ) [RhymeHarmony; TonalBalance; Parallelism; Imagery; FormBeauty] in
      
      Buffer.add_string buffer (Printf.sprintf "\"%s\",%.3f,%s\n" 
        verse result.overall_score (String.concat "," scores))
    ) results;
    
    Buffer.contents buffer
end

(** {1 统一报告生成接口} *)

(** 默认报告配置 *)
let default_report_config = {
  format = PlainText;
  detail_level = Standard;
  include_metadata = true;
  include_recommendations = false;
  chinese_output = true;
  custom_template = None;
}

(** 生成评估报告 *)
let generate_report (result : evaluation_result) ?(config = default_report_config) () : string =
  match config.format with
  | PlainText -> PlainTextFormatter.format_evaluation_result result config
  | JSON -> JsonFormatter.format_evaluation_result result
  | HTML -> HtmlFormatter.format_evaluation_result result config
  | Markdown -> MarkdownFormatter.format_evaluation_result result config
  | CSV -> CsvFormatter.format_evaluation_result result
  | XML -> "XML format not implemented yet"

(** 生成批量评估报告 *)
let generate_batch_report (results : (string * evaluation_result) list) ?(config = default_report_config) () : string =
  match config.format with
  | PlainText -> PlainTextFormatter.format_comparison_report results
  | JSON -> JsonFormatter.format_batch_results results
  | CSV -> CsvFormatter.format_batch_results results
  | _ -> "Batch report for this format not implemented yet"

(** 生成性能报告 *)
let generate_performance_report (results : evaluation_result list) : string =
  let total_time = List.fold_left (fun acc r -> acc +. r.evaluation_time) 0.0 results in
  let avg_time = total_time /. float_of_int (List.length results) in
  let throughput = if avg_time > 0.0 then 1.0 /. avg_time else 0.0 in
  
  Printf.sprintf "性能报告:\n总评估数: %d\n总耗时: %.4f 秒\n平均耗时: %.4f 秒\n吞吐量: %.2f 次/秒"
    (List.length results) total_time avg_time throughput

(** 保存报告到文件 *)
let save_report_to_file (content : string) (filename : string) : bool =
  try
    let oc = open_out filename in
    output_string oc content;
    close_out oc;
    true
  with
  | _ -> false

(** 获取推荐建议 *)
let generate_recommendations (result : evaluation_result) : string list =
  let recommendations = ref [] in
  
  List.iter (fun dim_score ->
    if dim_score.score < 0.6 then
      let dim_name = dimension_to_chinese dim_score.dimension in
      let suggestion = match dim_score.dimension with
        | RhymeHarmony -> "建议注意韵脚的选择和音韵的和谐性"
        | TonalBalance -> "建议检查平仄的搭配，确保声调的协调"
        | Parallelism -> "建议加强对仗的工整性，注意词性的对应"
        | Imagery -> "建议丰富意象的运用，增加诗句的层次感"
        | FormBeauty -> "建议注意诗句的结构和形式美感"
        | _ -> "建议进一步完善这个维度"
      in
      recommendations := (dim_name ^ ": " ^ suggestion) :: !recommendations
  ) result.dimension_scores;
  
  List.rev !recommendations