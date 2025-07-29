(** 骆言诗词统一类型定义模块 - 接口文件

    Author: Alpha, 主要工作代理 - 负责功能实现和技术债务处理 Phase: 1.2.1 核心类型统一 (Poetry模块重构Phase 1) Date: 2025-07-29

    此模块是整个Poetry系统的统一类型定义中心的接口声明。 提供公共类型和函数的声明，隐藏内部实现细节。 *)

(** === 基础字符和文本类型 === *)

type chinese_character = string
type verse_line = string
type poem_text = verse_line list

(** === 音韵分类类型 === *)

type rhyme_category = PingSheng | ZeSheng | ShangSheng | QuSheng | RuSheng

type rhyme_group =
  | AnRhyme
  | SiRhyme
  | TianRhyme
  | WangRhyme
  | QuRhyme
  | YuRhyme
  | HuaRhyme
  | FengRhyme
  | YueRhyme
  | XueRhyme
  | JiangRhyme
  | HuiRhyme
  | UnknownRhyme

(** === 韵律数据类型 === *)

type rhyme_data_entry = {
  character : string;
  category : rhyme_category;
  group : rhyme_group;
  variants : string list;
  usage_frequency : float;
}

type rhyme_match_result = { is_match : bool; match_quality : float; match_reason : string }

type char_rhyme_info = {
  character : string;
  rhyme_category : rhyme_category;
  rhyme_group : rhyme_group;
  confidence : float;
}

type verse_rhyme_analysis = {
  verse_text : string;
  rhyme_ending : string option;
  dominant_rhyme_group : rhyme_group;
  dominant_rhyme_category : rhyme_category;
  char_analysis : char_rhyme_info list;
  rhyme_quality_score : float;
}

type poem_rhyme_analysis = {
  verses : string list;
  verse_analyses : verse_rhyme_analysis list;
  overall_rhyme_groups : rhyme_group list;
  overall_rhyme_categories : rhyme_category list;
  rhyme_consistency_score : float;
  artistic_quality_score : float;
  suggestions : string list;
}

type rhyme_suggestion = {
  suggestion_type : string;
  original_char : string;
  suggested_chars : string list;
  reason : string;
  improvement_score : float;
}

(** === 艺术性评价类型 === *)

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

type evaluation_grade = Excellent | Good | Fair | Poor

type artistic_evaluation_result = {
  overall_grade : evaluation_grade;
  dimension_scores : (artistic_dimension * float) list;
  detailed_feedback : string;
  suggestions : string list;
}

type artistic_report = {
  verse : string;
  rhyme_score : float;
  tone_score : float;
  parallelism_score : float;
  imagery_score : float;
  rhythm_score : float;
  elegance_score : float;
  overall_grade : evaluation_grade;
  detailed_feedback : string;
  suggestions : string list;
}

type artistic_scores = {
  rhyme_harmony : float;
  tonal_balance : float;
  parallelism : float;
  imagery : float;
  rhythm : float;
  elegance : float;
  overall : float;
}

(** === 诗词形式类型 === *)

type poem_form = LuShi | JueShi | GuFengShi | CiPai of string | FuTi

type poetry_form =
  | SiYanPianTi
  | WuYanLuShi
  | QiYanJueJu
  | CiPai of string
  | ModernPoetry
  | SiYanParallelProse

type meter_pattern = PingZe_Pattern of bool list | Free_Verse

(** === 诗词标准和评价标准类型 === *)

type siyan_artistic_standards = {
  char_count : int;
  tone_pattern : bool list;
  parallelism_required : bool;
  rhythm_weight : float;
}

type wuyan_lushi_standards = {
  line_count : int;
  char_per_line : int;
  rhyme_scheme : bool array;
  parallelism_required : bool array;
  tone_pattern : bool list list;
  rhythm_weight : float;
}

type qiyan_jueju_standards = {
  line_count : int;
  char_per_line : int;
  rhyme_scheme : bool array;
  parallelism_required : bool array;
  tone_pattern : bool list list;
  rhythm_weight : float;
}

(** === 分析查询类型 === *)

type analysis_depth = Surface | Moderate | Deep
type rhyme_query = { text : string; target_rhyme : string option; analysis_depth : analysis_depth }

type artistic_query = {
  poem : poem_text;
  form : poem_form option;
  criteria : artistic_dimension list;
}

(** === 声调信息类型 === *)

type tone_info = { char : char; tone : rhyme_category; is_tonal_mismatch : bool }

type tone_analysis_report = {
  verse : string;
  tone_pattern : bool list;
  tone_infos : tone_info list;
  balance_score : float;
  adherence_score : float;
}

(** === 综合分析类型 === *)

type verse_summary = {
  verse : string;
  rhyme_info : verse_rhyme_analysis;
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

(** === 结果和响应类型 === *)

type 'a analysis_result = Success of 'a | Failure of string | Partial of 'a * string list

type rhyme_analysis_result = {
  matches : (string * rhyme_match_result * float) list;
  suggestions : string list;
  confidence : float;
}

type artistic_analysis_result = {
  evaluation : artistic_evaluation_result;
  rhyme_analysis : rhyme_analysis_result;
  meter_analysis : meter_pattern option;
}

(** === 错误和异常类型 === *)

type rhyme_error =
  | CharacterNotFound of string
  | InvalidRhymeGroup of string
  | DataCorruption of string
  | ConfigurationError of string
  | AnalysisFailure of string

exception RhymeException of rhyme_error
exception Json_parse_error of string

(** === 数据源和缓存类型 === *)

type data_source_type = JSON_File of string | Memory_Cache | External_API
type cache_policy = No_Cache | LRU_Cache of int | TTL_Cache of int

(** === 配置类型 === *)

type analysis_config = {
  strict_mode : bool;
  cache_policy : cache_policy;
  data_sources : data_source_type list;
  custom_rhyme_groups : (string * rhyme_group) list;
}

(** === 数据库类型 === *)

type rhyme_data_item = {
  character : string;
  category : rhyme_category;
  group : rhyme_group;
  confidence : float;
}

type rhyme_group_data_engine = {
  group : rhyme_group;
  description : string;
  items : rhyme_data_item list;
}

type rhyme_database = {
  groups : rhyme_group_data_engine list;
  version : string;
  metadata : (string * string) list;
}

type rhyme_database_simple = (string * rhyme_category * rhyme_group) list
type rhyme_database_legacy = rhyme_database_simple
type rhyme_group_data = { category : string; characters : string list }

type rhyme_data_file = {
  rhyme_groups : (string * rhyme_group_data) list;
  metadata : (string * string) list;
}

type rhyme_analysis_report = {
  verse : string;
  rhyme_ending : char option;
  rhyme_group : rhyme_group;
  rhyme_category : rhyme_category;
  char_analysis : (char * rhyme_category * rhyme_group) list;
}

(** === 工具函数类型 === *)

type 'a comparison_result = Equal | Greater | Less
type 'a conversion_result = Converted of 'a | Conversion_Failed of string

(** === 类型转换和兼容性函数 === *)

val string_of_rhyme_category : rhyme_category -> string
val string_of_rhyme_group : rhyme_group -> string
val string_of_evaluation_grade : evaluation_grade -> string
val rhyme_category_to_string : rhyme_category -> string
val rhyme_group_to_string : rhyme_group -> string
val string_to_rhyme_category : string -> rhyme_category option
val string_to_rhyme_group : string -> rhyme_group option
val rhyme_category_equal : rhyme_category -> rhyme_category -> bool
val rhyme_group_equal : rhyme_group -> rhyme_group -> bool
val is_ping_sheng : rhyme_category -> bool
val is_ze_sheng : rhyme_category -> bool
val dimension_to_string : artistic_dimension -> string
val poetry_form_to_string : poetry_form -> string
