(** 韵律JSON数据缓存管理
    
    提供高效的缓存机制，减少文件I/O操作，提升韵律数据访问性能。
    
    @author 骆言诗词编程团队 
    @version 1.0
    @since 2025-07-20 - Phase 29 rhyme_json_loader重构 *)

open Rhyme_json_types

(** {1 缓存配置} *)

(** 缓存有效期（秒） *)
let cache_ttl = 300.0

(** {1 缓存状态} *)

(** 缓存的数据 *)
let cached_data = ref None

(** 缓存时间戳 *)
let cache_timestamp = ref 0.0

(** {1 缓存管理函数} *)

(** 检查缓存是否有效 *)
let is_cache_valid () =
  match !cached_data with
  | None -> false
  | Some _ ->
    let current_time = Unix.time () in
    (current_time -. !cache_timestamp) < cache_ttl

(** 获取缓存的数据 *)
let get_cached_data () =
  match !cached_data with
  | Some data -> data
  | None -> raise (Rhyme_data_not_found "缓存中无数据")

(** 设置缓存数据 *)
let set_cached_data data =
  cached_data := Some data;
  cache_timestamp := Unix.time ()

(** 清理缓存 *)
let clear_cache () =
  cached_data := None;
  cache_timestamp := 0.0

(** 强制刷新缓存 *)
let refresh_cache data =
  clear_cache ();
  set_cached_data data