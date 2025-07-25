(** Token兼容性分隔符映射模块接口 - 向后兼容性包装器

    此模块为原有的token_compatibility_delimiters.ml模块提供向后兼容性。
    现在所有功能都通过Token_compatibility_unified模块实现。

    @author 骆言技术债务清理团队 Issue #1235
    @version 1.0
    @since 2025-07-25 *)

(** 映射遗留分隔符到统一Token系统
    @param delimiter_string 分隔符字符串
    @return 对应的统一Token，如果无法映射则返回None *)
val map_legacy_delimiter_to_unified : string -> Unified_token_core.unified_token option