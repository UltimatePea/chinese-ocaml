(** 数据管理核心类型定义模块
    
    从 data_manager.ml 中提取的核心类型定义，提供统一的数据结构规范。
    这个模块专注于类型定义，不包含任何实现逻辑。
                                                           
    @author Charlie, 规划代理 - 负责架构重构
    @refactored_from data_manager.ml
    @fix_issue #1727 *)

(** {1 核心数据类型定义} *)

(** 统一数据项类型 - 标准化的数据表示 *)
type unified_data_item = {
  character : string; (** 字符内容 *)
  category : Poetry_core.Json_core.rhyme_category; (** 韵类 *)
  group : Poetry_core.Json_core.rhyme_group; (** 韵组 *)
  metadata : (string * string) list; (** 元数据键值对 *)
}

(** 数据源标识符 - 用于区分不同类型的数据源 *)
type data_source_id =
  | RhymeData of string (** 韵律数据源 *)
  | PoetryData of string (** 诗词数据源 *)
  | ToneData of string (** 声调数据源 *)
  | WordClassData of string (** 词类数据源 *)

(** 查询条件 - 支持多种查询方式的统一接口 *)
type query_criteria =
  | ByCharacter of string (** 按字符查询 *)
  | ByCategory of Poetry_core.Json_core.rhyme_category (** 按韵类查询 *)
  | ByGroup of Poetry_core.Json_core.rhyme_group (** 按韵组查询 *)
  | BySource of data_source_id (** 按数据源查询 *)
  | CompositeQuery of query_criteria list (** 复合查询条件 *)

(** 数据操作结果类型 - 统一的错误处理 *)
type 'a data_result = 
  | Success of 'a 
  | Error of Poetry_core.Poetry_errors.data_error

(** {1 缓存策略类型} *)

(** 缓存策略配置 *)
type cache_strategy = {
  enable_cache : bool; (** 是否启用缓存 *)
  max_cache_size : int; (** 最大缓存条目数 *)
  ttl_seconds : float; (** 缓存生存时间(秒) *)
  eviction_policy : [ `LRU | `LFU | `FIFO ]; (** 缓存淘汰策略 *)
}

(** 缓存统计信息 *)
type cache_statistics = {
  total_queries : int; (** 总查询次数 *)
  cache_hits : int; (** 缓存命中次数 *)
  cache_misses : int; (** 缓存未命中次数 *)
  cache_size : int; (** 当前缓存大小 *)
  hit_rate : float; (** 命中率 *)
  last_cleanup : float; (** 上次清理时间 *)
}

(** {1 数据源类型} *)

(** 数据源信息 *)
type data_source_info = {
  source_id : data_source_id; (** 数据源ID *)
  loader : unit -> unified_data_item list data_result; (** 数据加载器 *)
  priority : int; (** 优先级 *)
  description : string; (** 描述信息 *)
}

(** 数据导出格式 *)
type export_format = 
  | JSON (** JSON格式 *)
  | CSV (** CSV格式 *)
  | XML (** XML格式 *)

(** {1 工具函数} *)

(** 将数据源ID转换为字符串表示 *)
let string_of_data_source_id = function
  | RhymeData s -> "rhyme:" ^ s
  | PoetryData s -> "poetry:" ^ s
  | ToneData s -> "tone:" ^ s
  | WordClassData s -> "word:" ^ s

(** 将查询条件转换为字符串表示(用于缓存键生成) *)
let rec string_of_query_criteria = function
  | ByCharacter s -> "char:" ^ s
  | ByCategory cat -> "cat:" ^ (Obj.repr cat |> Obj.tag |> string_of_int)
  | ByGroup grp -> "grp:" ^ (Obj.repr grp |> Obj.tag |> string_of_int)
  | BySource src -> "src:" ^ (string_of_data_source_id src)
  | CompositeQuery lst -> 
      "comp:[" ^ String.concat ";" (List.map string_of_query_criteria lst) ^ "]"

(** 创建默认缓存策略 *)
let default_cache_strategy = {
  enable_cache = true;
  max_cache_size = 10000;
  ttl_seconds = 3600.0;
  eviction_policy = `LRU;
}

(** 创建空的缓存统计 *)
let empty_cache_statistics = {
  total_queries = 0;
  cache_hits = 0;
  cache_misses = 0;
  cache_size = 0;
  hit_rate = 0.0;
  last_cleanup = Unix.time ();
}