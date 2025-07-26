(** 中央Token注册器 - 重构后的模块化版本 *)
(* 使用统一token定义，通过专门的子模块管理不同类型的token *)

(* 重新导出核心类型和函数，保持向后兼容性 *)
open Token_definitions_unified
open Token_registry_core
open Token_registry_literals
open Token_registry_identifiers
open Token_registry_keywords
open Token_registry_operators

type local_token = token
(** 为了向后兼容，保留local_token类型别名 *)

type token_mapping_entry = Token_registry_core.token_mapping_entry = {
  source_token : string; (* 源token名称 *)
  target_token : token; (* 目标token类型，使用统一定义 *)
  category : string; (* 分类：literal, identifier, keyword, operator等 *)
  priority : int; (* 优先级，用于冲突解决 *)
  description : string; (* 描述信息 *)
}
(** 重新导出token_mapping_entry类型 *)

(* 重新导出核心函数以保持接口兼容性 *)
let register_token_mapping = Token_registry_core.register_token_mapping
let find_token_mapping = Token_registry_core.find_token_mapping
let get_sorted_mappings = Token_registry_core.get_sorted_mappings
let get_mappings_by_category = Token_registry_core.get_mappings_by_category
let get_registry_stats = Token_registry_stats.get_registry_stats
let validate_registry = Token_registry_stats.validate_registry
let generate_token_converter = Token_registry_converter.generate_token_converter

(** 初始化注册器 - 注册所有基础映射 *)
let initialize_registry () =
  (* 清空现有注册 *)
  clear_registry ();

  (* 分别注册各类Token映射 *)
  register_literal_tokens ();
  register_identifier_tokens ();
  register_basic_keywords ();
  register_type_keywords ();
  register_operator_tokens ();

  (* 输出统计信息 *)
  Printf.printf "%s\n" (get_registry_stats ())
