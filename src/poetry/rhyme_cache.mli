(** 韵律缓存管理模块接口

    提供统一的韵律数据缓存管理功能，支持高效的韵律信息存储和查询。 *)

open Rhyme_types

(** {1 缓存管理函数} *)

val add_to_cache : string -> rhyme_category -> rhyme_group -> unit
(** 添加字符到韵律缓存 *)

val add_rhyme_group_chars : rhyme_group -> string list -> unit
(** 添加韵组字符集 *)

val lookup_rhyme : string -> (rhyme_category * rhyme_group) option
(** 查询字符的韵律信息 *)

val lookup_rhyme_group_chars : rhyme_group -> string list option
(** 查询韵组的字符集 *)

val get_cache_stats : unit -> int * int
(** 获取缓存统计信息 *)

val clear_cache : unit -> unit
(** 清空所有缓存 *)

val is_initialized : unit -> bool
(** 检查是否已初始化 *)

val set_initialized : bool -> unit
(** 设置初始化状态 *)

val get_all_cached_chars : unit -> string list
(** 获取所有缓存的字符 *)

val get_all_rhyme_groups : unit -> rhyme_group list
(** 获取所有韵组 *)
