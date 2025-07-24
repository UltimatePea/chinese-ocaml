(** 系统配置常量模块 - 向后兼容性包装器 *)

(** 重新导出来自统一常量模块的系统常量 *)
include Core_constants.System

(** 缓冲区相关常量 *)
let utf8_char_max_bytes = Core_constants.Buffers.utf8_char_max_bytes
let utf8_char_buffer_size = Core_constants.Buffers.utf8_char_buffer_size
let file_chunk_size = Core_constants.Buffers.file_chunk_size
let max_file_size = Core_constants.Buffers.max_file_size

(** 数值相关常量 *)
let percentage_multiplier = Core_constants.Numbers.percentage_multiplier

(** 诗词相关常量 *)
let max_verse_length = Core_constants.Poetry.max_verse_length
let max_poem_lines = Core_constants.Poetry.max_poem_lines
let default_rhyme_scheme_length = Core_constants.Poetry.default_rhyme_scheme_length
