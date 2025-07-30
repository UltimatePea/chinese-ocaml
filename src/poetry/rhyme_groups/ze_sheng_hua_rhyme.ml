(** 花韵组模块 - 模块化韵组架构实现
    
    此模块实现花韵组的数据定义，包含花、家、华等韵字。
    属于仄声韵组，支持统一韵组访问接口。
    
    @author Alpha, 主要工作代理  
    @version 1.0 - 模块化重构版本
    @since 2025-07-30
    @related_issue #1773 统一模块技术债务清理 *)

open Poetry_core.Types
open Rhyme_group_builder

(** 花韵组配置数据 *)
let hua_rhyme_config = {
  group_type = HuaRhyme;
  description = "花韵组：花、家、华等韵字";
  ping_sheng_chars = [
    "花"; "家"; "华"; "加"; "嘉"; "茶"; "霞"; "沙"; "斜"; "牙";
    "芽"; "瓜"; "麻"; "纱"; "娃"; "蛙"; "哇"; "奢"; "车"; "赊";
  ];
  ze_sheng_chars = [
    "化"; "话"; "画"; "价"; "架"; "假"; "下"; "夏"; "罢"; "马";
    "卦"; "挂"; "骂"; "巴"; "把"; "爸"; "打"; "达"; "答"; "塔";
  ];
}

(** 花韵组数据 *)
let hua_rhyme_data = build_from_config hua_rhyme_config

(** 模块注册 - 自动注册到注册表 *)
let () = Rhyme_data_registry.register_rhyme_group hua_rhyme_data
