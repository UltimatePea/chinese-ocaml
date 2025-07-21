(** 颜色和样式格式化模块

    本模块提供统一的颜色和样式格式化功能， 通过常量模块确保样式的一致性。

    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 Issue #708 重构 *)

(** {1 ANSI颜色代码常量} *)

val red : string
(** 红色ANSI代码 *)

val green : string
(** 绿色ANSI代码 *)

val yellow : string
(** 黄色ANSI代码 *)

val blue : string
(** 蓝色ANSI代码 *)

val bold : string
(** 粗体ANSI代码 *)

val reset : string
(** 重置ANSI代码 *)

(** {1 颜色格式化函数} *)

val with_color : string -> string -> string
(** [with_color color_code message] 使用指定颜色代码包装消息文本 *)

(** {1 预定义颜色格式化函数} *)

val red_text : string -> string
(** [red_text message] 将文本格式化为红色 *)

val green_text : string -> string
(** [green_text message] 将文本格式化为绿色 *)

val yellow_text : string -> string
(** [yellow_text message] 将文本格式化为黄色 *)

val blue_text : string -> string
(** [blue_text message] 将文本格式化为蓝色 *)

val bold_text : string -> string
(** [bold_text message] 将文本格式化为粗体 *)
