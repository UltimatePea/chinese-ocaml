(** 骆言中文编程最佳实践检查器接口 - 第二阶段技术债务重构版本
 
    配置外化重构版本的公共接口，提供懒加载的测试配置访问，
    同时保持与原始模块的向后兼容性。
    
    修复 Issue #801 - 技术债务改进第二阶段：超长函数重构和数据外化
 
    @author 骆言诗词编程团队
    @version 2.0 (配置外化重构版)
    @since 2025-07-21 - 技术债务改进第二阶段 *)

(** {1 数据类型} *)

type practice_violation = Chinese_best_practices_types.Practice_types.practice_violation =
  | MixedLanguage of string * string * string
  | ImproperWordOrder of string * string * string
  | Unidiomatic of string * string * string
  | InconsistentStyle of string * string * string
  | ModernizationSuggestion of string * string * string

type severity = Chinese_best_practices_types.Severity_types.severity =
  | Error
  | Warning
  | Info
  | Style

type practice_check_result = Chinese_best_practices_types.Severity_types.practice_check_result = {
  violation : practice_violation;
  severity : severity;
  message : string;
  suggestion : string;
  confidence : float;
  ai_friendly : bool;
}

(** {1 配置加载异常} *)

exception Test_config_error of string

(** {1 测试配置类型} *)

type test_config = {
  name : string;
  icon : string;
  test_cases : string list;
  checker_function : string -> practice_check_result list;
}

(** {1 核心功能函数} *)

(** 综合最佳实践检查 *)
val comprehensive_practice_check : 
  ?config:Chinese_best_practices_core.Practice_coordinator.check_config -> 
  string -> string

(** 简化的综合检查（用于测试） *)
val generate_practice_report : practice_check_result list -> string

(** {1 兼容性函数} *)

(** 检测中英文混用模式 *)
val detect_mixed_language_patterns : string -> practice_check_result list

(** 检查中文语序 *)
val check_chinese_word_order : string -> practice_check_result list

(** 检查地道中文表达 *)
val check_idiomatic_chinese : string -> practice_check_result list

(** 检查风格一致性 *)
val check_style_consistency : string -> practice_check_result list

(** 检查古雅体适用性 *)
val check_classical_style_appropriateness : string -> practice_check_result list

(** 检查AI友好性 *)
val check_ai_friendly_patterns : string -> practice_check_result list

(** {1 测试运行函数} *)

(** 运行单个测试套件 *)
val run_test_suite : test_config -> unit

(** 运行综合测试 *)
val run_comprehensive_test : unit -> unit

(** 打印测试统计 *)
val print_test_summary : unit -> unit

(** {1 主测试函数} *)

(** 测试中文编程最佳实践检查器 - 配置外化重构版本 *)
val test_chinese_best_practices : unit -> unit