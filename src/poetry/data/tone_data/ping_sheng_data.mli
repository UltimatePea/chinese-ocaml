(** 平声字符数据模块接口 - 重构版本

    提供平声声调汉字字符的访问功能，使用JSON外化数据。
    平声是诗词韵律中的基础声调之一，音平而长，如江河流水。
    
    @author 骆言诗词编程团队
    @version 2.0 - JSON数据外化重构  
    @since 2025-07-21 *)

val get_ping_sheng_chars : unit -> string list
(** 获取平声字符列表 - 从JSON文件动态加载 *)

val is_ping_sheng : string -> bool
(** 检查字符是否为平声 *)

val count_ping_sheng : unit -> int
(** 获取平声字符数量 *)
