(** 骆言日志用户输出模块 - 面向用户的输出功能 *)

val success : string -> unit
(** 成功消息 *)

val warning : string -> unit
(** 警告消息 *)

val error : string -> unit
(** 错误消息 *)

val info : string -> unit
(** 信息消息 *)

val progress : string -> unit
(** 进度消息 *)

val print_user_output : string -> unit
(** 用户输出 - 程序执行结果等面向用户的信息 *)

val print_compiler_message : string -> unit
(** 编译器消息 - 编译过程中的提示信息 *)

val print_debug_info : string -> unit
(** 调试信息输出 *)

val print_user_prompt : string -> unit
(** 不换行的用户输出 - 用于提示符等 *)
