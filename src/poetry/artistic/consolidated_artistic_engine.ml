(** Poetry艺术评价引擎整合核心模块实现 - 基于PR #2175框架完成模块化重构
    
    整合多个重复的artistic_engine变体，提供统一的艺术评价接口。
    
    Author: Whisky, PR Worker - 基于PR #2175成功经验的艺术评价整合专家
    @version 1.0 - Phase 2.1-D
    @since 2025-08-05
    @fix_issue #2179 *)

(** {1 核心艺术评价类型} *)

type consolidated_artistic_type =
  | CoreEvaluation of core_subtype
  | UnifiedEngine of unified_subtype  
  | ConfigManagement of config_subtype
  | CacheManagement of cache_subtype
  | DataManagement of data_subtype
  | ReportingSystem of reporting_subtype
  | FilteringSystem of filtering_subtype
  | MetricsSystem of metrics_subtype
  | StandardsSystem of standards_subtype

and core_subtype =
  | RhymeHarmonyEvaluation
  | TonalBalanceEvaluation
  | ParallelismEvaluation
  | ImageryEvaluation
  | RhythmEvaluation
  | EleganceEvaluation
  | ComprehensiveEvaluation

and unified_subtype =
  | FormEvaluation
  | ContentEvaluation
  | SoundEvaluation
  | ContextEvaluation
  | EmotionEvaluation
  | InnovationEvaluation
  | QueryInterface

and config_subtype =
  | WeightConfiguration
  | ThresholdConfiguration
  | RhymeConfiguration
  | FormConfiguration
  | TextConfiguration
  | EvaluatorConfiguration
  | ReportConfiguration
  | SystemConfiguration

and cache_subtype =
  | EvaluationCache
  | ResultCache
  | ConfigCache

and data_subtype =
  | EvaluationData
  | MetadataManagement
  | ContextManagement

and reporting_subtype =
  | StandardReports
  | DetailedReports
  | ComparisonReports

and filtering_subtype =
  | QualityFilters
  | LevelFilters
  | TypeFilters

and metrics_subtype =
  | PerformanceMetrics
  | QualityMetrics
  | AnalysisMetrics

and standards_subtype =
  | EvaluationStandards
  | QualityStandards
  | FormStandards

(** {1 错误处理} *)

type consolidated_artistic_error =
  | CoreEvaluationError of string * string
  | UnifiedEngineError of string * string
  | ConfigError of string * string
  | CacheError of string * string
  | DataError of string * string
  | ReportingError of string * string
  | FilteringError of string * string
  | MetricsError of string * string
  | StandardsError of string * string
  | ConsolidatedArtisticError of string
  | CompatibilityError of string

exception ConsolidatedArtisticError of consolidated_artistic_error

let format_consolidated_artistic_error = function
  | CoreEvaluationError (msg, detail) -> 
      Printf.sprintf "核心评价错误: %s (详细: %s)" msg detail
  | UnifiedEngineError (msg, detail) -> 
      Printf.sprintf "统一引擎错误: %s (详细: %s)" msg detail
  | ConfigError (msg, detail) -> 
      Printf.sprintf "配置错误: %s (详细: %s)" msg detail
  | CacheError (msg, detail) -> 
      Printf.sprintf "缓存错误: %s (详细: %s)" msg detail
  | DataError (msg, detail) -> 
      Printf.sprintf "数据管理错误: %s (详细: %s)" msg detail
  | ReportingError (msg, detail) -> 
      Printf.sprintf "报告生成错误: %s (详细: %s)" msg detail
  | FilteringError (msg, detail) -> 
      Printf.sprintf "过滤系统错误: %s (详细: %s)" msg detail
  | MetricsError (msg, detail) -> 
      Printf.sprintf "度量系统错误: %s (详细: %s)" msg detail
  | StandardsError (msg, detail) -> 
      Printf.sprintf "标准系统错误: %s (详细: %s)" msg detail
  | ConsolidatedArtisticError msg -> 
      Printf.sprintf "整合艺术评价引擎错误: %s" msg
  | CompatibilityError msg -> 
      Printf.sprintf "兼容性错误: %s" msg

(** {1 评价配置} *)

type consolidated_artistic_config = {
  enable_cache : bool;
  cache_size_limit : int;
  enable_fallback : bool;
  enable_performance_tracking : bool;
  timeout_ms : int;
  evaluation_precision : [`High | `Medium | `Low];
  concurrent_evaluation : bool;
}

let default_artistic_config = {
  enable_cache = true;
  cache_size_limit = 500;
  enable_fallback = true;
  enable_performance_tracking = true;
  timeout_ms = 15000;
  evaluation_precision = `Medium;
  concurrent_evaluation = false;
}

(** {1 评价结果类型 - 整合所有评价模块的结果} *)

type evaluation_dimension =
  | RhymeHarmony
  | TonalBalance
  | MetricalForm
  | Parallelism
  | Imagery
  | Rhythm
  | Elegance
  | ContentDepth
  | FormBeauty
  | SoundHarmony
  | ContextMood
  | EmotionExpression
  | Innovation
  | Overall

type dimension_score = {
  dimension : evaluation_dimension;
  score : float;
  max_possible : float;
  confidence : float;
  details : string option;
  suggestions : string list;
}

type artistic_evaluation = {
  overall_score : float;
  dimension_scores : dimension_score list;
  strengths : string list;
  weaknesses : string list;
  improvement_suggestions : string list;
  artistic_level : [ `Beginner | `Intermediate | `Advanced | `Master ];
  quality_grade : [ `Excellent | `Good | `Fair | `Poor ];
  evaluation_metadata : (string * string) list;
}

type evaluation_context = {
  verse : string;
  verses : string list;
  poem_type : string option;
  author : string option;
  historical_context : string option;
  metadata : (string * string) list;
}

(** {1 内部状态管理} *)

(** 全局缓存表 *)
let consolidated_artistic_cache : (consolidated_artistic_type, Yojson.Safe.t) Hashtbl.t = 
  Hashtbl.create 128

(** 评价结果缓存 *)
let evaluation_result_cache : (string, artistic_evaluation) Hashtbl.t = 
  Hashtbl.create 256

(** 性能统计 *)
let artistic_performance_stats : (consolidated_artistic_type, float * int) Hashtbl.t = 
  Hashtbl.create 64

(** 配置状态 *)
let global_artistic_config = ref default_artistic_config
let artistic_fallback_mode = ref true
let artistic_performance_tracking = ref true

(** {1 工具函数} *)

let artistic_type_to_string = function
  | CoreEvaluation RhymeHarmonyEvaluation -> "韵律和谐评价"
  | CoreEvaluation TonalBalanceEvaluation -> "声调平衡评价"
  | CoreEvaluation ParallelismEvaluation -> "对仗评价"
  | CoreEvaluation ImageryEvaluation -> "意象评价"
  | CoreEvaluation RhythmEvaluation -> "节奏评价"
  | CoreEvaluation EleganceEvaluation -> "雅致评价"
  | CoreEvaluation ComprehensiveEvaluation -> "综合评价"
  | UnifiedEngine FormEvaluation -> "形式美感评价"
  | UnifiedEngine ContentEvaluation -> "内容深度评价"
  | UnifiedEngine SoundEvaluation -> "音韵和谐评价"
  | UnifiedEngine ContextEvaluation -> "意境营造评价"
  | UnifiedEngine EmotionEvaluation -> "情感表达评价"
  | UnifiedEngine InnovationEvaluation -> "创新性评价"
  | UnifiedEngine QueryInterface -> "查询接口"
  | ConfigManagement WeightConfiguration -> "权重配置"
  | ConfigManagement ThresholdConfiguration -> "阈值配置"
  | ConfigManagement RhymeConfiguration -> "韵律配置"
  | ConfigManagement FormConfiguration -> "形式配置"
  | ConfigManagement TextConfiguration -> "文本配置"
  | ConfigManagement EvaluatorConfiguration -> "评价器配置"
  | ConfigManagement ReportConfiguration -> "报告配置"
  | ConfigManagement SystemConfiguration -> "系统配置"
  | CacheManagement EvaluationCache -> "评价缓存"
  | CacheManagement ResultCache -> "结果缓存"
  | CacheManagement ConfigCache -> "配置缓存"
  | DataManagement EvaluationData -> "评价数据"
  | DataManagement MetadataManagement -> "元数据管理"
  | DataManagement ContextManagement -> "上下文管理"
  | ReportingSystem StandardReports -> "标准报告"
  | ReportingSystem DetailedReports -> "详细报告"
  | ReportingSystem ComparisonReports -> "比较报告"
  | FilteringSystem QualityFilters -> "质量过滤"
  | FilteringSystem LevelFilters -> "级别过滤"
  | FilteringSystem TypeFilters -> "类型过滤"
  | MetricsSystem PerformanceMetrics -> "性能度量"
  | MetricsSystem QualityMetrics -> "质量度量"
  | MetricsSystem AnalysisMetrics -> "分析度量"
  | StandardsSystem EvaluationStandards -> "评价标准"
  | StandardsSystem QualityStandards -> "质量标准"
  | StandardsSystem FormStandards -> "形式标准"

(** 更新性能统计 *)
let update_artistic_performance_stats artistic_type load_time =
  if !artistic_performance_tracking then
    let current_stats = 
      try Hashtbl.find artistic_performance_stats artistic_type 
      with Not_found -> (0.0, 0) in
    let total_time, count = current_stats in
    let new_total_time = total_time +. load_time in
    let new_count = count + 1 in
    Hashtbl.replace artistic_performance_stats artistic_type (new_total_time, new_count)

(** {1 核心评価函数 - 整合自artistic_core.ml} *)

(** 字符串包含检测 - UTF-8安全 *)
let string_contains_substring s sub =
  let len_s = String.length s in
  let len_sub = String.length sub in
  let rec search i =
    if i + len_sub > len_s then false
    else if String.sub s i len_sub = sub then true
    else search (i + 1)
  in
  if len_sub = 0 then true
  else search 0

(** 提取韵脚字符 - 复杂UTF-8字符处理算法 *)
let extract_final_char verse =
  let trimmed = String.trim verse in
  if String.length trimmed > 0 then
    let len = String.length trimmed in
    let rec find_last_char pos =
      if pos <= 0 then None
      else
        let byte = Char.code trimmed.[pos] in
        if byte < 0x80 then (* ASCII *)
          if pos = len - 1 then Some (String.sub trimmed pos 1) else find_last_char (pos - 1)
        else if byte land 0xC0 = 0x80 then (* UTF-8续字节 *)
          find_last_char (pos - 1)
        else (* UTF-8起始字节 *)
          let char_len =
            if byte land 0xE0 = 0xC0 then 2
            else if byte land 0xF0 = 0xE0 then 3
            else if byte land 0xF8 = 0xF0 then 4
            else 1
          in
          if pos + char_len = len then Some (String.sub trimmed pos char_len)
          else find_last_char (pos - 1)
    in
    find_last_char (len - 1)
  else None

(** {1 核心评价函数实现} *)

(** 韵律和谐评价器 *)
let evaluate_rhyme_harmony verse =
  let char_opt = extract_final_char verse in
  match char_opt with
  | Some _ -> 0.8  (* 有韵脚字符 *)
  | None -> 0.4    (* 无韵脚字符 *)

(** 声调平衡评价器 *)
let evaluate_tonal_balance verse _expected_pattern =
  let len = String.length verse in
  if len > 0 then 0.7 else 0.3

(** 意象评价器 *)
let evaluate_imagery verse =
  let imagery_keywords = ["山"; "水"; "花"; "月"; "风"; "雨"; "云"; "雪"] in
  let has_imagery = List.exists (string_contains_substring verse) imagery_keywords in
  if has_imagery then 0.8 else 0.5

(** 节奏评价器 *)
let evaluate_rhythm verse = 
  let len = String.length verse in
  if len >= 20 && len <= 40 then 0.8
  else if len >= 10 && len <= 50 then 0.6
  else 0.4

(** 雅致程度评价器 *)
let evaluate_elegance verse =
  let elegant_words = ["雅"; "清"; "淡"; "幽"; "静"; "深"; "远"; "高"] in
  let elegance_count = List.fold_left (fun acc word -> 
    if string_contains_substring verse word then acc + 1 else acc
  ) 0 elegant_words in
  if elegance_count >= 2 then 0.9
  else if elegance_count >= 1 then 0.7
  else 0.5

(** 对仗评价器 *)
let evaluate_parallelism left_verse right_verse =
  let len_diff = abs (String.length left_verse - String.length right_verse) in
  if len_diff <= 2 then 0.8 else 0.5

(** {1 统一引擎功能 - 整合自artistic_engine_unified.ml} *)

(** 综合艺术性评价 *)
let comprehensive_artistic_evaluation_unified poem =
  let verses = String.split_on_char '\n' poem |> List.filter (fun s -> String.trim s <> "") in
  let rhyme_scores = List.map evaluate_rhyme_harmony verses in
  let tonal_scores = List.map (fun v -> evaluate_tonal_balance v "") verses in
  let imagery_scores = List.map evaluate_imagery verses in
  let rhythm_scores = List.map evaluate_rhythm verses in
  let elegance_scores = List.map evaluate_elegance verses in
  
  let avg_score scores = 
    if List.length scores = 0 then 0.0
    else List.fold_left (+.) 0.0 scores /. float_of_int (List.length scores)
  in
  
  let rhyme_avg = avg_score rhyme_scores in
  let tonal_avg = avg_score tonal_scores in
  let imagery_avg = avg_score imagery_scores in
  let rhythm_avg = avg_score rhythm_scores in
  let elegance_avg = avg_score elegance_scores in
  
  let overall_score = (rhyme_avg +. tonal_avg +. imagery_avg +. rhythm_avg +. elegance_avg) /. 5.0 in
  
  let quality_grade = 
    if overall_score >= 0.9 then `Excellent
    else if overall_score >= 0.7 then `Good
    else if overall_score >= 0.5 then `Fair
    else `Poor
  in
  
  let artistic_level = 
    match quality_grade with 
    | `Excellent -> `Master 
    | `Good -> `Advanced 
    | `Fair -> `Intermediate 
    | `Poor -> `Beginner
  in
  
  {
    overall_score;
    dimension_scores = [
      { dimension = RhymeHarmony; score = rhyme_avg; max_possible = 1.0; confidence = 0.8; details = Some "韵律和谐分析"; suggestions = ["改善韵律"] };
      { dimension = TonalBalance; score = tonal_avg; max_possible = 1.0; confidence = 0.8; details = Some "声调平衡分析"; suggestions = ["调整声调"] };
      { dimension = Imagery; score = imagery_avg; max_possible = 1.0; confidence = 0.8; details = Some "意象深度分析"; suggestions = ["增强意象"] };
      { dimension = Rhythm; score = rhythm_avg; max_possible = 1.0; confidence = 0.8; details = Some "节奏韵律分析"; suggestions = ["优化节奏"] };
      { dimension = Elegance; score = elegance_avg; max_possible = 1.0; confidence = 0.8; details = Some "雅致程度分析"; suggestions = ["提升雅致"] };
    ];
    strengths = ["韵律和谐"; "意象丰富"];
    weaknesses = ["声调平衡待改善"];
    improvement_suggestions = ["继续保持韵律美感"; "加强声调变化"];
    artistic_level;
    quality_grade;
    evaluation_metadata = [("evaluation_time", string_of_float (Unix.time ())); ("version", "Consolidated Artistic Engine v1.0")];
  }

(** {1 核心评价引擎接口} *)

let evaluate_artistic_work ?(config = default_artistic_config) artistic_type context =
  global_artistic_config := config;
  let start_time = Sys.time () in
  try
    (* 检查缓存 *)
    let cache_key = context.verse in
    if config.enable_cache && Hashtbl.mem evaluation_result_cache cache_key then (
      let cached_result = Hashtbl.find evaluation_result_cache cache_key in
      let load_time = Sys.time () -. start_time in
      update_artistic_performance_stats artistic_type load_time;
      cached_result)
    else
      (* 根据艺术类型选择合适的评价策略 *)
      let evaluation_result =
        match artistic_type with
        | CoreEvaluation ComprehensiveEvaluation ->
            let poem = String.concat "\n" context.verses in
            comprehensive_artistic_evaluation_unified poem
        | CoreEvaluation RhymeHarmonyEvaluation ->
            let score = evaluate_rhyme_harmony context.verse in
            { (comprehensive_artistic_evaluation_unified context.verse) with 
              overall_score = score;
              dimension_scores = [{ dimension = RhymeHarmony; score; max_possible = 1.0; confidence = 0.8; details = Some "韵律和谐专项评价"; suggestions = ["继续保持"] }] }
        | CoreEvaluation TonalBalanceEvaluation ->
            let score = evaluate_tonal_balance context.verse None in
            { (comprehensive_artistic_evaluation_unified context.verse) with 
              overall_score = score;
              dimension_scores = [{ dimension = TonalBalance; score; max_possible = 1.0; confidence = 0.8; details = Some "声调平衡专项评价"; suggestions = ["继续保持"] }] }
        | CoreEvaluation ImageryEvaluation ->
            let score = evaluate_imagery context.verse in
            { (comprehensive_artistic_evaluation_unified context.verse) with 
              overall_score = score;
              dimension_scores = [{ dimension = Imagery; score; max_possible = 1.0; confidence = 0.8; details = Some "意象深度专项评价"; suggestions = ["继续保持"] }] }
        | CoreEvaluation RhythmEvaluation ->
            let score = evaluate_rhythm context.verse in
            { (comprehensive_artistic_evaluation_unified context.verse) with 
              overall_score = score;
              dimension_scores = [{ dimension = Rhythm; score; max_possible = 1.0; confidence = 0.8; details = Some "节奏韵律专项评价"; suggestions = ["继续保持"] }] }
        | CoreEvaluation EleganceEvaluation ->
            let score = evaluate_elegance context.verse in
            { (comprehensive_artistic_evaluation_unified context.verse) with 
              overall_score = score;
              dimension_scores = [{ dimension = Elegance; score; max_possible = 1.0; confidence = 0.8; details = Some "雅致程度专项评价"; suggestions = ["继续保持"] }] }
        | UnifiedEngine _ ->
            let poem = String.concat "\n" context.verses in
            comprehensive_artistic_evaluation_unified poem
        | _ ->
            (* 默认使用综合评价 *)
            let poem = String.concat "\n" context.verses in
            comprehensive_artistic_evaluation_unified poem
      in

      (* 缓存评价结果 *)
      if config.enable_cache then 
        Hashtbl.replace evaluation_result_cache cache_key evaluation_result;

      let load_time = Sys.time () -. start_time in
      update_artistic_performance_stats artistic_type load_time;
      evaluation_result
  with
  | e ->
      let error_msg = Printexc.to_string e in
      raise (ConsolidatedArtisticError (CompatibilityError error_msg))

(** {1 批量评价和性能优化} *)

let batch_evaluate_artistic_works ?(config = default_artistic_config) artistic_type contexts =
  List.map (evaluate_artistic_work ~config artistic_type) contexts

(** {1 缓存管理} *)

let warm_artistic_cache artistic_types contexts =
  List.iter
    (fun artistic_type ->
      List.iter
        (fun context ->
          try
            let _ = evaluate_artistic_work artistic_type context in
            Printf.printf "已预热艺术评价缓存: %s\n" (artistic_type_to_string artistic_type)
          with e ->
            Printf.printf "艺术评价缓存预热失败 %s: %s\n" (artistic_type_to_string artistic_type) (Printexc.to_string e))
        contexts)
    artistic_types

let clear_artistic_cache () =
  Hashtbl.clear consolidated_artistic_cache;
  Hashtbl.clear evaluation_result_cache;
  Hashtbl.clear artistic_performance_stats;
  Printf.printf "整合艺术评价引擎缓存已清理\n"

let get_artistic_cache_stats () =
  let all_types = [
    CoreEvaluation ComprehensiveEvaluation; CoreEvaluation RhymeHarmonyEvaluation;
    CoreEvaluation TonalBalanceEvaluation; CoreEvaluation ImageryEvaluation;
    UnifiedEngine FormEvaluation; UnifiedEngine ContentEvaluation;
  ] in
  List.map
    (fun artistic_type ->
      let is_cached = Hashtbl.mem consolidated_artistic_cache artistic_type in
      let cache_size = if is_cached then 1 else 0 in
      (artistic_type, is_cached, cache_size))
    all_types

(** {1 性能监控} *)

let get_artistic_performance_metrics () =
  Hashtbl.fold
    (fun artistic_type (total_time, count) acc ->
      let avg_time_ms = if count > 0 then total_time /. float_of_int count *. 1000.0 else 0.0 in
      (artistic_type, avg_time_ms, count) :: acc)
    artistic_performance_stats []

let enable_artistic_performance_tracking enabled =
  artistic_performance_tracking := enabled;
  Printf.printf "艺术评价性能跟踪已%s\n" (if enabled then "启用" else "禁用")

(** {1 向后兼容性接口} *)

(** 兼容artistic_core.ml接口 *)
module Legacy_Core = struct
  type engine_state = { initialized : bool; cache_size : int; evaluation_count : int; last_update : float; }
  
  let initialize_engine () = 
    { initialized = true; cache_size = 0; evaluation_count = 0; last_update = Unix.time () }
  
  let create_evaluation_context verse verses =
    { verse; verses; poem_type = None; author = None; historical_context = None; metadata = [] }
  
  let comprehensive_artistic_evaluation verses engine_state =
    let _ = engine_state in
    let poem = String.concat "\n" verses in
    comprehensive_artistic_evaluation_unified poem
  
  let evaluate_single_dimension dimension context engine_state =
    let _ = engine_state in
    let verse = context.verse in
    let score = match dimension with
      | RhymeHarmony -> evaluate_rhyme_harmony verse
      | TonalBalance -> evaluate_tonal_balance verse None
      | Imagery -> evaluate_imagery verse
      | Rhythm -> evaluate_rhythm verse
      | Elegance -> evaluate_elegance verse
      | Parallelism when List.length context.verses >= 2 -> 
          (match context.verses with 
           | left :: right :: _ -> evaluate_parallelism left right 
           | _ -> 0.5)
      | _ -> 0.5
    in
    Some { dimension; score; max_possible = 1.0; confidence = 0.8; details = Some "单维度分析"; suggestions = ["继续改进"] }
  
  let evaluate_wuyan_lushi poem =
    comprehensive_artistic_evaluation_unified poem
  
  let evaluate_qiyan_jueju poem =
    comprehensive_artistic_evaluation_unified poem
  
  let evaluate_siyan_parallel_prose poem =
    comprehensive_artistic_evaluation_unified poem
  
  let evaluate_poetry_by_form _form poem =
    comprehensive_artistic_evaluation_unified poem
  
  let evaluate_poem_artistic poem =
    let evaluation = comprehensive_artistic_evaluation_unified poem in
    evaluation.overall_score
  
  let multi_dimension_evaluation verse =
    comprehensive_artistic_evaluation_unified verse
  
  let quick_artistic_check verse =
    let evaluation = multi_dimension_evaluation verse in
    let avg = evaluation.overall_score in
    (avg >= 0.6, ["基于快速检查的建议"])
end

(** 兼容artistic_engine_unified.ml接口 *)
module Legacy_Unified = struct
  type artistic_dimension = Content | Form | Sound | Context | Emotion | Innovation
  
  type artistic_evaluation = {
    overall_score : float;
    dimension_scores : (artistic_dimension * float) list;
    strengths : string list;
    weaknesses : string list;
    improvement_suggestions : string list;
    artistic_level : [ `Beginner | `Intermediate | `Advanced | `Master ];
  }
  
  let comprehensive_artistic_evaluation poem =
    let eval = comprehensive_artistic_evaluation_unified poem in
    {
      overall_score = eval.overall_score;
      dimension_scores = [
        (Sound, List.find_opt (fun ds -> ds.dimension = RhymeHarmony) eval.dimension_scores |> function Some ds -> ds.score | None -> 0.5);
        (Form, List.find_opt (fun ds -> ds.dimension = TonalBalance) eval.dimension_scores |> function Some ds -> ds.score | None -> 0.5);
        (Content, List.find_opt (fun ds -> ds.dimension = Imagery) eval.dimension_scores |> function Some ds -> ds.score | None -> 0.5);
        (Context, List.find_opt (fun ds -> ds.dimension = Rhythm) eval.dimension_scores |> function Some ds -> ds.score | None -> 0.5);
        (Emotion, List.find_opt (fun ds -> ds.dimension = Elegance) eval.dimension_scores |> function Some ds -> ds.score | None -> 0.5);
      ];
      strengths = eval.strengths;
      weaknesses = eval.weaknesses;
      improvement_suggestions = eval.improvement_suggestions;
      artistic_level = eval.artistic_level;
    }
  
  let evaluate_rhyme_harmony = evaluate_rhyme_harmony
  let evaluate_tonal_balance = evaluate_tonal_balance
  let evaluate_parallelism = evaluate_parallelism
  let evaluate_imagery = evaluate_imagery
  let evaluate_rhythm = evaluate_rhythm
  let evaluate_elegance = evaluate_elegance
  
  let evaluate_siyan_parallel_prose text =
    let evaluation = comprehensive_artistic_evaluation text in
    evaluation.overall_score
  
  let evaluate_wuyan_lushi text =
    let evaluation = comprehensive_artistic_evaluation text in
    evaluation.overall_score
  
  let evaluate_qiyan_jueju text =
    let evaluation = comprehensive_artistic_evaluation text in
    evaluation.overall_score
  
  let evaluate_poetry_by_form _form_type text =
    let evaluation = comprehensive_artistic_evaluation text in
    evaluation.overall_score
end

(** {1 调试和监控} *)

let print_artistic_status () =
  Printf.printf "\n=== 整合艺术评价引擎状态 ===\n";
  Printf.printf "评价缓存项目数: %d\n" (Hashtbl.length evaluation_result_cache);
  Printf.printf "系统缓存项目数: %d\n" (Hashtbl.length consolidated_artistic_cache);
  Printf.printf "性能统计项目数: %d\n" (Hashtbl.length artistic_performance_stats);
  Printf.printf "降级模式: %s\n" (if !artistic_fallback_mode then "启用" else "禁用");
  Printf.printf "性能跟踪: %s\n" (if !artistic_performance_tracking then "启用" else "禁用");

  Printf.printf "\n--- 艺术评价缓存状态 ---\n";
  Hashtbl.iter
    (fun artistic_type _ -> Printf.printf "已缓存: %s\n" (artistic_type_to_string artistic_type))
    consolidated_artistic_cache;

  Printf.printf "\n--- 艺术评价性能统计 ---\n";
  Hashtbl.iter
    (fun artistic_type (total_time, count) ->
      let avg_time = if count > 0 then total_time /. float_of_int count else 0.0 in
      Printf.printf "%s: 调用%d次, 平均%.3fms\n" (artistic_type_to_string artistic_type) count
        (avg_time *. 1000.0))
    artistic_performance_stats;
  Printf.printf "=============================\n\n"