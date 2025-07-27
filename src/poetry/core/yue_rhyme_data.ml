(** 月韵组数据模块

    从 rhyme_core_data.ml 中提取的月韵组专用数据， 包含月韵组的仄声字符数据。

    @author 骆言诗词编程团队
    @version 1.0 - 模块化重构版本
    @since 2025-07-27 *)

open Rhyme_core_types
open Rhyme_helpers

(** 月韵组仄声字符数据 *)
let ze_sheng_chars =
  [
    "月";
    "雪";
    "节";
    "热";
    "切";
    "设";
    "说";
    "决";
    "绝";
    "血";
    "铁";
    "别";
    "列";
    "烈";
    "裂";
    "灭";
    "结";
    "解";
    "界";
    "借";
    "街";
    "接";
    "皆";
    "阶";
    "揭";
    "竭";
    "截";
    "洁";
    "杰";
  ]

(** 月韵组仄声数据条目 *)
let ze_sheng_data = make_group_entries ZeSheng YueRhyme ze_sheng_chars

(** 月韵组所有数据 *)
let all_data = ze_sheng_data
