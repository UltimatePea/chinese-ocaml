(** 词法分析器关键字处理模块接口 *)

val convert_token : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
(** 将Token_mapping.Token_definitions_unified.token转换为Lexer_tokens.token 使用模块化设计替代原来的144行巨型函数 *)

val variant_to_token :
  [> `AcceptKeyword
  | `AddToKeyword
  | `AfterThatKeyword
  | `AlsoKeyword
  | `AncientAddToKeyword
  | `AncientAlgorithmKeyword
  | `AncientAnswerKeyword
  | `AncientArrowKeyword
  | `AncientAsOneKeyword
  | `AncientBeginKeyword
  | `AncientCallItKeyword
  | `AncientCombineKeyword
  | `AncientCommaKeyword
  | `AncientCompleteKeyword
  | `AncientDefineKeyword
  | `AncientEmptyKeyword
  | `AncientEndCompleteKeyword
  | `AncientEndKeyword
  | `AncientHasHeadTailKeyword
  | `AncientHeadNameKeyword
  | `AncientIsKeyword
  | `AncientItsFirstKeyword
  | `AncientItsSecondKeyword
  | `AncientItsThirdKeyword
  | `AncientListEndKeyword
  | `AncientListStartKeyword
  | `AncientNatureKeyword
  | `AncientObserveEndKeyword
  | `AncientObserveKeyword
  | `AncientOtherwiseKeyword
  | `AncientParticleFun
  | `AncientParticleThe
  | `AncientReceiveKeyword
  | `AncientRecordEmptyKeyword
  | `AncientRecordEndKeyword
  | `AncientRecordFinishKeyword
  | `AncientRecordStartKeyword
  | `AncientRecordUpdateKeyword
  | `AncientTailNameKeyword
  | `AncientTakeKeyword
  | `AncientThenKeyword
  | `AncientThusAnswerKeyword
  | `AncientWhenKeyword
  | `AndKeyword
  | `ArrayTypeKeyword
  | `AsForKeyword
  | `AsKeyword
  | `BoolTypeKeyword
  | `CallKeyword
  | `CatchKeyword
  | `CharacterCountKeyword
  | `CombineKeyword
  | `DefineKeyword
  | `DivideKeyword
  | `ElseKeyword
  | `ElseReturnKeyword
  | `EmptyKeyword
  | `EndCloudKeyword
  | `EndKeyword
  | `EqualToKeyword
  | `ExceptionKeyword
  | `ExpandKeyword
  | `FalseKeyword
  | `FinallyKeyword
  | `FirstElementKeyword
  | `FloatTypeKeyword
  | `ForThisKeyword
  | `FunKeyword
  | `ParamKeyword
  | `FunctorKeyword
  | `GreaterThanWenyan
  | `HaveKeyword
  | `IdentifierTokenSpecial
  | `IfKeyword
  | `IfWenyanKeyword
  | `InKeyword
  | `IncludeKeyword
  | `InputKeyword
  | `IntTypeKeyword
  | `LessThanEqualToKeyword
  | `LessThanWenyan
  | `LetKeyword
  | `ListTypeKeyword
  | `MacroKeyword
  | `MatchKeyword
  | `MinusOneKeyword
  | `ModuleKeyword
  | `ModuleTypeKeyword
  | `MultiplyKeyword
  | `MustFirstGetKeyword
  | `NameKeyword
  | `NotKeyword
  | `NumberKeyword
  | `OfKeyword
  | `OfParticle
  | `OneKeyword
  | `OrKeyword
  | `OtherKeyword
  | `OutputKeyword
  | `PlusKeyword
  | `PrivateKeyword
  | `RaiseKeyword
  | `RecKeyword
  | `RefKeyword
  | `RemainingKeyword
  | `ReturnWhenKeyword
  | `SetKeyword
  | `ShouldGetKeyword
  | `SigKeyword
  | `SmallKeyword
  | `StringTypeKeyword
  | `SubtractKeyword
  | `TagKeyword
  | `ThenGetKeyword
  | `ThenKeyword
  | `ThenWenyanKeyword
  | `TimesKeyword
  | `TrueKeyword
  | `TryKeyword
  | `TypeKeyword
  | `UnitTypeKeyword
  | `ValueKeyword
  | `VariantKeyword
  | `WantExecuteKeyword
  | `WhenKeyword
  | `WhereKeyword
  | `WithDefaultKeyword
  | `WithKeyword
  | `WithOpKeyword ] ->
  Lexer_tokens.token
(** 将关键字变体转换为对应的token
    @param variant 关键字变体（多态变体）
    @return 对应的Lexer_tokens.token
    @raise Failure 如果变体无法识别 *)

val find_keyword : string -> Lexer_tokens.token option
(** 查找关键字
    @param str 要查找的字符串
    @return 如果是关键字则返回Some token，否则返回None *)
