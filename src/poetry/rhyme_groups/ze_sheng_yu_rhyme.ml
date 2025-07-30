(** 鱼韵组模块 - 模块化韵组架构实现
    
    此模块实现鱼韵组的数据定义，包含鱼、余、居等韵字。
    属于仄声韵组，支持统一韵组访问接口。
    
    @author Alpha, 主要工作代理  
    @version 1.0 - 模块化重构版本
    @since 2025-07-30
    @related_issue #1773 统一模块技术债务清理 *)

open Poetry_core.Types
open Rhyme_group_builder

(** 鱼韵组配置数据 *)
let yu_rhyme_config =
  {
    group_type = YuRhyme;
    description = "鱼韵组：鱼、书、余等韵字";
    ping_sheng_chars = [ "鱼"; "余"; "居"; "初"; "渠"; "车" ];
    ze_sheng_chars =
      [
        "语";
        "举";
        "女";
        "雨";
        "与";
        "许";
        "处";
        "虑";
        "数";
        "度";
        "路";
        "故";
        "顾";
        "具";
        "句";
        "据";
        "遇";
        "务";
        "树";
        "素";
      ];
  }

(** 鱼韵组数据 *)
let yu_rhyme_data = build_from_config yu_rhyme_config

(** 模块注册 - 自动注册到注册表 *)
let () = Rhyme_data_registry.register_rhyme_group yu_rhyme_data
