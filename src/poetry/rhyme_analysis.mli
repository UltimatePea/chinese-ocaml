(** 音韵分析模块接口 - 骆言诗词编程特性

    本模块提供了古典诗词编程中的音韵分析功能，包括韵母分类、韵组检测、
    韵脚验证等核心功能。支持传统诗词的音韵规则分析和韵律美化建议。
 *)

(** 韵母分类类型

    根据传统诗词理论，将字符的韵母分为平声、仄声、上声、去声、入声五类。
    这些分类用于判断字符的音韵特征，是古典诗词格律分析的基础。
 *)
type rhyme_category =
  | PingSheng (* 平声韵 *)
  | ZeSheng (* 仄声韵 *)
  | ShangSheng (* 上声韵 *)
  | QuSheng (* 去声韵 *)
  | RuSheng (* 入声韵 *)

(** 韵组类型

    将字符按照韵母特征分组，包括常见的安韵组、思韵组、天韵组、望韵组、
    去韵组等。韵组用于判断字符是否押韵，是诗词韵律分析的重要依据。
 *)
type rhyme_group =
  | AnRhyme (* 安韵组 *)
  | SiRhyme (* 思韵组 *)
  | TianRhyme (* 天韵组 *)
  | WangRhyme (* 望韵组 *)
  | QuRhyme (* 去韵组 *)
  | UnknownRhyme (* 未知韵组 *)

(** 韵律分析报告类型

    包含单个诗句的完整韵律分析信息，包括原诗句、韵脚字符、韵组分类、
    韵母分类以及每个字符的详细分析结果。
 *)
type rhyme_analysis_report = {
  verse : string;
  rhyme_ending : char option;
  rhyme_group : rhyme_group;
  rhyme_category : rhyme_category;
  char_analysis : (char * rhyme_category * rhyme_group) list;
}

(** 整体韵律分析报告类型

    包含整首诗词的完整韵律分析信息，包括各句分析报告、韵组分布、
    韵母分类、韵律质量评分等综合信息。
*)
type poem_rhyme_analysis = {
  verses : string list;
  verse_reports : rhyme_analysis_report list;
  rhyme_groups : rhyme_group list;
  rhyme_categories : rhyme_category list;
  rhyme_quality : float;
  rhyme_consistency : bool;
}

(** 检测字符的韵母分类

    @param char 要检测的字符
    @return 字符的韵母分类（平声、仄声、上声、去声、入声）
 *)
val detect_rhyme_category : char -> rhyme_category

(** 检测UTF-8字符串的韵母分类
    
    根据传统诗词理论，检测UTF-8字符串的韵母分类。
    
    @param string UTF-8字符串
    @return 韵母分类
 *)
val detect_rhyme_category_by_string : string -> rhyme_category

(** 检测字符的韵组

    @param char 要检测的字符
    @return 字符所属的韵组
 *)
val detect_rhyme_group : char -> rhyme_group

(** 从字符串中提取韵脚字符

    从诗句字符串中提取用于押韵的字符，通常是句末的字符。

    @param string 诗句字符串
    @return 韵脚字符（如果存在）
 *)
val extract_rhyme_ending : string -> char option

(** 验证韵脚一致性

    检查多个诗句的韵脚是否一致，用于验证诗词的韵律规则。

    @param string list 诗句列表
    @return 韵脚是否一致
 *)
val validate_rhyme_consistency : string list -> bool

(** 验证韵律方案

    根据指定的韵律方案验证诗句列表的韵律是否符合规则。

    @param string list 诗句列表
    @param char list 韵律方案
    @return 是否符合韵律方案
 *)
val validate_rhyme_scheme : string list -> char list -> bool

(** 分析诗句的韵律信息

    对单个诗句进行完整的韵律分析，返回每个字符的韵律特征。

    @param string 诗句字符串
    @return 字符韵律信息列表（字符、韵母分类、韵组）
 *)
val analyze_rhyme_pattern : string -> (char * rhyme_category * rhyme_group) list

(** 建议韵脚字符

    根据指定的韵组，建议可用的韵脚字符列表。

    @param rhyme_group 韵组类型
    @return 建议的韵脚字符列表
 *)
val suggest_rhyme_characters : rhyme_group -> string list

(** 检查两个字符是否押韵

    判断两个字符是否属于同一韵组，可以用于押韵。

    @param char 第一个字符
    @param char 第二个字符
    @return 是否押韵
 *)
val chars_rhyme : char -> char -> bool

(** 生成韵律分析报告

    为单个诗句生成完整的韵律分析报告，包含所有韵律信息。

    @param string 诗句字符串
    @return 韵律分析报告
 *)
val generate_rhyme_report : string -> rhyme_analysis_report

(** 韵律美化建议

    根据诗句的韵律特征和目标韵组，提供韵律美化的建议。

    @param string 诗句字符串
    @param rhyme_group 目标韵组
    @return 美化建议列表
 *)
val suggest_rhyme_improvements : string -> rhyme_group -> string list

(** 检测押韵质量

    评估诗句列表的韵脚和谐程度，返回质量评分。

    @param string list 诗句列表
    @return 押韵质量评分（0.0-1.0）
*)
val evaluate_rhyme_quality : string list -> float

(** 分析诗词整体韵律

    对整首诗词进行完整的韵律分析，包括各句分析报告、韵组分布、
    韵母分类、韵律质量评分等综合信息。

    @param string list 诗句列表
    @return 整体韵律分析报告
*)
val analyze_poem_rhyme : string list -> poem_rhyme_analysis
