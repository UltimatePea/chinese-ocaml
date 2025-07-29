(** 骆言诗词统一配置管理模块接口 - Poetry模块整合优化 Fix #1707
    
    此模块接口定义了统一的系统配置管理功能。
    提供完整的配置访问、更新和预设管理服务。
    
    Author: Alpha, 主要工作代理 *)

open Unified_data_types
open Unified_artistic_standards

(** {1 系统配置结构} *)

(** 日志级别 *)
type log_level =
  | Debug    (** 调试级别 - 详细的调试信息 *)
  | Info     (** 信息级别 - 一般信息 *)
  | Warning  (** 警告级别 - 警告信息 *)
  | Error    (** 错误级别 - 错误信息 *)
  | Critical (** 致命级别 - 严重错误 *)

(** 性能配置 *)
type performance_config = {
  max_concurrent_analyses : int;       (** 最大并发分析数 *)
  analysis_timeout_ms : int;           (** 分析超时时间(毫秒) *)
  enable_caching : bool;               (** 是否启用缓存 *)
  cache_size_limit : int;              (** 缓存大小限制 *)
  gc_frequency : int;                  (** 垃圾回收频率 *)
}

(** 输出格式配置 *)
type output_format_config = {
  default_format : string;             (** 默认输出格式 *)
  include_metadata : bool;             (** 是否包含元数据 *)
  verbose_output : bool;               (** 是否详细输出 *)
  pretty_print : bool;                 (** 是否美化打印 *)
  encoding : string;                   (** 输出编码 *)
}

(** 数据源配置扩展 *)
type data_source_config = {
  base_config : analysis_config;       (** 基础分析配置 *)
  data_dir : string;                   (** 数据目录路径 *)
  fallback_enabled : bool;             (** 是否启用降级模式 *)
  auto_reload : bool;                  (** 是否自动重载数据 *)
  validation_level : int;              (** 数据验证级别 1-5 *)
}

(** 评价配置 *)
type evaluation_config = {
  default_standard : artistic_standard_config; (** 默认艺术标准 *)
  auto_form_detection : bool;          (** 是否自动检测诗体 *)
  strict_mode : bool;                  (** 是否严格模式 *)
  enable_suggestions : bool;           (** 是否生成建议 *)
  max_suggestions : int;               (** 最大建议数量 *)
}

(** 系统完整配置 *)
type system_config = {
  version : string;                    (** 系统版本 *)
  debug_mode : bool;                   (** 调试模式 *)
  log_level : log_level;               (** 日志级别 *)
  performance : performance_config;    (** 性能配置 *)
  output_format : output_format_config; (** 输出格式配置 *)
  data_sources : data_source_config;   (** 数据源配置 *)
  evaluation : evaluation_config;      (** 评价配置 *)
  custom_settings : (string * string) list; (** 自定义设置 *)
}

(** {1 默认配置} *)

val default_system_config : system_config
(** 默认系统配置 *)

val development_config : system_config
(** 开发环境配置 *)

val production_config : system_config
(** 生产环境配置 *)

val testing_config : system_config
(** 测试环境配置 *)

(** {1 配置管理} *)

val get_config : unit -> system_config
(** 获取当前配置 *)

val update_config : system_config -> unit
(** 更新配置 *)

val reset_to_default : unit -> unit
(** 重置为默认配置 *)

(** {1 配置访问器} *)

val is_debug_mode : unit -> bool
(** 获取调试模式状态 *)

val get_log_level : unit -> log_level
(** 获取日志级别 *)

val is_strict_mode : unit -> bool
(** 获取严格模式状态 *)

val get_cache_policy : unit -> cache_policy
(** 获取缓存策略 *)

val get_default_artistic_standard : unit -> artistic_standard_config
(** 获取默认艺术标准 *)

val get_data_directory : unit -> string
(** 获取数据目录 *)

val get_max_concurrent_analyses : unit -> int
(** 获取最大并发数 *)

val get_analysis_timeout : unit -> int
(** 获取分析超时时间 *)

(** {1 配置更新器} *)

val set_debug_mode : bool -> unit
(** 设置调试模式 *)

val set_log_level : log_level -> unit
(** 设置日志级别 *)

val set_strict_mode : bool -> unit
(** 设置严格模式 *)

val set_default_artistic_standard : artistic_standard_config -> unit
(** 设置默认艺术标准 *)

val set_cache_policy : cache_policy -> unit
(** 设置缓存策略 *)

val set_performance_params : int -> int -> int -> unit
(** 设置性能参数 *)

val set_environment_config : string -> unit
(** 设置环境配置 *)

(** {1 配置验证} *)

val validate_config : system_config -> string list
(** 验证配置合法性 *)

val validate_current_config : unit -> string list
(** 验证当前配置 *)

(** {1 配置序列化} *)

val log_level_to_string : log_level -> string
(** 日志级别转字符串 *)

val string_to_log_level : string -> log_level option
(** 字符串转日志级别 *)

val export_config_summary : system_config -> (string * string) list
(** 导出配置摘要 *)

(** {1 配置预设管理} *)

type config_preset = {
  name : string;
  description : string;
  config : system_config;
}

val all_presets : config_preset list
(** 所有预设配置 *)

val get_preset : string -> config_preset option
(** 根据名称获取预设 *)

val apply_preset : string -> bool
(** 应用预设配置 *)

val list_presets : unit -> (string * string) list
(** 列出所有预设 *)

(** {1 运行时配置调整} *)

val with_temporary_config : system_config -> (unit -> 'a) -> 'a
(** 临时配置修改 *)

val with_debug_mode : bool -> (unit -> 'a) -> 'a
(** 临时设置调试模式 *)

val with_strict_mode : bool -> (unit -> 'a) -> 'a
(** 临时设置严格模式 *)

(** {1 向后兼容接口} *)

(** 兼容旧版本的简单配置 *)
type legacy_config = {
  debug : bool;
  strict : bool;
  cache_enabled : bool;
  max_suggestions : int;
}

val to_legacy_config : system_config -> legacy_config
(** 转换为旧版本配置 *)

val from_legacy_config : legacy_config -> system_config
(** 从旧版本配置转换 *)

val get_legacy_config : unit -> legacy_config
(** 获取旧版本兼容配置 *)

val set_legacy_config : legacy_config -> unit
(** 设置旧版本兼容配置 *)