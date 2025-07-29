(** 韵律数据构建器接口 - 模块化重构后的兼容接口

    此模块作为统一注册中心的兼容层，保持所有现有API完全不变。 提供韵律数据条目构建和各韵组数据访问的统一接口。

    Author: Alpha, 主要工作代理
    @version 2.0 - 模块化重构版本
    @since 2025-07-28 *)

open Poetry_core.Poetry_types
open Rhyme_core_types

(** {1 数据构建辅助函数} *)

val make_entry :
  string ->
  rhyme_category ->
  rhyme_group ->
  ?variants:string list ->
  ?frequency:float ->
  unit ->
  rhyme_data_entry
(** [make_entry char category group ?variants ?frequency ()] 创建韵律数据条目
    @param char 字符
    @param category 韵律类别
    @param group 韵组
    @param variants 可选的变体列表，默认为空
    @param frequency 可选的使用频率，默认为1.0
    @return 韵律数据条目 *)

val make_group_entries : rhyme_category -> rhyme_group -> string list -> rhyme_data_entry list
(** [make_group_entries category group chars] 为韵组创建字符列表
    @param category 韵律类别
    @param group 韵组
    @param chars 字符列表
    @return 韵律数据条目列表 *)

(** {2 韵组数据访问接口} *)

val an_rhyme_data : rhyme_group_data
(** 安韵组数据 *)

val si_rhyme_data : rhyme_group_data
(** 思韵组数据 *)

val tian_rhyme_data : rhyme_group_data
(** 天韵组数据 *)

val wang_rhyme_data : rhyme_group_data
(** 望韵组数据 *)

val qu_rhyme_data : rhyme_group_data
(** 去韵组数据 *)

val yu_rhyme_data : rhyme_group_data
(** 鱼韵组数据 *)

val hua_rhyme_data : rhyme_group_data
(** 花韵组数据 *)

val feng_rhyme_data : rhyme_group_data
(** 风韵组数据 *)

val yue_rhyme_data : rhyme_group_data
(** 月韵组数据 *)

val jiang_rhyme_data : rhyme_group_data
(** 江韵组数据 *)

val hui_rhyme_data : rhyme_group_data
(** 灰韵组数据 *)

(** {3 集合数据} *)

val all_rhyme_groups : rhyme_group_data list
(** 所有韵组的完整列表 *)
