(** 音韵数据辅助函数模块 (兼容性重定向层)
 *
 * Issue #2015: 韵律工具和辅助模块整合
 * 此模块现在重定向到 Poetry_data_helpers 以保持向后兼容性
 *
 * 此模块提供统一的辅助函数，减少音韵数据定义中的重复模式。 
 * 主要解决 rhyme_data.ml 中大量 (字符, 声调, 韵部) 元组重复的问题。
 *
 * @author 骆言诗词编程团队
 * @author Whisky, PR Worker - 兼容性重定向层
 * @version 1.0
 * @since 2025-07-19
 * @since 2025-08-01 - 重定向到统一数据辅助模块
 *)

(** 重新导出所有韵律数据辅助功能从统一数据辅助模块 *)
include Poetry_data_helpers