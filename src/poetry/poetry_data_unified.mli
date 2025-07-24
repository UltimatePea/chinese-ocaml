(** 诗词数据统一加载器 - 整合版本
    
    整合了原本分散在多个模块中的数据加载功能，包括：
    - 多种数据源支持 (JSON文件、静态数据、降级数据)
    - 统一缓存管理
    - 数据源注册和优先级管理
    - 统一数据库构建和查询
    
    使用统一的 Poetry_core_types，提供一致的数据接口。
    
    @author 骆言诗词编程团队
    @version 2.0 - Issue #1096 技术债务整理
    @since 2025-07-24
*)

open Poetry_core_types

(** {1 数据源管理} *)

(** 数据源类型 *)
type data_source = 
  | JsonFile of string  (** JSON文件路径 *)
  | FallbackData  (** 降级数据 *)
  | StaticData of (string * rhyme_group_data) list  (** 静态数据 *)

(** 数据源条目 *)
type data_source_entry = {
  name : string;  (** 数据源名称 *)
  source : data_source;  (** 数据源 *)
  priority : int;  (** 优先级，数值越大优先级越高 *)
  description : string;  (** 描述信息 *)
}

(** 数据错误类型 *)
type data_error = 
  | FileNotFound of string  (** 文件未找到 *)
  | ParseError of string  (** 解析错误 *)
  | InvalidData of string  (** 数据无效 *)
  | CacheError of string  (** 缓存错误 *)

exception DataError of data_error
(** 数据处理异常 *)

val format_error : data_error -> string
(** 格式化错误信息 *)

(** {1 数据源注册接口} *)

val register_source : string -> data_source -> ?priority:int -> string -> unit
(** 注册数据源
    @param name 数据源名称
    @param source 数据源
    @param priority 优先级，默认0
    @param description 描述信息 *)

val get_registered_sources : unit -> data_source_entry list
(** 获取所有已注册的数据源 *)

val get_source_names : unit -> string list
(** 获取所有数据源名称 *)

(** {1 数据加载接口} *)

val load_data : string -> rhyme_data_file
(** 从指定数据源加载数据
    @param source_name 数据源名称
    @return 韵律数据文件
    @raise DataError 加载失败时抛出异常 *)

val load_data_safe : string -> rhyme_data_file
(** 安全加载数据，失败时使用降级数据
    @param source_name 数据源名称
    @return 韵律数据文件，保证不会失败 *)

(** {1 统一数据库接口} *)

(** 统一数据库类型 *)
type unified_database = {
  char_to_rhyme : (string, rhyme_category * rhyme_group) Hashtbl.t;
  rhyme_groups : (string * rhyme_group_data) list;
  source_info : string list;
}

val build_unified_database : unit -> unified_database
(** 构建统一数据库
    @return 包含所有数据源的统一数据库 *)

val get_unified_database : unit -> unified_database
(** 获取统一数据库（带缓存）
    @return 统一数据库实例 *)

(** {1 查询接口} *)

val lookup_char : string -> (rhyme_category * rhyme_group) option
(** 查找字符的韵律信息
    @param char 要查找的字符
    @return Some (韵类, 韵组) 或 None *)

val get_statistics : unit -> int * int
(** 获取数据库统计信息
    @return (韵组总数, 字符总数) *)

(** {1 缓存管理接口} *)

val clear_cache : unit -> unit
(** 清空所有缓存 *)

val refresh_data : unit -> unit
(** 刷新所有数据，清空缓存并重新构建数据库 *)

(** {1 标准数据源} *)

val register_standard_sources : unit -> unit
(** 注册标准数据源（自动调用，包括韵律数据、声调数据等） *)