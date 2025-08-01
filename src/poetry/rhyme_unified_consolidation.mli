(** 韵律模块统一整合核心模块接口 - Issue #1999 实施
    
    此模块整合65个重复韵律文件为15个核心模块的公共接口定义。
    
    Author: Whisky, PR Worker
    @version 1.0 - Poetry韵律模块统一整合实施
    @since 2025-08-01
    @implements Issue #1999 - Poetry韵律模块统一整合实施 *)

open Rhyme_types_unified

(** {1 统一韵律数据结构} *)

(** 统一的韵律条目结构 *)
type unified_rhyme_entry = {
  character: string;            (** 韵字 *)
  rhyme_group: rhyme_group;     (** 韵组 *)
  tone_category: rhyme_category; (** 声调类别 *)
  frequency: float;             (** 使用频率 *)
  variants: string list;        (** 变体字 *)
  source_module: string;        (** 来源模块 (用于追踪) *)
}

(** 统一的韵律数据库结构 *)
type unified_rhyme_database = {
  entries: unified_rhyme_entry list;
  lookup_table: (string, unified_rhyme_entry) Hashtbl.t;
  group_index: (rhyme_group, unified_rhyme_entry list) Hashtbl.t;
  tone_index: (rhyme_category, unified_rhyme_entry list) Hashtbl.t;
  stats: database_stats;
}

and database_stats = {
  total_entries: int;
  ping_sheng_count: int;
  ze_sheng_count: int;
  ru_sheng_count: int;
  group_counts: (rhyme_group * int) list;
}

(** {2 高性能查询接口} *)

(** O(1) 韵字查询 - 性能优化核心 *)
val lookup_rhyme_entry : string -> unified_rhyme_entry option

(** O(1) 韵组查询 *)
val lookup_rhyme_group : rhyme_group -> unified_rhyme_entry list option

(** O(1) 声调查询 *)
val lookup_tone_category : rhyme_category -> unified_rhyme_entry list option

(** 韵字匹配检查 - 优化版本 *)
val characters_rhyme : string -> string -> bool

(** 获取统计信息 *)
val get_database_stats : unit -> database_stats

(** {2 向后兼容接口} *)

(** 兼容原有API - 保持100%向后兼容 *)
module Legacy_API : sig
  (** 兼容 an_rhyme_data.ml *)
  module An_Rhyme_Data : sig
    val ping_sheng_chars : string list
    val ze_sheng_chars : string list
  end
  
  (** 兼容 feng_rhyme_data.ml *)
  module Feng_Rhyme_Data : sig
    val ping_sheng_chars : string list
  end
  
  (** 兼容 unified_rhyme_data.ml 接口 *)
  val load_rhyme_data_from_json : unit -> (rhyme_group * rhyme_category * string list) list
  
  (** 兼容 rhyme_database.ml 接口 *)
  val query_rhyme : string -> unified_rhyme_entry option
  
  (** 兼容 rhyme_query_engine.ml 接口 *)
  val find_rhyming_words : string -> string list
end

(** {2 性能监控} *)

(** 查询性能统计 *)
type performance_stats = {
  mutable total_queries: int;
  mutable cache_hits: int;
  mutable cache_misses: int;
}

(** 性能监控包装器 *)
val monitored_lookup : string -> unified_rhyme_entry option

(** 获取性能统计 *)
val get_performance_stats : unit -> performance_stats

(** {2 验证和测试接口} *)

(** 数据完整性验证 *)
val validate_data_integrity : unit -> bool

(** 性能基准测试 *)
val benchmark_queries : int -> float