(** Token兼容性分隔符映射模块 - 向后兼容性包装器

    此模块为原有的token_compatibility_delimiters.ml模块提供向后兼容性。 现在所有功能都通过Token_compatibility_unified模块实现。

    @author 骆言技术债务清理团队 Issue #1066
    @version 1.0
    @since 2025-07-24 *)

let map_legacy_delimiter_to_unified = Token_compatibility_unified.map_legacy_delimiter_to_unified
