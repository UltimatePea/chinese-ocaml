(** 骆言诗词统一配置管理模块 - Poetry模块整合优化 Fix #1707
    
    此模块是数据层第五个模块，统一管理所有诗词分析系统的配置。
    整合来源：各模块中分散的配置定义和管理功能
    
    Author: Alpha, 主要工作代理
    
    治者，理也。配者，合也。统一系统配置，运筹帷幄决胜。 *)

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

(** {1 默认配置定义} *)

(** 默认性能配置 *)
let default_performance_config = {
  max_concurrent_analyses = 4;
  analysis_timeout_ms = 30000;
  enable_caching = true;
  cache_size_limit = 1000;
  gc_frequency = 100;
}

(** 默认输出格式配置 *)
let default_output_format_config = {
  default_format = "text";
  include_metadata = true;
  verbose_output = false;
  pretty_print = true;
  encoding = "UTF-8";
}

(** 默认数据源配置 *)
let default_data_source_config = {
  base_config = {
    strict_mode = false;
    cache_policy = LRU_Cache 500;
    data_sources = [Memory_Cache];
    custom_rhyme_groups = [];
  };
  data_dir = "data/poetry";
  fallback_enabled = true;
  auto_reload = false;
  validation_level = 3;
}

(** 默认评价配置 *)
let default_evaluation_config = {
  default_standard = get_default_standard ();
  auto_form_detection = true;
  strict_mode = false;
  enable_suggestions = true;
  max_suggestions = 5;
}

(** 默认系统配置 *)
let default_system_config = {
  version = "2.0.0-poetry-integration";
  debug_mode = false;
  log_level = Info;
  performance = default_performance_config;
  output_format = default_output_format_config;
  data_sources = default_data_source_config;
  evaluation = default_evaluation_config;
  custom_settings = [];
}

(** {1 配置管理功能} *)

(** 全局配置实例 *)
let global_config = ref default_system_config

(** 获取当前配置 *)
let get_config () = !global_config

(** 更新配置 *)
let update_config new_config = global_config := new_config

(** 重置为默认配置 *)
let reset_to_default () = global_config := default_system_config

(** {1 配置访问器} *)

(** 获取调试模式状态 *)
let is_debug_mode () = (get_config ()).debug_mode

(** 获取日志级别 *)
let get_log_level () = (get_config ()).log_level

(** 获取严格模式状态 *)
let is_strict_mode () = (get_config ()).evaluation.strict_mode

(** 获取缓存策略 *)
let get_cache_policy () = (get_config ()).data_sources.base_config.cache_policy

(** 获取默认艺术标准 *)
let get_default_artistic_standard () = (get_config ()).evaluation.default_standard

(** 获取数据目录 *)
let get_data_directory () = (get_config ()).data_sources.data_dir

(** 获取最大并发数 *)
let get_max_concurrent_analyses () = (get_config ()).performance.max_concurrent_analyses

(** 获取分析超时时间 *)
let get_analysis_timeout () = (get_config ()).performance.analysis_timeout_ms

(** {1 配置更新器} *)

(** 设置调试模式 *)
let set_debug_mode enabled =
  let config = get_config () in
  update_config { config with debug_mode = enabled }

(** 设置日志级别 *)
let set_log_level level =
  let config = get_config () in
  update_config { config with log_level = level }

(** 设置严格模式 *)
let set_strict_mode enabled =
  let config = get_config () in
  let eval_config = config.evaluation in
  let new_eval_config = { eval_config with strict_mode = enabled } in
  update_config { config with evaluation = new_eval_config }

(** 设置默认艺术标准 *)
let set_default_artistic_standard standard =
  let config = get_config () in
  let eval_config = config.evaluation in
  let new_eval_config = { eval_config with default_standard = standard } in
  update_config { config with evaluation = new_eval_config }

(** 设置缓存策略 *)
let set_cache_policy policy =
  let config = get_config () in
  let data_config = config.data_sources in
  let base_config = data_config.base_config in
  let new_base_config = { base_config with cache_policy = policy } in
  let new_data_config = { data_config with base_config = new_base_config } in
  update_config { config with data_sources = new_data_config }

(** 设置性能参数 *)
let set_performance_params max_concurrent timeout cache_size =
  let config = get_config () in
  let perf_config = config.performance in
  let new_perf_config = {
    perf_config with
    max_concurrent_analyses = max_concurrent;
    analysis_timeout_ms = timeout;
    cache_size_limit = cache_size;
  } in
  update_config { config with performance = new_perf_config }

(** {1 环境相关配置} *)

(** 开发环境配置 *)
let development_config = {
  default_system_config with
  debug_mode = true;
  log_level = Debug;
  performance = {
    default_performance_config with
    max_concurrent_analyses = 2;
    analysis_timeout_ms = 60000;
  };
  evaluation = {
    default_evaluation_config with
    strict_mode = false;
    enable_suggestions = true;
    max_suggestions = 10;
  };
}

(** 生产环境配置 *)
let production_config = {
  default_system_config with
  debug_mode = false;
  log_level = Warning;
  performance = {
    default_performance_config with
    max_concurrent_analyses = 8;
    analysis_timeout_ms = 15000;
    enable_caching = true;
    cache_size_limit = 2000;
  };
  evaluation = {
    default_evaluation_config with
    strict_mode = true;
    enable_suggestions = true;
    max_suggestions = 3;
  };
}

(** 测试环境配置 *)
let testing_config = {
  default_system_config with
  debug_mode = true;
  log_level = Info;
  performance = {
    default_performance_config with
    max_concurrent_analyses = 1;
    analysis_timeout_ms = 5000;
    enable_caching = false;
  };
  evaluation = {
    default_evaluation_config with
    strict_mode = true;
    enable_suggestions = false;
  };
}

(** 设置环境配置 *)
let set_environment_config = function
  | "development" | "dev" -> update_config development_config
  | "production" | "prod" -> update_config production_config
  | "testing" | "test" -> update_config testing_config
  | _ -> update_config default_system_config

(** {1 配置验证} *)

(** 验证配置合法性 *)
let validate_config config =
  let errors = ref [] in
  
  (* 验证性能配置 *)
  if config.performance.max_concurrent_analyses <= 0 then
    errors := "最大并发数必须大于0" :: !errors;
  
  if config.performance.analysis_timeout_ms <= 0 then
    errors := "分析超时时间必须大于0" :: !errors;
    
  if config.performance.cache_size_limit <= 0 then
    errors := "缓存大小限制必须大于0" :: !errors;
  
  (* 验证评价配置 *)
  if config.evaluation.max_suggestions <= 0 then
    errors := "最大建议数量必须大于0" :: !errors;
  
  (* 验证数据源配置 *)
  if config.data_sources.validation_level < 1 || config.data_sources.validation_level > 5 then
    errors := "数据验证级别必须在1-5之间" :: !errors;
  
  List.rev !errors

(** 验证当前配置 *)
let validate_current_config () = validate_config (get_config ())

(** {1 配置序列化} *)

(** 日志级别转字符串 *)
let log_level_to_string = function
  | Debug -> "debug"
  | Info -> "info"
  | Warning -> "warning"
  | Error -> "error"
  | Critical -> "critical"

(** 字符串转日志级别 *)
let string_to_log_level = function
  | "debug" -> Some Debug
  | "info" -> Some Info
  | "warning" -> Some Warning
  | "error" -> Some Error
  | "critical" -> Some Critical
  | _ -> None

(** 导出配置摘要 *)
let export_config_summary config = [
  ("版本", config.version);
  ("调试模式", string_of_bool config.debug_mode);
  ("日志级别", log_level_to_string config.log_level);
  ("严格模式", string_of_bool config.evaluation.strict_mode);
  ("最大并发", string_of_int config.performance.max_concurrent_analyses);
  ("分析超时", string_of_int config.performance.analysis_timeout_ms);
  ("启用缓存", string_of_bool config.performance.enable_caching);
  ("缓存大小", string_of_int config.performance.cache_size_limit);
  ("数据目录", config.data_sources.data_dir);
  ("自动检测诗体", string_of_bool config.evaluation.auto_form_detection);
  ("生成建议", string_of_bool config.evaluation.enable_suggestions);
  ("最大建议数", string_of_int config.evaluation.max_suggestions);
]

(** {1 配置预设管理} *)

(** 配置预设 *)
type config_preset = {
  name : string;
  description : string;
  config : system_config;
}

(** 所有预设配置 *)
let all_presets = [
  {
    name = "default";
    description = "默认平衡配置，适用于大多数场景";
    config = default_system_config;
  };
  {
    name = "development";
    description = "开发环境配置，启用调试和详细日志";
    config = development_config;
  };
  {
    name = "production";
    description = "生产环境配置，优化性能和稳定性";
    config = production_config;
  };
  {
    name = "testing";
    description = "测试环境配置，严格模式和确定性行为";
    config = testing_config;
  };
  {
    name = "classical_strict";
    description = "古典严格模式，专业级古典标准";
    config = {
      default_system_config with
      evaluation = {
        default_evaluation_config with
        default_standard = Unified_artistic_standards.professional_classical_standard;
        strict_mode = true;
      };
    };
  };
  {
    name = "modern_relaxed";
    description = "现代宽松模式，大众级现代标准";
    config = {
      default_system_config with
      evaluation = {
        default_evaluation_config with
        default_standard = Unified_artistic_standards.popular_modern_standard;
        strict_mode = false;
        max_suggestions = 8;
      };
    };
  };
]

(** 根据名称获取预设 *)
let get_preset name =
  List.find_opt (fun preset -> preset.name = name) all_presets

(** 应用预设配置 *)
let apply_preset name =
  match get_preset name with
  | Some preset -> update_config preset.config; true
  | None -> false

(** 列出所有预设 *)
let list_presets () =
  List.map (fun preset -> (preset.name, preset.description)) all_presets

(** {1 运行时配置调整} *)

(** 临时配置修改 *)
let with_temporary_config temp_config f =
  let original_config = get_config () in
  update_config temp_config;
  let result = f () in
  update_config original_config;
  result

(** 临时设置调试模式 *)
let with_debug_mode enabled f =
  let temp_config = { (get_config ()) with debug_mode = enabled } in
  with_temporary_config temp_config f

(** 临时设置严格模式 *)
let with_strict_mode enabled f =
  let config = get_config () in
  let eval_config = config.evaluation in
  let new_eval_config = { eval_config with strict_mode = enabled } in
  let temp_config = { config with evaluation = new_eval_config } in
  with_temporary_config temp_config f

(** {1 向后兼容接口} *)

(** 兼容旧版本的简单配置 *)
type legacy_config = {
  debug : bool;
  strict : bool;
  cache_enabled : bool;
  max_suggestions : int;
}

(** 转换为旧版本配置 *)
let to_legacy_config config = {
  debug = config.debug_mode;
  strict = config.evaluation.strict_mode;
  cache_enabled = config.performance.enable_caching;
  max_suggestions = config.evaluation.max_suggestions;
}

(** 从旧版本配置转换 *)
let from_legacy_config legacy =
  let config = get_config () in
  let eval_config = config.evaluation in
  let perf_config = config.performance in
  {
    config with
    debug_mode = legacy.debug;
    evaluation = { eval_config with 
                   strict_mode = legacy.strict;
                   max_suggestions = legacy.max_suggestions };
    performance = { perf_config with enable_caching = legacy.cache_enabled };
  }

(** 获取旧版本兼容配置 *)
let get_legacy_config () = to_legacy_config (get_config ())

(** 设置旧版本兼容配置 *)
let set_legacy_config legacy = update_config (from_legacy_config legacy)