(** 骆言诗词类型整合模块 - 统一诗词分析类型定义
    
    此模块整合了诗词分析系统中的所有核心类型定义，
    包括音韵类型、艺术性评价类型、数据结构等。
    
    技术债务改进：将140+个分散模块的类型定义统一至此处，
    减少模块间依赖，提高代码维护性。
    
    @author 骆言诗词编程团队
    @version 2.0 - 整合版本
    @since 2025-07-24 *)

(** {1 核心音韵类型} *)

(** 声韵分类：依古韵书分平仄入声 *)
type rhyme_category =
  | PingSheng  (** 平声韵 - 音平而长，如天籁之响 *)
  | ZeSheng  (** 仄声韵 - 音仄而促，如金石之声 *)
  | ShangSheng  (** 上声韵 - 音上扬，如询问之态 *)
  | QuSheng  (** 去声韵 - 音下降，如叹息之音 *)
  | RuSheng  (** 入声韵 - 音促而急，如鼓点之节 *)

(** 韵组分类：按韵书传统分组，同组可押韵 *)
type rhyme_group =
  | AnRhyme  (** 安韵组 - 含山、间、闲等字 *)
  | SiRhyme  (** 思韵组 - 含时、诗、知等字 *)
  | TianRhyme  (** 天韵组 - 含年、先、田等字 *)
  | WangRhyme  (** 望韵组 - 含放、向、响等字 *)
  | QuRhyme  (** 去韵组 - 含路、度、步等字 *)
  | YuRhyme  (** 鱼韵组 - 含鱼、书、居等字 *)
  | HuaRhyme  (** 花韵组 - 含花、霞、家等字 *)
  | FengRhyme  (** 风韵组 - 含风、送、中等字 *)
  | YueRhyme  (** 月韵组 - 含月、雪、节等字 *)
  | JiangRhyme  (** 江韵组 - 含江、窗、双等字 *)
  | HuiRhyme  (** 灰韵组 - 含灰、回、推等字 *)
  | UnknownRhyme  (** 未知韵组 - 韵书未载，待考证者 *)

(** 韵律分析报告 *)
type rhyme_analysis_report = {
  verse : string;
  rhyme_ending : char option;
  rhyme_group : rhyme_group;
  rhyme_category : rhyme_category;
  char_analysis : (char * rhyme_category * rhyme_group) list;
}

(** 整体韵律分析报告 *)
type poem_rhyme_analysis = {
  verses : string list;
  verse_reports : rhyme_analysis_report list;
  rhyme_groups : rhyme_group list;
  rhyme_categories : rhyme_category list;
  rhyme_quality : float;
  rhyme_consistency : bool;
}

(** {1 艺术性评价类型} *)

(** 艺术性评价维度 *)
type artistic_dimension =
  | RhymeHarmony
  | TonalBalance
  | Parallelism
  | Imagery
  | Rhythm
  | Elegance
  | ClassicalElegance
  | ModernInnovation
  | CulturalDepth
  | EmotionalResonance
  | IntellectualDepth

(** 评价等级 *)
type evaluation_grade = Excellent | Good | Fair | Poor

(** 艺术性评价报告 *)
type artistic_report = {
  verse : string;
  rhyme_score : float;
  tone_score : float;
  parallelism_score : float;
  imagery_score : float;
  rhythm_score : float;
  elegance_score : float;
  overall_grade : evaluation_grade;
  suggestions : string list;
}

(** 艺术性分数记录 *)
type artistic_scores = {
  rhyme_harmony : float;
  tonal_balance : float;
  parallelism : float;
  imagery : float;
  rhythm : float;
  elegance : float;
}

(** {1 诗词形式定义} *)

(** 诗词形式 *)
type poetry_form =
  | SiYanPianTi (** 四言骈体 *)
  | WuYanLuShi (** 五言律诗 *)
  | QiYanJueJu (** 七言绝句 *)
  | CiPai of string (** 词牌 *)
  | ModernPoetry (** 现代诗 *)
  | SiYanParallelProse (** 四言骈体散文 *)

(** 四言骈体评价标准 *)
type siyan_artistic_standards = {
  char_count : int;
  tone_pattern : bool list;
  parallelism_required : bool;
  rhythm_weight : float;
}

(** 五言律诗评价标准 *)
type wuyan_lushi_standards = {
  line_count : int;
  char_per_line : int;
  rhyme_scheme : bool array;
  parallelism_required : bool array;
  tone_pattern : bool list list;
  rhythm_weight : float;
}

(** 七言绝句评价标准 *)
type qiyan_jueju_standards = {
  line_count : int;
  char_per_line : int;
  rhyme_scheme : bool array;
  parallelism_required : bool array;
  tone_pattern : bool list list;
  rhythm_weight : float;
}

(** {1 声调分析类型} *)

type tone_info = {
  char : char;
  tone : rhyme_category;
  is_tonal_mismatch : bool;
}

type tone_analysis_report = {
  verse : string;
  tone_infos : tone_info list;
  tone_pattern : bool list;
  pattern_score : float;
  violations : int;
}

(** {1 综合分析类型} *)

type verse_summary = {
  verse : string;
  rhyme_info : rhyme_analysis_report;
  tone_info : tone_analysis_report;
  artistic_info : artistic_report;
}

type comprehensive_analysis = {
  poem_text : string list;
  form : poetry_form;
  verse_summaries : verse_summary list;
  overall_rhyme : poem_rhyme_analysis;
  overall_artistic : artistic_scores;
  final_grade : evaluation_grade;
  critique : string;
}

(** {1 类型转换和工具函数} *)

val rhyme_category_to_string : rhyme_category -> string
val rhyme_group_to_string : rhyme_group -> string
val dimension_to_string : artistic_dimension -> string
val grade_to_string : evaluation_grade -> string
val form_to_string : poetry_form -> string

val rhyme_category_equal : rhyme_category -> rhyme_category -> bool
val rhyme_group_equal : rhyme_group -> rhyme_group -> bool

val is_ping_sheng : rhyme_category -> bool
val is_ze_sheng : rhyme_category -> bool

val create_empty_report : string -> artistic_report
val calculate_overall_score : artistic_report -> float
val update_overall_grade : artistic_report -> artistic_report

(** {1 配置模块} *)

module WeightConfig : sig
  val rhyme_weight : float
  val tone_weight : float
  val parallelism_weight : float
  val imagery_weight : float
  val rhythm_weight : float
  val elegance_weight : float
  val all_weights : float list
  val calculate_weighted_score : artistic_report -> float
end

module ReportValidator : sig
  val is_valid_score : float -> bool
  val validate_report : artistic_report -> bool
  val clamp_score : float -> float
  val normalize_report : artistic_report -> artistic_report
end