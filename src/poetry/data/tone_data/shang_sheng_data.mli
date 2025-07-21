(** 上声字符数据模块接口 - 重构版本

    提供上声声调汉字字符的访问功能，使用JSON外化数据。 上声是诗词韵律中的重要声调之一，音上扬，如询问之声。

    @author 骆言诗词编程团队
    @version 2.0 - JSON数据外化重构
    @since 2025-07-21 *)

val get_shang_sheng_chars : unit -> string list
(** 获取上声字符列表 - 从JSON文件动态加载 *)

val is_shang_sheng : string -> bool
(** 检查字符是否为上声 *)

val count_shang_sheng : unit -> int
(** 获取上声字符数量 *)
