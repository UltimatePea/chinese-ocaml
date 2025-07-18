(** 统一Token转换接口模块 - 重构后的模块化设计替代144行巨型函数 *)

(** 主要的token转换函数，将原来的144行巨型函数重构为模块化的设计
    将Token_mapping.Token_definitions中的token转换为Lexer_tokens中的对应token
    
    支持的token类型包括：
    - 字面量tokens (使用Lexer_token_conversion_literals模块)
    - 标识符tokens (使用Lexer_token_conversion_identifiers模块)
    - 基础关键字tokens (使用Lexer_token_conversion_basic_keywords模块)
    - 类型关键字tokens (使用Lexer_token_conversion_type_keywords模块)
    - 文言文、古雅体和自然语言关键字tokens (使用Lexer_token_conversion_classical模块)
    
    @param token Token_mapping.Token_definitions中的token
    @return 对应的Lexer_tokens.token
    @raise Failure 如果token类型不被支持 *)
val convert_token : Token_mapping.Token_definitions.token -> Lexer_tokens.token