(** 违规报告生成器接口 *)

open Chinese_best_practices_types.Severity_types

val get_severity_icon : severity -> string
(** 获取严重程度图标 *)

val get_severity_text : severity -> string
(** 获取严重程度文本 *)

val count_violations_by_severity : practice_check_result list -> int * int * int * int
(** 统计违规数量 *)

val generate_violation_details : practice_check_result list -> string
(** 生成违规详细报告 *)

val generate_stats_report : practice_check_result list -> string
(** 生成统计报告 *)

val generate_improvement_suggestions : practice_check_result list -> string
(** 生成改进建议 *)

val generate_success_report : unit -> string
(** 生成成功报告 *)

val generate_practice_report : practice_check_result list -> string
(** 生成完整报告 *)
