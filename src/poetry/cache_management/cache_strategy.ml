(** 缓存策略管理模块
    
    此模块实现各种缓存策略（LRU, LFU, FIFO, TTL等）
    的逻辑和驱逐算法。
    
    @author Alpha, 主要工作代理
    @version 1.0 - 数据缓存管理器模块化重构
    @since 2025-07-30
    @extracted_from data_cache_manager.ml *)

open Cache_core_types
open Cache_state

(** 根据键获取对应的缓存策略 *)
let get_strategy_for_key (key : string) : cache_strategy =
  let rec find_matching_strategy patterns =
    match patterns with
    | [] -> LRU (* 默认策略 *)
    | (pattern, strategy) :: rest ->
        if Cache_utils.matches_pattern pattern key then strategy else find_matching_strategy rest
  in
  let patterns =
    Hashtbl.fold (fun pattern strategy acc -> (pattern, strategy) :: acc) cache_state.strategies []
  in
  find_matching_strategy patterns

(** 根据策略判断是否应该驱逐条目 *)
let should_evict_entry (entry : cache_entry) (strategy : cache_strategy) : bool =
  let current_time = Cache_utils.current_time () in
  match strategy with
  | TTL ttl -> current_time -. entry.metadata.created_time > ttl
  | Custom predicate -> predicate entry.metadata.key
  | _ -> false (* LRU, LFU, FIFO 需要全局比较 *)

(** 根据策略找到驱逐的受害者 *)
let find_victim_for_eviction (strategy : cache_strategy) : string option =
  let entries = Hashtbl.fold (fun key entry acc -> (key, entry) :: acc) cache_state.data_map [] in

  match entries with
  | [] -> None
  | _ ->
      let victim =
        match strategy with
        | LRU ->
            (* 找到最长时间未访问的条目 *)
            List.fold_left
              (fun (min_key, min_entry) (key, entry) ->
                if entry.metadata.last_accessed < min_entry.metadata.last_accessed then (key, entry)
                else (min_key, min_entry))
              (List.hd entries) entries
        | LFU ->
            (* 找到访问次数最少的条目 *)
            List.fold_left
              (fun (min_key, min_entry) (key, entry) ->
                if entry.metadata.access_count < min_entry.metadata.access_count then (key, entry)
                else (min_key, min_entry))
              (List.hd entries) entries
        | FIFO ->
            (* 找到最早创建的条目 *)
            List.fold_left
              (fun (min_key, min_entry) (key, entry) ->
                if entry.metadata.created_time < min_entry.metadata.created_time then (key, entry)
                else (min_key, min_entry))
              (List.hd entries) entries
        | TTL _ -> (
            (* 找到第一个过期的条目 *)
            let expired =
              List.find_opt (fun (_, entry) -> Cache_utils.is_entry_expired entry) entries
            in
            match expired with Some (key, entry) -> (key, entry) | None -> List.hd entries
            (* 如果没有过期的，选择第一个 *))
        | Custom _ -> (
            (* 自定义策略，选择第一个满足条件的 *)
            let matching =
              List.find_opt (fun (_, entry) -> should_evict_entry entry strategy) entries
            in
            match matching with Some (key, entry) -> (key, entry) | None -> List.hd entries)
      in
      Some (fst victim)

(** 检查是否需要驱逐 *)
let need_eviction () : bool =
  let current_entries = Hashtbl.length cache_state.data_map in
  let current_size_mb = Cache_utils.bytes_to_mb cache_state.current_size_bytes in
  current_entries >= cache_state.max_entries || current_size_mb >= cache_state.max_size_mb

(** 清理过期条目 *)
let expire_stale_entries ?(max_age = None) () : int =
  let current_time = Cache_utils.current_time () in
  let to_remove =
    Hashtbl.fold
      (fun key entry acc ->
        let should_expire =
          match max_age with
          | Some age -> current_time -. entry.metadata.created_time > age
          | None -> Cache_utils.is_entry_expired entry
        in
        if should_expire then key :: acc else acc)
      cache_state.data_map []
  in

  List.iter
    (fun key ->
      match Hashtbl.find_opt cache_state.data_map key with
      | Some entry ->
          Hashtbl.remove cache_state.data_map key;
          cache_state.current_size_bytes <-
            cache_state.current_size_bytes - entry.metadata.size_bytes
          (* 事件触发由调用者负责 *)
      | None -> ())
    to_remove;

  List.length to_remove
