(** 统一数据加载器 - 兼容性层接口

    Author: Alpha, 主要工作代理 - 负责功能实现和技术债务处理 Phase: 1.2.2 数据加载器合并 (Poetry模块重构Phase 1) - 兼容性层 Date:
    2025-07-29

    此接口现在是兼容性层，重新导出真正的统一数据加载器接口。 *)

(* 重新导出真正的统一数据加载器接口 *)
include module type of Poetry_data_loaders.Unified_loader
