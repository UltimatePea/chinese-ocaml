(** 中文语序检查器接口 *)

open Chinese_best_practices_types.Severity_types

(** 检查中文语序问题 *)
val check_chinese_word_order : string -> practice_check_result list

(** 检查特定类别的语序问题 *)
val check_category : string -> string -> practice_check_result list

(** 获取支持的检查类别 *)
val get_supported_categories : unit -> string list

(** 按严重程度过滤检查 *)
val check_with_severity_filter : string -> severity -> practice_check_result list