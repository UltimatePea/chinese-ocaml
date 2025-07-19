(** 古雅体关键字Token映射模块 - 使用统一token定义 *)

open Token_definitions_unified

(** {1 古雅体关键字映射} *)

(** 映射文言文关键字变体到Token *)
val map_wenyan_variant : [>
  | `HaveKeyword | `OneKeyword | `NameKeyword | `SetKeyword
  | `AlsoKeyword | `ThenGetKeyword | `CallKeyword | `ValueKeyword
  | `AsForKeyword | `NumberKeyword | `WantExecuteKeyword
  | `MustFirstGetKeyword | `ForThisKeyword | `TimesKeyword
  | `EndCloudKeyword | `IfWenyanKeyword | `ThenWenyanKeyword
  | `GreaterThanWenyan | `LessThanWenyan
] -> token

(** 映射古雅体关键字变体到Token *)
val map_ancient_variant : [>
  | `AncientDefineKeyword | `AncientEndKeyword | `AncientAlgorithmKeyword
  | `AncientCompleteKeyword | `AncientObserveKeyword | `AncientNatureKeyword
  | `AncientThenKeyword | `AncientOtherwiseKeyword | `AncientAnswerKeyword
  | `AncientCombineKeyword | `AncientAsOneKeyword | `AncientTakeKeyword
  | `AncientReceiveKeyword | `AncientParticleThe | `AncientParticleFun
  | `AncientCallItKeyword | `AncientListStartKeyword | `AncientListEndKeyword
  | `AncientItsFirstKeyword | `AncientItsSecondKeyword | `AncientItsThirdKeyword
  | `AncientEmptyKeyword | `AncientHasHeadTailKeyword | `AncientHeadNameKeyword
  | `AncientTailNameKeyword | `AncientThusAnswerKeyword | `AncientAddToKeyword
  | `AncientObserveEndKeyword | `AncientBeginKeyword | `AncientEndCompleteKeyword
  | `AncientIsKeyword | `AncientArrowKeyword | `AncientWhenKeyword
  | `AncientCommaKeyword | `AfterThatKeyword | `AncientRecordStartKeyword
  | `AncientRecordEndKeyword | `AncientRecordEmptyKeyword | `AncientRecordUpdateKeyword
  | `AncientRecordFinishKeyword
] -> token

(** 映射自然语言关键字变体到Token *)
val map_natural_language_variant : [>
  | `DefineKeyword | `AcceptKeyword | `ReturnWhenKeyword | `ElseReturnKeyword
  | `MultiplyKeyword | `DivideKeyword | `AddToKeyword | `SubtractKeyword
  | `EqualToKeyword | `LessThanEqualToKeyword | `FirstElementKeyword
  | `RemainingKeyword | `EmptyKeyword | `CharacterCountKeyword
  | `OfParticle | `MinusOneKeyword | `PlusKeyword | `WhereKeyword
  | `SmallKeyword | `ShouldGetKeyword
] -> token