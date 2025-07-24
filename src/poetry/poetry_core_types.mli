(** 诗词核心类型定义模块 - 统一类型基础 
    
    整合原有的 rhyme_types 和 rhyme_json_types 模块，
    提供统一的类型定义和转换函数，避免重复定义。
    
    @author 骆言诗词编程团队
    @version 2.0 - 技术债务整理Phase 6
    @since 2025-07-24
*)

(** {1 基础音韵类型} *)

(** 声韵分类：依古韵书分平仄入声 *)
type rhyme_category =
  | PingSheng  (** 平声韵 - 音平而长，如天籁之响 *)
  | ZeSheng  (** 仄声韵 - 音仄而促，如金石之声 *)
  | ShangSheng  (** 上声韵 - 音上扬，如询问之态 *)
  | QuSheng  (** 去声韵 - 音下降，如叹息之音 *)
  | RuSheng  (** 入声韵 - 音促而急，如鼓点之节 *)

(** 韵组分类：按韵书传统分组，同组可押韵 *)
type rhyme_group =
  | AnRhyme  (** 安韵组 - 含山、间、闲等字，音韵和谐 *)
  | SiRhyme  (** 思韵组 - 含时、诗、知等字，情思绵绵 *)
  | TianRhyme  (** 天韵组 - 含年、先、田等字，天籁之音 *)
  | WangRhyme  (** 望韵组 - 含放、向、响等字，远望之意 *)
  | QuRhyme  (** 去韵组 - 含路、度、步等字，去声之韵 *)
  | YuRhyme  (** 鱼韵组 - 含鱼、书、居等字，渔樵江渚 *)
  | HuaRhyme  (** 花韵组 - 含花、霞、家等字，春花秋月 *)
  | FengRhyme  (** 风韵组 - 含风、送、中等字，秋风萧瑟 *)
  | YueRhyme  (** 月韵组 - 含月、雪、节等字，秋月如霜 *)
  | XueRhyme  (** 雪韵组 - 扩展雪字韵组 *)
  | JiangRhyme  (** 江韵组 - 含江、窗、双等字，大江东去 *)
  | HuiRhyme  (** 灰韵组 - 含灰、回、推等字，灰飞烟灭 *)
  | UnknownRhyme  (** 未知韵组 - 韵书未载，待考证者 *)

(** {1 分析报告类型} *)

(** 韵律分析报告：详细记录诗句的音韵特征 *)
type rhyme_analysis_report = {
  verse : string;  (** 诗句内容 *)
  rhyme_ending : char option;  (** 韵脚字符 *)
  rhyme_group : rhyme_group;  (** 韵组分类 *)
  rhyme_category : rhyme_category;  (** 韵类分类 *)
  char_analysis : (char * rhyme_category * rhyme_group) list;  (** 逐字分析 *)
}

(** 整体韵律分析报告类型 *)
type poem_rhyme_analysis = {
  verses : string list;  (** 诗句列表 *)
  verse_reports : rhyme_analysis_report list;  (** 各句分析报告 *)
  rhyme_groups : rhyme_group list;  (** 使用的韵组 *)
  rhyme_categories : rhyme_category list;  (** 使用的韵类 *)
  rhyme_quality : float;  (** 韵律质量分数 *)
  rhyme_consistency : bool;  (** 韵律一致性 *)
}

(** {1 JSON数据处理类型} *)

(** 韵组数据类型 *)
type rhyme_group_data = {
  category : string;  (** 韵类名称 *)
  characters : string list;  (** 该韵组包含的字符列表 *)
}

(** 韵律数据文件结构 *)
type rhyme_data_file = {
  rhyme_groups : (string * rhyme_group_data) list;  (** 韵组映射 *)
  metadata : (string * string) list;  (** 元数据信息 *)
}

(** {1 异常定义} *)

exception Json_parse_error of string
(** JSON解析错误异常 *)

exception Rhyme_data_not_found of string
(** 韵律数据未找到异常 *)

(** {1 类型转换函数} *)

val rhyme_category_to_string : rhyme_category -> string
(** 韵类转字符串 *)

val rhyme_group_to_string : rhyme_group -> string
(** 韵组转字符串 *)

val string_to_rhyme_category : string -> rhyme_category
(** 字符串转韵类，支持中英文输入 *)

val string_to_rhyme_group : string -> rhyme_group
(** 字符串转韵组，支持中英文输入 *)

(** {1 比较函数} *)

val rhyme_category_equal : rhyme_category -> rhyme_category -> bool
(** 韵类比较函数 *)

val rhyme_group_equal : rhyme_group -> rhyme_group -> bool
(** 韵组比较函数 *)

(** {1 声韵判断函数} *)

val is_ping_sheng : rhyme_category -> bool
(** 判断是否为平声韵 *)

val is_ze_sheng : rhyme_category -> bool
(** 判断是否为仄声韵 *)