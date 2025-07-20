(** 平声字符数据模块接口
    
    提供平声声调汉字字符的访问功能。
    平声是诗词韵律中的基础声调之一。 *)

(** 平声字符数据列表 - 包含124个平声字符 *)
val ping_sheng_chars : string list

(** 获取平声字符列表 *)
val get_ping_sheng_chars : unit -> string list

(** 检查字符是否为平声 *)
val is_ping_sheng : string -> bool