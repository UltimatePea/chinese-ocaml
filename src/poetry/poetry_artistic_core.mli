(** 骆言诗词艺术性评价核心模块接口 - 重构版本

    此模块作为诗词艺术性评价系统的统一接口和协调器。 重构后的模块提供完整的向后兼容性，同时增加了协调器功能。

    Author: Beta, Code Reviewer
    @version 3.0 - 模块化重构版本
    @since 2025-07-25 - 技术债务重构Phase 3 *)

open Poetry_types_consolidated

(** {1 单维度艺术性评价函数} *)

val evaluate_rhyme_harmony : string -> float
(** 评价韵律和谐度 *)

val evaluate_tonal_balance : string -> bool list option -> float
(** 评价声调平衡度 *)

val evaluate_parallelism : string -> string -> float
(** 评价对仗工整度 *)

val evaluate_imagery : string -> float
(** 评价意象深度 *)

val evaluate_rhythm : string -> float
(** 评价节奏感 *)

val evaluate_elegance : string -> float
(** 评价雅致程度 *)

(** {1 综合艺术性评价函数} *)

val comprehensive_artistic_evaluation : string -> bool list option -> artistic_report
(** 全面艺术性评价 *)

val determine_overall_grade : artistic_scores -> evaluation_grade
(** 综合评价等级判定 *)

val generate_improvement_suggestions : artistic_report -> string list
(** 生成改进建议 *)

(** {1 诗词形式专项评价函数} *)

val evaluate_siyan_parallel_prose : string array -> artistic_report
(** 四言骈体专项评价 *)

val evaluate_wuyan_lushi : string array -> artistic_report
(** 五言律诗专项评价 *)

val evaluate_qiyan_jueju : string array -> artistic_report
(** 七言绝句专项评价 *)

val evaluate_poetry_by_form : poetry_form -> string array -> artistic_report
(** 根据诗词形式进行相应的艺术性评价 *)

(** {1 传统诗词品评函数} *)

val poetic_critique : string -> poetry_form -> artistic_report
(** 诗词品评 *)

val poetic_aesthetics_guidance : string -> poetry_form -> artistic_report
(** 诗词美学指导系统 *)

(** {1 高阶艺术性分析函数} *)

val analyze_artistic_progression : string array -> float list
(** 分析艺术性递进 *)

val compare_artistic_quality : string -> string -> int
(** 比较艺术性质量 *)

val detect_artistic_flaws : string -> string list
(** 检测艺术性缺陷 *)

(** {1 评价标准配置} *)

module ArtisticStandards : sig
  val siyan_standards : siyan_artistic_standards
  val wuyan_lushi_standards : wuyan_lushi_standards
  val qiyan_jueju_standards : qiyan_jueju_standards
  val get_standards_for_form : poetry_form -> float list
end

(** {1 智能评价助手} *)

module IntelligentEvaluator : sig
  val auto_detect_form : string array -> poetry_form
  val adaptive_evaluation : string array -> comprehensive_analysis
  val smart_suggestions : string array -> string list
end

(** {1 协调器功能 - 高级组合接口} *)

val comprehensive_poetry_analysis : string array -> poetry_form option -> comprehensive_analysis
(** 全面诗词艺术性分析协调器
    @param verses 诗句数组
    @param form_hint 诗词形式提示（None表示自动检测）
    @return 全面的综合分析结果 *)

val comparative_quality_analysis : string array list -> (string array * comprehensive_analysis) list
(** 诗词质量对比分析协调器
    @param poems 诗词列表，每首诗词为诗句数组
    @return 按艺术性质量排序的分析结果列表 *)

val comprehensive_improvement_guidance : string -> poetry_form -> string list
(** 艺术性改进建议协调器
    @param verse 诗句字符串
    @param form 诗词形式
    @return 综合改进建议列表 *)
