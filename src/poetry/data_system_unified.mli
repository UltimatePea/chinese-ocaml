(** 骆言诗词统一数据管理系统接口 - Issue #2084 架构整合
 *
 * 此接口整合了129个分散数据文件的核心功能，提供统一的数据管理API。
 *
 * @author Whisky, PR Worker
 * @consolidation_issue #2084
 * @version 1.0 - 统一数据管理系统接口
 *)

(** {1 核心类型重导出} *)

(* 重新导出统一类型定义 *)
include module type of Poetry_core.Types
module DataTypes = Poetry_data_core.Data_types

(** {1 统一数据项定义} *)

type unified_data_item = {
  id : string;
  character : string;
  category : rhyme_category;
  group : rhyme_group;
  tone : tone_pattern option;
  word_class : word_class option;  
  metadata : (string * string) list;
  source : string;
  last_updated : float;
}

(** {1 数据源管理} *)

module DataSource : sig
  (** 数据源类型 *)
  type source_type =
    | RhymeSource of string
    | PoetrySource of string
    | ToneSource of string
    | WordClassSource of string
    | ExternalSource of string

  (** 数据源信息 *)
  type source_info = {
    source_id : string;
    source_type : source_type;
    priority : int;
    description : string;
    loader : unit -> unified_data_item list;
    is_active : bool;
    last_loaded : float;
  }

  (** 注册数据源 *)
  val register_source : source_info -> unit

  (** 获取所有活跃数据源 *)
  val get_active_sources : unit -> source_info list

  (** 按类型获取数据源 *)
  val get_sources_by_type : source_type -> source_info list

  (** 获取数据源统计: (总数, 活跃数, 按类型统计) *)
  val get_source_statistics : unit -> int * int * (string * int) list
end

(** {1 数据加载引擎} *)

module DataLoader : sig
  (** 加载状态 *)
  type load_status = 
    | NotLoaded
    | Loading
    | Loaded of int * float  (* 数据条数, 加载时间 *)
    | LoadError of string

  (** 加载所有数据源 *)
  val load_all_data : unit -> bool

  (** 查找字符数据 *)
  val find_character_data : string -> unified_data_item option

  (** 获取加载状态 *)
  val get_load_status : unit -> load_status

  (** 强制重新加载 *)
  val reload_data : unit -> bool
end

(** {1 缓存管理} *)

module CacheManager : sig
  (** 缓存策略 *)
  type cache_strategy = {
    max_size : int;
    ttl_seconds : float;
    eviction_policy : [`LRU | `LFU | `FIFO];
  }

  (** 缓存统计 *)
  type cache_stats = {
    total_requests : int;
    cache_hits : int;
    cache_misses : int;
    hit_rate : float;
    cache_size : int;
  }

  (** 默认缓存策略 *)
  val default_strategy : cache_strategy

  (** 从缓存获取数据 *)
  val get_from_cache : string -> cache_strategy -> unified_data_item option

  (** 添加到缓存 *)
  val add_to_cache : string -> unified_data_item -> cache_strategy -> unit

  (** 获取缓存统计 *)
  val get_cache_statistics : unit -> cache_stats

  (** 清空缓存 *)
  val clear_cache : unit -> unit
end

(** {1 查询引擎} *)

module QueryEngine : sig
  (** 查询条件 *)
  type query_criteria =
    | ByCharacter of string
    | ByGroup of rhyme_group
    | ByCategory of rhyme_category
    | ByWordClass of word_class
    | ByMetadata of string * string
    | CompositeQuery of query_criteria list

  (** 查询结果 *)
  type query_result = {
    items : unified_data_item list;
    total_count : int;
    query_time : float;
    from_cache : bool;
  }

  (** 执行查询 *)
  val execute_query : query_criteria -> query_result
end

(** {1 统一对外API} *)

(** 初始化数据系统 *)
val initialize_data_system : unit -> unit

(** 查找字符数据 *)
val lookup_character_data : string -> unified_data_item option

(** 执行数据查询 *)
val execute_data_query : QueryEngine.query_criteria -> QueryEngine.query_result

(** 获取系统统计信息 *)
val get_data_system_statistics : unit -> (string * string) list

(** 重新加载数据 *)
val reload_data_system : unit -> bool

(** 清空缓存 *)
val clear_system_cache : unit -> unit

(** {1 向后兼容性接口} *)

(** 查找字符数据 (兼容性) *)
val find_character_data : string -> unified_data_item option

(** 获取数据统计 (兼容性) *)
val get_data_statistics : unit -> (string * string) list

(** 重新加载所有数据 (兼容性) *)
val reload_all_data : unit -> bool