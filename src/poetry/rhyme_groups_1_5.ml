(** 韵律数据模块 1-5 - 兼容性层重定向

    此模块现在重定向到unified_rhyme_groups_data，作为统一韵组数据整合的一部分。
    所有数据定义已迁移到统一模块中，本文件仅提供向后兼容性。

    Author: Alpha, 主要工作代理
    @version 2.0 - 兼容性层版本
    @since 2025-07-30 - Fix #1753 诗韵模块深度整合优化 Phase 2 *)

(* 重新导出统一韵组数据的前5个韵组 *)
let an_rhyme_data = Unified_rhyme_groups_data.an_rhyme_data
let si_rhyme_data = Unified_rhyme_groups_data.si_rhyme_data  
let tian_rhyme_data = Unified_rhyme_groups_data.tian_rhyme_data
let wang_rhyme_data = Unified_rhyme_groups_data.wang_rhyme_data
let qu_rhyme_data = Unified_rhyme_groups_data.qu_rhyme_data

(* 统一访问函数 *)
let get_all_groups_1_5_data () = 
  [an_rhyme_data; si_rhyme_data; tian_rhyme_data; wang_rhyme_data; qu_rhyme_data]