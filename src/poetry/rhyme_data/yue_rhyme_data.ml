(** 月韵组数据模块
    
    包含月韵组的所有韵字数据，分为平声和仄声两类。
    
    @author Alpha, 主要工作代理
    @version 1.0 - 韵组数据模块化重构
    @since 2025-07-30
    @rhyme_group YueRhyme *)

open Poetry_core.Rhyme_core_types
open Rhyme_data_core

(** 月韵组平声字列表 *)
let ping_sheng_chars =
  [
    "月";
    "越";
    "说";
    "雪";
    "节";
    "切";
    "热";
    "别";
    "铁";
    "烈";
    "血";
    "结";
    "裂";
    "折";
    "缺";
    "绝";
    "决";
    "穴";
    "列";
    "灭";
  ]

(** 月韵组仄声字列表 *)
let ze_sheng_chars =
  [
    "阅";
    "悦";
    "劣";
    "列";
    "灭";
    "绝";
    "决";
    "缺";
    "雪";
    "血";
    "热";
    "铁";
    "烈";
    "别";
    "切";
    "节";
    "折";
    "裂";
    "结";
    "穴";
  ]

(** 月韵组完整数据 *)
let yue_rhyme_data = create_rhyme_data YueRhyme "月韵组：月、越、说等韵字" ping_sheng_chars ze_sheng_chars
