(** 骆言词法分析器 - 基础关键字转换模块接口

    本模块提供基础关键字和语义关键字的转换功能。 支持从符号化关键字到Token类型的安全转换。

    @author 骆言团队
    @since 2025-07-20 *)

val convert_basic_keywords :
  Compiler_errors_types.position ->
  [> `LetKeyword
  | `RecKeyword
  | `InKeyword
  | `FunKeyword
  | `IfKeyword
  | `ThenKeyword
  | `ElseKeyword
  | `MatchKeyword
  | `WithKeyword
  | `OtherKeyword
  | `TypeKeyword
  | `PrivateKeyword
  | `TrueKeyword
  | `FalseKeyword
  | `AndKeyword
  | `OrKeyword
  | `NotKeyword
  | `OfKeyword ] ->
  Lexer_tokens.token Compiler_errors_types.error_result
(** 基础关键字转换 将基础关键字多态变体转换为对应的Token类型

    @param pos 位置信息，用于错误报告
    @param keyword 要转换的基础关键字多态变体
    @return 转换结果，成功时返回对应Token，失败时返回错误 *)

val convert_semantic_keywords :
  Compiler_errors_types.position ->
  [> `AsKeyword | `CombineKeyword | `WithOpKeyword | `WhenKeyword | `WithDefaultKeyword ] ->
  Lexer_tokens.token Compiler_errors_types.error_result
(** 语义关键字转换 将语义关键字多态变体转换为对应的Token类型

    @param pos 位置信息，用于错误报告
    @param keyword 要转换的语义关键字多态变体
    @return 转换结果，成功时返回对应Token，失败时返回错误 *)
