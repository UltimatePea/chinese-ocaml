(** 江韵组模块 - 模块化韵组架构实现
    
    此模块实现江韵组的数据定义，包含江、长、强等韵字。
    属于仄声韵组，支持统一韵组访问接口。
    
    @author Alpha, 主要工作代理  
    @version 1.0 - 模块化重构版本
    @since 2025-07-30
    @related_issue #1773 统一模块技术债务清理 *)

open Poetry_core.Types
open Rhyme_group_builder

(** 江韵组配置数据 *)
let jiang_rhyme_config =
  {
    group_type = JiangRhyme;
    description = "江韵组：江、长、强等韵字";
    ping_sheng_chars =
      [ "江"; "强"; "详"; "香"; "望"; "方"; "房"; "双"; "床"; "霜"; "庄"; "黄"; "皇"; "光"; "堂"; "常"; "良" ];
    ze_sheng_chars =
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
      ];
  }

(** 江韵组数据 *)
let jiang_rhyme_data = build_from_config jiang_rhyme_config

(** 模块注册 - 自动注册到注册表 *)
let () = Rhyme_data_registry.register_rhyme_group jiang_rhyme_data
