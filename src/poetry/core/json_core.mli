(** Poetry JSON处理统一核心接口 - Wave 2 实施
    
    @author Alpha, Primary Worker Agent
    @version 2.0 - Wave 2 统一版本
    @since 2025-07-28 - Poetry Phase 3 Wave 2
    @fix_issue #1548 *)

(** {1 核心类型定义} *)

(** 重新导出统一类型以保持兼容性 *)
type rhyme_category = Rhyme_core_types.rhyme_category
type rhyme_group = Rhyme_core_types.rhyme_group  
type rhyme_data_item = Rhyme_core_types.rhyme_data_item

(** {1 JSON专用类型定义} *)

(** JSON解析异常 *)
exception Json_parse_error of string

(** 韵律数据未找到异常 *)  
exception Rhyme_data_not_found of string

(** 缓存操作异常 *)
exception Cache_error of string

(** 韵组数据结构 *)
type rhyme_group_data = {
  category : string;        (** 韵类名称 *)
  characters : string list; (** 该韵组包含的字符列表 *)
}

(** 韵律数据文件结构 *)
type rhyme_data_file = {
  rhyme_groups : (string * rhyme_group_data) list; (** 韵组映射 *)
  metadata : (string * string) list;               (** 元数据信息 *)
}

(** {1 缓存管理模块} *)

module Cache : sig
  (** 检查缓存是否有效 *)
  val is_cache_valid : unit -> bool
  
  (** 获取缓存数据 *)
  val get_cached_data : unit -> rhyme_data_file option
  
  (** 设置缓存数据 *)
  val set_cached_data : rhyme_data_file -> unit
  
  (** 清空缓存 *)
  val clear_cache : unit -> unit
  
  (** 获取缓存统计 (命中次数, 未命中次数, 最后修改时间) *)
  val get_cache_stats : unit -> int * int * float
  
  (** 设置缓存TTL *)
  val set_cache_ttl : float -> unit
end

(** {1 JSON解析器模块} *)

module Parser : sig
  (** 清理JSON字符串 *)
  val clean_json_string : string -> string
  
  (** 解析韵律数据JSON *)
  val parse_rhyme_json : string -> rhyme_data_file
  
  (** 解析简化JSON格式（向后兼容） *)
  val parse_simple_json : string -> rhyme_data_file
end

(** {1 I/O操作模块} *)

module Io : sig
  (** 默认数据文件路径 *)
  val default_rhyme_data_path : string
  
  (** 备选数据文件路径 *)
  val fallback_paths : string list
  
  (** 安全读取文件内容 *)
  val safe_read_file : string -> string
  
  (** 从多个路径尝试加载数据 *)
  val load_from_paths : string list -> rhyme_data_file
  
  (** 获取韵律数据（带缓存） *)
  val get_rhyme_data : ?force_reload:bool -> unit -> rhyme_data_file
end

(** {1 降级处理模块} *)

module Fallback : sig
  (** 内置降级韵律数据 *)
  val fallback_rhyme_data : (string * rhyme_group_data) list
  
  (** 使用降级数据 *)
  val use_fallback_data : unit -> rhyme_data_file
end

(** {1 类型转换函数} *)

(** 字符串转韵类 *)
val string_to_rhyme_category : string -> rhyme_category option

(** 字符串转韵组 *)
val string_to_rhyme_group : string -> rhyme_group option

(** {1 统一API接口} *)

(** 获取韵律数据（安全版本，带降级处理） *)
val get_rhyme_data_safe : ?force_reload:bool -> unit -> rhyme_data_file option

(** 获取所有韵组 *)
val get_all_rhyme_groups : ?force_reload:bool -> unit -> (string * rhyme_group_data) list

(** 获取指定韵组的字符列表 *)
val get_rhyme_group_characters : ?force_reload:bool -> string -> string list

(** 获取指定韵组的韵类 *)
val get_rhyme_group_category : ?force_reload:bool -> string -> rhyme_category

(** 获取韵律映射关系 *)
val get_rhyme_mappings : ?force_reload:bool -> unit -> (string * (rhyme_category * rhyme_group)) list

(** 获取数据统计信息 (总韵组数, 总字符数, 缓存命中, 缓存未命中, 最后修改时间) *)
val get_data_statistics : ?force_reload:bool -> unit -> (int * int * int * int * float) option

(** 打印统计信息 *)
val print_statistics : ?force_reload:bool -> unit -> unit

(** 清空缓存 *)
val clear_cache : unit -> unit

(** 获取缓存统计 *)
val get_cache_stats : unit -> int * int * float

(** 设置缓存TTL *)
val set_cache_ttl : float -> unit