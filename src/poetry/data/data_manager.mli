(** 统一数据管理器API接口 - 模块化重构版本
    
    基于Delta/Beta代理质量标准的完整重构实现，将原589行巨型模块
    重构为薄API层，使用专门的子模块提供功能。
                                                           
    @author Alpha, 主要工作代理 - 响应Delta/Beta严厉批评
    @version 3.0 - 模块化API重构版本
    @since 2025-07-30 - Phase 2A 完整重构完成
    @fix_issue #1791 *)

(** {1 重新导出类型定义} *)

include module type of Data_manager_types

(** {1 核心查询API} *)

val query_data : query_criteria -> unified_data_item list data_result
(** 根据查询条件获取数据 *)

val batch_query : query_criteria list -> unified_data_item list list data_result
(** 批量查询数据 *)

(** {1 数据源管理接口} *)

val register_data_source : data_source_id -> (unit -> unified_data_item list data_result) -> ?priority:int -> string -> unit data_result
(** 注册数据源 *)

val get_registered_sources : unit -> (data_source_id * string * int) list
(** 获取已注册的数据源列表 *)

val unregister_data_source : data_source_id -> unit data_result
(** 取消注册数据源 *)

(** {1 直接查找接口} *)

val lookup_by_character : string -> unified_data_item option data_result
(** 按字符查找 *)

val lookup_by_group : Poetry_core.Json_core.rhyme_group -> string list data_result
(** 按韵组查找字符列表 *)

val lookup_by_category : Poetry_core.Json_core.rhyme_category -> string list data_result
(** 按韵类查找字符列表 *)

(** {1 缓存管理接口} *)

val get_cache_statistics : unit -> cache_statistics
(** 获取缓存统计信息 *)

val configure_cache : cache_strategy -> unit data_result
(** 配置缓存策略 *)

val clear_cache : ?source:data_source_id -> unit -> unit data_result
(** 清理缓存 *)

(** {1 向后兼容性接口} *)

val get_character_rhyme_info : string -> (string * Poetry_core.Json_core.rhyme_category * Poetry_core.Json_core.rhyme_group) option
(** 获取字符韵律信息（兼容接口）*)

val find_rhyme_group : string -> unified_data_item list option
(** 查找韵组（兼容接口）*)

val find_characters_by_rhyme : Poetry_core.Json_core.rhyme_group -> unified_data_item list option
(** 按韵查找字符（兼容接口）*)

(** {1 初始化和管理} *)

val initialize_data_manager : unit -> unit
(** 初始化数据管理器 *)

val cleanup_data_manager : unit -> unit
(** 清理数据管理器 *)

val health_check : unit -> bool
(** 系统健康检查 *)

(** {1 索引管理} *)

val rebuild_indexes : unified_data_item list -> unit
(** 重建索引 *)

val get_index_statistics : unit -> int * int * int
(** 获取索引统计信息 (字符数, 韵组数, 韵类数) *)