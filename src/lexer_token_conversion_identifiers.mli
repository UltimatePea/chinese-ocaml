(** 标识符Token转换模块 *)

val convert_identifier_token : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
(** 转换标识符tokens 将Token_mapping.Token_definitions中的标识符token转换为Lexer_tokens中的对应token
    @param token Token_mapping.Token_definitions中的标识符token
    @return 对应的Lexer_tokens.token
    @raise Failure 如果token不是标识符token *)
