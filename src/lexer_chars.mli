(** 词法分析器字符处理模块 *)

val check_utf8_char : Lexer_state.lexer_state -> int -> int -> int -> bool
(** 检查UTF-8字符匹配 *)

val try_match_keyword : Lexer_state.lexer_state -> (string * Lexer_tokens.token * int) option
(** 尝试匹配关键字 *)

val handle_letter_or_chinese_char :
  Lexer_state.lexer_state ->
  Lexer_tokens.position ->
  Lexer_tokens.token * Lexer_tokens.position * Lexer_state.lexer_state
(** 处理字母或中文字符 *)
