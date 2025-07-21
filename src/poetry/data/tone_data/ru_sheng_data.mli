(** 入声字符数据模块接口

    提供入声声调汉字字符的访问功能。 入声是诗词韵律中的重要声调之一。 *)

val ru_sheng_chars : string list
(** 入声字符数据列表 - 包含47个入声字符 *)

val get_ru_sheng_chars : unit -> string list
(** 获取入声字符列表 *)

val is_ru_sheng : string -> bool
(** 检查字符是否为入声 *)
