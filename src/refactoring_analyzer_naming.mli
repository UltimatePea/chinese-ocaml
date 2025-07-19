(** 命名质量分析器模块接口 *)

open Refactoring_analyzer_types

val is_english_naming : string -> bool
(** 检查是否为英文命名 *)

val is_mixed_naming : string -> bool
(** 检查是否为中英文混用 *)

val is_too_short : string -> bool
(** 检查是否为过短命名 *)

val is_meaningless_naming : string -> bool
(** 检查是否为常见的无意义命名 *)

val analyze_naming_quality : string -> refactoring_suggestion list
(** 分析命名质量并生成建议 *)

val analyze_multiple_names : string list -> refactoring_suggestion list
(** 批量分析多个名称的命名质量 *)

val get_naming_statistics : refactoring_suggestion list -> int * int * int * int
(** 获取命名建议的统计信息 *)

val generate_naming_report : refactoring_suggestion list -> string
(** 生成命名质量报告 *)
