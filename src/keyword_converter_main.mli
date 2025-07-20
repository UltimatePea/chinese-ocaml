(** 骆言词法分析器 - 关键字转换主协调器接口
    
    本模块是关键字转换系统的主入口点，协调各个专门的关键字转换器，
    提供统一的关键字转换接口。支持基础关键字、系统关键字、中文风格关键字和特殊类型关键字。
    
    @author 骆言团队
    @since 2025-07-20 *)

(** 转换基础和语义关键字
    处理基础编程语言关键字（如let、if、match等）和语义关键字
    
    @param pos 位置信息，用于错误报告
    @param keyword 要转换的核心关键字多态变体
    @return 转换结果，成功时返回对应Token，失败时返回错误 *)
val convert_core_keywords : Compiler_errors_types.position -> [> 
  | `LetKeyword | `RecKeyword | `InKeyword | `FunKeyword | `IfKeyword | `ThenKeyword
  | `ElseKeyword | `MatchKeyword | `WithKeyword | `OtherKeyword | `TypeKeyword | `PrivateKeyword
  | `TrueKeyword | `FalseKeyword | `AndKeyword | `OrKeyword | `NotKeyword | `OfKeyword 
  | `AsKeyword | `CombineKeyword | `WithOpKeyword | `WhenKeyword | `WithDefaultKeyword ] -> Lexer_tokens.token Compiler_errors_types.error_result

(** 转换系统关键字
    处理系统级关键字，包括异常处理、模块系统和宏系统相关关键字
    
    @param pos 位置信息，用于错误报告
    @param keyword 要转换的系统关键字多态变体
    @return 转换结果，成功时返回对应Token，失败时返回错误 *)
val convert_system_keywords : Compiler_errors_types.position -> [> 
  | `ExceptionKeyword | `RaiseKeyword | `TryKeyword | `CatchKeyword | `FinallyKeyword
  | `ModuleKeyword | `ModuleTypeKeyword | `RefKeyword | `IncludeKeyword | `FunctorKeyword
  | `SigKeyword | `EndKeyword | `MacroKeyword | `ExpandKeyword ] -> Lexer_tokens.token Compiler_errors_types.error_result

(** 转换中文风格关键字
    处理文言文风格、古文和自然语言风格的中文关键字
    
    @param pos 位置信息，用于错误报告
    @param keyword 要转换的中文风格关键字多态变体
    @return 转换结果，成功时返回对应Token，失败时返回错误 *)
val convert_chinese_style_keywords : Compiler_errors_types.position -> [> 
  | `HaveKeyword | `OneKeyword | `NameKeyword | `SetKeyword | `AlsoKeyword | `ThenGetKeyword
  | `CallKeyword | `ValueKeyword | `AsForKeyword | `NumberKeyword | `WantExecuteKeyword
  | `MustFirstGetKeyword | `ForThisKeyword | `TimesKeyword | `EndCloudKeyword | `IfWenyanKeyword
  | `ThenWenyanKeyword | `GreaterThanWenyan | `LessThanWenyan 
  | `AncientDefineKeyword | `AncientEndKeyword | `AncientAlgorithmKeyword
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
  | `AncientRecordEmptyKeyword | `AncientRecordUpdateKeyword | `AncientRecordFinishKeyword
  | `DefineKeyword | `AcceptKeyword | `ReturnWhenKeyword | `ElseReturnKeyword | `MultiplyKeyword
  | `DivideKeyword | `AddToKeyword | `SubtractKeyword | `EqualToKeyword | `LessThanEqualToKeyword
  | `FirstElementKeyword | `RemainingKeyword | `EmptyKeyword | `CharacterCountKeyword
  | `InputKeyword | `OutputKeyword | `MinusOneKeyword | `PlusKeyword | `WhereKeyword
  | `SmallKeyword | `ShouldGetKeyword | `OfParticle | `IsKeyword | `TopicMarker ] -> Lexer_tokens.token Compiler_errors_types.error_result

(** 转换特殊类型关键字
    处理类型关键字、古典诗词关键字和特殊标识符
    
    @param pos 位置信息，用于错误报告
    @param keyword 要转换的特殊类型关键字多态变体
    @return 转换结果，成功时返回对应Token，失败时返回错误 *)
val convert_special_type_keywords : Compiler_errors_types.position -> [> 
  | `IntTypeKeyword | `FloatTypeKeyword | `StringTypeKeyword | `BoolTypeKeyword | `UnitTypeKeyword
  | `ListTypeKeyword | `ArrayTypeKeyword | `VariantKeyword | `TagKeyword
  | `RhymeKeyword | `ToneKeyword | `ToneLevelKeyword | `ToneFallingKeyword | `ToneRisingKeyword
  | `ToneDepartingKeyword | `ToneEnteringKeyword | `ParallelKeyword | `PairedKeyword
  | `AntitheticKeyword | `BalancedKeyword | `PoetryKeyword | `FourCharKeyword | `FiveCharKeyword
  | `SevenCharKeyword | `ParallelStructKeyword | `RegulatedVerseKeyword | `QuatrainKeyword
  | `CoupletKeyword | `AntithesisKeyword | `MeterKeyword | `CadenceKeyword 
  | `IdentifierTokenSpecial ] -> Lexer_tokens.token Compiler_errors_types.error_result

(** 将多态变体转换为token类型 - 主入口函数
    尝试使用各种关键字转换器来转换给定的多态变体为Token类型
    
    @param pos 位置信息，用于错误报告
    @param variant 要转换的关键字多态变体（接受所有类型的关键字变体）
    @return 转换结果，成功时返回对应Token，失败时返回错误 *)
val variant_to_token : Compiler_errors_types.position -> [> 
  | `OrElseKeyword
  (* 基础关键字 *)
  | `LetKeyword | `RecKeyword | `InKeyword | `FunKeyword | `IfKeyword | `ThenKeyword
  | `ElseKeyword | `MatchKeyword | `WithKeyword | `OtherKeyword | `TypeKeyword | `PrivateKeyword
  | `TrueKeyword | `FalseKeyword | `AndKeyword | `OrKeyword | `NotKeyword | `OfKeyword 
  | `AsKeyword | `CombineKeyword | `WithOpKeyword | `WhenKeyword | `WithDefaultKeyword
  (* 系统关键字 *)
  | `ExceptionKeyword | `RaiseKeyword | `TryKeyword | `CatchKeyword | `FinallyKeyword
  | `ModuleKeyword | `ModuleTypeKeyword | `RefKeyword | `IncludeKeyword | `FunctorKeyword
  | `SigKeyword | `EndKeyword | `MacroKeyword | `ExpandKeyword
  (* 中文风格关键字 *)
  | `HaveKeyword | `OneKeyword | `NameKeyword | `SetKeyword | `AlsoKeyword | `ThenGetKeyword
  | `CallKeyword | `ValueKeyword | `AsForKeyword | `NumberKeyword | `WantExecuteKeyword
  | `MustFirstGetKeyword | `ForThisKeyword | `TimesKeyword | `EndCloudKeyword | `IfWenyanKeyword
  | `ThenWenyanKeyword | `GreaterThanWenyan | `LessThanWenyan 
  | `AncientDefineKeyword | `AncientEndKeyword | `AncientAlgorithmKeyword
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
  | `AncientRecordEmptyKeyword | `AncientRecordUpdateKeyword | `AncientRecordFinishKeyword
  | `DefineKeyword | `AcceptKeyword | `ReturnWhenKeyword | `ElseReturnKeyword | `MultiplyKeyword
  | `DivideKeyword | `AddToKeyword | `SubtractKeyword | `EqualToKeyword | `LessThanEqualToKeyword
  | `FirstElementKeyword | `RemainingKeyword | `EmptyKeyword | `CharacterCountKeyword
  | `InputKeyword | `OutputKeyword | `MinusOneKeyword | `PlusKeyword | `WhereKeyword
  | `SmallKeyword | `ShouldGetKeyword | `OfParticle | `IsKeyword | `TopicMarker
  (* 特殊类型关键字 *)
  | `IntTypeKeyword | `FloatTypeKeyword | `StringTypeKeyword | `BoolTypeKeyword | `UnitTypeKeyword
  | `ListTypeKeyword | `ArrayTypeKeyword | `VariantKeyword | `TagKeyword
  | `RhymeKeyword | `ToneKeyword | `ToneLevelKeyword | `ToneFallingKeyword | `ToneRisingKeyword
  | `ToneDepartingKeyword | `ToneEnteringKeyword | `ParallelKeyword | `PairedKeyword
  | `AntitheticKeyword | `BalancedKeyword | `PoetryKeyword | `FourCharKeyword | `FiveCharKeyword
  | `SevenCharKeyword | `ParallelStructKeyword | `RegulatedVerseKeyword | `QuatrainKeyword
  | `CoupletKeyword | `AntithesisKeyword | `MeterKeyword | `CadenceKeyword 
  | `IdentifierTokenSpecial ] -> Lexer_tokens.token Compiler_errors_types.error_result