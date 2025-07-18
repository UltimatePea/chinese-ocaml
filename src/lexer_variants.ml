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
let convert_exception_keywords pos = function
  | `ExceptionKeyword -> Ok ExceptionKeyword
  | `RaiseKeyword -> Ok RaiseKeyword
  | `TryKeyword -> Ok TryKeyword
  | `CatchKeyword -> Ok CatchKeyword
  | `FinallyKeyword -> Ok FinallyKeyword
  | _ -> unsupported_keyword_error "未知的异常处理关键字" pos

(** 模块系统关键字转换 *)
let convert_module_keywords pos = function
  | `ModuleKeyword -> Ok ModuleKeyword
  | `ModuleTypeKeyword -> Ok ModuleTypeKeyword
  | `RefKeyword -> Ok RefKeyword
  | `IncludeKeyword -> Ok IncludeKeyword
  | `FunctorKeyword -> Ok FunctorKeyword
  | `SigKeyword -> Ok SigKeyword
  | `EndKeyword -> Ok EndKeyword
  | _ -> unsupported_keyword_error "未知的模块系统关键字" pos

(** 宏系统关键字转换 *)
let convert_macro_keywords pos = function
  | `MacroKeyword -> Ok MacroKeyword
  | `ExpandKeyword -> Ok ExpandKeyword
  | _ -> unsupported_keyword_error "未知的宏系统关键字" pos

(** 文言文风格关键字转换 *)
let convert_wenyan_keywords pos = function
  | `HaveKeyword -> Ok HaveKeyword
  | `OneKeyword -> Ok OneKeyword
  | `NameKeyword -> Ok NameKeyword
  | `SetKeyword -> Ok SetKeyword
  | `AlsoKeyword -> Ok AlsoKeyword
  | `ThenGetKeyword -> Ok ThenGetKeyword
  | `CallKeyword -> Ok CallKeyword
  | `ValueKeyword -> Ok ValueKeyword
  | `AsForKeyword -> Ok AsForKeyword
  | `NumberKeyword -> Ok NumberKeyword
  | `WantExecuteKeyword -> Ok WantExecuteKeyword
  | `MustFirstGetKeyword -> Ok MustFirstGetKeyword
  | `ForThisKeyword -> Ok ForThisKeyword
  | `TimesKeyword -> Ok TimesKeyword
  | `EndCloudKeyword -> Ok EndCloudKeyword
  | `IfWenyanKeyword -> Ok IfWenyanKeyword
  | `ThenWenyanKeyword -> Ok ThenWenyanKeyword
  | `GreaterThanWenyan -> Ok GreaterThanWenyan
  | `LessThanWenyan -> Ok LessThanWenyan
  | _ -> unsupported_keyword_error "未知的文言文关键字" pos

(** 古文关键字转换 *)
let convert_ancient_keywords pos = function
  | `AncientDefineKeyword -> Ok AncientDefineKeyword
  | `AncientEndKeyword -> Ok AncientEndKeyword
  | `AncientAlgorithmKeyword -> Ok AncientAlgorithmKeyword
  | `AncientCompleteKeyword -> Ok AncientCompleteKeyword
  | `AncientObserveKeyword -> Ok AncientObserveKeyword
  | `AncientNatureKeyword -> Ok AncientNatureKeyword
  | `AncientThenKeyword -> Ok AncientThenKeyword
  | `AncientOtherwiseKeyword -> Ok AncientOtherwiseKeyword
  | `AncientAnswerKeyword -> Ok AncientAnswerKeyword
  | `AncientCombineKeyword -> Ok AncientCombineKeyword
  | `AncientAsOneKeyword -> Ok AncientAsOneKeyword
  | `AncientTakeKeyword -> Ok AncientTakeKeyword
  | `AncientReceiveKeyword -> Ok AncientReceiveKeyword
  | `AncientParticleThe -> Ok AncientParticleThe
  | `AncientParticleFun -> Ok AncientParticleFun
  | `AncientCallItKeyword -> Ok AncientCallItKeyword
  | `AncientListStartKeyword -> Ok AncientListStartKeyword
  | `AncientListEndKeyword -> Ok AncientListEndKeyword
  | `AncientItsFirstKeyword -> Ok AncientItsFirstKeyword
  | `AncientItsSecondKeyword -> Ok AncientItsSecondKeyword
  | `AncientItsThirdKeyword -> Ok AncientItsThirdKeyword
  | `AncientEmptyKeyword -> Ok AncientEmptyKeyword
  | `AncientHasHeadTailKeyword -> Ok AncientHasHeadTailKeyword
  | `AncientHeadNameKeyword -> Ok AncientHeadNameKeyword
  | `AncientTailNameKeyword -> Ok AncientTailNameKeyword
  | `AncientThusAnswerKeyword -> Ok AncientThusAnswerKeyword
  | `AncientAddToKeyword -> Ok AncientAddToKeyword
  | `AncientObserveEndKeyword -> Ok AncientObserveEndKeyword
  | `AncientBeginKeyword -> Ok AncientBeginKeyword
  | `AncientEndCompleteKeyword -> Ok AncientEndCompleteKeyword
  | `AncientIsKeyword -> Ok AncientIsKeyword
  | `AncientArrowKeyword -> Ok AncientArrowKeyword
  | `AncientWhenKeyword -> Ok AncientWhenKeyword
  | `AncientCommaKeyword -> Ok AncientCommaKeyword
  | `AncientPeriodKeyword -> Ok AncientPeriodKeyword
  | `AncientIfKeyword -> Ok AncientIfKeyword
  | `AncientRecursiveKeyword -> Ok AncientRecursiveKeyword
  | `AncientParticleOf -> Ok AncientParticleOf
  | `AfterThatKeyword -> Ok AfterThatKeyword
  (* 古雅体记录类型关键词 *)
  | `AncientRecordStartKeyword -> Ok AncientRecordStartKeyword
  | `AncientRecordEndKeyword -> Ok AncientRecordEndKeyword
  | `AncientRecordEmptyKeyword -> Ok AncientRecordEmptyKeyword
  | `AncientRecordUpdateKeyword -> Ok AncientRecordUpdateKeyword
  | `AncientRecordFinishKeyword -> Ok AncientRecordFinishKeyword
  | _ -> unsupported_keyword_error "未知的古文关键字" pos

(** 自然语言关键字转换 *)
let convert_natural_keywords pos = function
  | `DefineKeyword -> Ok DefineKeyword
  | `AcceptKeyword -> Ok AcceptKeyword
  | `ReturnWhenKeyword -> Ok ReturnWhenKeyword
  | `ElseReturnKeyword -> Ok ElseReturnKeyword
  | `MultiplyKeyword -> Ok MultiplyKeyword
  | `DivideKeyword -> Ok DivideKeyword
  | `AddToKeyword -> Ok AddToKeyword
  | `SubtractKeyword -> Ok SubtractKeyword
  | `EqualToKeyword -> Ok EqualToKeyword
  | `LessThanEqualToKeyword -> Ok LessThanEqualToKeyword
  | `FirstElementKeyword -> Ok FirstElementKeyword
  | `RemainingKeyword -> Ok RemainingKeyword
  | `EmptyKeyword -> Ok EmptyKeyword
  | `CharacterCountKeyword -> Ok CharacterCountKeyword
  | `InputKeyword -> Ok InputKeyword
  | `OutputKeyword -> Ok OutputKeyword
  | `MinusOneKeyword -> Ok MinusOneKeyword
  | `PlusKeyword -> Ok PlusKeyword
  | `WhereKeyword -> Ok WhereKeyword
  | `SmallKeyword -> Ok SmallKeyword
  | `ShouldGetKeyword -> Ok ShouldGetKeyword
  | `OfParticle -> Ok OfParticle
  | `IsKeyword -> Ok IsKeyword
  | `TopicMarker -> Ok TopicMarker
  | _ -> unsupported_keyword_error "未知的自然语言关键字" pos

(** 类型关键字转换 *)
let convert_type_keywords pos = function
  | `IntTypeKeyword -> Ok IntTypeKeyword
  | `FloatTypeKeyword -> Ok FloatTypeKeyword
  | `StringTypeKeyword -> Ok StringTypeKeyword
  | `BoolTypeKeyword -> Ok BoolTypeKeyword
  | `UnitTypeKeyword -> Ok UnitTypeKeyword
  | `ListTypeKeyword -> Ok ListTypeKeyword
  | `ArrayTypeKeyword -> Ok ArrayTypeKeyword
  | `VariantKeyword -> Ok VariantKeyword
  | `TagKeyword -> Ok TagKeyword
  | _ -> unsupported_keyword_error "未知的类型关键字" pos

(** 古典诗词关键字转换 *)
let convert_poetry_keywords pos = function
  | `RhymeKeyword -> Ok RhymeKeyword
  | `ToneKeyword -> Ok ToneKeyword
  | `ToneLevelKeyword -> Ok ToneLevelKeyword
  | `ToneFallingKeyword -> Ok ToneFallingKeyword
  | `ToneRisingKeyword -> Ok ToneRisingKeyword
  | `ToneDepartingKeyword -> Ok ToneDepartingKeyword
  | `ToneEnteringKeyword -> Ok ToneEnteringKeyword
  | `ParallelKeyword -> Ok ParallelKeyword
  | `PairedKeyword -> Ok PairedKeyword
  | `AntitheticKeyword -> Ok AntitheticKeyword
  | `BalancedKeyword -> Ok BalancedKeyword
  | `PoetryKeyword -> Ok PoetryKeyword
  | `FourCharKeyword -> Ok FourCharKeyword
  | `FiveCharKeyword -> Ok FiveCharKeyword
  | `SevenCharKeyword -> Ok SevenCharKeyword
  | `ParallelStructKeyword -> Ok ParallelStructKeyword
  | `RegulatedVerseKeyword -> Ok RegulatedVerseKeyword
  | `QuatrainKeyword -> Ok QuatrainKeyword
  | `CoupletKeyword -> Ok CoupletKeyword
  | `AntithesisKeyword -> Ok AntithesisKeyword
  | `MeterKeyword -> Ok MeterKeyword
  | `CadenceKeyword -> Ok CadenceKeyword
  | _ -> unsupported_keyword_error "未知的诗词关键字" pos

(** 特殊标识符转换 *)
let convert_special_identifier pos = function
  | `IdentifierTokenSpecial -> Ok (IdentifierTokenSpecial "数值")
  | _ -> unsupported_keyword_error "未知的特殊标识符" pos

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
      convert_exception_keywords pos variant
  (* 模块系统关键字 *)
  | ( `ModuleKeyword | `ModuleTypeKeyword | `RefKeyword | `IncludeKeyword | `FunctorKeyword
    | `SigKeyword | `EndKeyword ) as variant ->
      convert_module_keywords pos variant
  (* 宏系统关键字 *)
  | (`MacroKeyword | `ExpandKeyword) as variant -> convert_macro_keywords pos variant
  (* 文言文风格关键字 *)
  | ( `HaveKeyword | `OneKeyword | `NameKeyword | `SetKeyword | `AlsoKeyword | `ThenGetKeyword
    | `CallKeyword | `ValueKeyword | `AsForKeyword | `NumberKeyword | `WantExecuteKeyword
    | `MustFirstGetKeyword | `ForThisKeyword | `TimesKeyword | `EndCloudKeyword | `IfWenyanKeyword
    | `ThenWenyanKeyword | `GreaterThanWenyan | `LessThanWenyan ) as variant ->
      convert_wenyan_keywords pos variant
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
    | `AncientParticleOf | `AfterThatKeyword | `AncientRecordStartKeyword | `AncientRecordEndKeyword
    | `AncientRecordEmptyKeyword | `AncientRecordUpdateKeyword | `AncientRecordFinishKeyword ) as
    variant ->
      convert_ancient_keywords pos variant
  (* 自然语言关键字 *)
  | ( `DefineKeyword | `AcceptKeyword | `ReturnWhenKeyword | `ElseReturnKeyword | `MultiplyKeyword
    | `DivideKeyword | `AddToKeyword | `SubtractKeyword | `EqualToKeyword | `LessThanEqualToKeyword
    | `FirstElementKeyword | `RemainingKeyword | `EmptyKeyword | `CharacterCountKeyword
    | `InputKeyword | `OutputKeyword | `MinusOneKeyword | `PlusKeyword | `WhereKeyword
    | `SmallKeyword | `ShouldGetKeyword | `OfParticle | `IsKeyword | `TopicMarker ) as variant ->
      convert_natural_keywords pos variant
  (* 类型关键字 *)
  | ( `IntTypeKeyword | `FloatTypeKeyword | `StringTypeKeyword | `BoolTypeKeyword | `UnitTypeKeyword
    | `ListTypeKeyword | `ArrayTypeKeyword | `VariantKeyword | `TagKeyword ) as variant ->
      convert_type_keywords pos variant
  (* 古典诗词关键字 *)
  | ( `RhymeKeyword | `ToneKeyword | `ToneLevelKeyword | `ToneFallingKeyword | `ToneRisingKeyword
    | `ToneDepartingKeyword | `ToneEnteringKeyword | `ParallelKeyword | `PairedKeyword
    | `AntitheticKeyword | `BalancedKeyword | `PoetryKeyword | `FourCharKeyword | `FiveCharKeyword
    | `SevenCharKeyword | `ParallelStructKeyword | `RegulatedVerseKeyword | `QuatrainKeyword
    | `CoupletKeyword | `AntithesisKeyword | `MeterKeyword | `CadenceKeyword ) as variant ->
      convert_poetry_keywords pos variant
  (* 特殊标识符 *)
  | `IdentifierTokenSpecial as variant -> convert_special_identifier pos variant
  (* 错误恢复关键字 *)
  | `OrElseKeyword -> Ok OrElseKeyword
  (* 其他缺失的关键字 - 继续添加 *)
  | _ -> unsupported_keyword_error "未知的关键字变体" pos
