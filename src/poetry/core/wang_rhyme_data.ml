(** 望韵组数据模块

    从 rhyme_core_data.ml 中提取的望韵组专用数据， 包含望韵组的仄声字符数据。

    @author 骆言诗词编程团队
    @version 1.0 - 模块化重构版本
    @since 2025-07-27 *)

open Rhyme_core_types
open Rhyme_helpers

(** 望韵组仄声字符数据 *)
let ze_sheng_chars =
  [
    "望";
    "放";
    "向";
    "响";
    "上";
    "长";
    "张";
    "方";
    "房";
    "光";
    "广";
    "想";
    "象";
    "像";
    "相";
    "香";
    "乡";
    "详";
    "享";
    "让";
    "养";
    "样";
    "量";
    "亮";
    "强";
    "墙";
    "王";
    "忘";
    "网";
  ]

(** 望韵组仄声数据条目 *)
let ze_sheng_data = make_group_entries ZeSheng WangRhyme ze_sheng_chars

(** 望韵组所有数据 *)
let all_data = ze_sheng_data
