(** 去声字符数据模块接口

    提供去声声调汉字字符的访问功能。 去声是诗词韵律中的重要声调之一。 *)

val qu_sheng_chars : string list
(** 去声字符数据列表 - 包含42个去声字符 *)

val get_qu_sheng_chars : unit -> string list
(** 获取去声字符列表 *)

val is_qu_sheng : string -> bool
(** 检查字符是否为去声 *)
