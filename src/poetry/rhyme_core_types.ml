(** 韵律核心类型定义 - 从rhyme_core_unified.ml重构提取

    此模块包含韵律系统的核心数据类型定义，分离类型定义以提高模块化。

    重构目标:
    - 提供清晰的类型定义边界
    - 支持模块间依赖清理
    - 维持完全的API兼容性

    Author: Alpha, 主要工作代理
    @version 1.0 - 重构提取版本
    @since 2025-07-28 - 基于Issue #1585的科学技术债务重构计划 *)

open Poetry_core.Poetry_types

(** {1 韵律数据类型定义} *)

type rhyme_data_entry = {
  character : string;  (** 字符 *)
  category : rhyme_category;  (** 声韵类别 *)
  group : rhyme_group;  (** 韵组 *)
  variants : string list;  (** 异体字或相关字 *)
  usage_frequency : float;  (** 使用频度 *)
}
(** 韵律数据条目：基础数据单元 *)

type rhyme_group_data = {
  group_name : rhyme_group;  (** 韵组名称 *)
  group_description : string;  (** 韵组描述 *)
  entries : rhyme_data_entry list;  (** 该韵组所有条目 *)
  example_poems : string list;  (** 典型用例诗句 *)
}
(** 韵组数据：某个韵组的完整信息 *)
