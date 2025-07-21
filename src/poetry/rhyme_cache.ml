(** 韵律缓存管理模块

    提供统一的韵律数据缓存管理功能，支持高效的韵律信息存储和查询。

    @author 骆言诗词编程团队
    @version 1.0
    @since 2025-07-19 - unified_rhyme_api.ml重构 *)

open Rhyme_types

(** {1 缓存数据结构} *)

(** 韵律信息缓存表 *)
let rhyme_cache : (string, rhyme_category * rhyme_group) Hashtbl.t = Hashtbl.create 2000

(** 韵组字符集映射表 *)
let rhyme_group_chars : (rhyme_group, string list) Hashtbl.t = Hashtbl.create 20

(** 初始化状态标志 *)
let initialized = ref false

(** {1 缓存管理函数} *)

(** 添加字符到韵律缓存 *)
let add_to_cache char category group = Hashtbl.replace rhyme_cache char (category, group)

(** 添加韵组字符集 *)
let add_rhyme_group_chars group chars = Hashtbl.replace rhyme_group_chars group chars

(** 查询字符的韵律信息 *)
let lookup_rhyme char = try Some (Hashtbl.find rhyme_cache char) with Not_found -> None

(** 查询韵组的字符集 *)
let lookup_rhyme_group_chars group =
  try Some (Hashtbl.find rhyme_group_chars group) with Not_found -> None

(** 获取缓存统计信息 *)
let get_cache_stats () =
  let rhyme_count = Hashtbl.length rhyme_cache in
  let group_count = Hashtbl.length rhyme_group_chars in
  (rhyme_count, group_count)

(** 清空所有缓存 *)
let clear_cache () =
  Hashtbl.clear rhyme_cache;
  Hashtbl.clear rhyme_group_chars;
  initialized := false

(** 检查是否已初始化 *)
let is_initialized () = !initialized

(** 设置初始化状态 *)
let set_initialized state = initialized := state

(** 获取所有缓存的字符 *)
let get_all_cached_chars () = Hashtbl.fold (fun char _ acc -> char :: acc) rhyme_cache []

(** 获取所有韵组 *)
let get_all_rhyme_groups () = Hashtbl.fold (fun group _ acc -> group :: acc) rhyme_group_chars []
