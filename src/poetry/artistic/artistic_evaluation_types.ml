(** 诗词艺术评估统一类型系统模块 - Issue #2135 整合实施
 *
 * 此文件为Issue #2000-A的统一类型系统模块，整合所有艺术评估相关的类型定义。
 * 整合了以下源文件的类型定义：
 * - src/poetry/artistic_types.ml: 基础艺术类型
 * - src/poetry/artistic_standards.ml: 艺术标准类型  
 * - src/poetry/poetry_artistic_standards.ml: 诗词艺术标准
 * - src/poetry/artistic_evaluation_engine.ml: 评估引擎类型
 *
 * 真正整合：合并功能 + 删除原文件
 * 
 * @consolidation_issue #2135 (子任务 #2000-A)
 * @author Whisky, PR Worker
 * @since 2025-08-03
 *)

open Poetry_core.Types

(** {1 基础评估类型} *)

(** 艺术评估维度类型 - 重新导出core类型保持一致性 *)
type evaluation_dimension = Poetry_core.Types.artistic_dimension

(** 评估精度级别 *)
type evaluation_precision =
  | Basic       (** 基础评估 *)
  | Standard    (** 标准评估 *)
  | Professional (** 专业评估 *)
  | Expert      (** 专家级评估 *)

(** 评估模式 *)
type evaluation_mode =
  | Quick       (** 快速评估 *)
  | Comprehensive (** 综合评估 *)
  | Comparative (** 比较评估 *)
  | Interactive (** 交互式评估 *)

(** 评估上下文 *)
type evaluation_context = {
  precision: evaluation_precision;
  mode: evaluation_mode;
  focus_dimensions: evaluation_dimension list;
  reference_standards: string list;
  user_preferences: (string * string) list;
}

(** {1 诗词形式规范类型} *)

(** 声调类型 *)
type tone_type =
  | Ping       (** 平声 *)
  | Ze         (** 仄声 *)
  | Unknown    (** 未知 *)

(** 韵律要求 *)
type rhyme_requirement = {
  rhyme_scheme: string;           (** 韵律模式，如"ABAB" *)
  tone_pattern: tone_type list;   (** 平仄模式 *)
  required_lines: int;            (** 要求行数 *)
  allow_flexibility: bool;        (** 是否允许灵活性 *)
}

(** 对仗要求 *)
type parallelism_requirement = {
  positions: int list;            (** 要求对仗的位置 *)
  strictness: [`Strict | `Moderate | `Loose]; (** 对仗严格程度 *)
  type_matching: bool;            (** 是否要求词性匹配 *)
}

(** 诗词形式规范 *)
type poetry_form_specification = {
  form: poetry_form;
  line_count: int;
  chars_per_line: int option;     (** None表示不限制 *)
  rhyme_req: rhyme_requirement option;
  parallelism_req: parallelism_requirement option;
  special_requirements: string list;
}

(** {1 艺术标准类型} *)

(** 标准权重配置 *)
type weight_configuration = {
  dimension: evaluation_dimension;
  weight: float;
  min_threshold: float;           (** 最低阈值 *)
  excellence_threshold: float;    (** 优秀阈值 *)
}

(** 艺术评估标准 *)
type artistic_standard = {
  id: string;
  name: string;
  description: string;
  applicable_forms: poetry_form list;
  weight_config: weight_configuration list;
  minimum_overall_score: float;
  excellence_overall_score: float;
  evaluation_criteria: (evaluation_dimension * string list) list;
}

(** 标准应用结果 *)
type standard_application_result = {
  standard: artistic_standard;
  applicable: bool;
  compliance_score: float;
  dimension_scores: (evaluation_dimension * float) list;
  compliance_details: string;
  recommendations: string list;
}

(** {1 评估结果类型} *)

(** 单维度详细评估 *)
type dimension_evaluation = {
  dimension: evaluation_dimension;
  raw_score: float;
  weighted_score: float;
  weight: float;
  feedback: string;
  evidence: string list;
  improvement_suggestions: string list;
  confidence: float;              (** 评估置信度 *)
}

(** 综合评估报告 *)
type comprehensive_evaluation_report = {
  text_input: string;
  detected_form: poetry_form option;
  applied_standards: artistic_standard list;
  dimension_evaluations: dimension_evaluation list;
  overall_score: float;
  final_grade: evaluation_grade;
  summary_feedback: string;
  strengths: string list;
  weaknesses: string list;
  improvement_plan: string list;
  confidence_level: evaluation_precision;
}

(** 比较评估结果 *)
type comparative_evaluation = {
  text1: string;
  text2: string;
  dimension_comparisons: (evaluation_dimension * float * float * string) list;
  overall_comparison: [`Text1Better | `Text2Better | `Equivalent];
  comparative_analysis: string;
  recommendation: string;
}

(** {1 缓存和性能类型} *)

(** 评估缓存条目 *)
type evaluation_cache_entry = {
  text_hash: string;
  context_hash: string;
  evaluation: comprehensive_evaluation_report;
  timestamp: float;
  access_count: int;
}

(** 缓存配置 *)
type cache_configuration = {
  max_entries: int;
  ttl_seconds: float;
  enable_compression: bool;
  eviction_policy: [`LRU | `LFU | `TTL];
}

(** 性能指标 *)
type performance_metrics = {
  evaluation_time_ms: float;
  cache_hit_rate: float;
  memory_usage_mb: float;
  api_response_time_ms: float;
}

(** {1 数据管理类型} *)

(** 数据源配置 *)
type data_source_config = {
  source_type: [`File | `Database | `Memory];
  location: string;
  encoding: string;
  validation_enabled: bool;
}

(** 评估数据集 *)
type evaluation_dataset = {
  standards: artistic_standard list;
  reference_examples: (string * comprehensive_evaluation_report) list;
  dimension_weights: (evaluation_dimension * float) list;
  form_specifications: poetry_form_specification list;
}

(** 数据加载状态 *)
type data_loading_status = {
  loaded: bool;
  loading_time_ms: float;
  data_version: string;
  last_update: float;
  integrity_verified: bool;
}

(** {1 错误和状态类型} *)

(** 评估错误类型 *)
type evaluation_error =
  | InvalidInput of string
  | UnsupportedForm of poetry_form
  | MissingData of string
  | ComputationError of string
  | CacheError of string
  | ConfigurationError of string

(** 评估状态 *)
type evaluation_status =
  | NotStarted
  | InProgress of float  (** 进度百分比 *)
  | Completed of comprehensive_evaluation_report
  | Failed of evaluation_error
  | Cancelled

(** 系统健康状态 *)
type system_health = {
  data_loaded: bool;
  cache_operational: bool;
  memory_usage_ok: bool;
  response_time_ok: bool;
  last_check: float;
}

(** {1 配置类型} *)

(** 评估系统配置 *)
type evaluation_system_config = {
  default_precision: evaluation_precision;
  default_mode: evaluation_mode;
  cache_config: cache_configuration;
  data_sources: data_source_config list;
  performance_thresholds: (string * float) list;
  debug_mode: bool;
}

(** 用户偏好设置 *)
type user_preferences = {
  preferred_precision: evaluation_precision;
  focus_dimensions: evaluation_dimension list;
  output_format: [`Detailed | `Summary | `JSON];
  language: [`Chinese | `English];
  include_suggestions: bool;
}

(** {1 实用工具类型} *)

(** 版本信息 *)
type version_info = {
  major: int;
  minor: int;
  patch: int;
  build: string;
  release_date: string;
}

(** API响应封装 *)
type 'a api_response = {
  success: bool;
  data: 'a option;
  error: evaluation_error option;
  metadata: (string * string) list;
  performance: performance_metrics option;
}

(** {1 类型转换函数} *)

(** 评估精度转字符串 *)
let precision_to_string = function
  | Basic -> "基础"
  | Standard -> "标准"  
  | Professional -> "专业"
  | Expert -> "专家"

(** 评估模式转字符串 *)
let mode_to_string = function
  | Quick -> "快速"
  | Comprehensive -> "综合"
  | Comparative -> "比较"
  | Interactive -> "交互"

(** 声调类型转字符串 *)
let tone_to_string = function
  | Ping -> "平"
  | Ze -> "仄" 
  | Unknown -> "未知"

(** 错误类型转字符串 *)
let error_to_string = function
  | InvalidInput msg -> "输入无效: " ^ msg
  | UnsupportedForm form -> "不支持的诗词形式: " ^ (poetry_form_to_string form)
  | MissingData item -> "缺失数据: " ^ item
  | ComputationError msg -> "计算错误: " ^ msg
  | CacheError msg -> "缓存错误: " ^ msg
  | ConfigurationError msg -> "配置错误: " ^ msg

(** 评估状态转字符串 *)
let status_to_string = function
  | NotStarted -> "未开始"
  | InProgress progress -> Printf.sprintf "进行中 (%.1f%%)" (progress *. 100.0)
  | Completed _ -> "已完成"
  | Failed error -> "失败: " ^ (error_to_string error)
  | Cancelled -> "已取消"

(** {1 类型验证函数} *)

(** 验证权重配置 - 用于dimension_evaluation类型 *)
let validate_dimension_evaluation_weights weights =
  let total_weight = List.fold_left (fun acc w -> acc +. w.weight) 0.0 weights in
  abs_float (total_weight -. 1.0) < 0.001

(** 验证艺术标准权重配置 *)
let validate_weight_configuration weight_configs =
  let total_weight = List.fold_left (fun acc wc -> acc +. wc.weight) 0.0 weight_configs in
  abs_float (total_weight -. 1.0) < 0.001

(** 验证评估上下文 *)
let validate_evaluation_context context =
  match context.focus_dimensions with
  | [] -> false  (* 至少需要一个评估维度 *)
  | _ -> true

(** 验证艺术标准 *)
let validate_artistic_standard standard =
  (* TODO: Fix type confusion bug - see issue in validate_weight_configuration *)
  true &&
  standard.minimum_overall_score >= 0.0 &&
  standard.minimum_overall_score <= 1.0 &&
  standard.excellence_overall_score >= standard.minimum_overall_score &&
  standard.excellence_overall_score <= 1.0

(** {1 默认配置} *)

(** 默认评估上下文 *)
let default_evaluation_context = {
  precision = Standard;
  mode = Comprehensive;
  focus_dimensions = [RhymeHarmony; TonalBalance; Parallelism; Imagery];
  reference_standards = [];
  user_preferences = [];
}

(** 默认缓存配置 *)
let default_cache_configuration = {
  max_entries = 1000;
  ttl_seconds = 3600.0;  (* 1小时 *)
  enable_compression = true;
  eviction_policy = `LRU;
}

(** 默认系统配置 *)
let default_system_config = {
  default_precision = Standard;
  default_mode = Comprehensive;
  cache_config = default_cache_configuration;
  data_sources = [];
  performance_thresholds = [
    ("max_response_time_ms", 5000.0);
    ("max_memory_usage_mb", 512.0);
    ("min_cache_hit_rate", 0.7);
  ];
  debug_mode = false;
}