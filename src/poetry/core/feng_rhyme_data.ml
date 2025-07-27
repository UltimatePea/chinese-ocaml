(** 风韵组数据模块

    从 rhyme_core_data.ml 中提取的风韵组专用数据， 包含风韵组的平声字符数据。

    @author 骆言诗词编程团队
    @version 1.0 - 模块化重构版本
    @since 2025-07-27 *)

open Rhyme_core_types
open Rhyme_helpers

(** 风韵组平声字符数据 *)
let ping_sheng_chars =
  [
    "风";
    "中";
    "东";
    "冬";
    "终";
    "钟";
    "种";
    "重";
    "从";
    "丛";
    "聪";
    "葱";
    "空";
    "孔";
    "控";
    "恐";
    "松";
    "宋";
    "送";
    "诵";
    "颂";
    "动";
    "洞";
    "冻";
    "懂";
    "痛";
    "通";
    "同";
    "铜";
  ]

(** 风韵组平声数据条目 *)
let ping_sheng_data = make_group_entries PingSheng FengRhyme ping_sheng_chars

(** 风韵组所有数据 *)
let all_data = ping_sheng_data