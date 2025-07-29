(** 统一数据加载器综合模块接口 - Phase 2.2: 全面数据类型支持
    
    此模块扩展unified_data_loader架构，整合poetry_data_loader、rhyme_data_loader
    和tone_data_loader的功能，实现真正的统一数据加载核心。
    
    @author Alpha, 技术债务清理专员
    @version 2.2 - Phase 2.2 全面整合
    @since 2025-07-29
    @fix_issue #1732 *)

(** {1 扩展数据类型} *)

(** 综合数据类型 - 支持所有诗词相关数据 *)
type comprehensive_data_type =
  | RhymeDataType of rhyme_data_subtype
  | ToneDataType of tone_data_subtype
  | PoetryDataType of poetry_data_subtype
  | WordClassDataType
  | ArtisticDataType

(** 韵律数据子类型 *)
and rhyme_data_subtype =
  | PingShengRhymes  (** 平声韵数据 *)
  | ZeShengRhymes  (** 仄声韵数据 *)
  | CompleteRhymeDatabase  (** 完整韵律数据库 *)

(** 声调数据子类型 *)
and tone_data_subtype =
  | PingSheng  (** 平声字符 *)
  | ZeSheng  (** 仄声字符 *)
  | ShangSheng  (** 上声字符 *)
  | QuSheng  (** 去声字符 *)
  | RuSheng  (** 入声字符 *)
  | AllToneData  (** 所有声调数据 *)

(** 诗词数据子类型 *)
and poetry_data_subtype =
  | UnifiedDatabase  (** 统一数据库 *)
  | DataSourceRegistry  (** 数据源注册表 *)
  | CacheManagement  (** 缓存管理 *)

(** {1 综合错误类型} *)

(** 综合加载错误 - 统一所有子模块的错误类型 *)
type comprehensive_load_error =
  | RhymeLoadError of string * string  (** 韵律数据加载错误 *)
  | ToneLoadError of string * string  (** 声调数据加载错误 *)
  | PoetryLoadError of string * string  (** 诗词数据加载错误 *)
  | UnifiedLoadError of string  (** 统一加载器错误 *)
  | CompatibilityError of string  (** 兼容性错误 *)

exception ComprehensiveLoadError of comprehensive_load_error

(** {1 错误处理} *)

val format_comprehensive_error : comprehensive_load_error -> string
(** 格式化综合错误信息
    @param error 综合错误类型
    @return 格式化的错误消息字符串 *)

(** {1 核心数据加载接口} *)

val load_comprehensive_data :
  ?config:Poetry_data_loaders.Unified_loader.load_config ->
  comprehensive_data_type ->
  Poetry_data_loaders.Unified_loader.data_source ->
  Yojson.Safe.t
(** 综合数据加载核心函数
    @param options 加载选项 (可选)
    @param data_type 综合数据类型
    @param source_type 数据源类型
    @return JSON数据 *)

(** {1 韵律数据接口} *)

type rhyme_category = Poetry_core.Poetry_types.rhyme_category
(** 韵律类型定义 - 直接使用Poetry_types的统一类型 *)

type rhyme_group = Poetry_core.Poetry_types.rhyme_group

val load_ping_sheng_rhymes_comprehensive : unit -> (string * rhyme_category * rhyme_group) list
(** 加载平声韵数据 - 综合版本
    @return 平声韵字符列表 *)

val load_ze_sheng_rhymes_comprehensive : unit -> (string * rhyme_category * rhyme_group) list
(** 加载仄声韵数据 - 综合版本
    @return 仄声韵字符列表 *)

val load_complete_rhyme_database_comprehensive :
  unit -> (string * rhyme_category * rhyme_group) list
(** 加载完整韵律数据库 - 综合版本
    @return 完整韵律数据库 *)

(** {1 声调数据接口} *)

val get_ping_sheng_chars_comprehensive : unit -> string list
(** 获取平声字符列表 - 综合版本
    @return 平声字符列表 *)

val get_shang_sheng_chars_comprehensive : unit -> string list
(** 获取上声字符列表 - 综合版本
    @return 上声字符列表 *)

val get_qu_sheng_chars_comprehensive : unit -> string list
(** 获取去声字符列表 - 综合版本
    @return 去声字符列表 *)

val get_ru_sheng_chars_comprehensive : unit -> string list
(** 获取入声字符列表 - 综合版本
    @return 入声字符列表 *)

val get_all_tone_data_comprehensive : unit -> string list * string list * string list * string list
(** 获取所有声调数据 - 综合版本
    @return (平声, 上声, 去声, 入声) 四元组 *)

(** {1 诗词数据接口} *)

type data_source = Data_source_manager.data_source
(** 数据源类型 - 与poetry_data_loader兼容 *)

type data_source_entry = Data_source_manager.data_source_entry

val get_unified_database_comprehensive : unit -> (string * rhyme_category * rhyme_group) list
(** 获取统一数据库 - 综合版本
    @return 统一数据库字符列表 *)

val is_char_in_database_comprehensive : string -> bool
(** 检查字符是否在数据库中 - 综合版本
    @param char 要检查的字符
    @return 是否在数据库中 *)

val get_char_rhyme_info_comprehensive : string -> (string * rhyme_category * rhyme_group) option
(** 获取字符韵律信息 - 综合版本
    @param char 要查询的字符
    @return 韵律信息 (可选) *)

(** {1 批量操作和性能优化} *)

val load_all_data_types : unit -> unit
(** 批量加载所有数据类型到缓存 预热所有数据类型的缓存，提升后续访问性能 *)

val get_comprehensive_stats : unit -> (string * int * float) list
(** 获取综合统计信息
    @return (数据类型名称, 数据量, 缓存命中率) 列表 *)

val validate_all_data_integrity : unit -> bool * string list
(** 验证所有数据完整性
    @return (验证结果, 错误列表) *)

(** {1 缓存管理} *)

val clear_comprehensive_cache : unit -> unit
(** 清空综合模块所有缓存 *)

val warm_comprehensive_cache : comprehensive_data_type list -> unit
(** 预热指定数据类型的缓存
    @param data_types 要预热的数据类型列表 *)

val get_comprehensive_cache_info : unit -> (comprehensive_data_type * bool * int) list
(** 获取综合缓存信息
    @return (数据类型, 是否已缓存, 缓存大小) 列表 *)

(** {1 降级和容错} *)

val safe_load_with_fallback : comprehensive_data_type -> Yojson.Safe.t option
(** 安全加载数据，失败时返回None而不抛出异常
    @param data_type 数据类型
    @return 加载结果 (可选) *)

val enable_fallback_mode : bool -> unit
(** 启用/禁用降级模式
    @param enabled 是否启用降级模式 *)

(** {1 调试和监控} *)

val print_comprehensive_status : unit -> unit
(** 打印综合模块状态信息，用于调试 *)

val get_load_performance_metrics : unit -> (comprehensive_data_type * float * int) list
(** 获取加载性能指标
    @return (数据类型, 平均加载时间ms, 调用次数) 列表 *)
