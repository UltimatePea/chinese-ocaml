(** 缓存管理器注册表接口 *)

(** {1 类型定义} *)

type cache_strategy =
  | LRU           
  | LFU           
  | FIFO          
  | TTL of float  
  | Custom of (string -> bool)

type cache_priority =
  | Critical      
  | High          
  | Normal        
  | Low           
  | Disposable    

type cache_metadata = {
  key : string;                     
  size_bytes : int;                 
  created_time : float;             
  last_accessed : float;            
  access_count : int;               
  priority : cache_priority;        
  ttl : float option;               
  tags : string list;               
}

type cache_statistics = {
  total_entries : int;              
  total_size_bytes : int;           
  hit_count : int;                  
  miss_count : int;                 
  eviction_count : int;             
  hit_rate : float;                 
  avg_access_time : float;          
  memory_usage_mb : float;          
}

type cache_event =
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

(** {1 核心操作} *)

val initialize : ?max_size_mb:float -> ?max_entries:int -> 
                 ?default_strategy:cache_strategy -> ?_enable_statistics:bool -> unit -> unit

val shutdown : unit -> unit

val is_initialized : unit -> bool

val configure_strategy : string -> cache_strategy -> unit

(** {1 基本存储操作} *)

val store : string -> 'a -> ?priority:cache_priority -> ?ttl:float option -> 
            ?tags:string list -> unit -> bool

val retrieve : string -> 'a cache_result

val exists : string -> bool

val delete : string -> bool

val update_ttl : string -> float -> bool

(** {1 批量操作} *)

val store_batch : (string * 'a * cache_priority option * float option) list -> 
                  (string * bool) list

val retrieve_batch : string list -> (string * 'a cache_result) list

val delete_batch : string list -> (string * bool) list

(** {1 高级管理操作} *)

val clear_all : unit -> int

val clear_by_pattern : string -> int

val clear_by_tags : string list -> int

val clear_by_priority : cache_priority -> int

val expire_stale_entries : ?max_age:float option -> unit -> int

(** {1 统计和信息} *)

val get_statistics : unit -> cache_statistics

val get_metadata : string -> cache_metadata option

val list_all_keys : unit -> string list

val list_keys_by_pattern : string -> string list

val list_keys_by_tags : string list -> string list

val get_cache_usage_report : unit -> (string * int * float * float) list

(** {1 事件系统} *)

val register_event_listener : (cache_event -> unit) -> int

val unregister_event_listener : int -> bool

val get_recent_events : int -> cache_event list

(** {1 高级功能} *)

val preload_data_sources : string list -> int
val warm_cache_with_pattern : string -> int
val optimize_cache : unit -> (string * int * int) list
val defragment_cache : unit -> (int * int)
val analyze_access_patterns : unit -> 'a list
val suggest_cache_optimizations : unit -> (string * string) list
val benchmark_cache_performance : 'a -> (string * float) list
val export_cache_to_file : 'a -> bool
val import_cache_from_file : 'a -> int
val create_cache_snapshot : 'a -> bool
val restore_from_snapshot : 'a -> bool
val validate_cache_integrity : unit -> (bool * string list)
val diagnose_cache_issues : unit -> string
val get_memory_usage_details : unit -> (string * int * float) list
val enable_debug_mode : bool -> unit

(** {1 兼容性接口} *)

val legacy_get : string -> 'a option
val legacy_set : string -> 'a -> unit
val legacy_clear : unit -> unit