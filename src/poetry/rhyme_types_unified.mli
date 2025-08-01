(** 韵律类型统一定义模块接口 - 整合所有重复类型定义
    
    Author: Whisky, PR Worker
    @version 1.0 - Poetry韵律类型统一整合
    @since 2025-08-01
    @implements Issue #1999 - Poetry韵律模块统一整合实施 *)

(** {1 核心韵律类型定义} *)

(** 韵律条目结构 - 统一所有变体 *)
type unified_rhyme_entry = {
  character: string;              (** 韵字 *)
  rhyme_group: rhyme_group;       (** 韵组 *)
  tone_category: rhyme_category;  (** 声调类别 *)
  frequency: float;               (** 使用频率 0.0-1.0 *)
  variants: string list;          (** 变体字列表 *)
  phonetic: string option;        (** 拼音标注 (可选) *)
  source_module: string;          (** 数据来源模块 *)
  metadata: entry_metadata;       (** 扩展元数据 *)
}

(** 韵组定义 *)
and rhyme_group = 
  | AnRhyme      (** 安韵 *)
  | SiRhyme      (** 思韵 *)  
  | TianRhyme    (** 天韵 *)
  | FengRhyme    (** 风韵 *)
  | YuRhyme      (** 鱼韵 *)
  | WangRhyme    (** 王韵 *)
  | HuaRhyme     (** 花韵 *)
  | HuiRhyme     (** 辉韵 *)
  | JiangRhyme   (** 江韵 *)
  | YueRhyme     (** 月韵 *)
  | QuRhyme      (** 曲韵 *)
  | XueRhyme     (** 雪韵 *)
  | UnknownRhyme (** 未知韵 *)

(** 声调类别 *)
and rhyme_category =
  | PingSheng    (** 平声 *)
  | ZeSheng      (** 仄声 *)
  | ShangSheng   (** 上声 *)
  | QuSheng      (** 去声 *) 
  | RuSheng      (** 入声 *)

(** 条目元数据 *)
and entry_metadata = {
  created_at: float;             (** 创建时间戳 *)
  last_updated: float;           (** 最后更新时间戳 *)
  usage_count: int;              (** 使用次数统计 *)
  quality_score: float;          (** 质量评分 0.0-1.0 *)
  tags: string list;             (** 标签列表 *)
}

(** {2 数据库和索引类型} *)

(** 统一韵律数据库结构 *)  
type unified_rhyme_database = {
  entries: unified_rhyme_entry list;                                     (** 所有条目 *)
  lookup_table: (string, unified_rhyme_entry) Hashtbl.t;               (** 字符查找表 *)
  group_index: (rhyme_group, unified_rhyme_entry list) Hashtbl.t;      (** 韵组索引 *)
  tone_index: (rhyme_category, unified_rhyme_entry list) Hashtbl.t;    (** 声调索引 *)
  frequency_index: (float, unified_rhyme_entry list) Hashtbl.t;        (** 频率索引 *)
  stats: database_statistics;                                           (** 统计信息 *)
  config: database_config;                                              (** 配置信息 *)
}

(** 数据库统计信息 *)
and database_statistics = {
  total_entries: int;                             
  ping_sheng_count: int;                         
  ze_sheng_count: int;                           
  ru_sheng_count: int;                           
  group_distribution: (rhyme_group * int) list;  
  frequency_distribution: (float * int) list;    
  last_updated: float;                           
  cache_hit_rate: float;                         
}

(** 数据库配置 *)
and database_config = {
  enable_caching: bool;                          
  cache_size_limit: int;                         
  auto_warmup: bool;                             
  performance_monitoring: bool;                  
  compatibility_mode: bool;                      
}

(** {3 查询和结果类型} *)

(** 查询参数类型 *)
type query_params = {
  character: string option;                      
  rhyme_group: rhyme_group option;              
  tone_category: rhyme_category option;         
  min_frequency: float option;                  
  max_results: int option;                      
  sort_by: sort_criteria;                       
}

(** 排序标准 *)
and sort_criteria =
  | ByFrequency of sort_order                   
  | ByGroup of sort_order                       
  | ByTone of sort_order                        
  | ByUsage of sort_order                       

(** 排序顺序 *)
and sort_order = Ascending | Descending

(** 查询结果类型 *)
type query_result = {
  entries: unified_rhyme_entry list;            
  total_count: int;                             
  query_time: float;                            
  from_cache: bool;                             
  suggestion: string list;                      
}

(** {4 性能监控类型} *)

(** 性能统计 *)
type performance_stats = {
  mutable total_queries: int;                   
  mutable cache_hits: int;                      
  mutable cache_misses: int;                    
  mutable avg_query_time: float;                
  mutable peak_memory_usage: int;               
  mutable last_reset: float;                    
}

(** 基准测试结果 *)
type benchmark_result = {
  test_name: string;                            
  iterations: int;                              
  total_time: float;                            
  avg_time_per_op: float;                      
  ops_per_second: float;                       
  memory_usage: int;                           
}

(** {5 错误和异常类型} *)

(** 韵律系统错误类型 *)
type rhyme_error =
  | CharacterNotFound of string                 
  | InvalidRhymeGroup of string                
  | InvalidToneCategory of string              
  | DatabaseCorrupted of string                
  | CacheError of string                       
  | QueryTimeout of float                      
  | CompatibilityError of string               

(** 韵律系统异常 *)
exception RhymeSystemError of rhyme_error

(** {6 配置和选项类型} *)

(** 系统配置 *)
type system_config = {
  data_source: data_source_config;              
  performance: performance_config;              
  compatibility: compatibility_config;          
  logging: logging_config;                      
}

and data_source_config = {
  primary_source: string;                       
  fallback_sources: string list;                
  auto_update: bool;                           
  validation_enabled: bool;                     
}

and performance_config = {
  enable_caching: bool;                         
  cache_size: int;                             
  preload_common: bool;                        
  benchmark_mode: bool;                        
}

and compatibility_config = {
  legacy_api_support: bool;                     
  strict_type_checking: bool;                   
  migration_warnings: bool;                     
}

and logging_config = {
  level: log_level;                            
  output_file: string option;                  
  performance_logging: bool;                   
}

and log_level = Debug | Info | Warning | Error | Critical

(** {7 向后兼容类型别名} *)

(** 兼容 rhyme_types.ml *)
type rhyme_entry = unified_rhyme_entry
type rhyme_database = unified_rhyme_database  

(** 兼容 rhyme_core_types.ml *)
type core_rhyme_entry = unified_rhyme_entry
type rhyme_data_entry = unified_rhyme_entry

(** 兼容 rhyme_json_types.ml *)
type json_rhyme_entry = unified_rhyme_entry
type json_rhyme_data = unified_rhyme_database

(** {8 类型转换函数} *)

(** 将字符串转换为韵组 *)
val string_to_rhyme_group : string -> rhyme_group option

(** 将韵组转换为字符串 *)
val rhyme_group_to_string : rhyme_group -> string

(** 将字符串转换为声调类别 *)
val string_to_tone_category : string -> rhyme_category option

(** 将声调类别转换为字符串 *)
val tone_category_to_string : rhyme_category -> string

(** {9 工具函数} *)

(** 创建默认元数据 *)
val create_default_metadata : unit -> entry_metadata

(** 创建默认数据库配置 *)
val create_default_db_config : unit -> database_config

(** 创建默认系统配置 *)
val create_default_system_config : unit -> system_config

(** 验证韵律条目 *)
val validate_rhyme_entry : unified_rhyme_entry -> bool