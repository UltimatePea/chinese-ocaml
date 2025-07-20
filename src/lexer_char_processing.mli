(** 骆言词法分析器 - 字符处理工具模块接口 *)

(** UTF-8字符处理函数 *)
val is_chinese_char : char -> bool
val is_letter_or_chinese : char -> bool
val is_digit : char -> bool
val is_whitespace : char -> bool
val is_separator_char : char -> bool

(** UTF-8字符串处理函数 *)
val is_chinese_utf8 : string -> bool
val next_utf8_char : string -> int -> string * int
val is_chinese_digit_char : string -> bool

(** 字符串验证函数 *)
val is_all_digits : string -> bool
val is_valid_identifier : string -> bool

(** 词法分析器状态处理 *)
val get_current_char : Lexer_state.lexer_state -> char option
val check_utf8_char : Lexer_state.lexer_state -> int -> int -> int -> bool
val make_new_state : Lexer_state.lexer_state -> Lexer_state.lexer_state
val create_unsupported_char_error : Lexer_state.lexer_state -> Lexer_tokens.position -> 'a