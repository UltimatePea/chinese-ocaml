(* 诗词核心类型定义模块 - 骆言诗词编程特性 
   整合音韵类型与JSON数据类型，提供统一的类型基础
   
   古云：类者，分也。善分则理明，理明则功成。
   此模块统一诗词编程之基础类型，避免重复，明确边界。
*)

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

(* 韵律分析报告：详细记录诗句的音韵特征 *)
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

(* JSON数据处理相关类型 *)
type rhyme_group_data = { category : string; characters : string list }

type rhyme_data_file = {
  rhyme_groups : (string * rhyme_group_data) list;
  metadata : (string * string) list;
}

(* 异常定义 *)
exception Json_parse_error of string
exception Rhyme_data_not_found of string

(* 类型转换函数 *)

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
  | YuRhyme -> "鱼韵"
  | HuaRhyme -> "花韵"
  | FengRhyme -> "风韵"
  | YueRhyme -> "月韵"
  | XueRhyme -> "雪韵"
  | JiangRhyme -> "江韵"
  | HuiRhyme -> "灰韵"
  | UnknownRhyme -> "未知"

(* 字符串转韵类 - 支持中英文输入 *)
let string_to_rhyme_category = function
  | "平声" | "ping_sheng" -> PingSheng
  | "仄声" | "ze_sheng" -> ZeSheng
  | "上声" | "shang_sheng" -> ShangSheng
  | "去声" | "qu_sheng" -> QuSheng
  | "入声" | "ru_sheng" -> RuSheng
  | _ -> PingSheng (* 默认平声 *)

(* 字符串转韵组 - 支持中英文输入 *)
let string_to_rhyme_group = function
  | "安韵" | "an_rhyme" -> AnRhyme
  | "思韵" | "si_rhyme" -> SiRhyme
  | "天韵" | "tian_rhyme" -> TianRhyme
  | "望韵" | "wang_rhyme" | "王韵" -> WangRhyme
  | "去韵" | "qu_rhyme" | "曲韵" -> QuRhyme
  | "鱼韵" | "yu_rhyme" | "雨韵" -> YuRhyme
  | "花韵" | "hua_rhyme" -> HuaRhyme
  | "风韵" | "feng_rhyme" -> FengRhyme
  | "月韵" | "yue_rhyme" -> YueRhyme
  | "雪韵" | "xue_rhyme" -> XueRhyme
  | "江韵" | "jiang_rhyme" -> JiangRhyme
  | "灰韵" | "hui_rhyme" | "辉韵" -> HuiRhyme
  | _ -> UnknownRhyme

(* 比较函数 *)
let rhyme_category_equal cat1 cat2 = cat1 = cat2
let rhyme_group_equal group1 group2 = group1 = group2

(* 声韵判断函数 *)
let is_ping_sheng = function PingSheng -> true | _ -> false
let is_ze_sheng = function ZeSheng | ShangSheng | QuSheng | RuSheng -> true | _ -> false
