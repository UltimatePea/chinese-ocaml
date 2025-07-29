(** 骆言诗词核心类型定义模块接口 Author: Alpha, 主要工作代理 - 负责功能实现和技术债务处理

    此接口定义了整个诗词模块的核心类型系统。 所有其他模块应该通过此接口访问基础类型定义。 *)

(** === 基础字符和文本类型 === *)

type chinese_character = string
(** UTF-8编码的单个中文字符 *)

type verse_line = string
(** 诗句行，可包含多个字符 *)

type poem_text = verse_line list
(** 完整诗篇，由多行构成 *)

(** === 音韵分类类型 === *)

type rhyme_category =
  | PingSheng  (** 平声韵 - 音平而长，如天籁之响 *)
  | ZeSheng  (** 仄声韵 - 音仄而促，如金石之声 *)
  | ShangSheng  (** 上声韵 - 音上扬，如询问之态 *)
  | QuSheng  (** 去声韵 - 音下降，如叹息之音 *)
  | RuSheng  (** 入声韵 - 音促而急，如鼓点之节 *)

type rhyme_group =
  | AnRhyme  (** 安韵组 - 含山、间、闲等字，音韵和谐 *)
  | SiRhyme  (** 思韵组 - 含时、诗、知等字，情思绵绵 *)
  | TianRhyme  (** 天韵组 - 含年、先、田等字，天籁之音 *)
  | WangRhyme  (** 望韵组 - 含放、向、响等字，远望之意 *)
  | QuRhyme  (** 去韵组 - 含路、度、步等字，去声之韵 *)
  | YuRhyme  (** 鱼韵组 - 含鱼、书、居等字，渔樵江渚 *)
  | HuaRhyme  (** 花韵组 - 含花、霞、家等字，春花秋月 *)
  | FengRhyme  (** 风韵组 - 含风、送、中等字，秋风萧瑟 *)
  | YueRhyme  (** 月韵组 - 含月、雪、节等字，秋月如霜 *)
  | XueRhyme  (** 雪韵组 - 扩展雪字韵组 *)
  | JiangRhyme  (** 江韵组 - 含江、窗、双等字，大江东去 *)
  | HuiRhyme  (** 灰韵组 - 含灰、回、推等字，灰飞烟灭 *)
  | UnknownRhyme  (** 未知韵组 - 韵书未载，待考证者 *)

(** === 韵律数据类型 === *)

type rhyme_data_entry = {
  character : string;  (** 字符 *)
  category : rhyme_category;  (** 声韵类别 *)
  group : rhyme_group;  (** 韵组 *)
  variants : string list;  (** 异体字或相关字 *)
  usage_frequency : float;  (** 使用频度 *)
}
(** 韵律数据条目 - 描述单个字符的韵律信息 *)

type rhyme_match_result = {
  is_match : bool;  (** 是否匹配 *)
  match_quality : float;  (** 匹配质量 0.0-1.0 *)
  match_reason : string;  (** 匹配原因说明 *)
}
(** 韵律匹配结果 - 从Rhyme_core_types兼容版本 *)

type char_rhyme_info = {
  character : string;  (** 字符内容 *)
  rhyme_category : rhyme_category;  (** 声韵分类 *)
  rhyme_group : rhyme_group;  (** 所属韵组 *)
  confidence : float;  (** 分析置信度 0.0-1.0 *)
}
(** 单个字符的韵律分析结果 *)

type verse_rhyme_analysis = {
  verse_text : string;  (** 诗句原文 *)
  rhyme_ending : string option;  (** 韵脚字符 *)
  dominant_rhyme_group : rhyme_group;  (** 主要韵组 *)
  dominant_rhyme_category : rhyme_category;  (** 主要声韵类别 *)
  char_analysis : char_rhyme_info list;  (** 逐字韵律分析 *)
  rhyme_quality_score : float;  (** 韵律质量评分 *)
}
(** 诗句韵律分析报告 *)

type poem_rhyme_analysis = {
  verses : string list;  (** 诗句列表 *)
  verse_analyses : verse_rhyme_analysis list;  (** 各句分析结果 *)
  overall_rhyme_groups : rhyme_group list;  (** 全诗使用的韵组 *)
  overall_rhyme_categories : rhyme_category list;  (** 全诗使用的声韵类别 *)
  rhyme_consistency_score : float;  (** 韵律一致性评分 *)
  artistic_quality_score : float;  (** 艺术质量评分 *)
  suggestions : string list;  (** 改进建议 *)
}
(** 整体诗篇韵律分析报告 *)

type rhyme_suggestion = {
  suggestion_type : string;  (** 建议类型 *)
  original_char : string;  (** 原字符 *)
  suggested_chars : string list;  (** 建议字符列表 *)
  reason : string;  (** 建议理由 *)
  improvement_score : float;  (** 改进分数 *)
}
(** 韵律建议类型 *)

(** === 错误和异常类型 === *)

(** 韵律分析错误类型 *)
type rhyme_error =
  | CharacterNotFound of string  (** 字符未在韵书中找到 *)
  | InvalidRhymeGroup of string  (** 无效韵组 *)
  | DataCorruption of string  (** 数据损坏 *)
  | ConfigurationError of string  (** 配置错误 *)
  | AnalysisFailure of string  (** 分析失败 *)

exception RhymeException of rhyme_error
(** 韵律异常 *)

exception Json_parse_error of string
(** JSON解析错误异常 *)

(** === 艺术性评价类型 === *)

type artistic_dimension =
  | RhymeHarmony  (** 韵律和谐 *)
  | TonalBalance  (** 声调平衡 *)
  | Parallelism  (** 对仗工整 *)
  | Imagery  (** 意象深度 *)
  | Rhythm  (** 节奏感 *)
  | Elegance  (** 雅致程度 *)
  | ClassicalElegance  (** 古典雅致 *)
  | ModernInnovation  (** 现代创新 *)
  | CulturalDepth  (** 文化深度 *)
  | EmotionalResonance  (** 情感共鸣 *)
  | IntellectualDepth  (** 理性深度 *)

type evaluation_grade =
  | Excellent  (** 上品 - 意境高远，韵律和谐，可称佳作 *)
  | Good  (** 中品 - 格律工整，音韵协调，颇具水准 *)
  | Fair  (** 下品 - 基本合格，略有瑕疵，尚可改进 *)
  | Poor  (** 不入流 - 格律错乱，音韵不谐，需重修 *)

type artistic_evaluation_result = {
  overall_grade : evaluation_grade;
  dimension_scores : (artistic_dimension * float) list;
  detailed_feedback : string;
  suggestions : string list;
}

(** === 诗词形式类型 === *)

type poem_form =
  | LuShi  (** 律诗 - 八句成篇，格律严整 *)
  | JueShi  (** 绝句 - 四句成篇，意境深远 *)
  | GuFengShi  (** 古风诗 - 格律自由，古朴自然 *)
  | CiPai of string  (** 词牌 - 依谱填词，音律优美 *)
  | FuTi  (** 赋体 - 铺陈其事，华丽藻饰 *)

type meter_pattern =
  | PingZe_Pattern of bool list  (** 平仄格律模式，true为平，false为仄 *)
  | Free_Verse  (** 自由诗，不拘格律 *)

(** === 分析查询类型 === *)

type analysis_depth =
  | Surface  (** 表面分析 - 基础音韵匹配 *)
  | Moderate  (** 中等分析 - 包含格律检查 *)
  | Deep  (** 深度分析 - 全面艺术性评价 *)

type rhyme_query = { text : string; target_rhyme : string option; analysis_depth : analysis_depth }

type artistic_query = {
  poem : poem_text;
  form : poem_form option;
  criteria : artistic_dimension list;
}

(** === 结果和响应类型 === *)

type 'a analysis_result = Success of 'a | Failure of string | Partial of 'a * string list

type rhyme_analysis_result = {
  matches : (string * rhyme_match_result * float) list;
  suggestions : string list;
  confidence : float;
}

type artistic_analysis_result = {
  evaluation : artistic_evaluation_result;
  rhyme_analysis : rhyme_analysis_result;
  meter_analysis : meter_pattern option;
}

(** === 数据源和缓存类型 === *)

type data_source_type = JSON_File of string | Memory_Cache | External_API
type cache_policy = No_Cache | LRU_Cache of int | TTL_Cache of int

(** === 配置类型 === *)

type analysis_config = {
  strict_mode : bool;
  cache_policy : cache_policy;
  data_sources : data_source_type list;
  custom_rhyme_groups : (string * rhyme_group) list;
}

(** === 工具函数类型 === *)

type 'a comparison_result = Equal | Greater | Less
type 'a conversion_result = Converted of 'a | Conversion_Failed of string

(** === 类型转换函数 === *)

val string_of_rhyme_category : rhyme_category -> string
(** 将韵律分类转换为中文字符串 *)

val string_of_rhyme_group : rhyme_group -> string
(** 将韵组转换为中文字符串 *)

val string_of_evaluation_grade : evaluation_grade -> string
(** 将评价等级转换为中文字符串 *)

(** === 兼容性函数 - 向后兼容其他模块 === *)

val rhyme_category_to_string : rhyme_category -> string
(** 韵类转中文字符串 - 兼容函数 *)

val rhyme_group_to_string : rhyme_group -> string
(** 韵组转中文字符串 - 兼容函数 *)

val string_to_rhyme_category : string -> rhyme_category option
(** 字符串转韵类，支持中英文输入 *)

val string_to_rhyme_group : string -> rhyme_group option
(** 字符串转韵组，支持中英文输入 *)

val rhyme_category_equal : rhyme_category -> rhyme_category -> bool
(** 比较两个韵类是否相等 *)

val rhyme_group_equal : rhyme_group -> rhyme_group -> bool
(** 比较两个韵组是否相等 *)

val is_ping_sheng : rhyme_category -> bool
(** 判断是否为平声韵 *)

val is_ze_sheng : rhyme_category -> bool
(** 判断是否为仄声韵 *)

(** === 诗词形式和标准类型 (从artistic_types.ml整合) === *)

type poetry_form =
  | SiYanPianTi (** 四言骈体 *)
  | WuYanLuShi (** 五言律诗 *)
  | QiYanJueJu (** 七言绝句 *)
  | CiPai of string (** 词牌格律 *)
  | ModernPoetry (** 现代诗 *)
  | SiYanParallelProse (** 四言排律 *)

type siyan_artistic_standards = {
  char_count : int; (** 字数标准：每句四字 *)
  tone_pattern : bool list; (** 声调模式：平仄相对 *)
  parallelism_required : bool; (** 是否要求对仗 *)
  rhythm_weight : float; (** 节奏权重 *)
}

type wuyan_lushi_standards = {
  line_count : int; (** 句数标准：八句 *)
  char_per_line : int; (** 每句字数：五字 *)
  rhyme_scheme : bool array; (** 韵脚模式：2-4-6-8句押韵 *)
  parallelism_required : bool array; (** 对仗要求：颔联、颈联对仗 *)
  tone_pattern : bool list list; (** 声调模式：平仄相对 *)
  rhythm_weight : float; (** 节奏权重 *)
}

type qiyan_jueju_standards = {
  line_count : int; (** 句数标准：四句 *)
  char_per_line : int; (** 每句字数：七字 *)
  rhyme_scheme : bool array; (** 韵脚模式：2-4句押韵 *)
  parallelism_required : bool array; (** 对仗要求：后两句对仗 *)
  tone_pattern : bool list list; (** 声调模式：平仄相对 *)
  rhythm_weight : float; (** 节奏权重 *)
}

type artistic_report = {
  verse : string; (** 原诗句 *)
  rhyme_score : float; (** 韵律得分 *)
  tone_score : float; (** 声调得分 *)
  parallelism_score : float; (** 对仗得分 *)
  imagery_score : float; (** 意象得分 *)
  rhythm_score : float; (** 节奏得分 *)
  elegance_score : float; (** 雅致得分 *)
  overall_grade : evaluation_grade; (** 整体评级 *)
  detailed_feedback : string; (** 详细反馈 *)
  suggestions : string list; (** 改进建议 *)
}

type artistic_scores = {
  rhyme_harmony : float; (** 韵律和谐 0.0-1.0 *)
  tonal_balance : float; (** 声调平衡 0.0-1.0 *)
  parallelism : float; (** 对仗工整 0.0-1.0 *)
  imagery : float; (** 意象深度 0.0-1.0 *)
  rhythm : float; (** 节奏感 0.0-1.0 *)
  elegance : float; (** 雅致程度 0.0-1.0 *)
  overall : float; (** 综合得分 0.0-1.0 *)
}

(** === 转换函数扩展 === *)

val dimension_to_string : artistic_dimension -> string
(** 将艺术性维度转换为中文字符串 *)

val poetry_form_to_string : poetry_form -> string
(** 将诗词形式转换为中文字符串 *)

(** === 数据库和统一类型定义 === *)

type rhyme_database = (string * rhyme_category * rhyme_group) list
(** 韵律数据库类型 - 存储字符与韵律信息的关联列表 *)

type rhyme_data_item = {
  character : string;  (** 字符 *)
  category : rhyme_category;  (** 声韵类别 *)
  group : rhyme_group;  (** 韵组 *)
  confidence : float;  (** 置信度 *)
}
(** 韵律数据项 - 描述单个字符的韵律信息 *)

(** === 补充类型定义 (从poetry_types_consolidated.ml整合) === *)

type rhyme_analysis_report = {
  verse : string;
  rhyme_ending : char option;
  rhyme_group : rhyme_group;
  rhyme_category : rhyme_category;
  char_analysis : (char * rhyme_category * rhyme_group) list;
}

type tone_info = { 
  char : char; 
  tone : rhyme_category; 
  is_tonal_mismatch : bool 
}

type tone_analysis_report = {
  verse : string;
  tone_pattern : bool list; (** true=平声, false=仄声 *)
  tone_infos : tone_info list;
  balance_score : float; (** 0.0-1.0，声调平衡程度 *)
  adherence_score : float; (** 0.0-1.0，格律遵循程度 *)
}

type verse_summary = {
  verse : string;
  rhyme_info : rhyme_analysis_report;
  tone_info : tone_analysis_report;
  artistic_info : artistic_report;
}

type comprehensive_analysis = {
  poem_text : string list;
  form : poetry_form;
  verse_summaries : verse_summary list;
  overall_rhyme : poem_rhyme_analysis;
  overall_artistic : artistic_scores;
  final_grade : evaluation_grade;
  critique : string;
}
