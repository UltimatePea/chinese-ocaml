(** 缓存事件系统模块
    
    此模块管理缓存事件的触发、监听和历史记录，
    为缓存系统提供完整的事件驱动支持。
    
    @author Alpha, 主要工作代理
    @version 1.0 - 数据缓存管理器模块化重构
    @since 2025-07-30
    @extracted_from data_cache_manager.ml *)

open Cache_core_types
open Cache_state

(** 触发缓存事件 *)
let fire_event (event : cache_event) =
  (* 记录到最近事件列表 *)
  cache_state.recent_events <- Cache_utils.take 100 (event :: cache_state.recent_events);

  (* 通知所有监听器 *)
  List.iter
    (fun (_, listener) -> try listener event with _ -> () (* 忽略监听器中的错误 *))
    cache_state.event_listeners;

  (* 调试输出 *)
  if cache_state.debug_mode then
    match event with
    | CacheHit key -> Printf.printf "[CACHE] Hit: %s\n%!" key
    | CacheMiss key -> Printf.printf "[CACHE] Miss: %s\n%!" key
    | CacheStore (key, size) -> Printf.printf "[CACHE] Store: %s (%d bytes)\n%!" key size
    | CacheEvict (key, reason) -> Printf.printf "[CACHE] Evict: %s (reason: %s)\n%!" key reason
    | CacheExpire key -> Printf.printf "[CACHE] Expire: %s\n%!" key
    | CacheClear keys -> Printf.printf "[CACHE] Clear: %d keys\n%!" (List.length keys)

(** 更新缓存统计信息 *)
let update_statistics (hit : bool) (access_time : float option) =
  if hit then cache_state.hit_count <- cache_state.hit_count + 1
  else cache_state.miss_count <- cache_state.miss_count + 1;

  match access_time with
  | Some time ->
      cache_state.total_access_time <- cache_state.total_access_time +. time;
      cache_state.total_accesses <- cache_state.total_accesses + 1
  | None -> ()

(** 注册事件监听器 *)
let register_event_listener (listener : cache_event -> unit) : int =
  let listener_id = cache_state.next_listener_id in
  cache_state.next_listener_id <- cache_state.next_listener_id + 1;
  cache_state.event_listeners <- (listener_id, listener) :: cache_state.event_listeners;
  listener_id

(** 注销事件监听器 *)
let unregister_event_listener (listener_id : int) : bool =
  let original_length = List.length cache_state.event_listeners in
  cache_state.event_listeners <-
    List.filter (fun (id, _) -> id <> listener_id) cache_state.event_listeners;
  List.length cache_state.event_listeners < original_length

(** 获取最近的事件 *)
let get_recent_events (count : int) : cache_event list =
  Cache_utils.take count cache_state.recent_events
