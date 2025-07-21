(** 系统配置常量模块接口 *)

val default_hash_table_size : int
(** 哈希表大小 *)

val large_hash_table_size : int

val default_cache_size : int
(** 缓存大小 *)

val large_cache_size : int

val utf8_char_max_bytes : int
(** 字符串处理 *)

val utf8_char_buffer_size : int
val string_slice_length : int

val percentage_multiplier : float
(** 数值常量 *)

val max_recursion_depth : int
val default_timeout_ms : int

val file_chunk_size : int
(** 文件处理 *)

val max_file_size : int

val max_verse_length : int
(** 诗词相关配置 *)

val max_poem_lines : int
val default_rhyme_scheme_length : int
