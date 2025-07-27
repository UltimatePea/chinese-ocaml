(** 去韵组数据模块

    从 rhyme_core_data.ml 中提取的去韵组专用数据， 包含去韵组的去声字符数据。

    @author 骆言诗词编程团队
    @version 1.0 - 模块化重构版本
    @since 2025-07-27 *)

open Rhyme_core_types
open Rhyme_helpers

(** 去韵组去声字符数据 *)
let qu_sheng_chars =
  [
    "去";
    "路";
    "度";
    "步";
    "暮";
    "树";
    "住";
    "注";
    "助";
    "数";
    "术";
    "述";
    "故";
    "固";
    "顾";
    "库";
    "苦";
    "户";
    "护";
    "误";
    "雾";
    "务";
    "物";
    "服";
    "复";
    "福";
    "富";
    "付";
    "父";
  ]

(** 去韵组去声数据条目 *)
let qu_sheng_data = make_group_entries QuSheng QuRhyme qu_sheng_chars

(** 去韵组所有数据 *)
let all_data = qu_sheng_data