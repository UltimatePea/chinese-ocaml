(** 艺术数据访问器 - Phase 2.3.2 专用艺术评价数据访问模块

    本模块专门处理诗词艺术性评价相关的数据访问，包括意象词汇、雅致用词、评价标准等。
    基于统一数据引擎构建，为艺术评价系统提供数据支撑。

    @author Alpha, 主要工作代理 - Phase 2.3.2 数据加载器系统整合  
    @version 2.3.2
    @since 2025-07-30 *)

(** {1 艺术数据类型定义} *)

(** 词汇类别 *)
type word_category =
  | Imagery           (** 意象词汇 *)
  | Elegant           (** 雅致词汇 *)
  | Metaphor          (** 比喻词汇 *)
  | Emotion           (** 情感词汇 *)
  | Nature            (** 自然词汇 *)
  | Classical         (** 古典词汇 *)

(** 艺术评价维度 *)
type evaluation_dimension =
  | RhymeHarmony      (** 韵律和谐度 *)
  | TonalBalance      (** 声调平衡度 *)
  | Parallelism       (** 对仗工整度 *)
  | ImageryDepth      (** 意象深度 *)
  | FormBeauty        (** 形式美感 *)
  | ContentDepth      (** 内容深度 *)
  | MoodContext       (** 意境营造 *)

(** 词汇信息 *)
type word_info = {
  word : string;                    (** 词汇 *)
  category : word_category;         (** 类别 *)
  frequency : int;                  (** 使用频率 *)
  artistic_value : float;           (** 艺术价值评分 (0.0-1.0) *)
  synonyms : string list;           (** 同义词 *)
  contexts : string list;           (** 使用语境 *)
  examples : string list;           (** 使用示例 *)
}

(** 评价标准 *)
type evaluation_standard = {
  dimension : evaluation_dimension; (** 评价维度 *)
  name : string;                    (** 标准名称 *)
  description : string;             (** 描述 *)
  weight : float;                   (** 权重 (0.0-1.0) *)
  min_score : float;                (** 最低分数 *)
  max_score : float;                (** 最高分数 *)
  criteria : (string * float) list; (** 具体标准 (描述, 分值) *)
}

(** 艺术模板 *)
type artistic_template = {
  name : string;                    (** 模板名称 *)
  category : word_category;         (** 适用类别 *)
  pattern : string;                 (** 模式描述 *)
  examples : string list;           (** 使用示例 *)
  effectiveness : float;            (** 有效性评分 *)
}

(** 查询结果类型 *)
type 'a query_result = 
  | Found of 'a
  | NotFound
  | QueryError of string

(** {1 初始化和配置} *)

val initialize : unit -> unit
(** 初始化艺术数据访问器

    自动注册必要的艺术数据源到统一引擎 *)

val is_initialized : unit -> bool
(** 检查是否已初始化 *)

val register_custom_word_source : string -> string -> unit
(** 注册自定义词汇数据源

    @param name 数据源名称
    @param filepath 数据文件路径 *)

(** {1 词汇查询接口} *)

val get_word_info : string -> word_info query_result
(** 获取词汇的详细信息

    @param word 词汇
    @return 词汇信息查询结果 *)

val get_words_by_category : word_category -> string list query_result
(** 按类别获取词汇列表

    @param category 词汇类别
    @return 词汇列表查询结果 *)

val search_words_by_pattern : string -> string list query_result
(** 按模式搜索词汇

    @param pattern 搜索模式（支持正则表达式）
    @return 匹配的词汇列表 *)

val get_high_value_words : word_category -> int -> (string * float) list query_result
(** 获取指定类别的高艺术价值词汇

    @param category 词汇类别
    @param limit 返回数量限制
    @return (词汇, 艺术价值) 列表 *)

(** {1 意象词汇专用接口} *)

val get_imagery_keywords : unit -> string list query_result
(** 获取意象关键词列表

    @return 意象关键词列表 *)

val get_nature_imagery : unit -> string list query_result
(** 获取自然意象词汇

    @return 自然意象词汇列表 *)

val get_seasonal_imagery : string -> string list query_result
(** 获取季节性意象词汇

    @param season 季节（春、夏、秋、冬）
    @return 季节意象词汇列表 *)

val suggest_imagery_for_theme : string -> string list query_result
(** 为指定主题推荐意象词汇

    @param theme 主题
    @return 推荐的意象词汇列表 *)

(** {1 雅致词汇专用接口} *)

val get_elegant_words : unit -> string list query_result
(** 获取雅致词汇列表

    @return 雅致词汇列表 *)

val get_classical_expressions : unit -> string list query_result
(** 获取古典表达

    @return 古典表达列表 *)

val get_formal_particles : unit -> string list query_result
(** 获取文言助词

    @return 文言助词列表 *)

val assess_word_elegance : string -> float query_result
(** 评估词汇的雅致程度

    @param word 词汇
    @return 雅致程度评分 (0.0-1.0) *)

(** {1 评价标准管理} *)

val get_evaluation_standards : evaluation_dimension -> evaluation_standard list query_result
(** 获取指定维度的评价标准

    @param dimension 评价维度
    @return 评价标准列表 *)

val get_all_evaluation_dimensions : unit -> evaluation_dimension list
(** 获取所有评价维度

    @return 评价维度列表 *)

val get_standard_weights : unit -> (evaluation_dimension * float) list query_result
(** 获取各维度的标准权重

    @return (评价维度, 权重) 列表 *)

val validate_evaluation_criteria : evaluation_dimension -> string -> bool query_result
(** 验证评价标准

    @param dimension 评价维度
    @param criteria_text 待验证的标准文本
    @return 验证结果 *)

(** {1 艺术模板管理} *)

val get_artistic_templates : word_category -> artistic_template list query_result
(** 获取指定类别的艺术模板

    @param category 词汇类别
    @return 艺术模板列表 *)

val suggest_template_for_context : string -> artistic_template list query_result
(** 为指定语境推荐艺术模板

    @param context 语境描述
    @return 推荐的艺术模板列表 *)

val evaluate_template_effectiveness : string -> float query_result
(** 评估模板的有效性

    @param template_name 模板名称
    @return 有效性评分 (0.0-1.0) *)

(** {1 高级分析功能} *)

val analyze_text_artistic_elements : string -> (word_category * string list) list query_result
(** 分析文本中的艺术元素

    @param text 待分析文本
    @return (词汇类别, 词汇列表) 列表 *)

val suggest_improvements : string -> evaluation_dimension -> string list query_result
(** 为文本推荐改进建议

    @param text 待改进文本
    @param focus_dimension 关注的评价维度
    @return 改进建议列表 *)

val calculate_artistic_score : string -> (evaluation_dimension * float) list query_result
(** 计算文本的艺术性评分

    @param text 待评分文本
    @return (评价维度, 得分) 列表 *)

val compare_artistic_quality : string -> string -> (evaluation_dimension * float * float) list query_result
(** 比较两个文本的艺术性

    @param text1 文本1
    @param text2 文本2
    @return (评价维度, 文本1得分, 文本2得分) 列表 *)

(** {1 数据统计和分析} *)

val get_word_category_statistics : unit -> (word_category * int) list query_result
(** 获取词汇类别统计

    @return (词汇类别, 词汇数量) 列表 *)

val get_popular_words : word_category -> int -> (string * int) list query_result
(** 获取热门词汇

    @param category 词汇类别
    @param limit 返回数量限制
    @return (词汇, 使用频率) 列表 *)

val get_artistic_trends : unit -> (word_category * float) list query_result
(** 获取艺术趋势分析

    @return (词汇类别, 趋势指数) 列表 *)

(** {1 兼容性接口} *)

val load_imagery_data : unit -> string list
(** 兼容性接口：加载意象数据

    @deprecated 建议使用 get_imagery_keywords
    @return 意象关键词列表 *)

val load_elegant_data : unit -> string list
(** 兼容性接口：加载雅致词汇数据

    @deprecated 建议使用 get_elegant_words
    @return 雅致词汇列表 *)

val check_word_availability : string -> bool
(** 兼容性接口：检查词汇可用性

    @param word 词汇
    @return 是否在数据库中 *)

(** {1 错误处理和诊断} *)

val format_query_error : string -> string
(** 格式化查询错误信息

    @param error_msg 错误信息
    @return 格式化的错误字符串 *)

val validate_data_integrity : unit -> (string * bool * string option) list
(** 验证艺术数据完整性

    @return (数据源名称, 验证通过, 错误信息) 列表 *)

val get_cache_status : unit -> (string * bool * int) list
(** 获取缓存状态

    @return (数据源名称, 是否缓存, 缓存大小) 列表 *)

val diagnose_performance : unit -> string
(** 诊断性能状况

    @return 性能诊断报告 *)