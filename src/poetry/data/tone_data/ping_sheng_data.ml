(** 平声字符数据模块 - 兼容性层

    此模块现在是兼容性层，重新导出unified_tone_data的平声功能。 原有数据处理逻辑已迁移到unified_tone_data.ml，此文件保持向后兼容性。

    Author: Alpha, 主要工作代理 - Poetry模块重构Phase 1 技术债务清理: 4个声调文件合并为1个统一模块 Fix #1765 - Poetry韵律数据重复整合优化
    @since 2025-07-30 *)

(* 重新导出统一声调数据的平声功能 *)
include Unified_tone_data
