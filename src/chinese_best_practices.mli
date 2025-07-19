(** 骆言中文编程最佳实践检查器 - 帮助AI代理写出更地道的中文代码 *)

(* 引入并重新导出类型定义 *)
type practice_violation = Chinese_best_practices_types.Practice_types.practice_violation =
  | MixedLanguage of string * string * string  (** 混用中英文：位置 * 中文部分 * 英文部分 *)
  | ImproperWordOrder of string * string * string  (** 不当语序：位置 * 当前 * 建议 *)
  | Unidiomatic of string * string * string  (** 不地道表达：位置 * 当前 * 建议 *)
  | InconsistentStyle of string * string * string  (** 风格不一致：位置 * 当前风格 * 推荐风格 *)
  | ModernizationSuggestion of string * string * string  (** 现代化建议：位置 * 古雅体 * 现代表达 *)

type severity = Chinese_best_practices_types.Severity_types.severity =
  | Error  (** 错误：必须修复 *)
  | Warning  (** 警告：建议修复 *)
  | Info  (** 信息：可选改进 *)
  | Style  (** 风格：编码风格建议 *)

type practice_check_result = Chinese_best_practices_types.Severity_types.practice_check_result = {
  violation : practice_violation;
  severity : severity;
  message : string;
  suggestion : string;
  confidence : float;
  ai_friendly : bool;  (** 是否对AI友好 *)
}

(** {1 模式检测函数} *)

val detect_mixed_language_patterns : string -> practice_check_result list
(** 检测代码中的中英文混用模式 *)

val check_chinese_word_order : string -> practice_check_result list
(** 检查中文语序问题 *)

val check_idiomatic_chinese : string -> practice_check_result list
(** 检查地道的中文表达 *)

val check_style_consistency : string -> practice_check_result list
(** 检查编程风格一致性 *)

val check_classical_style_appropriateness : string -> practice_check_result list
(** 检查古雅体适用性 *)

val check_ai_friendly_patterns : string -> practice_check_result list
(** 检查AI代理友好的编程模式 *)

(** {1 主要分析函数} *)

val comprehensive_practice_check : string -> practice_check_result list
(** 执行所有最佳实践检查的综合函数 *)

val generate_practice_report : practice_check_result list -> string
(** 生成格式化的最佳实践检查报告 *)

(** {1 测试函数} *)

val test_chinese_best_practices : unit -> unit
(** 测试中文编程最佳实践检查器 *)
