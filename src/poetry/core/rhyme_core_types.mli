(** 韵律核心类型定义模块 - 兼容性层接口

    Author: Alpha, 主要工作代理 - 负责功能实现和技术债务处理 Phase: 1.2.1 核心类型统一 (Poetry模块重构Phase 1) - 兼容性层 Date:
    2025-07-29

    此模块接口现在是兼容性层，重新导出统一的Types模块接口。 *)

(* 重新导出所有类型和函数接口，保持100%向后兼容性 *)
include module type of Types
