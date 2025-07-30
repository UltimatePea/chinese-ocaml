(** 江韵组数据模块
    
    包含江韵组的所有韵字数据，分为平声和仄声两类。
    
    @author Alpha, 主要工作代理
    @version 1.0 - 韵组数据模块化重构
    @since 2025-07-30
    @rhyme_group JiangRhyme *)

open Poetry_core.Rhyme_core_types
open Rhyme_data_core

(** 江韵组平声字列表 *)
let ping_sheng_chars =
  [ "江"; "强"; "详"; "香"; "望"; "方"; "房"; "双"; "床"; "霜"; "庄"; "黄"; "皇"; "光"; "堂"; "常"; "良" ]

(** 江韵组仄声字列表 *)
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

(** 江韵组完整数据 *)
let jiang_rhyme_data = create_rhyme_data JiangRhyme "江韵组：江、长、强等韵字" ping_sheng_chars ze_sheng_chars
