(** 骆言诗词统一缓存工具模块接口 - 韵律工具和辅助模块整合
 *
 * Issue #2015: 韵律工具和辅助模块整合
 * 统一缓存工具模块的公共接口定义
 *
 * Author: Whisky, PR Worker
 * @since 2025-08-01
 * @version 1.0 - 初始整合版本
 *)

open Poetry_core.Poetry_types

(** {1 重新导出缓存管理功能} *)

(** 数据缓存管理器兼容性层 - 重新导出缓存管理功能 *)
include module type of Poetry_cache_management.Cache_manager_registry

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
val create_rhyme_cache : ?char_capacity:int -> ?group_capacity:int -> unit -> rhyme_cache

(** === 韵律缓存操作函数 === *)

(** 添加字符到韵律缓存 *)
val add_to_rhyme_cache : rhyme_cache -> string -> rhyme_category -> rhyme_group -> unit

(** 添加韵组字符集 *)
val add_rhyme_group_chars : rhyme_cache -> rhyme_group -> string list -> unit

(** 查询字符的韵律信息 *)
val lookup_rhyme : rhyme_cache -> string -> (rhyme_category * rhyme_group) option

(** 查询韵组的字符集 *)
val lookup_rhyme_group_chars : rhyme_cache -> rhyme_group -> string list option

(** === 韵律缓存统计和管理 === *)

(** 获取缓存统计信息 *)
val get_rhyme_cache_stats : rhyme_cache -> int * int

(** 清空所有韵律缓存 *)
val clear_rhyme_cache : rhyme_cache -> unit

(** 检查韵律缓存是否已初始化 *)
val is_rhyme_cache_initialized : rhyme_cache -> bool

(** 设置韵律缓存初始化状态 *)
val set_rhyme_cache_initialized : rhyme_cache -> bool -> unit

(** 获取所有缓存的字符 *)
val get_all_cached_chars : rhyme_cache -> string list

(** 获取所有韵组 *)
val get_all_rhyme_groups : rhyme_cache -> rhyme_group list

(** 缓存信息报告 *)
val rhyme_cache_info : rhyme_cache -> string

(** {1 全局韵律缓存兼容性接口} *)

(** === 简化的全局兼容函数 === *)

(** 全局查询字符的韵律信息 *)
val lookup_rhyme_global : string -> (rhyme_category * rhyme_group) option

(** 全局查询韵组的字符集 *)
val lookup_rhyme_group_chars_global : rhyme_group -> string list option

(** 全局添加字符到缓存 *)
val add_to_cache_global : string -> rhyme_category -> rhyme_group -> unit

(** 全局添加韵组字符集 *)
val add_rhyme_group_chars_global : rhyme_group -> string list -> unit

(** 获取全局缓存统计 *)
val get_cache_stats_global : unit -> int * int

(** 获取所有全局缓存字符 *)
val get_all_cached_chars_global : unit -> string list

(** 检查全局缓存是否初始化 *)
val is_initialized_global : unit -> bool

(** 设置全局缓存初始化状态 *)
val set_initialized_global : bool -> unit

(** 清空全局缓存 *)
val clear_cache_global : unit -> unit