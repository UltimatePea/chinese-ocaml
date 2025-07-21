(** 骆言词法分析器 - 重构后的工具函数模块接口 - 向后兼容性接口 *)

module StringParsing : module type of String_parsing
(** 子模块接口 *)

module EscapeProcessing : module type of Escape_processing
module ChineseNumberProcessing : module type of Chinese_number_processing
module FullwidthNumberProcessing : module type of Fullwidth_number_processing
module ChinesePunctuationRecognition : module type of Chinese_punctuation_recognition

val is_chinese_char : string -> bool
(** UTF-8字符处理函数 *)

val is_letter_or_chinese : string -> bool
val is_digit : char -> bool
val is_whitespace : char -> bool
val is_separator_char : char -> bool
val is_chinese_utf8 : string -> bool
val next_utf8_char : string -> int -> string * int
val is_chinese_digit_char : string -> bool

val read_string_until : Lexer_state.t -> int -> (string -> bool) -> string * int
(** 向后兼容的函数接口 *)

val parse_integer : string -> int option
val parse_float : string -> float option
val parse_hex_int : string -> int option
val parse_oct_int : string -> int option
val parse_bin_int : string -> int option
val process_escape_sequences : string -> string
val is_all_digits : string -> bool
val is_valid_identifier : string -> bool
val read_chinese_number_sequence : Lexer_state.t -> string * Lexer_state.t
val convert_chinese_number_sequence : string -> Lexer_tokens.token
val read_fullwidth_number_sequence : Lexer_state.t -> string * Lexer_state.t
val convert_fullwidth_number_sequence : string -> Lexer_tokens.token

val recognize_chinese_punctuation :
  Lexer_state.t ->
  Lexer_tokens.position ->
  (Lexer_tokens.token * Lexer_tokens.position * Lexer_state.t) option

val recognize_pipe_right_bracket :
  Lexer_state.t ->
  Lexer_tokens.position ->
  (Lexer_tokens.token * Lexer_tokens.position * Lexer_state.t) option
