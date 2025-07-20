(** Token注册器核心功能接口 - 注册器数据结构和基础操作 *)

open Token_definitions_unified

(** Token映射条目类型 *)
type token_mapping_entry = {
  source_token : string; (* 源token名称 *)
  target_token : token; (* 目标token类型，使用统一定义 *)
  category : string; (* 分类：literal, identifier, keyword, operator等 *)
  priority : int; (* 优先级，用于冲突解决 *)
  description : string; (* 描述信息 *)
}

val register_token_mapping : token_mapping_entry -> unit
(** 注册token映射 *)

val find_token_mapping : string -> token_mapping_entry option
(** 查询token映射 *)

val get_sorted_mappings : unit -> token_mapping_entry list
(** 获取按优先级排序的映射 *)

val get_mappings_by_category : string -> token_mapping_entry list
(** 获取按分类分组的映射 *)

val clear_registry : unit -> unit
(** 清空注册表 *)

val get_all_mappings : unit -> token_mapping_entry list
(** 获取所有注册的映射 *)