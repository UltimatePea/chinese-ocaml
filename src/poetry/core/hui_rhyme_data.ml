(** 灰韵组数据模块

    从 rhyme_core_data.ml 中提取的灰韵组专用数据， 包含灰韵组的仄声字符数据。

    @author 骆言诗词编程团队
    @version 1.0 - 模块化重构版本
    @since 2025-07-27 *)

open Rhyme_core_types
open Rhyme_helpers

(** 灰韵组仄声字符数据 *)
let ze_sheng_chars =
  [
    "灰";
    "回";
    "推";
    "退";
    "追";
    "坠";
    "醉";
    "碎";
    "岁";
    "税";
    "睡";
    "水";
    "谁";
    "虽";
    "随";
    "隋";
    "髓";
    "遂";
    "祟";
    "崇";
    "从";
    "匆";
    "聪";
    "葱";
    "囱";
    "冲";
    "充";
    "虫";
    "崇";
  ]

(** 灰韵组仄声数据条目 *)
let ze_sheng_data = make_group_entries ZeSheng HuiRhyme ze_sheng_chars

(** 灰韵组所有数据 *)
let all_data = ze_sheng_data