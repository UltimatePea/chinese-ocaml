(** 基础评价器整合模块接口 - Poetry模块整合Phase 1试点
 *
 * 提供四个基础评价器的统一接口，保持向后兼容性。
 *
 * @author Whisky, PR Worker - Poetry模块整合Phase 1试点
 * @version 1.0 - 低风险模块整合试点
 * @since 2025-08-01
 *)

open Evaluator_types

(** {1 评价器模块} *)

(** 综合评价器模块 *)
module OverallEvaluator : EVALUATOR

(** 内容深度评价器模块 *)
module ContentDepthEvaluator : EVALUATOR

(** 意境评价器模块 *)
module MoodContextEvaluator : EVALUATOR

(** 声调平衡评价器模块 *)
module TonalBalanceEvaluator : EVALUATOR

(** {1 兼容性别名} *)

(** 综合评价器兼容性别名 *)
module Overall : EVALUATOR

(** 内容深度评价器兼容性别名 *)
module ContentDepth : EVALUATOR

(** 意境评价器兼容性别名 *)
module MoodContext : EVALUATOR

(** 声调平衡评价器兼容性别名 *)
module TonalBalance : EVALUATOR

(** {1 批量操作接口} *)

(** 所有评价器的列表 *)
val all_evaluators : (module EVALUATOR) list

(** 根据维度获取对应的评价器 *)
val get_evaluator_by_dimension : evaluation_dimension -> (module EVALUATOR)