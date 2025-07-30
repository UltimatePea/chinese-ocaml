(** 会韵组数据模块
    
    包含会韵组的所有韵字数据，分为平声和仄声两类。
    
    @author Alpha, 主要工作代理
    @version 1.0 - 韵组数据模块化重构
    @since 2025-07-30
    @rhyme_group HuiRhyme *)

open Poetry_core.Rhyme_core_types
open Rhyme_data_core

(** 会韵组平声字列表 *)
let ping_sheng_chars =
  [
    "会";
    "回";
    "来";
    "开";
    "台";
    "才";
    "材";
    "白";
    "百";
    "排";
    "败";
    "买";
    "卖";
    "海";
    "害";
    "爱";
    "在";
    "再";
    "外";
    "内";
  ]

(** 会韵组仄声字列表 *)
let ze_sheng_chars =
  [
    "对";
    "队";
    "背";
    "黑";
    "北";
    "倍";
    "配";
    "退";
    "推";
    "追";
    "催";
    "灰";
    "悔";
    "累";
    "类";
    "泪";
    "醉";
    "罪";
    "碎";
    "岁";
  ]

(** 会韵组完整数据 *)
let hui_rhyme_data =
  create_rhyme_data HuiRhyme "会韵组：会、回、来等韵字" ping_sheng_chars ze_sheng_chars