(** 骆言诗词统一类型定义模块 - 单一数据源架构
    
    Author: Alpha, 主要工作代理 - 负责功能实现和技术债务处理
    Phase: 1.2.1 核心类型统一 (Poetry模块重构Phase 1)
    Date: 2025-07-29
    
    此模块是整个Poetry系统的统一类型定义中心，消除了之前30+文件的类型重复定义问题。
    统一整合以下文件的类型定义：
    - poetry_types.ml (452行) 
    - rhyme_types.ml (兼容层)
    - poetry_core_types.ml (121行)
    - artistic_types.ml (部分)
    - rhyme_core_types.ml (兼容层)
    - poetry_types_consolidated.ml
    
    设计原则：
    1. 单一数据源 - 所有类型定义集中于此
    2. 层次清晰 - 从基础类型到复合类型
    3. 语义明确 - 每个类型有明确的业务含义
    4. 向后兼容 - 保持现有API的兼容性
    5. 消除重复 - 一个概念只定义一次
*)

(** === 基础字符和文本类型 === *)

type chinese_character = string (* UTF-8编码的单个中文字符 *)
type verse_line = string (* 诗句行，可包含多个字符 *)
type poem_text = verse_line list (* 完整诗篇，由多行构成 *)

(** === 音韵分类类型 === *)

(* 音韵分类：依古韵书分平仄入声 *)
type rhyme_category =
  | PingSheng (* 平声韵 - 音平而长，如天籁之响 *)
  | ZeSheng (* 仄声韵 - 音仄而促，如金石之声 *)
  | ShangSheng (* 上声韵 - 音上扬，如询问之态 *)
  | QuSheng (* 去声韵 - 音下降，如叹息之音 *)
  | RuSheng (* 入声韵 - 音促而急，如鼓点之节 *)

(* 韵组分类：按韵书传统分组，同组可押韵 *)
type rhyme_group =
  | AnRhyme (* 安韵组 - 含山、间、闲等字，音韵和谐 *)
  | SiRhyme (* 思韵组 - 含时、诗、知等字，情思绵绵 *)
  | TianRhyme (* 天韵组 - 含年、先、田等字，天籁之音 *)
  | WangRhyme (* 望韵组 - 含放、向、响等字，远望之意 *)
  | QuRhyme (* 去韵组 - 含路、度、步等字，去声之韵 *)
  | YuRhyme (* 鱼韵组 - 含鱼、书、居等字，渔樵江渚 *)
  | HuaRhyme (* 花韵组 - 含花、霞、家等字，春花秋月 *)
  | FengRhyme (* 风韵组 - 含风、送、中等字，秋风萧瑟 *)
  | YueRhyme (* 月韵组 - 含月、雪、节等字，秋月如霜 *)
  | XueRhyme (* 雪韵组 - 扩展雪字韵组 *)
  | JiangRhyme (* 江韵组 - 含江、窗、双等字，大江东去 *)
  | HuiRhyme (* 灰韵组 - 含灰、回、推等字，灰飞烟灭 *)
  | UnknownRhyme (* 未知韵组 - 韵书未载，待考证者 *)

(** === 韵律数据类型 === *)

(* 韵律数据条目 - 描述单个字符的韵律信息 *)
type rhyme_data_entry = {
  character : string;  (** 字符 *)
  category : rhyme_category;  (** 声韵类别 *)
  group : rhyme_group;  (** 韵组 *)
  variants : string list;  (** 异体字或相关字 *)
  usage_frequency : float;  (** 使用频度 *)
}

(* 韵律匹配结果 *)
type rhyme_match_result = {
  is_match : bool;  (** 是否匹配 *)
  match_quality : float;  (** 匹配质量 0.0-1.0 *)
  match_reason : string;  (** 匹配原因说明 *)
}

(* 单个字符的韵律分析结果 *)
type char_rhyme_info = {
  character : string;  (** 字符内容 *)
  rhyme_category : rhyme_category;  (** 声韵分类 *)
  rhyme_group : rhyme_group;  (** 所属韵组 *)
  confidence : float;  (** 分析置信度 0.0-1.0 *)
}

(* 诗句韵律分析报告 *)
type verse_rhyme_analysis = {
  verse_text : string;  (** 诗句原文 *)
  rhyme_ending : string option;  (** 韵脚字符 *)
  dominant_rhyme_group : rhyme_group;  (** 主要韵组 *)
  dominant_rhyme_category : rhyme_category;  (** 主要声韵类别 *)
  char_analysis : char_rhyme_info list;  (** 逐字韵律分析 *)
  rhyme_quality_score : float;  (** 韵律质量评分 *)
}

(* 整体诗篇韵律分析报告 *)
type poem_rhyme_analysis = {
  verses : string list;  (** 诗句列表 *)
  verse_analyses : verse_rhyme_analysis list;  (** 各句分析结果 *)
  overall_rhyme_groups : rhyme_group list;  (** 全诗使用的韵组 *)
  overall_rhyme_categories : rhyme_category list;  (** 全诗使用的声韵类别 *)
  rhyme_consistency_score : float;  (** 韵律一致性评分 *)
  artistic_quality_score : float;  (** 艺术质量评分 *)
  suggestions : string list;  (** 改进建议 *)
}

(* 韵律建议类型 *)
type rhyme_suggestion = {
  suggestion_type : string;  (** 建议类型 *)
  original_char : string;  (** 原字符 *)
  suggested_chars : string list;  (** 建议字符列表 *)
  reason : string;  (** 建议理由 *)
  improvement_score : float;  (** 改进分数 *)
}

(** === 艺术性评价类型 === *)

(* 艺术性评价维度 - 整合自artistic_types.ml *)
type artistic_dimension =
  | RhymeHarmony (* 韵律和谐 *)
  | TonalBalance (* 声调平衡 *)
  | Parallelism (* 对仗工整 *)
  | Imagery (* 意象深度 *)
  | Rhythm (* 节奏感 *)
  | Elegance (* 雅致程度 *)
  | ClassicalElegance (* 古典雅致 *)
  | ModernInnovation (* 现代创新 *)
  | CulturalDepth (* 文化深度 *)
  | EmotionalResonance (* 情感共鸣 *)
  | IntellectualDepth (* 理性深度 *)

(* 评价等级：依传统诗词品评标准 *)
type evaluation_grade =
  | Excellent (* 上品 - 意境高远，韵律和谐，可称佳作 *)
  | Good (* 中品 - 格律工整，音韵协调，颇具水准 *)
  | Fair (* 下品 - 基本合格，略有瑕疵，尚可改进 *)
  | Poor (* 不入流 - 格律错乱，音韵不谐，需重修 *)

(* 艺术性评价结果 *)
type artistic_evaluation_result = {
  overall_grade : evaluation_grade;
  dimension_scores : (artistic_dimension * float) list;
  detailed_feedback : string;
  suggestions : string list;
}

(* 艺术性报告类型 - 整合自artistic_types.ml *)
type artistic_report = {
  verse : string; (* 原诗句 *)
  rhyme_score : float; (* 韵律得分 *)
  tone_score : float; (* 声调得分 *)
  parallelism_score : float; (* 对仗得分 *)
  imagery_score : float; (* 意象得分 *)
  rhythm_score : float; (* 节奏得分 *)
  elegance_score : float; (* 雅致得分 *)
  overall_grade : evaluation_grade; (* 整体评级 *)
  detailed_feedback : string; (* 详细反馈 *)
  suggestions : string list; (* 改进建议 *)
}

(* 艺术性分数记录 - 整合自artistic_types.ml *)
type artistic_scores = {
  rhyme_harmony : float; (* 韵律和谐 0.0-1.0 *)
  tonal_balance : float; (* 声调平衡 0.0-1.0 *)
  parallelism : float; (* 对仗工整 0.0-1.0 *)
  imagery : float; (* 意象深度 0.0-1.0 *)
  rhythm : float; (* 节奏感 0.0-1.0 *)
  elegance : float; (* 雅致程度 0.0-1.0 *)
  overall : float; (* 综合得分 0.0-1.0 *)
}

(** === 诗词形式类型 === *)

type poem_form =
  | LuShi (* 律诗 - 八句成篇，格律严整 *)
  | JueShi (* 绝句 - 四句成篇，意境深远 *)
  | GuFengShi (* 古风诗 - 格律自由，古朴自然 *)
  | CiPai of string (* 词牌 - 依谱填词，音律优美 *)
  | FuTi (* 赋体 - 铺陈其事，华丽藻饰 *)

(* 诗词形式定义 - 支持多种经典诗词格式，整合自artistic_types.ml *)
type poetry_form =
  | SiYanPianTi (* 四言骈体 - 已支持 *)
  | WuYanLuShi (* 五言律诗 - 新增支持 *)
  | QiYanJueJu (* 七言绝句 - 新增支持 *)
  | CiPai of string (* 词牌格律 - 新增支持 *)
  | ModernPoetry (* 现代诗 - 新增支持 *)
  | SiYanParallelProse (* 四言排律 - 新增支持 *)

type meter_pattern =
  | PingZe_Pattern of bool list (* 平仄格律模式，true为平，false为仄 *)
  | Free_Verse (* 自由诗，不拘格律 *)

(** === 诗词标准和评价标准类型 === *)

(* 四言骈体艺术性评价标准 *)
type siyan_artistic_standards = {
  char_count : int; (* 字数标准：每句四字 *)
  tone_pattern : bool list; (* 声调模式：平仄相对 *)
  parallelism_required : bool; (* 是否要求对仗 *)
  rhythm_weight : float; (* 节奏权重 *)
}

(* 五言律诗艺术性评价标准 *)
type wuyan_lushi_standards = {
  line_count : int; (* 句数标准：八句 *)
  char_per_line : int; (* 每句字数：五字 *)
  rhyme_scheme : bool array; (* 韵脚模式：2-4-6-8句押韵 *)
  parallelism_required : bool array; (* 对仗要求：颔联、颈联对仗 *)
  tone_pattern : bool list list; (* 声调模式：平仄相对 *)
  rhythm_weight : float; (* 节奏权重 *)
}

(* 七言绝句艺术性评价标准 *)
type qiyan_jueju_standards = {
  line_count : int; (* 句数标准：四句 *)
  char_per_line : int; (* 每句字数：七字 *)
  rhyme_scheme : bool array; (* 韵脚模式：2-4句押韵 *)
  parallelism_required : bool array; (* 对仗要求：后两句对仗 *)
  tone_pattern : bool list list; (* 声调模式：平仄相对 *)
  rhythm_weight : float; (* 节奏权重 *)
}

(** === 分析查询类型 === *)

type analysis_depth =
  | Surface (* 表面分析 - 基础音韵匹配 *)
  | Moderate (* 中等分析 - 包含格律检查 *)
  | Deep (* 深度分析 - 全面艺术性评价 *)

type rhyme_query = { 
  text : string; 
  target_rhyme : string option; 
  analysis_depth : analysis_depth 
}

type artistic_query = {
  poem : poem_text;
  form : poem_form option;
  criteria : artistic_dimension list;
}

(** === 声调信息类型 === *)

(* 声调信息类型 - 整合自poetry_types_consolidated.ml *)
type tone_info = { 
  char : char; 
  tone : rhyme_category; 
  is_tonal_mismatch : bool 
}

(* 声调分析报告 *)
type tone_analysis_report = {
  verse : string;
  tone_pattern : bool list; (* true=平声, false=仄声 *)
  tone_infos : tone_info list;
  balance_score : float; (* 0.0-1.0，声调平衡程度 *)
  adherence_score : float; (* 0.0-1.0，格律遵循程度 *)
}

(** === 综合分析类型 === *)

(* 诗句综合摘要 *)
type verse_summary = {
  verse : string;
  rhyme_info : verse_rhyme_analysis;
  tone_info : tone_analysis_report;
  artistic_info : artistic_report;
}

(* 综合分析报告 *)
type comprehensive_analysis = {
  poem_text : string list;
  form : poetry_form;
  verse_summaries : verse_summary list;
  overall_rhyme : poem_rhyme_analysis;
  overall_artistic : artistic_scores;
  final_grade : evaluation_grade;
  critique : string;
}

(** === 结果和响应类型 === *)

type 'a analysis_result =
  | Success of 'a
  | Failure of string
  | Partial of 'a * string list (* 部分成功，带警告信息 *)

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

(** === 错误和异常类型 === *)

(* 韵律分析错误类型 *)
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

(** === 数据源和缓存类型 === *)

type data_source_type = 
  | JSON_File of string 
  | Memory_Cache 
  | External_API

type cache_policy =
  | No_Cache
  | LRU_Cache of int (* 最大缓存条目数 *)
  | TTL_Cache of int (* 生存时间，秒 *)

(** === 配置类型 === *)

type analysis_config = {
  strict_mode : bool; (* 严格模式，更严格的韵律要求 *)
  cache_policy : cache_policy;
  data_sources : data_source_type list;
  custom_rhyme_groups : (string * rhyme_group) list; (* 自定义韵组 *)
}

(** === 数据库类型 === *)

(* 韵律数据项 - 描述单个字符的韵律信息 *)
type rhyme_data_item = {
  character : string;  (* 字符 *)
  category : rhyme_category;  (* 声韵类别 *)
  group : rhyme_group;  (* 韵组 *)
  confidence : float;  (* 置信度 *)
}

(* 韵组数据结构 - 用于数据引擎 *)
type rhyme_group_data_engine = {
  group : rhyme_group;  (* 韵组 *)
  description : string;  (* 韵组描述 *)
  items : rhyme_data_item list;  (* 韵组包含的数据项 *)
}

(* 结构化韵律数据库 - 用于数据引擎 *)
type rhyme_database = {
  groups : rhyme_group_data_engine list;  (* 韵组列表 *)
  version : string;  (* 数据库版本 *)
  metadata : (string * string) list;  (* 元数据 *)
}

(* 韵律数据库类型 - 存储字符与韵律信息的关联列表 *)
type rhyme_database_simple = (string * rhyme_category * rhyme_group) list

(* 向后兼容别名 *)
type rhyme_database_legacy = rhyme_database_simple

(* JSON数据处理相关类型 - 整合自poetry_core_types.ml *)
type rhyme_group_data = { 
  category : string; 
  characters : string list 
}

type rhyme_data_file = {
  rhyme_groups : (string * rhyme_group_data) list;
  metadata : (string * string) list;
}

(* 兼容性类型 - 支持旧版API *)
type rhyme_analysis_report = {
  verse : string;
  rhyme_ending : char option;
  rhyme_group : rhyme_group;
  rhyme_category : rhyme_category;
  char_analysis : (char * rhyme_category * rhyme_group) list;
}

(** === 工具函数类型 === *)

(* 比较函数类型 *)
type 'a comparison_result = Equal | Greater | Less

(* 转换函数结果类型 *)
type 'a conversion_result = Converted of 'a | Conversion_Failed of string

(** === 类型转换和兼容性函数 === *)

(* 为了向后兼容，提供类型转换函数 *)
let string_of_rhyme_category = function
  | PingSheng -> "平声"
  | ZeSheng -> "仄声"
  | ShangSheng -> "上声"
  | QuSheng -> "去声"
  | RuSheng -> "入声"

let string_of_rhyme_group = function
  | AnRhyme -> "安韵"
  | SiRhyme -> "思韵"
  | TianRhyme -> "天韵"
  | WangRhyme -> "望韵"
  | QuRhyme -> "去韵"
  | YuRhyme -> "鱼韵"
  | HuaRhyme -> "花韵"
  | FengRhyme -> "风韵"
  | YueRhyme -> "月韵"
  | XueRhyme -> "雪韵"
  | JiangRhyme -> "江韵"
  | HuiRhyme -> "灰韵"
  | UnknownRhyme -> "未知"

let string_of_evaluation_grade = function
  | Excellent -> "上品"
  | Good -> "中品"
  | Fair -> "下品"
  | Poor -> "不入流"

(* 兼容函数别名，指向现有实现 *)
let rhyme_category_to_string = string_of_rhyme_category
let rhyme_group_to_string = string_of_rhyme_group

(* 字符串到类型的转换函数 *)
let string_to_rhyme_category s =
  match s with
  | "平声" | "PingSheng" | "ping" | "ping_sheng" -> Some PingSheng
  | "仄声" | "ZeSheng" | "ze" | "ze_sheng" -> Some ZeSheng
  | "上声" | "ShangSheng" | "shang" | "shang_sheng" -> Some ShangSheng
  | "去声" | "QuSheng" | "qu" | "qu_sheng" -> Some QuSheng
  | "入声" | "RuSheng" | "ru" | "ru_sheng" -> Some RuSheng
  | _ -> None

let string_to_rhyme_group s =
  match s with
  | "安韵" | "AnRhyme" | "an" | "an_rhyme" -> Some AnRhyme
  | "思韵" | "SiRhyme" | "si" | "si_rhyme" -> Some SiRhyme
  | "天韵" | "TianRhyme" | "tian" | "tian_rhyme" -> Some TianRhyme
  | "望韵" | "WangRhyme" | "wang" | "wang_rhyme" | "王韵" -> Some WangRhyme
  | "去韵" | "QuRhyme" | "qu" | "qu_rhyme" | "曲韵" -> Some QuRhyme
  | "鱼韵" | "YuRhyme" | "yu" | "yu_rhyme" | "雨韵" -> Some YuRhyme
  | "花韵" | "HuaRhyme" | "hua" | "hua_rhyme" -> Some HuaRhyme
  | "风韵" | "FengRhyme" | "feng" | "feng_rhyme" -> Some FengRhyme
  | "月韵" | "YueRhyme" | "yue" | "yue_rhyme" -> Some YueRhyme
  | "雪韵" | "XueRhyme" | "xue" | "xue_rhyme" -> Some XueRhyme
  | "江韵" | "JiangRhyme" | "jiang" | "jiang_rhyme" -> Some JiangRhyme
  | "灰韵" | "HuiRhyme" | "hui" | "hui_rhyme" | "辉韵" -> Some HuiRhyme
  | "未知" | "UnknownRhyme" | "unknown" -> Some UnknownRhyme
  | _ -> None

(* 比较函数 *)
let rhyme_category_equal c1 c2 = c1 = c2
let rhyme_group_equal g1 g2 = g1 = g2

(* 声韵判断函数 *)
let is_ping_sheng = function PingSheng -> true | _ -> false
let is_ze_sheng = function ZeSheng | ShangSheng | QuSheng | RuSheng -> true | PingSheng -> false

(* 艺术性维度转换为字符串 *)
let dimension_to_string = function
  | RhymeHarmony -> "韵律和谐"
  | TonalBalance -> "声调平衡"
  | Parallelism -> "对仗工整"
  | Imagery -> "意象深度"
  | Rhythm -> "节奏感"
  | Elegance -> "雅致程度"
  | ClassicalElegance -> "古典雅致"
  | ModernInnovation -> "现代创新"
  | CulturalDepth -> "文化深度"
  | EmotionalResonance -> "情感共鸣"
  | IntellectualDepth -> "理性深度"

(* 诗词形式转换为字符串 *)
let poetry_form_to_string = function
  | SiYanPianTi -> "四言骈体"
  | WuYanLuShi -> "五言律诗"
  | QiYanJueJu -> "七言绝句"
  | CiPai name -> Printf.sprintf "词牌(%s)" name
  | ModernPoetry -> "现代诗"
  | SiYanParallelProse -> "四言排律"