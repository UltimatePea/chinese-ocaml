(*
 * 统一缓存管理器 - 消除39个重复缓存实现
 * 
 * Author: Alpha, 主要工作代理  
 * Issue: #1605 - 统一缓存系统技术债务清理
 * 优化目标: 减少内存占用30-40%, 提升查找性能20-30%
 *)

type ('k, 'v) cache_strategy =
  | LRU of int (* 最近最少使用，参数为最大容量 *)
  | LFU of int (* 最少使用频率，参数为最大容量 *)
  | TTL of float (* 生存时间，参数为秒数 *)
  | Simple (* 简单哈希表，无淘汰策略 *)

type ('k, 'v) cache_config = {
  initial_size : int;
  max_size : int option;
  strategy : ('k, 'v) cache_strategy;
  name : string; (* 用于监控和调试 *)
}

type ('k, 'v) cache_stats = {
  hits : int;
  misses : int;
  evictions : int;
  size : int;
  hit_rate : float;
}

type ('k, 'v) lru_node = {
  key : 'k;
  mutable value : 'v;
  mutable prev : ('k, 'v) lru_node option;
  mutable next : ('k, 'v) lru_node option;
}

type ('k, 'v) lru_cache_data = {
  data : ('k, ('k, 'v) lru_node) Hashtbl.t;
  mutable head : ('k, 'v) lru_node option;
  mutable tail : ('k, 'v) lru_node option;
  max_size : int;
}

type ('k, 'v) lfu_cache_data = {
  data : ('k, 'v * int ref) Hashtbl.t; (* value * frequency *)
  max_size : int;
}

type ('k, 'v) ttl_cache_data = {
  data : ('k, 'v * float) Hashtbl.t; (* value * expiry_time *)
  ttl : float;
}

type ('k, 'v) cache_impl =
  | SimpleCache of ('k, 'v) Hashtbl.t
  | LRUCache of ('k, 'v) lru_cache_data
  | LFUCache of ('k, 'v) lfu_cache_data
  | TTLCache of ('k, 'v) ttl_cache_data

type ('k, 'v) cache = {
  config : ('k, 'v) cache_config;
  impl : ('k, 'v) cache_impl;
  mutable stats : ('k, 'v) cache_stats;
}

(* 默认配置 - 针对不同使用场景优化 *)
let default_config ?(name = "unnamed") () =
  {
    initial_size = 128;
    (* 增大默认大小，减少rehashing *)
    max_size = Some 1024;
    strategy = LRU 1024;
    name;
  }

let small_cache_config ?(name = "small") () =
  { initial_size = 32; max_size = Some 128; strategy = LRU 128; name }

let large_cache_config ?(name = "large") () =
  { initial_size = 512; max_size = Some 4096; strategy = LRU 4096; name }

let ttl_cache_config ?(name = "ttl") ?(ttl = 300.0) () =
  { initial_size = 256; max_size = None; strategy = TTL ttl; name }

let init_stats () = { hits = 0; misses = 0; evictions = 0; size = 0; hit_rate = 0.0 }

let update_hit_rate stats =
  let total = stats.hits + stats.misses in
  let hit_rate = if total > 0 then float_of_int stats.hits /. float_of_int total else 0.0 in
  { stats with hit_rate }

(* LRU 实现辅助函数 *)
let create_lru_node key value = { key; value; prev = None; next = None }

let remove_lru_node node =
  (match node.prev with Some prev -> prev.next <- node.next | None -> ());
  match node.next with Some next -> next.prev <- node.prev | None -> ()

let add_to_head lru_data node =
  match lru_data.head with
  | None ->
      lru_data.head <- Some node;
      lru_data.tail <- Some node
  | Some head ->
      node.next <- Some head;
      head.prev <- Some node;
      lru_data.head <- Some node

let move_to_head lru_data node =
  remove_lru_node node;
  add_to_head lru_data node

let remove_tail lru_data =
  match lru_data.tail with
  | None -> None
  | Some tail ->
      (match tail.prev with
      | None ->
          lru_data.head <- None;
          lru_data.tail <- None
      | Some prev ->
          prev.next <- None;
          lru_data.tail <- Some prev);
      Some tail

(* 创建缓存 *)
let create config =
  let impl =
    match config.strategy with
    | Simple -> SimpleCache (Hashtbl.create config.initial_size)
    | LRU max_size ->
        LRUCache { data = Hashtbl.create config.initial_size; head = None; tail = None; max_size }
    | LFU max_size -> LFUCache { data = Hashtbl.create config.initial_size; max_size }
    | TTL ttl -> TTLCache { data = Hashtbl.create config.initial_size; ttl }
  in
  { config; impl; stats = init_stats () }

(* 获取当前时间 *)
let current_time () = Unix.time ()

(* 清理过期的TTL条目 *)
let cleanup_ttl_cache data =
  let now = current_time () in
  let to_remove = ref [] in
  Hashtbl.iter (fun key (_, expiry) -> if expiry < now then to_remove := key :: !to_remove) data;
  List.iter (Hashtbl.remove data) !to_remove;
  List.length !to_remove

(* 获取缓存值 *)
let get cache key =
  match cache.impl with
  | SimpleCache data -> (
      match Hashtbl.find_opt data key with
      | Some value ->
          cache.stats <- { cache.stats with hits = cache.stats.hits + 1 } |> update_hit_rate;
          Some value
      | None ->
          cache.stats <- { cache.stats with misses = cache.stats.misses + 1 } |> update_hit_rate;
          None)
  | LRUCache lru_data -> (
      match Hashtbl.find_opt lru_data.data key with
      | Some node ->
          move_to_head lru_data node;
          cache.stats <- { cache.stats with hits = cache.stats.hits + 1 } |> update_hit_rate;
          Some node.value
      | None ->
          cache.stats <- { cache.stats with misses = cache.stats.misses + 1 } |> update_hit_rate;
          None)
  | LFUCache cache_data -> (
      match Hashtbl.find_opt cache_data.data key with
      | Some (value, freq) ->
          incr freq;
          cache.stats <- { cache.stats with hits = cache.stats.hits + 1 } |> update_hit_rate;
          Some value
      | None ->
          cache.stats <- { cache.stats with misses = cache.stats.misses + 1 } |> update_hit_rate;
          None)
  | TTLCache cache_data -> (
      let evicted = cleanup_ttl_cache cache_data.data in
      cache.stats <- { cache.stats with evictions = cache.stats.evictions + evicted };
      match Hashtbl.find_opt cache_data.data key with
      | Some (value, expiry) ->
          if expiry >= current_time () then (
            cache.stats <- { cache.stats with hits = cache.stats.hits + 1 } |> update_hit_rate;
            Some value)
          else (
            Hashtbl.remove cache_data.data key;
            cache.stats <-
              {
                cache.stats with
                misses = cache.stats.misses + 1;
                evictions = cache.stats.evictions + 1;
              }
              |> update_hit_rate;
            None)
      | None ->
          cache.stats <- { cache.stats with misses = cache.stats.misses + 1 } |> update_hit_rate;
          None)

(* 添加缓存值 *)
let put cache key value =
  match cache.impl with
  | SimpleCache data ->
      let was_present = Hashtbl.mem data key in
      Hashtbl.replace data key value;
      if not was_present then cache.stats <- { cache.stats with size = cache.stats.size + 1 }
  | LRUCache lru_data -> (
      match Hashtbl.find_opt lru_data.data key with
      | Some node ->
          (* 更新现有节点 *)
          node.value <- value;
          move_to_head lru_data node
      | None ->
          (* 添加新节点 *)
          let new_node = create_lru_node key value in
          (if Hashtbl.length lru_data.data >= lru_data.max_size then
             (* 需要淘汰最少使用的 *)
             match remove_tail lru_data with
             | Some removed ->
                 Hashtbl.remove lru_data.data removed.key;
                 cache.stats <- { cache.stats with evictions = cache.stats.evictions + 1 }
             | None -> ());
          Hashtbl.replace lru_data.data key new_node;
          add_to_head lru_data new_node;
          cache.stats <- { cache.stats with size = min (cache.stats.size + 1) lru_data.max_size })
  | LFUCache cache_data -> (
      match Hashtbl.find_opt cache_data.data key with
      | Some (_, freq) ->
          (* 更新现有条目 *)
          Hashtbl.replace cache_data.data key (value, freq)
      | None ->
          (* 添加新条目 *)
          if Hashtbl.length cache_data.data >= cache_data.max_size then (
            (* 找到频率最低的条目并删除 *)
            let min_freq = ref max_int in
            let min_key = ref key in
            Hashtbl.iter
              (fun k (_, freq) ->
                if !freq < !min_freq then (
                  min_freq := !freq;
                  min_key := k))
              cache_data.data;
            if !min_key <> key then (
              Hashtbl.remove cache_data.data !min_key;
              cache.stats <- { cache.stats with evictions = cache.stats.evictions + 1 }));
          Hashtbl.replace cache_data.data key (value, ref 1);
          cache.stats <- { cache.stats with size = min (cache.stats.size + 1) cache_data.max_size })
  | TTLCache cache_data ->
      let expiry = current_time () +. cache_data.ttl in
      let was_present = Hashtbl.mem cache_data.data key in
      Hashtbl.replace cache_data.data key (value, expiry);
      if not was_present then cache.stats <- { cache.stats with size = cache.stats.size + 1 }

(* 检查缓存中是否存在key *)
let mem cache key = match get cache key with Some _ -> true | None -> false

(* 删除缓存条目 *)
let remove cache key =
  match cache.impl with
  | SimpleCache data ->
      if Hashtbl.mem data key then (
        Hashtbl.remove data key;
        cache.stats <- { cache.stats with size = cache.stats.size - 1 };
        true)
      else false
  | LRUCache lru_data -> (
      match Hashtbl.find_opt lru_data.data key with
      | Some node ->
          Hashtbl.remove lru_data.data key;
          remove_lru_node node;
          cache.stats <- { cache.stats with size = cache.stats.size - 1 };
          true
      | None -> false)
  | LFUCache cache_data ->
      if Hashtbl.mem cache_data.data key then (
        Hashtbl.remove cache_data.data key;
        cache.stats <- { cache.stats with size = cache.stats.size - 1 };
        true)
      else false
  | TTLCache cache_data ->
      if Hashtbl.mem cache_data.data key then (
        Hashtbl.remove cache_data.data key;
        cache.stats <- { cache.stats with size = cache.stats.size - 1 };
        true)
      else false

(* 清空缓存 *)
let clear cache =
  match cache.impl with
  | SimpleCache data -> Hashtbl.clear data
  | LRUCache lru_data ->
      Hashtbl.clear lru_data.data;
      lru_data.head <- None;
      lru_data.tail <- None
  | LFUCache cache_data -> Hashtbl.clear cache_data.data
  | TTLCache cache_data ->
      Hashtbl.clear cache_data.data;
      cache.stats <- init_stats ()

(* 获取缓存统计信息 *)
let stats cache =
  (* 更新当前大小 *)
  let current_size =
    match cache.impl with
    | SimpleCache data -> Hashtbl.length data
    | LRUCache lru_data -> Hashtbl.length lru_data.data
    | LFUCache cache_data -> Hashtbl.length cache_data.data
    | TTLCache cache_data -> Hashtbl.length cache_data.data
  in
  { cache.stats with size = current_size } |> update_hit_rate

(* 缓存大小 *)
let size cache = (stats cache).size

(* 是否为空 *)
let is_empty cache = size cache = 0

(* 调试信息 *)
let debug_info cache =
  let stats = stats cache in
  Printf.sprintf "Cache[%s]: size=%d, hits=%d, misses=%d, hit_rate=%.2f%%, evictions=%d"
    cache.config.name stats.size stats.hits stats.misses (stats.hit_rate *. 100.0) stats.evictions

(* 批量操作 - 针对高频场景优化 *)
let get_batch cache keys =
  List.map
    (fun key -> match get cache key with Some value -> Some (key, value) | None -> None)
    keys
  |> List.filter_map (fun x -> x)

let put_batch cache pairs = List.iter (fun (key, value) -> put cache key value) pairs

(* 预热缓存 - 批量加载常用数据 *)
let warm_up cache loader keys =
  List.iter
    (fun key ->
      if not (mem cache key) then
        match loader key with Some value -> put cache key value | None -> ())
    keys

(* 缓存迁移 - 用于逐步替换现有缓存 *)
let migrate_from_hashtbl cache hashtbl = Hashtbl.iter (put cache) hashtbl

(* 为向后兼容创建简单的Hashtbl包装器 *)
let create_hashtbl_compatible ?(size = 128) ?(name = "compat") () =
  let config = { initial_size = size; max_size = None; strategy = Simple; name } in
  create config

(* 全局监控功能暂时移除以避免弱类型问题 *)
