(** 古典语言Token转换模块 - 包含文言文、古雅体和自然语言关键字 *)

val convert_wenyan_token : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
(** 转换文言文关键字tokens 将Token_mapping.Token_definitions中的文言文关键字token转换为Lexer_tokens中的对应token
    @param token Token_mapping.Token_definitions中的文言文关键字token
    @return 对应的Lexer_tokens.token
    @raise Failure 如果token不是文言文关键字token *)

val convert_natural_language_token :
  Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
(** 转换自然语言关键字tokens 将Token_mapping.Token_definitions中的自然语言关键字token转换为Lexer_tokens中的对应token
    @param token Token_mapping.Token_definitions中的自然语言关键字token
    @return 对应的Lexer_tokens.token
    @raise Failure 如果token不是自然语言关键字token *)

val convert_ancient_token : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
(** 转换古雅体关键字tokens 将Token_mapping.Token_definitions中的古雅体关键字token转换为Lexer_tokens中的对应token
    @param token Token_mapping.Token_definitions中的古雅体关键字token
    @return 对应的Lexer_tokens.token
    @raise Failure 如果token不是古雅体关键字token *)

val convert_classical_token : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
(** 转换古典语言tokens - 主入口函数 尝试依次转换文言文、自然语言和古雅体关键字token
    @param token Token_mapping.Token_definitions中的古典语言token
    @return 对应的Lexer_tokens.token
    @raise Failure 如果token不是古典语言token *)
