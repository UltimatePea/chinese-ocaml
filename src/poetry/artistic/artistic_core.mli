(** 诗词艺术评估核心模块接口
 *
 * 此模块包含诗词艺术评估系统的核心类型定义、评价算法和基础评价器。
 * 提供统一的评价框架和核心评价函数。
 *
 * 主要功能：
 * - 核心评价类型定义
 * - 评价器接口规范
 * - 基础评价算法实现
 * - 综合评价函数
 * - 工具函数集合
 * - API兼容性支持
 *
 * @author Whisky, PR Worker
 *)

(** {1 核心类型定义} *)

(** 评价维度枚举 *)
type evaluation_dimension =
  | RhymeHarmony      (** 韵律和谐 *)
  | TonalBalance      (** 声调平衡 *)
  | MetricalForm      (** 格律形式 *)
  | Parallelism       (** 对仗工整 *)
  | Imagery           (** 意象丰富 *)
  | Rhythm            (** 节奏韵律 *)
  | Elegance          (** 典雅程度 *)
  | ContentDepth      (** 内容深度 *)
  | FormBeauty        (** 形式美感 *)
  | SoundHarmony      (** 音韵和谐 *)
  | ContextMood       (** 意境氛围 *)
  | EmotionExpression (** 情感表达 *)
  | Innovation        (** 创新性 *)
  | Overall           (** 整体评价 *)

(** 维度评分详情 *)
type dimension_score = {
  dimension : evaluation_dimension;  (** 评价维度 *)
  score : float;                    (** 得分 *)
  max_possible : float;             (** 最高可能分数 *)
  confidence : float;               (** 置信度 *)
  details : string option;          (** 详细说明 *)
  suggestions : string list;        (** 改进建议 *)
}

(** 艺术评价结果 *)
type artistic_evaluation = {
  overall_score : float;                                           (** 总体评分 *)
  dimension_scores : dimension_score list;                         (** 各维度评分 *)
  strengths : string list;                                         (** 优势 *)
  weaknesses : string list;                                        (** 劣势 *)
  improvement_suggestions : string list;                           (** 改进建议 *)
  artistic_level : [ `Beginner | `Intermediate | `Advanced | `Master ]; (** 艺术水平 *)
  quality_grade : [ `Excellent | `Good | `Fair | `Poor ];         (** 质量等级 *)
  evaluation_metadata : (string * string) list;                   (** 评价元数据 *)
}

(** 评价上下文 *)
type evaluation_context = {
  verse : string;                     (** 当前诗句 *)
  verses : string list;               (** 所有诗句 *)
  poem_type : string option;          (** 诗词类型 *)
  author : string option;             (** 作者 *)
  historical_context : string option; (** 历史背景 *)
  metadata : (string * string) list;  (** 元数据 *)
}

(** 引擎状态 *)
type engine_state = {
  initialized : bool;     (** 是否已初始化 *)
  cache_size : int;       (** 缓存大小 *)
  evaluation_count : int; (** 评价次数 *)
  last_update : float;    (** 最后更新时间 *)
}

(** 质量评分结构 *)
type quality_scores = {
  rhyme_harmony : float;  (** 韵律和谐分数 *)
  tonal_balance : float;  (** 声调平衡分数 *)
  parallelism : float;    (** 对仗工整分数 *)
  imagery : float;        (** 意象丰富分数 *)
  rhythm : float;         (** 节奏韵律分数 *)
  elegance : float;       (** 典雅程度分数 *)
}

(** 情境分析结果 *)
type mood_analysis = {
  primary_mood : string;       (** 主要情绪 *)
  secondary_moods : string list; (** 次要情绪 *)
  mood_intensity : float;      (** 情绪强度 *)
  mood_coherence : float;      (** 情绪一致性 *)
  mood_techniques : string list; (** 情绪技巧 *)
}

(** 修辞技巧分析结果 *)
type rhetoric_analysis = {
  detected_techniques : string list;           (** 检测到的技巧 *)
  technique_examples : (string * string) list; (** 技巧示例 *)
  rhetoric_richness : float;                   (** 修辞丰富度 *)
  technique_effectiveness : (string * float) list; (** 技巧有效性 *)
}

(** {1 评价器接口定义} *)

module type EVALUATOR = sig
  (** 评价维度 *)
  val dimension : evaluation_dimension
  
  (** 评价器名称 *)
  val name : string
  
  (** 评价器描述 *)
  val description : string
  
  (** 权重 *)
  val weight : float
  
  (** 所需上下文 *)
  val required_context : string list
  
  (** 是否适用于给定上下文 *)
  val is_applicable : evaluation_context -> bool
  
  (** 执行评价 *)
  val evaluate : evaluation_context -> dimension_score
end

(** {1 核心工具函数} *)

(** 字符串包含检测（UTF-8安全）
    @param s 源字符串
    @param sub 子字符串
    @return 是否包含 *)
val string_contains_substring : string -> string -> bool

(** 列表取前n个元素
    @param n 要取的元素数量
    @param lst 源列表
    @return 前n个元素的列表 *)
val list_take : int -> 'a list -> 'a list

(** 提取韵脚字符（支持UTF-8）
    @param verse 诗句
    @return 韵脚字符选项 *)
val extract_final_char : string -> string option

(** 计算韵律多样性
    @param rhyme_chars 韵字列表
    @return (多样性比例, 唯一字符数, 总字符数) *)
val calculate_rhyme_diversity : string list -> float * int * int

(** 加权评分计算
    @param scores 分数列表
    @param weights 权重列表
    @return 加权平均分 *)
val calculate_weighted_score : float list -> float list -> float

(** 提取维度评分
    @param evaluation 评价结果
    @param dimension 目标维度
    @return 该维度的评分 *)
val extract_dimension_score : artistic_evaluation -> evaluation_dimension -> float

(** {1 引擎管理函数} *)

(** 初始化评价引擎
    @return 初始化的引擎状态 *)
val initialize_engine : unit -> engine_state

(** 清理引擎缓存
    @param engine_state 引擎状态
    @return 更新后的引擎状态 *)
val clear_engine_cache : engine_state -> engine_state

(** 获取引擎统计信息
    @param engine_state 引擎状态
    @return 统计信息列表 *)
val get_engine_statistics : engine_state -> (string * string) list

(** 创建评价上下文
    @param verse 当前诗句
    @param verses 所有诗句
    @return 评价上下文 *)
val create_evaluation_context : string -> string list -> evaluation_context

(** {1 基础评价器函数} *)

(** 韵律和谐评价
    @param verse 诗句
    @return 韵律和谐分数 *)
val evaluate_rhyme_harmony : string -> float

(** 声调平衡评价
    @param verse 诗句
    @param expected_pattern 期望模式
    @return 声调平衡分数 *)
val evaluate_tonal_balance : string -> 'a option -> float

(** 意象评价
    @param verse 诗句
    @return 意象丰富度分数 *)
val evaluate_imagery : string -> float

(** 节奏评价
    @param verse 诗句
    @return 节奏韵律分数 *)
val evaluate_rhythm : string -> float

(** 雅致程度评价
    @param verse 诗句
    @return 典雅程度分数 *)
val evaluate_elegance : string -> float

(** 对仗评价
    @param left_verse 左联
    @param right_verse 右联
    @return 对仗工整分数 *)
val evaluate_parallelism : string -> string -> float

(** {1 核心评价函数} *)

(** 计算综合质量等级
    @param scores 质量评分结构
    @return 质量等级 *)
val determine_overall_grade : quality_scores -> [> `Excellent | `Fair | `Good | `Poor ]

(** 综合艺术评价
    @param verses 诗句列表
    @param engine_state 引擎状态
    @return 完整的艺术评价结果 *)
val comprehensive_artistic_evaluation : string list -> engine_state -> artistic_evaluation

(** 单维度评价
    @param dimension 评价维度
    @param context 评价上下文
    @param engine_state 引擎状态
    @return 维度评分选项 *)
val evaluate_single_dimension : 
  evaluation_dimension -> evaluation_context -> engine_state -> dimension_score option

(** {1 诗词形式专门评价函数} *)

(** 五言律诗评价 *)
val evaluate_wuyan_lushi : string -> artistic_evaluation

(** 七言绝句评价 *)
val evaluate_qiyan_jueju : string -> artistic_evaluation

(** 四言排律评价 *)
val evaluate_siyan_parallel_prose : string -> artistic_evaluation

(** 按形式评价诗词 *)
val evaluate_poetry_by_form : 'a -> string -> artistic_evaluation

(** {1 专门分析函数} *)

(** 情境营造分析
    @param verses 诗句列表
    @param engine_state 引擎状态
    @return 情境分析结果 *)
val analyze_mood_creation : string list -> engine_state -> mood_analysis

(** 修辞技巧检测
    @param verses 诗句列表
    @param engine_state 引擎状态
    @return 修辞分析结果 *)
val detect_rhetoric_techniques : string list -> engine_state -> rhetoric_analysis

(** 形式美分析
    @param verses 诗句列表
    @param engine_state 引擎状态
    @return (形式美分数, 建议列表) *)
val analyze_form_beauty : string list -> engine_state -> float * string list

(** 内容深度分析
    @param verses 诗句列表
    @param engine_state 引擎状态
    @return (内容深度分数, 建议列表) *)
val analyze_content_depth : string list -> engine_state -> float * string list

(** 音韵和谐分析
    @param verses 诗句列表
    @param engine_state 引擎状态
    @return (音韵和谐分数, 建议列表) *)
val analyze_sound_harmony : string list -> engine_state -> float * string list

(** 生成改进指导
    @param evaluation 评价结果
    @param engine_state 引擎状态
    @return 改进建议列表 *)
val generate_improvement_guidance : artistic_evaluation -> engine_state -> string list

(** 艺术性增强建议
    @param verses 诗句列表
    @param engine_state 引擎状态
    @return 增强建议列表 *)
val suggest_artistic_enhancements : string list -> engine_state -> string list

(** {1 兼容性API函数} *)

(** 诗词艺术性评价（单一分数）
    @param poem 完整诗词文本
    @return 艺术性分数 *)
val evaluate_poem_artistic : string -> float

(** 多维度评价
    @param verse 诗句
    @return 完整的艺术评价结果 *)
val multi_dimension_evaluation : string -> artistic_evaluation

(** 格式化评价结果
    @param evaluation 评价结果
    @return 格式化的字符串 *)
val format_evaluation_result : artistic_evaluation -> string

(** 导出JSON格式评价结果
    @param evaluation 评价结果
    @return JSON字符串 *)
val export_evaluation_json : artistic_evaluation -> string

(** 快速艺术性检查
    @param verse 诗句
    @return (是否通过检查, 建议列表) *)
val quick_artistic_check : string -> bool * string list