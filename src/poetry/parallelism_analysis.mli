(** 对仗分析模块接口 - 骆言诗词编程特性

    本模块提供了古典诗词编程中的对仗分析功能，包括词性分类、对仗质量评估、 律诗对仗验证等核心功能。支持传统诗词的对仗规则分析和对仗改进建议。 *)

open Poetry_data.Word_class_types
(** 词性分类类型

    词性类型定义已统一移至 Poetry_data.Word_class_types 模块。 *)

(** 对仗类型

    按传统诗词理论对对仗质量进行分类，从工对到无对共五个等级。 *)
type parallelism_type =
  | PerfectParallelism (* 工对 - 词性声律完全相对 *)
  | GoodParallelism (* 正对 - 词性相对声律和谐 *)
  | LooseParallelism (* 宽对 - 词性相近声律可容 *)
  | WeakParallelism (* 邻对 - 词性相邻声律不完全 *)
  | NoParallelism (* 无对 - 词性声律皆不相对 *)

(** 对仗位置类型

    标识对仗在诗词中的位置，包括首联、颔联、颈联、尾联等。 *)
type parallelism_position =
  | FirstCouplet (* 首联 *)
  | SecondCouplet (* 颔联 *)
  | ThirdCouplet (* 颈联 *)
  | LastCouplet (* 尾联 *)
  | MiddleCouplet (* 中联 *)

type parallelism_analysis_report = {
  line1 : string;
  line2 : string;
  parallelism_type : parallelism_type;
  word_class_pairs : (word_class * word_class) list;
  rhyme_pairs : (Rhyme_types.rhyme_category * Rhyme_types.rhyme_category) list;
  perfect_match_ratio : float;
  good_match_ratio : float;
  rhyme_match_ratio : float;
  overall_score : float;
}
(** 对仗分析报告类型

    包含两句诗的完整对仗分析信息，包括原诗句、对仗类型、词性对应、 声律对应、匹配率、总体评分等详细信息。 *)

val detect_word_class : char -> word_class
(** 检测字符的词性

    根据字符判断其在古典诗词中的词性分类。

    @param char 要检测的字符
    @return 字符的词性分类 *)

val detect_word_class_by_string : string -> word_class
(** 检测字符串的词性

    根据字符串判断其在古典诗词中的词性分类。

    @param string 要检测的字符串
    @return 字符串的词性分类 *)

val word_classes_match : word_class -> word_class -> parallelism_type -> bool
(** 检测词性相对性

    判断两个词性是否符合指定等级的对仗要求。

    @param word_class 第一个词性
    @param word_class 第二个词性
    @param parallelism_type 对仗等级要求
    @return 是否符合对仗要求 *)

val analyze_parallelism_quality : string -> string -> parallelism_type
(** 分析对仗质量

    评估两句诗的对仗程度，综合考虑词性对仗、声律对仗等因素。

    @param string 第一句诗
    @param string 第二句诗
    @return 对仗质量等级 *)

val generate_parallelism_report : string -> string -> parallelism_analysis_report
(** 生成对仗分析报告

    为两句诗生成详细的对仗分析报告，包含所有对仗信息。

    @param string 第一句诗
    @param string 第二句诗
    @return 对仗分析报告 *)

val validate_regulated_verse_parallelism :
  string list -> parallelism_analysis_report * parallelism_analysis_report * float
(** 检验律诗对仗

    检查律诗的对仗规则，验证颔联、颈联是否符合对仗要求。

    @param string list 律诗八句
    @return 颔联分析报告 * 颈联分析报告 * 总体质量评分 *)

val suggest_parallelism_improvements : parallelism_analysis_report -> string list
(** 建议对仗改进

    为不工整的对仗提供改进建议，分析问题并提供相应的建议。

    @param parallelism_analysis_report 对仗分析报告
    @return 改进建议列表 *)
