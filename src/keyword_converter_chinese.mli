(** 骆言词法分析器 - 中文风格关键字转换模块接口

    本模块提供中文风格关键字的转换功能，包括文言文、古文和自然语言风格的关键字转换。 采用数据驱动的设计，提高维护性和扩展性。

    @author 骆言团队
    @since 2025-07-20 *)

val convert_wenyan_keywords :
  Compiler_errors_types.position ->
  [> `HaveKeyword
  | `OneKeyword
  | `NameKeyword
  | `SetKeyword
  | `AlsoKeyword
  | `ThenGetKeyword
  | `CallKeyword
  | `ValueKeyword
  | `AsForKeyword
  | `NumberKeyword
  | `WantExecuteKeyword
  | `MustFirstGetKeyword
  | `ForThisKeyword
  | `TimesKeyword
  | `EndCloudKeyword
  | `IfWenyanKeyword
  | `ThenWenyanKeyword
  | `GreaterThanWenyan
  | `LessThanWenyan ] ->
  Lexer_tokens.token Compiler_errors_types.error_result
(** 文言文风格关键字转换 将文言文风格的关键字多态变体转换为对应的Token类型

    @param pos 位置信息，用于错误报告
    @param variant 要转换的文言文关键字多态变体
    @return 转换结果，成功时返回对应Token，失败时返回错误 *)

val convert_ancient_keywords :
  Compiler_errors_types.position ->
  [> `AncientDefineKeyword
  | `AncientEndKeyword
  | `AncientAlgorithmKeyword
  | `AncientCompleteKeyword
  | `AncientObserveKeyword
  | `AncientNatureKeyword
  | `AncientThenKeyword
  | `AncientOtherwiseKeyword
  | `AncientAnswerKeyword
  | `AncientCombineKeyword
  | `AncientAsOneKeyword
  | `AncientTakeKeyword
  | `AncientReceiveKeyword
  | `AncientParticleThe
  | `AncientParticleFun
  | `AncientCallItKeyword
  | `AncientListStartKeyword
  | `AncientListEndKeyword
  | `AncientItsFirstKeyword
  | `AncientItsSecondKeyword
  | `AncientItsThirdKeyword
  | `AncientEmptyKeyword
  | `AncientHasHeadTailKeyword
  | `AncientHeadNameKeyword
  | `AncientTailNameKeyword
  | `AncientThusAnswerKeyword
  | `AncientAddToKeyword
  | `AncientObserveEndKeyword
  | `AncientBeginKeyword
  | `AncientEndCompleteKeyword
  | `AncientIsKeyword
  | `AncientArrowKeyword
  | `AncientWhenKeyword
  | `AncientCommaKeyword
  | `AncientPeriodKeyword
  | `AncientIfKeyword
  | `AncientRecursiveKeyword
  | `AncientParticleOf
  | `AfterThatKeyword
  | `AncientRecordStartKeyword
  | `AncientRecordEndKeyword
  | `AncientRecordEmptyKeyword
  | `AncientRecordUpdateKeyword
  | `AncientRecordFinishKeyword ] ->
  Lexer_tokens.token Compiler_errors_types.error_result
(** 古文关键字转换 将古文风格的关键字多态变体转换为对应的Token类型

    @param pos 位置信息，用于错误报告
    @param variant 要转换的古文关键字多态变体
    @return 转换结果，成功时返回对应Token，失败时返回错误 *)

val convert_natural_keywords :
  Compiler_errors_types.position ->
  [> `DefineKeyword
  | `AcceptKeyword
  | `ReturnWhenKeyword
  | `ElseReturnKeyword
  | `MultiplyKeyword
  | `DivideKeyword
  | `AddToKeyword
  | `SubtractKeyword
  | `EqualToKeyword
  | `LessThanEqualToKeyword
  | `FirstElementKeyword
  | `RemainingKeyword
  | `EmptyKeyword
  | `CharacterCountKeyword
  | `InputKeyword
  | `OutputKeyword
  | `MinusOneKeyword
  | `PlusKeyword
  | `WhereKeyword
  | `SmallKeyword
  | `ShouldGetKeyword
  | `OfParticle
  | `IsKeyword
  | `TopicMarker ] ->
  Lexer_tokens.token Compiler_errors_types.error_result
(** 自然语言关键字转换 将自然语言风格的关键字多态变体转换为对应的Token类型

    @param pos 位置信息，用于错误报告
    @param variant 要转换的自然语言关键字多态变体
    @return 转换结果，成功时返回对应Token，失败时返回错误 *)
