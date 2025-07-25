(** 基础关键字Token映射模块 - 使用统一token定义 *)

open Token_definitions_unified

(** {1 异常类型} *)

exception TokenMappingError of string * string
(** 统一的映射错误异常类型 *)

(** {1 基础关键字映射} *)

val map_basic_variant :
  [> `LetKeyword
  | `RecKeyword
  | `InKeyword
  | `FunKeyword
  | `ParamKeyword
  | `IfKeyword
  | `ThenKeyword
  | `ElseKeyword
  | `MatchKeyword
  | `WithKeyword
  | `OtherKeyword
  | `AndKeyword
  | `OrKeyword
  | `NotKeyword
  | `OfKeyword
  | `TrueKeyword
  | `FalseKeyword
  | `TypeKeyword
  | `PrivateKeyword
  | `AsKeyword
  | `CombineKeyword
  | `WithOpKeyword
  | `WhenKeyword
  | `WithDefaultKeyword
  | `ExceptionKeyword
  | `RaiseKeyword
  | `TryKeyword
  | `CatchKeyword
  | `FinallyKeyword
  | `ModuleKeyword
  | `ModuleTypeKeyword
  | `RefKeyword
  | `IncludeKeyword
  | `FunctorKeyword
  | `SigKeyword
  | `EndKeyword
  | `MacroKeyword
  | `ExpandKeyword
  | `IntTypeKeyword
  | `FloatTypeKeyword
  | `StringTypeKeyword
  | `BoolTypeKeyword
  | `UnitTypeKeyword
  | `ListTypeKeyword
  | `ArrayTypeKeyword
  | `VariantKeyword
  | `TagKeyword
  | `HaveKeyword
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
  | `LessThanWenyan
  | `DefineKeyword
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
  | `OfParticle
  | `MinusOneKeyword
  | `PlusKeyword
  | `WhereKeyword
  | `SmallKeyword
  | `ShouldGetKeyword
  | `AncientDefineKeyword
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
  | `AfterThatKeyword
  | `AncientRecordStartKeyword
  | `AncientRecordEndKeyword
  | `AncientRecordEmptyKeyword
  | `AncientRecordUpdateKeyword
  | `AncientRecordFinishKeyword
  | `IdentifierTokenSpecial ] ->
  token
(** 映射基础关键字变体到Token *)
