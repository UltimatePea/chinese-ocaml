(** 颜色和样式格式化模块

    本模块提供统一的颜色和样式格式化功能， 通过常量模块确保样式的一致性。

    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 Issue #708 重构 *)

(** ANSI颜色代码常量 *)
let red = "\027[31m"

let green = "\027[32m"
let yellow = "\027[33m"
let blue = "\027[34m"
let bold = "\027[1m"
let reset = "\027[0m"

(** 通用颜色格式化函数 *)
let with_color color_code message = color_code ^ message ^ reset

(** 预定义颜色格式化函数 *)
let red_text message = with_color red message

let green_text message = with_color green message
let yellow_text message = with_color yellow message
let blue_text message = with_color blue message
let bold_text message = with_color bold message
