(** 错误信息格式化接口 - 骆言编译器 *)

open Compiler_errors_types

(** 格式化位置信息 *)
val format_position : position -> string

(** 格式化错误消息 *)
val format_error_message : compiler_error -> string

(** 格式化完整错误信息 *)
val format_error_info : error_info -> string

(** 输出错误信息到stderr *)
val print_error_info : error_info -> unit