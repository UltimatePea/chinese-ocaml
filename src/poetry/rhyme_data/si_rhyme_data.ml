(** 思韵组数据模块
    
    包含思韵组的所有韵字数据，分为平声和仄声两类。
    
    @author Alpha, 主要工作代理
    @version 1.0 - 韵组数据模块化重构
    @since 2025-07-30
    @rhyme_group SiRhyme *)

open Poetry_core.Rhyme_core_types
open Rhyme_data_core

(** 思韵组平声字列表 *)
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

(** 思韵组仄声字列表 *)
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

(** 思韵组完整数据 *)
let si_rhyme_data = create_rhyme_data SiRhyme "思韵组：思、师、时等韵字" ping_sheng_chars ze_sheng_chars
