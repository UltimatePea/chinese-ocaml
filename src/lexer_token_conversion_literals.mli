(** 字面量Token转换模块 *)

(** 转换字面量tokens
    将Token_mapping.Token_definitions中的字面量token转换为Lexer_tokens中的对应token
    @param token Token_mapping.Token_definitions中的字面量token
    @return 对应的Lexer_tokens.token
    @raise Failure 如果token不是字面量token *)
val convert_literal_token : Token_mapping.Token_definitions.token -> Lexer_tokens.token