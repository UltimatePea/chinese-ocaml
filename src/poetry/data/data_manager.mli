(** 统一数据管理器接口 - Phase 2 架构修正核心模块
    
    基于Delta代理批判性分析的架构修正，实现真正统一的数据访问层，
    解决当前69个数据模块混乱的根本问题。
                                                           
    @author Alpha, 主要工作代理 - 负责功能实现和技术债务处理
    @version 2.0 - 架构修正版本
    @since 2025-07-28 - Phase 2A 核心重构
    @fix_issue #1572 *)

(** {1 核心数据类型定义} *)

(** 统一数据项类型 - 类型安全的数据表示 *)
type unified_data_item = {
  character : string;
  category : Poetry_core.Json_core.rhyme_category;
  group : Poetry_core.Json_core.rhyme_group;
  metadata : (string * string) list;
}

(** 数据源标识符 - 支持扩展的数据源类型 *)
type data_source_id = 
  | RhymeData of string        (* 韵律数据源 *)
  | PoetryData of string       (* 诗词数据源 *)
  | ToneData of string         (* 声调数据源 *)
  | WordClassData of string    (* 词类数据源 *)

(** 查询条件类型 - 支持复合查询 *)
type query_criteria =
  | ByCharacter of string
  | ByCategory of Poetry_core.Json_core.rhyme_category  
  | ByGroup of Poetry_core.Json_core.rhyme_group
  | BySource of data_source_id
  | CompositeQuery of query_criteria list

(** 数据操作结果类型 - 统一错误处理 *)
type 'a data_result = 
  | Success of 'a
  | Error of Poetry_core.Poetry_errors.data_error

(** {1 缓存策略类型} *)

(** 缓存策略配置 *)
type cache_strategy = {
  enable_cache : bool;
  max_cache_size : int;
  ttl_seconds : float;
  eviction_policy : [`LRU | `LFU | `FIFO];
}

(** 缓存统计信息 *)
type cache_statistics = {
  total_queries : int;
  cache_hits : int;
  cache_misses : int;
  cache_size : int;
  hit_rate : float;
  last_cleanup : float;
}

(** {1 数据源管理} *)

val register_data_source : data_source_id -> 
  (unit -> unified_data_item list data_result) -> 
  ?priority:int -> 
  string -> 
  unit data_result
(** 注册数据源加载器
    
    类型安全的数据源注册，支持延迟加载和错误处理
    
    @param source_id 数据源标识
    @param loader 数据加载函数
    @param priority 优先级（默认为0）
    @param description 描述信息
    @return 注册结果 *)

val unregister_data_source : data_source_id -> unit data_result
(** 注销数据源 *)

val list_registered_sources : unit -> (data_source_id * string * int) list
(** 列出所有注册的数据源 (源标识, 描述, 优先级) *)

(** {1 统一数据查询接口} *)

val query_data : query_criteria -> unified_data_item list data_result
(** 统一数据查询接口 - 支持复合查询和缓存 *)

val query_data_streaming : query_criteria -> 
  (unified_data_item -> unit) -> 
  unit data_result
(** 流式数据查询 - 适用于大数据集 *)

val count_data : query_criteria -> int data_result
(** 数据计数查询 - 不加载完整数据 *)

(** {1 高性能查询接口} *)

module FastLookup : sig
  val build_index : data_source_id list -> unit data_result
  (** 为指定数据源构建快速查找索引 *)
  
  val lookup_character : string -> unified_data_item option data_result
  (** O(1) 字符查找 *)
  
  val lookup_characters_by_group : Poetry_core.Json_core.rhyme_group -> 
    string list data_result
  (** O(1) 按韵组查找字符列表 *)
  
  val is_index_built : data_source_id -> bool
  (** 检查索引是否已构建 *)
  
  val rebuild_index : data_source_id -> unit data_result
  (** 重建指定数据源的索引 *)
end

(** {1 缓存管理} *)

module Cache : sig
  val configure : cache_strategy -> unit data_result
  (** 配置缓存策略 *)
  
  val get_statistics : unit -> cache_statistics
  (** 获取缓存统计 *)
  
  val clear_cache : ?source:data_source_id -> unit -> unit data_result
  (** 清除缓存（可选择性清除特定数据源） *)
  
  val preload_cache : data_source_id list -> unit data_result
  (** 预加载缓存 *)
  
  val get_cache_efficiency : unit -> float
  (** 获取缓存效率 (0.0-1.0) *)
end

(** {1 数据一致性和验证} *)

val validate_data_integrity : data_source_id list -> 
  (bool * string list) data_result  
(** 验证数据完整性
    
    @param sources 要验证的数据源列表
    @return (是否有效, 错误信息列表) *)

val detect_data_conflicts : data_source_id list -> 
  (string * data_source_id * data_source_id) list data_result
(** 检测数据冲突
    
    @return (冲突字符, 数据源1, 数据源2) 列表 *)

val merge_conflicting_data : 
  resolve_conflict:(unified_data_item -> unified_data_item -> unified_data_item) ->
  data_source_id list -> 
  unified_data_item list data_result
(** 合并冲突数据
    
    @param resolve_conflict 冲突解决函数
    @param sources 数据源列表
    @return 合并后的数据 *)

(** {1 统计和监控} *)

val get_data_statistics : unit -> 
  (int * int * int * float) data_result
(** 获取数据统计
    
    @return (总数据项数, 数据源数, 缓存大小, 平均查询时间ms) *)

val get_source_statistics : data_source_id -> 
  (int * float * bool) data_result  
(** 获取特定数据源统计
    
    @return (数据项数, 最后加载时间, 索引状态) *)

val print_performance_report : unit -> unit
(** 打印性能报告 *)

(** {1 向后兼容性接口} *)

module Compatibility : sig
  val get_legacy_rhyme_database : unit -> 
    (string * Poetry_core.Json_core.rhyme_category * Poetry_core.Json_core.rhyme_group) list
  (** 兼容原 cache_manager.ml 的 get_unified_database 接口 *)
  
  val is_char_in_database : string -> bool
  (** 兼容原 cache_manager.ml 的 is_char_in_database 接口 *)
  
  val get_char_rhyme_info : string -> 
    (string * Poetry_core.Json_core.rhyme_category * Poetry_core.Json_core.rhyme_group) option
  (** 兼容原 cache_manager.ml 的 get_char_rhyme_info 接口 *)
end

(** {1 批量操作和导出} *)

val export_data : query_criteria -> format:[`JSON | `CSV | `OCaml] -> string data_result
(** 导出查询结果到不同格式 *)

val import_data : data_source_id -> format:[`JSON | `CSV] -> string -> unit data_result  
(** 从外部格式导入数据 *)

val batch_query : query_criteria list -> unified_data_item list list data_result
(** 批量查询 - 优化多个查询的性能 *)