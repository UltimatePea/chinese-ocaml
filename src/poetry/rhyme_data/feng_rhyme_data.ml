(** 风韵组数据模块
    
    包含风韵组的所有韵字数据，分为平声和仄声两类。
    
    @author Alpha, 主要工作代理
    @version 1.0 - 韵组数据模块化重构
    @since 2025-07-30
    @rhyme_group FengRhyme *)

open Poetry_core.Rhyme_core_types
open Rhyme_data_core

(** 风韵组平声字列表 *)
let ping_sheng_chars =
  [
    "风";
    "东";
    "中";
    "空";
    "同";
    "通";
    "红";
    "公";
    "功";
    "工";
    "穷";
    "终";
    "冬";
    "龙";
    "虫";
    "融";
    "隆";
    "松";
    "钟";
    "宫";
  ]

(** 风韵组仄声字列表 *)
let ze_sheng_chars =
  [
    "动";
    "用";
    "重";
    "众";
    "种";
    "痛";
    "送";
    "统";
    "共";
    "控";
    "总";
    "聪";
    "充";
    "宋";
    "诵";
    "颂";
    "涌";
    "拥";
    "容";
    "纵";
  ]

(** 风韵组完整数据 *)
let feng_rhyme_data =
  create_rhyme_data FengRhyme "风韵组：风、东、中等韵字" ping_sheng_chars ze_sheng_chars