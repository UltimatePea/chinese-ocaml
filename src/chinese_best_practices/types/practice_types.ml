(** 骆言中文编程最佳实践核心类型定义 *)

(** 最佳实践违规类型 *)
type practice_violation =
  | MixedLanguage of string * string * string (* 混用中英文：位置 * 中文部分 * 英文部分 *)
  | ImproperWordOrder of string * string * string (* 不当语序：位置 * 当前 * 建议 *)
  | Unidiomatic of string * string * string (* 不地道表达：位置 * 当前 * 建议 *)
  | InconsistentStyle of string * string * string (* 风格不一致：位置 * 当前风格 * 推荐风格 *)
  | ModernizationSuggestion of string * string * string (* 现代化建议：位置 * 古雅体 * 现代表达 *)
