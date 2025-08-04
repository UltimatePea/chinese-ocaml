(** 统一数据管理器接口 - 整合版本
    
    将原本分散在多个文件中的数据管理功能整合到单一模块中。
    这个整合遵循Poetry模块整合原则，减少文件数量。
                                                           
    @author Whisky, PR Worker - Poetry模块整合专员
    @version 4.0 - 整合版本
    @since 2025-08-04 - Poetry模块整合Phase 1
    @fix_issue #1999 *)

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

(** {1 主要查询接口} *)

val query_data : query_criteria -> unified_data_item list data_result
(** 主要查询接口，支持多种查询条件 *)

val batch_query : query_criteria list -> unified_data_item list list data_result
(** 批量查询接口 *)

(** {1 数据源管理接口} *)

val register_data_source : 
  data_source_id -> 
  (unit -> unified_data_item list data_result) -> 
  (unified_data_item -> bool) -> 
  (string * string) list -> 
  unit
(** 注册数据源 *)

val get_registered_sources : unit -> data_source_id list
(** 获取已注册的数据源列表 *)

val unregister_data_source : data_source_id -> unit
(** 注销数据源 *)

(** {1 直接查找接口} *)

val lookup_by_character : string -> unified_data_item option data_result
(** 根据字符查找 *)

val lookup_by_group : Poetry_core.Json_core.rhyme_group -> string list data_result
(** 根据韵组查找字符列表 *)

val lookup_by_category : Poetry_core.Json_core.rhyme_category -> string list data_result
(** 根据韵类查找字符列表 *)

(** {1 缓存管理接口} *)

val get_cache_statistics : unit -> cache_statistics
(** 获取缓存统计信息 *)

val configure_cache : cache_strategy -> unit
(** 配置缓存策略 *)

val clear_cache : unit -> unit
(** 清空缓存 *)

(** {1 向后兼容性接口} *)

val get_character_rhyme_info : string -> (Poetry_core.Json_core.rhyme_group * Poetry_core.Json_core.rhyme_category) option data_result
(** 获取字符的韵律信息 *)

val find_rhyme_group : string -> Poetry_core.Json_core.rhyme_group option
(** 查找字符的韵组 *)

val find_characters_by_rhyme : Poetry_core.Json_core.rhyme_group -> string list
(** 根据韵组查找字符 *)

(** {1 初始化和管理函数} *)

val initialize_data_manager : unit -> unit
(** 初始化数据管理器 *)

val cleanup_data_manager : unit -> unit
(** 清理数据管理器 *)

val health_check : unit -> bool
(** 健康检查 *)

(** {1 索引管理} *)

val rebuild_indexes : unified_data_item list -> unit
(** 重建索引 *)

val get_index_statistics : unit -> (string * string) list
(** 获取索引统计信息 *)