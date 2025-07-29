(** 音韵类型定义模块 - 兼容层

    此模块现为纯兼容层，重新导出Poetry_core.Rhyme_core_types的类型定义， 消除重复代码但保持向后兼容性。

    技术债务清理：将94行重复类型定义转换为兼容层重新导出

    Author: Alpha, 主要工作代理 - 技术债务清理
    @version 2.0 - 兼容层版本
    @since 2025-07-29 *)

(* 重新导出核心类型系统，保持100%向后兼容包括构造器 *)

(* 类型重新导出 - 包含所有构造器 *)
type rhyme_category = Poetry_core.Poetry_types.rhyme_category =
  | PingSheng
  | ZeSheng
  | ShangSheng
  | QuSheng
  | RuSheng

type rhyme_group = Poetry_core.Poetry_types.rhyme_group =
  | AnRhyme
  | SiRhyme
  | TianRhyme
  | WangRhyme
  | QuRhyme
  | YuRhyme
  | HuaRhyme
  | FengRhyme
  | YueRhyme
  | XueRhyme
  | JiangRhyme
  | HuiRhyme
  | UnknownRhyme

type rhyme_analysis_report = {
  verse : string;
  rhyme_ending : char option;
  rhyme_group : rhyme_group;
  rhyme_category : rhyme_category;
  char_analysis : (char * rhyme_category * rhyme_group) list;
}

(* 函数重新导出 - 保持向后兼容 *)
let rhyme_category_to_string = function
  | PingSheng -> "平声"
  | ZeSheng -> "仄声"
  | ShangSheng -> "上声"
  | QuSheng -> "去声"
  | RuSheng -> "入声"

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

let rhyme_category_equal cat1 cat2 = cat1 = cat2
let rhyme_group_equal group1 group2 = group1 = group2
let is_ping_sheng = function PingSheng -> true | _ -> false
let is_ze_sheng = function ZeSheng | ShangSheng | QuSheng | RuSheng -> true | _ -> false

(* 向后兼容的类型别名 *)
type poem_rhyme_analysis = {
  verses : string list;
  verse_reports : rhyme_analysis_report list;
  rhyme_groups : rhyme_group list;
  rhyme_categories : rhyme_category list;
  rhyme_quality : float;
  rhyme_consistency : bool;
}
