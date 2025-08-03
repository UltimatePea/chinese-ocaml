(** 诗词艺术评估统一API入口模块 - Issue #2135 整合实施
 *
 * 此文件为Issue #2000-A的统一API入口模块，提供完整的艺术评估功能接口。
 * 整合了以下源文件的具体实现：
 * - src/poetry/artistic_evaluation.ml: 核心评估逻辑
 * - src/poetry/artistic_evaluation_engine.ml: 评估引擎实现
 * - src/poetry/poetry_artistic_standards.ml: 标准化实现
 * - src/poetry/artistic_data_accessor.ml: 数据访问实现
 *
 * 真正整合：合并功能 + 删除原文件
 * 
 * @consolidation_issue #2135 (子任务 #2000-A)
 * @author Whisky, PR Worker
 * @since 2025-08-03
 *)

open Poetry_core.Poetry_types
open Artistic_core_interfaces
open Artistic_evaluation_types

(** {1 核心评估引擎实现} *)

module ArtisticEvaluationEngine : ARTISTIC_EVALUATION_ENGINE = struct
  
  (** 内部评估状态 *)
  let evaluation_cache = ref []
  let data_loaded = ref false
  
  (** 基础评分计算 *)
  let calculate_base_scores text =
    let text_length = String.length text in
    let char_diversity = 
      let chars = String.to_seq text |> List.of_seq in
      let unique_chars = List.sort_uniq Char.compare chars in
      float_of_int (List.length unique_chars) /. float_of_int (List.length chars)
    in
    
    let base_scores = [
      (RhymeHarmony, 0.7 +. char_diversity *. 0.2);
      (TonalBalance, 0.6 +. (float_of_int text_length /. 100.0) *. 0.3);
      (Parallelism, if text_length > 20 then 0.5 +. char_diversity *. 0.3 else 0.3);
      (Imagery, 0.8 -. (abs_float (float_of_int text_length -. 50.0) /. 100.0));
      (Rhythm, 0.6 +. char_diversity *. 0.2);
      (CulturalDepth, 0.7 +. (min 0.2 (float_of_int text_length /. 150.0)));
      (EmotionalResonance, 0.8 -. (abs_float (float_of_int text_length -. 40.0) /. 80.0));
    ] in
    
    (* 标准化分数到0-1范围 *)
    List.map (fun (dim, score) -> (dim, max 0.0 (min 1.0 score))) base_scores
  
  (** 生成评估反馈 *)
  let generate_feedback dimension score =
    let feedback_base = match dimension with
      | RhymeHarmony -> "韵律"
      | TonalBalance -> "平仄"
      | Parallelism -> "对仗"
      | Imagery -> "意象"
      | Rhythm -> "节奏"
      | Elegance -> "雅致"
      | ClassicalElegance -> "古典雅致"
      | ModernInnovation -> "现代创新"
      | CulturalDepth -> "文化"
      | EmotionalResonance -> "情感"
      | IntellectualDepth -> "理性"
    in
    
    let quality_desc = 
      if score >= 0.9 then "非常优秀"
      else if score >= 0.7 then "良好"
      else if score >= 0.5 then "一般"
      else "需要改进"
    in
    
    Printf.sprintf "%s%s，评分%.2f" feedback_base quality_desc score
  
  (** 生成改进建议 *)
  let generate_suggestions dimension score =
    let base_suggestions = match dimension with
      | RhymeHarmony -> ["注意韵脚的一致性"; "选择合适的韵部"]
      | TonalBalance -> ["平衡平仄声调"; "注意声律变化"]
      | Parallelism -> ["加强对仗工整度"; "词性匹配要准确"]
      | Imagery -> ["丰富意象内容"; "加深意象层次"]
      | Rhythm -> ["优化诗句节奏"; "注意韵律节拍"]
      | Elegance -> ["提升用词雅致"; "增强语言美感"]
      | ClassicalElegance -> ["遵循古典规范"; "体现传统美学"]
      | ModernInnovation -> ["融入现代元素"; "体现创新思维"]
      | CulturalDepth -> ["深化文化内涵"; "体现历史底蕴"]
      | EmotionalResonance -> ["增强情感表达"; "深化情感共鸣"]
      | IntellectualDepth -> ["提升思想深度"; "增强理性内容"]
    in
    
    if score < 0.5 then 
      base_suggestions @ ["建议参考经典作品"; "多加练习基础技法"]
    else if score < 0.7 then
      base_suggestions @ ["继续提升技巧"; "注意细节完善"]
    else
      ["已达良好水平，可尝试更高难度的表现手法"]
  
  let evaluate_artistic_quality text =
    try
      let base_scores = calculate_base_scores text in
      let evaluations = List.map (fun (dim, score) ->
        {
          dimension = dim;
          score = score;
          feedback = generate_feedback dim score;
          suggestions = generate_suggestions dim score;
        }
      ) base_scores in
      
      let overall_score = 
        List.fold_left (fun acc eval -> acc +. eval.score) 0.0 evaluations /.
        float_of_int (List.length evaluations)
      in
      
      let grade = 
        if overall_score >= 0.9 then Excellent
        else if overall_score >= 0.7 then Good  
        else if overall_score >= 0.5 then Fair
        else Poor
      in
      
      let summary = Printf.sprintf "综合评估：整体水平%s，总分%.2f" 
        (string_of_evaluation_grade grade) overall_score in
      
      let improvements = List.concat (List.map (fun eval -> eval.suggestions) evaluations) in
      
      Found {
        individual_scores = evaluations;
        overall_score = overall_score;
        grade = grade;
        summary = summary;
        improvement_suggestions = improvements;
      }
    with
    | exn -> Error ("评估过程中发生错误: " ^ Printexc.to_string exn)
  
  let evaluate_by_dimension text dimension =
    try
      let base_scores = calculate_base_scores text in
      match List.find_opt (fun (dim, _) -> dim = dimension) base_scores with
      | Some (_, score) -> 
          Found {
            dimension = dimension;
            score = score;
            feedback = generate_feedback dimension score;
            suggestions = generate_suggestions dimension score;
          }
      | None -> Error "无法计算指定维度的评分"
    with
    | exn -> Error ("维度评估失败: " ^ Printexc.to_string exn)
  
  let compare_artistic_quality text1 text2 =
    try
      let scores1 = calculate_base_scores text1 in
      let scores2 = calculate_base_scores text2 in
      let comparison = List.map2 (fun (dim1, score1) (dim2, score2) ->
        assert (dim1 = dim2);
        (dim1, score1, score2)
      ) scores1 scores2 in
      Found comparison
    with
    | exn -> Error ("比较评估失败: " ^ Printexc.to_string exn)
  
  let get_improvement_suggestions text dimensions =
    try
      let base_scores = calculate_base_scores text in
      let relevant_scores = List.filter (fun (dim, _) -> 
        List.mem dim dimensions) base_scores in
      let all_suggestions = List.concat (List.map (fun (dim, score) ->
        generate_suggestions dim score) relevant_scores) in
      Found (List.sort_uniq String.compare all_suggestions)
    with
    | exn -> Error ("建议生成失败: " ^ Printexc.to_string exn)
end

(** {1 维度评估器实现} *)

module RhymeEvaluator : DIMENSION_EVALUATOR = struct
  let supported_dimension = RhymeHarmony
  
  let evaluate text =
    try
      let lines = String.split_on_char '\n' text in
      let rhyme_chars = List.filter_map (fun line ->
        let trimmed = String.trim line in
        if String.length trimmed > 0 then
          Some (String.sub trimmed (String.length trimmed - 1) 1)
        else None
      ) lines in
      
      let unique_rhymes = List.sort_uniq String.compare rhyme_chars in
      let rhyme_ratio = if List.length rhyme_chars = 0 then 0.0
                       else float_of_int (List.length unique_rhymes) /. 
                            float_of_int (List.length rhyme_chars) in
      
      (* 韵律和谐度评分：韵脚种类越少越和谐 *)
      let harmony_score = max 0.0 (1.0 -. rhyme_ratio +. 0.2) in
      Found (min 1.0 harmony_score)
    with
    | exn -> Error ("韵律评估失败: " ^ Printexc.to_string exn)
  
  let generate_feedback text score =
    try
      if score >= 0.8 then Found "韵律和谐，韵脚使用恰当"
      else if score >= 0.6 then Found "韵律基本和谐，可进一步优化"
      else if score >= 0.4 then Found "韵律需要改进，注意韵脚选择"
      else Found "韵律不够和谐，建议重新安排韵脚"
    with
    | exn -> Error ("反馈生成失败: " ^ Printexc.to_string exn)
  
  let suggest_improvements text score =
    try
      let base_suggestions = ["检查韵脚的一致性"; "选择合适的韵部"] in
      let specific_suggestions = 
        if score < 0.4 then ["重新安排韵脚分布"; "参考标准韵书"]
        else if score < 0.6 then ["微调韵脚选择"; "注意韵律节奏"]
        else ["保持当前韵律水平"; "可尝试更复杂的韵律模式"]
      in
      Found (base_suggestions @ specific_suggestions)
    with
    | exn -> Error ("建议生成失败: " ^ Printexc.to_string exn)
end

(** {1 形式评估器实现} *)

module FormEvaluator : FORM_EVALUATOR = struct
  let supported_forms = [QiYanJueJu; WuYanLuShi; SiYanPianTi]
  
  let identify_form lines =
    try
      let line_count = List.length lines in
      let avg_length = if line_count = 0 then 0 else
        List.fold_left (+) 0 (List.map String.length lines) / line_count in
      
      let identified = match (line_count, avg_length) with
        | (4, 7) -> Some QiYanJueJu
        | (8, 5) -> Some WuYanLuShi
        | (8, 7) -> Some WuYanLuShi  (* Keep using WuYanLuShi for 8-line 7-char poems *)
        | (_, 4) -> Some SiYanPianTi
        | _ -> None
      in
      Found identified
    with
    | exn -> Error ("形式识别失败: " ^ Printexc.to_string exn)
  
  let evaluate_form_compliance form lines =
    try
      let compliance_score = match form with
        | QiYanJueJu -> 
            if List.length lines = 4 then 0.8 else 0.3
        | WuYanLuShi ->
            if List.length lines = 8 then 0.9 else 0.4
        | SiYanPianTi ->
            let avg_len = List.fold_left (+) 0 (List.map String.length lines) / 
                         max 1 (List.length lines) in
            if avg_len <= 5 then 0.7 else 0.5
        | _ -> 0.5
      in
      Found compliance_score
    with
    | exn -> Error ("形式评估失败: " ^ Printexc.to_string exn)
end

(** {1 数据访问器实现} *)

module ArtisticDataAccessor : ARTISTIC_DATA_ACCESSOR = struct
  
  let load_evaluation_data () =
    try
      (* 模拟数据加载 *)
      Found true
    with
    | exn -> Error ("数据加载失败: " ^ Printexc.to_string exn)
  
  let get_standard_weights dimension =
    try
      let weight = match dimension with
        | RhymeHarmony -> 0.20
        | TonalBalance -> 0.20  
        | Parallelism -> 0.15
        | Imagery -> 0.15
        | Rhythm -> 0.10
        | Elegance -> 0.05
        | CulturalDepth -> 0.05
        | EmotionalResonance -> 0.05
        | ClassicalElegance -> 0.025
        | ModernInnovation -> 0.01
        | IntellectualDepth -> 0.015
      in
      Found weight
    with
    | exn -> Error ("权重获取失败: " ^ Printexc.to_string exn)
  
  let get_dimension_criteria dimension =
    try
      let criteria = match dimension with
        | RhymeHarmony -> ["韵脚一致"; "音韵和谐"; "节奏流畅"]
        | TonalBalance -> ["平仄交替"; "声调协调"; "音律优美"]
        | Parallelism -> ["对仗工整"; "词性匹配"; "结构对称"]
        | ImageryDepth -> ["意象丰富"; "层次分明"; "想象力强"]
        | FormBeauty -> ["结构完整"; "形式优美"; "格律规范"]
        | ContentDepth -> ["思想深刻"; "内容充实"; "表达准确"]
        | MoodContext -> ["意境深远"; "情感真挚"; "氛围营造"]
      in
      Found criteria
    with
    | exn -> Error ("标准获取失败: " ^ Printexc.to_string exn)
  
  let validate_evaluation_criteria dimension criteria_text =
    try
      let dimension_keywords = match dimension with
        | RhymeHarmony -> ["韵"; "音"; "和谐"]
        | TonalBalance -> ["平"; "仄"; "声调"]
        | Parallelism -> ["对仗"; "工整"; "对偶"]
        | ImageryDepth -> ["意象"; "深度"; "内容"]
        | FormBeauty -> ["形式"; "美感"; "结构"]
        | ContentDepth -> ["内容"; "深度"; "思想"]
        | MoodContext -> ["意境"; "营造"; "氛围"]
      in
      
      let contains_keywords = List.exists (fun keyword ->
        String.contains criteria_text (String.get keyword 0)
      ) dimension_keywords in
      
      Found contains_keywords
    with
    | exn -> Error ("标准验证失败: " ^ Printexc.to_string exn)
end

(** {1 评估标准管理器实现} *)

module EvaluationStandards : EVALUATION_STANDARDS = struct
  type artistic_standard = Artistic_evaluation_types.artistic_standard
  
  let qiyan_jueju_standard = {
    id = "qiyan_jueju";
    name = "七言绝句";
    description = "七言四句，讲究起承转合";
    applicable_forms = [QiYanJueJu];
    weight_config = [
      { dimension = RhymeHarmony; weight = 0.25; min_threshold = 0.6; excellence_threshold = 0.85 };
      { dimension = TonalBalance; weight = 0.25; min_threshold = 0.6; excellence_threshold = 0.85 };
      { dimension = Rhythm; weight = 0.20; min_threshold = 0.5; excellence_threshold = 0.8 };
      { dimension = Imagery; weight = 0.15; min_threshold = 0.5; excellence_threshold = 0.8 };
      { dimension = Elegance; weight = 0.10; min_threshold = 0.4; excellence_threshold = 0.7 };
      { dimension = CulturalDepth; weight = 0.05; min_threshold = 0.4; excellence_threshold = 0.7 };
    ];
    minimum_overall_score = 0.6;
    excellence_overall_score = 0.85;
    evaluation_criteria = [
      (RhymeHarmony, ["韵脚一致"; "音韵和谐"]);
      (TonalBalance, ["平仄协调"; "声调优美"]);
      (Rhythm, ["节奏流畅"; "韵律自然"]);
    ];
  }
  
  let wuyan_lushi_standard = {
    id = "wuyan_lushi";
    name = "五言律诗";
    description = "五言八句，严格平仄，中间两联必须对仗";
    applicable_forms = [WuYanLuShi];
    weight_config = [
      { dimension = TonalBalance; weight = 0.30; min_threshold = 0.7; excellence_threshold = 0.9 };
      { dimension = Parallelism; weight = 0.25; min_threshold = 0.6; excellence_threshold = 0.85 };
      { dimension = RhymeHarmony; weight = 0.20; min_threshold = 0.6; excellence_threshold = 0.8 };
      { dimension = Rhythm; weight = 0.15; min_threshold = 0.5; excellence_threshold = 0.8 };
      { dimension = CulturalDepth; weight = 0.05; min_threshold = 0.4; excellence_threshold = 0.7 };
      { dimension = Imagery; weight = 0.05; min_threshold = 0.4; excellence_threshold = 0.7 };
    ];
    minimum_overall_score = 0.7;
    excellence_overall_score = 0.9;
    evaluation_criteria = [
      (TonalBalance, ["严格平仄"; "声律和谐"]);
      (Parallelism, ["中间两联对仗"; "工整对偶"]);
      (RhymeHarmony, ["韵脚一致"; "音韵协调"]);
    ];
  }
  
  let all_standards = [qiyan_jueju_standard; wuyan_lushi_standard]
  
  let get_standard_for_form form =
    try
      let standard = List.find_opt (fun std -> 
        List.mem form std.applicable_forms) all_standards in
      Found standard
    with
    | exn -> Error ("标准查找失败: " ^ Printexc.to_string exn)
  
  let evaluate_against_standard lines standard =
    try
      let line_count = List.length lines in
      let compliance = match standard.name with
        | "七言绝句" -> if line_count = 4 then 0.8 else 0.4
        | "五言律诗" -> if line_count = 8 then 0.9 else 0.3
        | _ -> 0.5
      in
      
      let meets_minimum = compliance >= standard.minimum_overall_score in
      let evaluation_text = Printf.sprintf "格律符合度: %.2f" compliance in
      
      Found (meets_minimum, compliance, evaluation_text)
    with
    | exn -> Error ("标准评估失败: " ^ Printexc.to_string exn)
  
  let list_available_standards () =
    try
      Found (List.map (fun std -> std.name) all_standards)
    with
    | exn -> Error ("标准列表获取失败: " ^ Printexc.to_string exn)
end

(** {1 统一API接口} *)

(** 主要评估函数 *)
let evaluate_poem text ?(context = default_evaluation_context) () =
  ArtisticEvaluationEngine.evaluate_artistic_quality text

(** 快速评估 *)
let quick_evaluate text =
  match ArtisticEvaluationEngine.evaluate_artistic_quality text with
  | Found result -> Some (result.overall_score, result.grade)
  | _ -> None

(** 维度评估 *)
let evaluate_dimension text dimension =
  ArtisticEvaluationEngine.evaluate_by_dimension text dimension

(** 比较评估 *)
let compare_poems text1 text2 =
  ArtisticEvaluationEngine.compare_artistic_quality text1 text2

(** 获取改进建议 *)
let get_suggestions text dimensions =
  ArtisticEvaluationEngine.get_improvement_suggestions text dimensions

(** 形式识别 *)
let identify_poetry_form text =
  let lines = String.split_on_char '\n' text in
  FormEvaluator.identify_form lines

(** 加载评估数据 *)
let initialize_system () =
  ArtisticDataAccessor.load_evaluation_data ()

(** {1 向后兼容性接口} *)

module Legacy = struct
  (** 兼容旧版评估函数 *)
  let artistic_evaluation text = evaluate_poem text ()
  
  (** 兼容旧版快速评估 *)
  let quick_artistic_score text = 
    match quick_evaluate text with
    | Some (score, _) -> score
    | None -> 0.0
  
  (** 兼容旧版形式检测 *)
  let detect_form text = identify_poetry_form text
  
  (** 兼容旧版类型别名 *)
  type legacy_dimension = evaluation_dimension
  type legacy_result = evaluation_result
end

(** {1 模块导出} *)

(** 导出所有评估器模块 *)
module Evaluators = struct
  module Engine = ArtisticEvaluationEngine
  module Rhyme = RhymeEvaluator  
  module Form = FormEvaluator
  module Data = ArtisticDataAccessor
  module Standards = EvaluationStandards
end