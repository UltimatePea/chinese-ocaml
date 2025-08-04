(** 骆言诗词类型整合模块 - 统一诗词分析类型定义

    此模块整合了诗词分析系统中的所有核心类型定义， 包括音韵类型、艺术性评价类型、数据结构等。

    Phase 1-A 韵律系统整合：将8个重复模块的类型定义统一至此处，作为唯一权威源。
    消除技术债务：rhythm_analyzer.mli, rhyme_types.mli, meter_types.mli等重复定义。

    @author 骆言诗词编程团队 + Whisky, PR Worker (Phase 1-A 整合)
    @version 3.0 - Phase 1-A 韵律系统整合版本
    @since 2025-07-24
    @updated 2025-08-04 - Phase 1-A 实施 *)

(** {1 核心音韵类型} *)

(* 使用中央类型定义，消除重复 *)
(* Consolidated types - replacing Poetry_core references *)
type rhyme_category = 
  | PingSheng    (** 平声：第一、二声 *)
  | ShangSheng   (** 上声：第三声 *)
  | QuSheng      (** 去声：第四声 *)
  | RuSheng      (** 入声：古代汉语特有 *)
  | ZeSheng      (** 仄声：统称 *)

type rhyme_group = 
  | AnRhyme | SiRhyme | TianRhyme | WangRhyme | QuRhyme 
  | YuRhyme | HuaRhyme | FengRhyme | YueRhyme | JiangRhyme 
  | HuiRhyme | UnknownRhyme

(** Phase 1-A: 统一韵律字符信息类型 - 整合多模块重复定义 *)
type rhyme_character = {
  character: string;
  rhyme_category: rhyme_category;
  rhyme_group: rhyme_group;
  confidence: float;
  variants: string list;            (** 异体字列表 *)
  usage_frequency: float;           (** 使用频率 *)
  is_common: bool;                  (** 是否常用字 *)
  pinyin: string option;            (** 拼音注音 *)
}
(** 韵律字符完整信息 - Phase 1-A 统一定义 *)

(** Phase 1-A: 统一查询结果类型 - 整合4个查询引擎的重复定义 *)
type query_result = 
  | Found of rhyme_character         (** 找到匹配字符 *)
  | NotFound of string              (** 未找到，返回原字符 *)
  | MultipleMatches of rhyme_character list  (** 多个匹配结果 *)
(** 统一查询结果类型 - Phase 1-A 标准 *)

(** Phase 1-A: 韵组数据结构 - 统一定义 *)
type rhyme_group_data = {
  group_id: rhyme_group;
  group_name: string;
  description: string;
  ping_sheng_chars: string list;     (** 平声字符 *)
  ze_sheng_chars: string list;       (** 仄声字符 *)
  all_characters: rhyme_character list;  (** 所有字符详细信息 *)
  example_poems: string list;        (** 示例诗句 *)
}
(** 韵组完整数据 - Phase 1-A 统一标准 *)

(** {1 Phase 1-A: 向后兼容性映射} *)

(** 向后兼容：保留原 char_rhyme_info 别名 *)
type char_rhyme_info = {
  character: string;
  rhyme_category: rhyme_category;
  rhyme_group: rhyme_group;
  confidence: float;
}

(** Phase 1-A: 向后兼容映射模块 *)
module Legacy_Types : sig
  (** rhyme_types.mli 兼容映射 *)
  type tone_category = rhyme_category
  
  (** unified_tone_data.mli 兼容映射 *)
  type tone_type = Ping | Shang | Qu | Ru
  
  (** meter_types.mli 部分兼容 *)
  type meter_rhyme_group = rhyme_group
  type meter_rhyme_category = rhyme_category
end

(** Phase 1-A: 类型转换函数 *)
val rhyme_character_to_char_info : rhyme_character -> char_rhyme_info
val char_info_to_rhyme_character : char_rhyme_info -> rhyme_character
val tone_category_to_legacy_tone : rhyme_category -> Legacy_Types.tone_type option

type verse_rhyme_analysis = {
  verse_text: string;
  character_analyses: char_rhyme_info list;
  rhyme_pattern: bool list;
  pattern_compliance: float;
}

type poem_rhyme_analysis = {
  verses: verse_rhyme_analysis list;
  overall_pattern: bool array;
  consistency_score: float;
  detected_scheme: string;
}

(* Legacy compatibility types - to be removed in future versions *)
type rhyme_analysis_report = {
  verse : string;
  rhyme_ending : char option;
  rhyme_group : rhyme_group;
  rhyme_category : rhyme_category;
  char_analysis : (char * rhyme_category * rhyme_group) list;
}
(** 韵律分析报告 - 向后兼容类型，将在未来版本中移除 *)

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
type evaluation_grade = Excellent | Good | Average | Fair | Poor

type artistic_report = {
  verses : string;  (* Changed from verse to verses to match usage *)
  rhyme_score : float;
  tone_score : float;
  parallelism_score : float;
  imagery_score : float;
  rhythm_score : float;
  elegance_score : float;
  overall_grade : evaluation_grade;
  detailed_feedback : string;  (* Added missing field *)
  suggestions : string list;
}
(** 艺术性评价报告 *)

type artistic_scores = {
  rhyme_harmony : float;
  tonal_balance : float;
  parallelism : float;
  imagery : float;
  rhythm : float;
  elegance : float;
}
(** 艺术性分数记录 *)

(** {1 诗词形式定义} *)

(** 诗词形式 *)
type poetry_form =
  | SiYanPianTi  (** 四言骈体 *)
  | WuYanLuShi  (** 五言律诗 *)
  | QiYanJueJu  (** 七言绝句 *)
  | CiPai of string  (** 词牌 *)
  | ModernPoetry  (** 现代诗 *)
  | SiYanParallelProse  (** 四言骈体散文 *)

type siyan_artistic_standards = {
  char_count : int;
  tone_pattern : bool list;
  parallelism_required : bool;
  rhythm_weight : float;
}
(** 四言骈体评价标准 *)

type wuyan_lushi_standards = {
  line_count : int;
  char_per_line : int;
  rhyme_scheme : bool array;
  parallelism_required : bool array;
  tone_pattern : bool list list;
  rhythm_weight : float;
}
(** 五言律诗评价标准 *)

type qiyan_jueju_standards = {
  line_count : int;
  char_per_line : int;
  rhyme_scheme : bool array;
  parallelism_required : bool array;
  tone_pattern : bool list list;
  rhythm_weight : float;
}
(** 七言绝句评价标准 *)

(** {1 声调分析类型} *)

type tone_info = { char : char; tone : rhyme_category; is_tonal_mismatch : bool }

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
