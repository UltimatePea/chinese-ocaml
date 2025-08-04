(** 骆言诗词统一类型定义模块接口 - Issue #2084 Phase 1 架构整合
    
    Author: Whisky, PR Worker - Poetry模块架构整合
    Date: 2025-08-04
    
    本模块接口定义了Poetry系统的所有核心类型，作为系统架构整合的基础。
    所有类型定义统一在此，消除重复定义，建立单一数据源。 *)

(** === 基础诗词文本类型 === *)

type chinese_character = string
(** UTF-8编码的单个中文字符 *)

type verse_line = string 
(** 诗句行，可包含多个字符 *)

type poem_text = verse_line list
(** 完整诗篇，由多行构成 *)

(** === 音韵分类类型 === *)

type rhyme_category =
  | PingSheng   (** 平声韵 *)
  | ZeSheng     (** 仄声韵 *)
  | ShangSheng  (** 上声韵 *)
  | QuSheng     (** 去声韵 *)
  | RuSheng     (** 入声韵 *)

type rhyme_group =  
  | AnRhyme      (** 安韵组 *)
  | SiRhyme      (** 思韵组 *)
  | TianRhyme    (** 天韵组 *)
  | WangRhyme    (** 望韵组 *)
  | QuRhyme      (** 去韵组 *)
  | YuRhyme      (** 鱼韵组 *)
  | HuaRhyme     (** 花韵组 *)
  | FengRhyme    (** 风韵组 *)
  | YueRhyme     (** 月韵组 *)
  | XueRhyme     (** 雪韵组 *)
  | JiangRhyme   (** 江韵组 *)
  | HuiRhyme     (** 灰韵组 *)
  | UnknownRhyme (** 未知韵组 *)

(** === 韵律数据结构类型 === *)

type rhyme_data_entry = {
  character : string;
  category : rhyme_category;
  group : rhyme_group;
  variants : string list;
  usage_frequency : float;
}

type char_rhyme_info = {
  character : string;
  rhyme_category : rhyme_category;
  rhyme_group : rhyme_group;  
  confidence : float;
}

type rhyme_match_result = {
  is_match : bool;
  match_quality : float;
  match_reason : string;
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

(** === 艺术性评价类型 === *)

type artistic_dimension =
  | RhymeHarmony       (** 韵律和谐 *)
  | TonalBalance       (** 声调平衡 *)
  | Parallelism        (** 对仗工整 *)
  | Imagery            (** 意象深度 *)
  | Rhythm             (** 节奏感 *)
  | Elegance           (** 雅致程度 *)
  | ClassicalElegance  (** 古典雅致 *)
  | ModernInnovation   (** 现代创新 *)
  | CulturalDepth      (** 文化深度 *)
  | EmotionalResonance (** 情感共鸣 *)
  | IntellectualDepth  (** 理性深度 *)

type evaluation_grade =
  | Excellent  (** 上品 *)
  | Good       (** 中品 *)
  | Fair       (** 下品 *)
  | Poor       (** 不入流 *)

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

type poetry_form =
  | SiYanPianTi         (** 四言骈体 *)
  | WuYanLuShi         (** 五言律诗 *)
  | QiYanJueJu         (** 七言绝句 *)
  | CiPai of string    (** 词牌格律 *)
  | ModernPoetry       (** 现代诗 *)
  | SiYanParallelProse (** 四言排律 *)

type poem_form =
  | LuShi      (** 律诗 *)
  | JueShi     (** 绝句 *)
  | GuFengShi  (** 古风诗 *)
  | CiPai of string (** 词牌 *)
  | FuTi       (** 赋体 *)

type meter_pattern =
  | PingZe_Pattern of bool list (** 平仄格律模式 *)
  | Free_Verse                  (** 自由诗 *)

(** === 诗词标准类型 === *)

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

(** === 声调分析类型 === *)

type tone_info = { 
  char : char; 
  tone : rhyme_category; 
  is_tonal_mismatch : bool 
}

type tone_analysis_report = {
  verse : string;
  tone_pattern : bool list;
  tone_infos : tone_info list;
  balance_score : float;
  adherence_score : float;
}

(** === 查询和分析类型 === *)

type analysis_depth =
  | Surface  (** 表面分析 *)
  | Moderate (** 中等分析 *)
  | Deep     (** 深度分析 *)

type rhyme_query = { 
  text : string; 
  target_rhyme : string option; 
  analysis_depth : analysis_depth 
}

type artistic_query = {
  poem : poem_text;
  form : poem_form option;
  criteria : artistic_dimension list;
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

(** === 结果类型 === *)

type 'a analysis_result =
  | Success of 'a
  | Failure of string
  | Partial of 'a * string list

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

(** === 数据管理类型 === *)

type data_source_type = 
  | JSON_File of string 
  | Memory_Cache 
  | External_API

type cache_policy =
  | No_Cache
  | LRU_Cache of int
  | TTL_Cache of int

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

type rhyme_group_data = { 
  category : string; 
  characters : string list 
}

type rhyme_data_file = {
  rhyme_groups : (string * rhyme_group_data) list;
  metadata : (string * string) list;
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

(** === 建议类型 === *)

type rhyme_suggestion = {
  suggestion_type : string;
  original_char : string;
  suggested_chars : string list;
  reason : string;
  improvement_score : float;
}

(** === 向后兼容类型别名 === *)

type rhyme_analysis_report = {
  verse : string;
  rhyme_ending : char option;
  rhyme_group : rhyme_group;
  rhyme_category : rhyme_category;
  char_analysis : (char * rhyme_category * rhyme_group) list;
}

type rhyme_database_legacy = rhyme_database_simple

(** === 类型转换和工具函数 === *)

val string_of_rhyme_category : rhyme_category -> string
val string_of_rhyme_group : rhyme_group -> string
val string_of_evaluation_grade : evaluation_grade -> string
val string_of_artistic_dimension : artistic_dimension -> string
val string_of_poetry_form : poetry_form -> string

val string_to_rhyme_category : string -> rhyme_category option
val string_to_rhyme_group : string -> rhyme_group option

val rhyme_category_equal : rhyme_category -> rhyme_category -> bool
val rhyme_group_equal : rhyme_group -> rhyme_group -> bool

val is_ping_sheng : rhyme_category -> bool
val is_ze_sheng : rhyme_category -> bool

(** === 向后兼容别名 === *)

val rhyme_category_to_string : rhyme_category -> string
val rhyme_group_to_string : rhyme_group -> string
val dimension_to_string : artistic_dimension -> string
val poetry_form_to_string : poetry_form -> string