(** 统一艺术性评价引擎 - Phase 2: Engine Layer Refactoring
    
    此模块统一了原先分散在30个文件中的艺术性评价功能，建立插件式架构，
    基于统一的韵律分析引擎提供综合的诗词艺术性评价。
    
    技术债务修复：
    - 消除artistic_evaluator_*.ml等30个重复模块
    - 建立统一的评价框架和插件系统
    - 基于统一韵律分析引擎，提升评价准确性
    
    @author Alpha, 主要开发代理 - Poetry模块重构团队
    @version 2.0 (Phase 2: 引擎层重构版)
    @since 2025-07-27
    @fix_issue #1501 *)

open Rhythm_analyzer

(** {1 艺术性评价类型定义} *)

(** 评价维度类型 *)
type evaluation_dimension = 
  | Rhyme          (** 韵律评价 *)
  | Tone           (** 声调评价 *)
  | Meter          (** 格律评价 *)
  | Parallelism    (** 对仗评价 *)
  | Imagery        (** 意象评价 *)
  | Rhythm         (** 节奏评价 *)
  | Elegance       (** 雅致评价 *)
  | Content        (** 内容评价 *)
  | Form           (** 形式评价 *)
  | Overall        (** 综合评价 *)

(** 评价结果 *)
type evaluation_result = {
  dimension: evaluation_dimension;       (** 评价维度 *)
  score: float;                         (** 评分 (0.0-1.0) *)
  max_score: float;                     (** 最高分 *)
  details: string option;               (** 详细说明 *)
  confidence: float;                    (** 评价置信度 *)
  suggestions: string list;             (** 改进建议 *)
}

(** 诗词评价上下文 *)
type evaluation_context = {
  verse: string;                        (** 诗句内容 *)
  verses: string list;                  (** 多句诗词 *)
  rhythm_analysis: verse_rhythm_analysis; (** 韵律分析结果 *)
  multi_analysis: multi_verse_analysis option; (** 多句分析结果 *)
  metadata: (string * string) list;    (** 额外元数据 *)
}

(** 综合评价结果 *)
type comprehensive_evaluation = {
  context: evaluation_context;          (** 评价上下文 *)
  dimension_results: evaluation_result list; (** 各维度评价结果 *)
  overall_score: float;                 (** 综合评分 *)
  overall_confidence: float;            (** 综合置信度 *)
  strengths: string list;               (** 优点列表 *)
  weaknesses: string list;              (** 不足列表 *)
  suggestions: string list;             (** 综合建议 *)
  quality_level: [ `Excellent | `Good | `Fair | `Poor ]; (** 质量等级 *)
}

(** {1 评价器插件接口} *)

(** 评价器签名 *)
module type EVALUATOR = sig
  val dimension : evaluation_dimension
  val description : string
  val weight : float
  val evaluate : evaluation_context -> evaluation_result
  val is_applicable : evaluation_context -> bool
end

(** {1 核心评价器实现} *)

(** 韵律评价器 *)
module RhymeEvaluator : EVALUATOR = struct
  let dimension = Rhyme
  let description = "基于韵组一致性和韵脚质量的韵律评价"
  let weight = 0.25

  let evaluate context =
    let analysis = context.rhythm_analysis in
    let has_rhyme_ending = Option.is_some analysis.rhyme_ending in
    let consistency_score = if analysis.rhyme_group_consistency then 1.0 else 0.3 in
    
    let score = 
      if has_rhyme_ending then
        consistency_score
      else
        0.1 (* 无韵脚的情况 *)
    in
    
    let details = 
      match analysis.rhyme_ending with
      | Some ending -> Some (Printf.sprintf "韵脚: %s, 一致性: %s" 
                             ending 
                             (if analysis.rhyme_group_consistency then "良好" else "不佳"))
      | None -> Some "未检测到韵脚"
    in
    
    let suggestions = 
      if not has_rhyme_ending then ["建议添加韵脚字符"]
      else if not analysis.rhyme_group_consistency then ["建议保持韵组一致性"]
      else []
    in
    
    {
      dimension;
      score;
      max_score = 1.0;
      details;
      confidence = 0.9;
      suggestions;
    }

  let is_applicable _context = true
end

(** 声调评价器 *)
module ToneEvaluator : EVALUATOR = struct
  let dimension = Tone
  let description = "基于平仄规律的声调评价"
  let weight = 0.15

  let evaluate context =
    let analysis = context.rhythm_analysis in
    let pattern = analysis.rhyme_pattern in
    
    (* 简单的平仄评价：检查平仄交替 *)
    let tone_score = 
      if List.length pattern <= 1 then 0.5
      else
        let rec check_alternation acc = function
          | [] | [_] -> acc
          | a :: b :: rest ->
              let alternates = a <> b in
              check_alternation (acc +. if alternates then 1.0 else 0.0) (b :: rest)
        in
        let alternation_count = check_alternation 0.0 pattern in
        let max_alternations = float_of_int (List.length pattern - 1) in
        if max_alternations > 0.0 then alternation_count /. max_alternations else 0.5
    in
    
    let details = Some (Printf.sprintf "声调模式长度: %d, 平仄交替度: %.2f" 
                        (List.length pattern) tone_score) in
    
    let suggestions = 
      if tone_score < 0.5 then ["建议增加平仄变化"] else []
    in
    
    {
      dimension;
      score = tone_score;
      max_score = 1.0;
      details;
      confidence = 0.7;
      suggestions;
    }

  let is_applicable context = 
    List.length context.rhythm_analysis.rhyme_pattern > 0
end

(** 节奏评价器 *)
module RhythmEvaluator : EVALUATOR = struct
  let dimension = Rhythm
  let description = "基于字符数量和节奏感的节奏评价"
  let weight = 0.15

  let evaluate context =
    let char_count = List.length context.rhythm_analysis.characters in
    
    (* 传统诗词长度评价 *)
    let length_score = 
      match char_count with
      | 5 | 7 -> 1.0      (* 五言、七言最佳 *)
      | 4 | 6 | 8 -> 0.8  (* 四言、六言、八言较好 *)
      | 3 | 9 -> 0.6      (* 三言、九言一般 *)
      | _ when char_count > 10 -> 0.3  (* 过长 *)
      | _ -> 0.4          (* 其他情况 *)
    in
    
    let details = Some (Printf.sprintf "字符数: %d" char_count) in
    
    let suggestions = 
      if char_count < 3 then ["诗句过短，建议增加字数"]
      else if char_count > 10 then ["诗句过长，建议精简"]
      else if char_count <> 5 && char_count <> 7 then ["建议使用五言或七言格式"]
      else []
    in
    
    {
      dimension;
      score = length_score;
      max_score = 1.0;
      details;
      confidence = 0.8;
      suggestions;
    }

  let is_applicable _context = true
end

(** 多句一致性评价器 *)
module ConsistencyEvaluator : EVALUATOR = struct
  let dimension = Overall
  let description = "基于多句韵律一致性的整体评价"
  let weight = 0.20

  let evaluate context =
    match context.multi_analysis with
    | None -> 
        (* 单句情况，给予中等评分 *)
        {
          dimension;
          score = 0.6;
          max_score = 1.0;
          details = Some "单句诗词，无法评价整体一致性";
          confidence = 0.5;
          suggestions = ["建议提供完整诗词进行综合评价"];
        }
    | Some multi ->
        let consistency_score = multi.consistency_score in
        let quality_score = multi.overall_quality in
        let combined_score = (consistency_score +. quality_score) /. 2.0 in
        
        let details = Some (Printf.sprintf 
          "一致性: %.2f, 整体质量: %.2f, 诗句数: %d" 
          consistency_score quality_score (List.length multi.verses)) in
        
        let suggestions = 
          if consistency_score < 0.5 then ["建议保持各句韵律一致"]
          else if quality_score < 0.5 then ["建议提升单句韵律质量"]
          else if combined_score > 0.8 then ["韵律质量优秀！"]
          else []
        in
        
        {
          dimension;
          score = combined_score;
          max_score = 1.0;
          details;
          confidence = 0.9;
          suggestions;
        }

  let is_applicable _context = true
end

(** {1 评价引擎状态和管理} *)

(** 评价器注册表 *)
type evaluator_registry = {
  evaluators: (evaluation_dimension * (module EVALUATOR)) list;
  weights: (evaluation_dimension * float) list;
}

(** 艺术性评价引擎状态 *)
type artistic_evaluator_state = {
  registry: evaluator_registry;
  rhythm_analyzer: analyzer_state;
  evaluation_cache: (string, comprehensive_evaluation) Hashtbl.t;
  last_evaluation_time: float;
}

(** 评价引擎异常 *)
exception ArtisticEvaluatorError of string

(** 初始化评价引擎 *)
let initialize_evaluator rhythm_analyzer =
  let registry = {
    evaluators = [
      (Rhyme, (module RhymeEvaluator));
      (Tone, (module ToneEvaluator)); 
      (Rhythm, (module RhythmEvaluator));
      (Overall, (module ConsistencyEvaluator));
    ];
    weights = [
      (Rhyme, 0.25);
      (Tone, 0.15);
      (Rhythm, 0.15);
      (Overall, 0.20);
    ];
  } in
  
  {
    registry;
    rhythm_analyzer;
    evaluation_cache = Hashtbl.create 200;
    last_evaluation_time = Unix.time ();
  }

(** 注册新的评价器 *)
let register_evaluator dimension evaluator_module evaluator_state =
  let updated_evaluators = 
    (dimension, evaluator_module) :: evaluator_state.registry.evaluators
  in
  let module E = (val evaluator_module : EVALUATOR) in
  let updated_weights = 
    (dimension, E.weight) :: evaluator_state.registry.weights
  in
  let updated_registry = {
    evaluators = updated_evaluators;
    weights = updated_weights;
  } in
  { evaluator_state with registry = updated_registry }

(** {1 评价执行函数} *)

(** 创建评价上下文 *)
let create_evaluation_context verse verses rhythm_analyzer =
  let rhythm_analysis = analyze_verse_rhythm verse rhythm_analyzer in
  let multi_analysis = 
    if List.length verses > 1 then
      Some (analyze_multi_verse_rhythm verses rhythm_analyzer)
    else
      None
  in
  
  {
    verse;
    verses;
    rhythm_analysis;
    multi_analysis;
    metadata = [];
  }

(** 执行单个维度评价 *)
let evaluate_dimension dimension context evaluator_state =
  try
    let evaluators = evaluator_state.registry.evaluators in
    match List.find_opt (fun (dim, _) -> dim = dimension) evaluators with
    | Some (_, evaluator_module) ->
        let module E = (val evaluator_module : EVALUATOR) in
        if E.is_applicable context then
          Some (E.evaluate context)
        else
          None
    | None -> None
  with
  | exn -> raise (ArtisticEvaluatorError ("评价执行失败: " ^ Printexc.to_string exn))

(** 执行综合评价 *)
let evaluate_comprehensive verse verses evaluator_state =
  let cache_key = String.concat "|" (verse :: verses) in
  
  (* 检查缓存 *)
  match Hashtbl.find_opt evaluator_state.evaluation_cache cache_key with
  | Some result -> result
  | None ->
      try
        let context = create_evaluation_context verse verses evaluator_state.rhythm_analyzer in
        
        (* 执行各维度评价 *)
        let dimension_eval_results = 
          List.filter_map (fun (dimension, _) ->
            evaluate_dimension dimension context evaluator_state
          ) evaluator_state.registry.evaluators
        in
        
        (* 计算加权综合评分 *)
        let total_weighted_score = 
          List.fold_left (fun acc result ->
            let weight = 
              List.assoc_opt result.dimension evaluator_state.registry.weights
              |> Option.value ~default:0.1
            in
            acc +. (result.score *. weight)
          ) 0.0 dimension_eval_results
        in
        
        let total_weight = 
          List.fold_left (fun acc result ->
            let weight = 
              List.assoc_opt result.dimension evaluator_state.registry.weights
              |> Option.value ~default:0.1
            in
            acc +. weight
          ) 0.0 dimension_eval_results
        in
        
        let overall_score = 
          if total_weight > 0.0 then total_weighted_score /. total_weight else 0.0
        in
        
        (* 计算综合置信度 *)
        let overall_confidence = 
          if List.length dimension_eval_results > 0 then
            List.fold_left (fun acc result -> acc +. result.confidence) 0.0 dimension_eval_results
            /. float_of_int (List.length dimension_eval_results)
          else
            0.0
        in
        
        (* 提取优点和不足 *)
        let strengths = 
          List.filter_map (fun result ->
            if result.score > 0.7 then
              Some (Printf.sprintf "%s表现优秀 (%.2f)" 
                    (match result.dimension with
                     | Rhyme -> "韵律"
                     | Tone -> "声调"
                     | Rhythm -> "节奏"
                     | Overall -> "整体"
                     | _ -> "其他") result.score)
            else None
          ) dimension_eval_results
        in
        
        let weaknesses = 
          List.filter_map (fun result ->
            if result.score < 0.5 then
              Some (Printf.sprintf "%s需要改进 (%.2f)" 
                    (match result.dimension with
                     | Rhyme -> "韵律"
                     | Tone -> "声调"
                     | Rhythm -> "节奏"
                     | Overall -> "整体"
                     | _ -> "其他") result.score)
            else None
          ) dimension_eval_results
        in
        
        (* 汇总建议 *)
        let all_suggestions = 
          List.fold_left (fun (acc : string list) (eval_result : evaluation_result) -> 
            acc @ eval_result.suggestions
          ) [] dimension_eval_results
        in
        
        (* 确定质量等级 *)
        let quality_level = 
          if overall_score >= 0.85 then `Excellent
          else if overall_score >= 0.70 then `Good
          else if overall_score >= 0.50 then `Fair
          else `Poor
        in
        
        let result = {
          context;
          dimension_results = dimension_eval_results;
          overall_score;
          overall_confidence;
          strengths;
          weaknesses;
          suggestions = all_suggestions;
          quality_level;
        } in
        
        (* 缓存结果 *)
        Hashtbl.replace evaluator_state.evaluation_cache cache_key result;
        result
        
      with
      | exn -> raise (ArtisticEvaluatorError ("综合评价失败: " ^ Printexc.to_string exn))

(** {1 工具和统计函数} *)

(** 获取评价器统计信息 *)
let get_evaluator_statistics evaluator_state =
  let cache_size = Hashtbl.length evaluator_state.evaluation_cache in
  let registered_evaluators = List.length evaluator_state.registry.evaluators in
  let rhythm_stats = get_analyzer_statistics evaluator_state.rhythm_analyzer in
  
  ("评价缓存大小", string_of_int cache_size) ::
  ("注册评价器数量", string_of_int registered_evaluators) ::
  ("上次评价时间", string_of_float evaluator_state.last_evaluation_time) ::
  rhythm_stats

(** 清理评价器缓存 *)
let clear_evaluator_cache evaluator_state =
  Hashtbl.clear evaluator_state.evaluation_cache;
  { evaluator_state with last_evaluation_time = Unix.time () }

(** 格式化评价结果 *)
let format_evaluation_result result =
  let dimension_str = 
    match result.dimension with
    | Rhyme -> "韵律"
    | Tone -> "声调"
    | Rhythm -> "节奏"
    | Meter -> "格律"
    | Parallelism -> "对仗"
    | Imagery -> "意象"
    | Elegance -> "雅致"
    | Content -> "内容"
    | Form -> "形式"
    | Overall -> "整体"
  in
  
  let score_str = Printf.sprintf "%.2f/%.2f" result.score result.max_score in
  let details_str = Option.value result.details ~default:"" in
  let suggestions_str = String.concat "; " result.suggestions in
  
  Printf.sprintf "%s: %s (置信度: %.2f)\n详情: %s\n建议: %s" 
    dimension_str score_str result.confidence details_str suggestions_str

(** 格式化综合评价结果 *)
let format_comprehensive_evaluation evaluation =
  let quality_str = 
    match evaluation.quality_level with
    | `Excellent -> "优秀"
    | `Good -> "良好"
    | `Fair -> "一般"
    | `Poor -> "较差"
  in
  
  let eval_results_str = 
    List.map format_evaluation_result evaluation.dimension_results
    |> String.concat "\n---\n"
  in
  
  let strengths_str = String.concat "; " evaluation.strengths in
  let weaknesses_str = String.concat "; " evaluation.weaknesses in
  let suggestions_str = String.concat "; " evaluation.suggestions in
  
  Printf.sprintf 
    "=== 诗词艺术性综合评价 ===\n整体评分: %.2f (质量等级: %s)\n置信度: %.2f\n\n%s\n\n优点: %s\n不足: %s\n建议: %s"
    evaluation.overall_score quality_str evaluation.overall_confidence
    eval_results_str strengths_str weaknesses_str suggestions_str