(** 韵律JSON数据缓存管理接口 - 无全局状态版本

    修复Issue #1463: 提供线程安全的缓存机制，消除全局状态风险。

    @author Beta, 代码审查代理
    @version 2.0 - 修复全局状态风险
    @since 2025-07-27 - Fix #1463 *)

open Rhyme_json_types

(** {1 缓存配置} *)

val cache_ttl : float
(** 缓存有效期（秒） *)

(** {1 安全缓存类型} *)

type json_cache
(** 缓存实例类型 *)

(** {1 缓存实例管理} *)

val create_cache : ?ttl:float -> unit -> json_cache
(** 创建新的缓存实例 *)

(** {1 缓存操作函数} *)

val is_cache_valid : json_cache -> bool
(** 检查缓存是否有效 *)

val get_cached_data : json_cache -> rhyme_data_file
(** 获取缓存的数据 *)

val set_cached_data : json_cache -> rhyme_data_file -> unit
(** 设置缓存数据 *)

val clear_cache : json_cache -> unit
(** 清理缓存 *)

val refresh_cache : json_cache -> rhyme_data_file -> unit
(** 强制刷新缓存 *)

val cache_stats : json_cache -> string
(** 获取缓存统计信息 *)
