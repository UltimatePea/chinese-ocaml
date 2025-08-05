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

and cache_subtype = EvaluationCache | ResultCache | ConfigCache
and data_subtype = EvaluationData | MetadataManagement | ContextManagement
and reporting_subtype = StandardReports | DetailedReports | ComparisonReports
and filtering_subtype = QualityFilters | LevelFilters | TypeFilters
and metrics_subtype = PerformanceMetrics | QualityMetrics | AnalysisMetrics
and standards_subtype = EvaluationStandards | QualityStandards | FormStandards

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
  | CoreEvaluationError (msg, detail) -> Printf.sprintf "核心评价错误: %s (详细: %s)" msg detail
  | UnifiedEngineError (msg, detail) -> Printf.sprintf "统一引擎错误: %s (详细: %s)" msg detail
  | ConfigError (msg, detail) -> Printf.sprintf "配置错误: %s (详细: %s)" msg detail
  | CacheError (msg, detail) -> Printf.sprintf "缓存错误: %s (详细: %s)" msg detail
  | DataError (msg, detail) -> Printf.sprintf "数据管理错误: %s (详细: %s)" msg detail
  | ReportingError (msg, detail) -> Printf.sprintf "报告生成错误: %s (详细: %s)" msg detail
  | FilteringError (msg, detail) -> Printf.sprintf "过滤系统错误: %s (详细: %s)" msg detail
  | MetricsError (msg, detail) -> Printf.sprintf "度量系统错误: %s (详细: %s)" msg detail
  | StandardsError (msg, detail) -> Printf.sprintf "标准系统错误: %s (详细: %s)" msg detail
  | ConsolidatedArtisticError msg -> Printf.sprintf "整合艺术评价引擎错误: %s" msg
  | CompatibilityError msg -> Printf.sprintf "兼容性错误: %s" msg

(** {1 评价配置} *)

(** 整合配置模块的常量 - 与artistic_config.ml保持一致 *)
let default_evaluation_score = 0.5

let excellent_threshold = 0.9
let good_threshold = 0.7
let fair_threshold = 0.5
let poor_threshold = 0.3

type consolidated_artistic_config = {
  enable_cache : bool;
  cache_size_limit : int;
  enable_fallback : bool;
  enable_performance_tracking : bool;
  timeout_ms : int;
  evaluation_precision : [ `High | `Medium | `Low ];
  concurrent_evaluation : bool;
  (* 艺术评价权重配置 - From artistic_config.ml *)
  rhyme_harmony_weight : float;
  tonal_balance_weight : float;
  form_beauty_weight : float;
  parallelism_weight : float;
  imagery_weight : float;
  rhythm_weight : float;
  elegance_weight : float;
  content_depth_weight : float;
}

let default_artistic_config =
  {
    enable_cache = true;
    cache_size_limit = 500;
    enable_fallback = true;
    enable_performance_tracking = true;
    timeout_ms = 15000;
    evaluation_precision = `Medium;
    concurrent_evaluation = false;
    (* 使用artistic_config.ml中的权重配置 *)
    rhyme_harmony_weight = 0.20;
    tonal_balance_weight = 0.15;
    form_beauty_weight = 0.15;
    parallelism_weight = 0.12;
    imagery_weight = 0.12;
    rhythm_weight = 0.10;
    elegance_weight = 0.10;
    content_depth_weight = 0.06;
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
let evaluation_result_cache : (string, artistic_evaluation) Hashtbl.t = Hashtbl.create 256

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
      try Hashtbl.find artistic_performance_stats artistic_type with Not_found -> (0.0, 0)
    in
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
  if len_sub = 0 then true else search 0

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

(** 韵律和谐评价器 - 增强版 *)
let evaluate_rhyme_harmony verse =
  let trimmed = String.trim verse in
  let len = String.length trimmed in
  if len = 0 then 0.3
  else
    (* 中文字符检测 - 只有中文字符才能有高韵律评分 *)
    let chinese_char_count = ref 0 in
    let ascii_char_count = ref 0 in
    for i = 0 to len - 1 do
      let byte = Char.code trimmed.[i] in
      if byte >= 0x80 then incr chinese_char_count (* 非-ASCII字符，可能是中文 *)
      else if (byte >= 0x41 && byte <= 0x5A) || (byte >= 0x61 && byte <= 0x7A) then
        incr ascii_char_count
    done;

    let chinese_ratio = float_of_int !chinese_char_count /. float_of_int len in
    let ascii_ratio = float_of_int !ascii_char_count /. float_of_int len in

    (* 非中文文本惩罚 *)
    if ascii_ratio > 0.5 then 0.3 (* 大量英文字母，不适合中文诗词 *)
    else if chinese_ratio < 0.3 then 0.4 (* 中文字符太少 *)
    else
      let char_opt = extract_final_char verse in
      match char_opt with
      | Some final_char ->
          (* 中文常见韵母分析 *)
          let rhyme_quality =
            if string_contains_substring final_char "音" || string_contains_substring final_char "韵"
            then 0.95
            else if
              string_contains_substring final_char "声" || string_contains_substring final_char "调"
            then 0.9
            else if
              string_contains_substring final_char "晓"
              || string_contains_substring final_char "鸟"
              || string_contains_substring final_char "多"
              || string_contains_substring final_char "少"
            then 0.85
            else 0.75
          in
          (* 诗句长度对韵律的影响 *)
          let length_factor =
            if len >= 14 && len <= 21 then 1.0 (* 七言诗句 *)
            else if len >= 10 && len <= 15 then 0.95 (* 五言诗句 *)
            else if len >= 8 && len <= 12 then 0.9 (* 四言诗句 *)
            else 0.8
          in
          let chinese_bonus = chinese_ratio *. 0.1 in
          (* 中文字符比例奖励 *)
          min 1.0 ((rhyme_quality *. length_factor) +. chinese_bonus)
      | None ->
          (* 无韵脚但中文字符丰富 *)
          (0.5 *. chinese_ratio) +. 0.3

(** 声调平衡评价器 - 增强版 *)
let evaluate_tonal_balance verse expected_pattern =
  let _ = expected_pattern in
  (* 保持向后兼容 *)
  let len = String.length verse in
  if len = 0 then 0.3
  else
    (* 基于字符分布的声调平衡分析 *)
    let chars = List.init len (String.get verse) in
    let char_variety =
      let unique_chars = List.sort_uniq Char.compare chars in
      float_of_int (List.length unique_chars) /. float_of_int len
    in
    (* 声调标记词汇检测 *)
    let tonal_indicators = [ "平"; "仄"; "上"; "去"; "入" ] in
    let tonal_richness =
      List.fold_left
        (fun acc indicator ->
          if string_contains_substring verse indicator then acc +. 0.15 else acc)
        0.0 tonal_indicators
    in
    (* 句长对声调平衡的影响 *)
    let length_bonus =
      if len >= 14 && len <= 21 then 0.1 (* 七言适中长度 *)
      else if len >= 10 && len <= 15 then 0.08 (* 五言适中长度 *)
      else 0.05
    in
    let base_score = 0.5 +. (char_variety *. 0.3) +. tonal_richness +. length_bonus in
    min 1.0 base_score

(** 意象评价器 - 增强版 *)
let evaluate_imagery verse =
  (* 丰富的意象关键词分类 *)
  let natural_imagery =
    [ "山"; "水"; "花"; "月"; "风"; "雨"; "云"; "雪"; "江"; "河"; "海"; "天"; "地"; "树"; "林"; "鸟"; "虫" ]
  in
  let seasonal_imagery = [ "春"; "夏"; "秋"; "冬"; "寒"; "暖"; "热"; "凉" ] in
  let emotional_imagery = [ "愁"; "喜"; "怒"; "哀"; "乐"; "思"; "念"; "忆"; "梦"; "醉" ] in
  let cultural_imagery = [ "书"; "琴"; "棋"; "画"; "诗"; "词"; "酒"; "茶"; "香"; "禅" ] in

  let count_imagery_type keywords =
    List.fold_left
      (fun acc keyword -> if string_contains_substring verse keyword then acc + 1 else acc)
      0 keywords
  in

  let natural_count = count_imagery_type natural_imagery in
  let seasonal_count = count_imagery_type seasonal_imagery in
  let emotional_count = count_imagery_type emotional_imagery in
  let cultural_count = count_imagery_type cultural_imagery in

  let total_imagery_count = natural_count + seasonal_count + emotional_count + cultural_count in

  (* 意象丰富度评分 *)
  let imagery_richness =
    if total_imagery_count >= 4 then 0.95
    else if total_imagery_count >= 3 then 0.85
    else if total_imagery_count >= 2 then 0.75
    else if total_imagery_count >= 1 then 0.65
    else 0.4
  in

  (* 意象类型多样性奖励 *)
  let diversity_bonus =
    let type_count =
      (if natural_count > 0 then 1 else 0)
      + (if seasonal_count > 0 then 1 else 0)
      + (if emotional_count > 0 then 1 else 0)
      + if cultural_count > 0 then 1 else 0
    in
    float_of_int type_count *. 0.05
  in

  min 1.0 (imagery_richness +. diversity_bonus)

(** 节奏评价器 - 增强版 *)
let evaluate_rhythm verse =
  let trimmed = String.trim verse in
  let char_count = String.length trimmed in
  if char_count = 0 then 0.3
  else
    (* 中文字符检测 *)
    let chinese_char_count = ref 0 in
    let ascii_char_count = ref 0 in
    for i = 0 to char_count - 1 do
      let byte = Char.code trimmed.[i] in
      if byte >= 0x80 then incr chinese_char_count
      else if (byte >= 0x41 && byte <= 0x5A) || (byte >= 0x61 && byte <= 0x7A) then
        incr ascii_char_count
    done;

    let chinese_ratio = float_of_int !chinese_char_count /. float_of_int char_count in
    let ascii_ratio = float_of_int !ascii_char_count /. float_of_int char_count in

    (* 非中文文本惩罚 *)
    if ascii_ratio > 0.5 then 0.3 (* 大量英文字母 *)
    else if chinese_ratio < 0.3 then 0.4 (* 中文字符太少 *)
    else
      (* 中文诗词节奏标准分析 *)
      let rhythm_score =
        if char_count = 28 then 0.95 (* 七言律诗标准长度 *)
        else if char_count >= 26 && char_count <= 30 then 0.9 (* 七言诗句范围 *)
        else if char_count = 20 then 0.9 (* 五言律诗标准长度 *)
        else if char_count >= 18 && char_count <= 22 then 0.85 (* 五言诗句范围 *)
        else if char_count = 16 then 0.85 (* 四言诗标准长度 *)
        else if char_count >= 14 && char_count <= 18 then 0.8 (* 四言诗范围 *)
        else if char_count >= 10 && char_count <= 35 then 0.7 (* 自由诗范围 *)
        else if char_count < 5 then 0.2 (* 过短文本严重惩罚 *)
        else if char_count > 50 then 0.4 (* 过长文本惩罚 *)
        else 0.5
      in

      (* 停顿和数特征分析 *)
      let pause_indicators = [ "，"; "。"; "；"; "："; "！"; "？"; "—" ] in
      let pause_count =
        List.fold_left
          (fun acc indicator -> if string_contains_substring verse indicator then acc + 1 else acc)
          0 pause_indicators
      in

      let pause_bonus = if pause_count >= 2 then 0.1 else if pause_count = 1 then 0.05 else 0.0 in

      (* 重复字符检测（影响节奏） *)
      let chars = List.init char_count (String.get trimmed) in
      let unique_chars = List.sort_uniq Char.compare chars in
      let repetition_penalty = if List.length unique_chars < char_count / 2 then -0.1 else 0.0 in

      let chinese_bonus = chinese_ratio *. 0.1 in
      (* 中文字符比例奖励 *)
      min 1.0 (max 0.0 (rhythm_score +. pause_bonus +. repetition_penalty +. chinese_bonus))

(** 雅致程度评价器 - 增强版 *)
let evaluate_elegance verse =
  (* 雅致词汇分类 *)
  let refined_words = [ "雅"; "清"; "淡"; "幽"; "静"; "深"; "远"; "高"; "淡泊"; "清雅"; "清新" ] in
  let noble_words = [ "尊"; "贵"; "圣"; "仙"; "神"; "灵"; "妙"; "玄"; "禅"; "道" ] in
  let aesthetic_words = [ "美"; "美丽"; "姿"; "美姿"; "婐娜"; "续约"; "美好"; "动人" ] in
  let literary_words = [ "文"; "文雅"; "诗"; "词"; "曲"; "赋"; "书"; "墨"; "笔"; "章" ] in

  let count_elegance_type words =
    List.fold_left
      (fun acc word -> if string_contains_substring verse word then acc + 1 else acc)
      0 words
  in

  let refined_count = count_elegance_type refined_words in
  let noble_count = count_elegance_type noble_words in
  let aesthetic_count = count_elegance_type aesthetic_words in
  let literary_count = count_elegance_type literary_words in

  let total_elegance = refined_count + noble_count + aesthetic_count + literary_count in

  (* 雅致程度基础评分 *)
  let elegance_base =
    if total_elegance >= 5 then 0.95
    else if total_elegance >= 4 then 0.9
    else if total_elegance >= 3 then 0.85
    else if total_elegance >= 2 then 0.75
    else if total_elegance >= 1 then 0.65
    else 0.45
  in

  (* 雅致类型多样性奖励 *)
  let category_diversity =
    let active_categories =
      (if refined_count > 0 then 1 else 0)
      + (if noble_count > 0 then 1 else 0)
      + (if aesthetic_count > 0 then 1 else 0)
      + if literary_count > 0 then 1 else 0
    in
    float_of_int active_categories *. 0.02
  in

  (* 俗词惩罚 *)
  let vulgar_words = [ "俗"; "低"; "粗"; "恶"; "脏"; "丑" ] in
  let vulgar_penalty =
    List.fold_left
      (fun acc word -> if string_contains_substring verse word then acc -. 0.1 else acc)
      0.0 vulgar_words
  in

  min 1.0 (max 0.0 (elegance_base +. category_diversity +. vulgar_penalty))

(** 对仗评价器 - 增强版 *)
let evaluate_parallelism left_verse right_verse =
  let left_len = String.length (String.trim left_verse) in
  let right_len = String.length (String.trim right_verse) in
  let len_diff = abs (left_len - right_len) in

  (* 长度对等性评分 *)
  let length_score =
    if len_diff = 0 then 1.0
    else if len_diff <= 1 then 0.9
    else if len_diff <= 2 then 0.8
    else if len_diff <= 3 then 0.6
    else 0.4
  in

  (* 结构对应性分析 *)
  let structure_similarity =
    let left_has_punctuation =
      List.exists (string_contains_substring left_verse) [ "，"; "。"; "；"; "：" ]
    in
    let right_has_punctuation =
      List.exists (string_contains_substring right_verse) [ "，"; "。"; "；"; "：" ]
    in
    if left_has_punctuation = right_has_punctuation then 0.1 else 0.0
  in

  (* 词性对应分析（简化版） *)
  let semantic_parallel =
    let left_has_nature =
      List.exists (string_contains_substring left_verse) [ "山"; "水"; "花"; "月"; "风"; "雨" ]
    in
    let right_has_nature =
      List.exists (string_contains_substring right_verse) [ "山"; "水"; "花"; "月"; "风"; "雨" ]
    in
    let left_has_emotion =
      List.exists (string_contains_substring left_verse) [ "情"; "思"; "心"; "爱"; "恨"; "愁" ]
    in
    let right_has_emotion =
      List.exists (string_contains_substring right_verse) [ "情"; "思"; "心"; "爱"; "恨"; "愁" ]
    in

    if (left_has_nature && right_has_nature) || (left_has_emotion && right_has_emotion) then 0.15
    else 0.0
  in

  (* 韵律对应性 *)
  let rhyme_parallel =
    let left_final = extract_final_char left_verse in
    let right_final = extract_final_char right_verse in
    match (left_final, right_final) with Some _, Some _ -> 0.1 | _ -> 0.0
  in

  min 1.0 (length_score +. structure_similarity +. semantic_parallel +. rhyme_parallel)

(** {1 统一引擎功能 - 整合自artistic_engine_unified.ml} *)

(** 综合艺术性评价 - 增强版 *)
let comprehensive_artistic_evaluation_unified poem =
  let verses = String.split_on_char '\n' poem |> List.filter (fun s -> String.trim s <> "") in
  let verse_count = List.length verses in

  let rhyme_scores = List.map evaluate_rhyme_harmony verses in
  let tonal_scores = List.map (fun v -> evaluate_tonal_balance v "") verses in
  let imagery_scores = List.map evaluate_imagery verses in
  let rhythm_scores = List.map evaluate_rhythm verses in
  let elegance_scores = List.map evaluate_elegance verses in

  (* 使用权重配置计算平均分 *)
  let weighted_avg scores weight =
    if List.length scores = 0 then 0.0
    else List.fold_left ( +. ) 0.0 scores /. float_of_int (List.length scores) *. weight
  in

  let rhyme_weighted = weighted_avg rhyme_scores !global_artistic_config.rhyme_harmony_weight in
  let tonal_weighted = weighted_avg tonal_scores !global_artistic_config.tonal_balance_weight in
  let imagery_weighted = weighted_avg imagery_scores !global_artistic_config.imagery_weight in
  let rhythm_weighted = weighted_avg rhythm_scores !global_artistic_config.rhythm_weight in
  let elegance_weighted = weighted_avg elegance_scores !global_artistic_config.elegance_weight in

  (* 计算对仗分数（如果有多行） *)
  let parallelism_score =
    if verse_count >= 2 then
      let rec take n lst =
        match (n, lst) with 0, _ | _, [] -> [] | n, h :: t -> h :: take (n - 1) t
      in
      let rec drop n lst =
        match (n, lst) with 0, _ -> lst | _, [] -> [] | n, _ :: t -> drop (n - 1) t
      in
      let first_half = take (verse_count / 2) verses in
      let second_half = take (verse_count / 2) (drop (verse_count / 2) verses) in
      if List.length first_half = List.length second_half then
        let pairs = List.combine first_half second_half in
        let parallelism_scores =
          List.map (fun (left, right) -> evaluate_parallelism left right) pairs
        in
        weighted_avg parallelism_scores !global_artistic_config.parallelism_weight
      else 0.0
    else 0.0
  in

  (* 诗体类型奖励/惩罚 *)
  let form_bonus =
    if verse_count = 4 then 0.05 (* 绝句形式 *)
    else if verse_count = 8 then 0.08 (* 律诗形式 *)
    else if verse_count >= 2 && verse_count <= 12 then 0.02 (* 其他规范形式 *)
    else -0.05 (* 过长或过短惩罚 *)
  in

  let base_score =
    rhyme_weighted +. tonal_weighted +. imagery_weighted +. rhythm_weighted +. elegance_weighted
    +. parallelism_score
  in
  let overall_score = min 1.0 (max 0.0 (base_score +. form_bonus)) in

  (* 更精细的质量等级判定 *)
  let quality_grade =
    if overall_score >= 0.95 then `Excellent
    else if overall_score >= 0.85 then `Good
    else if overall_score >= 0.70 then `Fair
    else `Poor
  in

  (* 更精细的艺术水平判定 *)
  let artistic_level =
    if overall_score >= 0.92 then `Master
    else if overall_score >= 0.80 then `Advanced
    else if overall_score >= 0.65 then `Intermediate
    else `Beginner
  in

  {
    overall_score;
    dimension_scores =
      ([
         {
           dimension = RhymeHarmony;
           score = rhyme_weighted /. !global_artistic_config.rhyme_harmony_weight;
           max_possible = 1.0;
           confidence = 0.9;
           details = Some "韵律和谐分析 - 增强版";
           suggestions = (if rhyme_weighted < 0.7 then [ "改善韵脚选择"; "加强音韵和谐" ] else [ "继续保持韵律优美" ]);
         };
         {
           dimension = TonalBalance;
           score = tonal_weighted /. !global_artistic_config.tonal_balance_weight;
           max_possible = 1.0;
           confidence = 0.85;
           details = Some "声调平衡分析 - 增强版";
           suggestions = (if tonal_weighted < 0.7 then [ "注意平仄搭配"; "增强声调变化" ] else [ "声调平衡较好" ]);
         };
         {
           dimension = Imagery;
           score = imagery_weighted /. !global_artistic_config.imagery_weight;
           max_possible = 1.0;
           confidence = 0.9;
           details = Some "意象深度分析 - 增强版";
           suggestions = (if imagery_weighted < 0.7 then [ "丰富意象表达"; "加强情景交融" ] else [ "意象丰富生动" ]);
         };
         {
           dimension = Rhythm;
           score = rhythm_weighted /. !global_artistic_config.rhythm_weight;
           max_possible = 1.0;
           confidence = 0.85;
           details = Some "节奏韵律分析 - 增强版";
           suggestions = (if rhythm_weighted < 0.7 then [ "调整句式长度"; "改善节奏韵律" ] else [ "节奏韵律优美" ]);
         };
         {
           dimension = Elegance;
           score = elegance_weighted /. !global_artistic_config.elegance_weight;
           max_possible = 1.0;
           confidence = 0.8;
           details = Some "雅致程度分析 - 增强版";
           suggestions = (if elegance_weighted < 0.7 then [ "提升词汇雅致度"; "增强文学气息" ] else [ "雅致气质优秀" ]);
         };
       ]
      @
      if verse_count >= 2 then
        [
          {
            dimension = Parallelism;
            score = parallelism_score /. !global_artistic_config.parallelism_weight;
            max_possible = 1.0;
            confidence = 0.8;
            details = Some "对仗分析 - 增强版";
            suggestions = (if parallelism_score < 0.7 then [ "改善对仗工整度" ] else [ "对仗较为工整" ]);
          };
        ]
      else []);
    (* 动态生成优势和弱点 *)
    strengths =
      (let strengths_list = ref [] in
       if rhyme_weighted >= 0.8 then strengths_list := "韵律和谐优美" :: !strengths_list;
       if imagery_weighted >= 0.8 then strengths_list := "意象丰富生动" :: !strengths_list;
       if elegance_weighted >= 0.8 then strengths_list := "词藻雅致脱俗" :: !strengths_list;
       if rhythm_weighted >= 0.8 then strengths_list := "节奏韵律优美" :: !strengths_list;
       if tonal_weighted >= 0.8 then strengths_list := "声调平衡得当" :: !strengths_list;
       if parallelism_score >= 0.8 && verse_count >= 2 then
         strengths_list := "对仗工整对称" :: !strengths_list;
       if !strengths_list = [] then [ "具有基本的诗词特征" ] else !strengths_list);
    weaknesses =
      (let weaknesses_list = ref [] in
       if rhyme_weighted < 0.6 then weaknesses_list := "韵律谐音待改善" :: !weaknesses_list;
       if imagery_weighted < 0.6 then weaknesses_list := "意象表达不够丰富" :: !weaknesses_list;
       if elegance_weighted < 0.6 then weaknesses_list := "词汇雅致度不够" :: !weaknesses_list;
       if rhythm_weighted < 0.6 then weaknesses_list := "节奏韵律需调整" :: !weaknesses_list;
       if tonal_weighted < 0.6 then weaknesses_list := "声调平衡待优化" :: !weaknesses_list;
       if parallelism_score < 0.6 && verse_count >= 2 then
         weaknesses_list := "对仗工整度不够" :: !weaknesses_list;
       if !weaknesses_list = [] then [ "整体表现均衡" ] else !weaknesses_list);
    improvement_suggestions =
      (let suggestions = ref [] in
       if overall_score < 0.7 then suggestions := "需要全面提升艺术水平" :: !suggestions;
       if rhyme_weighted < 0.7 then suggestions := "加强韵律训练和实践" :: !suggestions;
       if imagery_weighted < 0.7 then suggestions := "多读优秀诗作，学习意象运用" :: !suggestions;
       if elegance_weighted < 0.7 then suggestions := "提高文学修养，丰富词汇积累" :: !suggestions;
       if overall_score >= 0.8 then suggestions := "继续保持和发扩优势" :: !suggestions;
       !suggestions);
    artistic_level;
    quality_grade;
    evaluation_metadata =
      [
        ("evaluation_time", string_of_float (Unix.time ()));
        ("version", "Consolidated Artistic Engine v2.0 - Enhanced");
        ("verse_count", string_of_int verse_count);
        ("algorithm_version", "phase2-enhanced");
        ("weighted_evaluation", "true");
        ("form_bonus_applied", string_of_float form_bonus);
      ];
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
            {
              (comprehensive_artistic_evaluation_unified context.verse) with
              overall_score = score;
              dimension_scores =
                [
                  {
                    dimension = RhymeHarmony;
                    score;
                    max_possible = 1.0;
                    confidence = 0.8;
                    details = Some "韵律和谐专项评价";
                    suggestions = [ "继续保持" ];
                  };
                ];
            }
        | CoreEvaluation TonalBalanceEvaluation ->
            let score = evaluate_tonal_balance context.verse "" in
            {
              (comprehensive_artistic_evaluation_unified context.verse) with
              overall_score = score;
              dimension_scores =
                [
                  {
                    dimension = TonalBalance;
                    score;
                    max_possible = 1.0;
                    confidence = 0.8;
                    details = Some "声调平衡专项评价";
                    suggestions = [ "继续保持" ];
                  };
                ];
            }
        | CoreEvaluation ImageryEvaluation ->
            let score = evaluate_imagery context.verse in
            {
              (comprehensive_artistic_evaluation_unified context.verse) with
              overall_score = score;
              dimension_scores =
                [
                  {
                    dimension = Imagery;
                    score;
                    max_possible = 1.0;
                    confidence = 0.8;
                    details = Some "意象深度专项评价";
                    suggestions = [ "继续保持" ];
                  };
                ];
            }
        | CoreEvaluation RhythmEvaluation ->
            let score = evaluate_rhythm context.verse in
            {
              (comprehensive_artistic_evaluation_unified context.verse) with
              overall_score = score;
              dimension_scores =
                [
                  {
                    dimension = Rhythm;
                    score;
                    max_possible = 1.0;
                    confidence = 0.8;
                    details = Some "节奏韵律专项评价";
                    suggestions = [ "继续保持" ];
                  };
                ];
            }
        | CoreEvaluation EleganceEvaluation ->
            let score = evaluate_elegance context.verse in
            {
              (comprehensive_artistic_evaluation_unified context.verse) with
              overall_score = score;
              dimension_scores =
                [
                  {
                    dimension = Elegance;
                    score;
                    max_possible = 1.0;
                    confidence = 0.8;
                    details = Some "雅致程度专项评价";
                    suggestions = [ "继续保持" ];
                  };
                ];
            }
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
  with e ->
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
            Printf.printf "艺术评价缓存预热失败 %s: %s\n"
              (artistic_type_to_string artistic_type)
              (Printexc.to_string e))
        contexts)
    artistic_types

let clear_artistic_cache () =
  Hashtbl.clear consolidated_artistic_cache;
  Hashtbl.clear evaluation_result_cache;
  Hashtbl.clear artistic_performance_stats;
  Printf.printf "整合艺术评价引擎缓存已清理\n"

let get_artistic_cache_stats () =
  let all_types =
    [
      CoreEvaluation ComprehensiveEvaluation;
      CoreEvaluation RhymeHarmonyEvaluation;
      CoreEvaluation TonalBalanceEvaluation;
      CoreEvaluation ImageryEvaluation;
      UnifiedEngine FormEvaluation;
      UnifiedEngine ContentEvaluation;
    ]
  in
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
  type engine_state = {
    initialized : bool;
    cache_size : int;
    evaluation_count : int;
    last_update : float;
  }

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
    let score =
      match dimension with
      | RhymeHarmony -> evaluate_rhyme_harmony verse
      | TonalBalance -> evaluate_tonal_balance verse ""
      | Imagery -> evaluate_imagery verse
      | Rhythm -> evaluate_rhythm verse
      | Elegance -> evaluate_elegance verse
      | Parallelism when List.length context.verses >= 2 -> (
          match context.verses with
          | left :: right :: _ -> evaluate_parallelism left right
          | _ -> 0.5)
      | _ -> 0.5
    in
    Some
      {
        dimension;
        score;
        max_possible = 1.0;
        confidence = 0.8;
        details = Some "单维度分析";
        suggestions = [ "继续改进" ];
      }

  let evaluate_wuyan_lushi poem = comprehensive_artistic_evaluation_unified poem
  let evaluate_qiyan_jueju poem = comprehensive_artistic_evaluation_unified poem
  let evaluate_siyan_parallel_prose poem = comprehensive_artistic_evaluation_unified poem
  let evaluate_poetry_by_form _form poem = comprehensive_artistic_evaluation_unified poem

  let evaluate_poem_artistic poem =
    let evaluation = comprehensive_artistic_evaluation_unified poem in
    evaluation.overall_score

  let multi_dimension_evaluation verse = comprehensive_artistic_evaluation_unified verse

  let quick_artistic_check verse =
    let evaluation = multi_dimension_evaluation verse in
    let avg = evaluation.overall_score in
    (avg >= 0.6, [ "基于快速检查的建议" ])
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
      dimension_scores =
        [
          ( Sound,
            List.find_opt (fun ds -> ds.dimension = RhymeHarmony) eval.dimension_scores |> function
            | Some ds -> ds.score
            | None -> 0.5 );
          ( Form,
            List.find_opt (fun ds -> ds.dimension = TonalBalance) eval.dimension_scores |> function
            | Some ds -> ds.score
            | None -> 0.5 );
          ( Content,
            List.find_opt (fun ds -> ds.dimension = Imagery) eval.dimension_scores |> function
            | Some ds -> ds.score
            | None -> 0.5 );
          ( Context,
            List.find_opt (fun ds -> ds.dimension = Rhythm) eval.dimension_scores |> function
            | Some ds -> ds.score
            | None -> 0.5 );
          ( Emotion,
            List.find_opt (fun ds -> ds.dimension = Elegance) eval.dimension_scores |> function
            | Some ds -> ds.score
            | None -> 0.5 );
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
      Printf.printf "%s: 调用%d次, 平均%.3fms\n"
        (artistic_type_to_string artistic_type)
        count (avg_time *. 1000.0))
    artistic_performance_stats;
  Printf.printf "=============================\n\n"
