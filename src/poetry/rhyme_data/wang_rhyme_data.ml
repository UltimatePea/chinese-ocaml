(** 王韵组数据模块
    
    包含王韵组的所有韵字数据，分为平声和仄声两类。
    
    @author Alpha, 主要工作代理
    @version 1.0 - 韵组数据模块化重构
    @since 2025-07-30
    @rhyme_group WangRhyme *)

open Poetry_core.Rhyme_core_types
open Rhyme_data_core

(** 王韵组平声字列表 *)
let ping_sheng_chars =
  [
    "王";
    "章";
    "张";
    "长";
    "场";
    "房";
    "方";
    "香";
    "黄";
    "光";
    "当";
    "堂";
    "常";
    "望";
    "强";
    "良";
    "皇";
    "央";
    "扬";
    "阳";
  ]

(** 王韵组仄声字列表 *)
let ze_sheng_chars =
  [
    "上";
    "响";
    "向";
    "像";
    "想";
    "相";
    "状";
    "况";
    "望";
    "量";
    "样";
    "养";
    "忘";
    "放";
    "访";
    "房";
    "防";
    "仿";
    "妨";
    "芳";
  ]

(** 王韵组完整数据 *)
let wang_rhyme_data =
  create_rhyme_data WangRhyme "王韵组：王、章、张等韵字" ping_sheng_chars ze_sheng_chars