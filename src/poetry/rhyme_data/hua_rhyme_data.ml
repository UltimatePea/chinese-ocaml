(** 花韵组数据模块
    
    包含花韵组的所有韵字数据，分为平声和仄声两类。
    
    @author Alpha, 主要工作代理
    @version 1.0 - 韵组数据模块化重构
    @since 2025-07-30
    @rhyme_group HuaRhyme *)

open Poetry_core.Rhyme_core_types
open Rhyme_data_core

(** 花韵组平声字列表 *)
let ping_sheng_chars =
  [
    "花";
    "家";
    "华";
    "加";
    "嘉";
    "茶";
    "霞";
    "沙";
    "斜";
    "牙";
    "芽";
    "瓜";
    "麻";
    "纱";
    "娃";
    "蛙";
    "哇";
    "奢";
    "车";
    "赊";
  ]

(** 花韵组仄声字列表 *)
let ze_sheng_chars =
  [
    "化";
    "话";
    "画";
    "价";
    "架";
    "假";
    "下";
    "夏";
    "罢";
    "马";
    "卦";
    "挂";
    "骂";
    "巴";
    "把";
    "爸";
    "打";
    "达";
    "答";
    "塔";
  ]

(** 花韵组完整数据 *)
let hua_rhyme_data = create_rhyme_data HuaRhyme "花韵组：花、家、华等韵字" ping_sheng_chars ze_sheng_chars
