(** 诗词韵律引擎 - 整合版本接口
 *
 * 此模块整合了原本分散在15个韵律相关模块中的功能，提供统一的韵律处理接口。
 *
 * 整合的原始模块包括：
 * - rhyme_analysis, rhyme_detection, rhyme_matching, rhyme_validation
 * - rhyme_database, rhyme_lookup, rhyme_scoring, rhyme_pattern
 * - rhyme_utils, rhyme_helpers, rhyme_json_* 系列模块
 *
 * @author 骆言编程团队 - 模块整合项目  
 * @version 2.0 (整合版本)
 * @since 2025-07-25
 * @issue #1155 诗词模块整合优化
 *)

open Rhyme_types

(** {1 核心类型定义} *)

type rhyme_analysis_result = {
  category : rhyme_category;  (** 韵类：平声、仄声等 *)
  group : rhyme_group;  (** 韵组：具体的韵部 *)
  confidence : float;  (** 置信度 0.0-1.0 *)
  alternatives : rhyme_group list;  (** 可能的备选韵组 *)
}
(** 韵律分析结果 *)

type rhyme_match_result = {
  is_match : bool;  (** 是否押韵 *)
  match_type : [ `Perfect | `Partial | `None ];  (** 匹配类型 *)
  similarity_score : float;  (** 相似度分数 0.0-1.0 *)
  explanation : string;  (** 匹配情况说明 *)
}
(** 韵律匹配结果 *)

type rhyme_pattern = {
  pattern_name : string;  (** 模式名称，如"五言绝句" *)
  required_groups : rhyme_group list;  (** 要求的韵组序列 *)
  allow_variations : bool;  (** 是否允许韵律变化 *)
}
(** 韵律模式定义 *)

(** {1 引擎管理功能} *)

val initialize_engine : unit -> unit
(** 初始化韵律引擎 * 加载韵律数据到内存缓存，建议在程序启动时调用 *)

val get_engine_stats : unit -> string
(** 获取引擎统计信息
 * @return 包含缓存状态和数据统计的字符串
 *)

val warm_up_engine : unit -> unit
(** 预热韵律引擎缓存 * 预加载常用字符，提升后续查询性能 *)

val cleanup_engine : unit -> unit
(** 清理引擎资源 * 清空缓存，释放内存 *)

(** {1 核心韵律分析功能} *)

val analyze_char_rhyme : string -> rhyme_analysis_result option
(** 分析单字符的韵律信息
 * 
 * 整合了原 rhyme_analysis.ml 和 rhyme_detection.ml 的功能
 * 
 * @param char 要分析的汉字字符
 * @return 韵律分析结果，未找到时返回None
 * @example analyze_char_rhyme "春" = Some {category=PingSheng; group=SiRhyme; ...}
 *)

val analyze_chars_rhyme : string list -> (string * rhyme_analysis_result option) list
(** 批量分析多字符韵律
 * 
 * 整合了原 rhyme_utils.ml 中的批量处理功能
 * 
 * @param chars 字符列表
 * @return 字符与分析结果的对应列表
 * @example analyze_chars_rhyme ["春"; "花"] = [("春", Some {...}); ("花", Some {...})]
 *)

(** {1 韵律匹配和验证功能} *)

val check_rhyme_match : string -> string -> rhyme_match_result
(** 检测两字符是否押韵
 * 
 * 整合了原 rhyme_matching.ml 和 rhyme_validation.ml 的功能
 * 
 * @param char1 第一个字符
 * @param char2 第二个字符  
 * @return 详细的韵律匹配结果
 * @example check_rhyme_match "春" "人" = {is_match=true; match_type=`Perfect; ...}
 *)

val validate_poem_rhyme : string list -> (int * rhyme_match_result) list
(** 验证诗句的韵律一致性
 * 
 * 整合了原 rhyme_pattern.ml 的功能
 * 
 * @param lines 诗句列表，每个字符串代表一行
 * @return 行索引与韵律匹配结果的对应列表
 * @example validate_poem_rhyme ["春眠不觉晓"; "处处闻啼鸟"] = [(0, {...})]
 *)

(** {1 韵律模式匹配功能} *)

val common_rhyme_patterns : rhyme_pattern list
(** 常用诗词韵律模式定义 * 包含五言绝句、七言律诗等常见格式的韵律要求 *)

val detect_rhyme_pattern : string list -> (rhyme_pattern * float) list
(** 检测诗词符合哪种韵律模式
 * 
 * 整合了原 rhyme_scoring.ml 的评分功能
 * 
 * @param lines 诗句列表
 * @return 韵律模式与匹配分数的对应列表，分数越高越匹配
 * @example detect_rhyme_pattern poem_lines = [(pattern1, 0.8); (pattern2, 0.3)]
 *)

(** {1 高级韵律功能} *)

val find_rhyming_chars : string -> string list
(** 查找与指定字符押韵的所有字符
 * 
 * 整合了原 rhyme_lookup.ml 和 rhyme_database.ml 的功能
 * 
 * @param char 参考字符
 * @return 与其押韵的字符列表
 * @example find_rhyming_chars "春" = ["人"; "真"; "因"; ...]
 *)

val suggest_rhyme_improvements : string list -> string list
(** 生成韵律改进建议
 * 
 * 整合了原 rhyme_helpers.ml 的辅助功能
 * 
 * @param lines 诗句列表
 * @return 改进建议列表
 * @example suggest_rhyme_improvements poem = ["第1行和第2行不押韵"; "建议调整韵脚"]
 *)

(** {1 向后兼容接口} *)

val detect_rhyme_info : string -> (rhyme_category * rhyme_group) option
(** 兼容原 rhyme_detection.ml 的 find_rhyme_info 函数
 * @deprecated 建议使用 analyze_char_rhyme 替代
 *)

val check_simple_rhyme : string -> string -> bool
(** 兼容原 rhyme_matching.ml 的 check_rhyme 函数  
 * @deprecated 建议使用 check_rhyme_match 替代
 *)

val get_rhyme_category : string -> rhyme_category
(** 兼容原 rhyme_analysis.ml 的 detect_category 函数
 * @deprecated 建议使用 analyze_char_rhyme 替代
 *)
