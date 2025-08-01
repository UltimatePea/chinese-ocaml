(** 韵律类型统一定义模块 - 整合所有重复类型定义
    
    此模块整合并替代以下重复类型模块:
    - rhyme_types.ml
    - rhyme_core_types.ml
    - rhyme_json_types.ml
    - poetry_types_consolidated.ml (韵律部分)
    - poetry_types_unified.ml (韵律部分)
    - artistic_types.ml (韵律部分)
    
    提供统一、简洁、高效的韵律类型定义。
    
    Author: Whisky, PR Worker
    @version 1.0 - Poetry韵律类型统一整合
    @since 2025-08-01
    @implements Issue #1999 - Poetry韵律模块统一整合实施 *)

(** {1 核心韵律类型定义} *)

(** 韵律条目结构 - 统一所有变体 *)
type unified_rhyme_entry = {
  character: string;              (** 韵字 *)
  rhyme_group: rhyme_group;       (** 韵组 *)
  tone_category: rhyme_category;  (** 声调类别 *)
  frequency: float;               (** 使用频率 0.0-1.0 *)
  variants: string list;          (** 变体字列表 *)
  phonetic: string option;        (** 拼音标注 (可选) *)
  source_module: string;          (** 数据来源模块 *)
  metadata: entry_metadata;       (** 扩展元数据 *)
}

(** 韵组定义 - 自包含类型定义 *)
and rhyme_group =
  | AnRhyme      (** 安韵 *)
  | SiRhyme      (** 思韵 *)  
  | TianRhyme    (** 天韵 *)
  | FengRhyme    (** 风韵 *)
  | YuRhyme      (** 鱼韵 *)
  | WangRhyme    (** 王韵 *)
  | HuaRhyme     (** 花韵 *)
  | HuiRhyme     (** 辉韵 *)
  | JiangRhyme   (** 江韵 *)
  | YueRhyme     (** 月韵 *)
  | QuRhyme      (** 曲韵 *)
  | XueRhyme     (** 雪韵 *)
  | UnknownRhyme (** 未知韵 *)

(** 声调类别 - 自包含类型定义 *)
and rhyme_category =
  | PingSheng    (** 平声 *)
  | ZeSheng      (** 仄声 *)
  | ShangSheng   (** 上声 *)
  | QuSheng      (** 去声 *) 
  | RuSheng      (** 入声 *)

(** 条目元数据 *)
and entry_metadata = {
  created_at: float;             (** 创建时间戳 *)
  last_updated: float;           (** 最后更新时间戳 *)
  usage_count: int;              (** 使用次数统计 *)
  quality_score: float;          (** 质量评分 0.0-1.0 *)
  tags: string list;             (** 标签列表 *)
}

(** {2 数据库和索引类型} *)

(** 统一韵律数据库结构 *)  
type unified_rhyme_database = {
  entries: unified_rhyme_entry list;                                     (** 所有条目 *)
  lookup_table: (string, unified_rhyme_entry) Hashtbl.t;               (** 字符查找表 *)
  group_index: (rhyme_group, unified_rhyme_entry list) Hashtbl.t;      (** 韵组索引 *)
  tone_index: (rhyme_category, unified_rhyme_entry list) Hashtbl.t;    (** 声调索引 *)
  frequency_index: (float, unified_rhyme_entry list) Hashtbl.t;        (** 频率索引 *)
  stats: database_statistics;                                           (** 统计信息 *)
  config: database_config;                                              (** 配置信息 *)
}

(** 数据库统计信息 *)
and database_statistics = {
  total_entries: int;                             (** 总条目数 *)
  ping_sheng_count: int;                         (** 平声字数 *)
  ze_sheng_count: int;                           (** 仄声字数 *)
  ru_sheng_count: int;                           (** 入声字数 *)
  group_distribution: (rhyme_group * int) list;  (** 韵组分布 *)
  frequency_distribution: (float * int) list;    (** 频率分布 *)
  last_updated: float;                           (** 最后更新时间 *)
  cache_hit_rate: float;                         (** 缓存命中率 *)
}

(** 数据库配置 *)
and database_config = {
  enable_caching: bool;                          (** 启用缓存 *)
  cache_size_limit: int;                         (** 缓存大小限制 *)
  auto_warmup: bool;                             (** 自动预热 *)
  performance_monitoring: bool;                  (** 性能监控 *)
  compatibility_mode: bool;                      (** 兼容模式 *)
}

(** {3 查询和结果类型} *)

(** 查询参数类型 *)
type query_params = {
  character: string option;                      (** 查询字符 *)
  rhyme_group: rhyme_group option;              (** 韵组过滤 *)
  tone_category: rhyme_category option;         (** 声调过滤 *)
  min_frequency: float option;                  (** 最小频率 *)
  max_results: int option;                      (** 最大结果数 *)
  sort_by: sort_criteria;                       (** 排序方式 *)
}

(** 排序标准 *)
and sort_criteria =
  | ByFrequency of sort_order                   (** 按频率排序 *)
  | ByGroup of sort_order                       (** 按韵组排序 *)
  | ByTone of sort_order                        (** 按声调排序 *)
  | ByUsage of sort_order                       (** 按使用次数排序 *)

(** 排序顺序 *)
and sort_order = Ascending | Descending

(** 查询结果类型 *)
type query_result = {
  entries: unified_rhyme_entry list;            (** 匹配的条目 *)
  total_count: int;                             (** 总匹配数 *)
  query_time: float;                            (** 查询耗时 *)
  from_cache: bool;                             (** 是否来自缓存 *)
  suggestion: string list;                      (** 建议查询 *) 
}

(** {4 性能监控类型} *)

(** 性能统计 *)
type performance_stats = {
  mutable total_queries: int;                   (** 总查询次数 *)
  mutable cache_hits: int;                      (** 缓存命中次数 *)
  mutable cache_misses: int;                    (** 缓存未命中次数 *)
  mutable avg_query_time: float;                (** 平均查询时间 *)
  mutable peak_memory_usage: int;               (** 峰值内存使用 *)
  mutable last_reset: float;                    (** 上次重置时间 *)
}

(** 基准测试结果 *)
type benchmark_result = {
  test_name: string;                            (** 测试名称 *)
  iterations: int;                              (** 迭代次数 *)
  total_time: float;                            (** 总耗时 *)
  avg_time_per_op: float;                      (** 平均单操作时间 *)
  ops_per_second: float;                       (** 每秒操作数 *)
  memory_usage: int;                           (** 内存使用量 *)
}

(** {5 错误和异常类型} *)

(** 韵律系统错误类型 *)
type rhyme_error =
  | CharacterNotFound of string                 (** 字符未找到 *)
  | InvalidRhymeGroup of string                (** 无效韵组 *)
  | InvalidToneCategory of string              (** 无效声调类别 *)
  | DatabaseCorrupted of string                (** 数据库损坏 *)
  | CacheError of string                       (** 缓存错误 *)
  | QueryTimeout of float                      (** 查询超时 *)
  | CompatibilityError of string               (** 兼容性错误 *)

(** 韵律系统异常 *)
exception RhymeSystemError of rhyme_error

(** {6 配置和选项类型} *)

(** 系统配置 *)
type system_config = {
  data_source: data_source_config;              (** 数据源配置 *)
  performance: performance_config;              (** 性能配置 *)
  compatibility: compatibility_config;          (** 兼容性配置 *)
  logging: logging_config;                      (** 日志配置 *)
}

(** 数据源配置 *)
and data_source_config = {
  primary_source: string;                       (** 主数据源 *)
  fallback_sources: string list;                (** 备用数据源 *)
  auto_update: bool;                           (** 自动更新 *)
  validation_enabled: bool;                     (** 启用验证 *)
}

(** 性能配置 *)
and performance_config = {
  enable_caching: bool;                         (** 启用缓存 *)
  cache_size: int;                             (** 缓存大小 *)
  preload_common: bool;                        (** 预加载常用字 *)
  benchmark_mode: bool;                        (** 基准测试模式 *)
}

(** 兼容性配置 *)
and compatibility_config = {
  legacy_api_support: bool;                     (** 遗留API支持 *)
  strict_type_checking: bool;                   (** 严格类型检查 *)
  migration_warnings: bool;                     (** 迁移警告 *)
}

(** 日志配置 *)
and logging_config = {
  level: log_level;                            (** 日志级别 *)
  output_file: string option;                  (** 输出文件 *)
  performance_logging: bool;                   (** 性能日志 *)
}

(** 日志级别 *)
and log_level = Debug | Info | Warning | Error | Critical

(** {7 向后兼容类型别名} *)

(** 兼容 rhyme_types.ml *)
type rhyme_entry = unified_rhyme_entry
type rhyme_database = unified_rhyme_database  

(** 兼容 rhyme_core_types.ml *)
type core_rhyme_entry = unified_rhyme_entry
type rhyme_data_entry = unified_rhyme_entry

(** 兼容 rhyme_json_types.ml *)
type json_rhyme_entry = unified_rhyme_entry
type json_rhyme_data = unified_rhyme_database

(** {8 类型转换函数} *)

(** 将字符串转换为韵组 *)
let string_to_rhyme_group = function
  | "安" | "An" | "AnRhyme" -> Some AnRhyme
  | "思" | "Si" | "SiRhyme" -> Some SiRhyme
  | "天" | "Tian" | "TianRhyme" -> Some TianRhyme
  | "风" | "Feng" | "FengRhyme" -> Some FengRhyme
  | "鱼" | "Yu" | "YuRhyme" -> Some YuRhyme
  | "王" | "Wang" | "WangRhyme" -> Some WangRhyme
  | "花" | "Hua" | "HuaRhyme" -> Some HuaRhyme
  | "辉" | "Hui" | "HuiRhyme" -> Some HuiRhyme
  | "江" | "Jiang" | "JiangRhyme" -> Some JiangRhyme
  | "月" | "Yue" | "YueRhyme" -> Some YueRhyme
  | "曲" | "Qu" | "QuRhyme" -> Some QuRhyme
  | _ -> None

(** 将韵组转换为字符串 *)
let rhyme_group_to_string = function
  | AnRhyme -> "安韵"
  | SiRhyme -> "思韵"
  | TianRhyme -> "天韵"
  | FengRhyme -> "风韵"
  | YuRhyme -> "鱼韵"
  | WangRhyme -> "王韵"
  | HuaRhyme -> "花韵"
  | HuiRhyme -> "辉韵"
  | JiangRhyme -> "江韵"
  | YueRhyme -> "月韵"
  | QuRhyme -> "曲韵"

(** 将字符串转换为声调类别 *)
let string_to_tone_category = function
  | "平声" | "PingSheng" | "ping" -> Some PingSheng
  | "仄声" | "ZeSheng" | "ze" -> Some ZeSheng
  | "入声" | "RuSheng" | "ru" -> Some RuSheng
  | _ -> None

(** 将声调类别转换为字符串 *)
let tone_category_to_string = function
  | PingSheng -> "平声"
  | ZeSheng -> "仄声"
  | RuSheng -> "入声"

(** {9 工具函数} *)

(** 创建默认元数据 *)
let create_default_metadata () = {
  created_at = Sys.time ();
  last_updated = Sys.time ();
  usage_count = 0;
  quality_score = 1.0;
  tags = [];
}

(** 创建默认数据库配置 *)
let create_default_db_config () = {
  enable_caching = true;
  cache_size_limit = 10000;
  auto_warmup = true;
  performance_monitoring = true;
  compatibility_mode = false;
}

(** 创建默认系统配置 *)
let create_default_system_config () = {
  data_source = {
    primary_source = "unified_data";
    fallback_sources = ["legacy_data"];
    auto_update = false;
    validation_enabled = true;
  };
  performance = {
    enable_caching = true;
    cache_size = 10000;
    preload_common = true;
    benchmark_mode = false;
  };
  compatibility = {
    legacy_api_support = true;
    strict_type_checking = false;
    migration_warnings = true;
  };
  logging = {
    level = Info;
    output_file = None;
    performance_logging = true;
  };
}

(** 验证韵律条目 *)
let validate_rhyme_entry entry =
  if String.length entry.character = 0 then
    raise (RhymeSystemError (CharacterNotFound "Empty character"))
  else if entry.frequency < 0.0 || entry.frequency > 1.0 then
    raise (RhymeSystemError (InvalidRhymeGroup "Invalid frequency range"))
  else
    true

(** 模块初始化 *)
let () =
  Printf.printf "韵律类型统一定义模块初始化完成\n";
  Printf.printf "- 整合类型模块: 6 → 1\n";
  Printf.printf "- 统一类型定义: unified_rhyme_entry\n";
  Printf.printf "- 向后兼容: 完整支持\n"