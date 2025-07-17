(** 词法分析器关键字处理模块 *)

open Lexer_tokens

(** 将关键字变体转换为对应的token *)
let variant_to_token = function
  (* Basic keywords *)
  | `LetKeyword -> LetKeyword
  | `RecKeyword -> RecKeyword
  | `InKeyword -> InKeyword
  | `FunKeyword -> FunKeyword
  | `IfKeyword -> IfKeyword
  | `ThenKeyword -> ThenKeyword
  | `ElseKeyword -> ElseKeyword
  | `MatchKeyword -> MatchKeyword
  | `WithKeyword -> WithKeyword
  | `OtherKeyword -> OtherKeyword
  | `TypeKeyword -> TypeKeyword
  | `PrivateKeyword -> PrivateKeyword
  | `TrueKeyword -> BoolToken true
  | `FalseKeyword -> BoolToken false
  | `AndKeyword -> AndKeyword
  | `OrKeyword -> OrKeyword
  | `NotKeyword -> NotKeyword
  | `OfKeyword -> OfKeyword
  (* Semantic keywords *)
  | `AsKeyword -> AsKeyword
  | `CombineKeyword -> CombineKeyword
  | `WithOpKeyword -> WithOpKeyword
  | `WhenKeyword -> WhenKeyword
  (* Error recovery keywords *)
  | `WithDefaultKeyword -> WithDefaultKeyword
  | `ExceptionKeyword -> ExceptionKeyword
  | `RaiseKeyword -> RaiseKeyword
  | `TryKeyword -> TryKeyword
  | `CatchKeyword -> CatchKeyword
  | `FinallyKeyword -> FinallyKeyword
  (* Module keywords *)
  | `ModuleKeyword -> ModuleKeyword
  | `ModuleTypeKeyword -> ModuleTypeKeyword
  | `RefKeyword -> RefKeyword
  | `IncludeKeyword -> IncludeKeyword
  | `FunctorKeyword -> FunctorKeyword
  | `SigKeyword -> SigKeyword
  | `EndKeyword -> EndKeyword
  (* Macro keywords *)
  | `MacroKeyword -> MacroKeyword
  | `ExpandKeyword -> ExpandKeyword
  (* Wenyan keywords *)
  | `HaveKeyword -> HaveKeyword
  | `OneKeyword -> OneKeyword
  | `NameKeyword -> NameKeyword
  | `SetKeyword -> SetKeyword
  | `AlsoKeyword -> AlsoKeyword
  | `ThenGetKeyword -> ThenGetKeyword
  | `CallKeyword -> CallKeyword
  | `ValueKeyword -> ValueKeyword
  | `AsForKeyword -> AsForKeyword
  | `NumberKeyword -> NumberKeyword
  (* Wenyan extended keywords *)
  | `WantExecuteKeyword -> WantExecuteKeyword
  | `MustFirstGetKeyword -> MustFirstGetKeyword
  | `ForThisKeyword -> ForThisKeyword
  | `TimesKeyword -> TimesKeyword
  | `EndCloudKeyword -> EndCloudKeyword
  | `IfWenyanKeyword -> IfWenyanKeyword
  | `ThenWenyanKeyword -> ThenWenyanKeyword
  | `GreaterThanWenyan -> GreaterThanWenyan
  | `LessThanWenyan -> LessThanWenyan
  (* Natural language keywords *)
  | `DefineKeyword -> DefineKeyword
  | `AcceptKeyword -> AcceptKeyword
  | `ReturnWhenKeyword -> ReturnWhenKeyword
  | `ElseReturnKeyword -> ElseReturnKeyword
  | `MultiplyKeyword -> MultiplyKeyword
  | `DivideKeyword -> DivideKeyword
  | `AddToKeyword -> AddToKeyword
  | `SubtractKeyword -> SubtractKeyword
  | `EqualToKeyword -> EqualToKeyword
  | `LessThanEqualToKeyword -> LessThanEqualToKeyword
  | `FirstElementKeyword -> FirstElementKeyword
  | `RemainingKeyword -> RemainingKeyword
  | `EmptyKeyword -> EmptyKeyword
  | `CharacterCountKeyword -> CharacterCountKeyword
  | `OfParticle -> OfParticle
  (* Type annotation keywords *)
  | `InputKeyword -> InputKeyword
  | `OutputKeyword -> OutputKeyword
  | `MinusOneKeyword -> MinusOneKeyword
  | `PlusKeyword -> PlusKeyword
  | `WhereKeyword -> WhereKeyword
  | `SmallKeyword -> SmallKeyword
  | `ShouldGetKeyword -> ShouldGetKeyword
  | `IntTypeKeyword -> IntTypeKeyword
  | `FloatTypeKeyword -> FloatTypeKeyword
  | `StringTypeKeyword -> StringTypeKeyword
  | `BoolTypeKeyword -> BoolTypeKeyword
  | `UnitTypeKeyword -> UnitTypeKeyword
  | `ListTypeKeyword -> ListTypeKeyword
  | `ArrayTypeKeyword -> ArrayTypeKeyword
  (* Variant keywords *)
  | `VariantKeyword -> VariantKeyword
  | `TagKeyword -> TagKeyword
  (* Ancient keywords *)
  | `AncientDefineKeyword -> AncientDefineKeyword
  | `AncientEndKeyword -> AncientEndKeyword
  | `AncientAlgorithmKeyword -> AncientAlgorithmKeyword
  | `AncientCompleteKeyword -> AncientCompleteKeyword
  | `AncientObserveKeyword -> AncientObserveKeyword
  | `AncientNatureKeyword -> AncientNatureKeyword
  | `AncientThenKeyword -> AncientThenKeyword
  | `AncientOtherwiseKeyword -> AncientOtherwiseKeyword
  | `AncientAnswerKeyword -> AncientAnswerKeyword
  | `AncientCombineKeyword -> AncientCombineKeyword
  | `AncientAsOneKeyword -> AncientAsOneKeyword
  | `AncientTakeKeyword -> AncientTakeKeyword
  | `AncientReceiveKeyword -> AncientReceiveKeyword
  | `AncientParticleThe -> AncientParticleThe
  | `AncientParticleFun -> AncientParticleFun
  | `AncientCallItKeyword -> AncientCallItKeyword
  | `AncientListStartKeyword -> AncientListStartKeyword
  | `AncientListEndKeyword -> AncientListEndKeyword
  | `AncientItsFirstKeyword -> AncientItsFirstKeyword
  | `AncientItsSecondKeyword -> AncientItsSecondKeyword
  | `AncientItsThirdKeyword -> AncientItsThirdKeyword
  | `AncientEmptyKeyword -> AncientEmptyKeyword
  | `AncientHasHeadTailKeyword -> AncientHasHeadTailKeyword
  | `AncientHeadNameKeyword -> AncientHeadNameKeyword
  | `AncientTailNameKeyword -> AncientTailNameKeyword
  | `AncientThusAnswerKeyword -> AncientThusAnswerKeyword
  | `AncientAddToKeyword -> AncientAddToKeyword
  | `AncientObserveEndKeyword -> AncientObserveEndKeyword
  | `AncientBeginKeyword -> AncientBeginKeyword
  | `AncientEndCompleteKeyword -> AncientEndCompleteKeyword
  | `AncientIsKeyword -> AncientIsKeyword
  | `AncientArrowKeyword -> AncientArrowKeyword
  | `AncientWhenKeyword -> AncientWhenKeyword
  | `AncientCommaKeyword -> AncientCommaKeyword
  | `AfterThatKeyword -> AfterThatKeyword
  (* 古雅体记录类型关键词 *)
  | `AncientRecordStartKeyword -> AncientRecordStartKeyword
  | `AncientRecordEndKeyword -> AncientRecordEndKeyword
  | `AncientRecordEmptyKeyword -> AncientRecordEmptyKeyword
  | `AncientRecordUpdateKeyword -> AncientRecordUpdateKeyword
  | `AncientRecordFinishKeyword -> AncientRecordFinishKeyword
  (* Special keywords *)
  | `IdentifierTokenSpecial -> IdentifierTokenSpecial "数值"

(** 查找关键字 *)
let find_keyword str =
  match Keyword_tables.Keywords.find_keyword str with
  | Some variant -> Some (variant_to_token variant)
  | None -> None