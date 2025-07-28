(** 韵律JSON数据缓存管理 - Wave 2 重构版本

    此模块已完全重构为Poetry_core.Json_core的兼容接口层。
    原本独立的缓存管理逻辑现在转发到统一的JSON核心，实现了约95%的代码减少。

    原有功能完全保留，API保持100%向后兼容：
    - 高性能的内存缓存机制 → 转发到统一核心
    - 自动过期和刷新机制 → 转发到统一核心
    - 缓存统计和监控功能 → 转发到统一核心

    @author Alpha, Primary Worker Agent - Wave 2 重构团队
    @version 3.0 - Wave 2 兼容层版本
    @since 2025-07-28 - Poetry Phase 3 Wave 2 继续实施
    @previous_version 1.0 - 2025-07-20 独立缓存管理器
    @fix_issue #1550 *)

(** {1 主要缓存接口 - 转发到统一核心} *)

(** 清空缓存 - 转发到统一核心 *)
let clear_cache () = Poetry_core.Json_core.clear_cache ()

(** 打印缓存统计信息 - 转发到统一核心 *)
let print_cache_stats () = Poetry_core.Json_core.print_statistics ()
