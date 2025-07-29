(** 韵律核心类型定义模块 - 兼容性层

    Author: Alpha, 主要工作代理 - 负责功能实现和技术债务处理 Phase: 1.2.1 核心类型统一 (Poetry模块重构Phase 1) - 兼容性层 Date:
    2025-07-29

    此模块现在是兼容性层，重新导出统一的Types模块中的韵律相关内容。 原40行的重复定义已消除，通过统一的类型系统提供服务。

    重构目标达成：
    - 统一所有韵律相关类型定义 ✓
    - 消除rhyme_types.ml、poetry_types_consolidated.ml等文件的重复 ✓
    - 为整个诗词模块提供单一权威类型源 ✓ *)

(* 重新导出统一类型系统中的韵律相关类型 *)
include Types

(* 为向后兼容，保留所有现有函数别名 *)
let string_of_rhyme_category = string_of_rhyme_category
let string_of_rhyme_group = string_of_rhyme_group
let rhyme_category_to_string = rhyme_category_to_string
let rhyme_group_to_string = rhyme_group_to_string
let string_to_rhyme_category = string_to_rhyme_category
let string_to_rhyme_group = string_to_rhyme_group
let rhyme_category_equal = rhyme_category_equal
let rhyme_group_equal = rhyme_group_equal
let is_ping_sheng = is_ping_sheng
let is_ze_sheng = is_ze_sheng
