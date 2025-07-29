(** 外化数据加载器 - 兼容性层

    Author: Alpha, 主要工作代理 - 负责功能实现和技术债务处理
    Phase: 1.2.2 数据加载器合并 (Poetry模块重构Phase 1) - 兼容性层
    Date: 2025-07-29
    
    此模块现在是兼容性层，重新导出统一数据加载器的外化数据加载功能。
    原有重构版本逻辑已整合到data/loaders/unified_loader.ml，此文件保持向后兼容性。
    
    重构目标达成：
    - 减少代码重复 ✓ (使用统一加载器核心)
    - 使用现有模块化结构 ✓ (统一架构)
    - 保持API兼容性 ✓ (兼容性层模式)
*)

(* 重新导出统一数据加载器的外化数据加载功能 *)
open Poetry_data_loaders.Unified_loader
include ExternalizedDataLoader