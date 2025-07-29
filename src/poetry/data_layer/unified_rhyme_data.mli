(** 骆言诗词统一韵律数据模块接口 - Poetry模块整合优化 Fix #1707
    
    此模块接口定义了统一的韵律数据访问和管理功能。
    提供完整的韵律数据查询、匹配和分析服务。
    
    Author: Alpha, 主要工作代理 *)

open Unified_data_types

(** {1 韵律数据结构} *)

(** 韵律数据条目扩展 - 包含更多元数据 *)
type extended_rhyme_entry = {
  base : rhyme_data_entry;        (** 基础韵律信息 *)
  pinyin : string option;         (** 拼音注音 *)
  traditional : string option;    (** 繁体字形式 *)
  meaning : string option;        (** 字义说明 *)
  frequency_rank : int option;    (** 使用频率排名 *)
  historical_variants : string list; (** 历史异体字 *)
}

(** 韵组数据结构 *)
type rhyme_group_data = {
  group_name : rhyme_group;       (** 韵组名称 *)
  description : string;           (** 韵组描述 *)
  entries : extended_rhyme_entry list; (** 韵组字符列表 *)
  example_poems : string list;    (** 示例诗句 *)
  historical_usage : string;      (** 历史使用情况 *)
}

(** 韵律数据源标识 *)
type data_source_info = {
  source_name : string;           (** 数据源名称 *)
  version : string;               (** 版本信息 *)
  last_updated : string;          (** 最后更新时间 *)
  reliability : float;            (** 可靠性评分 0.0-1.0 *)
}

(** 统一韵律数据库 *)
type unified_rhyme_database = {
  groups : rhyme_group_data list;           (** 所有韵组数据 *)
  character_index : (string, extended_rhyme_entry) Hashtbl.t; (** 字符索引 *)
  group_index : (rhyme_group, rhyme_group_data) Hashtbl.t;    (** 韵组索引 *)
  category_index : (rhyme_category, extended_rhyme_entry list) Hashtbl.t; (** 声韵索引 *)
  sources : data_source_info list;          (** 数据源信息 *)
  metadata : (string * string) list;        (** 元数据 *)
}

(** 数据库统计信息 *)
type database_statistics = {
  total_characters : int;
  total_groups : int;
  category_distribution : (rhyme_category * int) list;
  group_distribution : (rhyme_group * int) list;
  source_distribution : (string * int) list;
  completeness_score : float;
}

(** {1 数据库访问} *)

val get_database : unit -> unified_rhyme_database
(** 获取统一韵律数据库实例 *)

val get_statistics : unit -> database_statistics
(** 获取数据库统计信息 *)

(** {1 基础数据访问} *)

val find_character_info : string -> extended_rhyme_entry option
(** 根据字符查找韵律信息 *)

val get_characters_by_group : rhyme_group -> string list
(** 根据韵组获取所有字符 *)

val get_characters_by_category : rhyme_category -> string list
(** 根据声韵类别获取所有字符 *)

val get_group_info : rhyme_group -> rhyme_group_data option
(** 获取韵组详细信息 *)

val get_all_groups : unit -> rhyme_group_data list
(** 获取所有韵组 *)

(** {1 韵律匹配和检查} *)

val is_character_in_group : string -> rhyme_group -> bool
(** 检查字符是否在指定韵组 *)

val are_characters_rhyming : string -> string -> bool
(** 检查两个字符是否同韵 *)

val get_rhyme_match_result : string -> string -> rhyme_match_result
(** 获取字符的韵律匹配结果 *)

val get_rhyme_suggestions : string -> string list
(** 获取韵组建议 *)

(** {1 高级查询接口} *)

val fuzzy_rhyme_match : string -> rhyme_group -> float -> rhyme_match_result option
(** 模糊韵律匹配 - 支持近似押韵 *)

val analyze_verse_rhyme : string -> verse_rhyme_analysis
(** 获取诗句的韵律分析 *)

(** {1 向后兼容接口} *)

val legacy_get_rhyme_data : unit -> (string * rhyme_category * rhyme_group) list
(** 兼容旧版本的简单数据访问 *)

val legacy_an_rhyme_data : (string * rhyme_category * rhyme_group) list
(** 兼容旧版本的安韵组数据 *)

val legacy_si_rhyme_data : (string * rhyme_category * rhyme_group) list
(** 兼容旧版本的思韵组数据 *)

val legacy_tian_rhyme_data : (string * rhyme_category * rhyme_group) list
(** 兼容旧版本的天韵组数据 *)

val legacy_hua_rhyme_data : (string * rhyme_category * rhyme_group) list
(** 兼容旧版本的花韵组数据 *)

val legacy_yue_rhyme_data : (string * rhyme_category * rhyme_group) list
(** 兼容旧版本的月韵组数据 *)