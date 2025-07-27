(** 韵律缓存管理模块接口 - 无全局状态版本

    修复Issue #1463: 提供线程安全的韵律缓存，消除全局状态风险。 *)

open Rhyme_types

(** {1 安全缓存类型} *)

type rhyme_cache
(** 韵律缓存实例类型 *)

(** {1 缓存实例管理} *)

val create_cache : ?char_capacity:int -> ?group_capacity:int -> unit -> rhyme_cache
(** 创建新的韵律缓存实例 *)

(** {1 缓存操作函数} *)

val add_to_cache : rhyme_cache -> string -> rhyme_category -> rhyme_group -> unit
(** 添加字符到韵律缓存 *)

val add_rhyme_group_chars : rhyme_cache -> rhyme_group -> string list -> unit
(** 添加韵组字符集 *)

val lookup_rhyme : rhyme_cache -> string -> (rhyme_category * rhyme_group) option
(** 查询字符的韵律信息 *)

val lookup_rhyme_group_chars : rhyme_cache -> rhyme_group -> string list option
(** 查询韵组的字符集 *)

val get_cache_stats : rhyme_cache -> int * int
(** 获取缓存统计信息 *)

val clear_cache : rhyme_cache -> unit
(** 清空所有缓存 *)

val is_initialized : rhyme_cache -> bool
(** 检查是否已初始化 *)

val set_initialized : rhyme_cache -> bool -> unit
(** 设置初始化状态 *)

val get_all_cached_chars : rhyme_cache -> string list
(** 获取所有缓存的字符 *)

val get_all_rhyme_groups : rhyme_cache -> rhyme_group list
(** 获取所有韵组 *)

val cache_info : rhyme_cache -> string
(** 缓存信息报告 *)

(** {1 简化兼容性接口} *)

val lookup_rhyme : string -> (rhyme_category * rhyme_group) option
(** 简化的全局韵律查询 *)

val lookup_rhyme_group_chars : rhyme_group -> string list option
(** 简化的全局韵组字符查询 *)

val add_to_cache : string -> rhyme_category -> rhyme_group -> unit
(** 简化的全局缓存添加 *)

val add_rhyme_group_chars : rhyme_group -> string list -> unit
(** 简化的全局韵组字符添加 *)

val get_cache_stats : unit -> int * int
(** 简化的全局缓存统计 *)

val get_all_cached_chars : unit -> string list
(** 简化的全局缓存字符查询 *)

val is_initialized : unit -> bool
(** 简化的全局初始化状态 *)

val set_initialized : bool -> unit
(** 简化的全局初始化状态设置 *)

val clear_cache : unit -> unit
(** 简化的全局缓存清理 *)
