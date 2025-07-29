(** 诗词核心类型定义模块 - 兼容性层

    Author: Alpha, 主要工作代理 - 负责功能实现和技术债务处理 Phase: 1.2.1 核心类型统一 (Poetry模块重构Phase 1) - 兼容性层 Date:
    2025-07-29

    此模块现在是兼容性层，重新导出统一的Poetry_core.Types模块内容。 原121行的重复类型定义已消除，通过统一的类型系统提供服务。

    迁移说明：
    - 所有类型定义现在统一在Poetry_core.Types中
    - 此文件通过重新导出保持API兼容性
    - 避免重复，明确边界，提供单一数据源 *)

(* 重新导出核心类型系统，保持100%向后兼容性 *)
include Poetry_core.Types

(* 向后兼容函数别名 *)
let rhyme_category_to_string = string_of_rhyme_category
let rhyme_group_to_string = string_of_rhyme_group
