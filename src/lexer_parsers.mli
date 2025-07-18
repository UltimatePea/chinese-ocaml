(** 词法分析器解析器模块 *)

val read_string_literal : Lexer_state.lexer_state -> Lexer_tokens.token * Lexer_state.lexer_state
(** 读取字符串字面量 *)

val read_quoted_identifier : Lexer_state.lexer_state -> Lexer_tokens.token * Lexer_state.lexer_state
(** 读取引用标识符 *)
