(** 曲韵组数据模块
    
    包含曲韵组的所有韵字数据，分为平声和仄声两类。
    
    @author Alpha, 主要工作代理
    @version 1.0 - 韵组数据模块化重构
    @since 2025-07-30
    @rhyme_group QuRhyme *)

open Poetry_core.Rhyme_core_types
open Rhyme_data_core

(** 曲韵组平声字列表 *)
let ping_sheng_chars =
  [ "曲"; "书"; "虚"; "如"; "除"; "无"; "吴"; "须"; "徐"; "胥"; "疏"; "图"; "途"; "都" ]

(** 曲韵组仄声字列表 *)
let ze_sheng_chars =
  [
    "去";
    "取";
    "住";
    "数";
    "度";
    "路";
    "故";
    "顾";
    "具";
    "句";
    "处";
    "据";
    "遇";
    "务";
    "树";
    "素";
    "注";
    "助";
    "著";
    "暑";
  ]

(** 曲韵组完整数据 *)
let qu_rhyme_data =
  create_rhyme_data QuRhyme "曲韵组：曲、书、虚等韵字" ping_sheng_chars ze_sheng_chars