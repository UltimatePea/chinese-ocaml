(** 骆言诗词韵律核心模块 - 整合版本

    此模块整合了原有20+个韵律相关模块的核心功能， 提供统一的韵律检测、分析、验证和评分接口。

    技术债务改进：将find_rhyme_info等核心函数从13+个模块中整合， 消除重复代码，提供统一的API接口。

    原模块映射：
    - rhyme_api_core.ml -> 核心API函数
    - rhyme_analysis.ml -> 分析函数
    - rhyme_detection.ml -> 检测函数
    - rhyme_validation.ml -> 验证函数
    - rhyme_scoring.ml -> 评分函数
    - rhyme_utils.ml -> 工具函数

    @author 骆言诗词编程团队
    @version 2.0 - 整合版本
    @since 2025-07-24 *)

open Poetry_types_consolidated

(** {1 核心韵律检测函数} *)

val find_rhyme_info : char -> (rhyme_category * rhyme_group) option
(** 从音韵数据库中查找字符的韵母信息
    
    这是最核心的韵律查询函数，原本分散在13+个模块中。
    现在提供统一实现，避免重复代码。
    
    @param char 待查询的汉字字符
    @return 韵类和韵组的选项类型，None表示未找到
    
    @example [find_rhyme_info '山'] 返回 [Some (PingSheng, AnRhyme)] *)

val find_rhyme_info_string : string -> (rhyme_category * rhyme_group) option
(** 字符串版本的韵律信息查询

    @param str 单个汉字的字符串形式
    @return 韵类和韵组的选项类型 *)

val detect_rhyme_category : char -> rhyme_category
(** 检测字符的韵类（平仄声调）

    @param char 待检测字符
    @return 韵类枚举值，未知字符返回PingSheng *)

val detect_rhyme_group : char -> rhyme_group
(** 检测字符的韵组

    @param char 待检测字符
    @return 韵组枚举值，未知字符返回UnknownRhyme *)

val chars_rhyme : char -> char -> bool
(** 检查两个字符是否押韵（同韵组）

    @param char1 第一个字符
    @param char2 第二个字符
    @return 押韵返回true，否则返回false *)

val strings_rhyme : string -> string -> bool
(** 检查两个字符串（单字）是否押韵（同韵组）

    @param str1 第一个字符串
    @param str2 第二个字符串
    @return 押韵返回true，否则返回false *)

val verses_rhyme : string -> string -> bool
(** 检查两个诗句是否押韵（韵脚相同韵组）

    @param verse1 第一句诗
    @param verse2 第二句诗
    @return 押韵返回true，否则返回false *)

(** {1 韵律模式分析函数} *)

val extract_rhyme_ending : string -> char option
(** 从诗句中提取韵脚字符

    @param verse 诗句字符串
    @return 韵脚字符的选项类型 *)

val analyze_rhyme_pattern : string -> (char * rhyme_category * rhyme_group) list
(** 分析诗句的完整韵律模式

    逐字分析诗句中每个字符的韵律信息

    @param verse 诗句字符串
    @return 字符与其韵律信息的列表 *)

val detect_rhyme_pattern : string list -> char list
(** 检测诗词的韵脚模式

    提取每句诗的韵脚，形成韵脚列表

    @param verses 诗句列表
    @return 韵脚字符列表 *)

(** {1 韵律验证函数} *)

val validate_rhyme_consistency : string list -> bool
(** 验证诗词的韵脚一致性

    检查所有韵脚是否属于同一韵组

    @param verses 诗句列表
    @return 一致返回true，否则返回false *)

val validate_rhyme_scheme : string list -> char list -> bool
(** 验证诗词是否符合特定韵律方案

    @param verses 诗句列表
    @param expected_pattern 期望的韵脚模式
    @return 符合返回true，否则返回false *)

val validate_specific_pattern : string list -> char list -> bool
(** 验证诗词是否符合特定韵律模式

    @param verses 诗句列表
    @param pattern 韵律模式
    @return 符合返回true，否则返回false *)

(** {1 韵律分析报告函数} *)

val generate_rhyme_report : string -> rhyme_analysis_report
(** 生成单句韵律分析报告

    @param verse 诗句字符串
    @return 详细的韵律分析报告 *)

val analyze_poem_rhyme : string list -> poem_rhyme_analysis
(** 分析整首诗词的韵律结构

    @param verses 诗句列表
    @return 完整的诗词韵律分析报告 *)

(** {1 韵律评分函数} *)

val evaluate_rhyme_quality : string list -> float
(** 评估韵律质量（0.0-1.0）

    @param verses 诗句列表
    @return 韵律质量评分 *)

val evaluate_rhyme_harmony : string list -> float
(** 评估韵律和谐度

    @param verses 诗句列表
    @return 和谐度评分 *)

val evaluate_rhyme_diversity : string list -> float
(** 评估韵律多样性

    @param verses 诗句列表
    @return 多样性评分 *)

val evaluate_rhyme_regularity : string list -> float
(** 评估韵律规整度

    @param verses 诗句列表
    @return 规整度评分 *)

(** {1 韵律工具函数} *)

val get_rhyme_characters : rhyme_group -> string list
(** 获取韵组包含的所有字符

    @param group 韵组
    @return 该韵组的字符列表 *)

val suggest_rhyme_characters : rhyme_group -> string list
(** 根据韵组建议用韵字符

    @param group 韵组
    @return 建议的韵字列表 *)

val find_rhyming_characters : char -> string list
(** 查找与给定字符押韵的所有字符

    @param char 基准字符
    @return 押韵字符列表 *)

val is_known_rhyme_char : char -> bool
(** 检查字符是否为已知韵字

    @param char 待检查字符
    @return 已知返回true，否则返回false *)

val get_rhyme_description : char -> string
(** 获取字符的韵律描述

    @param char 待描述字符
    @return 韵律描述字符串 *)

(** {1 高级分析函数} *)

type quick_diagnosis = {
  consistency : bool;
  quality_score : float;
  quality_grade : string;
  pattern_type : string option;
  diagnosis : string;
}
(** 快速诊断结果类型 *)

val quick_rhyme_diagnosis : string list -> quick_diagnosis
(** 快速韵律诊断

    提供快速的韵律问题诊断和评估

    @param verses 诗句列表
    @return 诊断结果 *)

val comprehensive_rhyme_analysis : string list -> comprehensive_analysis
(** 综合韵律分析

    结合韵律检测、验证、评分等功能提供全面分析

    @param verses 诗句列表
    @return 综合分析结果 *)

(** {1 韵律模式常量} *)

val common_patterns : (string * char list) list
(** 常见韵律模式定义

    包含五绝、七绝、律诗等常见格律诗的韵脚模式 *)

val identify_pattern_type : string list -> string option
(** 识别韵律模式类型

    根据韵脚模式自动识别诗词类型

    @param verses 诗句列表
    @return 诗词类型的选项类型 *)
