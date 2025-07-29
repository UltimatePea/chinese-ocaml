(** 兼容性模块：重定向到统一数据加载模块
 *
 * 此模块为poetry_data_loader.ml的兼容性替换，将所有调用重定向到
 * 新的统一模块poetry_data_unified.ml，确保向后兼容性。
 *
 * Author: Alpha, 主要工作代理 - Poetry模块整合优化 Issue #1707
 * @since 2025-07-29
 *)

(* 重新导出所有功能到统一模块 *)
include Poetry_data_unified.Poetry_data_loader_compat