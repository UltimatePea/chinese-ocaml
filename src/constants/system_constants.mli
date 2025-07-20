(** 系统配置常量模块接口 *)

(** 哈希表大小 *)
val default_hash_table_size : int
val large_hash_table_size : int

(** 缓存大小 *)
val default_cache_size : int
val large_cache_size : int

(** 字符串处理 *)
val utf8_char_max_bytes : int
val utf8_char_buffer_size : int
val string_slice_length : int

(** 数值常量 *)
val percentage_multiplier : float
val max_recursion_depth : int
val default_timeout_ms : int

(** 文件处理 *)
val file_chunk_size : int
val max_file_size : int

(** 诗词相关配置 *)
val max_verse_length : int
val max_poem_lines : int
val default_rhyme_scheme_length : int