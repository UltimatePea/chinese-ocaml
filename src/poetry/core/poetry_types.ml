(** 骆言诗词核心类型定义模块 - 统一类型系统
    Author: Alpha, 主要工作代理 - 负责功能实现和技术债务处理
    
    古云：类者，分也。善分则理明，理明则功成。
    此模块统一诗词编程之基础类型，消除重复，明确边界。
    
    设计原则：
    1. 单一数据源 - 所有类型定义集中于此
    2. 层次清晰 - 从基础类型到复合类型
    3. 语义明确 - 每个类型有明确的业务含义
    4. 向后兼容 - 保持现有API的兼容性
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

(* 韵律匹配结果 *)
type rhyme_match_result =
  | Perfect_Match (* 完全韵合 - 声韵俱谐，如珠玉相击 *)
  | Good_Match (* 良好匹配 - 基本协调，略有不足 *)
  | Weak_Match (* 勉强匹配 - 勉强可用，但不理想 *)
  | No_Match (* 不匹配 - 韵不相协，不可同用 *)

(** === 艺术性评价类型 === *)

(* 艺术性评价维度 *)
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

(** === 诗词形式类型 === *)

type poem_form =
  | LuShi (* 律诗 - 八句成篇，格律严整 *)
  | JueShi (* 绝句 - 四句成篇，意境深远 *)
  | GuFengShi (* 古风诗 - 格律自由，古朴自然 *)
  | CiPai of string (* 词牌 - 依谱填词，音律优美 *)
  | FuTi (* 赋体 - 铺陈其事，华丽藻饰 *)

type meter_pattern =
  | PingZe_Pattern of bool list (* 平仄格律模式，true为平，false为仄 *)
  | Free_Verse (* 自由诗，不拘格律 *)

(** === 分析查询类型 === *)

type analysis_depth =
  | Surface (* 表面分析 - 基础音韵匹配 *)
  | Moderate (* 中等分析 - 包含格律检查 *)
  | Deep (* 深度分析 - 全面艺术性评价 *)

type rhyme_query = {
  text : string;
  target_rhyme : string option;
  analysis_depth : analysis_depth;
}

type artistic_query = {
  poem : poem_text;
  form : poem_form option;
  criteria : artistic_dimension list;
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

(** === 工具函数类型 === *)

(* 比较函数类型 *)
type 'a comparison_result = 
  | Equal 
  | Greater 
  | Less

(* 转换函数结果类型 *)
type 'a conversion_result = 
  | Converted of 'a
  | Conversion_Failed of string

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