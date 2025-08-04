(** 诗词艺术评估配置模块 - Phase 1-C 模块化重构
 *
 * 此模块包含评价系统的配置、常数和参数设置
 * 从 artistic_evaluators.ml 中提取的配置相关功能
 *
 * @author Whisky, PR Worker - Phase 1-C 模块化重构  
 * @refactors Issue #2171 - Phase 1-C 代码重构现代化
 *)

(** {1 默认配置值} *)

(** 默认评分：当找不到对应评价器时的默认分数 *)
let default_evaluation_score = 0.5

(** 各维度权重配置 *)
module WeightConfig = struct
  let rhyme_harmony_weight = 0.20
  let tonal_balance_weight = 0.15
  let form_beauty_weight = 0.15
  let parallelism_weight = 0.12
  let imagery_weight = 0.12
  let rhythm_weight = 0.10
  let elegance_weight = 0.10
  let content_depth_weight = 0.06

  let all_weights = [
    rhyme_harmony_weight; tonal_balance_weight; form_beauty_weight;
    parallelism_weight; imagery_weight; rhythm_weight;
    elegance_weight; content_depth_weight;
  ]

  let get_weight = function
    | Artistic_core.RhymeHarmony -> rhyme_harmony_weight
    | Artistic_core.TonalBalance -> tonal_balance_weight
    | Artistic_core.FormBeauty -> form_beauty_weight
    | Artistic_core.Parallelism -> parallelism_weight
    | Artistic_core.Imagery -> imagery_weight
    | Artistic_core.Rhythm -> rhythm_weight
    | Artistic_core.Elegance -> elegance_weight
    | Artistic_core.ContentDepth -> content_depth_weight
    | _ -> 0.05  (* 其他维度的默认权重 *)
end

(** 评价阈值配置 *)
module ThresholdConfig = struct
  let excellent_threshold = 0.9
  let good_threshold = 0.7
  let fair_threshold = 0.5
  let poor_threshold = 0.3

  let master_level_threshold = 0.85
  let advanced_level_threshold = 0.70
  let intermediate_level_threshold = 0.50
  let beginner_level_threshold = 0.30
end

(** 韵律分析配置 *)
module RhymeConfig = struct
  let min_verses_for_analysis = 2
  let min_rhyme_chars_for_analysis = 2
  let optimal_rhyme_diversity_min = 0.25
  let optimal_rhyme_diversity_max = 0.75
  let acceptable_rhyme_diversity_min = 0.15
  let acceptable_rhyme_diversity_max = 0.85
end

(** 形式美分析配置 *)
module FormConfig = struct
  let perfect_verse_counts = [4; 8]  (* 绝句或律诗 *)
  let good_verse_threshold = 2       (* 偶数行加分 *)
  let length_variance_penalty = 10.0
  let structural_perfect_score = 1.0
  let structural_good_score = 0.8
  let structural_fair_score = 0.6
end

(** 文本分析配置 *)
module TextConfig = struct
  let max_suggestions_count = 5
  let min_confidence_threshold = 0.3
  let utf8_char_detection_enabled = true
  let punctuation_chars = ["。"; "，"; "！"; "？"; "；"; "："]
end

(** 评价器配置映射 *)
module EvaluatorConfig = struct
  let get_required_context = function
    | Artistic_core.RhymeHarmony -> ["verses"]
    | Artistic_core.TonalBalance -> ["verse"]
    | Artistic_core.FormBeauty -> ["verses"]
    | Artistic_core.Parallelism -> ["verses"]
    | Artistic_core.Imagery -> ["verse"]
    | Artistic_core.Rhythm -> ["verse"]
    | Artistic_core.Elegance -> ["verse"]
    | Artistic_core.ContentDepth -> ["verse"; "metadata"]
    | _ -> ["verse"]

  let get_min_applicable_verses = function
    | Artistic_core.RhymeHarmony -> 2
    | Artistic_core.Parallelism -> 2
    | Artistic_core.FormBeauty -> 1
    | _ -> 1

  let get_confidence_factor = function
    | Artistic_core.RhymeHarmony -> 0.8
    | Artistic_core.TonalBalance -> 0.7
    | Artistic_core.FormBeauty -> 0.7
    | Artistic_core.Parallelism -> 0.9
    | Artistic_core.Imagery -> 0.6
    | Artistic_core.Rhythm -> 0.7
    | Artistic_core.Elegance -> 0.6
    | Artistic_core.ContentDepth -> 0.5
    | _ -> 0.5
end

(** 报告生成配置 *)
module ReportConfig = struct
  let max_strengths_count = 3
  let max_weaknesses_count = 3
  let max_suggestions_count = 5
  let include_metadata = true
  let include_confidence_scores = true
  let detailed_feedback_enabled = true
end

(** 系统运行配置 *)
module SystemConfig = struct
  let enable_caching = true
  let cache_ttl_seconds = 300
  let max_cache_entries = 1000
  let enable_performance_monitoring = true
  let log_evaluation_details = false
  let parallel_evaluation_enabled = false
end