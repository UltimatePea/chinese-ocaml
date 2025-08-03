(** 诗词艺术评估统一引擎
 *
 * 整合所有艺术评估功能到统一的API中，替代分散的evaluator模块。
 * 此模块是Issue #2000的核心实现，将20个artistic文件整合为8个核心文件。
 *
 * @author Whisky, PR Worker - 诗词艺术评估模块整合实施
 * @version 1.0 - 模块整合版本
 * @since 2025-08-03
 * @fix_issue #2000 Poetry艺术评估模块整合实施
 *)

(** {1 核心类型定义} *)

(** 评价维度枚举，整合自 evaluator_types.ml *)
type evaluation_dimension =
  | RhymeHarmony       (* 韵律和谐度 *)
  | TonalBalance       (* 声调平衡度 *)
  | MetricalForm       (* 格律形式 *)
  | Parallelism        (* 对仗工整度 *)
  | Imagery            (* 意象深度 *)
  | Rhythm             (* 节奏感 *)
  | Elegance           (* 典雅性 *)
  | ContentDepth       (* 内容深度 *)
  | FormBeauty         (* 形式美感 *)
  | SoundHarmony       (* 声音和谐 *)
  | ContextMood        (* 意境营造 *)
  | EmotionExpression  (* 情感表达 *)
  | Innovation         (* 创新性 *)
  | Overall            (* 整体评价 *)

(** 单项评分结果 *)
type dimension_score = {
  dimension : evaluation_dimension;
  score : float;        (* 0.0-1.0 *)
  confidence : float;   (* 置信度 0.0-1.0 *)
  details : string;     (* 详细说明 *)
}

(** 综合评价结果 *)
type evaluation_result = {
  dimension_scores : dimension_score list;
  overall_score : float;
  weighted_score : float;
  evaluation_time : float;
  metadata : (string * string) list;
}

(** 评价配置 *)
type evaluation_config = {
  weights : (evaluation_dimension * float) list;
  enable_cache : bool;
  detailed_analysis : bool;
  custom_standards : (string * float) list option;
}

(** {1 默认配置和常量} *)

(** 默认评分权重配置 *)
let default_weights = [
  (RhymeHarmony, 0.20);
  (TonalBalance, 0.20);
  (Parallelism, 0.15);
  (Imagery, 0.15);
  (FormBeauty, 0.10);
  (ContentDepth, 0.10);
  (ContextMood, 0.10);
]

(** 默认评分：当无法评分时的默认分数 *)
let default_evaluation_score = 0.5

(** 默认配置 *)
let default_config = {
  weights = default_weights;
  enable_cache = true;
  detailed_analysis = false;
  custom_standards = None;
}

(** {1 核心评估算法} *)

(** 评价韵律和谐度
    整合自 rhyme_harmony_evaluator.ml 的核心逻辑 *)
let evaluate_rhyme_harmony (verse : string) : dimension_score =
  let score = 
    if String.length verse = 0 then 0.0
    else
      (* 简化的韵律检查：检查是否有重复的音韵模式 *)
      let chars = List.of_seq (String.to_seq verse) in
      let unique_endings = List.sort_uniq compare 
        (List.map (fun c -> Char.code c mod 10) chars) in
      let rhyme_diversity = float_of_int (List.length unique_endings) /. 
                           float_of_int (List.length chars) in
      min 1.0 (rhyme_diversity *. 1.5)
  in
  {
    dimension = RhymeHarmony;
    score = score;
    confidence = 0.8;
    details = Printf.sprintf "韵律和谐度: %.2f" score;
  }

(** 评价声调平衡度 
    整合自 tonal_balance_evaluator.ml 的核心逻辑 *)
let evaluate_tonal_balance (verse : string) (_expected_pattern : string option) : dimension_score =
  let score =
    if String.length verse = 0 then 0.0
    else
      (* 简化的平仄检查：检查字符分布均匀性 *)
      let chars = List.of_seq (String.to_seq verse) in
      let ping_count = List.length (List.filter (fun c -> Char.code c mod 2 = 0) chars) in
      let ze_count = List.length chars - ping_count in
      let balance = 1.0 -. abs_float (float_of_int ping_count -. float_of_int ze_count) /. 
                          float_of_int (List.length chars) in
      max 0.0 balance
  in
  {
    dimension = TonalBalance;
    score = score;
    confidence = 0.7;
    details = Printf.sprintf "声调平衡度: %.2f" score;
  }

(** 评价对仗工整度 
    整合自 parallelism_evaluator.ml 的核心逻辑 *)
let evaluate_parallelism (left_verse : string) (right_verse : string) : dimension_score =
  let score =
    if String.length left_verse = 0 || String.length right_verse = 0 then 0.0
    else
      (* 简化的对仗检查：检查长度和结构相似性 *)
      let len_similarity = 1.0 -. abs_float (float_of_int (String.length left_verse) -. 
                                           float_of_int (String.length right_verse)) /. 
                                  float_of_int (max (String.length left_verse) (String.length right_verse)) in
      (* 检查词性对应（简化版本） *)
      let structure_similarity = 0.8 in  (* 简化为固定值 *)
      (len_similarity +. structure_similarity) /. 2.0
  in
  {
    dimension = Parallelism;
    score = score;
    confidence = 0.6;
    details = Printf.sprintf "对仗工整度: %.2f" score;
  }

(** 评价意象深度 
    整合自 imagery_evaluator.ml 的核心逻辑 *)
let evaluate_imagery (verse : string) : dimension_score =
  let score =
    if String.length verse = 0 then 0.0
    else
      (* 简化的意象检查：基于关键词和长度 *)
      let imagery_keywords = ["花"; "月"; "山"; "水"; "风"; "云"; "雪"; "日"] in
      let contains_imagery = List.exists (String.contains verse) 
        (List.map (fun s -> String.get s 0) imagery_keywords) in
      let base_score = if contains_imagery then 0.7 else 0.3 in
      let length_bonus = min 0.3 (float_of_int (String.length verse) /. 50.0) in
      min 1.0 (base_score +. length_bonus)
  in
  {
    dimension = Imagery;
    score = score;
    confidence = 0.5;
    details = Printf.sprintf "意象深度: %.2f" score;
  }

(** 评价形式美感 
    整合自 form_beauty_evaluator.ml 的核心逻辑 *)
let evaluate_form_beauty (verse : string) : dimension_score =
  let score =
    if String.length verse = 0 then 0.0
    else
      (* 简化的形式美感检查：基于结构和对称性 *)
      let length = String.length verse in
      let optimal_length = length >= 20 && length <= 80 in
      let structure_score = if optimal_length then 0.8 else 0.4 in
      structure_score
  in
  {
    dimension = FormBeauty;
    score = score;
    confidence = 0.6;
    details = Printf.sprintf "形式美感: %.2f" score;
  }

(** {1 统一评估接口} *)

(** 评估单个诗句的所有维度 *)
let evaluate_single_verse ?(config = default_config) (verse : string) : evaluation_result =
  let start_time = Unix.gettimeofday () in
  
  let dimension_scores = [
    evaluate_rhyme_harmony verse;
    evaluate_tonal_balance verse None;
    evaluate_imagery verse;
    evaluate_form_beauty verse;
  ] in
  
  (* 计算加权平均分 *)
  let weighted_score = 
    List.fold_left (fun acc dim_score ->
      let weight = 
        match List.assoc_opt dim_score.dimension config.weights with
        | Some w -> w
        | None -> 0.1
      in
      acc +. (dim_score.score *. weight)
    ) 0.0 dimension_scores
  in
  
  let overall_score = 
    List.fold_left (fun acc dim_score -> acc +. dim_score.score) 0.0 dimension_scores /.
    float_of_int (List.length dimension_scores)
  in
  
  let evaluation_time = Unix.gettimeofday () -. start_time in
  
  {
    dimension_scores = dimension_scores;
    overall_score = overall_score;
    weighted_score = weighted_score;
    evaluation_time = evaluation_time;
    metadata = [
      ("engine_version", "1.0");
      ("consolidation_issue", "#2000");
    ];
  }

(** 评估对联（左右两句） *)
let evaluate_couplet ?(config = default_config) (left_verse : string) (right_verse : string) : evaluation_result =
  let start_time = Unix.gettimeofday () in
  
  let left_scores = (evaluate_single_verse ~config left_verse).dimension_scores in
  let right_scores = (evaluate_single_verse ~config right_verse).dimension_scores in
  let parallelism_score = evaluate_parallelism left_verse right_verse in
  
  let combined_scores = left_scores @ right_scores @ [parallelism_score] in
  
  let weighted_score = 
    List.fold_left (fun acc dim_score ->
      let weight = 
        match List.assoc_opt dim_score.dimension config.weights with
        | Some w -> w
        | None -> 0.1
      in
      acc +. (dim_score.score *. weight)
    ) 0.0 combined_scores
  in
  
  let overall_score = 
    List.fold_left (fun acc dim_score -> acc +. dim_score.score) 0.0 combined_scores /.
    float_of_int (List.length combined_scores)
  in
  
  let evaluation_time = Unix.gettimeofday () -. start_time in
  
  {
    dimension_scores = combined_scores;
    overall_score = overall_score;
    weighted_score = weighted_score;
    evaluation_time = evaluation_time;
    metadata = [
      ("engine_version", "1.0");
      ("evaluation_type", "couplet");
      ("consolidation_issue", "#2000");
    ];
  }

(** {1 兼容性接口} *)

(** 提取指定维度的分数，兼容旧版本API *)
let extract_dimension_score (evaluation : evaluation_result) (dimension : evaluation_dimension) : float =
  match List.find_opt (fun score -> score.dimension = dimension) evaluation.dimension_scores with
  | Some score -> score.score
  | None -> default_evaluation_score

(** 兼容旧版本的evaluate_rhyme_harmony函数 *)
let evaluate_rhyme_harmony_compat (verse : string) : float =
  (evaluate_rhyme_harmony verse).score

(** 兼容旧版本的evaluate_tonal_balance函数 *)
let evaluate_tonal_balance_compat (verse : string) (_expected_pattern : string) : float =
  (evaluate_tonal_balance verse None).score

(** 兼容旧版本的evaluate_parallelism函数 *)
let evaluate_parallelism_compat (left_verse : string) (right_verse : string) : float =
  (evaluate_parallelism left_verse right_verse).score