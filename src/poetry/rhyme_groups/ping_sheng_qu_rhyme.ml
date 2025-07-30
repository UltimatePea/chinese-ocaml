(** 曲韵组模块 - 模块化韵组架构实现
    
    此模块实现曲韵组的数据定义，包含曲、书、虚等韵字。
    属于平声韵组，支持统一韵组访问接口。
    
    @author Alpha, 主要工作代理  
    @version 1.0 - 模块化重构版本
    @since 2025-07-30
    @related_issue #1773 统一模块技术债务清理 *)

open Poetry_core.Types
open Rhyme_group_builder

(** 曲韵组配置数据 *)
let qu_rhyme_config =
  {
    group_type = QuRhyme;
    description = "曲韵组：曲、书、虚等韵字";
    ping_sheng_chars = [ "曲"; "书"; "虚"; "如"; "除"; "无"; "吴"; "须"; "徐"; "胥"; "疏"; "图"; "途"; "都" ];
    ze_sheng_chars =
      [
        "去";
        "取";
        "住";
        "数";
        "度";
        "路";
        "故";
        "顾";
        "具";
        "句";
        "处";
        "据";
        "遇";
        "务";
        "树";
        "素";
        "注";
        "助";
        "著";
        "暑";
      ];
  }

(** 曲韵组数据 *)
let qu_rhyme_data = build_from_config qu_rhyme_config

(** 模块注册 - 自动注册到注册表 *)
let () = Rhyme_data_registry.register_rhyme_group qu_rhyme_data
