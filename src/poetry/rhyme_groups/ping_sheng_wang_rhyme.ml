(** 王韵组模块 - 模块化韵组架构实现
    
    此模块实现王韵组的数据定义，包含王、章、张等韵字。
    属于平声韵组，支持统一韵组访问接口。
    
    @author Alpha, 主要工作代理  
    @version 1.0 - 模块化重构版本
    @since 2025-07-30
    @related_issue #1773 统一模块技术债务清理 *)

open Poetry_core.Types
open Rhyme_group_builder

(** 王韵组配置数据 *)
let wang_rhyme_config =
  {
    group_type = WangRhyme;
    description = "王韵组：王、章、张等韵字";
    ping_sheng_chars =
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
      ];
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

(** 王韵组数据 *)
let wang_rhyme_data = build_from_config wang_rhyme_config

(** 模块注册 - 自动注册到注册表 *)
let () = Rhyme_data_registry.register_rhyme_group wang_rhyme_data
