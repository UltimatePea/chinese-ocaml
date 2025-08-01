(** 骆言词法分析器UTF-8字符处理工具模块 - 增强版接口 *)

(** UTF-8字符处理结果类型 *)
type utf8_char_result = 
  | ValidChar of string * int
  | InvalidSequence of int * string
  | EndOfInput

type boundary_result =
  | CharBoundary of int
  | InvalidBoundary of string
  | NoBoundary

type enhanced_position = {
  byte_pos : int;
  char_pos : int;
  line_num : int;
  col_num : int;
  context : string;
}

(** 字符检测和分类 *)
module CharacterDetection : sig
  val is_chinese_char : char -> bool
  val is_letter_or_chinese : char -> bool
  val is_digit : char -> bool
  val is_whitespace : char -> bool
  val is_separator_char : char -> bool
  val is_valid_utf8_sequence : int array -> bool
  val classify_unicode_char : string -> string
end

(** UTF-8字符序列处理 *)
module UTF8Processing : sig
  val get_utf8_char_length : char -> int
  val next_utf8_char_safe : string -> int -> utf8_char_result
  val next_utf8_char : string -> int -> (string * int) option
  val validate_utf8_string : string -> (int * string) list
  val count_utf8_chars : string -> int
  val utf8_string_to_char_list : string -> string list
end

(** 位置跟踪 *)
module PositionTracking : sig
  val create_initial_position : unit -> enhanced_position
  val advance_position : enhanced_position -> string -> enhanced_position
  val char_offset_to_byte_offset : string -> int -> int
  val byte_offset_to_char_offset : string -> int -> int
  val get_context_at_position : string -> int -> int -> string * string
end

(** 中文字符专用处理 *)
module ChineseCharProcessing : sig
  val is_chinese_digit_char : string -> bool
  val is_chinese_punctuation_char : string -> bool
  val is_poetry_symbol_char : string -> bool
  val get_chinese_char_info : string -> Unicode_constants_enhanced.char_definition option
  val validate_chinese_sequence : string list -> (string * string) list
  val suggest_chinese_alternative : string -> string option
end

(** 边界检测 *)
module BoundaryDetection : sig
  val is_word_boundary : string -> int -> bool
  val is_chinese_keyword_boundary : string -> int -> string -> bool
  val find_next_boundary : string -> int -> boundary_result
  val find_prev_boundary : string -> int -> boundary_result
end

(** 错误处理和恢复 *)
module ErrorHandling : sig
  type utf8_error = {
    position : int;
    error_type : string;
    message : string;
    context : string * string;
    suggestion : string option;
  }
  
  val create_utf8_error : string -> int -> string -> string -> utf8_error
  val format_error_message : utf8_error -> string
  val try_recover_utf8_error : string -> int -> (string * int) option
end

(** 性能优化 *)
module Performance : sig
  val get_char_info_cached : string -> Unicode_constants_enhanced.char_definition option
  val is_boundary_cached : string -> int -> bool
  val clear_caches : unit -> unit
  val get_cache_stats : unit -> int * int
end

(** 向后兼容性 *)
module LegacyCompatibility : sig
  val check_utf8_char : string -> int -> int -> int -> int -> bool
  val is_chinese_utf8 : string -> bool
  val is_valid_identifier : string -> bool
  include module type of CharacterDetection
end

(** 公共API *)
val next_utf8_char : string -> int -> (string * int) option
val is_chinese_char : char -> bool
val is_chinese_digit_char : string -> bool
val is_letter_or_chinese : char -> bool
val is_digit : char -> bool
val is_whitespace : char -> bool
val is_separator_char : char -> bool
val count_utf8_chars : string -> int
val validate_utf8_string : string -> (int * string) list