(** Poetry数据加载器整合核心模块接口 - P0专项整合
    
    整合unified_data_loader、unified_data_loader_comprehensive、
    unified_data_loader_extended和externalized_data_loader等模块的功能，
    提供统一的数据加载接口。
    
    Author: Whisky, PR Worker - P0专项整合
    @version 1.0 - Phase 2.1
    @since 2025-08-04
    @fix_issue #2174 *)

(** {1 核心数据类型} *)

(** 整合的数据类型枚举 *)
type consolidated_data_type =
  | RhymeData of rhyme_subtype
  | ToneData of tone_subtype
  | PoetryData of poetry_subtype
  | WordClassData of word_class_subtype
  | ExternalizedData of external_subtype
  | ArtisticData

(** 韵律数据子类型 *)
and rhyme_subtype =
  | PingShengRhymes  (** 平声韵数据 *)
  | ZeShengRhymes  (** 仄声韵数据 *)
  | CompleteRhymeDatabase  (** 完整韵律数据库 *)

(** 声调数据子类型 *)
and tone_subtype =
  | PingSheng  (** 平声字符 *)
  | ZeSheng  (** 仄声字符 *)
  | ShangSheng  (** 上声字符 *)
  | QuSheng  (** 去声字符 *)
  | RuSheng  (** 入声字符 *)
  | AllToneData  (** 所有声调数据 *)

(** 诗词数据子类型 *)
and poetry_subtype =
  | UnifiedDatabase  (** 统一数据库 *)
  | DataSourceRegistry  (** 数据源注册表 *)
  | CacheManagement  (** 缓存管理 *)

(** 词类数据子类型 *)
and word_class_subtype =
  | NatureNouns  (** 自然名词 *)
  | GeographyPoliticsNouns  (** 地理政治名词 *)
  | PersonRelationNouns  (** 人物关系名词 *)
  | SocialStatusNouns  (** 社会地位名词 *)
  | ToolsObjectsNouns  (** 工具物品名词 *)
  | BuildingPlaceNouns  (** 建筑场所名词 *)
  | AllWordClassData  (** 所有词类数据 *)

(** 外部数据子类型 *)
and external_subtype =
  | CustomJsonData of string  (** 自定义JSON数据 *)
  | FileSystemData of string  (** 文件系统数据 *)

(** {1 错误处理} *)

(** 整合的错误类型 *)
type consolidated_load_error =
  | RhymeLoadError of string * string  (** 韵律数据加载错误 *)
  | ToneLoadError of string * string  (** 声调数据加载错误 *)
  | PoetryLoadError of string * string  (** 诗词数据加载错误 *)
  | WordClassLoadError of string * string  (** 词类数据加载错误 *)
  | ExternalLoadError of string * string  (** 外部数据加载错误 *)
  | ArtisticLoadError of string * string  (** 艺术数据加载错误 *)
  | ConsolidatedLoadError of string  (** 整合加载器错误 *)
  | CompatibilityError of string  (** 兼容性错误 *)

exception ConsolidatedLoadError of consolidated_load_error

val format_consolidated_error : consolidated_load_error -> string
(** 格式化错误信息 *)

(** {1 加载配置} *)

type consolidated_config = {
  enable_cache : bool;  (** 启用缓存 *)
  cache_size_limit : int;  (** 缓存大小限制 *)
  enable_fallback : bool;  (** 启用降级模式 *)
  enable_performance_tracking : bool;  (** 启用性能跟踪 *)
  timeout_ms : int;  (** 超时时间(毫秒) *)
}
(** 整合的加载配置 *)

val default_config : consolidated_config
(** 默认配置 *)

(** {1 核心数据加载接口} *)

val load_data : ?config:consolidated_config -> consolidated_data_type -> Yojson.Safe.t
(** 核心数据加载函数
    @param config 加载配置 (可选)
    @param data_type 数据类型
    @return JSON数据 *)

(** {1 兼容性类型重导出} *)

type rhyme_category = Yyocamlc_lib.Poetry_core.Poetry_types.rhyme_category
(** 韵律类型定义 *)

type rhyme_group = Yyocamlc_lib.Poetry_core.Poetry_types.rhyme_group
(** 韵组类型定义 *)

type data_source = Data_source_manager.data_source
(** 数据源类型 *)

type data_source_entry = Data_source_manager.data_source_entry
(** 数据源条目类型 *)

(** {1 韵律数据接口} *)

val load_ping_sheng_rhymes : unit -> (string * rhyme_category * rhyme_group) list
(** 加载平声韵数据 *)

val load_ze_sheng_rhymes : unit -> (string * rhyme_category * rhyme_group) list
(** 加载仄声韵数据 *)

val load_complete_rhyme_database : unit -> (string * rhyme_category * rhyme_group) list
(** 加载完整韵律数据库 *)

(** {1 声调数据接口} *)

val get_ping_sheng_chars : unit -> string list
(** 获取平声字符列表 *)

val get_shang_sheng_chars : unit -> string list
(** 获取上声字符列表 *)

val get_qu_sheng_chars : unit -> string list
(** 获取去声字符列表 *)

val get_ru_sheng_chars : unit -> string list
(** 获取入声字符列表 *)

val get_all_tone_data : unit -> string list * string list * string list * string list
(** 获取所有声调数据
    @return (平声, 上声, 去声, 入声) 四元组 *)

(** {1 词类数据接口} *)

val get_nature_nouns : unit -> string list
(** 获取自然名词列表 *)

val get_geography_politics_nouns : unit -> string list
(** 获取地理政治名词列表 *)

val get_person_relation_nouns : unit -> string list
(** 获取人物关系名词列表 *)

val get_social_status_nouns : unit -> string list
(** 获取社会地位名词列表 *)

val get_tools_objects_nouns : unit -> string list
(** 获取工具物品名词列表 *)

val get_building_place_nouns : unit -> string list
(** 获取建筑场所名词列表 *)

type all_word_class_data = {
  nature_nouns : string list;
  geography_politics_nouns : string list;
  person_relation_nouns : string list;
  social_status_nouns : string list;
  tools_objects_nouns : string list;
  building_place_nouns : string list;
  ping_sheng : string list;
  shang_sheng : string list;
  qu_sheng : string list;
  ru_sheng : string list;
}
(** 所有词类数据结构 *)

val load_all_word_class_data : unit -> all_word_class_data
(** 加载所有词类数据 *)

(** {1 诗词数据接口} *)

val get_unified_database : unit -> (string * rhyme_category * rhyme_group) list
(** 获取统一数据库 *)

val is_char_in_database : string -> bool
(** 检查字符是否在数据库中 *)

val get_char_rhyme_info : string -> (string * rhyme_category * rhyme_group) option
(** 获取字符韵律信息 *)

(** {1 缓存管理} *)

val warm_cache : consolidated_data_type list -> unit
(** 预热指定数据类型的缓存 *)

val clear_cache : unit -> unit
(** 清空所有缓存 *)

val get_cache_stats : unit -> (consolidated_data_type * bool * int) list
(** 获取缓存统计信息
    @return (数据类型, 是否已缓存, 缓存大小) 列表 *)

val get_cache_info : unit -> bool * int
(** 获取缓存状态信息
    @return (缓存是否启用, 缓存项目数) *)

(** {1 批量操作和性能优化} *)

val load_all_data_types : unit -> unit
(** 批量加载所有数据类型到缓存 *)

val get_comprehensive_stats : unit -> (string * int * float) list
(** 获取综合统计信息
    @return (数据类型名称, 访问次数, 缓存命中率) 列表 *)

val validate_all_data_integrity : unit -> bool * string list
(** 验证所有数据完整性
    @return (验证结果, 错误列表) *)

(** {1 性能监控} *)

val get_load_performance_metrics : unit -> (consolidated_data_type * float * int) list
(** 获取加载性能指标
    @return (数据类型, 平均加载时间ms, 调用次数) 列表 *)

val enable_performance_tracking : bool -> unit
(** 启用/禁用性能跟踪 *)

(** {1 降级和容错} *)

val safe_load_with_fallback : consolidated_data_type -> Yojson.Safe.t option
(** 安全加载数据，失败时返回None *)

val enable_fallback_mode : bool -> unit
(** 启用/禁用降级模式 *)

(** {1 调试和监控} *)

val print_status : unit -> unit
(** 打印整合模块状态信息 *)

val data_type_to_string : consolidated_data_type -> string
(** 将数据类型转换为字符串 *)

(** {1 向后兼容性接口} *)

val load_ping_sheng_rhymes_comprehensive : unit -> (string * rhyme_category * rhyme_group) list
(** 兼容unified_data_loader_comprehensive *)

val load_ze_sheng_rhymes_comprehensive : unit -> (string * rhyme_category * rhyme_group) list

val load_complete_rhyme_database_comprehensive :
  unit -> (string * rhyme_category * rhyme_group) list

val get_ping_sheng_chars_comprehensive : unit -> string list
val get_shang_sheng_chars_comprehensive : unit -> string list
val get_qu_sheng_chars_comprehensive : unit -> string list
val get_ru_sheng_chars_comprehensive : unit -> string list
val get_all_tone_data_comprehensive : unit -> string list * string list * string list * string list
val get_unified_database_comprehensive : unit -> (string * rhyme_category * rhyme_group) list
val is_char_in_database_comprehensive : string -> bool
val get_char_rhyme_info_comprehensive : string -> (string * rhyme_category * rhyme_group) option

val validate_data_integrity : unit -> bool
(** 兼容unified_data_loader_extended *)

val warm_word_class_cache : unit -> unit
val get_word_class_stats : unit -> (string * int) list

(** 兼容externalized_data_loader *)
module ExternalizedCompat : sig
  type externalized_data_error =
    | FileNotFound of string
    | ParseError of string * string
    | ValidationError of string

  exception ExternalizedDataError of externalized_data_error

  val format_error : externalized_data_error -> string
end
