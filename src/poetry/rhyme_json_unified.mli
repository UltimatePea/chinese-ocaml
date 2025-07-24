(** 韵律JSON统一处理模块接口 - 诗词模块整合优化 Phase 5.2
 
    统一的韵律数据JSON处理接口，整合原有多个 rhyme_json_* 模块功能。
    
    @author 骆言诗词编程团队
    @version 3.0 - 整合版本
    @since 2025-07-24 - Phase 5.2 诗词模块整合优化 *)

open Rhyme_json_types

(** {1 异常类型} *)

exception Rhyme_data_not_found of string
(** 韵律数据未找到异常 *)

exception Json_parse_error of string
(** JSON解析错误异常 *)

exception Cache_error of string
(** 缓存错误异常 *)

(** {1 缓存管理模块} *)

module Cache : sig
  (** 清空缓存 *)
  val clear_cache : unit -> unit

  (** 获取缓存统计信息 *)
  val get_cache_stats : unit -> int * int * float
  (** 返回 (命中次数, 未命中次数, 最后更新时间) *)
end

(** {1 JSON解析模块} *)

module Parser : sig
  (** 清理JSON字符串 *)
  val clean_json_string : string -> string

  (** 解析韵律数据JSON *)
  val parse_rhyme_json : string -> rhyme_data_file
end

(** {1 I/O操作模块} *)

module Io : sig
  (** 默认数据文件路径 *)
  val default_rhyme_data_path : string

  (** 读取JSON文件 *)
  val read_json_file : string -> string

  (** 获取韵律数据（带缓存） *)
  val get_rhyme_data : ?force_reload:bool -> unit -> rhyme_data_file
end

(** {1 数据访问模块} *)

module Access : sig
  (** 获取所有韵组 *)
  val get_all_rhyme_groups : unit -> (string * rhyme_group_data) list

  (** 获取指定韵组的字符列表 *)
  val get_rhyme_group_characters : string -> string list

  (** 获取指定韵组的韵类 *)
  val get_rhyme_group_category : string -> rhyme_category

  (** 获取韵律映射关系 *)
  val get_rhyme_mappings : unit -> (string * (rhyme_category * rhyme_group)) list

  (** 获取数据统计 *)
  val get_data_statistics : unit -> string

  (** 打印统计信息 *)
  val print_statistics : unit -> unit
end

(** {1 降级处理模块} *)

module Fallback : sig
  (** 使用内置的降级数据 *)
  val use_fallback_data : unit -> rhyme_data_file
end

(** {1 主要API - 统一接口} *)

(** 获取韵律数据（兼容原有接口） *)
val get_rhyme_data : ?force_reload:bool -> unit -> rhyme_data_file option

(** 获取所有韵组（兼容原有接口） *)
val get_all_rhyme_groups : unit -> (string * rhyme_group_data) list

(** 获取韵组字符（兼容原有接口） *)
val get_rhyme_group_characters : string -> string list

(** 获取韵组类别（兼容原有接口） *)
val get_rhyme_group_category : string -> rhyme_category

(** 获取韵律映射（兼容原有接口） *)
val get_rhyme_mappings : unit -> (string * (rhyme_category * rhyme_group)) list

(** 获取数据统计（兼容原有接口） *)
val get_data_statistics : unit -> string

(** 打印统计信息（兼容原有接口） *)
val print_statistics : unit -> unit

(** 使用降级数据（兼容原有接口） *)
val use_fallback_data : unit -> unit

(** 清空缓存（新增接口） *)
val clear_cache : unit -> unit

(** 获取缓存统计（新增接口） *)
val get_cache_stats : unit -> int * int * float