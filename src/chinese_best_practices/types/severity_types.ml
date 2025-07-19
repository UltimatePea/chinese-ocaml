(** 骆言中文编程最佳实践严重度类型定义 *)

(** 违规严重度 *)
type severity =
  | Error (* 错误：必须修复 *)
  | Warning (* 警告：建议修复 *)
  | Info (* 信息：可选改进 *)
  | Style (* 风格：编码风格建议 *)

(** 最佳实践检查结果 *)
type practice_check_result = {
  violation : Practice_types.practice_violation;
  severity : severity;
  message : string;
  suggestion : string;
  confidence : float;
  ai_friendly : bool; (* 是否对AI友好 *)
}