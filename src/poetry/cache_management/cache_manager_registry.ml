(** 缓存管理器注册表模块
    
    此模块作为统一的访问入口，整合所有模块化的缓存管理功能，
    并保持与原始data_cache_manager.ml的完全向后兼容性。
    
    @author Alpha, 主要工作代理
    @version 1.0 - 数据缓存管理器模块化重构
    @since 2025-07-30
    @replaces data_cache_manager.ml *)

(** {1 类型定义重新导出} *)

(* 重新导出所有核心类型以保持兼容性 *)
type cache_strategy = Cache_core_types.cache_strategy =
  | LRU           
  | LFU           
  | FIFO          
  | TTL of float  
  | Custom of (string -> bool)

type cache_priority = Cache_core_types.cache_priority =
  | Critical      
  | High          
  | Normal        
  | Low           
  | Disposable    

type cache_metadata = Cache_core_types.cache_metadata = {
  key : string;                     
  size_bytes : int;                 
  created_time : float;             
  last_accessed : float;            
  access_count : int;               
  priority : cache_priority;        
  ttl : float option;               
  tags : string list;               
}

type cache_statistics = Cache_core_types.cache_statistics = {
  total_entries : int;              
  total_size_bytes : int;           
  hit_count : int;                  
  miss_count : int;                 
  eviction_count : int;             
  hit_rate : float;                 
  avg_access_time : float;          
  memory_usage_mb : float;          
}

type cache_event = Cache_core_types.cache_event =
  | CacheHit of string              
  | CacheMiss of string             
  | CacheStore of string * int      
  | CacheEvict of string * string   
  | CacheExpire of string           
  | CacheClear of string list       

type 'a cache_result =
  | CacheSuccess of 'a              
  | CacheError of string            
  | CacheNotFound                   
  | CacheExpired                    

(** {1 统一缓存管理接口} *)

(** 核心操作 *)
let initialize = Cache_state.initialize
let shutdown = Cache_state.shutdown
let is_initialized = Cache_state.is_initialized
let configure_strategy = Cache_state.configure_strategy

(** 基本存储操作 *)
let store = Cache_storage.store
let retrieve = Cache_storage.retrieve
let exists = Cache_storage.exists
let delete = Cache_storage.delete
let update_ttl = Cache_storage.update_ttl

(** 批量操作 *)
let store_batch = Cache_batch_ops.store_batch
let retrieve_batch = Cache_batch_ops.retrieve_batch
let delete_batch = Cache_batch_ops.delete_batch

(** 高级管理操作 *)
let clear_all = Cache_advanced_ops.clear_all
let clear_by_pattern = Cache_advanced_ops.clear_by_pattern
let clear_by_tags = Cache_advanced_ops.clear_by_tags
let clear_by_priority = Cache_advanced_ops.clear_by_priority
let expire_stale_entries = Cache_strategy.expire_stale_entries

(** 统计和信息 *)
let get_statistics = Cache_state.get_statistics
let get_metadata = Cache_storage.get_metadata
let list_all_keys = Cache_state.list_all_keys
let list_keys_by_pattern = Cache_state.list_keys_by_pattern
let list_keys_by_tags = Cache_state.list_keys_by_tags
let get_cache_usage_report = Cache_advanced_ops.get_cache_usage_report

(** 事件系统 *)
let register_event_listener = Cache_events.register_event_listener
let unregister_event_listener = Cache_events.unregister_event_listener
let get_recent_events = Cache_events.get_recent_events

(** 高级功能 *)
let preload_data_sources = Cache_advanced_ops.preload_data_sources
let warm_cache_with_pattern = Cache_advanced_ops.warm_cache_with_pattern
let optimize_cache = Cache_advanced_ops.optimize_cache
let defragment_cache = Cache_advanced_ops.defragment_cache
let analyze_access_patterns = Cache_advanced_ops.analyze_access_patterns
let suggest_cache_optimizations = Cache_advanced_ops.suggest_cache_optimizations
let benchmark_cache_performance = Cache_advanced_ops.benchmark_cache_performance
let export_cache_to_file = Cache_advanced_ops.export_cache_to_file
let import_cache_from_file = Cache_advanced_ops.import_cache_from_file
let create_cache_snapshot = Cache_advanced_ops.create_cache_snapshot
let restore_from_snapshot = Cache_advanced_ops.restore_from_snapshot
let validate_cache_integrity = Cache_advanced_ops.validate_cache_integrity
let diagnose_cache_issues = Cache_advanced_ops.diagnose_cache_issues
let get_memory_usage_details = Cache_advanced_ops.get_memory_usage_details
let enable_debug_mode = Cache_state.enable_debug_mode

(** 兼容性接口 *)
let legacy_get = Cache_legacy.legacy_get
let legacy_set = Cache_legacy.legacy_set
let legacy_clear = Cache_legacy.legacy_clear