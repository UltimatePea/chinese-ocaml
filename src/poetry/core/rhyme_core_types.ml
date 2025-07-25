(** 韵律核心类型定义模块 - 骆言诗词编程特性
    
    盖古之诗者，音韵为要。声韵调谐，方称佳构。
    此模块统一定义所有音韵类型，为整个诗词系统提供基础类型支撑。
    消除项目中30+文件的类型重复定义问题。
    
    重构目标：
    - 统一所有韵律相关类型定义
    - 消除rhyme_types.ml、poetry_types_consolidated.ml等文件的重复
    - 为整个诗词模块提供单一权威类型源
    
    @author 骆言诗词编程团队  
    @version 3.0 - 核心重构版本
    @since 2025-07-25 *)

(** {1 基础音韵类型} *)

(** 声韵分类：依古韵书分平仄入声 
    承袭《广韵》、《集韵》等韵书传统分类法 *)
type rhyme_category =
  | PingSheng   (** 平声韵 - 音平而长，如天籁之响 *)
  | ZeSheng     (** 仄声韵 - 音仄而促，如金石之声 *)  
  | ShangSheng  (** 上声韵 - 音上扬，如询问之态 *)
  | QuSheng     (** 去声韵 - 音下降，如叹息之音 *)
  | RuSheng     (** 入声韵 - 音促而急，如鼓点之节 *)

(** 韵组分类：按韵书传统分组，同组字可相押
    基于古代韵书的韵组划分，包含常用诗词韵组 *)
type rhyme_group =
  (* 传统经典韵组 *)
  | AnRhyme     (** 安韵组 - 含山、间、闲等字，音韵和谐 *)
  | SiRhyme     (** 思韵组 - 含时、诗、知等字，情思绵绵 *)
  | TianRhyme   (** 天韵组 - 含年、先、田等字，天籁之音 *)
  | WangRhyme   (** 望韵组 - 含放、向、响等字，远望之意 *)
  | QuRhyme     (** 去韵组 - 含路、度、步等字，去声之韵 *)
  
  (* 扩展韵组 - Phase 1 Enhancement *)
  | YuRhyme     (** 鱼韵组 - 含鱼、书、居等字，渔樵江渚 *)
  | HuaRhyme    (** 花韵组 - 含花、霞、家等字，春花秋月 *)
  | FengRhyme   (** 风韵组 - 含风、送、中等字，秋风萧瑟 *)
  | YueRhyme    (** 月韵组 - 含月、雪、节等字，秋月如霜 *)
  | JiangRhyme  (** 江韵组 - 含江、窗、双等字，大江东去 *)
  | HuiRhyme    (** 灰韵组 - 含灰、回、推等字，灰飞烟灭 *)
  | UnknownRhyme (** 未知韵组 - 韵书未载，待考证者 *)

(** {2 分析报告类型} *)

(** 单个字符的韵律分析结果 *)
type char_rhyme_info = {
  character : string;              (** 字符内容 *)
  rhyme_category : rhyme_category; (** 声韵分类 *)  
  rhyme_group : rhyme_group;       (** 所属韵组 *)
  confidence : float;              (** 分析置信度 0.0-1.0 *)
}

(** 诗句韵律分析报告：详细记录诗句的音韵特征
    包含韵脚、韵组、韵类及逐字分析，为诗词创作提供全面指导 *)
type verse_rhyme_analysis = {
  verse_text : string;                    (** 诗句原文 *)
  rhyme_ending : string option;           (** 韵脚字符 *)
  dominant_rhyme_group : rhyme_group;     (** 主要韵组 *)
  dominant_rhyme_category : rhyme_category; (** 主要声韵类别 *)
  char_analysis : char_rhyme_info list;   (** 逐字韵律分析 *)
  rhyme_quality_score : float;            (** 韵律质量评分 *)
}

(** 整体诗篇韵律分析报告 *)
type poem_rhyme_analysis = {
  verses : string list;                      (** 诗句列表 *)
  verse_analyses : verse_rhyme_analysis list; (** 各句分析结果 *)
  overall_rhyme_groups : rhyme_group list;   (** 全诗使用的韵组 *)
  overall_rhyme_categories : rhyme_category list; (** 全诗使用的声韵类别 *)
  rhyme_consistency_score : float;           (** 韵律一致性评分 *)
  artistic_quality_score : float;            (** 艺术质量评分 *)
  suggestions : string list;                 (** 改进建议 *)
}

(** {3 数据结构类型} *)

(** 韵律数据条目：基础数据单元 *)
type rhyme_data_entry = {
  character : string;              (** 字符 *)
  category : rhyme_category;       (** 声韵类别 *)
  group : rhyme_group;            (** 韵组 *)
  variants : string list;          (** 异体字或相关字 *)
  usage_frequency : float;         (** 使用频度 *)
}

(** 韵组数据：某个韵组的完整信息 *)
type rhyme_group_data = {
  group_name : rhyme_group;        (** 韵组名称 *)
  group_description : string;      (** 韵组描述 *)
  entries : rhyme_data_entry list; (** 该韵组所有条目 *)
  example_poems : string list;     (** 典型用例诗句 *)
}

(** {4 配置和选项类型} *)

(** 韵律分析配置 *)
type analysis_config = {
  strict_mode : bool;              (** 严格模式：严格按古韵书分析 *)
  modern_adaptation : bool;        (** 现代适应：适应现代读音 *)
  confidence_threshold : float;    (** 置信度阈值 *)
  enable_suggestions : bool;       (** 启用改进建议 *)
}

(** 数据加载配置 *)  
type data_config = {
  data_sources : string list;      (** 数据源文件路径 *)
  cache_enabled : bool;           (** 启用缓存 *)
  cache_size_limit : int;         (** 缓存大小限制 *)
  auto_reload : bool;             (** 自动重新加载 *)
}

(** {5 错误和异常类型} *)

(** 韵律分析错误类型 *)
type rhyme_error =
  | CharacterNotFound of string    (** 字符未在韵书中找到 *)
  | InvalidRhymeGroup of string   (** 无效韵组 *)
  | DataCorruption of string      (** 数据损坏 *)
  | ConfigurationError of string  (** 配置错误 *)
  | AnalysisFailure of string     (** 分析失败 *)

(** 韵律异常 *)
exception RhymeException of rhyme_error

(** {6 辅助类型定义} *)

(** 韵律匹配结果 *)
type rhyme_match_result = {
  is_match : bool;                (** 是否匹配 *)
  match_quality : float;          (** 匹配质量 0.0-1.0 *)
  match_reason : string;          (** 匹配原因说明 *)
}

(** 韵律建议类型 *)
type rhyme_suggestion = {
  suggestion_type : string;       (** 建议类型 *)
  original_char : string;         (** 原字符 *)
  suggested_chars : string list;  (** 建议字符列表 *)
  reason : string;               (** 建议理由 *)
  improvement_score : float;      (** 改进分数 *)
}

(** {7 JSON兼容类型} *)

(** JSON序列化配置 *)
type json_config = {
  pretty_print : bool;            (** 美化输出 *)
  include_metadata : bool;        (** 包含元数据 *)
  compression_level : int;        (** 压缩级别 *)
}

(** 导出用于JSON的简化类型 *)
type simple_rhyme_info = {
  char : string;
  category : string; 
  group : string;
}