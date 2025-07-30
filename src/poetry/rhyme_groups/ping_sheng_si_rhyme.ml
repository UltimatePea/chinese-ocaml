(** 思韵组数据模块 - 思、师、时等韵字
    
    此模块定义思韵组的所有数据，从unified_rhyme_groups_data.ml中提取
    并模块化。思韵组包含"思、师、时、词、丝"等常用韵字。
    
    @author Alpha, 主要工作代理
    @version 1.0 - 模块化重构版本
    @since 2025-07-30  
    @related_issue #1773 统一模块技术债务清理 *)

open Poetry_core.Types
open Rhyme_group_builder
open Rhyme_data_registry

(** {1 思韵组字符数据} *)

(** 思韵组平声字符 *)
let ping_sheng_chars =
  [
    "思";
    "师";
    "时";
    "词";
    "丝";
    "知";
    "之";
    "期";
    "其";
    "奇";
    "痴";
    "持";
    "池";
    "迟";
    "诗";
    "支";
    "枝";
    "儿";
    "而";
    "资";
  ]

(** 思韵组仄声字符 *)
let ze_sheng_chars =
  [
    "使";
    "史";
    "只";
    "止";
    "指";
    "趾";
    "市";
    "智";
    "志";
    "置";
    "治";
    "制";
    "至";
    "质";
    "致";
    "试";
    "事";
    "视";
    "示";
    "式";
  ]

(** {1 韵组配置和数据构建} *)

(** 思韵组配置 *)
let si_config =
  { group_type = SiRhyme; description = "思韵组：思、师、时等韵字"; ping_sheng_chars; ze_sheng_chars }

(** 思韵组数据 *)
let si_rhyme_data = build_from_config si_config

(** {1 模块初始化} *)

(** 自动注册到韵组注册表 *)
let () = register_rhyme_group si_rhyme_data
