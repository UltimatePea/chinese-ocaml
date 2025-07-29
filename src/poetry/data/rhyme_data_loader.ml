(** 韵律数据加载器 - 兼容性层

    Author: Alpha, 主要工作代理 - 负责功能实现和技术债务处理
    Phase: 1.2.2 数据加载器合并 (Poetry模块重构Phase 1) - 兼容性层
    Date: 2025-07-29
    
    此模块现在是兼容性层，重新导出统一数据加载器的韵律数据加载功能。
    
    重构成效：
    - 消除本地类型重复定义 ✓ (删除重复的rhyme_category和rhyme_group定义)
    - 使用统一类型系统 ✓ (Poetry_core.Types)
    - 从318行优化为17行 ✓ (减少95%代码量)
    - 保持API兼容性 ✓ (兼容性层模式)
    
    技术债务清理：原文件存在严重的类型重复定义问题，与统一类型系统冲突。
    现在通过统一加载器提供相同功能，消除代码重复。
*)

(* 重新导出统一数据加载器的韵律数据加载功能 *)
open Poetry_data_loaders.Unified_loader
include RhymeDataLoader