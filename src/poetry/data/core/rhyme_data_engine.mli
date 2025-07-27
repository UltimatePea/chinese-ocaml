(** 韵律数据引擎接口 - 统一数据管理核心
    
    此模块提供Poetry系统的核心数据管理功能，包括：
    - 统一的数据加载和缓存
    - 高效的韵律查询和匹配
    - 数据源管理和更新
    - 性能优化和监控
    
    技术债务修复：统一分散的数据管理逻辑，建立高效的单一数据引擎。
    
    @author Alpha, 主要开发代理 - Poetry模块重构团队
    @version 2.0 (统一架构版)
    @since 2025-07-27
    @fix_issue #1501 *)

open Poetry_types.Rhyme_types

(** {1 数据引擎类型定义} *)

type cache_statistics = {
  hits : int;  (** 缓存命中次数 *)
  misses : int;  (** 缓存未命中次数 *)
  total_queries : int;  (** 总查询次数 *)
  last_reset : float;  (** 上次重置时间 *)
}
(** 缓存统计信息 *)

type engine_state
(** 数据引擎状态 - 不透明类型 *)

exception RhymeDataEngineError of string
(** 数据引擎异常 *)

(** {1 核心功能} *)

val initialize : unit -> engine_state
(** 初始化数据引擎
    @return 初始化的引擎状态 *)

val load_database : rhyme_database -> engine_state -> engine_state
(** 加载韵律数据库
    @param database 要加载的韵律数据库
    @param engine_state 当前引擎状态
    @return 更新后的引擎状态
    @raise RhymeDataEngineError 当数据库无效时 *)

(** {1 查询功能} *)

val lookup_character : string -> engine_state -> rhyme_data_item option
(** 查询字符韵律信息
    @param character 要查询的字符
    @param engine_state 引擎状态
    @return 韵律数据项（如果找到）
    @raise RhymeDataEngineError 当引擎未初始化时 *)

val get_group_characters : rhyme_group -> engine_state -> rhyme_data_item list
(** 查询韵组所有字符
    @param group 韵组
    @param engine_state 引擎状态
    @return 韵组中的所有韵律数据项
    @raise RhymeDataEngineError 当引擎未初始化时 *)

val get_category_characters : rhyme_category -> engine_state -> rhyme_data_item list
(** 查询韵类所有字符
    @param category 韵类
    @param engine_state 引擎状态
    @return 韵类中的所有韵律数据项
    @raise RhymeDataEngineError 当引擎未初始化时 *)

(** {1 匹配功能} *)

val check_rhyme_match : string -> string -> engine_state -> bool
(** 检查韵律匹配
    @param char1 第一个字符
    @param char2 第二个字符
    @param engine_state 引擎状态
    @return 是否韵律匹配
    @raise RhymeDataEngineError 当引擎未初始化时 *)

val check_category_match : string -> string -> engine_state -> bool
(** 检查韵类匹配
    @param char1 第一个字符
    @param char2 第二个字符
    @param engine_state 引擎状态
    @return 是否韵类匹配
    @raise RhymeDataEngineError 当引擎未初始化时 *)

(** {1 高级查询功能} *)

val find_similar_characters : string -> engine_state -> rhyme_data_item list
(** 查找相似韵律的字符
    @param character 基准字符
    @param engine_state 引擎状态
    @return 相同韵组的其他字符列表 *)

val batch_lookup_characters : string list -> engine_state -> (string * rhyme_data_item option) list
(** 批量查询字符
    @param characters 字符列表
    @param engine_state 引擎状态
    @return 字符与对应韵律信息的关联列表 *)

(** {1 管理功能} *)

val get_cache_stats : engine_state -> cache_statistics
(** 获取缓存统计
    @param engine_state 引擎状态
    @return 缓存统计信息 *)

val clear_cache_stats : engine_state -> engine_state
(** 清理缓存统计
    @param engine_state 引擎状态
    @return 重置统计后的引擎状态 *)

val get_database_info : engine_state -> int * int * string
(** 获取数据库信息
    @param engine_state 引擎状态
    @return (总数据项数, 韵组数, 版本号)
    @raise RhymeDataEngineError 当引擎未初始化时 *)

(** {1 验证和监控功能} *)

val validate_engine_state : engine_state -> bool
(** 验证引擎状态
    @param engine_state 引擎状态
    @return 引擎状态是否有效 *)

val get_performance_metrics : engine_state -> (string * string) list
(** 获取引擎性能指标
    @param engine_state 引擎状态
    @return 性能指标键值对列表 *)
