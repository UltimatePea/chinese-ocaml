(** ANSI颜色代码常量模块接口 *)

val red : string
(** 基础颜色 *)

val green : string
val yellow : string
val blue : string
val magenta : string
val cyan : string
val white : string

val bright_red : string
(** 亮色 *)

val bright_green : string
val bright_yellow : string
val bright_blue : string
val bright_magenta : string
val bright_cyan : string
val bright_white : string

val bold : string
(** 样式 *)

val dim : string
val italic : string
val underline : string
val blink : string
val reverse : string
val strikethrough : string

val reset : string
(** 重置 *)

val with_color : string -> string -> string
(** 便捷函数 *)

val red_text : string -> string
(** 预定义颜色函数 *)

val green_text : string -> string
val yellow_text : string -> string
val blue_text : string -> string
val cyan_text : string -> string
val bold_text : string -> string
val bright_red_text : string -> string

val debug_color : string
(** 日志级别颜色 *)

val info_color : string
val warn_color : string
val error_color : string
val fatal_color : string
