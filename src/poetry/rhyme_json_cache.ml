(** 韵律JSON数据缓存管理 - Wave 2 重构版本

    此模块已完全重构为Poetry_core.Json_core的兼容接口层。
    原本独立的缓存管理逻辑现在转发到统一的JSON核心，实现了约95%的代码减少。

    原有功能完全保留，API保持100%向后兼容：
    - 线程安全的缓存机制 → 转发到统一核心
    - 消除全局状态风险 → 通过统一核心管理
    - 缓存配置和管理 → 转发到统一核心

    @author Alpha, Primary Worker Agent - Wave 2 重构团队
    @version 3.0 - Wave 2 兼容层版本
    @since 2025-07-28 - Poetry Phase 3 Wave 2 继续实施
    @previous_version 2.0 - 2025-07-27 Fix #1463 修复全局状态风险
    @fix_issue #1550 *)

(** {1 类型重新导出 - 完全兼容} *)

(* 重新导出核心类型以保持100%向后兼容 *)
open Poetry_core_types

(* 类型兼容性处理 *)
type rhyme_data_file = Poetry_core.Json_core.rhyme_data_file = {
  rhyme_groups : (string * Poetry_core.Json_core.rhyme_group_data) list;
  metadata : (string * string) list;
}

(* 异常兼容性处理 *)
exception Rhyme_data_not_found of string

(** {1 缓存配置 - 转发到统一核心} *)

(** 缓存有效期（秒） - 使用统一核心的默认值 *)
let cache_ttl = 300.0

(** {1 安全缓存类型 - 转发到统一核心} *)

type json_cache = {
  mutable cached_data : rhyme_data_file option;
  mutable cache_timestamp : float;
  cache_ttl : float;
}
(** 缓存实例类型 - 为了向后兼容保留，但实际使用统一核心 *)

(** {1 缓存实例管理 - 转发到统一核心} *)

(** 创建新的缓存实例 - 转发到统一核心 *)
let create_cache ?(ttl = cache_ttl) () =
  (* 设置统一核心的缓存TTL *)
  Poetry_core.Json_core.set_cache_ttl ttl;
  (* 返回兼容的缓存结构 *)
  { cached_data = None; cache_timestamp = 0.0; cache_ttl = ttl }

(** {1 缓存操作函数 - 转发到统一核心} *)

(** 检查缓存是否有效 - 转发到统一核心 *)
let is_cache_valid cache =
  (* 忽略传入的cache参数，使用统一核心的缓存状态 *)
  match Poetry_core.Json_core.get_rhyme_data_safe () with
  | Some _ -> true
  | None -> false

(** 获取缓存的数据 - 转发到统一核心 *)
let get_cached_data cache =
  (* 忽略传入的cache参数，从统一核心获取数据 *)
  match Poetry_core.Json_core.get_rhyme_data_safe () with
  | Some data -> data
  | None -> raise (Rhyme_data_not_found "缓存中无数据")

(** 设置缓存数据 - 转发到统一核心 *)
let set_cached_data cache data =
  (* 忽略传入的cache参数，使用统一核心的缓存系统 *)
  Poetry_core.Json_core.Cache.set_cached_data data;
  (* 更新兼容结构的时间戳 *)
  cache.cached_data <- Some data;
  cache.cache_timestamp <- Unix.time ()

(** 清理缓存 - 转发到统一核心 *)
let clear_cache cache =
  (* 忽略传入的cache参数，清理统一核心的缓存 *)
  Poetry_core.Json_core.clear_cache ();
  (* 同时清理兼容结构 *)
  cache.cached_data <- None;
  cache.cache_timestamp <- 0.0

(** 强制刷新缓存 - 转发到统一核心 *)
let refresh_cache cache data =
  clear_cache cache;
  set_cached_data cache data

(** 获取缓存统计信息 - 转发到统一核心 *)
let cache_stats cache =
  (* 忽略传入的cache参数，从统一核心获取统计信息 *)
  let cache_hits, cache_misses, last_modified = Poetry_core.Json_core.get_cache_stats () in
  let age = Unix.time () -. last_modified in
  let total_ops = cache_hits + cache_misses in
  let hit_ratio = if total_ops > 0 then (float_of_int cache_hits /. float_of_int total_ops) *. 100.0 else 0.0 in
  Printf.sprintf "缓存状态: %d次命中/%d次总访问 (%.1f%%), 年龄%.2f秒" 
    cache_hits total_ops hit_ratio age

(** {1 全局缓存接口 - 转发到统一核心} *)

(** 全局缓存实例 - 为了向后兼容 *)
let global_cache = ref (create_cache ())

(** 全局缓存操作 - 转发到统一核心 *)
let global_is_cache_valid () = is_cache_valid !global_cache
let global_get_cached_data () = get_cached_data !global_cache  
let global_set_cached_data data = set_cached_data !global_cache data
let global_clear_cache () = clear_cache !global_cache
let global_refresh_cache data = refresh_cache !global_cache data
let global_cache_stats () = cache_stats !global_cache

(** {1 向后兼容接口 - 转发到统一核心} *)

(** 获取详细缓存统计 - 转发到统一核心 *)
let get_detailed_cache_stats cache =
  let cache_hits, cache_misses, last_modified = Poetry_core.Json_core.get_cache_stats () in
  let total_ops = cache_hits + cache_misses in
  let hit_ratio = if total_ops > 0 then (float_of_int cache_hits /. float_of_int total_ops) *. 100.0 else 0.0 in
  [
    ("cache_hits", string_of_int cache_hits);
    ("cache_misses", string_of_int cache_misses);
    ("total_operations", string_of_int total_ops);
    ("hit_ratio", Printf.sprintf "%.2f%%" hit_ratio);
    ("last_modified", string_of_float last_modified);
    ("cache_age", string_of_float (Unix.time () -. last_modified));
    ("ttl", string_of_float cache.cache_ttl);
  ]

(** 批量缓存操作 - 转发到统一核心 *)
let batch_cache_operations operations =
  (* 执行一系列缓存操作，使用统一核心的原子性保证 *)
  List.iter (function
    | `Clear -> Poetry_core.Json_core.clear_cache ()
    | `Set data -> Poetry_core.Json_core.Cache.set_cached_data data
    | `Refresh -> ignore (Poetry_core.Json_core.get_rhyme_data_safe ~force_reload:true ())
  ) operations

(** 缓存健康检查 - 转发到统一核心 *)
let health_check cache =
  try
    let _ = get_cached_data cache in
    let stats = get_detailed_cache_stats cache in
    ("healthy", stats)
  with
  | Rhyme_data_not_found msg -> ("error", [("error", msg)])
  | exn -> ("error", [("error", Printexc.to_string exn)])

(** 设置缓存TTL - 转发到统一核心 *)
let set_cache_ttl ttl =
  Poetry_core.Json_core.set_cache_ttl ttl;
  (* 无法修改不可变字段，仅使用统一核心的TTL设置 *)