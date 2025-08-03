(** 统一数据管理器API接口 - 整合版本
    
    将原本分离的data_manager_*模块整合为单一模块接口，减少文件数量
    同时保持所有功能完整性。
                                                           
    @author Whisky, PR Worker - Issue #2084 诗词模块整合
    @version 4.0 - 整合版本
    @since 2025-08-03 - 文件整合Phase 1
    @fix_issue #2084 *)

(** {1 核心数据类型定义} *)

type unified_data_item = {
  character : string;
  category : Poetry_core.Json_core.rhyme_category;
  group : Poetry_core.Json_core.rhyme_group;
  metadata : (string * string) list;
}

type data_source_id =
  | RhymeData of string
  | PoetryData of string
  | ToneData of string
  | WordClassData of string

type query_criteria =
  | ByCharacter of string
  | ByCategory of Poetry_core.Json_core.rhyme_category
  | ByGroup of Poetry_core.Json_core.rhyme_group
  | BySource of data_source_id
  | CompositeQuery of query_criteria list

type data_error =
  | FileNotFound of string
  | ParseError of string * string
  | ValidationError of string * string

type 'a data_result = Success of 'a | Error of data_error

type cache_strategy = {
  enable_cache : bool;
  max_cache_size : int;
  ttl_seconds : float;
  eviction_policy : [ `LRU | `LFU | `FIFO ];
}

type cache_statistics = {
  total_queries : int;
  cache_hits : int;
  cache_misses : int;
  cache_size : int;
  hit_rate : float;
  last_cleanup : float;
}

(** {1 核心查询API} *)

val query_data : query_criteria -> unified_data_item list data_result
(** 根据查询条件获取数据 *)

(** {1 数据源管理接口} *)

val register_source : data_source_id -> (unit -> unified_data_item list data_result) -> int -> string -> unit data_result
(** 注册数据源 *)

val get_registered_source : data_source_id -> ((unit -> unified_data_item list data_result) * int * string * float) option
(** 获取已注册的数据源 *)

val get_all_registered_sources : unit -> (data_source_id * int * string * float) list
(** 获取所有已注册的数据源列表 *)

(** {1 直接查找接口} *)

val lookup_character : string -> unified_data_item option data_result
(** 按字符查找 *)

val lookup_characters_by_group : Poetry_core.Json_core.rhyme_group -> string list data_result
(** 按韵组查找字符列表 *)

val lookup_characters_by_category : Poetry_core.Json_core.rhyme_category -> string list data_result
(** 按韵类查找字符列表 *)

(** {1 缓存管理接口} *)

val get_statistics : unit -> cache_statistics
(** 获取缓存统计信息 *)

val configure : cache_strategy -> unit data_result
(** 配置缓存策略 *)

val get_cache_config : unit -> cache_strategy
(** 获取当前缓存配置 *)

(** {1 向后兼容性接口} *)

val get_char_rhyme_info : string -> (string * Poetry_core.Json_core.rhyme_category * Poetry_core.Json_core.rhyme_group) option
(** 获取字符韵律信息（兼容接口）*)

val is_char_in_database : string -> bool
(** 检查字符是否在数据库中 *)

val get_legacy_rhyme_database : (unit -> unified_data_item list) -> (string * Poetry_core.Json_core.rhyme_category * Poetry_core.Json_core.rhyme_group) list
(** 获取传统格式的韵律数据库 *)

val convert_to_legacy_format : unified_data_item list -> (string * Poetry_core.Json_core.rhyme_category * Poetry_core.Json_core.rhyme_group) list
(** 转换为传统格式 *)

val convert_from_legacy_format : (string * Poetry_core.Json_core.rhyme_category * Poetry_core.Json_core.rhyme_group) list -> unified_data_item list
(** 从传统格式转换 *)

val legacy_query_by_character : string -> unified_data_item list option
(** 传统字符查询接口 *)

val legacy_query_by_group : Poetry_core.Json_core.rhyme_group -> unified_data_item list option
(** 传统韵组查询接口 *)

val legacy_query_by_category : Poetry_core.Json_core.rhyme_category -> unified_data_item list option
(** 传统韵类查询接口 *)

val legacy_error_to_string : data_error -> string
(** 错误转字符串（传统接口）*)

(** {1 索引管理} *)

val build_index : data_source_id list -> (unit -> unified_data_item list) -> unit data_result
(** 构建索引 *)

val is_index_built : data_source_id -> bool
(** 检查索引是否已构建 *)

val rebuild_index : data_source_id -> unit data_result
(** 重建索引 *)

val get_index_statistics : unit -> int * int * int
(** 获取索引统计信息 (字符数, 韵组数, 韵类数) *)