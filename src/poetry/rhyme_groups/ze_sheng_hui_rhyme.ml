(** 会韵组模块 - 模块化韵组架构实现
    
    此模块实现会韵组的数据定义，包含会、回、来等韵字。
    属于仄声韵组，支持统一韵组访问接口。
    
    @author Alpha, 主要工作代理  
    @version 1.0 - 模块化重构版本
    @since 2025-07-30
    @related_issue #1773 统一模块技术债务清理 *)

open Poetry_core.Types
open Rhyme_group_builder

(** 会韵组配置数据 *)
let hui_rhyme_config = {
  group_type = HuiRhyme;
  description = "会韵组：会、回、来等韵字";
  ping_sheng_chars = [
    "会"; "回"; "来"; "开"; "台"; "才"; "材"; "白"; "百"; "排";
    "败"; "买"; "卖"; "海"; "害"; "爱"; "在"; "再"; "外"; "内";
  ];
  ze_sheng_chars = [
    "对"; "队"; "背"; "黑"; "北"; "倍"; "配"; "退"; "推"; "追";
    "催"; "灰"; "悔"; "累"; "类"; "泪"; "醉"; "罪"; "碎"; "岁";
  ];
}

(** 会韵组数据 *)
let hui_rhyme_data = build_from_config hui_rhyme_config

(** 模块注册 - 自动注册到注册表 *)
let () = Rhyme_data_registry.register_rhyme_group hui_rhyme_data
