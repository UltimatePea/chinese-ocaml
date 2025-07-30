(** 韵律数据模块 6-10 - 兼容性层重定向

    此模块现在重定向到unified_rhyme_groups_data，作为统一韵组数据整合的一部分。
    所有数据定义已迁移到统一模块中，本文件仅提供向后兼容性。

    Author: Alpha, 主要工作代理
    @version 2.0 - 兼容性层版本
    @since 2025-07-30 - Fix #1753 诗韵模块深度整合优化 Phase 2 *)

(* 重新导出统一韵组数据的第6-10个韵组 *)
let yu_rhyme_data = Unified_rhyme_groups_data.yu_rhyme_data
let hua_rhyme_data = Unified_rhyme_groups_data.hua_rhyme_data
let feng_rhyme_data = Unified_rhyme_groups_data.feng_rhyme_data
let yue_rhyme_data = Unified_rhyme_groups_data.yue_rhyme_data
let jiang_rhyme_data = Unified_rhyme_groups_data.jiang_rhyme_data

(* 统一访问函数 *)
let get_all_groups_6_10_data () = 
  [yu_rhyme_data; hua_rhyme_data; feng_rhyme_data; yue_rhyme_data; jiang_rhyme_data]
  |> List.flatten