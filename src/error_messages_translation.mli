(** 错误消息翻译模块接口 - Error Message Translation Module Interface *)

val chinese_type_error_message : string -> string
(** 将英文类型错误转换为中文 转换OCaml类型系统错误消息中的关键词和类型名称为中文表示
    @param msg 英文错误消息
    @return 翻译后的中文错误消息 *)

val chinese_runtime_error_message : string -> string
(** 将运行时错误转换为中文 转换程序运行时产生的英文错误消息为中文表示
    @param msg 英文运行时错误消息
    @return 翻译后的中文错误消息 *)
