(** 鱼韵组数据模块

    从 rhyme_core_data.ml 中提取的鱼韵组专用数据， 包含鱼韵组的平声字符数据。

    @author 骆言诗词编程团队
    @version 1.0 - 模块化重构版本
    @since 2025-07-27 *)

open Rhyme_core_types
open Rhyme_helpers

(** 鱼韵组平声字符数据 *)
let ping_sheng_chars =
  [
    "鱼";
    "书";
    "居";
    "虚";
    "余";
    "舒";
    "初";
    "疏";
    "如";
    "须";
    "需";
    "渠";
    "驱";
    "区";
    "躯";
    "具";
    "拒";
    "据";
    "句";
    "剧";
    "举";
    "巨";
    "拘";
    "局";
    "竹";
    "祝";
    "族";
    "足";
    "促";
  ]

(** 鱼韵组平声数据条目 *)
let ping_sheng_data = make_group_entries PingSheng YuRhyme ping_sheng_chars

(** 鱼韵组所有数据 *)
let all_data = ping_sheng_data
