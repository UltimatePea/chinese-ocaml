(** 骆言词法分析器 - 变体转换模块 *)

open Lexer_tokens
open Compiler_errors

(** 基础关键字转换 *)
let convert_basic_keywords pos = function
  | `LetKeyword -> Ok LetKeyword
  | `RecKeyword -> Ok RecKeyword
  | `InKeyword -> Ok InKeyword
  | `FunKeyword -> Ok FunKeyword
  | `IfKeyword -> Ok IfKeyword
  | `ThenKeyword -> Ok ThenKeyword
  | `ElseKeyword -> Ok ElseKeyword
  | `MatchKeyword -> Ok MatchKeyword
  | `WithKeyword -> Ok WithKeyword
  | `OtherKeyword -> Ok OtherKeyword
  | `TypeKeyword -> Ok TypeKeyword
  | `PrivateKeyword -> Ok PrivateKeyword
  | `TrueKeyword -> Ok TrueKeyword
  | `FalseKeyword -> Ok FalseKeyword
  | `AndKeyword -> Ok AndKeyword
  | `OrKeyword -> Ok OrKeyword
  | `NotKeyword -> Ok NotKeyword
  | `OfKeyword -> Ok OfKeyword
  | _ -> unsupported_keyword_error "未知的基础关键字" pos

(** 语义关键字转换 *)
let convert_semantic_keywords pos = function
  | `AsKeyword -> Ok AsKeyword
  | `CombineKeyword -> Ok CombineKeyword
  | `WithOpKeyword -> Ok WithOpKeyword
  | `WhenKeyword -> Ok WhenKeyword
  | `WithDefaultKeyword -> Ok WithDefaultKeyword
  | _ -> unsupported_keyword_error "未知的语义关键字" pos

(** 异常处理关键字转换 *)
let convert_exception_keywords = function
  | `ExceptionKeyword -> ExceptionKeyword
  | `RaiseKeyword -> RaiseKeyword
  | `TryKeyword -> TryKeyword
  | `CatchKeyword -> CatchKeyword
  | `FinallyKeyword -> FinallyKeyword
  | _ -> failwith "不支持的异常处理关键字"

(** 模块系统关键字转换 *)
let convert_module_keywords = function
  | `ModuleKeyword -> ModuleKeyword
  | `ModuleTypeKeyword -> ModuleTypeKeyword
  | `RefKeyword -> RefKeyword
  | `IncludeKeyword -> IncludeKeyword
  | `FunctorKeyword -> FunctorKeyword
  | `SigKeyword -> SigKeyword
  | `EndKeyword -> EndKeyword
  | _ -> failwith "不支持的模块系统关键字"

(** 宏系统关键字转换 *)
let convert_macro_keywords = function
  | `MacroKeyword -> MacroKeyword
  | `ExpandKeyword -> ExpandKeyword
  | _ -> failwith "不支持的宏系统关键字"

(** 文言文风格关键字转换 *)
let convert_wenyan_keywords = function
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
  | _ -> failwith "不支持的文言文关键字"

(** 古文关键字转换 *)
let convert_ancient_keywords = function
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
  | `AncientPeriodKeyword -> AncientPeriodKeyword
  | `AncientIfKeyword -> AncientIfKeyword
  | `AncientRecursiveKeyword -> AncientRecursiveKeyword
  | `AncientParticleOf -> AncientParticleOf
  | `AfterThatKeyword -> AfterThatKeyword
  | _ -> failwith "不支持的古文关键字"

(** 自然语言关键字转换 *)
let convert_natural_keywords = function
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
  | `MinusOneKeyword -> MinusOneKeyword
  | `PlusKeyword -> PlusKeyword
  | `WhereKeyword -> WhereKeyword
  | `SmallKeyword -> SmallKeyword
  | `ShouldGetKeyword -> ShouldGetKeyword
  | `OfParticle -> OfParticle
  | `IsKeyword -> IsKeyword
  | `TopicMarker -> TopicMarker
  | _ -> failwith "不支持的自然语言关键字"

(** 类型关键字转换 *)
let convert_type_keywords = function
  | `IntTypeKeyword -> IntTypeKeyword
  | `FloatTypeKeyword -> FloatTypeKeyword
  | `StringTypeKeyword -> StringTypeKeyword
  | `BoolTypeKeyword -> BoolTypeKeyword
  | `UnitTypeKeyword -> UnitTypeKeyword
  | `ListTypeKeyword -> ListTypeKeyword
  | `ArrayTypeKeyword -> ArrayTypeKeyword
  | `VariantKeyword -> VariantKeyword
  | `TagKeyword -> TagKeyword
  | _ -> failwith "不支持的类型关键字"

(** 古典诗词关键字转换 *)
let convert_poetry_keywords = function
  | `RhymeKeyword -> RhymeKeyword
  | `ToneKeyword -> ToneKeyword
  | `ToneLevelKeyword -> ToneLevelKeyword
  | `ToneFallingKeyword -> ToneFallingKeyword
  | `ToneRisingKeyword -> ToneRisingKeyword
  | `ToneDepartingKeyword -> ToneDepartingKeyword
  | `ToneEnteringKeyword -> ToneEnteringKeyword
  | `ParallelKeyword -> ParallelKeyword
  | `PairedKeyword -> PairedKeyword
  | `AntitheticKeyword -> AntitheticKeyword
  | `BalancedKeyword -> BalancedKeyword
  | `PoetryKeyword -> PoetryKeyword
  | `FourCharKeyword -> FourCharKeyword
  | `FiveCharKeyword -> FiveCharKeyword
  | `SevenCharKeyword -> SevenCharKeyword
  | `ParallelStructKeyword -> ParallelStructKeyword
  | `RegulatedVerseKeyword -> RegulatedVerseKeyword
  | `QuatrainKeyword -> QuatrainKeyword
  | `CoupletKeyword -> CoupletKeyword
  | `AntithesisKeyword -> AntithesisKeyword
  | `MeterKeyword -> MeterKeyword
  | `CadenceKeyword -> CadenceKeyword
  | _ -> failwith "不支持的诗词关键字"

(** 特殊标识符转换 *)
let convert_special_identifier = function
  | `IdentifierTokenSpecial -> IdentifierTokenSpecial "数值"
  | _ -> failwith "不支持的特殊标识符"

(** 将多态变体转换为token类型 *)
let variant_to_token pos = function
  (* 基础关键字 *)
  | ( `LetKeyword | `RecKeyword | `InKeyword | `FunKeyword | `IfKeyword | `ThenKeyword
    | `ElseKeyword | `MatchKeyword | `WithKeyword | `OtherKeyword | `TypeKeyword | `PrivateKeyword
    | `TrueKeyword | `FalseKeyword | `AndKeyword | `OrKeyword | `NotKeyword | `OfKeyword ) as
    variant ->
      convert_basic_keywords pos variant
  (* 语义关键字 *)
  | (`AsKeyword | `CombineKeyword | `WithOpKeyword | `WhenKeyword | `WithDefaultKeyword) as variant
    ->
      convert_semantic_keywords pos variant
  (* 异常处理关键字 *)
  | (`ExceptionKeyword | `RaiseKeyword | `TryKeyword | `CatchKeyword | `FinallyKeyword) as variant
    ->
      convert_exception_keywords variant
  (* 模块系统关键字 *)
  | ( `ModuleKeyword | `ModuleTypeKeyword | `RefKeyword | `IncludeKeyword | `FunctorKeyword
    | `SigKeyword | `EndKeyword ) as variant ->
      convert_module_keywords variant
  (* 宏系统关键字 *)
  | (`MacroKeyword | `ExpandKeyword) as variant -> convert_macro_keywords variant
  (* 文言文风格关键字 *)
  | ( `HaveKeyword | `OneKeyword | `NameKeyword | `SetKeyword | `AlsoKeyword | `ThenGetKeyword
    | `CallKeyword | `ValueKeyword | `AsForKeyword | `NumberKeyword | `WantExecuteKeyword
    | `MustFirstGetKeyword | `ForThisKeyword | `TimesKeyword | `EndCloudKeyword | `IfWenyanKeyword
    | `ThenWenyanKeyword | `GreaterThanWenyan | `LessThanWenyan ) as variant ->
      convert_wenyan_keywords variant
  (* 古文关键字 *)
  | ( `AncientDefineKeyword | `AncientEndKeyword | `AncientAlgorithmKeyword
    | `AncientCompleteKeyword | `AncientObserveKeyword | `AncientNatureKeyword | `AncientThenKeyword
    | `AncientOtherwiseKeyword | `AncientAnswerKeyword | `AncientCombineKeyword
    | `AncientAsOneKeyword | `AncientTakeKeyword | `AncientReceiveKeyword | `AncientParticleThe
    | `AncientParticleFun | `AncientCallItKeyword | `AncientListStartKeyword
    | `AncientListEndKeyword | `AncientItsFirstKeyword | `AncientItsSecondKeyword
    | `AncientItsThirdKeyword | `AncientEmptyKeyword | `AncientHasHeadTailKeyword
    | `AncientHeadNameKeyword | `AncientTailNameKeyword | `AncientThusAnswerKeyword
    | `AncientAddToKeyword | `AncientObserveEndKeyword | `AncientBeginKeyword
    | `AncientEndCompleteKeyword | `AncientIsKeyword | `AncientArrowKeyword | `AncientWhenKeyword
    | `AncientCommaKeyword | `AncientPeriodKeyword | `AncientIfKeyword | `AncientRecursiveKeyword
    | `AncientParticleOf | `AfterThatKeyword ) as variant ->
      convert_ancient_keywords variant
  (* 自然语言关键字 *)
  | ( `DefineKeyword | `AcceptKeyword | `ReturnWhenKeyword | `ElseReturnKeyword | `MultiplyKeyword
    | `DivideKeyword | `AddToKeyword | `SubtractKeyword | `EqualToKeyword | `LessThanEqualToKeyword
    | `FirstElementKeyword | `RemainingKeyword | `EmptyKeyword | `CharacterCountKeyword
    | `InputKeyword | `OutputKeyword | `MinusOneKeyword | `PlusKeyword | `WhereKeyword
    | `SmallKeyword | `ShouldGetKeyword | `OfParticle | `IsKeyword | `TopicMarker ) as variant ->
      convert_natural_keywords variant
  (* 类型关键字 *)
  | ( `IntTypeKeyword | `FloatTypeKeyword | `StringTypeKeyword | `BoolTypeKeyword | `UnitTypeKeyword
    | `ListTypeKeyword | `ArrayTypeKeyword | `VariantKeyword | `TagKeyword ) as variant ->
      convert_type_keywords variant
  (* 古典诗词关键字 *)
  | ( `RhymeKeyword | `ToneKeyword | `ToneLevelKeyword | `ToneFallingKeyword | `ToneRisingKeyword
    | `ToneDepartingKeyword | `ToneEnteringKeyword | `ParallelKeyword | `PairedKeyword
    | `AntitheticKeyword | `BalancedKeyword | `PoetryKeyword | `FourCharKeyword | `FiveCharKeyword
    | `SevenCharKeyword | `ParallelStructKeyword | `RegulatedVerseKeyword | `QuatrainKeyword
    | `CoupletKeyword | `AntithesisKeyword | `MeterKeyword | `CadenceKeyword ) as variant ->
      convert_poetry_keywords variant
  (* 特殊标识符 *)
  | `IdentifierTokenSpecial as variant -> convert_special_identifier variant
  (* 错误恢复关键字 *)
  | `OrElseKeyword -> OrElseKeyword
  (* 其他缺失的关键字 - 继续添加 *)
  | _ -> failwith "不支持的关键字变体"
