(** 风韵组模块 - 模块化韵组架构实现
    
    此模块实现风韵组的数据定义，包含风、东、中等韵字。
    属于仄声韵组，支持统一韵组访问接口。
    
    @author Alpha, 主要工作代理  
    @version 1.0 - 模块化重构版本
    @since 2025-07-30
    @related_issue #1773 统一模块技术债务清理 *)

open Poetry_core.Types
open Rhyme_group_builder

(** 风韵组配置数据 *)
let feng_rhyme_config =
  {
    group_type = FengRhyme;
    description = "风韵组：风、东、中等韵字";
    ping_sheng_chars =
      [
        "风";
        "东";
        "中";
        "空";
        "同";
        "通";
        "红";
        "公";
        "功";
        "工";
        "穷";
        "终";
        "冬";
        "龙";
        "虫";
        "融";
        "隆";
        "松";
        "钟";
        "宫";
      ];
    ze_sheng_chars =
      [
        "动";
        "用";
        "重";
        "众";
        "种";
        "痛";
        "送";
        "统";
        "共";
        "控";
        "总";
        "聪";
        "充";
        "宋";
        "诵";
        "颂";
        "涌";
        "拥";
        "容";
        "纵";
      ];
  }

(** 风韵组数据 *)
let feng_rhyme_data = build_from_config feng_rhyme_config

(** 模块注册 - 自动注册到注册表 *)
let () = Rhyme_data_registry.register_rhyme_group feng_rhyme_data
