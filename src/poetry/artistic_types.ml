(** 骆言诗词艺术性评价类型定义模块 - 兼容性层
    
    Author: Whisky, PR Worker Agent - Poetry架构整合Phase 1
    Issue: #2084 Poetry模块架构整合计划
    
    此模块现为兼容性层，重新导出Poetry_core/Types的艺术性评价类型定义，
    消除重复代码但保持向后兼容性。
    
    技术债务清理：将213行重复类型定义转换为兼容层重新导出
    
    从artistic_evaluation.ml重构而来，集中管理所有艺术性评价相关的类型定义
    现在统一使用src/poetry/core/types.ml作为单一类型源
    
    迁移说明：
    - 所有艺术性评价类型定义现在统一在core/types.ml中
    - 此文件通过重新导出保持API兼容性
    - 逐步迁移依赖方后，此文件将被删除
    
    @version 2.0 - 兼容层版本  
    @since 2025-08-03 *)

(* 重新导出所有艺术性评价类型，保持100%向后兼容性 *)
include Poetry_core.Types

(** 向后兼容的函数别名 *)

(** 评价等级转换为字符串 *)
let grade_to_string = string_of_evaluation_grade

(** 诗词形式转换为字符串 *)
let form_to_string = poetry_form_to_string