(** 音韵分析模块接口 - 骆言诗词编程特性

    盖古之诗者，音韵为要。声韵调谐，方称佳构。 此模块为音韵分析的主要协调模块，整合各子模块功能。 凡诗词编程，必先通音韵，后成文章。

    音韵分析包含以下核心功能：
    - 韵母分类：按平仄声调分类汉字音韵
    - 韵脚检测：识别诗句末尾的韵脚字符
    - 韵律验证：检查诗词的押韵一致性
    - 韵律分析：生成详细的韵律分析报告
    - 韵律评分：评估诗词的韵律质量

    @author 骆言诗词编程团队
    @version 2.0
    @since 2025-07-17 *)

open Rhyme_types

(** {1 韵母匹配函数} *)

val find_rhyme_info : char -> (rhyme_category * rhyme_group) option
(** 从音韵数据库中查找字符的韵母信息 *)

val detect_rhyme_category : char -> rhyme_category
(** 检测字符的韵母分类 *)

val detect_rhyme_category_by_string : string -> rhyme_category
(** 通过字符串检测韵母分类 *)

val detect_rhyme_group : char -> rhyme_group
(** 检测字符的韵组 *)

val chars_rhyme : char -> char -> bool
(** 检查两个字符是否押韵 *)

val suggest_rhyme_characters : rhyme_group -> string list
(** 建议韵脚字符：根据韵组提供用韵建议 *)


(** {1 韵律模式识别函数} *)

val extract_rhyme_ending : string -> char option
(** 提取韵脚：从字符串中提取韵脚字符 *)

val validate_rhyme_consistency : string list -> bool
(** 验证韵脚一致性：检查多句诗词的韵脚是否和谐 *)

val validate_rhyme_scheme : string list -> char list -> bool
(** 验证韵律方案：依传统诗词格律检验韵律 *)

val analyze_rhyme_pattern : string -> (char * rhyme_category * rhyme_group) list
(** 分析诗句的韵律信息：逐字分析，察其音韵 *)

(** 韵律分析报告类型 *)
(* 直接使用 Rhyme_types 中的类型定义 *)

val generate_rhyme_report : string -> Rhyme_types.rhyme_analysis_report
(** 生成韵律分析报告：为诗句提供全面的音韵分析 *)

(** 整体韵律分析报告类型 *)
(* 直接使用 Rhyme_types 中的类型定义 *)

val analyze_poem_rhyme : string list -> Rhyme_types.poem_rhyme_analysis
(** 分析诗词整体韵律：分析整首诗的韵律结构 *)

val suggest_rhyme_improvements : string -> rhyme_group -> string list
(** 韵律美化建议：为诗句提供音韵改进之建议 *)

val detect_rhyme_pattern : string list -> char list
(** 检测韵律模式：分析诗词的韵律结构模式 *)

val validate_specific_pattern : string list -> char list -> bool
(** 验证特定韵律模式：检查诗词是否符合特定韵律模式 *)

val common_patterns : (string * char list) list
(** 常见韵律模式定义 *)

val identify_pattern_type : string list -> string option
(** 识别韵律模式类型：根据检测到的韵律模式识别诗词类型 *)

(** {1 韵律评分函数} *)

val evaluate_rhyme_quality : string list -> float
(** 检测押韵质量：评估韵脚的和谐程度 *)

val evaluate_rhyme_diversity : string list -> float
(** 韵律丰富度评分：评估韵律的多样性 *)

val evaluate_rhyme_regularity : string list -> float
(** 韵律规整度评分：评估韵律的规整程度 *)

val evaluate_rhyme_harmony : string list -> float
(** 韵律协调度评分：评估韵律的协调程度 *)

val evaluate_rhyme_completeness : string list -> float
(** 韵律完整度评分：评估韵律的完整程度 *)

(** 韵律评分详细报告类型 *)
(* 直接使用 Rhyme_scoring 中的类型定义 *)

val generate_comprehensive_score : string list -> Rhyme_scoring.rhyme_score_report
(** 生成综合韵律评分报告：对诗词进行全面的韵律评估 *)

(** 评分等级定义 *)
(* 直接使用 Rhyme_scoring 中的类型定义 *)

val score_to_grade : float -> Rhyme_scoring.score_grade
(** 将评分转换为等级 *)

val grade_to_string : Rhyme_scoring.score_grade -> string
(** 等级转换为字符串 *)

val generate_improvement_suggestions : Rhyme_scoring.rhyme_score_report -> string list
(** 生成评分建议：根据评分结果提供改进建议 *)

val quick_quality_check : string list -> float * string
(** 快速韵律质量检查：提供快速的韵律质量评估 *)

val compare_rhyme_quality : string list -> string list -> int
(** 韵律质量比较：比较两组诗词的韵律质量 *)

(** {1 高级分析函数} *)

type comprehensive_analysis = {
  rhyme_analysis : Rhyme_types.poem_rhyme_analysis;
  score_report : Rhyme_scoring.rhyme_score_report;
  suggestions : string list;
  grade : Rhyme_scoring.score_grade;
  grade_description : string;
}
(** 综合分析结果类型 *)

val comprehensive_poem_analysis : string list -> comprehensive_analysis
(** 综合诗词分析：结合韵律分析和评分功能 *)

val smart_rhyme_suggestions : string list -> string list
(** 智能韵律建议：基于分析结果提供智能建议 *)

type quick_diagnosis = {
  consistency : bool;
  quality_score : float;
  quality_grade : string;
  pattern_type : string option;
  diagnosis : string;
}
(** 快速诊断结果类型 *)

val quick_rhyme_diagnosis : string list -> quick_diagnosis
(** 快速韵律诊断：提供快速的韵律问题诊断 *)

val optimize_rhyme_suggestions : string list -> float -> string list
(** 韵律优化建议：针对特定韵律问题提供优化建议 *)

type learning_guide = {
  basic_concepts : string list;
  verse_examples : string list;
  analysis_summary : comprehensive_analysis;
  learning_tips : string list;
}
(** 韵律学习指导结果类型 *)

val rhyme_learning_guide : string list -> learning_guide
(** 韵律学习辅助：为学习者提供韵律学习指导 *)
