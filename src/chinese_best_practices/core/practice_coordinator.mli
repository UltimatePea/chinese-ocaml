(** 中文编程最佳实践检查协调器接口 *)

open Chinese_best_practices_types.Severity_types

type check_config = {
  enable_mixed_language : bool;
  enable_word_order : bool;
  enable_idiomatic : bool;
  enable_style_consistency : bool;
  enable_classical_style : bool;
  enable_ai_friendly : bool;
  min_severity : severity;
}
(** 检查配置 *)

val default_config : check_config
(** 默认检查配置 *)

val run_basic_checks : string -> check_config -> practice_check_result list
(** 执行基础检查（已模块化的部分） *)

val filter_violations : practice_check_result list -> check_config -> practice_check_result list
(** 过滤违规结果 *)

val comprehensive_practice_check : ?config:check_config -> string -> string
(** 综合最佳实践检查（基础版） *)

val check_single_category : string -> string -> string -> practice_check_result list
(** 检查单个类别 *)

val get_supported_checker_types : unit -> string list
(** 获取支持的检查器类型 *)

val get_checker_categories : string -> string list
(** 获取检查器支持的类别 *)
