(** 韵律数据组辅助函数模块 (兼容性重定向层)
 *
 * Issue #2015: 韵律工具和辅助模块整合
 * 此模块现在重定向到 Poetry_data_helpers 以保持向后兼容性
 *
 * 提供rhyme_groups模块使用的数据结构辅助函数，避免代码重复。
 *
 * Author: Alpha, 主要工作代理
 * Author: Whisky, PR Worker - 兼容性重定向层
 * @version 1.0 - 重复代码清理版本
 * @since 2025-07-29 - Fix #1637 韵律数据模块重复代码清理
 * @since 2025-08-01 - 重定向到统一数据辅助模块
 *)

(** 重新导出所有韵律数据组辅助功能从统一数据辅助模块 *)
include Poetry_data_helpers