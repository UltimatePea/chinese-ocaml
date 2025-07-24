(** 类型关键字Token转换模块 - 向后兼容性包装器

    此模块为原有的lexer_token_conversion_type_keywords.ml模块提供向后兼容性。
    现在所有功能都通过Token_conversion_core模块实现。

    @author 骆言技术债务清理团队 Issue #1066
    @version 1.0
    @since 2025-07-24 *)

let convert_type_keyword_token = Token_conversion_core.convert_type_keyword_token