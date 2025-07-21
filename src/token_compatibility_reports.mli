(** Token兼容性报告生成模块接口 *)

val get_supported_legacy_tokens : unit -> string list
val generate_compatibility_report : unit -> string
val generate_detailed_compatibility_report : unit -> string
