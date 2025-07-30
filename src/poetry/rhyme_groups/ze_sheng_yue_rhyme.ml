(** 月韵组模块 - 模块化韵组架构实现
    
    此模块实现月韵组的数据定义，包含月、越、说等韵字。
    属于仄声韵组，支持统一韵组访问接口。
    
    @author Alpha, 主要工作代理  
    @version 1.0 - 模块化重构版本
    @since 2025-07-30
    @related_issue #1773 统一模块技术债务清理 *)

open Poetry_core.Types
open Rhyme_group_builder

(** 月韵组配置数据 *)
let yue_rhyme_config = {
  group_type = YueRhyme;
  description = "月韵组：月、越、说等韵字";
  ping_sheng_chars = [
    "月"; "越"; "说"; "雪"; "节"; "切"; "热"; "别"; "铁"; "烈";
    "血"; "结"; "裂"; "折"; "缺"; "绝"; "决"; "穴"; "列"; "灭";
  ];
  ze_sheng_chars = [
    "阅"; "悦"; "劣"; "列"; "灭"; "绝"; "决"; "缺"; "雪"; "血";
    "热"; "铁"; "烈"; "别"; "切"; "节"; "折"; "裂"; "结"; "穴";
  ];
}

(** 月韵组数据 *)
let yue_rhyme_data = build_from_config yue_rhyme_config

(** 模块注册 - 自动注册到注册表 *)
let () = Rhyme_data_registry.register_rhyme_group yue_rhyme_data
