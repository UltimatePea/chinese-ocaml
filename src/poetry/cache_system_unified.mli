(** 骆言诗词统一缓存系统接口 - Issue #2084 架构整合
 *
 * 此接口整合了28个分散缓存文件的核心功能，提供统一的缓存管理API。
 *
 * @author Whisky, PR Worker
 * @consolidation_issue #2084
 * @version 1.0 - 统一缓存系统接口
 *)

(** {1 核心类型重导出} *)

(* 重新导出统一类型定义 *)
include module type of Poetry_core.Types

(** {1 缓存条目类型} *)

type 'a cache_entry = {
  key : string;
  value : 'a;
  created_at : float;
  last_accessed : float;
  access_count : int;
  ttl : float option;
  size_bytes : int;
}

(** {1 缓存策略} *)

type eviction_policy = 
  | LRU  (* 最近最少使用 *)
  | LFU  (* 最少使用频率 *)
  | FIFO (* 先进先出 *)
  | TTL  (* 基于生存时间 *)

type cache_config = {
  max_entries : int;
  max_memory_mb : int;
  default_ttl : float option;
  eviction_policy : eviction_policy;
  enable_compression : bool;
  enable_statistics : bool;
}

(** {1 缓存统计} *)

type cache_statistics = {
  total_requests : int;
  hits : int;
  misses : int;
  evictions : int;
  current_entries : int;
  memory_usage_mb : float;
  hit_rate : float;
  average_access_time : float;
  last_cleanup : float;
}

(** {1 缓存核心引擎} *)

module CacheCore : sig
  (** 缓存实例类型 *)
  type 'a cache

  (** 默认配置 *)
  val default_config : cache_config

  (** 创建缓存实例 *)
  val create_cache : string -> cache_config -> 'a cache

  (** 获取缓存条目 *)
  val get : 'a cache -> string -> 'a option

  (** 设置缓存条目 *)
  val set : 'a cache -> string -> 'a -> int -> float option -> unit

  (** 删除缓存条目 *)
  val remove : 'a cache -> string -> bool

  (** 清空缓存 *)
  val clear : 'a cache -> unit

  (** 获取缓存统计 *)
  val get_statistics : 'a cache -> cache_statistics
end

(** {1 专用缓存实例} *)

(** 韵律数据缓存 *)
module RhymeCache : sig
  val get : string -> string option
  val set : string -> string -> unit
  val remove : string -> bool
  val clear : unit -> unit
  val statistics : unit -> cache_statistics
end

(** 艺术评价缓存 *)
module ArtisticCache : sig
  val get : string -> string option  
  val set : string -> string -> unit
  val remove : string -> bool
  val clear : unit -> unit
  val statistics : unit -> cache_statistics
end

(** 数据加载缓存 *)
module DataCache : sig
  val get : string -> string option
  val set : string -> string -> unit
  val remove : string -> bool
  val clear : unit -> unit
  val statistics : unit -> cache_statistics
end

(** {1 缓存管理器} *)

module CacheManager : sig
  (** 清空所有缓存 *)
  val clear_all_caches : unit -> unit

  (** 获取所有缓存统计 *)
  val get_all_statistics : unit -> (string * cache_statistics) list

  (** 执行全局清理 *)
  val global_cleanup : unit -> unit
end

(** {1 统一对外API} *)

(** 通用缓存操作 *)
val cache_get : string -> string -> string option
val cache_set : string -> string -> string -> unit
val cache_remove : string -> string -> bool

(** 获取缓存统计 *)
val get_cache_statistics : string -> cache_statistics option

(** 清空指定缓存 *)
val clear_cache : string -> unit

(** 获取系统统计 *)
val get_system_statistics : unit -> (string * (string * string) list) list

(** 执行全局维护 *)
val perform_maintenance : unit -> unit

(** {1 向后兼容性接口} *)

(** 韵律缓存操作 (兼容性) *)
val rhyme_cache_get : string -> string option
val rhyme_cache_set : string -> string -> unit

(** 艺术评价缓存操作 (兼容性) *)
val artistic_cache_get : string -> string option
val artistic_cache_set : string -> string -> unit

(** 数据缓存操作 (兼容性) *)
val data_cache_get : string -> string option
val data_cache_set : string -> string -> unit

(** 全局缓存操作 (兼容性) *)
val clear_all_caches : unit -> unit
val get_all_cache_stats : unit -> (string * cache_statistics) list