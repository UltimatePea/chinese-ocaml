(** 韵律数据缓存模块接口
    
    专门处理韵律数据缓存、性能优化和内存管理，
    使用哈希表和LRU策略优化缓存性能。
    
    Author: Alpha, 主工作代理
    Fix #1460 Phase 2.1 - 缓存模块优化 *)

open Rhyme_file_config

(** 韵律数据条目 *)
type rhyme_entry = {
  character : string;
  category : rhyme_category;
  group : rhyme_group;
  tone_info : string option;
  usage_notes : string option;
}

(** 缓存统计信息 *)
type cache_stats = {
  total_entries : int;
  cache_hits : int;
  cache_misses : int;
  memory_usage_bytes : int;
}

(** 韵律数据缓存模块 *)
module RhymeCache : sig
  (** 获取缓存数据 *)
  val get_cached : rhyme_category -> rhyme_group -> rhyme_entry list option
  
  (** 存储缓存数据 *)
  val store_cached : rhyme_category -> rhyme_group -> rhyme_entry list -> string -> unit
  
  (** 清理缓存 *)
  val clear_cache : unit -> unit
  
  (** 获取缓存统计信息 *)
  val get_cache_stats : unit -> cache_stats
  
  (** 缓存信息摘要 *)
  val cache_info : unit -> string
  
  (** 预热缓存 *)
  val warm_up_cache : rhyme_file_config -> (rhyme_category * rhyme_group) list -> unit
end

(** 创建韵律条目 *)
val create_rhyme_entries : string list -> rhyme_category -> rhyme_group -> rhyme_entry list

(** 验证韵律条目 *)
val validate_rhyme_entry : rhyme_entry -> bool

(** 清理重复的韵律条目 *)
val deduplicate_rhyme_entries : rhyme_entry list -> rhyme_entry list

(** 韵律数据统计 *)
val analyze_rhyme_data : rhyme_entry list -> string

(** 创建韵律匹配器 *)
val create_rhyme_matcher : rhyme_entry list -> (string -> rhyme_group option)

(** 创建韵律验证器 *)
val create_rhyme_validator : rhyme_entry list -> (string -> bool)

(** 韵律分析报告 *)
val generate_rhyme_report : rhyme_entry list -> string