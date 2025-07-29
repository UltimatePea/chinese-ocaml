(** 统一数据加载器 - 兼容性层

    Author: Alpha, 主要工作代理 - 负责功能实现和技术债务处理
    Phase: 1.2.2 数据加载器合并 (Poetry模块重构Phase 1) - 兼容性层
    Date: 2025-07-29
    
    此模块现在是兼容性层，重新导出data/loaders/unified_loader.ml的统一加载功能。
    原有统一错误处理和加载接口已整合到真正的统一加载器中。
    
    重构成效：
    - 真正的统一实现 ✓ (data/loaders/unified_loader.ml)
    - 一致的接口和错误处理 ✓ (16个加载器整合)
    - 高性能缓存机制 ✓ (内置缓存管理)
    - 完整向后兼容 ✓ (兼容性层模式)
    
    设计原则达成：
    1. 统一错误处理 ✓
    2. 通用加载接口 ✓  
    3. 可扩展架构 ✓
    4. 高性能实现 ✓
*)

(* 重新导出真正的统一数据加载器 *)
open Poetry_data_loaders
include Unified_loader