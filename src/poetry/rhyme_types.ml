(* 音韵类型定义模块 - 骆言诗词编程特性
   盖古之诗者，音韵为要。声韵调谐，方称佳构。
   此模块专司音韵类型定义，为音韵分析提供基础类型。
   凡诗词编程，必先明类型，后成功能。
*)

(* 声韵分类：依古韵书分平仄入声 *)
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
  | UnknownRhyme (* 未知韵组 - 韵书未载，待考证者 *)

(* 韵律分析报告：详细记录诗句的音韵特征
   包含韵脚、韵组、韵类及逐字分析，为诗词创作提供全面指导。
*)
type rhyme_analysis_report = {
  verse : string;
  rhyme_ending : char option;
  rhyme_group : rhyme_group;
  rhyme_category : rhyme_category;
  char_analysis : (char * rhyme_category * rhyme_group) list;
}

(* 整体韵律分析报告类型 *)
type poem_rhyme_analysis = {
  verses : string list;
  verse_reports : rhyme_analysis_report list;
  rhyme_groups : rhyme_group list;
  rhyme_categories : rhyme_category list;
  rhyme_quality : float;
  rhyme_consistency : bool;
}

(* 类型转换和显示函数 *)

(* 韵类转字符串 *)
let rhyme_category_to_string = function
  | PingSheng -> "平声"
  | ZeSheng -> "仄声"
  | ShangSheng -> "上声"
  | QuSheng -> "去声"
  | RuSheng -> "入声"

(* 韵组转字符串 *)
let rhyme_group_to_string = function
  | AnRhyme -> "安韵"
  | SiRhyme -> "思韵"
  | TianRhyme -> "天韵"
  | WangRhyme -> "望韵"
  | QuRhyme -> "去韵"
  | UnknownRhyme -> "未知"

(* 韵类比较函数 *)
let rhyme_category_equal cat1 cat2 = cat1 = cat2

(* 韵组比较函数 *)
let rhyme_group_equal group1 group2 = group1 = group2

(* 判断是否为平声韵 *)
let is_ping_sheng = function
  | PingSheng -> true
  | _ -> false

(* 判断是否为仄声韵 *)
let is_ze_sheng = function
  | ZeSheng | ShangSheng | QuSheng | RuSheng -> true
  | _ -> false