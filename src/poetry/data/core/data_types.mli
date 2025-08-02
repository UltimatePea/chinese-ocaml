(** 数据管理核心类型定义模块接口
    
    从 data_manager.ml 中提取的核心类型定义，提供统一的数据结构规范。
    这个模块专注于类型定义，不包含任何实现逻辑。
                                                           
    @author Charlie, 规划代理 - 负责架构重构
    @refactored_from data_manager.ml
    @fix_issue #1727 *)

(** {1 核心数据类型定义} *)

(** 统一数据项类型 - 标准化的数据表示 *)
type unified_data_item = {
  character : string;  (** 字符内容 *)
  category : Poetry_core.Json_core.rhyme_category;  (** 韵类 *)
  group : Poetry_core.Json_core.rhyme_group;  (** 韵组 *)
  metadata : (string * string) list;  (** 元数据键值对 *)
}

(** 数据源标识符 - 用于区分不同类型的数据源 *)
type data_source_id =
  | RhymeData of string  (** 韵律数据源 *)
  | PoetryData of string  (** 诗词数据源 *)
  | ToneData of string  (** 声调数据源 *)
  | WordClassData of string  (** 词类数据源 *)

(** 查询条件 - 支持多种查询方式的统一接口 *)
type query_criteria =
  | ByCharacter of string  (** 按字符查询 *)
  | ByCategory of Poetry_core.Json_core.rhyme_category  (** 按韵类查询 *)
  | ByGroup of Poetry_core.Json_core.rhyme_group  (** 按韵组查询 *)
  | BySource of data_source_id  (** 按数据源查询 *)
  | CompositeQuery of query_criteria list  (** 复合查询条件 *)

(** 数据操作结果类型 - 统一的错误处理 *)
type 'a data_result = Success of 'a | Error of Poetry_core.Poetry_errors.data_error

(** {1 缓存策略类型} *)

(** 缓存策略配置 *)
type cache_strategy = {
  enable_cache : bool;  (** 是否启用缓存 *)
  max_cache_size : int;  (** 最大缓存条目数 *)
  ttl_seconds : float;  (** 缓存生存时间(秒) *)
  eviction_policy : [ `LRU | `LFU | `FIFO ];  (** 缓存淘汰策略 *)
}

(** 缓存统计信息 *)
type cache_statistics = {
  total_queries : int;  (** 总查询次数 *)
  cache_hits : int;  (** 缓存命中次数 *)
  cache_misses : int;  (** 缓存未命中次数 *)
  cache_size : int;  (** 当前缓存大小 *)
  hit_rate : float;  (** 命中率 *)
  last_cleanup : float;  (** 上次清理时间 *)
}