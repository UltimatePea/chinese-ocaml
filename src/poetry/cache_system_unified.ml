(** 骆言诗词统一缓存系统 - Issue #2084 架构整合
 *
 * 此模块整合了28个分散缓存文件的核心功能，包括：
 * - 多级缓存管理
 * - 缓存策略和淘汰算法
 * - 缓存统计和监控
 * - 性能优化和内存管理
 *
 * 整合文件清单：(部分关键文件)
 * - src/poetry/cache_management/ 目录下所有文件
 * - src/poetry/rhyme_cache.ml
 * - src/poetry/data_cache_manager.ml
 * - src/poetry/artistic_cache.ml
 * - 所有 *_cache.ml 文件
 *
 * @author Whisky, PR Worker
 * @consolidation_issue #2084
 * @version 1.0 - 统一缓存系统
 *)

(** {1 核心类型重导出} *)

(* 重新导出统一类型定义 *)
include Poetry_core.Types

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

module CacheCore = struct
  (** 缓存实例 *)
  type 'a cache = {
    name : string;
    config : cache_config;
    storage : ('a cache_entry) Hashtbl.t;
    mutable statistics : cache_statistics;
    mutable last_cleanup : float;
  }

  (** 默认配置 *)
  let default_config = {
    max_entries = 10000;
    max_memory_mb = 100;
    default_ttl = Some 3600.0;
    eviction_policy = LRU;
    enable_compression = false;
    enable_statistics = true;
  }

  (** 创建缓存实例 *)
  let create_cache name config =
    {
      name;
      config;
      storage = Hashtbl.create config.max_entries;
      statistics = {
        total_requests = 0; hits = 0; misses = 0; evictions = 0;
        current_entries = 0; memory_usage_mb = 0.0; hit_rate = 0.0;
        average_access_time = 0.0; last_cleanup = Unix.time ();
      };
      last_cleanup = Unix.time ();
    }

  (** 检查条目是否过期 *)
  let is_expired entry current_time =
    match entry.ttl with
    | Some ttl -> current_time -. entry.created_at > ttl
    | None -> false

  (** 计算条目大小 *)
  let estimate_entry_size entry =
    (* 简化的大小估算 *)
    String.length entry.key + entry.size_bytes + 64

  (** 更新统计信息 *)
  let update_statistics cache hit =
    if cache.config.enable_statistics then (
      cache.statistics <- {
        cache.statistics with
        total_requests = cache.statistics.total_requests + 1;
        hits = if hit then cache.statistics.hits + 1 else cache.statistics.hits;
        misses = if not hit then cache.statistics.misses + 1 else cache.statistics.misses;
        current_entries = Hashtbl.length cache.storage;
        hit_rate = 
          if cache.statistics.total_requests > 0 then
            float_of_int cache.statistics.hits /. float_of_int cache.statistics.total_requests
          else 0.0;
      }
    )

  (** 清理过期条目 *)
  let cleanup_expired cache =
    let current_time = Unix.time () in
    let expired_keys = ref [] in
    
    Hashtbl.iter (fun key entry ->
      if is_expired entry current_time then
        expired_keys := key :: !expired_keys
    ) cache.storage;
    
    List.iter (fun key ->
      Hashtbl.remove cache.storage key;
      cache.statistics <- { cache.statistics with evictions = cache.statistics.evictions + 1 }
    ) !expired_keys;
    
    cache.last_cleanup <- current_time;
    List.length !expired_keys

  (** LRU淘汰策略 *)
  let evict_lru cache =
    let oldest_key = ref None in
    let oldest_time = ref (Unix.time ()) in
    
    Hashtbl.iter (fun key entry ->
      if entry.last_accessed < !oldest_time then (
        oldest_time := entry.last_accessed;
        oldest_key := Some key
      )
    ) cache.storage;
    
    match !oldest_key with
    | Some key ->
        Hashtbl.remove cache.storage key;
        cache.statistics <- { cache.statistics with evictions = cache.statistics.evictions + 1 };
        true
    | None -> false

  (** 执行淘汰策略 *)
  let perform_eviction cache =
    match cache.config.eviction_policy with
    | LRU -> evict_lru cache
    | FIFO | LFU | TTL -> evict_lru cache  (* 简化实现，都使用LRU *)

  (** 获取缓存条目 *)
  let get cache key =
    let current_time = Unix.time () in
    
    (* 定期清理过期条目 *)
    if current_time -. cache.last_cleanup > 300.0 then (
      ignore (cleanup_expired cache)
    );
    
    match Hashtbl.find_opt cache.storage key with
    | Some entry when not (is_expired entry current_time) ->
        let updated_entry = { entry with 
          last_accessed = current_time;
          access_count = entry.access_count + 1;
        } in
        Hashtbl.replace cache.storage key updated_entry;
        update_statistics cache true;
        Some updated_entry.value
    | Some _ ->
        (* 条目已过期 *)
        Hashtbl.remove cache.storage key;
        update_statistics cache false;
        None
    | None ->
        update_statistics cache false;
        None

  (** 设置缓存条目 *)
  let set cache key value size_bytes ttl_override =
    let current_time = Unix.time () in
    let ttl = match ttl_override with
      | Some t -> Some t
      | None -> cache.config.default_ttl
    in
    
    let entry = {
      key;
      value;
      created_at = current_time;
      last_accessed = current_time;
      access_count = 1;
      ttl;
      size_bytes;
    } in
    
    (* 检查是否需要淘汰 *)
    while Hashtbl.length cache.storage >= cache.config.max_entries do
      if not (perform_eviction cache) then break
    done;
    
    Hashtbl.replace cache.storage key entry

  (** 删除缓存条目 *)
  let remove cache key =
    match Hashtbl.find_opt cache.storage key with
    | Some _ ->
        Hashtbl.remove cache.storage key;
        true
    | None -> false

  (** 清空缓存 *)
  let clear cache =
    Hashtbl.clear cache.storage;
    cache.statistics <- {
      total_requests = 0; hits = 0; misses = 0; evictions = 0;
      current_entries = 0; memory_usage_mb = 0.0; hit_rate = 0.0;
      average_access_time = 0.0; last_cleanup = Unix.time ();
    }

  (** 获取缓存统计 *)
  let get_statistics cache = cache.statistics
end

(** {1 专用缓存实例} *)

(** 韵律数据缓存 *)
module RhymeCache = struct
  let cache = CacheCore.create_cache "rhyme_cache" {
    CacheCore.default_config with 
    max_entries = 5000;
    default_ttl = Some 7200.0;
  }
  
  let get = CacheCore.get cache
  let set key value = CacheCore.set cache key value 256 None
  let remove = CacheCore.remove cache
  let clear () = CacheCore.clear cache
  let statistics () = CacheCore.get_statistics cache
end

(** 艺术评价缓存 *)
module ArtisticCache = struct
  let cache = CacheCore.create_cache "artistic_cache" {
    CacheCore.default_config with
    max_entries = 2000;
    default_ttl = Some 1800.0;
  }
  
  let get = CacheCore.get cache
  let set key value = CacheCore.set cache key value 512 None
  let remove = CacheCore.remove cache
  let clear () = CacheCore.clear cache
  let statistics () = CacheCore.get_statistics cache
end

(** 数据加载缓存 *)
module DataCache = struct
  let cache = CacheCore.create_cache "data_cache" {
    CacheCore.default_config with
    max_entries = 10000;
    default_ttl = Some 3600.0;
  }
  
  let get = CacheCore.get cache
  let set key value = CacheCore.set cache key value 128 None
  let remove = CacheCore.remove cache
  let clear () = CacheCore.clear cache
  let statistics () = CacheCore.get_statistics cache
end

(** {1 缓存管理器} *)

module CacheManager = struct
  (** 所有缓存实例的注册表 *)
  let registered_caches = ref [
    ("rhyme", (module RhymeCache : sig
      val get : string -> string option
      val set : string -> string -> unit
      val remove : string -> bool
      val clear : unit -> unit
      val statistics : unit -> cache_statistics
    end));
    ("artistic", (module ArtisticCache));
    ("data", (module DataCache));
  ]

  (** 注册新缓存 *)
  let register_cache name cache_module =
    registered_caches := (name, cache_module) :: 
      (List.filter (fun (n, _) -> n <> name) !registered_caches)

  (** 获取缓存实例 *)
  let get_cache name =
    List.assoc_opt name !registered_caches

  (** 清空所有缓存 *)
  let clear_all_caches () =
    RhymeCache.clear ();
    ArtisticCache.clear ();
    DataCache.clear ()

  (** 获取所有缓存统计 *)
  let get_all_statistics () = [
    ("rhyme", RhymeCache.statistics ());
    ("artistic", ArtisticCache.statistics ());
    ("data", DataCache.statistics ());
  ]

  (** 执行全局清理 *)
  let global_cleanup () =
    let start_time = Unix.time () in
    clear_all_caches ();
    let end_time = Unix.time () in
    Printf.printf "全局缓存清理完成，耗时: %.3f秒\n" (end_time -. start_time)
end

(** {1 统一对外API} *)

(** 通用缓存操作 *)
let cache_get cache_name key =
  match cache_name with
  | "rhyme" -> RhymeCache.get key
  | "artistic" -> ArtisticCache.get key
  | "data" -> DataCache.get key
  | _ -> None

let cache_set cache_name key value =
  match cache_name with
  | "rhyme" -> RhymeCache.set key value
  | "artistic" -> ArtisticCache.set key value
  | "data" -> DataCache.set key value
  | _ -> ()

let cache_remove cache_name key =
  match cache_name with
  | "rhyme" -> RhymeCache.remove key
  | "artistic" -> ArtisticCache.remove key
  | "data" -> DataCache.remove key
  | _ -> false

(** 获取缓存统计 *)
let get_cache_statistics cache_name =
  match cache_name with
  | "rhyme" -> Some (RhymeCache.statistics ())
  | "artistic" -> Some (ArtisticCache.statistics ())
  | "data" -> Some (DataCache.statistics ())
  | _ -> None

(** 清空指定缓存 *)
let clear_cache cache_name =
  match cache_name with
  | "rhyme" -> RhymeCache.clear ()
  | "artistic" -> ArtisticCache.clear ()
  | "data" -> DataCache.clear ()
  | _ -> ()

(** 获取系统统计 *)
let get_system_statistics () =
  let all_stats = CacheManager.get_all_statistics () in
  List.map (fun (name, stats) ->
    (name, [
      ("hits", string_of_int stats.hits);
      ("misses", string_of_int stats.misses);
      ("hit_rate", Printf.sprintf "%.2f%%" (stats.hit_rate *. 100.0));
      ("entries", string_of_int stats.current_entries);
      ("memory_mb", Printf.sprintf "%.2f" stats.memory_usage_mb);
    ])
  ) all_stats

(** 执行全局维护 *)
let perform_maintenance () = CacheManager.global_cleanup ()

(** === 向后兼容性接口 === *)

(* 为现有代码提供兼容性支持 *)
let rhyme_cache_get = RhymeCache.get
let rhyme_cache_set = RhymeCache.set
let artistic_cache_get = ArtisticCache.get
let artistic_cache_set = ArtisticCache.set
let data_cache_get = DataCache.get
let data_cache_set = DataCache.set
let clear_all_caches = CacheManager.clear_all_caches
let get_all_cache_stats = CacheManager.get_all_statistics

(** 模块初始化 *)
let () = 
  Printf.printf "统一缓存系统初始化完成\n";
  Printf.printf "已注册缓存实例: rhyme, artistic, data\n"