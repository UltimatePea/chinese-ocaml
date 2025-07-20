(** 中央Token注册器接口 - 重构后的模块化版本 *)

(* 使用统一token定义，通过专门的子模块管理不同类型的token *)
open Token_definitions_unified

(** 为了向后兼容，保留local_token类型别名 *)
type local_token = token

(** 重新导出token_mapping_entry类型 *)
type token_mapping_entry = Token_registry_core.token_mapping_entry = {
  source_token : string; (* 源token名称 *)
  target_token : token; (* 目标token类型，使用统一定义 *)
  category : string; (* 分类：literal, identifier, keyword, operator等 *)
  priority : int; (* 优先级，用于冲突解决 *)
  description : string; (* 描述信息 *)
}

(** 重新导出核心功能 *)
val register_token_mapping : token_mapping_entry -> unit
(** 注册token映射 *)

val find_token_mapping : string -> token_mapping_entry option
(** 查询token映射 *)

val get_sorted_mappings : unit -> token_mapping_entry list
(** 获取按优先级排序的映射 *)

val get_mappings_by_category : string -> token_mapping_entry list
(** 获取按分类分组的映射 *)

val get_registry_stats : unit -> string
(** 获取注册器统计信息 *)

val validate_registry : unit -> unit
(** 验证注册器一致性 *)

val generate_token_converter : unit -> string
(** 生成token转换函数 *)

val initialize_registry : unit -> unit
(** 初始化注册器 - 注册所有基础映射 *)
