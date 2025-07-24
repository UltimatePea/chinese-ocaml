(** 诗词JSON处理统一模块 - 整合版本
    
    整合了原本分散在14个rhyme_json_*模块中的功能，包括：
    - JSON解析和数据加载
    - 缓存管理
    - 文件I/O操作  
    - 降级数据处理
    - 数据访问接口
    
    使用统一的 Poetry_core_types，避免类型重复定义。
    
    @author 骆言诗词编程团队
    @version 2.0 - Issue #1096 技术债务整理
    @since 2025-07-24
*)

open Poetry_core_types

(** {1 主要数据访问接口} *)

val get_data : ?force_reload:bool -> unit -> rhyme_data_file
(** 获取韵律数据，支持缓存。
    @param force_reload 是否强制重新加载，默认false
    @return 韵律数据文件结构
    @raise Json_parse_error JSON解析失败
    @raise Rhyme_data_not_found 数据文件未找到 *)

val get_data_safe : ?force_reload:bool -> unit -> rhyme_data_file
(** 安全获取韵律数据，失败时自动使用降级数据。
    @param force_reload 是否强制重新加载，默认false
    @return 韵律数据文件结构，保证不会失败 *)

val get_all_groups : unit -> (string * rhyme_group_data) list
(** 获取所有韵组数据
    @return 韵组名称与数据的列表 *)

val get_group_characters : string -> string list
(** 获取指定韵组包含的字符列表
    @param group_name 韵组名称
    @return 字符列表，未找到时返回空列表 *)

val get_group_category : string -> rhyme_category
(** 获取指定韵组的韵类
    @param group_name 韵组名称
    @return 韵类，未找到时返回PingSheng *)

(** {1 字符查询接口} *)

val get_char_mappings : unit -> (string * (rhyme_category * rhyme_group)) list
(** 获取字符到韵律信息的映射关系
    @return (字符, (韵类, 韵组)) 的列表 *)

val lookup_char : string -> (rhyme_category * rhyme_group) option
(** 查找指定字符的韵律信息
    @param char 要查找的字符
    @return Some (韵类, 韵组) 或 None *)

(** {1 统计和调试接口} *)

val get_statistics : unit -> int * int
(** 获取数据统计信息
    @return (韵组总数, 字符总数) *)

val print_statistics : unit -> unit
(** 打印韵律数据统计信息到标准输出 *)

(** {1 缓存管理接口} *)

val clear_cache : unit -> unit
(** 清空缓存 *)

val refresh_cache : rhyme_data_file -> unit
(** 刷新缓存数据
    @param data 新的韵律数据 *)