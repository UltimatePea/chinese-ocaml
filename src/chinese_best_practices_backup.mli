(** 骆言中文编程最佳实践检查器备份模块接口
    
    本模块是中文编程最佳实践检查器的备份版本，
    帮助AI代理写出更地道的中文代码。使用模块化架构，提高代码可维护性和扩展性。
    
    @author 骆言团队
    @since 2025-07-20 *)

(** 实践违规类型 *)
type practice_violation =
  | MixedLanguage of string * string * string
  | ImproperWordOrder of string * string * string
  | Unidiomatic of string * string * string
  | InconsistentStyle of string * string * string
  | ModernizationSuggestion of string * string * string

(** 严重程度类型 *)
type severity =
  | Error
  | Warning
  | Info
  | Style

(** 实践检查结果类型 *)
type practice_check_result = {
  violation : practice_violation;
  severity : severity;
  message : string;
  suggestion : string;
  confidence : float;
  ai_friendly : bool;
}

(** 综合最佳实践检查
    对给定的代码或文本进行全面的中文编程最佳实践检查
    
    @param text 要检查的代码或文本
    @return 检查结果列表 *)
val comprehensive_practice_check : string -> practice_check_result list

(** 生成最佳实践报告
    根据检查结果生成格式化的报告
    
    @param results 检查结果列表
    @return 格式化的报告字符串 *)
val generate_practice_report : practice_check_result list -> string