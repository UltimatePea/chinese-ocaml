(** 骆言诗词高阶艺术性分析模块接口 *)

open Poetry_types_consolidated

(** {1 传统诗词品评函数} *)

(** 传统诗词品评
    @param verse 诗句
    @param form 诗词形式
    @return 带有品评意见的艺术性评价报告 *)
val poetic_critique : string -> poetry_form -> artistic_report

(** 诗词美学指导
    @param verse 诗句
    @param form 诗词形式
    @return 带有美学指导的艺术性评价报告 *)
val poetic_aesthetics_guidance : string -> poetry_form -> artistic_report

(** {1 高阶艺术性分析函数} *)

(** 计算综合艺术性评分
    @param report 艺术性评价报告
    @return 综合评分 *)
val calculate_overall_score : artistic_report -> float

(** 分析诗句组的艺术性发展趋势
    @param verses 诗句数组
    @return 各句的艺术性评分列表 *)
val analyze_artistic_progression : string array -> float list

(** 比较两首诗的艺术性质量
    @param verse1 第一首诗
    @param verse2 第二首诗
    @return 比较结果：1表示第一首更好，-1表示第二首更好，0表示相等 *)
val compare_artistic_quality : string -> string -> int

(** 检测诗句的艺术性缺陷
    @param verse 诗句
    @return 检测到的缺陷列表 *)
val detect_artistic_flaws : string -> string list

(** {1 评价标准配置} *)

module ArtisticStandards : sig
  (** 四言诗艺术标准 *)
  val siyan_standards : siyan_artistic_standards

  (** 五言律诗艺术标准 *)
  val wuyan_lushi_standards : wuyan_lushi_standards

  (** 七言绝句艺术标准 *)
  val qiyan_jueju_standards : qiyan_jueju_standards

  (** 获取特定诗词形式的评价权重
      @param form 诗词形式
      @return 各维度评价权重列表 [韵律;声调;对仗;意象;节奏;雅致] *)
  val get_standards_for_form : poetry_form -> float list
end

(** {1 智能评价助手} *)

module IntelligentEvaluator : sig
  (** 自动检测诗词形式
      @param verses 诗句数组
      @return 检测到的诗词形式 *)
  val auto_detect_form : string array -> poetry_form

  (** 自适应诗词评价
      @param verses 诗句数组
      @return 完整的诗词评价分析报告 *)
  val adaptive_evaluation : string array -> comprehensive_analysis

  (** 智能建议生成
      @param verses 诗句数组
      @return 针对性建议列表 *)
  val smart_suggestions : string array -> string list
end