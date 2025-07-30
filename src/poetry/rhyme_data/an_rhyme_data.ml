(** 安韵组数据模块
    
    包含安韵组的所有韵字数据，分为平声和仄声两类。
    
    @author Alpha, 主要工作代理
    @version 1.0 - 韵组数据模块化重构
    @since 2025-07-30
    @rhyme_group AnRhyme *)

open Poetry_core.Rhyme_core_types
open Rhyme_data_core

(** 安韵组平声字列表 *)
let ping_sheng_chars =
  [
    "山";
    "间";
    "闲";
    "关";
    "还";
    "班";
    "颜";
    "安";
    "删";
    "蛮";
    "环";
    "弯";
    "天";
    "千";
    "田";
    "先";
    "年";
    "连";
    "边";
    "全";
    "春";
  ]

(** 安韵组仄声字列表 *)
let ze_sheng_chars =
  [
    "产";
    "满";
    "简";
    "眼";
    "展";
    "面";
    "限";
    "善";
    "判";
    "管";
    "见";
    "变";
    "片";
    "现";
    "线";
    "显";
    "献";
    "念";
    "练";
    "遍";
  ]

(** 安韵组完整数据 *)
let an_rhyme_data = create_rhyme_data AnRhyme "安韵组：山、关、间等韵字" ping_sheng_chars ze_sheng_chars
