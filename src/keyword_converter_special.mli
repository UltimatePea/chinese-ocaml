(** 骆言词法分析器 - 特殊关键字转换模块接口

    本模块提供特殊类型关键字的转换功能，包括类型关键字、古典诗词关键字和特殊标识符的转换。 采用数据驱动的设计，提高维护性和扩展性。

    @author 骆言团队
    @since 2025-07-20 *)

val convert_type_keywords :
  Compiler_errors_types.position ->
  [> `IntTypeKeyword
  | `FloatTypeKeyword
  | `StringTypeKeyword
  | `BoolTypeKeyword
  | `UnitTypeKeyword
  | `ListTypeKeyword
  | `ArrayTypeKeyword
  | `VariantKeyword
  | `TagKeyword ] ->
  Lexer_tokens.token Compiler_errors_types.error_result
(** 类型关键字转换 将类型相关的关键字多态变体转换为对应的Token类型

    @param pos 位置信息，用于错误报告
    @param variant 要转换的类型关键字多态变体
    @return 转换结果，成功时返回对应Token，失败时返回错误 *)

val convert_poetry_keywords :
  Compiler_errors_types.position ->
  [> `RhymeKeyword
  | `ToneKeyword
  | `ToneLevelKeyword
  | `ToneFallingKeyword
  | `ToneRisingKeyword
  | `ToneDepartingKeyword
  | `ToneEnteringKeyword
  | `ParallelKeyword
  | `PairedKeyword
  | `AntitheticKeyword
  | `BalancedKeyword
  | `PoetryKeyword
  | `FourCharKeyword
  | `FiveCharKeyword
  | `SevenCharKeyword
  | `ParallelStructKeyword
  | `RegulatedVerseKeyword
  | `QuatrainKeyword
  | `CoupletKeyword
  | `AntithesisKeyword
  | `MeterKeyword
  | `CadenceKeyword ] ->
  Lexer_tokens.token Compiler_errors_types.error_result
(** 古典诗词关键字转换 将古典诗词相关的关键字多态变体转换为对应的Token类型

    @param pos 位置信息，用于错误报告
    @param variant 要转换的诗词关键字多态变体
    @return 转换结果，成功时返回对应Token，失败时返回错误 *)

val convert_special_identifier :
  Compiler_errors_types.position ->
  [> `IdentifierTokenSpecial ] ->
  Lexer_tokens.token Compiler_errors_types.error_result
(** 特殊标识符转换 将特殊标识符多态变体转换为对应的Token类型

    @param pos 位置信息，用于错误报告
    @param variant 要转换的特殊标识符多态变体
    @return 转换结果，成功时返回对应Token，失败时返回错误 *)
