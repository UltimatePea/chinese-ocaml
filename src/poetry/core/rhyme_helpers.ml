(** 韵律数据组辅助函数模块 (兼容性重定向层)
 *
 * Issue #2015: 韵律工具和辅助模块整合
 * 注意：由于库依赖限制，core子库不能直接引用主库的Poetry_data_helpers
 * 此模块保持基本功能以避免循环依赖
 *
 * Author: Alpha, 主要工作代理
 * Author: Whisky, PR Worker - 兼容性重定向层
 * @version 1.0 - 重复代码清理版本
 * @since 2025-07-29 - Fix #1637 韵律数据模块重复代码清理
 * @since 2025-08-01 - 重定向到统一数据辅助模块
 *)

open Poetry_types

(** 注意：此模块为兼容性保留，主要功能已迁移到主库的Poetry_data_helpers模块 *)

(** 创建韵律数据条目的辅助函数 *)
let make_entry char category group ?(variants = []) ?(frequency = 1.0) () =
  { character = char; category; group; variants; usage_frequency = frequency }

(** 创建某个韵组字符列表的辅助函数 *)
let make_group_entries category group chars =
  List.map (fun char -> make_entry char category group ()) chars

(** 合并平声和仄声数据的辅助函数 *)
let combine_data ping_sheng_data ze_sheng_data = ping_sheng_data @ ze_sheng_data

(** 获取韵组数据统计信息 - 简化版本 *)
let get_rhyme_stats data = List.length data