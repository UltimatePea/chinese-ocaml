(** 基础关键字Token映射模块 - 优化版本，保持向后兼容 *)

open Token_definitions_unified

(** 映射基础编程关键字（let, fun, if等） *)
let map_basic_programming_keywords = function
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
  | `AndKeyword -> AndKeyword
  | `OrKeyword -> OrKeyword
  | `NotKeyword -> NotKeyword
  | `OfKeyword -> OfKeyword
  | `TrueKeyword -> BoolToken true
  | `FalseKeyword -> BoolToken false
  | `TypeKeyword -> TypeKeyword
  | `PrivateKeyword -> PrivateKeyword
  | _ -> raise (Invalid_argument "不是基础编程关键字")

(** 映射语义相关关键字（as, combine等） *)
let map_semantic_keywords = function
  | `AsKeyword -> AsKeyword
  | `CombineKeyword -> CombineKeyword
  | `WithOpKeyword -> WithOpKeyword
  | `WhenKeyword -> WhenKeyword
  | _ -> raise (Invalid_argument "不是语义关键字")

(** 映射错误处理关键字（try, catch等） *)
let map_error_recovery_keywords = function
  | `WithDefaultKeyword -> WithDefaultKeyword
  | `ExceptionKeyword -> ExceptionKeyword
  | `RaiseKeyword -> RaiseKeyword
  | `TryKeyword -> TryKeyword
  | `CatchKeyword -> CatchKeyword
  | `FinallyKeyword -> FinallyKeyword
  | _ -> raise (Invalid_argument "不是错误处理关键字")

(** 映射模块系统关键字（module, functor等） *)
let map_module_keywords = function
  | `ModuleKeyword -> ModuleKeyword
  | `ModuleTypeKeyword -> ModuleTypeKeyword
  | `RefKeyword -> RefKeyword
  | `IncludeKeyword -> IncludeKeyword
  | `FunctorKeyword -> FunctorKeyword
  | `SigKeyword -> SigKeyword
  | `EndKeyword -> EndKeyword
  | _ -> raise (Invalid_argument "不是模块关键字")

(** 映射宏系统关键字 *)
let map_macro_keywords = function
  | `MacroKeyword -> MacroKeyword
  | `ExpandKeyword -> ExpandKeyword
  | _ -> raise (Invalid_argument "不是宏关键字")

(** 映射类型标注关键字 *)
let map_type_annotation_keywords = function
  | `IntTypeKeyword -> IntTypeKeyword
  | `FloatTypeKeyword -> FloatTypeKeyword
  | `StringTypeKeyword -> StringTypeKeyword
  | `BoolTypeKeyword -> BoolTypeKeyword
  | `UnitTypeKeyword -> UnitTypeKeyword
  | `ListTypeKeyword -> ListTypeKeyword
  | `ArrayTypeKeyword -> ArrayTypeKeyword
  | `VariantKeyword -> VariantKeyword
  | `TagKeyword -> TagKeyword
  | _ -> raise (Invalid_argument "不是类型标注关键字")

(** 映射文言文关键字 *)
let map_wenyan_keywords = function
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
  | `WantExecuteKeyword -> WantExecuteKeyword
  | `MustFirstGetKeyword -> MustFirstGetKeyword
  | `ForThisKeyword -> ForThisKeyword
  | `TimesKeyword -> TimesKeyword
  | `EndCloudKeyword -> EndCloudKeyword
  | `IfWenyanKeyword -> IfWenyanKeyword
  | `ThenWenyanKeyword -> ThenWenyanKeyword
  | `GreaterThanWenyan -> GreaterThanWenyan
  | `LessThanWenyan -> LessThanWenyan
  | _ -> raise (Invalid_argument "不是文言文关键字")

(** 映射自然语言关键字 *)
let map_natural_language_keywords = function
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
  | `InputKeyword -> InputKeyword
  | `OutputKeyword -> OutputKeyword
  | `OfParticle -> OfParticle
  | `MinusOneKeyword -> MinusOneKeyword
  | `PlusKeyword -> PlusKeyword
  | `WhereKeyword -> WhereKeyword
  | `SmallKeyword -> SmallKeyword
  | `ShouldGetKeyword -> ShouldGetKeyword
  | _ -> raise (Invalid_argument "不是自然语言关键字")

(** 映射古雅体关键字 *)
let map_ancient_keywords = function
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
  | `AncientRecordStartKeyword -> AncientRecordStartKeyword
  | `AncientRecordEndKeyword -> AncientRecordEndKeyword
  | `AncientRecordEmptyKeyword -> AncientRecordEmptyKeyword
  | `AncientRecordUpdateKeyword -> AncientRecordUpdateKeyword
  | `AncientRecordFinishKeyword -> AncientRecordFinishKeyword
  | _ -> raise (Invalid_argument "不是古雅体关键字")

(** 映射特殊标识符 *)
let map_special_identifiers = function
  | `IdentifierTokenSpecial -> IdentifierTokenSpecial ""
  | _ -> raise (Invalid_argument "不是特殊标识符")

(** 映射基础关键字变体到Token - 重构后的模块化版本 *)
let map_basic_variant variant =
  try
    (* 按类别顺序尝试映射，优先匹配常用关键字 *)
    try map_basic_programming_keywords variant with Invalid_argument _ ->
    try map_semantic_keywords variant with Invalid_argument _ ->
    try map_error_recovery_keywords variant with Invalid_argument _ ->
    try map_module_keywords variant with Invalid_argument _ ->
    try map_macro_keywords variant with Invalid_argument _ ->
    try map_type_annotation_keywords variant with Invalid_argument _ ->
    try map_wenyan_keywords variant with Invalid_argument _ ->
    try map_natural_language_keywords variant with Invalid_argument _ ->
    try map_ancient_keywords variant with Invalid_argument _ ->
    try map_special_identifiers variant with Invalid_argument _ ->
    (* 如果所有类别都不匹配，返回错误 *)
    failwith "Unmapped keyword variant - needs manual review"
  with
  | Invalid_argument _ -> failwith "Unmapped keyword variant - needs manual review"
