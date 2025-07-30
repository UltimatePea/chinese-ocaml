(** 鱼韵组数据模块
    
    包含鱼韵组的所有韵字数据，分为平声和仄声两类。
    
    @author Alpha, 主要工作代理
    @version 1.0 - 韵组数据模块化重构
    @since 2025-07-30
    @rhyme_group YuRhyme *)

open Poetry_core.Rhyme_core_types
open Rhyme_data_core

(** 鱼韵组平声字列表 *)
let ping_sheng_chars = [ "鱼"; "余"; "居"; "初"; "渠"; "车" ]

(** 鱼韵组仄声字列表 *)
let ze_sheng_chars =
  [
    "语";
    "举";
    "女";
    "雨";
    "与";
    "许";
    "处";
    "虑";
    "数";
    "度";
    "路";
    "故";
    "顾";
    "具";
    "句";
    "据";
    "遇";
    "务";
    "树";
    "素";
  ]

(** 鱼韵组完整数据 *)
let yu_rhyme_data = create_rhyme_data YuRhyme "鱼韵组：鱼、书、余等韵字" ping_sheng_chars ze_sheng_chars
