(** 诗词艺术评估新指标模块接口
 *
 * 此模块提供新的艺术评估指标和度量方法，包括现代化的评价算法
 * 和更精确的量化指标。
 *
 * 主要功能：
 * - 新一代评价指标定义
 * - 多维度量化分析
 * - 动态权重调整
 * - 智能评分算法
 * - 统计分析工具
 * - 指标对比功能
 *
 * @author Whisky, PR Worker
 *)

(** {1 新指标类型定义} *)

(** 评价指标类型 *)
type metric_type = 
  | RhymeMetric          (** 韵律指标 *)
  | TonalMetric          (** 声调指标 *)
  | StructuralMetric     (** 结构指标 *)
  | SemanticMetric       (** 语义指标 *)
  | AestheticMetric      (** 美学指标 *)
  | InnovationMetric     (** 创新指标 *)

(** 指标权重配置 *)
type metric_weights = {
  rhyme_weight : float;      (** 韵律权重 *)
  tonal_weight : float;      (** 声调权重 *)
  structural_weight : float; (** 结构权重 *)
  semantic_weight : float;   (** 语义权重 *)
  aesthetic_weight : float;  (** 美学权重 *)
  innovation_weight : float; (** 创新权重 *)
}

(** 指标计算结果 *)
type metric_result = {
  metric_type : metric_type;    (** 指标类型 *)
  raw_score : float;            (** 原始分数 *)
  normalized_score : float;     (** 标准化分数 *)
  confidence_level : float;     (** 置信水平 *)
  calculation_method : string;  (** 计算方法 *)
  metadata : (string * string) list; (** 元数据 *)
}

(** 综合指标报告 *)
type comprehensive_metrics = {
  individual_metrics : metric_result list; (** 各项指标 *)
  weighted_average : float;                (** 加权平均 *)
  overall_grade : string;                  (** 总体等级 *)
  strengths : string list;                 (** 优势指标 *)
  weaknesses : string list;                (** 劣势指标 *)
  recommendations : string list;           (** 改进建议 *)
}

(** {1 核心指标计算函数} *)

(** 计算韵律指标
    @param poem_text 诗词文本
    @return 韵律指标结果 *)
val calculate_rhyme_metric : string -> metric_result

(** 计算声调指标
    @param poem_text 诗词文本
    @return 声调指标结果 *)
val calculate_tonal_metric : string -> metric_result

(** 计算结构指标
    @param poem_text 诗词文本
    @return 结构指标结果 *)
val calculate_structural_metric : string -> metric_result

(** 计算语义指标
    @param poem_text 诗词文本
    @return 语义指标结果 *)
val calculate_semantic_metric : string -> metric_result

(** 计算美学指标
    @param poem_text 诗词文本
    @return 美学指标结果 *)
val calculate_aesthetic_metric : string -> metric_result

(** 计算创新指标
    @param poem_text 诗词文本
    @return 创新指标结果 *)
val calculate_innovation_metric : string -> metric_result

(** {1 综合评价函数} *)

(** 计算所有指标
    @param poem_text 诗词文本
    @param weights 权重配置
    @return 综合指标报告 *)
val calculate_all_metrics : string -> metric_weights -> comprehensive_metrics

(** 计算加权总分
    @param metrics 指标结果列表
    @param weights 权重配置
    @return 加权总分 *)
val calculate_weighted_score : metric_result list -> metric_weights -> float

(** 确定总体等级
    @param weighted_score 加权总分
    @return 等级字符串 *)
val determine_overall_grade : float -> string

(** 确定艺术水平等级
    @param overall_score 总体评分
    @return 艺术水平等级 *)
val determine_artistic_level : float -> [`Beginner | `Intermediate | `Advanced | `Master]

(** {1 指标比较与分析} *)

(** 比较两个指标结果
    @param result1 第一个结果
    @param result2 第二个结果
    @return 比较分析报告 *)
val compare_metric_results : metric_result -> metric_result -> (string * string) list

(** 分析指标趋势
    @param results 历史指标结果列表
    @return 趋势分析报告 *)
val analyze_metric_trends : metric_result list -> (string * string) list

(** 识别优势劣势
    @param metrics 综合指标
    @return (优势列表, 劣势列表) *)
val identify_strengths_weaknesses : comprehensive_metrics -> string list * string list

(** {1 权重管理} *)

(** 创建默认权重配置
    @return 默认权重配置 *)
val create_default_weights : unit -> metric_weights

(** 创建自定义权重配置
    @param rhyme 韵律权重
    @param tonal 声调权重
    @param structural 结构权重
    @param semantic 语义权重
    @param aesthetic 美学权重
    @param innovation 创新权重
    @return 自定义权重配置 *)
val create_custom_weights : 
  float -> float -> float -> float -> float -> float -> metric_weights

(** 标准化权重配置
    @param weights 原始权重配置
    @return 标准化后的权重配置 *)
val normalize_weights : metric_weights -> metric_weights

(** {1 高级分析功能} *)

(** 执行统计分析
    @param results 指标结果列表
    @return 统计分析报告 *)
val perform_statistical_analysis : metric_result list -> (string * float) list

(** 生成改进建议
    @param metrics 综合指标
    @return 改进建议列表 *)
val generate_improvement_suggestions : comprehensive_metrics -> string list

(** 计算置信区间
    @param results 指标结果列表
    @param confidence_level 置信水平
    @return (下界, 上界) *)
val calculate_confidence_interval : metric_result list -> float -> float * float

(** {1 指标可视化支持} *)

(** 生成指标摘要
    @param metrics 综合指标
    @return 摘要字符串 *)
val generate_metrics_summary : comprehensive_metrics -> string

(** 导出指标为JSON
    @param metrics 综合指标
    @return JSON字符串 *)
val export_metrics_to_json : comprehensive_metrics -> string

(** 格式化指标报告
    @param metrics 综合指标
    @return 格式化的报告文本 *)
val format_metrics_report : comprehensive_metrics -> string

(** {1 指标验证与校准} *)

(** 验证指标一致性
    @param metrics 综合指标
    @return 一致性检查结果 *)
val validate_metrics_consistency : comprehensive_metrics -> bool * string list

(** 校准指标分数
    @param result 原始指标结果
    @param calibration_factor 校准因子
    @return 校准后的指标结果 *)
val calibrate_metric_score : metric_result -> float -> metric_result