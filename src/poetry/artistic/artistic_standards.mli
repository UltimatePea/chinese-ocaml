(** 诗词艺术评估标准模块接口
 *
 * 此模块定义和管理诗词艺术评估的各种标准和规范，包括传统诗词格律、
 * 现代评价标准、质量等级划分等。
 *
 * 主要功能：
 * - 诗词格律标准定义
 * - 评价等级标准
 * - 质量阈值管理
 * - 标准验证功能
 * - 自定义标准支持
 * - 标准比较分析
 *
 * @author Whisky, PR Worker
 *)

(** {1 标准类型定义} *)

(** 诗词形式标准 *)
type poetry_form_standard = {
  name : string;                    (** 标准名称 *)
  verse_count : int option;         (** 诗句数量要求 *)
  syllable_pattern : int list option; (** 音节模式 *)
  rhyme_scheme : string option;     (** 韵律方案 *)
  tonal_pattern : string option;    (** 声调模式 *)
  parallelism_required : bool;      (** 是否要求对仗 *)
  special_rules : string list;      (** 特殊规则 *)
}

(** 质量等级标准 *)
type quality_grade_standard = {
  grade_name : string;              (** 等级名称 *)
  min_score : float;                (** 最低分数 *)
  max_score : float;                (** 最高分数 *)
  criteria : string list;           (** 评判标准 *)
  examples : string list;           (** 示例作品 *)
}

(** 评价维度标准 *)
type dimension_standard = {
  dimension_name : string;          (** 维度名称 *)
  weight : float;                   (** 权重 *)
  evaluation_criteria : string list; (** 评价标准 *)
  scoring_rubric : (float * string) list; (** 评分标准 *)
}

(** 综合评价标准 *)
type comprehensive_standard = {
  standard_name : string;           (** 标准名称 *)
  version : string;                 (** 版本号 *)
  poetry_forms : poetry_form_standard list; (** 诗词形式标准 *)
  quality_grades : quality_grade_standard list; (** 质量等级标准 *)
  dimensions : dimension_standard list; (** 评价维度标准 *)
  created_date : float;             (** 创建日期 *)
  description : string;             (** 标准描述 *)
}

(** {1 标准管理} *)

(** 创建诗词形式标准
    @param name 标准名称
    @param verse_count 诗句数量
    @param syllable_pattern 音节模式
    @param rhyme_scheme 韵律方案
    @return 诗词形式标准 *)
val create_poetry_form_standard : 
  string -> int option -> int list option -> string option -> poetry_form_standard

(** 创建质量等级标准
    @param grade_name 等级名称
    @param min_score 最低分数
    @param max_score 最高分数
    @param criteria 评判标准
    @return 质量等级标准 *)
val create_quality_grade_standard : 
  string -> float -> float -> string list -> quality_grade_standard

(** 创建维度评价标准
    @param dimension_name 维度名称
    @param weight 权重
    @param criteria 评价标准
    @return 维度标准 *)
val create_dimension_standard : 
  string -> float -> string list -> dimension_standard

(** {1 预定义标准} *)

(** 获取古典诗词标准
    @return 古典诗词综合标准 *)
val get_classical_poetry_standard : unit -> comprehensive_standard

(** 获取现代诗词标准
    @return 现代诗词综合标准 *)
val get_modern_poetry_standard : unit -> comprehensive_standard

(** 获取绝句标准
    @return 绝句形式标准 *)
val get_jueju_standard : unit -> poetry_form_standard

(** 获取律诗标准
    @return 律诗形式标准 *)
val get_lushi_standard : unit -> poetry_form_standard

(** 获取词牌标准
    @param ci_pai_name 词牌名
    @return 词牌形式标准选项 *)
val get_ci_pai_standard : string -> poetry_form_standard option

(** {1 标准验证} *)

(** 验证诗词符合标准
    @param poem_text 诗词文本
    @param standard 诗词形式标准
    @return (是否符合, 违规项目列表) *)
val validate_poetry_against_standard : 
  string -> poetry_form_standard -> bool * string list

(** 检查质量等级
    @param score 评分
    @param standards 质量等级标准列表
    @return 对应的等级名称选项 *)
val check_quality_grade : float -> quality_grade_standard list -> string option

(** 评估维度符合度
    @param dimension_score 维度评分
    @param standard 维度标准
    @return 符合度分数 *)
val assess_dimension_compliance : float -> dimension_standard -> float

(** {1 标准比较} *)

(** 比较两个标准
    @param standard1 第一个标准
    @param standard2 第二个标准
    @return 比较结果报告 *)
val compare_standards : 
  comprehensive_standard -> comprehensive_standard -> (string * string) list

(** 分析标准差异
    @param standards 标准列表
    @return 差异分析报告 *)
val analyze_standard_differences : 
  comprehensive_standard list -> (string * string list) list

(** {1 自定义标准} *)

(** 注册自定义标准
    @param standard 自定义综合标准 *)
val register_custom_standard : comprehensive_standard -> unit

(** 获取自定义标准
    @param standard_name 标准名称
    @return 标准选项 *)
val get_custom_standard : string -> comprehensive_standard option

(** 列出所有自定义标准
    @return 标准名称列表 *)
val list_custom_standards : unit -> string list

(** 删除自定义标准
    @param standard_name 标准名称
    @return 是否成功删除 *)
val remove_custom_standard : string -> bool

(** {1 标准应用} *)

(** 应用综合标准进行评价
    @param poem_text 诗词文本
    @param standard 综合标准
    @return 评价结果 *)
val apply_comprehensive_standard : 
  string -> comprehensive_standard -> Artistic_core.artistic_evaluation

(** 根据标准计算加权分数
    @param dimension_scores 维度分数列表
    @param standard 综合标准
    @return 加权总分 *)
val calculate_weighted_score_by_standard : 
  (string * float) list -> comprehensive_standard -> float

(** {1 标准统计} *)

(** 统计标准使用情况
    @param standard_name 标准名称
    @return 使用统计信息 *)
val get_standard_usage_statistics : string -> (string * int) list

(** 分析标准效果
    @param standard 综合标准
    @param test_cases 测试案例列表
    @return 效果分析报告 *)
val analyze_standard_effectiveness : 
  comprehensive_standard -> string list -> (string * float) list

(** {1 标准导出导入} *)

(** 导出标准为JSON
    @param standard 综合标准
    @return JSON字符串 *)
val export_standard_to_json : comprehensive_standard -> string

(** 从JSON导入标准
    @param json_string JSON字符串
    @return 导入的标准选项 *)
val import_standard_from_json : string -> comprehensive_standard option

(** 导出标准为文本
    @param standard 综合标准
    @return 文本格式字符串 *)
val export_standard_to_text : comprehensive_standard -> string

(** {1 标准版本管理} *)

(** 创建标准版本
    @param base_standard 基础标准
    @param version 新版本号
    @param changes 变更描述
    @return 新版本标准 *)
val create_standard_version : 
  comprehensive_standard -> string -> string list -> comprehensive_standard

(** 获取标准历史版本
    @param standard_name 标准名称
    @return 历史版本列表 *)
val get_standard_versions : string -> comprehensive_standard list

(** 比较标准版本
    @param old_version 旧版本标准
    @param new_version 新版本标准
    @return 版本差异报告 *)
val compare_standard_versions : 
  comprehensive_standard -> comprehensive_standard -> (string * string) list