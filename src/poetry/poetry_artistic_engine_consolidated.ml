(** Poetry Artistic Engine Consolidated Module - Issue #1999
 * 
 * 诗词艺术性评价引擎统一模块
 * Author: Whisky, PR Worker
 * 
 * 整合以下模块的功能：
 * - artistic_* 系列文件
 * - evaluation_framework.ml
 * - poetry_artistic_engine.ml
 * - evaluators/ 目录下的文件
 * 
 * 目标：提供全面的诗词艺术性分析和评价
 *)

open Poetry_core_consolidated

(** {1 艺术性评价类型定义} *)

(** 艺术性评价维度 *)
type artistic_dimension = 
  | ContentDepth      (** 内容深度 *)
  | FormBeauty        (** 形式美感 *)
  | ImageryVividness  (** 意象生动性 *)
  | MoodContext       (** 意境氛围 *)
  | ParallelismQuality (** 对仗工整性 *)
  | RhymeHarmony      (** 韵律和谐性 *)
  | TonalBalance      (** 音调平衡 *)

(** 艺术性分析结果 *)
type artistic_analysis = {
  dimension: artistic_dimension;
  score: float;
  details: string;
  suggestions: string list;
}

(** 综合艺术性评价结果 *)
type comprehensive_artistic_evaluation = {
  overall_score: float;
  dimension_scores: (evaluation_dimension * float) list;
  detailed_analysis: artistic_analysis list;
  artistic_highlights: string list;
  improvement_areas: string list;
}

(** 诗词意象类型 *)
type imagery_type = 
  | Natural     (** 自然意象 *)
  | Human       (** 人文意象 *)
  | Emotional   (** 情感意象 *)
  | Historical  (** 历史意象 *)
  | Seasonal    (** 季节意象 *)

(** 意象元素 *)
type imagery_element = {
  element_type: imagery_type;
  keywords: string list;
  emotional_tone: float;  (* -1.0 到 1.0，负值表示消极，正值表示积极 *)
  frequency: int;
}

(** {1 艺术性评价数据库} *)

(** 自然意象关键词库 *)
let natural_imagery_keywords = [
  ("山", 0.6); ("水", 0.7); ("云", 0.8); ("月", 0.9); ("星", 0.8);
  ("风", 0.5); ("雨", 0.4); ("雪", 0.6); ("花", 0.9); ("草", 0.5);
  ("树", 0.6); ("林", 0.7); ("江", 0.7); ("河", 0.6); ("海", 0.8);
  ("天", 0.8); ("地", 0.5); ("日", 0.8); ("光", 0.9); ("影", 0.4);
]

(** 情感意象关键词库 *)
let emotional_imagery_keywords = [
  ("愁", -0.8); ("忧", -0.7); ("悲", -0.9); ("哀", -0.8); ("痛", -0.9);
  ("喜", 0.8); ("乐", 0.9); ("欢", 0.8); ("笑", 0.7); ("欣", 0.6);
  ("爱", 0.9); ("恨", -0.8); ("思", 0.3); ("念", 0.4); ("望", 0.5);
  ("怨", -0.6); ("叹", -0.4); ("泣", -0.7); ("啼", -0.6); ("吟", 0.3);
]

(** 季节意象关键词库 *)
let seasonal_imagery_keywords = [
  ("春", 0.8); ("夏", 0.6); ("秋", 0.2); ("冬", -0.2);
  ("芳", 0.7); ("绿", 0.6); ("红", 0.5); ("黄", 0.3);
  ("暖", 0.6); ("寒", -0.4); ("热", 0.2); ("冷", -0.5);
  ("暮", -0.2); ("晨", 0.7); ("夜", -0.1); ("昼", 0.5);
]

(** 人文意象关键词库 *)
let human_imagery_keywords = [
  ("君", 0.6); ("臣", 0.3); ("民", 0.4); ("人", 0.5); ("士", 0.5);
  ("友", 0.7); ("敌", -0.6); ("家", 0.8); ("国", 0.6); ("城", 0.4);
  ("宫", 0.3); ("府", 0.2); ("楼", 0.5); ("阁", 0.6); ("台", 0.5);
  ("门", 0.2); ("窗", 0.3); ("庭", 0.6); ("园", 0.7); ("堂", 0.5);
]

(** {1 意象分析引擎} *)

(** 检测诗句中的意象元素 *)
let detect_imagery_elements (line: string) : imagery_element list =
  let chars = List.init (String.length line) (String.get line) in
  let char_strings = List.map (String.make 1) chars in
  
  let natural_matches = List.filter_map (fun char ->
    match List.find_opt (fun (keyword, _) -> keyword = char) natural_imagery_keywords with
    | Some (keyword, tone) -> Some { 
        element_type = Natural; 
        keywords = [keyword]; 
        emotional_tone = tone; 
        frequency = 1 
      }
    | None -> None
  ) char_strings in
  
  let emotional_matches = List.filter_map (fun char ->
    match List.find_opt (fun (keyword, _) -> keyword = char) emotional_imagery_keywords with
    | Some (keyword, tone) -> Some { 
        element_type = Emotional; 
        keywords = [keyword]; 
        emotional_tone = tone; 
        frequency = 1 
      }
    | None -> None
  ) char_strings in
  
  let seasonal_matches = List.filter_map (fun char ->
    match List.find_opt (fun (keyword, _) -> keyword = char) seasonal_imagery_keywords with
    | Some (keyword, tone) -> Some { 
        element_type = Seasonal; 
        keywords = [keyword]; 
        emotional_tone = tone; 
        frequency = 1 
      }
    | None -> None
  ) char_strings in
  
  let human_matches = List.filter_map (fun char ->
    match List.find_opt (fun (keyword, _) -> keyword = char) human_imagery_keywords with
    | Some (keyword, tone) -> Some { 
        element_type = Human; 
        keywords = [keyword]; 
        emotional_tone = tone; 
        frequency = 1 
      }
    | None -> None
  ) char_strings in
  
  natural_matches @ emotional_matches @ seasonal_matches @ human_matches

(** 分析诗词整体意象 *)
let analyze_poem_imagery (poem_lines: string list) : imagery_element list =
  List.fold_left (fun acc line ->
    let line_imagery = detect_imagery_elements line in
    line_imagery @ acc
  ) [] poem_lines

(** {1 艺术性分析引擎} *)

(** 内容深度评价 *)
let evaluate_content_depth (poem_lines: string list) : artistic_analysis =
  let imagery_elements = analyze_poem_imagery poem_lines in
  let total_elements = List.length imagery_elements in
  let unique_types = 
    imagery_elements
    |> List.map (fun elem -> elem.element_type)
    |> List.sort_uniq compare
    |> List.length
  in
  
  let depth_score = 
    if total_elements = 0 then 0.3
    else min 1.0 (float_of_int unique_types /. 3.0 +. float_of_int total_elements /. 10.0)
  in
  
  let details = Printf.sprintf "检测到%d个意象元素，涵盖%d种类型" total_elements unique_types in
  let suggestions = 
    if depth_score < 0.6 then ["增加更多丰富的意象元素"; "扩展诗词的内涵深度"]
    else ["内容深度良好"]
  in
  
  {
    dimension = ContentDepth;
    score = depth_score;
    details = details;
    suggestions = suggestions;
  }

(** 形式美感评价 *)
let evaluate_form_beauty (poem_lines: string list) : artistic_analysis =
  let line_count = List.length poem_lines in
  let line_lengths = List.map String.length poem_lines in
  let avg_length = 
    if line_count > 0 then
      float_of_int (List.fold_left (+) 0 line_lengths) /. float_of_int line_count
    else 0.0
  in
  
  (* 检查行长度一致性 *)
  let length_consistency = 
    let max_len = List.fold_left max 0 line_lengths in
    let min_len = List.fold_left min max_int line_lengths in
    if max_len = min_len then 1.0
    else 1.0 -. float_of_int (max_len - min_len) /. float_of_int max_len
  in
  
  (* 检查是否符合传统格律 *)
  let form_score = 
    match (line_count, int_of_float avg_length) with
    | (4, 5) -> 0.9  (* 五言绝句 *)
    | (4, 7) -> 0.9  (* 七言绝句 *)
    | (8, 5) -> 0.95 (* 五言律诗 *)
    | (8, 7) -> 0.95 (* 七言律诗 *)
    | _ -> length_consistency *. 0.7
  in
  
  let details = Printf.sprintf "平均行长度%.1f字，长度一致性%.2f" avg_length length_consistency in
  let suggestions = 
    if form_score < 0.6 then ["调整诗句长度保持一致"; "考虑传统诗词格律"]
    else ["形式美感良好"]
  in
  
  {
    dimension = FormBeauty;
    score = form_score;
    details = details;
    suggestions = suggestions;
  }

(** 意象生动性评价 *)
let evaluate_imagery_vividness (poem_lines: string list) : artistic_analysis =
  let imagery_elements = analyze_poem_imagery poem_lines in
  let vivid_elements = List.filter (fun elem ->
    match elem.element_type with
    | Natural | Seasonal -> true
    | _ -> false
  ) imagery_elements in
  
  let vividness_score = 
    if List.length imagery_elements > 0 then
      float_of_int (List.length vivid_elements) /. float_of_int (List.length imagery_elements)
    else 0.3
  in
  
  let details = Printf.sprintf "生动意象%d个，总意象%d个" 
    (List.length vivid_elements) (List.length imagery_elements) in
  let suggestions = 
    if vividness_score < 0.5 then ["增加自然和季节意象"; "使用更生动的描述"]
    else ["意象生动性良好"]
  in
  
  {
    dimension = ImageryVividness;
    score = vividness_score;
    details = details;
    suggestions = suggestions;
  }

(** 意境氛围评价 *)
let evaluate_mood_context (poem_lines: string list) : artistic_analysis =
  let imagery_elements = analyze_poem_imagery poem_lines in
  let emotional_tones = List.map (fun elem -> elem.emotional_tone) imagery_elements in
  
  let avg_tone = 
    if List.length emotional_tones > 0 then
      List.fold_left (+.) 0.0 emotional_tones /. float_of_int (List.length emotional_tones)
    else 0.0
  in
  
  let tone_consistency = 
    let variance = List.fold_left (fun acc tone -> 
      acc +. (tone -. avg_tone) ** 2.0
    ) 0.0 emotional_tones in
    let std_dev = sqrt (variance /. float_of_int (max 1 (List.length emotional_tones))) in
    max 0.0 (1.0 -. std_dev)
  in
  
  let mood_score = (abs_float avg_tone +. tone_consistency) /. 2.0 in
  
  let mood_description = 
    if avg_tone > 0.3 then "积极向上"
    else if avg_tone < -0.3 then "忧郁深沉"
    else "平和中性"
  in
  
  let details = Printf.sprintf "整体情调：%s（%.2f），情调一致性：%.2f" 
    mood_description avg_tone tone_consistency in
  let suggestions = 
    if mood_score < 0.5 then ["统一诗词的情感基调"; "加强意境营造"]
    else ["意境氛围营造良好"]
  in
  
  {
    dimension = MoodContext;
    score = mood_score;
    details = details;
    suggestions = suggestions;
  }

(** {1 综合艺术性评价引擎} *)

(** 综合诗词艺术性评价 *)
let comprehensive_artistic_evaluation (poem_lines: string list) : comprehensive_artistic_evaluation =
  let content_analysis = evaluate_content_depth poem_lines in
  let form_analysis = evaluate_form_beauty poem_lines in
  let imagery_analysis = evaluate_imagery_vividness poem_lines in
  let mood_analysis = evaluate_mood_context poem_lines in
  
  let detailed_analysis = [content_analysis; form_analysis; imagery_analysis; mood_analysis] in
  
  let overall_score = 
    (content_analysis.score +. form_analysis.score +. 
     imagery_analysis.score +. mood_analysis.score) /. 4.0
  in
  
  let dimension_scores = [
    (Content, content_analysis.score);
    (Form, form_analysis.score);
    (Artistic, (imagery_analysis.score +. mood_analysis.score) /. 2.0);
  ] in
  
  let artistic_highlights = 
    List.filter_map (fun analysis ->
      if analysis.score >= 0.8 then Some (Printf.sprintf "%s表现优秀" analysis.details)
      else None
    ) detailed_analysis
  in
  
  let improvement_areas = 
    List.fold_left (fun acc analysis ->
      if analysis.score < 0.6 then analysis.suggestions @ acc
      else acc
    ) [] detailed_analysis
  in
  
  {
    overall_score = overall_score;
    dimension_scores = dimension_scores;
    detailed_analysis = detailed_analysis;
    artistic_highlights = artistic_highlights;
    improvement_areas = improvement_areas;
  }

(** 生成改进指导建议 *)
let generate_improvement_guidance (evaluation: comprehensive_artistic_evaluation) : string list =
  let basic_suggestions = evaluation.improvement_areas in
  let score_based_suggestions = 
    if evaluation.overall_score < 0.4 then
      ["整体艺术水平需要显著提升"; "建议从基础格律和韵律开始改进"]
    else if evaluation.overall_score < 0.7 then
      ["艺术表现力有待提高"; "可以尝试更丰富的意象和修辞手法"]
    else
      ["艺术水平较好"; "可以追求更高层次的意境表达"]
  in
  basic_suggestions @ score_based_suggestions

(** {1 兼容性函数} *)

(** 兼容旧的艺术性评价接口 *)
let evaluate_poem_artistic_compat (poem_lines: string list) : evaluation_result =
  let artistic_eval = comprehensive_artistic_evaluation poem_lines in
  {
    overall_score = artistic_eval.overall_score;
    dimension_scores = artistic_eval.dimension_scores;
    rhyme_quality = 0.5;  (* 韵律质量由其他模块提供 *)
    artistic_quality = artistic_eval.overall_score;
    form_compliance = 
      (match List.find_opt (fun (dim, _) -> dim = Form) artistic_eval.dimension_scores with
      | Some (_, score) -> score
      | None -> 0.5);
    recommendations = generate_improvement_guidance artistic_eval;
  }

(** 简化的艺术性评分 *)
let quick_artistic_score (poem_lines: string list) : float =
  let evaluation = comprehensive_artistic_evaluation poem_lines in
  evaluation.overall_score