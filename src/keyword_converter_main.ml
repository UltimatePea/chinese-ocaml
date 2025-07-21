(** 骆言词法分析器 - 关键字转换主协调器 *)

open Lexer_tokens
open Compiler_errors

(** 转换基础和语义关键字 *)
let convert_core_keywords pos = function
  (* 基础关键字 *)
  | ( `LetKeyword | `RecKeyword | `InKeyword | `FunKeyword | `IfKeyword | `ThenKeyword
    | `ElseKeyword | `MatchKeyword | `WithKeyword | `OtherKeyword | `TypeKeyword | `PrivateKeyword
    | `TrueKeyword | `FalseKeyword | `AndKeyword | `OrKeyword | `NotKeyword | `OfKeyword ) as
    variant ->
      Keyword_converter_basic.convert_basic_keywords pos variant
  (* 语义关键字 *)
  | (`AsKeyword | `CombineKeyword | `WithOpKeyword | `WhenKeyword | `WithDefaultKeyword) as variant
    ->
      Keyword_converter_basic.convert_semantic_keywords pos variant
  | _ -> unsupported_keyword_error "不是核心关键字" pos

(** 转换系统关键字 *)
let convert_system_keywords pos = function
  (* 异常处理关键字 *)
  | (`ExceptionKeyword | `RaiseKeyword | `TryKeyword | `CatchKeyword | `FinallyKeyword) as variant
    ->
      Keyword_converter_system.convert_exception_keywords pos variant
  (* 模块系统关键字 *)
  | ( `ModuleKeyword | `ModuleTypeKeyword | `RefKeyword | `IncludeKeyword | `FunctorKeyword
    | `SigKeyword | `EndKeyword ) as variant ->
      Keyword_converter_system.convert_module_keywords pos variant
  (* 宏系统关键字 *)
  | (`MacroKeyword | `ExpandKeyword) as variant ->
      Keyword_converter_system.convert_macro_keywords pos variant
  | _ -> unsupported_keyword_error "不是系统关键字" pos

(** 转换中文风格关键字 *)
let convert_chinese_style_keywords pos = function
  (* 文言文风格关键字 *)
  | ( `HaveKeyword | `OneKeyword | `NameKeyword | `SetKeyword | `AlsoKeyword | `ThenGetKeyword
    | `CallKeyword | `ValueKeyword | `AsForKeyword | `NumberKeyword | `WantExecuteKeyword
    | `MustFirstGetKeyword | `ForThisKeyword | `TimesKeyword | `EndCloudKeyword | `IfWenyanKeyword
    | `ThenWenyanKeyword | `GreaterThanWenyan | `LessThanWenyan ) as variant ->
      Keyword_converter_chinese.convert_wenyan_keywords pos variant
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
      Keyword_converter_chinese.convert_ancient_keywords pos variant
  (* 自然语言关键字 *)
  | ( `DefineKeyword | `AcceptKeyword | `ReturnWhenKeyword | `ElseReturnKeyword | `MultiplyKeyword
    | `DivideKeyword | `AddToKeyword | `SubtractKeyword | `EqualToKeyword | `LessThanEqualToKeyword
    | `FirstElementKeyword | `RemainingKeyword | `EmptyKeyword | `CharacterCountKeyword
    | `InputKeyword | `OutputKeyword | `MinusOneKeyword | `PlusKeyword | `WhereKeyword
    | `SmallKeyword | `ShouldGetKeyword | `OfParticle | `IsKeyword | `TopicMarker ) as variant ->
      Keyword_converter_chinese.convert_natural_keywords pos variant
  | _ -> unsupported_keyword_error "不是中文风格关键字" pos

(** 转换特殊类型关键字 *)
let convert_special_type_keywords pos = function
  (* 类型关键字 *)
  | ( `IntTypeKeyword | `FloatTypeKeyword | `StringTypeKeyword | `BoolTypeKeyword | `UnitTypeKeyword
    | `ListTypeKeyword | `ArrayTypeKeyword | `VariantKeyword | `TagKeyword ) as variant ->
      Keyword_converter_special.convert_type_keywords pos variant
  (* 古典诗词关键字 *)
  | ( `RhymeKeyword | `ToneKeyword | `ToneLevelKeyword | `ToneFallingKeyword | `ToneRisingKeyword
    | `ToneDepartingKeyword | `ToneEnteringKeyword | `ParallelKeyword | `PairedKeyword
    | `AntitheticKeyword | `BalancedKeyword | `PoetryKeyword | `FourCharKeyword | `FiveCharKeyword
    | `SevenCharKeyword | `ParallelStructKeyword | `RegulatedVerseKeyword | `QuatrainKeyword
    | `CoupletKeyword | `AntithesisKeyword | `MeterKeyword | `CadenceKeyword ) as variant ->
      Keyword_converter_special.convert_poetry_keywords pos variant
  (* 特殊标识符 *)
  | `IdentifierTokenSpecial as variant ->
      Keyword_converter_special.convert_special_identifier pos variant
  | _ -> unsupported_keyword_error "不是特殊类型关键字" pos

(** 将多态变体转换为token类型 - 主入口函数 *)
let variant_to_token pos variant =
  (* 错误恢复关键字 - 直接处理 *)
  match variant with
  | `OrElseKeyword -> Ok OrElseKeyword
  | _ -> (
      (* 尝试不同类型的关键字转换 *)
      try convert_core_keywords pos variant
      with Failure _ -> (
        try convert_system_keywords pos variant
        with Failure _ -> (
          try convert_chinese_style_keywords pos variant
          with Failure _ -> (
            try convert_special_type_keywords pos variant
            with Failure _ -> unsupported_keyword_error "未知的关键字变体" pos))))
