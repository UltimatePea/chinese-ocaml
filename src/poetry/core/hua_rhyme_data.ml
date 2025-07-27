(** 花韵组数据模块

    从 rhyme_core_data.ml 中提取的花韵组专用数据， 包含花韵组的平声字符数据。

    @author 骆言诗词编程团队
    @version 1.0 - 模块化重构版本
    @since 2025-07-27 *)

open Rhyme_core_types
open Rhyme_helpers

(** 花韵组平声字符数据 *)
let ping_sheng_chars =
  [
    "花";
    "霞";
    "家";
    "茶";
    "沙";
    "华";
    "瓜";
    "夸";
    "画";
    "话";
    "化";
    "划";
    "挂";
    "卦";
    "怕";
    "爬";
    "拿";
    "那";
    "哪";
    "马";
    "骂";
    "打";
    "大";
    "达";
    "塔";
    "答";
    "搭";
    "法";
    "发";
  ]

(** 花韵组平声数据条目 *)
let ping_sheng_data = make_group_entries PingSheng HuaRhyme ping_sheng_chars

(** 花韵组所有数据 *)
let all_data = ping_sheng_data