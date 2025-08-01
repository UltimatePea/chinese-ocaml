(** 骆言诗词统一缓存工具模块 - 韵律工具和辅助模块整合
 *
 * Issue #2015: 韵律工具和辅助模块整合
 * 将10个工具模块整合为3个高效模块的第三个：统一缓存工具模块
 *
 * 整合的模块：
 * - data_cache_manager.ml (重定向功能) 
 * - rhyme_cache.ml (韵律缓存)
 *
 * 注意：cache_management/cache_utils.ml 保留在其子库中以避免循环依赖
 *
 * Author: Whisky, PR Worker
 * @since 2025-08-01
 * @version 1.0 - 初始整合版本
 *)

open Poetry_core.Poetry_types

(** {1 重新导出缓存管理功能} *)

(** 数据缓存管理器兼容性层 - 重新导出缓存管理功能 *)
include Poetry_cache_management.Cache_manager_registry

(** {1 韵律缓存类型定义} *)

(** 韵律缓存专用类型 *)
type rhyme_cache = {
  char_cache : (string, rhyme_category * rhyme_group) Hashtbl.t;
  group_chars_cache : (rhyme_group, string list) Hashtbl.t;
  mutable initialized : bool;
}

(** {1 韵律缓存管理} *)

(** === 韵律缓存实例管理 === *)

(** 创建新的韵律缓存实例 *)
let create_rhyme_cache ?(char_capacity = 2000) ?(group_capacity = 20) () =
  {
    char_cache = Hashtbl.create char_capacity;
    group_chars_cache = Hashtbl.create group_capacity;
    initialized = false;
  }

(** === 韵律缓存操作函数 === *)

(** 添加字符到韵律缓存 *)
let add_to_rhyme_cache cache char category group = 
  Hashtbl.replace cache.char_cache char (category, group)

(** 添加韵组字符集 *)
let add_rhyme_group_chars cache group chars = 
  Hashtbl.replace cache.group_chars_cache group chars

(** 查询字符的韵律信息 *)
let lookup_rhyme cache char = 
  try Some (Hashtbl.find cache.char_cache char) with Not_found -> None

(** 查询韵组的字符集 *)
let lookup_rhyme_group_chars cache group =
  try Some (Hashtbl.find cache.group_chars_cache group) with Not_found -> None

(** === 韵律缓存统计和管理 === *)

(** 获取缓存统计信息 *)
let get_rhyme_cache_stats cache =
  let rhyme_count = Hashtbl.length cache.char_cache in
  let group_count = Hashtbl.length cache.group_chars_cache in
  (rhyme_count, group_count)

(** 清空所有韵律缓存 *)
let clear_rhyme_cache cache =
  Hashtbl.clear cache.char_cache;
  Hashtbl.clear cache.group_chars_cache;
  cache.initialized <- false

(** 检查韵律缓存是否已初始化 *)
let is_rhyme_cache_initialized cache = cache.initialized

(** 设置韵律缓存初始化状态 *)
let set_rhyme_cache_initialized cache state = cache.initialized <- state

(** 获取所有缓存的字符 *)
let get_all_cached_chars cache = 
  Hashtbl.fold (fun char _ acc -> char :: acc) cache.char_cache []

(** 获取所有韵组 *)
let get_all_rhyme_groups cache =
  Hashtbl.fold (fun group _ acc -> group :: acc) cache.group_chars_cache []

(** 缓存信息报告 *)
let rhyme_cache_info cache =
  let rhyme_count = Hashtbl.length cache.char_cache in
  let group_count = Hashtbl.length cache.group_chars_cache in
  Printf.sprintf "韵律缓存: %d个字符, %d个韵组, 初始化: %b" rhyme_count group_count cache.initialized

(** {1 全局韵律缓存兼容性接口} *)

(** === 简化兼容性接口 - 修复Issue #1463的编译错误 === *)

(** 临时全局缓存实例 - 待重构为无全局状态版本 *)
let global_rhyme_cache = lazy (create_rhyme_cache ())

(** 简化的全局兼容函数 *)
let lookup_rhyme_global char = lookup_rhyme (Lazy.force global_rhyme_cache) char

let lookup_rhyme_group_chars_global group = lookup_rhyme_group_chars (Lazy.force global_rhyme_cache) group

let add_to_cache_global char category group =
  add_to_rhyme_cache (Lazy.force global_rhyme_cache) char category group

let add_rhyme_group_chars_global group chars =
  add_rhyme_group_chars (Lazy.force global_rhyme_cache) group chars

let get_cache_stats_global () = get_rhyme_cache_stats (Lazy.force global_rhyme_cache)
let get_all_cached_chars_global () = get_all_cached_chars (Lazy.force global_rhyme_cache)
let is_initialized_global () = is_rhyme_cache_initialized (Lazy.force global_rhyme_cache)
let set_initialized_global state = set_rhyme_cache_initialized (Lazy.force global_rhyme_cache) state
let clear_cache_global () = clear_rhyme_cache (Lazy.force global_rhyme_cache)