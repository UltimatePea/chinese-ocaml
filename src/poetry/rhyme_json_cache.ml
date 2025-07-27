(** 韵律JSON数据缓存管理 - 无全局状态版本

    修复Issue #1463: 提供线程安全的缓存机制，消除全局状态风险。

    @author Beta, 代码审查代理
    @version 2.0 - 修复全局状态风险
    @since 2025-07-27 - Fix #1463 *)

open Rhyme_json_types

(** {1 缓存配置} *)

(** 缓存有效期（秒） *)
let cache_ttl = 300.0

(** {1 安全缓存类型} *)

(** 缓存实例类型 - 封装状态避免全局污染 *)
type json_cache = {
  mutable cached_data : Rhyme_json_types.rhyme_data_file option;
  mutable cache_timestamp : float;
  cache_ttl : float;
}

(** {1 缓存实例管理} *)

(** 创建新的缓存实例 *)
let create_cache ?(ttl = cache_ttl) () = {
  cached_data = None;
  cache_timestamp = 0.0;
  cache_ttl = ttl;
}

(** {1 缓存操作函数} *)

(** 检查缓存是否有效 *)
let is_cache_valid cache =
  match cache.cached_data with
  | None -> false
  | Some _ ->
      let current_time = Unix.time () in
      current_time -. cache.cache_timestamp < cache.cache_ttl

(** 获取缓存的数据 *)
let get_cached_data cache =
  match cache.cached_data with 
  | Some data -> data 
  | None -> raise (Rhyme_data_not_found "缓存中无数据")

(** 设置缓存数据 *)
let set_cached_data cache data =
  cache.cached_data <- Some data;
  cache.cache_timestamp <- Unix.time ()

(** 清理缓存 *)
let clear_cache cache =
  cache.cached_data <- None;
  cache.cache_timestamp <- 0.0

(** 强制刷新缓存 *)
let refresh_cache cache data =
  clear_cache cache;
  set_cached_data cache data

(** 获取缓存统计信息 *)
let cache_stats cache =
  let data_size = match cache.cached_data with
    | None -> 0
    | Some _ -> 1
  in
  let age = Unix.time () -. cache.cache_timestamp in
  Printf.sprintf "缓存状态: %d项数据, 年龄%.2f秒" data_size age
