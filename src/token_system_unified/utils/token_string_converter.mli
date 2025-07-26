(** Token字符串转换模块接口

    优化重构版本，提供Token到字符串的高效转换功能。 从300行优化为紧凑结构，提升可维护性。 *)

open Token_types_core
open Error_types

val string_of_token_safe : unified_token -> string unified_result
(** 将Token安全地转换为字符串表示

    处理所有类型的Token，包括：
    - 字面量Token (整数、浮点数、字符串、布尔值等)
    - 标识符Token (普通标识符、构造器、引用标识符等)
    - 关键字Token (基础关键字、文言关键字、古雅体关键字等)
    - 运算符Token (算术、逻辑、比较、赋值运算符等)
    - 分隔符Token (括号、逗号、分号等)

    @param token 要转换的Token
    @return 转换成功时返回Ok(字符串)，失败时返回Error(错误信息) *)

val string_of_token : unified_token -> string
(** 将Token转换为字符串表示（兼容版本）

    这是string_of_token_safe的兼容版本，失败时返回"<UNKNOWN_TOKEN>"而不是抛出异常。 适用于需要容错处理的场景。

    @param token 要转换的Token
    @return Token的字符串表示，无法识别时返回"<UNKNOWN_TOKEN>" *)
