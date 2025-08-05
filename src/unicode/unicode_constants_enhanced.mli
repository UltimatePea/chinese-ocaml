(** 骆言编译器Unicode字符处理常量模块 - 增强统一版本接口 *)

type byte_triple = int * int * int
(** 核心类型定义 *)

type char_definition = {
  name : string;
  char : string;
  bytes : byte_triple;
  category : string;
  unicode_category : string option;
}

type chinese_char_category =
  | ChineseIdeograph
  | ChinesePunctuation
  | ChineseSymbol
  | ChineseNumber
  | Poetry
  | Quote
  | Unknown

type char_processing_result =
  | ValidChar of char_definition
  | InvalidChar of string * string
  | UnsupportedChar of string

type utf8_position = { byte_offset : int; char_offset : int; line : int; column : int }

val get_char_bytes_by_name : string -> byte_triple
(** 助手函数 *)

val get_char_bytes_by_char : string -> byte_triple
val get_char_bytes_by_name_enhanced : string -> byte_triple option
val get_char_bytes_by_char_enhanced : string -> byte_triple option

(** 字符定义模块 *)
module ChineseQuotes : sig
  val left_quote_def : char_definition
  val right_quote_def : char_definition
  val string_start_def : char_definition
  val string_end_def : char_definition
  val left_quote_bytes : byte_triple
  val right_quote_bytes : byte_triple
  val string_start_bytes : byte_triple
  val string_end_bytes : byte_triple
  val all_quote_chars : char_definition list
  val is_quote_char : string -> bool
  val get_quote_pair : string -> string option
end

module ChinesePunctuation : sig
  val left_parentheses_def : char_definition
  val right_parentheses_def : char_definition
  val comma_def : char_definition
  val colon_def : char_definition
  val period_def : char_definition
  val semicolon_def : char_definition
  val pause_mark_def : char_definition
  val left_parentheses_bytes : byte_triple
  val right_parentheses_bytes : byte_triple
  val comma_bytes : byte_triple
  val colon_bytes : byte_triple
  val period_bytes : byte_triple
  val semicolon_bytes : byte_triple
  val pause_mark_bytes : byte_triple
  val all_punctuation_chars : char_definition list
  val classify_punctuation : string -> string option
  val get_punctuation_pair : string -> string option
end

module ChineseSymbols : sig
  val left_square_bracket_def : char_definition
  val right_square_bracket_def : char_definition
  val pipe_def : char_definition
  val arrow_def : char_definition
  val double_arrow_def : char_definition
  val assign_arrow_def : char_definition
  val left_square_bracket_bytes : byte_triple
  val right_square_bracket_bytes : byte_triple
  val pipe_bytes : byte_triple
  val arrow_bytes : byte_triple
  val double_arrow_bytes : byte_triple
  val assign_arrow_bytes : byte_triple
  val all_symbol_chars : char_definition list
  val classify_symbol : string -> string option
  val is_directional_symbol : string -> bool
end

module PoetrySymbols : sig
  val title_left_def : char_definition
  val title_right_def : char_definition
  val exclamation_def : char_definition
  val question_def : char_definition
  val rhyme_marker_def : char_definition
  val non_rhyme_marker_def : char_definition
  val optional_rhyme_def : char_definition
  val title_left_bytes : byte_triple
  val title_right_bytes : byte_triple
  val exclamation_bytes : byte_triple
  val question_bytes : byte_triple
  val rhyme_marker_bytes : byte_triple
  val non_rhyme_marker_bytes : byte_triple
  val optional_rhyme_bytes : byte_triple
  val all_poetry_chars : char_definition list
  val classify_poetry_symbol : string -> string option
end

module ChineseNumbers : sig
  val chinese_digit_chars : (string * string) list
  val is_chinese_number_char : string -> bool
  val get_arabic_value : string -> string option
  val is_unit_char : string -> bool
  val is_basic_digit : string -> bool
end

(** 统一字符定义 *)
module UnifiedCharDefinitions : sig
  val all_char_definitions : char_definition list
  val find_by_category : string -> char_definition list
  val find_by_char : string -> char_definition option
  val find_by_name : string -> char_definition option
  val classify_char : string -> chinese_char_category
  val process_char_sequence : string list -> char_processing_result list
end

(** 高性能查找 *)
module OptimizedLookup : sig
  val find_char_by_name_fast : string -> string option
  val find_bytes_by_char_fast : string -> byte_triple option
  val find_bytes_by_name_fast : string -> byte_triple option
  val find_definitions_by_category_fast : string -> char_definition list option
  val get_all_char_names : unit -> string list
  val get_all_chars : unit -> string list
  val get_all_categories : unit -> string list
end

(** 位置跟踪 *)
module PositionTracking : sig
  val count_utf8_chars : string -> int
  val char_offset_to_byte_offset : string -> int -> int

  val create_position :
    byte_offset:int -> char_offset:int -> line:int -> column:int -> utf8_position

  val advance_position : utf8_position -> string -> utf8_position
end

(** 字符验证 *)
module CharacterValidation : sig
  val validate_utf8_sequence : byte_triple -> bool
  val is_suitable_for_chinese_programming : string -> bool
  val suggest_alternative : string -> string option
end

(** 向后兼容性 *)
module LegacyCompatibility : sig
  module Quote : sig
    val left_quote_bytes : byte_triple
    val right_quote_bytes : byte_triple
    val string_start_bytes : byte_triple
    val string_end_bytes : byte_triple
  end

  module ChinesePunctuation : sig
    val chinese_left_paren_bytes : byte_triple
    val chinese_right_paren_bytes : byte_triple
    val chinese_comma_bytes : byte_triple
    val chinese_colon_bytes : byte_triple
    val chinese_period_bytes : byte_triple
  end

  module Fullwidth : sig
    val fullwidth_left_paren_bytes : byte_triple
    val fullwidth_right_paren_bytes : byte_triple
    val fullwidth_comma_bytes : byte_triple
    val fullwidth_colon_bytes : byte_triple
    val fullwidth_period_bytes : byte_triple
    val fullwidth_semicolon_bytes : byte_triple
    val fullwidth_pipe_bytes : byte_triple
  end

  module OtherSymbols : sig
    val chinese_minus_bytes : byte_triple
    val chinese_square_left_bracket_bytes : byte_triple
    val chinese_square_right_bracket_bytes : byte_triple
    val chinese_arrow_bytes : byte_triple
    val chinese_double_arrow_bytes : byte_triple
    val chinese_assign_arrow_bytes : byte_triple
    val chinese_pipe_bytes : byte_triple
  end

  module OptimizedLegacyAPI : sig
    val get_char_bytes_by_name : string -> byte_triple
    val get_char_bytes_by_char : string -> byte_triple
    val find_definition_by_char : string -> char_definition option
    val find_definition_by_name : string -> char_definition option
  end
end

(** 字节访问器 *)
module ByteAccessors : sig
  val get_byte1 : byte_triple -> int
  val get_byte2 : byte_triple -> int
  val get_byte3 : byte_triple -> int
  val get_bytes_tuple : byte_triple -> byte_triple
  val is_valid_bytes : byte_triple -> bool
  val bytes_to_hex_string : byte_triple -> string
  val hex_string_to_bytes : string -> byte_triple option
end

(** 统计和分析 *)
module Statistics : sig
  val get_char_statistics : unit -> int * (string, int) Hashtbl.t
  val print_statistics : unit -> unit
  val get_lookup_performance_info : unit -> int * int * int * int
  val analyze_usage_patterns : string list -> (string, int) Hashtbl.t
end
