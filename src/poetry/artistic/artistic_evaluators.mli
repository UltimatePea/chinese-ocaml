(** 标准化评估器模块接口
 *
 * 提供统一的评估器接口，整合所有evaluators目录下的评估器。
 * 
 * @author Whisky, PR Worker - 诗词艺术评估模块整合实施
 * @version 1.0 - 模块整合版本
 * @since 2025-08-03
 * @fix_issue #2000 Poetry艺术评估模块整合实施
 *)

open Artistic_engine_unified

(** {1 专门化评估器模块} *)

(** 韵律和谐评估器 *)
module RhymeHarmonyEvaluator : sig
  (** 韵脚模式 *)
  type rhyme_pattern = {
    pattern_id : string;     (** 模式标识 *)
    tone_sequence : string;  (** 声调序列 *)
    rhyme_scheme : string;   (** 韵脚模式 *)
  }

  (** 分析韵脚模式
      @param verses 诗句列表
      @return 韵脚模式分析结果 *)
  val analyze_rhyme_pattern : string list -> rhyme_pattern

  (** 评估韵律和谐度
      @param verse 待评价的诗句
      @return 韵律和谐度评分结果 *)
  val evaluate : string -> dimension_score

  (** 批量评估多个诗句
      @param verses 诗句列表
      @return 评分结果列表 *)
  val evaluate_batch : string list -> dimension_score list
end

(** 声调平衡评估器 *)
module TonalBalanceEvaluator : sig
  (** 声调类型 *)
  type tone_pattern = Ping | Ze | Unknown

  (** 检测字符声调
      @param char 字符
      @return 声调类型 *)
  val detect_tone : char -> tone_pattern

  (** 分析声调模式
      @param verse 诗句
      @return 声调模式列表 *)
  val analyze_tonal_pattern : string -> tone_pattern list

  (** 评估声调平衡度
      @param verse 待评价的诗句
      @param expected_pattern 期望的平仄模式
      @return 声调平衡度评分结果 *)
  val evaluate : string -> string option -> dimension_score

  (** 检查声调模式匹配度
      @param verse 诗句
      @param expected 期望模式
      @return 匹配度分数 (0.0-1.0) *)
  val check_pattern_match : string -> string -> float
end

(** 对仗评估器 *)
module ParallelismEvaluator : sig
  (** 词性类型 *)
  type word_class = Noun | Verb | Adjective | Adverb | Other

  (** 检测词性
      @param word 词语
      @return 词性类型 *)
  val detect_word_class : string -> word_class

  (** 分析句子结构
      @param verse 诗句
      @return 词性结构列表 *)
  val analyze_structure : string -> word_class list

  (** 评估对仗工整度
      @param left_verse 左联
      @param right_verse 右联
      @return 对仗工整度评分结果 *)
  val evaluate : string -> string -> dimension_score

  (** 检查词性对应度
      @param left 左联
      @param right 右联
      @return 对应度分数 (0.0-1.0) *)
  val check_word_class_correspondence : string -> string -> float
end

(** 意象评估器 *)
module ImageryEvaluator : sig
  (** 意象类别 *)
  type imagery_category = Nature | Human | Abstract | Temporal | Spatial

  (** 检测意象类别
      @param verse 诗句
      @return 意象类别和数量的列表 *)
  val detect_imagery : string -> (imagery_category * int) list

  (** 评估意象深度
      @param verse 待评价的诗句
      @return 意象深度评分结果 *)
  val evaluate : string -> dimension_score

  (** 计算意象丰富度
      @param verse 诗句
      @return 丰富度分数 (0.0-1.0) *)
  val calculate_richness : string -> float
end

(** 形式美感评估器 *)
module FormBeautyEvaluator : sig
  (** 诗句结构 *)
  type verse_structure = {
    character_count : int;    (** 字符数 *)
    word_count : int;         (** 词数 *)
    symmetry_score : float;   (** 对称性分数 *)
    rhythm_score : float;     (** 节奏分数 *)
  }

  (** 分析诗句结构
      @param verse 诗句
      @return 结构分析结果 *)
  val analyze_structure : string -> verse_structure

  (** 评估形式美感
      @param verse 待评价的诗句
      @return 形式美感评分结果 *)
  val evaluate : string -> dimension_score

  (** 检查格律符合度
      @param verse 诗句
      @param meter_type 格律类型
      @return 符合度分数 (0.0-1.0) *)
  val check_metrical_compliance : string -> string -> float
end

(** 内容深度评估器 *)
module ContentDepthEvaluator : sig
  (** 内容主题 *)
  type content_theme = Philosophy | Nature | Love | Friendship | Patriotism | Melancholy

  (** 检测主题
      @param verse 诗句
      @return 主题和分数的列表 *)
  val detect_themes : string -> (content_theme * float) list

  (** 评估内容深度
      @param verse 待评价的诗句
      @return 内容深度评分结果 *)
  val evaluate : string -> dimension_score
end

(** {1 统一评估接口} *)

(** 综合评估模块 *)
module ComprehensiveEvaluator : sig
  (** 评估单个诗句的所有维度
      @param verse 待评价的诗句
      @return 综合评价结果 *)
  val evaluate_all_dimensions : string -> evaluation_result

  (** 评估对联
      @param left_verse 左联
      @param right_verse 右联
      @return 综合评价结果 *)
  val evaluate_couplet : string -> string -> evaluation_result
end

(** {1 兼容性函数} *)

(** 评估韵律和谐度 - 兼容旧版API
    @param verse 待评价的诗句
    @return 韵律和谐度分数 (0.0-1.0) *)
val evaluate_rhyme_harmony_legacy : string -> float

(** 评估声调平衡度 - 兼容旧版API
    @param verse 待评价的诗句
    @param pattern 期望的平仄模式
    @return 声调平衡度分数 (0.0-1.0) *)
val evaluate_tonal_balance_legacy : string -> string -> float

(** 评估对仗工整度 - 兼容旧版API
    @param left 左联
    @param right 右联
    @return 对仗工整度分数 (0.0-1.0) *)
val evaluate_parallelism_legacy : string -> string -> float

(** 评估意象深度 - 兼容旧版API
    @param verse 待评价的诗句
    @return 意象深度分数 (0.0-1.0) *)
val evaluate_imagery_legacy : string -> float

(** 评估形式美感 - 兼容旧版API
    @param verse 待评价的诗句
    @return 形式美感分数 (0.0-1.0) *)
val evaluate_form_beauty_legacy : string -> float