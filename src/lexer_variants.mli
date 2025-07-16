(** 骆言词法分析器 - 变体转换模块接口 *)

(** 将多态变体转换为token类型 *)
val variant_to_token : [> 
  | `LetKeyword | `RecKeyword | `InKeyword | `FunKeyword | `IfKeyword | `ThenKeyword 
  | `ElseKeyword | `MatchKeyword | `WithKeyword | `OtherKeyword | `TypeKeyword 
  | `PrivateKeyword | `TrueKeyword | `FalseKeyword | `AndKeyword | `OrKeyword 
  | `NotKeyword | `OfKeyword | `AsKeyword | `CombineKeyword | `WithOpKeyword 
  | `WhenKeyword | `WithDefaultKeyword | `ExceptionKeyword | `RaiseKeyword 
  | `TryKeyword | `CatchKeyword | `FinallyKeyword | `ModuleKeyword 
  | `ModuleTypeKeyword | `RefKeyword | `IncludeKeyword | `FunctorKeyword 
  | `SigKeyword | `EndKeyword | `MacroKeyword | `ExpandKeyword | `HaveKeyword 
  | `OneKeyword | `NameKeyword | `SetKeyword | `AlsoKeyword | `ThenGetKeyword 
  | `CallKeyword | `ValueKeyword | `AsForKeyword | `NumberKeyword 
  | `WantExecuteKeyword | `MustFirstGetKeyword | `ForThisKeyword | `TimesKeyword 
  | `EndCloudKeyword | `IfWenyanKeyword | `ThenWenyanKeyword | `GreaterThanWenyan 
  | `LessThanWenyan | `AncientDefineKeyword | `AncientEndKeyword 
  | `AncientAlgorithmKeyword | `AncientCompleteKeyword | `AncientObserveKeyword 
  | `AncientNatureKeyword | `AncientThenKeyword | `AncientOtherwiseKeyword 
  | `AncientAnswerKeyword | `AncientCombineKeyword | `AncientAsOneKeyword 
  | `AncientTakeKeyword | `AncientReceiveKeyword | `AncientParticleThe 
  | `AncientParticleFun | `AncientCallItKeyword | `AncientListStartKeyword 
  | `AncientListEndKeyword | `AncientItsFirstKeyword | `AncientItsSecondKeyword 
  | `AncientItsThirdKeyword | `AncientEmptyKeyword | `AncientHasHeadTailKeyword 
  | `AncientHeadNameKeyword | `AncientTailNameKeyword | `AncientThusAnswerKeyword 
  | `AncientAddToKeyword | `AncientObserveEndKeyword | `AncientBeginKeyword 
  | `AncientEndCompleteKeyword | `AncientIsKeyword | `AncientArrowKeyword 
  | `AncientWhenKeyword | `AncientCommaKeyword | `AfterThatKeyword | `DefineKeyword 
  | `AcceptKeyword | `ReturnWhenKeyword | `ElseReturnKeyword | `MultiplyKeyword 
  | `DivideKeyword | `AddToKeyword | `SubtractKeyword | `EqualToKeyword 
  | `LessThanEqualToKeyword | `FirstElementKeyword | `RemainingKeyword 
  | `EmptyKeyword | `CharacterCountKeyword | `InputKeyword | `OutputKeyword 
  | `MinusOneKeyword | `PlusKeyword | `WhereKeyword | `SmallKeyword 
  | `ShouldGetKeyword | `OfParticle | `IntTypeKeyword | `FloatTypeKeyword 
  | `StringTypeKeyword | `BoolTypeKeyword | `UnitTypeKeyword | `ListTypeKeyword 
  | `ArrayTypeKeyword | `VariantKeyword | `TagKeyword | `IdentifierTokenSpecial 
  | `OrElseKeyword ] -> Lexer_tokens.token