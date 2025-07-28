(** 韵律核心类型定义模块接口 - 骆言诗词编程特性

    此模块统一定义所有音韵类型，为整个诗词系统提供基础类型支撑。 消除项目中30+文件的类型重复定义问题。

    @author 骆言诗词编程团队
    @version 3.0 - 核心重构版本
    @since 2025-07-25 *)

(** {1 基础音韵类型} *)

type rhyme_category =
  | PingSheng  (** 平声韵 *)
  | ZeSheng  (** 仄声韵 *)
  | ShangSheng  (** 上声韵 *)
  | QuSheng  (** 去声韵 *)
  | RuSheng  (** 入声韵 *)

type rhyme_group =
  | AnRhyme  (** 安韵组 *)
  | SiRhyme  (** 思韵组 *)
  | TianRhyme  (** 天韵组 *)
  | WangRhyme  (** 望韵组 *)
  | QuRhyme  (** 去韵组 *)
  | YuRhyme  (** 鱼韵组 *)
  | HuaRhyme  (** 花韵组 *)
  | FengRhyme  (** 风韵组 *)
  | YueRhyme  (** 月韵组 *)
  | XueRhyme  (** 雪韵组 *)
  | JiangRhyme  (** 江韵组 *)
  | HuiRhyme  (** 灰韵组 *)
  | UnknownRhyme  (** 未知韵组 *)

(** {2 分析报告类型} *)

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

(** {3 数据结构类型} *)

type rhyme_data_entry = {
  character : string;
  category : rhyme_category;
  group : rhyme_group;
  variants : string list;
  usage_frequency : float;
}

type rhyme_group_data = {
  group_name : rhyme_group;
  group_description : string;
  entries : rhyme_data_entry list;
  example_poems : string list;
}

(** {4 配置和选项类型} *)

type analysis_config = {
  strict_mode : bool;
  modern_adaptation : bool;
  confidence_threshold : float;
  enable_suggestions : bool;
}

type data_config = {
  data_sources : string list;
  cache_enabled : bool;
  cache_size_limit : int;
  auto_reload : bool;
}

(** {5 错误和异常类型} *)

type rhyme_error =
  | CharacterNotFound of string
  | InvalidRhymeGroup of string
  | DataCorruption of string
  | ConfigurationError of string
  | AnalysisFailure of string

exception RhymeException of rhyme_error

(** {6 辅助类型定义} *)

type rhyme_match_result = { is_match : bool; match_quality : float; match_reason : string }

type rhyme_suggestion = {
  suggestion_type : string;
  original_char : string;
  suggested_chars : string list;
  reason : string;
  improvement_score : float;
}

(** {7 JSON兼容类型} *)

type json_config = { pretty_print : bool; include_metadata : bool; compression_level : int }
type simple_rhyme_info = { char : string; category : string; group : string }

(** {8 兼容性类型定义} *)

type rhyme_data_item = {
  character : string;
  category : rhyme_category;
  group : rhyme_group;
  tone_value : int option;
  frequency : float option;
  source : string;
}

type compat_rhyme_group_data = {
  group : rhyme_group;
  items : rhyme_data_item list;
  metadata : (string * string) list;
}

type rhyme_database = {
  groups : compat_rhyme_group_data list;
  version : string;
  last_updated : string;
  sources : string list;
}

(** {9 兼容性工具函数} *)

val rhyme_category_to_string : rhyme_category -> string
val string_to_rhyme_category : string -> rhyme_category option
val rhyme_group_to_string : rhyme_group -> string
val string_to_rhyme_group : string -> rhyme_group option
val create_rhyme_item : string -> rhyme_category -> rhyme_group -> rhyme_data_item

val create_enhanced_rhyme_item :
  string ->
  rhyme_category ->
  rhyme_group ->
  ?tone_value:int ->
  ?frequency:float ->
  source:string ->
  unit ->
  rhyme_data_item

val compare_rhyme_items : rhyme_data_item -> rhyme_data_item -> int
val create_empty_database : unit -> rhyme_database

val create_rhyme_group_data :
  rhyme_group -> rhyme_data_item list -> (string * string) list -> compat_rhyme_group_data

val get_characters_from_group : compat_rhyme_group_data -> string list
val filter_by_category : rhyme_category -> rhyme_data_item list -> rhyme_data_item list
val filter_by_group : rhyme_group -> rhyme_data_item list -> rhyme_data_item list
val count_items_by_category : rhyme_database -> rhyme_category -> int
val count_items_by_group : rhyme_database -> rhyme_group -> int
val find_character_in_database : rhyme_database -> string -> rhyme_data_item option
val validate_rhyme_data_item : rhyme_data_item -> bool
val validate_rhyme_database : rhyme_database -> bool
