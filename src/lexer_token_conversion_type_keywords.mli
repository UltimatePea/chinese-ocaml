(** 类型关键字Token转换模块 *)

val convert_type_keyword_token : Token_mapping.Token_definitions.token -> Lexer_tokens.token
(** 转换类型关键字tokens 将Token_mapping.Token_definitions中的类型关键字token转换为Lexer_tokens中的对应token
    @param token Token_mapping.Token_definitions中的类型关键字token
    @return 对应的Lexer_tokens.token
    @raise Failure 如果token不是类型关键字token *)
