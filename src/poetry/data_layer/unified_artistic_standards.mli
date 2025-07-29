(** 骆言诗词统一艺术标准模块接口 - Poetry模块整合优化 Fix #1707
    
    此模块接口定义了统一的诗词艺术性评价标准体系。
    提供完整的艺术评价、标准管理和定制功能。
    
    Author: Alpha, 主要工作代理 *)

open Unified_data_types

(** {1 艺术评价标准体系} *)

(** 评价标准级别 *)
type standard_level =
  | Professional  (** 专业级 - 严格的学术标准 *)
  | Academic      (** 学院级 - 教学和研究标准 *)
  | Popular       (** 大众级 - 普及性标准 *)
  | Beginner      (** 初学级 - 宽松的入门标准 *)

(** 传统评价流派 *)
type evaluation_school =
  | Classical     (** 古典派 - 严格按古典标准 *)
  | Modern        (** 现代派 - 融合现代审美 *)
  | Contemporary  (** 当代派 - 当代文学标准 *)
  | Comprehensive (** 综合派 - 综合各家所长 *)

(** 艺术维度标准配置 *)
type dimension_standard = {
  dimension : artistic_dimension;      (** 维度名称 *)
  weight : float;                      (** 权重系数 *)
  threshold_excellent : float;         (** 优秀阈值 *)
  threshold_good : float;              (** 良好阈值 *)
  threshold_fair : float;              (** 一般阈值 *)
  evaluation_criteria : string list;   (** 评价标准 *)
  improvement_suggestions : string list; (** 改进建议模板 *)
}

(** 综合评价标准配置 *)
type artistic_standard_config = {
  standard_name : string;              (** 标准名称 *)
  level : standard_level;              (** 标准级别 *)
  school : evaluation_school;          (** 评价流派 *)
  dimensions : dimension_standard list; (** 各维度标准 *)
  overall_weights : (artistic_dimension * float) list; (** 总体权重配置 *)
  grade_thresholds : (evaluation_grade * float) list; (** 等级阈值 *)
  description : string;                (** 标准描述 *)
}

(** {1 标准访问和管理} *)

val professional_classical_standard : artistic_standard_config
(** 专业级古典标准 *)

val academic_comprehensive_standard : artistic_standard_config
(** 学院级综合标准 *)

val popular_modern_standard : artistic_standard_config
(** 大众级现代标准 *)

val beginner_lenient_standard : artistic_standard_config
(** 初学级宽松标准 *)

val all_standards : artistic_standard_config list
(** 所有预定义标准 *)

val find_standard : standard_level -> evaluation_school -> artistic_standard_config option
(** 根据级别和流派查找标准 *)

val get_default_standard : unit -> artistic_standard_config
(** 获取默认标准 *)

val get_recommended_standard_for_form : poetry_form -> artistic_standard_config
(** 根据诗体获取推荐标准 *)

(** {1 评价计算功能} *)

val calculate_dimension_score : artistic_standard_config -> artistic_dimension -> float -> float
(** 根据标准计算维度得分 *)

val calculate_overall_grade : artistic_standard_config -> (artistic_dimension * float) list -> evaluation_grade
(** 根据标准计算总体评级 *)

val generate_improvement_suggestions : artistic_standard_config -> (artistic_dimension * float) list -> string list
(** 生成改进建议 *)

(** {1 标准定制功能} *)

val create_custom_standard : string -> standard_level -> evaluation_school -> 
                             dimension_standard list -> (artistic_dimension * float) list -> 
                             (evaluation_grade * float) list -> string -> artistic_standard_config
(** 创建自定义标准 *)

val adjust_standard_thresholds : artistic_standard_config -> (evaluation_grade * float) list -> artistic_standard_config
(** 调整标准阈值 *)

val adjust_dimension_weights : artistic_standard_config -> (artistic_dimension * float) list -> artistic_standard_config
(** 调整维度权重 *)

(** {1 分析和导出功能} *)

val export_standard_config : artistic_standard_config -> artistic_standard_config
(** 导出标准配置 *)

val analyze_standard_characteristics : artistic_standard_config -> (string * string) list
(** 分析标准特征 *)

(** {1 向后兼容接口} *)

(** 兼容旧版本的权重配置 *)
module WeightConfig : sig
  val rhyme_weight : float
  val tone_weight : float
  val parallelism_weight : float
  val imagery_weight : float
  val rhythm_weight : float
  val elegance_weight : float
  val all_weights : float list
  val calculate_weighted_score : artistic_report -> float
end

val legacy_determine_overall_grade : artistic_report -> evaluation_grade
(** 兼容旧版本的评级函数 *)