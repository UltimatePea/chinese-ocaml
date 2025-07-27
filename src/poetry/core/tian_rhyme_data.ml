(** 天韵组数据模块

    从 rhyme_core_data.ml 中提取的天韵组专用数据， 包含天韵组的平声字符数据。

    @author 骆言诗词编程团队
    @version 1.0 - 模块化重构版本
    @since 2025-07-27 *)

open Rhyme_core_types
open Rhyme_helpers

(** 天韵组平声字符数据 *)
let ping_sheng_chars =
  [
    "天";
    "年";
    "先";
    "田";
    "边";
    "前";
    "连";
    "千";
    "线";
    "坚";
    "全";
    "圆";
    "便";
    "面";
    "见";
    "片";
    "变";
    "点";
    "电";
    "店";
    "展";
    "县";
    "现";
    "显";
    "间";
    "建";
    "健";
    "件";
    "剑";
  ]

(** 天韵组平声数据条目 *)
let ping_sheng_data = make_group_entries PingSheng TianRhyme ping_sheng_chars

(** 天韵组所有数据 *)
let all_data = ping_sheng_data