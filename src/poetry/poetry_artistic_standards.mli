(** 骆言诗词艺术标准模块接口

    此模块定义各种诗词形式的艺术性评价标准和智能评价助手。

    Author: Beta, Code Reviewer
    @since 2025-07-25 - 技术债务重构Phase 3 *)

open Poetry_types_consolidated

(** {1 评价标准配置} *)

module ArtisticStandards : sig
  val siyan_standards : siyan_artistic_standards
  (** 四言骈体艺术性评价标准 *)

  val wuyan_lushi_standards : wuyan_lushi_standards
  (** 五言律诗艺术性评价标准 *)

  val qiyan_jueju_standards : qiyan_jueju_standards
  (** 七言绝句艺术性评价标准 *)

  val get_standards_for_form : poetry_form -> float list
  (** 获取指定诗词形式的评价权重
      @param form 诗词形式
      @return 各维度评价权重列表 *)
end

(** {1 智能评价助手} *)

module IntelligentEvaluator : sig
  val auto_detect_form : string array -> poetry_form
  (** 自动检测诗词形式
      @param verses 诗句数组
      @return 检测到的诗词形式 *)

  val adaptive_evaluation : string array -> comprehensive_analysis
  (** 自适应评价
      @param verses 诗句数组
      @return 综合分析结果 *)

  val smart_suggestions : string array -> string list
  (** 智能建议生成
      @param verses 诗句数组
      @return 智能建议列表 *)
end
