(** 上声字符数据模块 - 重构版本

    重构后的上声字符数据模块，使用JSON外化数据替代硬编码列表。
    上声是诗词韵律中的重要声调之一，音上扬，如询问之声。

    @author 骆言诗词编程团队
    @version 2.0 - JSON数据外化重构  
    @since 2025-07-21 *)

(** 上声字符数据列表 - 从JSON文件动态加载 *)
let shang_sheng_chars = lazy (Tone_data_json_loader.get_shang_sheng_chars ())

(** 获取上声字符列表 *)
let get_shang_sheng_chars () = Lazy.force shang_sheng_chars

(** 检查字符是否为上声 *)
let is_shang_sheng char = List.mem char (get_shang_sheng_chars ())

(** 上声字符数量 *)
let count_shang_sheng () = List.length (get_shang_sheng_chars ())