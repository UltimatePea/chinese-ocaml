(** 江韵组数据模块

    从 rhyme_core_data.ml 中提取的江韵组专用数据， 包含江韵组的平声字符数据。

    @author 骆言诗词编程团队
    @version 1.0 - 模块化重构版本
    @since 2025-07-27 *)

open Rhyme_core_types
open Rhyme_helpers

(** 江韵组平声字符数据 *)
let ping_sheng_chars =
  [
    "江";
    "窗";
    "双";
    "霜";
    "装";
    "庄";
    "状";
    "撞";
    "创";
    "床";
    "伤";
    "商";
    "尚";
    "上";
    "常";
    "场";
    "厂";
    "长";
    "张";
    "章";
    "障";
    "掌";
    "藏";
    "仓";
    "苍";
    "沧";
  ]

(** 江韵组平声数据条目 *)
let ping_sheng_data = make_group_entries PingSheng JiangRhyme ping_sheng_chars

(** 江韵组所有数据 *)
let all_data = ping_sheng_data
