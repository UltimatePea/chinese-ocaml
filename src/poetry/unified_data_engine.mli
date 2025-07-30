(** 统一数据引擎 - Phase 2.3.2 核心数据访问引擎

    本模块作为诗韵项目数据访问的统一入口，整合所有分散的数据加载器功能为单一引擎系统。 采用插件化设计，支持多种数据源和访问模式，提供智能缓存和性能优化。

    @author Alpha, 主要工作代理 - Phase 2.3.2 数据加载器系统整合
    @version 2.3.2
    @since 2025-07-30 *)

(** {1 核心类型定义} *)

(** 数据类型分类 *)
type data_category =
  | Poetry  (** 诗歌相关数据：韵律、格律、诗词形式 *)
  | Artistic  (** 艺术相关数据：意象词汇、雅致用词、评价标准 *)
  | Linguistic  (** 语言学数据：声调、韵组、韵脚 *)
  | Configuration  (** 配置数据：系统设置、用户偏好 *)

(** 数据访问模式 *)
type access_mode =
  | Immediate  (** 立即访问模式：实时加载数据 *)
  | Cached  (** 缓存模式：优先使用缓存，缓存未命中时加载 *)
  | Lazy  (** 懒加载模式：延迟到实际使用时加载 *)
  | Preloaded  (** 预加载模式：系统启动时预先加载 *)

(** 数据源类型 *)
type data_source =
  | JsonFile of string  (** JSON文件数据源 *)
  | CsvFile of string  (** CSV文件数据源 *)
  | TextFile of string  (** 文本文件数据源 *)
  | Embedded of string  (** 内嵌数据源（硬编码） *)
  | External of string  (** 外部服务数据源 *)

(** 数据状态 *)
type data_status =
  | Loading  (** 数据加载中 *)
  | Ready  (** 数据就绪 *)
  | Error of string  (** 加载错误 *)
  | Stale  (** 数据过期 *)

(** 引擎错误类型 *)
type engine_error =
  | DataSourceNotFound of string  (** 数据源未找到 *)
  | LoadingFailed of string * string  (** 加载失败：数据源 * 错误信息 *)
  | ValidationFailed of string  (** 数据验证失败 *)
  | CacheError of string  (** 缓存错误 *)
  | InvalidConfiguration of string  (** 配置错误 *)

(** 加载结果类型 *)
type 'a load_result = Success of 'a | Failure of engine_error

type engine_stats = {
  total_requests : int;  (** 总请求次数 *)
  cache_hits : int;  (** 缓存命中次数 *)
  cache_misses : int;  (** 缓存未命中次数 *)
  load_errors : int;  (** 加载错误次数 *)
  average_load_time : float;  (** 平均加载时间（毫秒） *)
  data_sources_count : int;  (** 注册的数据源数量 *)
  cached_entries_count : int;  (** 缓存条目数量 *)
}
(** 引擎统计信息 *)

(** {1 引擎配置和初始化} *)

val initialize : ?cache_size:int -> ?preload_categories:data_category list -> unit -> unit
(** 初始化统一数据引擎

    @param cache_size 缓存大小限制（条目数），默认1000
    @param preload_categories 需要预加载的数据类别列表
    @return unit *)

val shutdown : unit -> unit
(** 关闭引擎，清理资源 *)

val is_initialized : unit -> bool
(** 检查引擎是否已初始化 *)

(** {1 数据源管理} *)

val register_data_source : string -> data_category -> data_source -> access_mode -> unit
(** 注册数据源

    @param name 数据源名称（唯一标识符）
    @param category 数据类别
    @param source 数据源
    @param mode 访问模式 *)

val unregister_data_source : string -> unit
(** 注销数据源

    @param name 数据源名称 *)

val list_registered_sources : unit -> (string * data_category * data_source * access_mode) list
(** 列出所有注册的数据源 *)

val get_data_source_status : string -> data_status option
(** 获取数据源状态

    @param name 数据源名称
    @return 数据状态，数据源不存在时返回None *)

(** {1 核心数据访问接口} *)

val load_string_list : string -> string list load_result
(** 加载字符串列表数据

    @param source_name 数据源名称
    @return 字符串列表加载结果 *)

val load_key_value_pairs : string -> (string * string) list load_result
(** 加载键值对数据

    @param source_name 数据源名称
    @return 键值对列表加载结果 *)

val load_json_data : string -> Yojson.Basic.t load_result
(** 加载JSON数据

    @param source_name 数据源名称
    @return JSON数据加载结果 *)

val load_custom_data : string -> ('a -> 'b) -> 'a -> 'b load_result
(** 自定义数据加载

    @param source_name 数据源名称
    @param transformer 数据转换函数
    @param default_data 默认数据
    @return 转换后的数据加载结果 *)

(** {1 高级查询接口} *)

val query_by_category : data_category -> string list
(** 按类别查询数据源

    @param category 数据类别
    @return 该类别下的数据源名称列表 *)

val search_data_sources : string -> string list
(** 搜索数据源

    @param pattern 搜索模式（支持通配符）
    @return 匹配的数据源名称列表 *)

val bulk_load : string list -> (string * string list load_result) list
(** 批量加载数据

    @param source_names 数据源名称列表
    @return (数据源名称, 加载结果) 对的列表 *)

(** {1 缓存管理} *)

val clear_cache : ?category:data_category option -> unit -> unit
(** 清除缓存

    @param category 可选的数据类别，未指定时清除全部缓存 *)

val refresh_data : string -> unit load_result
(** 刷新数据（强制重新加载）

    @param source_name 数据源名称 *)

val preload_category : data_category -> unit load_result
(** 预加载指定类别的所有数据

    @param category 数据类别 *)

val get_cache_info : unit -> (string * int * float) list
(** 获取缓存信息

    @return (数据源名称, 缓存大小字节, 最后访问时间) 列表 *)

(** {1 性能监控和统计} *)

val get_engine_stats : unit -> engine_stats
(** 获取引擎统计信息 *)

val reset_stats : unit -> unit
(** 重置统计信息 *)

val enable_profiling : bool -> unit
(** 启用/禁用性能分析

    @param enable 是否启用性能分析 *)

val get_load_time_history : string -> float list
(** 获取数据源的加载时间历史

    @param source_name 数据源名称
    @return 最近的加载时间列表（毫秒） *)

(** {1 错误处理和诊断} *)

val format_error : engine_error -> string
(** 格式化引擎错误信息

    @param error 引擎错误
    @return 格式化的错误信息字符串 *)

val validate_all_sources : unit -> (string * bool * string option) list
(** 验证所有数据源

    @return (数据源名称, 验证是否通过, 错误信息) 列表 *)

val diagnose_source : string -> string
(** 诊断数据源问题

    @param source_name 数据源名称
    @return 诊断报告字符串 *)

(** {1 兼容性和迁移接口} *)

val create_compatibility_layer : string -> (string -> 'a) -> unit
(** 创建兼容性层

    为旧的数据加载器创建兼容接口

    @param legacy_name 旧数据加载器名称
    @param adapter 适配器函数 *)

val migrate_legacy_usage : string -> string -> unit
(** 迁移旧的使用方式

    @param old_source_name 旧数据源名称
    @param new_source_name 新数据源名称 *)
