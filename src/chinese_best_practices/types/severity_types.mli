(** 骆言中文编程最佳实践严重度类型定义接口 *)

(** 违规严重度 *)
type severity =
  | Error  (** 错误：必须修复 *)
  | Warning  (** 警告：建议修复 *)
  | Info  (** 信息：可选改进 *)
  | Style  (** 风格：编码风格建议 *)

type practice_check_result = {
  violation : Practice_types.practice_violation;  (** 违规类型 *)
  severity : severity;  (** 严重度 *)
  message : string;  (** 错误消息 *)
  suggestion : string;  (** 改进建议 *)
  confidence : float;  (** 置信度 *)
  ai_friendly : bool;  (** 是否对AI友好 *)
}
(** 最佳实践检查结果 *)
