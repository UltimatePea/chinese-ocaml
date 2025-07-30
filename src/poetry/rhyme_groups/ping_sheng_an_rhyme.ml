(** 安韵组数据模块 - 山、关、间等韵字
    
    此模块定义安韵组的所有数据，从unified_rhyme_groups_data.ml中提取
    并模块化。安韵组包含"山、间、闲、关、还"等常用韵字。
    
    @author Alpha, 主要工作代理
    @version 1.0 - 模块化重构版本  
    @since 2025-07-30
    @related_issue #1773 统一模块技术债务清理 *)

open Poetry_core.Types
open Rhyme_group_builder
open Rhyme_data_registry

(** {1 安韵组字符数据} *)

(** 安韵组平声字符 *)
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

(** 安韵组仄声字符 *)
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

(** {1 韵组配置和数据构建} *)

(** 安韵组配置 *)
let an_config =
  { group_type = AnRhyme; description = "安韵组：山、关、间等韵字"; ping_sheng_chars; ze_sheng_chars }

(** 安韵组数据 *)
let an_rhyme_data = build_from_config an_config

(** {1 模块初始化} *)

(** 自动注册到韵组注册表 *)
let () = register_rhyme_group an_rhyme_data
