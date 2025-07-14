(** 中文编程最佳实践检查器接口 - Chinese Programming Best Practices Checker Interface *)

(** 最佳实践违规类型 *)
type practice_violation = 
  | MixedLanguage of string * string * string  (** 混用中英文：位置 * 中文部分 * 英文部分 *)
  | ImproperWordOrder of string * string * string  (** 不当语序：位置 * 当前 * 建议 *)
  | Unidiomatic of string * string * string  (** 不地道表达：位置 * 当前 * 建议 *)
  | InconsistentStyle of string * string * string  (** 风格不一致：位置 * 当前风格 * 推荐风格 *)
  | ModernizationSuggestion of string * string * string  (** 现代化建议：位置 * 古雅体 * 现代表达 *)

(** 违规严重度 *)
type severity = 
  | Error      (** 错误：必须修复 *)
  | Warning    (** 警告：建议修复 *)
  | Info       (** 信息：可选改进 *)
  | Style      (** 风格：编码风格建议 *)

(** 最佳实践检查结果 *)
type practice_check_result = {
  violation: practice_violation;     (** 违规记录 *)
  severity: severity;               (** 严重程度 *)
  message: string;                  (** 违规消息 *)
  suggestion: string;               (** 改进建议 *)
  confidence: float;                (** 置信度 *)
  ai_friendly: bool;                (** 是否对AI友好 *)
}

(** 主要功能函数 *)

(** 综合最佳实践检查
    @param code 要检查的代码字符串
    @return 检查结果列表 *)
val comprehensive_practice_check : string -> practice_check_result list

(** 生成实践检查报告
    @param results 检查结果列表
    @return 格式化的报告字符串 *)
val generate_practice_report : practice_check_result list -> string

(** 特定检查功能 *)

(** 检测中英文混用模式
    @param code 要检查的代码
    @return 检查结果列表 *)
val detect_mixed_language_patterns : string -> practice_check_result list

(** 检查中文语序
    @param code 要检查的代码
    @return 检查结果列表 *)
val check_chinese_word_order : string -> practice_check_result list

(** 检查地道中文表达
    @param code 要检查的代码
    @return 检查结果列表 *)
val check_idiomatic_chinese : string -> practice_check_result list

(** 检查风格一致性
    @param code 要检查的代码
    @return 检查结果列表 *)
val check_style_consistency : string -> practice_check_result list

