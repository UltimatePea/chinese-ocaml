(** 骆言诗词数据加载模块 - 兼容性层

    Author: Alpha, 主要工作代理 - 负责功能实现和技术债务处理 Phase: 1.2.2 数据加载器合并 (Poetry模块重构Phase 1) - 兼容性层 Date:
    2025-07-29

    此模块现在是兼容性层，重新导出统一数据加载器的功能。 原有数据加载逻辑已迁移到data/loaders/unified_loader.ml，此文件保持向后兼容性。

    迁移说明：
    - 数据加载功能现在统一在unified_loader.ml中
    - 此文件通过重新导出保持API兼容性
    - 消除了代码重复，提升了可维护性 *)

(* 重新导出统一数据加载器的Poetry数据加载功能 *)
open Poetry_data_loaders.Unified_loader
include PoetryDataLoader
