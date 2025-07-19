(** AI代理编程友好性检查器接口 - 骆言中文编程最佳实践 *)

open Chinese_best_practices_types.Severity_types

(** AI代理编程特征检查 *)
val check_ai_friendly_patterns : string -> practice_check_result list

(** 检查特定类别的AI友好性问题 *)
val check_category : string -> string -> practice_check_result list

(** 获取支持的检查类别 *)
val get_supported_categories : unit -> string list

(** 按严重程度过滤检查 *)
val check_with_severity_filter : string -> severity -> practice_check_result list