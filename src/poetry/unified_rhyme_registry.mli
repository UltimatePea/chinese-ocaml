(** 统一韵律数据注册中心接口 - 骆言诗词编程特性
 
    此模块提供统一的韵律数据访问接口，是Poetry模块技术债务重构的核心成果。
    消除了20+个重复的韵律数据文件，提供高效、一致的数据访问方式。
    
    Author: Alpha, 主要工作代理
    @version 1.0 - 统一重构版本  
    @since 2025-07-27 - Poetry模块技术债务专项整合 - Fix #1528 *)

open Rhyme_types

(** {1 核心数据类型} *)

type rhyme_entry = {
  character : string;        (** 字符 *)
  category : rhyme_category; (** 声韵类别 *)
  group : rhyme_group;      (** 韵组 *)
  frequency : float;        (** 使用频度 0.0-1.0 *)
  variants : string list;   (** 异体字或相关字 *)
}
(** 统一的韵律数据条目 *)

type rhyme_group_registry = {
  group_name : rhyme_group;        (** 韵组名称 *)
  description : string;            (** 韵组描述 *)
  entries : rhyme_entry list;      (** 韵组所有条目 *)
  example_poems : string list;     (** 典型诗例 *)
}
(** 韵组注册信息 *)

(** {2 数据构建辅助函数} *)

val make_entry : string -> rhyme_category -> rhyme_group -> ?frequency:float -> ?variants:string list -> unit -> rhyme_entry
(** 创建韵律条目 *)

val make_group_entries : rhyme_category -> rhyme_group -> string list -> rhyme_entry list  
(** 批量创建同韵组条目 *)

(** {2 查询接口} *)

val lookup_character : string -> (rhyme_category * rhyme_group) option
(** 查询字符的韵律信息。返回 (声调类别, 韵组) 或 None *)

val get_rhyme_group_entries : rhyme_group -> rhyme_entry list option
(** 获取指定韵组的所有条目 *)

val get_rhyme_group_registry : rhyme_group -> rhyme_group_registry option
(** 获取指定韵组的完整注册信息 *)

val get_characters_by_category : rhyme_category -> string list
(** 获取某个声调类别的所有字符 *)

val is_same_rhyme : string -> string -> bool
(** 检查两个字符是否同韵 *)

val is_ping_sheng_char : string -> bool
(** 检查字符是否为平声 *)

val is_ze_sheng_char : string -> bool  
(** 检查字符是否为仄声 *)

(** {2 统计和分析} *)

val get_registry_statistics : unit -> string
(** 获取注册中心统计信息 *)

(** {2 向后兼容接口} *)

val simple_lookup : string -> (string * rhyme_category * rhyme_group) option
(** 兼容原有API的简单查询函数 *)

val get_rhyme_group_data : rhyme_group -> (string * rhyme_category * rhyme_group) list
(** 获取韵组数据（兼容格式） *)

(** {2 预定义韵组注册表} *)

val an_rhyme_registry : rhyme_group_registry
(** 安韵组注册表 *)

val si_rhyme_registry : rhyme_group_registry
(** 思韵组注册表 *)

val tian_rhyme_registry : rhyme_group_registry
(** 天韵组注册表 *)

val feng_rhyme_registry : rhyme_group_registry
(** 风韵组注册表 *)

val yu_rhyme_registry : rhyme_group_registry
(** 鱼韵组注册表 *)

val hua_rhyme_registry : rhyme_group_registry
(** 花韵组注册表 *)

val yue_rhyme_registry : rhyme_group_registry
(** 月韵组注册表 *)

val jiang_rhyme_registry : rhyme_group_registry
(** 江韵组注册表 *)

val hui_rhyme_registry : rhyme_group_registry
(** 灰韵组注册表 *)

val qu_rhyme_registry : rhyme_group_registry
(** 去韵组注册表 *)

val wang_rhyme_registry : rhyme_group_registry
(** 望韵组注册表 *)

val all_rhyme_registries : rhyme_group_registry list
(** 所有韵组注册表 *)