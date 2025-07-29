(** 骆言诗词统一数据类型模块接口 - Poetry模块整合优化 Fix #1707
    
    此模块接口定义了所有诗词分析系统的核心类型。
    提供统一的类型定义，消除模块间重复，提升维护性。
    
    Author: Alpha, 主要工作代理 *)

(** {1 基础字符和文本类型} *)

type chinese_character = string
(** UTF-8编码的单个中文字符 *)

type verse_line = string
(** 诗句行，可包含多个字符 *)

type poem_text = verse_line list
(** 完整诗篇，由多行构成 *)

(** {1 音韵分类类型} *)

(** 音韵分类：依古韵书分平仄入声 *)
type rhyme_category =
  | PingSheng   (** 平声韵 - 音平而长，如天籁之响 *)
  | ZeSheng     (** 仄声韵 - 音仄而促，如金石之声 *)
  | ShangSheng  (** 上声韵 - 音上扬，如询问之态 *)
  | QuSheng     (** 去声韵 - 音下降，如叹息之音 *)
  | RuSheng     (** 入声韵 - 音促而急，如鼓点之节 *)

(** 韵组分类：按韵书传统分组，同组可押韵 *)
type rhyme_group =
  | AnRhyme     (** 安韵组 - 含山、间、闲等字，音韵和谐 *)
  | SiRhyme     (** 思韵组 - 含时、诗、知等字，情思绵绵 *)
  | TianRhyme   (** 天韵组 - 含年、先、田等字，天籁之音 *)
  | WangRhyme   (** 望韵组 - 含放、向、响等字，远望之意 *)
  | QuRhyme     (** 去韵组 - 含路、度、步等字，去声之韵 *)
  | YuRhyme     (** 鱼韵组 - 含鱼、书、居等字，渔樵江渚 *)
  | HuaRhyme    (** 花韵组 - 含花、霞、家等字，春花秋月 *)
  | FengRhyme   (** 风韵组 - 含风、送、中等字，秋风萧瑟 *)
  | YueRhyme    (** 月韵组 - 含月、雪、节等字，秋月如霜 *)
  | XueRhyme    (** 雪韵组 - 扩展雪字韵组 *)
  | JiangRhyme  (** 江韵组 - 含江、窗、双等字，大江东去 *)
  | HuiRhyme    (** 灰韵组 - 含灰、回、推等字，灰飞烟灭 *)
  | UnknownRhyme (** 未知韵组 - 韵书未载，待考证者 *)

(** {1 韵律数据结构类型} *)

(** 韵律数据条目 - 描述单个字符的韵律信息 *)
type rhyme_data_entry = {
  character : string;           (** 字符 *)
  category : rhyme_category;    (** 声韵类别 *)
  group : rhyme_group;          (** 韵组 *)
  variants : string list;       (** 异体字或相关字 *)
  usage_frequency : float;      (** 使用频度 *)
}

(** 韵律匹配结果 *)
type rhyme_match_result = {
  is_match : bool;              (** 是否匹配 *)
  match_quality : float;        (** 匹配质量 0.0-1.0 *)
  match_reason : string;        (** 匹配原因说明 *)
}

(** 单个字符的韵律分析结果 *)
type char_rhyme_info = {
  character : string;           (** 字符内容 *)
  rhyme_category : rhyme_category; (** 声韵分类 *)
  rhyme_group : rhyme_group;    (** 所属韵组 *)
  confidence : float;           (** 分析置信度 0.0-1.0 *)
}

(** 诗句韵律分析报告 *)
type verse_rhyme_analysis = {
  verse_text : string;          (** 诗句原文 *)
  rhyme_ending : string option; (** 韵脚字符 *)
  dominant_rhyme_group : rhyme_group; (** 主要韵组 *)
  dominant_rhyme_category : rhyme_category; (** 主要声韵类别 *)
  char_analysis : char_rhyme_info list; (** 逐字韵律分析 *)
  rhyme_quality_score : float;  (** 韵律质量评分 *)
}

(** 整体诗篇韵律分析报告 *)
type poem_rhyme_analysis = {
  verses : string list;         (** 诗句列表 *)
  verse_analyses : verse_rhyme_analysis list; (** 各句分析结果 *)
  overall_rhyme_groups : rhyme_group list; (** 全诗使用的韵组 *)
  overall_rhyme_categories : rhyme_category list; (** 全诗使用的声韵类别 *)
  rhyme_consistency_score : float; (** 韵律一致性评分 *)
  artistic_quality_score : float; (** 艺术质量评分 *)
  suggestions : string list;    (** 改进建议 *)
}

(** 韵律建议类型 *)
type rhyme_suggestion = {
  suggestion_type : string;     (** 建议类型 *)
  original_char : string;       (** 原字符 *)
  suggested_chars : string list; (** 建议字符列表 *)
  reason : string;              (** 建议理由 *)
  improvement_score : float;    (** 改进分数 *)
}

(** {1 艺术性评价类型} *)

(** 艺术性评价维度 *)
type artistic_dimension =
  | RhymeHarmony       (** 韵律和谐 *)
  | TonalBalance       (** 声调平衡 *)
  | Parallelism        (** 对仗工整 *)
  | Imagery            (** 意象深度 *)
  | Rhythm             (** 节奏感 *)
  | Elegance           (** 雅致程度 *)
  | ClassicalElegance  (** 古典雅致 *)
  | ModernInnovation   (** 现代创新 *)
  | CulturalDepth      (** 文化深度 *)
  | EmotionalResonance (** 情感共鸣 *)
  | IntellectualDepth  (** 理性深度 *)

(** 评价等级：依传统诗词品评标准 *)
type evaluation_grade =
  | Excellent  (** 上品 - 意境高远，韵律和谐，可称佳作 *)
  | Good       (** 中品 - 格律工整，音韵协调，颇具水准 *)
  | Fair       (** 下品 - 基本合格，略有瑕疵，尚可改进 *)
  | Poor       (** 不入流 - 格律错乱，音韵不谐，需重修 *)

(** 艺术性评价结果 *)
type artistic_evaluation_result = {
  overall_grade : evaluation_grade;
  dimension_scores : (artistic_dimension * float) list;
  detailed_feedback : string;
  suggestions : string list;
}

(** 艺术性报告 *)
type artistic_report = {
  verse : string;
  rhyme_score : float;
  tone_score : float;
  parallelism_score : float;
  imagery_score : float;
  rhythm_score : float;
  elegance_score : float;
  overall_grade : evaluation_grade;
  suggestions : string list;
}

(** 艺术性分数汇总 *)
type artistic_scores = {
  rhyme_harmony : float;
  tonal_balance : float;
  parallelism : float;
  imagery : float;
  rhythm : float;
  elegance : float;
}

(** {1 诗词形式类型} *)

(** 诗词形式枚举 *)
type poem_form =
  | LuShi           (** 律诗 - 八句成篇，格律严整 *)
  | JueShi          (** 绝句 - 四句成篇，意境深远 *)
  | GuFengShi       (** 古风诗 - 格律自由，古朴自然 *)
  | CiPai of string (** 词牌 - 依谱填词，音律优美 *)
  | FuTi            (** 赋体 - 铺陈其事，华丽藻饰 *)

(** 新增专门诗形 *)
type poetry_form =
  | SiYanPianTi           (** 四言骈体 *)
  | WuYanLuShi            (** 五言律诗 *)
  | QiYanJueJu            (** 七言绝句 *)
  | CiPaiForm of string   (** 词牌形式 *)
  | ModernPoetry          (** 现代诗 *)
  | SiYanParallelProse    (** 四言骈体散文 *)

(** 格律模式 *)
type meter_pattern =
  | PingZe_Pattern of bool list (** 平仄格律模式，true为平，false为仄 *)
  | Free_Verse                  (** 自由诗，不拘格律 *)

(** {1 分析查询类型} *)

(** 分析深度 *)
type analysis_depth =
  | Surface   (** 表面分析 - 基础音韵匹配 *)
  | Moderate  (** 中等分析 - 包含格律检查 *)
  | Deep      (** 深度分析 - 全面艺术性评价 *)

(** 韵律查询 *)
type rhyme_query = {
  text : string;
  target_rhyme : string option;
  analysis_depth : analysis_depth;
}

(** 艺术性查询 *)
type artistic_query = {
  poem : poem_text;
  form : poem_form option;
  criteria : artistic_dimension list;
}

(** {1 结果和响应类型} *)

(** 通用分析结果类型 *)
type 'a analysis_result =
  | Success of 'a
  | Failure of string
  | Partial of 'a * string list (** 部分成功，带警告信息 *)

(** 韵律分析结果 *)
type rhyme_analysis_result = {
  matches : (string * rhyme_match_result * float) list;
  suggestions : string list;
  confidence : float;
}

(** 艺术性分析结果 *)
type artistic_analysis_result = {
  evaluation : artistic_evaluation_result;
  rhyme_analysis : rhyme_analysis_result;
  meter_analysis : meter_pattern option;
}

(** {1 数据源和配置类型} *)

(** 数据源类型 *)
type data_source_type =
  | JSON_File of string
  | Memory_Cache
  | External_API

(** 缓存策略 *)
type cache_policy =
  | No_Cache
  | LRU_Cache of int    (** 最大缓存条目数 *)
  | TTL_Cache of int    (** 生存时间，秒 *)

(** 分析配置 *)
type analysis_config = {
  strict_mode : bool;    (** 严格模式，更严格的韵律要求 *)
  cache_policy : cache_policy;
  data_sources : data_source_type list;
  custom_rhyme_groups : (string * rhyme_group) list; (** 自定义韵组 *)
}

(** {1 错误和异常类型} *)

(** 韵律分析错误类型 *)
type rhyme_error =
  | CharacterNotFound of string   (** 字符未在韵书中找到 *)
  | InvalidRhymeGroup of string   (** 无效韵组 *)
  | DataCorruption of string      (** 数据损坏 *)
  | ConfigurationError of string  (** 配置错误 *)
  | AnalysisFailure of string     (** 分析失败 *)

exception RhymeException of rhyme_error
(** 韵律异常 *)

exception Json_parse_error of string
exception Rhyme_data_not_found of string

(** {1 类型转换函数} *)

val string_of_rhyme_category : rhyme_category -> string
(** 韵类转字符串 *)

val string_of_rhyme_group : rhyme_group -> string
(** 韵组转字符串 *)

val string_of_evaluation_grade : evaluation_grade -> string
(** 评级转字符串 *)

val string_of_artistic_dimension : artistic_dimension -> string
(** 艺术维度转字符串 *)

val string_of_poem_form : poem_form -> string
(** 诗词形式转字符串 *)

val string_of_poetry_form : poetry_form -> string
(** 诗形转字符串 *)

val string_to_rhyme_category : string -> rhyme_category option
(** 字符串转韵类 *)

val string_to_rhyme_group : string -> rhyme_group option
(** 字符串转韵组 *)

(** {1 比较和判断函数} *)

val rhyme_category_equal : rhyme_category -> rhyme_category -> bool
(** 韵类相等比较 *)

val rhyme_group_equal : rhyme_group -> rhyme_group -> bool
(** 韵组相等比较 *)

val is_ping_sheng : rhyme_category -> bool
(** 判断是否为平声 *)

val is_ze_sheng : rhyme_category -> bool
(** 判断是否为仄声 *)

(** {1 工具函数} *)

val create_empty_artistic_report : string -> artistic_report
(** 创建空的艺术性报告 *)

val calculate_overall_score : artistic_report -> float
(** 计算总体分数 *)

val update_overall_grade : artistic_report -> artistic_report
(** 更新总体评级 *)

(** {1 向后兼容性别名} *)

val rhyme_category_to_string : rhyme_category -> string
(** 兼容别名：韵类转字符串 *)

val rhyme_group_to_string : rhyme_group -> string
(** 兼容别名：韵组转字符串 *)

val dimension_to_string : artistic_dimension -> string
(** 兼容别名：艺术维度转字符串 *)

val grade_to_string : evaluation_grade -> string
(** 兼容别名：评级转字符串 *)

val form_to_string : poetry_form -> string
(** 兼容别名：诗形转字符串 *)