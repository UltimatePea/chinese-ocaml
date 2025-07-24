(** 古典语言Token转换模块 - 向后兼容性包装器

    此模块为原有的lexer_token_conversion_classical.ml模块提供向后兼容性。
    现在所有功能都通过Token_conversion_core模块实现。

    @author 骆言技术债务清理团队 Issue #1066
    @version 1.0
    @since 2025-07-24 *)

let convert_wenyan_token = Token_conversion_core.convert_wenyan_token
let convert_natural_language_token = Token_conversion_core.convert_natural_language_token
let convert_ancient_token = Token_conversion_core.convert_ancient_token
let convert_classical_token = Token_conversion_core.convert_classical_token