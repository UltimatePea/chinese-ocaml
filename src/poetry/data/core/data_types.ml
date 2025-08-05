(** 数据管理核心类型定义模块
    
    从 data_manager.ml 中提取的核心类型定义，提供统一的数据结构规范。
    这个模块专注于类型定义，不包含任何实现逻辑。
                                                           
    @author Charlie, 规划代理 - 负责架构重构
    @refactored_from data_manager.ml
    @fix_issue #1727 *)

(* 抑制未使用类型和字段的警告 - 这些是接口定义的一部分 *)
[@@@warning "-34-37-69-32"]

(** {1 核心数据类型定义} *)

type unified_data_item = {
  character : string;  (** 字符内容 *)
  category : string;  (** 韵类 - 简化为字符串类型 *)
  group : string;  (** 韵组 - 简化为字符串类型 *)
  metadata : (string * string) list;  (** 元数据键值对 *)
}
(** 统一数据项类型 - 标准化的数据表示 *)

(** 数据源标识符 - 用于区分不同类型的数据源 *)
type data_source_id =
  | RhymeData of string  (** 韵律数据源 *)
  | PoetryData of string  (** 诗词数据源 *)
  | ToneData of string  (** 声调数据源 *)
  | WordClassData of string  (** 词类数据源 *)

(** 查询条件 - 支持多种查询方式的统一接口 *)
type query_criteria =
  | ByCharacter of string  (** 按字符查询 *)
  | ByCategory of string  (** 按韵类查询 - 简化为字符串 *)
  | ByGroup of string  (** 按韵组查询 - 简化为字符串 *)
  | BySource of data_source_id  (** 按数据源查询 *)
  | CompositeQuery of query_criteria list  (** 复合查询条件 *)

(** 数据操作结果类型 - 统一的错误处理 *)
type 'a data_result = Success of 'a | Error of string (* 简化错误处理为字符串 *)

(** {1 缓存策略类型} *)

type cache_strategy = {
  enable_cache : bool;  (** 是否启用缓存 *)
  max_cache_size : int;  (** 最大缓存条目数 *)
  ttl_seconds : float;  (** 缓存生存时间(秒) *)
  eviction_policy : [ `LRU | `LFU | `FIFO ];  (** 缓存淘汰策略 *)
}
(** 缓存策略配置 *)

type cache_statistics = {
  total_queries : int;  (** 总查询次数 *)
  cache_hits : int;  (** 缓存命中次数 *)
  cache_misses : int;  (** 缓存未命中次数 *)
  cache_size : int;  (** 当前缓存大小 *)
  hit_rate : float;  (** 命中率 *)
  last_cleanup : float;  (** 上次清理时间 *)
}
(** 缓存统计信息 *)

type index_statistics = {
  character_index_size : int;  (** 字符索引大小 *)
  group_index_size : int;  (** 韵组索引大小 *)
  category_index_size : int;  (** 韵类索引大小 *)
  indexed_sources : data_source_id list;  (** 已建立索引的数据源 *)
}
(** 索引统计信息 *)

type source_statistics = {
  total_sources : int;  (** 总数据源数量 *)
  source_details : (data_source_id * int * int * float) list;  (** 数据源详情列表: (ID, 优先级, 数据数量, 注册时间) *)
}
(** 数据源统计信息 *)

type single_source_statistics = {
  source_id : data_source_id;  (** 数据源ID *)
  data_count : int;  (** 数据数量 *)
  priority : int;  (** 优先级 *)
  description : string;  (** 描述 *)
  register_time : float;  (** 注册时间 *)
}
(** 单个数据源统计信息 *)

type data_statistics = {
  cache_statistics : cache_statistics;  (** 缓存统计 *)
  query_statistics : index_statistics;  (** 查询索引统计 *)
  source_statistics : source_statistics;  (** 数据源统计 *)
}
(** 综合数据统计信息 *)

(** {1 数据源类型} *)

type data_source_info = {
  source_id : data_source_id;  (** 数据源ID *)
  loader : unit -> unified_data_item list data_result;  (** 数据加载器 *)
  priority : int;  (** 优先级 *)
  description : string;  (** 描述信息 *)
}
(** 数据源信息 *)

(** 数据导出格式 *)
type export_format = JSON  (** JSON格式 *) | CSV  (** CSV格式 *) | XML  (** XML格式 *)

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
  | BySource src -> "src:" ^ string_of_data_source_id src
  | CompositeQuery lst -> "comp:[" ^ String.concat ";" (List.map string_of_query_criteria lst) ^ "]"

(** 创建默认缓存策略 *)
let default_cache_strategy =
  { enable_cache = true; max_cache_size = 10000; ttl_seconds = 3600.0; eviction_policy = `LRU }

(** 创建空的缓存统计 *)
let empty_cache_statistics =
  {
    total_queries = 0;
    cache_hits = 0;
    cache_misses = 0;
    cache_size = 0;
    hit_rate = 0.0;
    last_cleanup = Unix.time ();
  }
