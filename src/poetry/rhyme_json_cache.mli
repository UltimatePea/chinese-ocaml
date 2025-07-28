(** 韵律JSON数据缓存管理接口 - Wave 2 重构版本

    此接口已完全重构为Poetry_core.Json_core的兼容接口层。
    原本独立的缓存管理接口现在转发到统一的JSON核心。

    @author Beta, Code Reviewer Agent - Wave 2 重构团队
    @version 3.0 - Wave 2 兼容层版本
    @since 2025-07-28 - Poetry Phase 3 Wave 2 继续实施
    @fix_issue #1550 *)

(** {1 主要缓存接口 - 转发到统一核心} *)

val clear_cache : unit -> unit
(** 清空缓存 - 转发到统一核心 *)

val print_cache_stats : unit -> unit
(** 打印缓存统计信息 - 转发到统一核心 *)
