(** ANSI颜色代码常量模块 *)

(** 基础颜色 *)
let red = "\027[31m"
let green = "\027[32m"
let yellow = "\027[33m"
let blue = "\027[34m"
let magenta = "\027[35m"
let cyan = "\027[36m"
let white = "\027[37m"

(** 亮色 *)
let bright_red = "\027[91m"
let bright_green = "\027[92m"
let bright_yellow = "\027[93m"
let bright_blue = "\027[94m"
let bright_magenta = "\027[95m"
let bright_cyan = "\027[96m"
let bright_white = "\027[97m"

(** 样式 *)
let bold = "\027[1m"
let dim = "\027[2m"
let italic = "\027[3m"
let underline = "\027[4m"
let blink = "\027[5m"
let reverse = "\027[7m"
let strikethrough = "\027[9m"

(** 重置 *)
let reset = "\027[0m"

(** 便捷函数 *)
let with_color color_code message = color_code ^ message ^ reset

(** 预定义颜色函数 *)
let red_text message = with_color red message
let green_text message = with_color green message
let yellow_text message = with_color yellow message
let blue_text message = with_color blue message
let cyan_text message = with_color cyan message
let bold_text message = with_color bold message
let bright_red_text message = with_color bright_red message

(** 日志级别颜色 *)
let debug_color = cyan
let info_color = green
let warn_color = yellow
let error_color = red
let fatal_color = bright_red