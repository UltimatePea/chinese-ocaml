(** Token兼容性核心转换模块接口

    本模块提供核心的Token转换逻辑，协调各种映射模块并提供统一转换接口。 这是从 token_compatibility.ml 中提取出来的专门模块，提升代码可维护性。

    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 Issue #646 *)

val convert_legacy_token_string : string -> 'a option -> Yyocamlc_lib.Unified_token_core.unified_token option
(** 核心转换函数 将传统Token字符串转换为统一的Token类型 通过依次尝试关键字、运算符、分隔符、字面量和标识符映射来完成转换

    @param token_str Token字符串表示
    @param value_opt 可选的值参数
    @return 转换结果，成功时返回对应Token，失败时返回None *)

val make_compatible_positioned_token :
  string -> 'a option -> string -> int -> int -> Yyocamlc_lib.Unified_token_core.positioned_token option
(** 创建兼容的带位置Token 创建一个包含位置信息的兼容Token

    @param token_str Token字符串表示
    @param value_opt 可选的值参数
    @param filename 文件名
    @param line 行号
    @param column 列号
    @return 带位置信息的Token，失败时返回None *)

val is_compatible_with_legacy : string -> bool
(** 检查Token字符串是否与统一系统兼容 检查给定的传统Token字符串是否能成功转换为统一Token系统

    @param token_str Token字符串表示
    @return 如果可以转换返回true，否则返回false *)
