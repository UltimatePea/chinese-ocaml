(** 中文古雅体适用性检查器接口 - 骆言中文编程最佳实践 *)

open Chinese_best_practices_types.Severity_types

(** 古雅体适用性检查 *)
val check_classical_style_appropriateness : string -> practice_check_result list

(** 检查特定类别的古雅体问题 *)
val check_category : string -> string -> practice_check_result list

(** 获取支持的检查类别 *)
val get_supported_categories : unit -> string list

(** 按严重程度过滤检查 *)
val check_with_severity_filter : string -> severity -> practice_check_result list