(** 诗词艺术评估报告生成模块 - Issue #2000 整合实施
 *
 * 此文件整合了从各个文件中提取的报告生成逻辑，
 * 提供统一的结果格式化功能和多种输出格式支持。
 *
 * 整合完成后，分散的报告生成逻辑将被统一管理。
 * @consolidation_issue #2000
 * @author Whisky, PR Worker
 *)

(** {1 报告类型定义} *)

type report_format =
  | PlainText    (** 纯文本格式 *)
  | Markdown     (** Markdown格式 *)
  | HTML         (** HTML格式 *)
  | JSON         (** JSON格式 *)
  | XML          (** XML格式 *)

type report_section =
  | Summary      (** 摘要部分 *)
  | Detailed     (** 详细分析 *)
  | Suggestions  (** 改进建议 *)
  | Metrics      (** 指标数据 *)
  | Comparison   (** 对比分析 *)

type report_data = {
  poem_text : string;
  overall_score : float;
  dimension_scores : (string * float) list;
  strengths : string list;
  weaknesses : string list;
  suggestions : string list;
  artistic_level : string;
  quality_grade : string;
  evaluation_time : float;
  metadata : (string * string) list;
}

(** {1 报告生成核心} *)

(** 生成基础评估报告 *)
let rec generate_basic_report data format =
  match format with
  | PlainText -> generate_plain_text_report data
  | Markdown -> generate_markdown_report data
  | HTML -> generate_html_report data
  | JSON -> generate_json_report data
  | XML -> generate_xml_report data

(** {1 纯文本格式报告} *)

and generate_plain_text_report data =
  let lines = [
    "诗词艺术性评估报告";
    "==================";
    "";
    "诗词内容:";
    data.poem_text;
    "";
    Printf.sprintf "整体评分: %.2f/1.00" data.overall_score;
    Printf.sprintf "艺术水平: %s" data.artistic_level;
    Printf.sprintf "质量等级: %s" data.quality_grade;
    "";
    "各维度评分:";
  ] @ (List.map (fun (dim, score) -> 
    Printf.sprintf "  %s: %.2f" dim score
  ) data.dimension_scores) @ [
    "";
    "优点:";
  ] @ (List.map (fun strength -> "  • " ^ strength) data.strengths) @ [
    "";
    "不足:";
  ] @ (List.map (fun weakness -> "  • " ^ weakness) data.weaknesses) @ [
    "";
    "改进建议:";
  ] @ (List.map (fun suggestion -> "  • " ^ suggestion) data.suggestions) @ [
    "";
    Printf.sprintf "评估耗时: %.3f秒" data.evaluation_time;
  ] in
  String.concat "\n" lines

(** {1 Markdown格式报告} *)

and generate_markdown_report data =
  let lines = [
    "# 诗词艺术性评估报告";
    "";
    "## 诗词内容";
    "";
    "```";
    data.poem_text;
    "```";
    "";
    "## 评估结果";
    "";
    Printf.sprintf "- **整体评分**: %.2f/1.00" data.overall_score;
    Printf.sprintf "- **艺术水平**: %s" data.artistic_level;
    Printf.sprintf "- **质量等级**: %s" data.quality_grade;
    "";
    "## 各维度评分";
    "";
  ] @ (List.map (fun (dim, score) -> 
    Printf.sprintf "- **%s**: %.2f" dim score
  ) data.dimension_scores) @ [
    "";
    "## 优点分析";
    "";
  ] @ (List.map (fun strength -> "- " ^ strength) data.strengths) @ [
    "";
    "## 不足分析";
    "";
  ] @ (List.map (fun weakness -> "- " ^ weakness) data.weaknesses) @ [
    "";
    "## 改进建议";
    "";
  ] @ (List.map (fun suggestion -> "- " ^ suggestion) data.suggestions) @ [
    "";
    "---";
    Printf.sprintf "*评估耗时: %.3f秒*" data.evaluation_time;
  ] in
  String.concat "\n" lines

(** {1 HTML格式报告} *)

and generate_html_report data =
  let style = {|
<style>
  .report { font-family: 'Microsoft YaHei', sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
  .poem { background: #f5f5f5; padding: 15px; border-left: 4px solid #007acc; margin: 10px 0; white-space: pre-line; }
  .score { font-size: 1.2em; font-weight: bold; color: #007acc; }
  .dimensions { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 10px; }
  .dimension { background: #f9f9f9; padding: 10px; border-radius: 5px; }
  .list-item { margin: 5px 0; }
  .footer { margin-top: 20px; padding-top: 10px; border-top: 1px solid #ddd; color: #666; }
</style>
|} in
  
  let html_content = Printf.sprintf {|
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <title>诗词艺术性评估报告</title>
  %s
</head>
<body>
  <div class="report">
    <h1>诗词艺术性评估报告</h1>
    
    <h2>诗词内容</h2>
    <div class="poem">%s</div>
    
    <h2>评估结果</h2>
    <div class="score">整体评分: %.2f/1.00</div>
    <p><strong>艺术水平</strong>: %s</p>
    <p><strong>质量等级</strong>: %s</p>
    
    <h2>各维度评分</h2>
    <div class="dimensions">
      %s
    </div>
    
    <h2>优点分析</h2>
    <ul>%s</ul>
    
    <h2>不足分析</h2>
    <ul>%s</ul>
    
    <h2>改进建议</h2>
    <ul>%s</ul>
    
    <div class="footer">
      评估耗时: %.3f秒
    </div>
  </div>
</body>
</html>
|} style data.poem_text data.overall_score data.artistic_level data.quality_grade
  (String.concat "\n" (List.map (fun (dim, score) ->
    Printf.sprintf {|<div class="dimension"><strong>%s</strong><br/>%.2f</div>|} dim score
  ) data.dimension_scores))
  (String.concat "\n" (List.map (fun s -> Printf.sprintf {|<li class="list-item">%s</li>|} s) data.strengths))
  (String.concat "\n" (List.map (fun w -> Printf.sprintf {|<li class="list-item">%s</li>|} w) data.weaknesses))
  (String.concat "\n" (List.map (fun s -> Printf.sprintf {|<li class="list-item">%s</li>|} s) data.suggestions))
  data.evaluation_time in
  
  html_content

(** {1 JSON格式报告} *)

and generate_json_report data =
  let escape_json_string s =
    let s = Str.global_replace (Str.regexp "\\\\") "\\\\" s in
    let s = Str.global_replace (Str.regexp "\"") "\\\"" s in
    let s = Str.global_replace (Str.regexp "\n") "\\n" s in
    s
  in
  
  let dimension_scores_json = String.concat ",\n    " (List.map (fun (dim, score) ->
    Printf.sprintf {|"%s": %.3f|} (escape_json_string dim) score
  ) data.dimension_scores) in
  
  let array_to_json arr = String.concat ",\n    " (List.map (fun s ->
    Printf.sprintf {|"%s"|} (escape_json_string s)
  ) arr) in
  
  let metadata_json = String.concat ",\n    " (List.map (fun (key, value) ->
    Printf.sprintf {|"%s": "%s"|} (escape_json_string key) (escape_json_string value)
  ) data.metadata) in
  
  Printf.sprintf {|{
  "report_type": "poetry_artistic_evaluation",
  "poem_text": "%s",
  "evaluation_results": {
    "overall_score": %.3f,
    "artistic_level": "%s",
    "quality_grade": "%s",
    "dimension_scores": {
      %s
    }
  },
  "analysis": {
    "strengths": [
      %s
    ],
    "weaknesses": [
      %s
    ],
    "suggestions": [
      %s
    ]
  },
  "metadata": {
    "evaluation_time": %.3f,
    %s
  },
  "generated_at": "%.0f"
}|} (escape_json_string data.poem_text) data.overall_score 
    (escape_json_string data.artistic_level) (escape_json_string data.quality_grade)
    dimension_scores_json
    (array_to_json data.strengths)
    (array_to_json data.weaknesses) 
    (array_to_json data.suggestions)
    data.evaluation_time metadata_json (Unix.time ())

(** {1 XML格式报告} *)

and generate_xml_report data =
  let escape_xml s =
    let s = Str.global_replace (Str.regexp "&") "&amp;" s in
    let s = Str.global_replace (Str.regexp "<") "&lt;" s in
    let s = Str.global_replace (Str.regexp ">") "&gt;" s in
    let s = Str.global_replace (Str.regexp "\"") "&quot;" s in
    s
  in
  
  let dimension_scores_xml = String.concat "\n    " (List.map (fun (dim, score) ->
    Printf.sprintf {|<dimension name="%s" score="%.3f" />|} (escape_xml dim) score
  ) data.dimension_scores) in
  
  let list_to_xml tag_name items = String.concat "\n    " (List.map (fun item ->
    Printf.sprintf {|<%s>%s</%s>|} tag_name (escape_xml item) tag_name
  ) items) in
  
  let metadata_xml = String.concat "\n    " (List.map (fun (key, value) ->
    Printf.sprintf {|<metadata key="%s" value="%s" />|} (escape_xml key) (escape_xml value)
  ) data.metadata) in
  
  Printf.sprintf {|<?xml version="1.0" encoding="UTF-8"?>
<poetry_evaluation_report>
  <poem_text><![CDATA[%s]]></poem_text>
  <evaluation_results>
    <overall_score>%.3f</overall_score>
    <artistic_level>%s</artistic_level>
    <quality_grade>%s</quality_grade>
    <dimension_scores>
      %s
    </dimension_scores>
  </evaluation_results>
  <analysis>
    <strengths>
      %s
    </strengths>
    <weaknesses>
      %s
    </weaknesses>
    <suggestions>
      %s
    </suggestions>
  </analysis>
  <metadata>
    <evaluation_time>%.3f</evaluation_time>
    %s
  </metadata>
  <generated_at>%.0f</generated_at>
</poetry_evaluation_report>|} data.poem_text data.overall_score 
    (escape_xml data.artistic_level) (escape_xml data.quality_grade)
    dimension_scores_xml
    (list_to_xml "strength" data.strengths)
    (list_to_xml "weakness" data.weaknesses)
    (list_to_xml "suggestion" data.suggestions)
    data.evaluation_time metadata_xml (Unix.time ())

(** {1 定制化报告} *)

(** 生成简化报告 *)
let generate_summary_report data =
  Printf.sprintf "【评估结果】整体评分: %.2f | 艺术水平: %s | 主要优点: %s | 主要建议: %s"
    data.overall_score data.artistic_level
    (match data.strengths with h :: _ -> h | [] -> "无")
    (match data.suggestions with h :: _ -> h | [] -> "无")

(** 生成对比报告 *)
let generate_comparison_report data1 data2 =
  let score_diff = data2.overall_score -. data1.overall_score in
  let comparison_text = 
    if score_diff > 0.05 then "有所提升"
    else if score_diff < -0.05 then "有所下降"
    else "基本持平"
  in
  
  Printf.sprintf {|
对比评估报告
============

作品1评分: %.2f (%s)
作品2评分: %.2f (%s)
变化趋势: %s (%.3f)

维度对比:
%s
|} data1.overall_score data1.quality_grade
   data2.overall_score data2.quality_grade
   comparison_text score_diff
   (String.concat "\n" (List.map2 (fun (dim1, score1) (_dim2, score2) ->
     Printf.sprintf "  %s: %.2f → %.2f (%+.2f)" dim1 score1 score2 (score2 -. score1)
   ) data1.dimension_scores data2.dimension_scores))

(** 生成专家点评报告 *)
let generate_expert_review data =
  let expertise_level = 
    if data.overall_score >= 0.9 then "这是一首优秀的作品"
    else if data.overall_score >= 0.75 then "这是一首良好的作品"
    else if data.overall_score >= 0.6 then "这是一首中等水平的作品"
    else "这首作品还有较大提升空间"
  in
  
  let detailed_analysis = match data.dimension_scores with
    | (_, rhyme_score) :: (_, tonal_score) :: (_, parallel_score) :: _ ->
      let rhyme_comment = if rhyme_score >= 0.8 then "韵律和谐，朗朗上口" else "韵律方面还可进一步改善" in
      let tonal_comment = if tonal_score >= 0.8 then "平仄协调，富有节奏感" else "平仄搭配需要注意" in
      let parallel_comment = if parallel_score >= 0.8 then "对仗工整，结构严谨" else "对仗方面可以加强" in
      [rhyme_comment; tonal_comment; parallel_comment]
    | _ -> ["各方面表现均衡"]
  in
  
  Printf.sprintf {|
专家点评
========

%s，整体评分%.2f分。

技法分析：
%s

创作建议：
%s

总评：%s在继承传统诗词精神的基础上，%s。建议作者%s，以期达到更高的艺术境界。
|} expertise_level data.overall_score
   (String.concat "\n" detailed_analysis)
   (String.concat "\n" data.suggestions)
   (if data.overall_score >= 0.8 then "作品" else "此作")
   (if data.overall_score >= 0.8 then "展现了扎实的文学功底" else "仍有提升的潜力")
   (if data.overall_score >= 0.8 then "保持现有水平并继续精进" else "加强基础训练，多读经典")

(** {1 批量报告生成} *)

(** 生成批量评估报告 *)
let generate_batch_report data_list format =
  let individual_reports = List.mapi (fun i data ->
    Printf.sprintf "## 作品 %d\n\n%s" (i + 1) (generate_basic_report data format)
  ) data_list in
  
  let summary_stats = 
    let scores = List.map (fun data -> data.overall_score) data_list in
    let avg_score = List.fold_left (+.) 0.0 scores /. float_of_int (List.length scores) in
    let max_score = List.fold_left max 0.0 scores in
    let min_score = List.fold_left min 1.0 scores in
    
    Printf.sprintf {|
# 批量评估报告摘要

- 评估作品数量: %d
- 平均评分: %.3f
- 最高评分: %.3f  
- 最低评分: %.3f
- 评分标准差: %.3f

|} (List.length data_list) avg_score max_score min_score
      (sqrt (List.fold_left (fun acc score -> acc +. ((score -. avg_score) ** 2.0)) 0.0 scores /. float_of_int (List.length scores)))
  in
  
  summary_stats ^ "\n" ^ String.concat "\n\n" individual_reports

(** {1 报告输出和保存} *)

(** 保存报告到文件 *)
let save_report_to_file report_content filename =
  try
    let oc = open_out filename in
    output_string oc report_content;
    close_out oc;
    Ok filename
  with e -> Error (Printexc.to_string e)

(** 生成文件名 *)
let generate_filename format timestamp =
  let extension = match format with
    | PlainText -> "txt"
    | Markdown -> "md"
    | HTML -> "html"
    | JSON -> "json"
    | XML -> "xml"
  in
  Printf.sprintf "poetry_evaluation_%.0f.%s" timestamp extension

(** {1 报告模板系统} *)

let report_templates = Hashtbl.create 10

(** 注册报告模板 *)
let register_template name template =
  Hashtbl.replace report_templates name template

(** 使用模板生成报告 *)
let generate_from_template template_name data =
  try
    let template = Hashtbl.find report_templates template_name in
    (* 简单的模板替换系统 *)
    let report = Str.global_replace (Str.regexp "{overall_score}") (string_of_float data.overall_score) template in
    let report = Str.global_replace (Str.regexp "{artistic_level}") data.artistic_level report in
    let report = Str.global_replace (Str.regexp "{poem_text}") data.poem_text report in
    Some report
  with Not_found -> None

(** {1 初始化默认模板} *)

let () =
  register_template "brief" "作品评分: {overall_score}, 水平: {artistic_level}";
  register_template "formal" "诗词：{poem_text}\n评估结果：整体评分{overall_score}，达到{artistic_level}水平。"