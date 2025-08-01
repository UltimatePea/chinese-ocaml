(** 韵律缓存管理模块 (兼容性重定向层)
 *
 * Issue #2015: 韵律工具和辅助模块整合
 * 此模块现在重定向到 Poetry_cache_utils 以保持向后兼容性
 *
 * 修复Issue #1463: 提供线程安全的韵律缓存，消除全局状态风险。
 *
 * @author Beta, 代码审查代理
 * @author Whisky, PR Worker - 兼容性重定向层
 * @version 2.0 - 修复全局状态风险
 * @since 2025-07-27 - Fix #1463
 * @since 2025-08-01 - 重定向到统一缓存工具模块
 *)

(** 重新导出所有韵律缓存功能从统一缓存工具模块 *)
include module type of Poetry_cache_utils