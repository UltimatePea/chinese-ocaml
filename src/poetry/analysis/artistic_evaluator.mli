(** 统一艺术性评价引擎接口 - Phase 2: Engine Layer Refactoring
    
    此模块提供Poetry系统的统一艺术性评价功能，整合原先分散在30个文件中的
    艺术性评价实现，建立插件式评价架构。
    
    技术债务修复：消除artistic_evaluator_*.ml等30个重复模块
    
    @author Alpha, 主要开发代理 - Poetry模块重构团队
    @version 2.0 (Phase 2: 引擎层重构版)
    @since 2025-07-27
    @fix_issue #1501 *)

open Rhythm_analyzer

(** {1 艺术性评价类型定义} *)

(** 评价维度类型 *)
type evaluation_dimension =
  | Rhyme  (** 韵律评价 *)
  | Tone  (** 声调评价 *)
  | Meter  (** 格律评价 *)
  | Parallelism  (** 对仗评价 *)
  | Imagery  (** 意象评价 *)
  | Rhythm  (** 节奏评价 *)
  | Elegance  (** 雅致评价 *)
  | Content  (** 内容评价 *)
  | Form  (** 形式评价 *)
  | Overall  (** 综合评价 *)

type evaluation_result = {
  dimension : evaluation_dimension;  (** 评价维度 *)
  score : float;  (** 评分 (0.0-1.0) *)
  max_score : float;  (** 最高分 *)
  details : string option;  (** 详细说明 *)
  confidence : float;  (** 评价置信度 *)
  suggestions : string list;  (** 改进建议 *)
}
(** 评价结果 *)

type evaluation_context = {
  verse : string;  (** 诗句内容 *)
  verses : string list;  (** 多句诗词 *)
  rhythm_analysis : verse_rhythm_analysis;  (** 韵律分析结果 *)
  multi_analysis : multi_verse_analysis option;  (** 多句分析结果 *)
  metadata : (string * string) list;  (** 额外元数据 *)
}
(** 诗词评价上下文 *)

type comprehensive_evaluation = {
  context : evaluation_context;  (** 评价上下文 *)
  dimension_results : evaluation_result list;  (** 各维度评价结果 *)
  overall_score : float;  (** 综合评分 *)
  overall_confidence : float;  (** 综合置信度 *)
  strengths : string list;  (** 优点列表 *)
  weaknesses : string list;  (** 不足列表 *)
  suggestions : string list;  (** 综合建议 *)
  quality_level : [ `Excellent | `Good | `Fair | `Poor ];  (** 质量等级 *)
}
(** 综合评价结果 *)

(** {1 评价器插件接口} *)

(** 评价器签名 *)
module type EVALUATOR = sig
  val dimension : evaluation_dimension
  val description : string
  val weight : float
  val evaluate : evaluation_context -> evaluation_result
  val is_applicable : evaluation_context -> bool
end

(** {1 核心评价器模块} *)

module RhymeEvaluator : EVALUATOR
(** 韵律评价器 *)

module ToneEvaluator : EVALUATOR
(** 声调评价器 *)

module RhythmEvaluator : EVALUATOR
(** 节奏评价器 *)

module ConsistencyEvaluator : EVALUATOR
(** 多句一致性评价器 *)

(** {1 评价引擎状态和管理} *)

type artistic_evaluator_state
(** 艺术性评价引擎状态 - 不透明类型 *)

exception ArtisticEvaluatorError of string
(** 评价引擎异常 *)

val initialize_evaluator : analyzer_state -> artistic_evaluator_state
(** 初始化评价引擎
    @param rhythm_analyzer 韵律分析引擎状态
    @return 初始化的艺术性评价引擎状态 *)

val register_evaluator :
  evaluation_dimension -> (module EVALUATOR) -> artistic_evaluator_state -> artistic_evaluator_state
(** 注册新的评价器
    @param dimension 评价维度
    @param evaluator_module 评价器模块
    @param evaluator_state 当前评价引擎状态
    @return 更新后的评价引擎状态 *)

(** {1 评价执行函数} *)

val create_evaluation_context : string -> string list -> analyzer_state -> evaluation_context
(** 创建评价上下文
    @param verse 主要诗句
    @param verses 完整诗句列表
    @param rhythm_analyzer 韵律分析引擎
    @return 评价上下文 *)

val evaluate_dimension :
  evaluation_dimension -> evaluation_context -> artistic_evaluator_state -> evaluation_result option
(** 执行单个维度评价
    @param dimension 评价维度
    @param context 评价上下文
    @param evaluator_state 评价引擎状态
    @return 评价结果（如果适用）
    @raise ArtisticEvaluatorError 当评价失败时 *)

val evaluate_comprehensive :
  string -> string list -> artistic_evaluator_state -> comprehensive_evaluation
(** 执行综合评价
    @param verse 主要诗句
    @param verses 完整诗句列表
    @param evaluator_state 评价引擎状态
    @return 综合评价结果
    @raise ArtisticEvaluatorError 当评价失败时 *)

(** {1 工具和统计函数} *)

val get_evaluator_statistics : artistic_evaluator_state -> (string * string) list
(** 获取评价器统计信息
    @param evaluator_state 评价引擎状态
    @return 统计信息键值对列表 *)

val clear_evaluator_cache : artistic_evaluator_state -> artistic_evaluator_state
(** 清理评价器缓存
    @param evaluator_state 评价引擎状态
    @return 清理缓存后的评价引擎状态 *)

val format_evaluation_result : evaluation_result -> string
(** 格式化评价结果
    @param result 评价结果
    @return 格式化的字符串表示 *)

val format_comprehensive_evaluation : comprehensive_evaluation -> string
(** 格式化综合评价结果
    @param evaluation 综合评价结果
    @return 格式化的字符串表示 *)
