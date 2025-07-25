(** 古典语言Token转换模块接口 - 向后兼容性包装器

    此模块为原有的lexer_token_conversion_classical.ml模块提供向后兼容性。 现在所有功能都通过Token_conversion_core模块实现。

    @author 骆言技术债务清理团队 Issue #1235
    @version 1.0
    @since 2025-07-25 *)

val convert_wenyan_token : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
(** 转换文言文Token
    @param token 输入的统一Token定义
    @return 转换后的词法分析器Token
    @raise Unknown_classical_token 如果Token无法识别 *)

val convert_natural_language_token :
  Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
(** 转换自然语言Token
    @param token 输入的统一Token定义
    @return 转换后的词法分析器Token
    @raise Unknown_classical_token 如果Token无法识别 *)

val convert_ancient_token : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
(** 转换古雅体Token
    @param token 输入的统一Token定义
    @return 转换后的词法分析器Token
    @raise Unknown_classical_token 如果Token无法识别 *)

val convert_classical_token : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
(** 转换古典语言Token - 主入口函数
    @param token 输入的统一Token定义
    @return 转换后的词法分析器Token
    @raise Unknown_classical_token 如果Token无法识别 *)
