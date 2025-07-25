(** 骆言编译器核心常量模块 - 整合版本 *)

(** {1 数值常量} *)
module Numbers : sig
  val zero : int
  (** 常用整数 *)

  val one : int
  val two : int
  val three : int
  val four : int
  val five : int
  val ten : int
  val hundred : int
  val thousand : int

  val zero_float : float
  (** 浮点数 *)

  val one_float : float
  val half_float : float
  val pi : float

  val full_percentage : float
  (** 比例和百分比 *)

  val half_percentage : float
  val quarter_percentage : float
  val percentage_multiplier : float

  val type_complexity_basic : int
  (** 类型复杂度常量 *)

  val type_complexity_composite : int
end

(** {1 缓冲区配置} *)
module Buffers : sig
  val default_buffer_size : int
  (** 缓冲区大小 *)

  val large_buffer_size : int
  val report_buffer_size : int

  val utf8_char_buffer_size : int
  (** UTF-8字符处理 *)

  val utf8_char_max_bytes : int

  val file_chunk_size : int
  (** 文件处理 *)

  val max_file_size : int
end

(** {1 系统配置} *)
module System : sig
  val default_hash_table_size : int
  (** 哈希表大小 *)

  val large_hash_table_size : int

  val default_cache_size : int
  (** 缓存配置 *)

  val large_cache_size : int

  val max_recursion_depth : int
  (** 性能限制 *)

  val default_timeout_ms : int

  val string_slice_length : int
  (** 字符串处理 *)
end

(** {1 诗词相关配置} *)
module Poetry : sig
  val max_verse_length : int
  val max_poem_lines : int
  val default_rhyme_scheme_length : int
end

(** {1 测试数据常量} *)
module Testing : sig
  val small_test_number : int
  val large_test_number : int
  val factorial_test_input : int
  val factorial_expected_result : int
  val sum_1_to_100 : int
end

(** {1 向后兼容性别名} *)

val default_buffer_size : int
(** 从 buffer_constants.ml 的向后兼容性 *)

val large_buffer_size : int
val report_buffer_size : int
val utf8_char_buffer_size : int

val zero : int
(** 从 number_constants.ml 的向后兼容性 *)

val one : int
val two : int
val three : int
val four : int
val five : int
val ten : int
val hundred : int
val thousand : int
val zero_float : float
val one_float : float
val half_float : float
val pi : float
val full_percentage : float
val half_percentage : float
val quarter_percentage : float
val type_complexity_basic : int
val type_complexity_composite : int

val default_hash_table_size : int
(** 从 system_constants.ml 的向后兼容性 *)

val large_hash_table_size : int
val default_cache_size : int
val large_cache_size : int
val utf8_char_max_bytes : int
val string_slice_length : int
val percentage_multiplier : float
val max_recursion_depth : int
val default_timeout_ms : int
val file_chunk_size : int
val max_file_size : int
val max_verse_length : int
val max_poem_lines : int
val default_rhyme_scheme_length : int

val small_test_number : int
(** 从 test_constants.ml 的向后兼容性 *)

val large_test_number : int
val factorial_test_input : int
val factorial_expected_result : int
val sum_1_to_100 : int
