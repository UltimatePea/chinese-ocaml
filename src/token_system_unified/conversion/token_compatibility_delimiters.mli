(** Token兼容性分隔符映射模块接口

    本模块负责处理各种分隔符的映射转换，包括括号、标点符号、中文标点等。 这是从 token_compatibility.ml 中提取出来的专门模块，提升代码可维护性。

    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 Issue #646 *)

val map_legacy_delimiter_to_unified : string -> Unified_token_core.unified_token option
(** 分隔符映射 将传统分隔符字符串转换为统一的Token类型 支持各种括号、基础标点符号和中文标点符号的映射

    @param delimiter_str 分隔符字符串表示
    @return 转换结果，成功时返回对应Token，失败时返回None *)
