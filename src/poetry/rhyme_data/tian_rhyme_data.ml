(** 天韵组数据模块
    
    包含天韵组的所有韵字数据，分为平声和仄声两类。
    
    @author Alpha, 主要工作代理
    @version 1.0 - 韵组数据模块化重构
    @since 2025-07-30
    @rhyme_group TianRhyme *)

open Poetry_core.Rhyme_core_types
open Rhyme_data_core

(** 天韵组平声字列表 *)
let ping_sheng_chars =
  [
    "天";
    "年";
    "先";
    "千";
    "前";
    "边";
    "连";
    "田";
    "眠";
    "绵";
    "然";
    "燃";
    "全";
    "川";
    "泉";
    "缘";
    "源";
    "园";
    "元";
    "圆";
  ]

(** 天韵组仄声字列表 *)
let ze_sheng_chars =
  [
    "典";
    "点";
    "电";
    "店";
    "面";
    "见";
    "现";
    "变";
    "练";
    "件";
    "片";
    "战";
    "站";
    "念";
    "线";
    "限";
    "善";
    "判";
    "显";
    "献";
  ]

(** 天韵组完整数据 *)
let tian_rhyme_data =
  create_rhyme_data TianRhyme "天韵组：天、年、先等韵字" ping_sheng_chars ze_sheng_chars