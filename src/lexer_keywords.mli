(** 词法分析器关键字处理模块 *)

(** 将关键字变体转换为对应的token *)
val variant_to_token : [< 
  | `LetKeyword | `RecKeyword | `InKeyword | `FunKeyword
  | `IfKeyword | `ThenKeyword | `ElseKeyword | `MatchKeyword
  | `WithKeyword | `OtherKeyword | `TypeKeyword | `PrivateKeyword
  | `TrueKeyword | `FalseKeyword | `AndKeyword | `OrKeyword
  | `NotKeyword | `OfKeyword | `AsKeyword | `CombineKeyword
  | `WithOpKeyword | `WhenKeyword | `WithDefaultKeyword
  | `ExceptionKeyword | `RaiseKeyword | `TryKeyword
  | `CatchKeyword | `FinallyKeyword | `ModuleKeyword
  | `ModuleTypeKeyword | `RefKeyword | `IncludeKeyword
  | `FunctorKeyword | `SigKeyword | `EndKeyword
  | `MacroKeyword | `ExpandKeyword | `HaveKeyword
  | `OneKeyword | `NameKeyword | `SetKeyword | `AlsoKeyword
  | `ThenGetKeyword | `CallKeyword | `ValueKeyword
  | `AsForKeyword | `NumberKeyword | `WantExecuteKeyword
  | `MustFirstGetKeyword | `ForThisKeyword | `TimesKeyword
  | `EndCloudKeyword | `IfWenyanKeyword | `ThenWenyanKeyword
  | `GreaterThanWenyan | `LessThanWenyan | `DefineKeyword
  | `AcceptKeyword | `ReturnWhenKeyword | `ElseReturnKeyword
  | `MultiplyKeyword | `DivideKeyword | `AddToKeyword
  | `SubtractKeyword | `EqualToKeyword | `LessThanEqualToKeyword
  | `FirstElementKeyword | `RemainingKeyword | `EmptyKeyword
  | `CharacterCountKeyword | `OfParticle | `InputKeyword
  | `OutputKeyword | `MinusOneKeyword | `PlusKeyword
  | `WhereKeyword | `SmallKeyword | `ShouldGetKeyword
  | `IntTypeKeyword | `FloatTypeKeyword | `StringTypeKeyword
  | `BoolTypeKeyword | `UnitTypeKeyword | `ListTypeKeyword
  | `ArrayTypeKeyword | `VariantKeyword | `TagKeyword
  | `AncientDefineKeyword | `AncientEndKeyword
  | `AncientAlgorithmKeyword | `AncientCompleteKeyword
  | `AncientObserveKeyword | `AncientNatureKeyword
  | `AncientThenKeyword | `AncientOtherwiseKeyword
  | `AncientAnswerKeyword | `AncientCombineKeyword
  | `AncientAsOneKeyword | `AncientTakeKeyword
  | `AncientReceiveKeyword | `AncientParticleThe
  | `AncientParticleFun | `AncientCallItKeyword
  | `AncientListStartKeyword | `AncientListEndKeyword
  | `AncientItsFirstKeyword | `AncientItsSecondKeyword
  | `AncientItsThirdKeyword | `AncientEmptyKeyword
  | `AncientHasHeadTailKeyword | `AncientHeadNameKeyword
  | `AncientTailNameKeyword | `AncientThusAnswerKeyword
  | `AncientAddToKeyword | `AncientObserveEndKeyword
  | `AncientBeginKeyword | `AncientEndCompleteKeyword
  | `AncientIsKeyword | `AncientArrowKeyword
  | `AncientWhenKeyword | `AncientCommaKeyword
  | `AfterThatKeyword | `AncientRecordStartKeyword
  | `AncientRecordEndKeyword | `AncientRecordEmptyKeyword
  | `AncientRecordUpdateKeyword | `AncientRecordFinishKeyword
  | `IdentifierTokenSpecial
] -> Lexer_tokens.token

(** 查找关键字 *)
val find_keyword : string -> Lexer_tokens.token option