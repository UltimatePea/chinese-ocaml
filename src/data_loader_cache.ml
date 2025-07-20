(* 数据加载器缓存管理模块
   
   负责数据缓存的存储、查询和过期管理。
   使用TTL机制确保数据新鲜度。 *)

open Data_loader_types

(** 缓存存活时间（秒） *)
let cache_ttl = 300.0 (* 5 minutes *)

(** 全局缓存表 *)
let cache_table : (string, Obj.t cache_entry) Hashtbl.t = Hashtbl.create 16

(** 检查缓存是否有效 *)
let is_cache_valid timestamp =
  let current_time = Unix.time () in
  current_time -. timestamp < cache_ttl

(** 获取缓存数据 *)
let get_cached key =
  try
    let entry = Hashtbl.find cache_table key in
    if is_cache_valid entry.timestamp then Some (Obj.obj entry.data)
    else (
      Hashtbl.remove cache_table key;
      None)
  with Not_found -> None

(** 设置缓存数据 *)
let set_cache key data =
  let entry = { data = Obj.repr data; timestamp = Unix.time () } in
  Hashtbl.replace cache_table key entry

(** 清空缓存 *)
let clear_cache () = Hashtbl.clear cache_table

(** 获取缓存大小 *)
let cache_size () = Hashtbl.length cache_table