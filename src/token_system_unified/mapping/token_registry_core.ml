(** Token注册器核心功能 - 注册器数据结构和基础操作 *)

open Token_definitions_unified

type token_mapping_entry = {
  source_token : string; (* 源token名称 *)
  target_token : token; (* 目标token类型，使用统一定义 *)
  category : string; (* 分类：literal, identifier, keyword, operator等 *)
  priority : int; (* 优先级，用于冲突解决 *)
  description : string; (* 描述信息 *)
}
(** Token映射条目类型 *)

(** Token注册表 *)
let token_registry = ref []

(** 注册token映射 *)
let register_token_mapping entry = token_registry := entry :: !token_registry

(** 查询token映射 *)
let find_token_mapping source_token =
  List.find_opt (fun entry -> entry.source_token = source_token) !token_registry

(** 获取按优先级排序的映射 *)
let get_sorted_mappings () = List.sort (fun a b -> compare b.priority a.priority) !token_registry

(** 获取按分类分组的映射 *)
let get_mappings_by_category category =
  List.filter (fun entry -> entry.category = category) !token_registry

(** 清空注册表 *)
let clear_registry () = token_registry := []

(** 获取所有注册的映射 *)
let get_all_mappings () = !token_registry
