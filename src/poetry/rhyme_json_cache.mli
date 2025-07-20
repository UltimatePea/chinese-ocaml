(** 韵律JSON数据缓存管理接口
    
    @author 骆言诗词编程团队 
    @version 1.0
    @since 2025-07-20 - Phase 29 rhyme_json_loader重构 *)

open Rhyme_json_types

(** {1 缓存配置} *)

val cache_ttl : float
(** 缓存有效期（秒） *)

(** {1 缓存管理} *)

val is_cache_valid : unit -> bool
(** 检查缓存是否有效 *)

val get_cached_data : unit -> rhyme_data_file
(** 获取缓存的数据 *)

val set_cached_data : rhyme_data_file -> unit
(** 设置缓存数据 *)

val clear_cache : unit -> unit
(** 清理缓存 *)

val refresh_cache : rhyme_data_file -> unit
(** 强制刷新缓存 *)