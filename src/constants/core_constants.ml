(** 骆言编译器核心常量模块 - 整合版本 *)

(** {1 数值常量} *)
module Numbers = struct
  (** 常用整数 *)
  let zero = 0

  let one = 1
  let two = 2
  let three = 3
  let four = 4
  let five = 5
  let ten = 10
  let hundred = 100
  let thousand = 1000

  (** 浮点数 *)
  let zero_float = 0.0

  let one_float = 1.0
  let half_float = 0.5
  let pi = 3.14159265359

  (** 比例和百分比 *)
  let full_percentage = 100.0

  let half_percentage = 50.0
  let quarter_percentage = 25.0
  let percentage_multiplier = 100.0

  (** 类型复杂度常量 *)
  let type_complexity_basic = 1

  let type_complexity_composite = 2
end

(** {1 缓冲区配置} *)
module Buffers = struct
  (** 缓冲区大小 *)
  let default_buffer_size = 1024

  let large_buffer_size = 4096
  let report_buffer_size = large_buffer_size * 4

  (** UTF-8字符处理 *)
  let utf8_char_buffer_size = 8

  let utf8_char_max_bytes = 4

  (** 文件处理 *)
  let file_chunk_size = 8192

  let max_file_size = 1048576 (* 1MB *)
end

(** {1 系统配置} *)
module System = struct
  (** 哈希表大小 *)
  let default_hash_table_size = 256

  let large_hash_table_size = 1024

  (** 缓存配置 *)
  let default_cache_size = 128

  let large_cache_size = 512

  (** 性能限制 *)
  let max_recursion_depth = 1000

  let default_timeout_ms = 5000

  (** 字符串处理 *)
  let string_slice_length = 3
end

(** {1 诗词相关配置} *)
module Poetry = struct
  let max_verse_length = 32
  let max_poem_lines = 100
  let default_rhyme_scheme_length = 8
end

(** {1 测试数据常量} *)
module Testing = struct
  let small_test_number = 100
  let large_test_number = 999999
  let factorial_test_input = 5
  let factorial_expected_result = 120
  let sum_1_to_100 = 5050
end

(** {1 向后兼容性别名} *)
(* 为了保持向后兼容性，重新导出原有的简单常量名 *)

(** 从 buffer_constants.ml 的向后兼容性 *)
let default_buffer_size = Buffers.default_buffer_size

let large_buffer_size = Buffers.large_buffer_size
let report_buffer_size = Buffers.report_buffer_size
let utf8_char_buffer_size = Buffers.utf8_char_buffer_size

(** 从 number_constants.ml 的向后兼容性 *)
let zero = Numbers.zero

let one = Numbers.one
let two = Numbers.two
let three = Numbers.three
let four = Numbers.four
let five = Numbers.five
let ten = Numbers.ten
let hundred = Numbers.hundred
let thousand = Numbers.thousand
let zero_float = Numbers.zero_float
let one_float = Numbers.one_float
let half_float = Numbers.half_float
let pi = Numbers.pi
let full_percentage = Numbers.full_percentage
let half_percentage = Numbers.half_percentage
let quarter_percentage = Numbers.quarter_percentage
let type_complexity_basic = Numbers.type_complexity_basic
let type_complexity_composite = Numbers.type_complexity_composite

(** 从 system_constants.ml 的向后兼容性 *)
let default_hash_table_size = System.default_hash_table_size

let large_hash_table_size = System.large_hash_table_size
let default_cache_size = System.default_cache_size
let large_cache_size = System.large_cache_size
let utf8_char_max_bytes = Buffers.utf8_char_max_bytes
let string_slice_length = System.string_slice_length
let percentage_multiplier = Numbers.percentage_multiplier
let max_recursion_depth = System.max_recursion_depth
let default_timeout_ms = System.default_timeout_ms
let file_chunk_size = Buffers.file_chunk_size
let max_file_size = Buffers.max_file_size
let max_verse_length = Poetry.max_verse_length
let max_poem_lines = Poetry.max_poem_lines
let default_rhyme_scheme_length = Poetry.default_rhyme_scheme_length

(** 从 test_constants.ml 的向后兼容性 *)
let small_test_number = Testing.small_test_number

let large_test_number = Testing.large_test_number
let factorial_test_input = Testing.factorial_test_input
let factorial_expected_result = Testing.factorial_expected_result
let sum_1_to_100 = Testing.sum_1_to_100
