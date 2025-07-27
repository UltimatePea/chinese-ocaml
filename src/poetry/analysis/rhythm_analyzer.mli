(** 统一韵律分析引擎接口 - Phase 2: Engine Layer Refactoring
    
    此模块提供Poetry系统的统一韵律分析功能，整合原先分散的韵律分析实现，
    基于Phase 1的统一类型系统和高性能数据引擎。
    
    技术债务修复：消除rhyme_analysis.ml, poetry_rhyme_engine.ml等重复实现
    
    @author Alpha, 主要开发代理 - Poetry模块重构团队
    @version 2.0 (Phase 2: 引擎层重构版)
    @since 2025-07-27
    @fix_issue #1501 *)

open Poetry_types.Rhyme_types

(** {1 韵律分析类型定义} *)

(** 韵律分析结果 *)
type rhythm_analysis_result = {
  character: string;                    (** 分析的字符 *)
  rhyme_info: rhyme_data_item option;   (** 韵律信息 *)
  category: rhyme_category option;      (** 韵类 *)
  group: rhyme_group option;           (** 韵组 *)
  is_rhyme_ending: bool;               (** 是否为韵脚 *)
}

(** 诗句韵律分析 *)
type verse_rhythm_analysis = {
  verse: string;                        (** 原诗句 *)
  characters: string list;              (** 字符列表 *)
  rhythm_results: rhythm_analysis_result list;  (** 每字分析结果 *)
  rhyme_pattern: rhyme_category list;   (** 韵律模式 *)
  rhyme_ending: string option;          (** 韵脚字符 *)
  rhyme_group_consistency: bool;        (** 韵组一致性 *)
}

(** 多句韵律分析 *)
type multi_verse_analysis = {
  verses: string list;                  (** 原诗句列表 *)
  verse_analyses: verse_rhythm_analysis list;  (** 各句分析结果 *)
  rhyme_scheme: rhyme_group option list; (** 整体韵式 *)
  consistency_score: float;             (** 韵律一致性评分 *)
  overall_quality: float;               (** 整体韵律质量 *)
}

(** 韵律匹配结果 *)
type rhyme_match_result = {
  char1: string;
  char2: string;
  matches: bool;
  match_type: [ `Same_group | `Same_category | `No_match ];
  confidence: float;
}

(** 分析引擎状态 - 不透明类型 *)
type analyzer_state

(** 分析引擎异常 *)
exception RhythmAnalyzerError of string

(** {1 引擎初始化与管理} *)

(** 初始化韵律分析引擎
    @return 初始化的分析引擎状态 *)
val initialize_analyzer : unit -> analyzer_state

(** 加载韵律数据库到分析引擎
    @param database 要加载的韵律数据库
    @param analyzer_state 当前分析引擎状态
    @return 更新后的分析引擎状态
    @raise RhythmAnalyzerError 当数据加载失败时 *)
val load_database_to_analyzer : rhyme_database -> analyzer_state -> analyzer_state

(** {1 单字符韵律分析} *)

(** 分析单个字符的韵律信息
    @param character 要分析的字符
    @param analyzer_state 分析引擎状态
    @return 韵律分析结果
    @raise RhythmAnalyzerError 当分析失败时 *)
val analyze_character : string -> analyzer_state -> rhythm_analysis_result

(** 批量分析字符
    @param characters 字符列表
    @param analyzer_state 分析引擎状态
    @return 韵律分析结果列表 *)
val batch_analyze_characters : string list -> analyzer_state -> rhythm_analysis_result list

(** {1 韵律匹配分析} *)

(** 检查两个字符的韵律匹配
    @param char1 第一个字符
    @param char2 第二个字符
    @param analyzer_state 分析引擎状态
    @return 韵律匹配结果
    @raise RhythmAnalyzerError 当匹配检查失败时 *)
val check_character_rhyme_match : string -> string -> analyzer_state -> rhyme_match_result

(** {1 诗句韵律分析} *)

(** 分析单句韵律
    @param verse 诗句字符串
    @param analyzer_state 分析引擎状态
    @return 诗句韵律分析结果 *)
val analyze_verse_rhythm : string -> analyzer_state -> verse_rhythm_analysis

(** {1 多句韵律分析} *)

(** 分析多句诗词的韵律
    @param verses 诗句列表
    @param analyzer_state 分析引擎状态
    @return 多句韵律分析结果 *)
val analyze_multi_verse_rhythm : string list -> analyzer_state -> multi_verse_analysis

(** {1 韵律建议与推荐} *)

(** 根据韵组推荐押韵字符
    @param group 韵组
    @param analyzer_state 分析引擎状态
    @return 推荐的押韵字符列表
    @raise RhythmAnalyzerError 当推荐失败时 *)
val suggest_rhyme_characters_for_group : rhyme_group -> analyzer_state -> string list

(** 根据给定字符推荐相似韵律字符
    @param character 基准字符
    @param analyzer_state 分析引擎状态
    @return 相似韵律字符列表
    @raise RhythmAnalyzerError 当推荐失败时 *)
val suggest_similar_characters : string -> analyzer_state -> string list

(** {1 性能监控和统计} *)

(** 获取分析器统计信息
    @param analyzer_state 分析引擎状态
    @return 统计信息键值对列表 *)
val get_analyzer_statistics : analyzer_state -> (string * string) list

(** 清理分析器缓存
    @param analyzer_state 分析引擎状态
    @return 清理缓存后的分析引擎状态 *)
val clear_analyzer_cache : analyzer_state -> analyzer_state

(** 验证分析器状态
    @param analyzer_state 分析引擎状态
    @return 分析器状态是否有效 *)
val validate_analyzer_state : analyzer_state -> bool

(** {1 工具函数} *)

(** 格式化韵律分析结果
    @param result 韵律分析结果
    @return 格式化的字符串表示 *)
val format_rhythm_analysis_result : rhythm_analysis_result -> string

(** 格式化诗句韵律分析
    @param analysis 诗句韵律分析
    @return 格式化的字符串表示 *)
val format_verse_analysis : verse_rhythm_analysis -> string

(** 格式化多句分析结果
    @param analysis 多句韵律分析
    @return 格式化的字符串表示 *)
val format_multi_verse_analysis : multi_verse_analysis -> string