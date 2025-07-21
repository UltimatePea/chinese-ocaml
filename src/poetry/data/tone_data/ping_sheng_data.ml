(** 平声字符数据模块 - 重构版本

    重构后的平声字符数据模块，使用JSON外化数据替代硬编码列表。
    平声是诗词韵律中的基础声调之一，音平而长，如江河流水。

    @author 骆言诗词编程团队
    @version 2.0 - JSON数据外化重构  
    @since 2025-07-21 *)

(** 平声字符数据列表 - 从JSON文件动态加载 *)
let ping_sheng_chars = lazy (Tone_data_json_loader.get_ping_sheng_chars ())

(** 获取平声字符列表 *)
let get_ping_sheng_chars () = Lazy.force ping_sheng_chars

(** 检查字符是否为平声 *)
let is_ping_sheng char = List.mem char (get_ping_sheng_chars ())

(** 平声字符数量 *)
let count_ping_sheng () = List.length (get_ping_sheng_chars ())
