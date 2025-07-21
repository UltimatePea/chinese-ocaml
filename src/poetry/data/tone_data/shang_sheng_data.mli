(** 上声字符数据模块接口

    提供上声声调汉字字符的访问功能。 上声是诗词韵律中的重要声调之一。 *)

val shang_sheng_chars : string list
(** 上声字符数据列表 - 包含76个上声字符 *)

val get_shang_sheng_chars : unit -> string list
(** 获取上声字符列表 *)

val is_shang_sheng : string -> bool
(** 检查字符是否为上声 *)
