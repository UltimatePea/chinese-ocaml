(** 中英文混用检查器接口 *)

open Chinese_best_practices_types.Severity_types

val detect_mixed_language_patterns : string -> practice_check_result list
(** 检测中英文混用模式 *)

val check_category : string -> string -> practice_check_result list
(** 检查特定类别的中英文混用问题 *)

val get_supported_categories : unit -> string list
(** 获取支持的检查类别 *)

val check_with_severity_filter : string -> severity -> practice_check_result list
(** 按严重程度过滤检查 *)
