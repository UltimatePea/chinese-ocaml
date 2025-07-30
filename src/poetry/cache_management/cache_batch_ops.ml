(** 缓存批量操作模块
    
    此模块实现缓存的批量操作功能，包括批量存储、
    检索和删除等，提高批量数据处理的效率。
    
    @author Alpha, 主要工作代理
    @version 1.0 - 数据缓存管理器模块化重构
    @since 2025-07-30
    @extracted_from data_cache_manager.ml *)

open Cache_core_types

(** 批量存储数据 *)
let store_batch (items : (string * 'a * cache_priority option * float option) list) :
    (string * bool) list =
  List.map
    (fun (key, data, priority_opt, ttl_opt) ->
      let priority = match priority_opt with Some p -> p | None -> Normal in
      let ttl = ttl_opt in
      let result = Cache_storage.store key data ~priority ~ttl () in
      (key, result))
    items

(** 批量检索数据 *)
let retrieve_batch (keys : string list) : (string * 'a cache_result) list =
  List.map
    (fun key ->
      let result = Cache_storage.retrieve key in
      (key, result))
    keys

(** 批量删除数据 *)
let delete_batch (keys : string list) : (string * bool) list =
  List.map
    (fun key ->
      let result = Cache_storage.delete key in
      (key, result))
    keys

(** 批量检查存在性 *)
let exists_batch (keys : string list) : (string * bool) list =
  List.map
    (fun key ->
      let result = Cache_storage.exists key in
      (key, result))
    keys

(** 批量更新TTL *)
let update_ttl_batch (items : (string * float) list) : (string * bool) list =
  List.map
    (fun (key, ttl) ->
      let result = Cache_storage.update_ttl key ttl in
      (key, result))
    items
