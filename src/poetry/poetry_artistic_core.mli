(** 骆言诗词艺术性评价核心模块 - 整合版本
    
    此模块整合了原有15+个艺术性评价模块的功能，
    提供统一的诗词艺术性分析、评价、指导接口。
    
    技术债务改进：将分散的艺术性评价功能整合，
    消除重复评价逻辑，提供一致的评价标准。
    
    原模块映射：
    - artistic_evaluation.ml -> 核心评价函数  
    - artistic_evaluator*.ml -> 各维度评价器
    - artistic_guidance.ml -> 美学指导功能
    - form_evaluators.ml -> 形式专项评价
    - poetry_standards.ml -> 评价标准定义
    
    @author 骆言诗词编程团队
    @version 2.0 - 整合版本
    @since 2025-07-24 *)

open Poetry_types_consolidated

(** {1 单维度艺术性评价函数} *)

val evaluate_rhyme_harmony : string -> float
(** 评价韵律和谐度
    
    检查诗句的音韵是否和谐，基于韵组分析和韵脚质量评价。
    韵律和谐是诗词艺术性的重要指标之一。
    
    @param verse 诗句字符串
    @return 韵律和谐度得分（0.0-1.0）
    
    @example [evaluate_rhyme_harmony "山外青山楼外楼"] 返回 [0.85] *)

val evaluate_tonal_balance : string -> bool list option -> float
(** 评价声调平衡度
    
    检查平仄搭配是否合理，基于声调模式匹配和声调多样性评价。
    声调平衡是古典诗词格律的核心要求。
    
    @param verse 诗句字符串
    @param expected_pattern 期望的平仄模式（true=平声，false=仄声）
    @return 声调平衡度得分（0.0-1.0） *)

val evaluate_parallelism : string -> string -> float
(** 评价对仗工整度
    
    检查对仗的工整程度，包括字数对应、声调对应、韵律对应等。
    对仗工整是骈体文和律诗的重要特征。
    
    @param left_verse 左联诗句
    @param right_verse 右联诗句
    @return 对仗工整度得分（0.0-1.0） *)

val evaluate_imagery : string -> float
(** 评价意象深度
    
    通过关键词分析评价意象的深度和丰富程度。
    意象深度体现了诗词的艺术内涵和表现力。
    
    @param verse 诗句字符串
    @return 意象深度得分（0.0-1.0） *)

val evaluate_rhythm : string -> float
(** 评价节奏感
    
    基于字数和声调变化评价诗句的节奏感。
    节奏感是诗词音律美感的重要组成部分。
    
    @param verse 诗句字符串
    @return 节奏感得分（0.0-1.0） *)

val evaluate_elegance : string -> float
(** 评价雅致程度
    
    基于用词和意境的雅致程度进行评价。
    雅致程度体现了诗词的文化品位和艺术修养。
    
    @param verse 诗句字符串
    @return 雅致程度得分（0.0-1.0） *)

(** {1 综合艺术性评价函数} *)

val comprehensive_artistic_evaluation : string -> bool list option -> artistic_report
(** 全面艺术性评价
    
    为诗句提供全面的艺术性分析，包含所有评价维度。
    这是本模块的核心功能，提供完整的艺术性评价报告。
    
    @param verse 诗句字符串
    @param expected_pattern 期望的平仄模式（None表示不检查平仄）
    @return 全面的艺术性评价报告 *)

val determine_overall_grade : artistic_scores -> evaluation_grade
(** 综合评价等级判定
    
    根据各项得分确定总体评价等级。
    综合考虑所有艺术性维度，给出客观的等级评价。
    
    @param scores 各维度艺术性得分
    @return 总体评价等级 *)

val generate_improvement_suggestions : artistic_report -> string list
(** 生成改进建议
    
    根据评价结果提供具体的改进建议。
    针对评分较低的维度，提供有针对性的改进建议。
    
    @param report 艺术性评价报告
    @return 改进建议列表 *)

(** {1 诗词形式专项评价函数} *)

val evaluate_siyan_parallel_prose : string array -> artistic_report
(** 四言骈体专项评价
    
    专门针对四言骈体的艺术性评价。
    考虑四言骈体的特殊格律要求，提供专业的评价结果。
    
    四言骈体要求：每句四字，上下句对仗，音韵和谐。
    
    @param verses 四言骈体诗句数组
    @return 四言骈体专项评价报告 *)

val evaluate_wuyan_lushi : string array -> artistic_report
(** 五言律诗专项评价
    
    专门针对五言律诗的艺术性评价。
    考虑五言律诗的特殊格律要求，提供专业的评价结果。
    
    五言律诗要求：八句五言，首联、颔联、颈联、尾联，
    颔联颈联须对仗，平仄有严格要求。
    
    @param verses 五言律诗八句诗句数组
    @return 五言律诗专项评价报告 *)

val evaluate_qiyan_jueju : string array -> artistic_report
(** 七言绝句专项评价
    
    专门针对七言绝句的艺术性评价。
    考虑七言绝句的特殊格律要求，提供专业的评价结果。
    
    七言绝句要求：四句七言，起承转合，韵律严格。
    
    @param verses 七言绝句四句诗句数组
    @return 七言绝句专项评价报告 *)

val evaluate_poetry_by_form : poetry_form -> string array -> artistic_report
(** 根据诗词形式进行相应的艺术性评价
    
    统一的诗词评价接口，根据不同的诗词形式自动选择合适的评价方法。
    
    @param form 诗词形式（四言骈体、五言律诗、七言绝句等）
    @param verses 诗句数组
    @return 对应形式的艺术性评价报告 *)

(** {1 传统诗词品评函数} *)

val poetic_critique : string -> poetry_form -> artistic_report
(** 诗词品评
    
    传统诗词品评方式的现代实现。
    模仿古代文人品评诗词的风格，提供雅致的评价文字。
    
    @param verse 诗句字符串
    @param form 诗词类型
    @return 艺术性评价报告，包含传统品评风格的建议 *)

val poetic_aesthetics_guidance : string -> poetry_form -> artistic_report
(** 诗词美学指导系统
    
    根据诗词类型和内容提供专门的美学指导。
    针对不同诗词形式的特点，提供有针对性的创作建议。
    
    @param verse 诗句字符串
    @param form 诗词类型（四言骈体、五言律诗、七言绝句等）
    @return 美学指导分析报告 *)

(** {1 高阶艺术性分析函数} *)

val analyze_artistic_progression : string array -> float list
(** 分析艺术性递进
    
    分析多句诗词中艺术性的变化趋势。
    
    @param verses 诗句数组
    @return 每句的艺术性得分列表 *)

val compare_artistic_quality : string -> string -> int
(** 比较艺术性质量
    
    比较两句诗词的艺术性高低。
    
    @param verse1 第一句诗
    @param verse2 第二句诗
    @return 比较结果（1=第一句更优，0=相等，-1=第二句更优） *)

val detect_artistic_flaws : string -> string list
(** 检测艺术性缺陷
    
    识别诗句中的艺术性问题。
    
    @param verse 诗句字符串
    @return 发现的缺陷描述列表 *)

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
      
      根据句数、字数等特征自动识别诗词类型。
      
      @param verses 诗句数组
      @return 检测到的诗词形式 *)

  val adaptive_evaluation : string array -> comprehensive_analysis
  (** 自适应评价
      
      根据检测到的诗词形式自动选择最合适的评价方法。
      
      @param verses 诗句数组
      @return 综合分析结果 *)

  val smart_suggestions : string array -> string list
  (** 智能建议生成
      
      基于综合分析结果生成智能化的改进建议。
      
      @param verses 诗句数组
      @return 智能建议列表 *)
end