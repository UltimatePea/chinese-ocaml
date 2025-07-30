(** 数据管理器类型定义模块
    
    统一所有数据管理相关的类型定义，为其他模块提供清晰的类型接口。
    遵循Beta代理建议的<200行模块标准。
                                                           
    @author Alpha, 主要工作代理 - 基于Delta/Beta反馈的改进重构
    @version 2.1 - 模块化架构版本  
    @since 2025-07-30 - Phase 2A 改进重构
    @fix_issue #1791 *)

(** {1 核心数据类型定义} *)

type unified_data_item = {
  character : string;
  category : Poetry_core.Json_core.rhyme_category;
  group : Poetry_core.Json_core.rhyme_group;
  metadata : (string * string) list;
}

type data_source_id =
  | RhymeData of string
  | PoetryData of string
  | ToneData of string
  | WordClassData of string

type query_criteria =
  | ByCharacter of string
  | ByCategory of Poetry_core.Json_core.rhyme_category
  | ByGroup of Poetry_core.Json_core.rhyme_group
  | BySource of data_source_id
  | CompositeQuery of query_criteria list

type 'a data_result = Success of 'a | Error of Poetry_core.Poetry_errors.data_error

(** {1 缓存策略类型} *)

type cache_strategy = {
  enable_cache : bool;
  max_cache_size : int;
  ttl_seconds : float;
  eviction_policy : [ `LRU | `LFU | `FIFO ];
}

type cache_statistics = {
  total_queries : int;
  cache_hits : int;
  cache_misses : int;
  cache_size : int;
  hit_rate : float;
  last_cleanup : float;
}

(** {1 内部缓存条目类型} *)

type cache_entry = { 
  data : unified_data_item list; 
  timestamp : float; 
  access_count : int 
}