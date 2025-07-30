(** 天韵组数据模块 - 天、年、先等韵字
    
    此模块定义天韵组的所有数据，从unified_rhyme_groups_data.ml中提取
    并模块化。天韵组包含"天、年、先、千、前"等常用韵字。
    
    @author Alpha, 主要工作代理
    @version 1.0 - 模块化重构版本
    @since 2025-07-30
    @related_issue #1773 统一模块技术债务清理 *)

open Poetry_core.Types
open Rhyme_group_builder
open Rhyme_data_registry

(** {1 天韵组字符数据} *)

(** 天韵组平声字符 *)
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

(** 天韵组仄声字符 *)
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

(** {1 韵组配置和数据构建} *)

(** 天韵组配置 *)
let tian_config =
  { group_type = TianRhyme; description = "天韵组：天、年、先等韵字"; ping_sheng_chars; ze_sheng_chars }

(** 天韵组数据 *)
let tian_rhyme_data = build_from_config tian_config

(** {1 模块初始化} *)

(** 自动注册到韵组注册表 *)
let () = register_rhyme_group tian_rhyme_data
