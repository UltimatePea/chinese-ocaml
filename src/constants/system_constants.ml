(** 系统配置常量模块 *)

(** 哈希表大小 *)
let default_hash_table_size = 256
let large_hash_table_size = 1024

(** 缓存大小 *)
let default_cache_size = 128
let large_cache_size = 512

(** 字符串处理 *)
let utf8_char_max_bytes = 4
let utf8_char_buffer_size = 8
let string_slice_length = 3

(** 数值常量 *)
let percentage_multiplier = 100.0
let max_recursion_depth = 1000
let default_timeout_ms = 5000

(** 文件处理 *)
let file_chunk_size = 8192
let max_file_size = 1048576 (* 1MB *)

(** 诗词相关配置 *)
let max_verse_length = 32
let max_poem_lines = 100
let default_rhyme_scheme_length = 8