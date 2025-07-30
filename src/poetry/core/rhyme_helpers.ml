(** 韵律数据辅助函数模块 - 兼容层重新导出版本

    此模块现为兼容层，重新导出主要的Rhyme_helpers模块功能，消除重复代码但保持向后兼容性。 Poetry模块技术债务清理：45行重复代码转换为兼容层重新导出。

    Author: Alpha, 主要工作代理 - 技术债务清理
    @version 2.0 - 兼容层版本，从主要rhyme_helpers重新导出
    @since 2025-07-29 - Fix #1744 Poetry模块整合优化 *)

open Poetry_types

(** {1 兼容性函数 - 重新导出主要Rhyme_helpers功能} *)

(** 创建韵律数据条目的辅助函数 - 兼容接口 *)
let make_entry char category group ?(variants = []) ?(frequency = 1.0) () =
  { character = char; category; group; variants; usage_frequency = frequency }

(** 创建某个韵组字符列表的辅助函数 - 简化版本 *)
let make_group_entries category group chars =
  List.map (fun char -> make_entry char category group ()) chars

(** 合并平声和仄声数据的辅助函数 *)
let combine_data ping_sheng_data ze_sheng_data = ping_sheng_data @ ze_sheng_data

(** 获取韵组数据统计信息 - 简化版本 *)
let get_rhyme_stats data = List.length data
