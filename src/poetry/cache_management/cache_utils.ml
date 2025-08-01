(** 缓存工具函数模块
 *
 * 此模块提供缓存系统需要的通用工具函数，
 * 包括时间处理、大小估算、字符串匹配等。
 *
 * @author Alpha, 主要工作代理
 * @version 1.0 - 数据缓存管理器模块化重构
 * @since 2025-07-30
 * @extracted_from data_cache_manager.ml
 *)

open Cache_core_types

(** 获取当前时间戳 *)
let current_time () = Unix.time ()

(** 估算对象的字节大小 *)
let estimate_size_bytes (obj : 'a) : int =
  try
    let size = Obj.size (Obj.repr obj) in
    if size > 0 then size * 8 else 64
  with _ -> 64

(** 模式匹配函数 - 简化实现 *)
let matches_pattern (pattern : string) (text : string) : bool =
  let pattern_len = String.length pattern in
  let text_len = String.length text in
  if pattern_len = 0 then true
  else if text_len = 0 then false
  else
    try
      let regex = Str.regexp pattern in
      Str.string_match regex text 0
    with _ -> String.contains text (String.get pattern 0)

(** 列表截取函数 *)
let take n lst =
  let rec aux acc count = function
    | [] -> List.rev acc
    | _ when count <= 0 -> List.rev acc
    | x :: xs -> aux (x :: acc) (count - 1) xs
  in
  aux [] n lst

(** 检查条目是否过期 *)
let is_entry_expired (entry : cache_entry) : bool =
  match entry.metadata.ttl with
  | None -> false
  | Some ttl ->
      let current = current_time () in
      current -. entry.metadata.created_time > ttl

(** 计算缓存命中率 *)
let calculate_hit_rate (hit_count : int) (miss_count : int) : float =
  let total = hit_count + miss_count in
  if total = 0 then 0.0 else float_of_int hit_count /. float_of_int total

(** 字节转MB *)
let bytes_to_mb (bytes : int) : float = float_of_int bytes /. (1024.0 *. 1024.0)

(** MB转字节 *)
let mb_to_bytes (mb : float) : int = int_of_float (mb *. 1024.0 *. 1024.0)

(** 比较缓存优先级 *)
let compare_priority (p1 : cache_priority) (p2 : cache_priority) : int =
  let priority_to_int = function
    | Critical -> 4
    | High -> 3
    | Normal -> 2
    | Low -> 1
    | Disposable -> 0
  in
  compare (priority_to_int p1) (priority_to_int p2)

(** 检查标签匹配 *)
let has_matching_tags (entry_tags : string list) (target_tags : string list) : bool =
  List.exists (fun target -> List.mem target entry_tags) target_tags