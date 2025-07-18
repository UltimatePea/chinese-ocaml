(** 音韵类型定义模块 - 骆言诗词编程特性

    盖古之诗者，音韵为要。声韵调谐，方称佳构。 此模块专司音韵类型定义，为音韵分析提供基础类型。 凡诗词编程，必先明类型，后成功能。

    @author 骆言诗词编程团队
    @version 1.0
    @since 2025-07-17 *)

(** {1 音韵分类类型} *)

(** 声韵分类：依古韵书分平仄入声

    音韵学中，汉字按声调分为平声、仄声等类别。 平声长而清，仄声短而促，各有其美。 *)
type rhyme_category =
  | PingSheng  (** 平声韵 - 音平而长，如天籁之响 *)
  | ZeSheng  (** 仄声韵 - 音仄而促，如金石之声 *)
  | ShangSheng  (** 上声韵 - 音上扬，如询问之态 *)
  | QuSheng  (** 去声韵 - 音下降，如叹息之音 *)
  | RuSheng  (** 入声韵 - 音促而急，如鼓点之节 *)

(** 韵组分类：按韵书传统分组，同组可押韵

    古代韵书将同韵的字归为一组，诗词创作中 同组字可以押韵，形成和谐的音韵效果。 *)
type rhyme_group =
  | AnRhyme  (** 安韵组 - 含山、间、闲等字，音韵和谐 *)
  | SiRhyme  (** 思韵组 - 含时、诗、知等字，情思绵绵 *)
  | TianRhyme  (** 天韵组 - 含年、先、田等字，天籁之音 *)
  | WangRhyme  (** 望韵组 - 含放、向、响等字，远望之意 *)
  | QuRhyme  (** 去韵组 - 含路、度、步等字，去声之韵 *)
  | UnknownRhyme  (** 未知韵组 - 韵书未载，待考证者 *)

(** {1 分析报告类型} *)

type rhyme_analysis_report = {
  verse : string;
  rhyme_ending : char option;
  rhyme_group : rhyme_group;
  rhyme_category : rhyme_category;
  char_analysis : (char * rhyme_category * rhyme_group) list;
}
(** 韵律分析报告：详细记录诗句的音韵特征

    包含韵脚、韵组、韵类及逐字分析，为诗词创作提供全面指导。

    @param verse 诗句内容
    @param rhyme_ending 韵脚字符（可选）
    @param rhyme_group 该句所属韵组
    @param rhyme_category 该句所属韵类
    @param char_analysis 逐字分析结果列表 *)

type poem_rhyme_analysis = {
  verses : string list;
  verse_reports : rhyme_analysis_report list;
  rhyme_groups : rhyme_group list;
  rhyme_categories : rhyme_category list;
  rhyme_quality : float;
  rhyme_consistency : bool;
}
(** 整体韵律分析报告类型

    对整首诗词进行综合分析的结果报告。

    @param verses 诗句列表
    @param verse_reports 各句分析报告
    @param rhyme_groups 使用的韵组列表
    @param rhyme_categories 使用的韵类列表
    @param rhyme_quality 韵律质量评分（0.0-1.0）
    @param rhyme_consistency 韵律一致性（true表示一致） *)

(** {1 类型转换函数} *)

val rhyme_category_to_string : rhyme_category -> string
(** 将韵类转换为中文字符串表示
    
    @param rhyme_category 韵类枚举值
    @return 对应的中文字符串
    
    @example [rhyme_category_to_string PingSheng] 返回 ["平声"]
*)

val rhyme_group_to_string : rhyme_group -> string
(** 将韵组转换为中文字符串表示
    
    @param rhyme_group 韵组枚举值
    @return 对应的中文字符串
    
    @example [rhyme_group_to_string AnRhyme] 返回 ["安韵"]
*)

(** {1 比较函数} *)

val rhyme_category_equal : rhyme_category -> rhyme_category -> bool
(** 比较两个韵类是否相等

    @param cat1 第一个韵类
    @param cat2 第二个韵类
    @return 相等则返回true，否则返回false *)

val rhyme_group_equal : rhyme_group -> rhyme_group -> bool
(** 比较两个韵组是否相等

    @param group1 第一个韵组
    @param group2 第二个韵组
    @return 相等则返回true，否则返回false *)

(** {1 判断函数} *)

val is_ping_sheng : rhyme_category -> bool
(** 判断是否为平声韵

    @param rhyme_category 待判断的韵类
    @return 是平声韵则返回true，否则返回false *)

val is_ze_sheng : rhyme_category -> bool
(** 判断是否为仄声韵

    仄声韵包括上声、去声、入声，与平声相对。

    @param rhyme_category 待判断的韵类
    @return 是仄声韵则返回true，否则返回false *)
