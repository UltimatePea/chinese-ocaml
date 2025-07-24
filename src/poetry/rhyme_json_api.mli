(** 韵律JSON API兼容层接口
    
    提供向后兼容的API接口，确保现有代码在模块整合后继续正常工作。
    
    @author 骆言诗词编程团队
    @version 2.0  
    @since 2025-07-24 - Phase 7.1 JSON处理系统整合重构 *)

(** {1 类型定义} *)

(** 韵类定义 *)
type rhyme_category =
  | PingSheng  (** 平声 *)
  | ZeSheng  (** 仄声 *)
  | ShangSheng  (** 上声 *)
  | QuSheng  (** 去声 *)
  | RuSheng  (** 入声 *)

(** 韵组定义 *)
type rhyme_group =
  | AnRhyme  (** 安韵 *)
  | SiRhyme  (** 思韵 *)
  | TianRhyme  (** 天韵 *)
  | WangRhyme  (** 王韵 *)
  | QuRhyme  (** 曲韵 *)
  | YuRhyme  (** 雨韵 *)
  | HuaRhyme  (** 花韵 *)
  | FengRhyme  (** 风韵 *)
  | YueRhyme  (** 月韵 *)
  | XueRhyme  (** 雪韵 *)
  | JiangRhyme  (** 江韵 *)
  | HuiRhyme  (** 辉韵 *)
  | UnknownRhyme  (** 未知韵 *)

(** 异常定义 *)
exception Json_parse_error of string
exception Rhyme_data_not_found of string

(** 韵组数据类型 *)
type rhyme_group_data = {
  category : string;
  characters : string list;
}

(** 韵律数据文件结构 *)
type rhyme_data_file = {
  rhyme_groups : (string * rhyme_group_data) list;
  metadata : (string * string) list;
}

(** {1 兼容性子模块} *)

(** 原 Rhyme_json_types 模块兼容接口 *)
module Types : sig
  type rhyme_category = 
    | PingSheng | ZeSheng | ShangSheng | QuSheng | RuSheng
  
  type rhyme_group = 
    | AnRhyme | SiRhyme | TianRhyme | WangRhyme | QuRhyme 
    | YuRhyme | HuaRhyme | FengRhyme | YueRhyme | XueRhyme 
    | JiangRhyme | HuiRhyme | UnknownRhyme
  
  exception Json_parse_error of string
  exception Rhyme_data_not_found of string
  
  type rhyme_group_data = {
    category : string;
    characters : string list;
  }
  
  type rhyme_data_file = {
    rhyme_groups : (string * rhyme_group_data) list;
    metadata : (string * string) list;
  }
  
  val string_to_rhyme_category : string -> rhyme_category
  val string_to_rhyme_group : string -> rhyme_group
end

(** 原 Rhyme_json_cache 模块兼容接口 *)
module Cache : sig
  val cache_ttl : float
  val is_cache_valid : unit -> bool
  val get_cached_data : unit -> rhyme_data_file
  val set_cached_data : rhyme_data_file -> unit
  val clear_cache : unit -> unit
  val refresh_cache : rhyme_data_file -> unit
end

(** 原 Rhyme_json_parser 模块兼容接口 *)
module Parser : sig
  val parse_nested_json : string -> (string * rhyme_group_data) list
end

(** 原 Rhyme_json_io 模块兼容接口 *)
module Io : sig
  val default_data_file : string
  val load_rhyme_data_from_file : ?filename:string -> unit -> rhyme_data_file
  val get_rhyme_data : ?force_reload:bool -> unit -> rhyme_data_file
end

(** 原 Rhyme_json_access 模块兼容接口 *)
module Access : sig
  val get_all_rhyme_groups : unit -> (string * rhyme_group_data) list
  val get_rhyme_group_characters : string -> string list
  val get_rhyme_group_category : string -> rhyme_category
  val get_rhyme_mappings : unit -> (string * (rhyme_category * rhyme_group)) list
  val get_data_statistics : unit -> (int * int) option
  val print_statistics : unit -> unit
end

(** 原 Rhyme_json_fallback 模块兼容接口 *)
module Fallback : sig
  val use_fallback_data : unit -> rhyme_data_file
end

(** {1 主要API - 完全兼容原接口} *)

(** 类型转换函数 *)
val string_to_rhyme_category : string -> rhyme_category
val string_to_rhyme_group : string -> rhyme_group

(** 获取韵律数据（兼容原有接口） *)
val get_rhyme_data : ?force_reload:bool -> unit -> rhyme_data_file option

(** 获取所有韵组（兼容原有接口） *)
val get_all_rhyme_groups : unit -> (string * rhyme_group_data) list

(** 获取韵组字符（兼容原有接口） *)
val get_rhyme_group_characters : string -> string list

(** 获取韵组韵类（兼容原有接口） *)
val get_rhyme_group_category : string -> rhyme_category

(** 获取韵律映射（兼容原有接口） *)
val get_rhyme_mappings : unit -> (string * (rhyme_category * rhyme_group)) list

(** 获取统计信息（兼容原有接口） *)
val get_data_statistics : unit -> (int * int) option

(** 打印统计信息（兼容原有接口） *)
val print_statistics : unit -> unit

(** 缓存管理（兼容原有接口） *)
val is_cache_valid : unit -> bool
val clear_cache : unit -> unit
val refresh_cache : rhyme_data_file -> unit

(** 文件操作（兼容原有接口） *)
val load_rhyme_data_from_file : ?filename:string -> unit -> rhyme_data_file

(** 降级处理（兼容原有接口） *)
val use_fallback_data : unit -> rhyme_data_file

(** JSON解析（兼容原有接口） *)
val parse_nested_json : string -> (string * rhyme_group_data) list