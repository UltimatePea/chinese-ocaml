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

(** 文言文关键字转换表 - 数据与逻辑分离 *)
let wenyan_keyword_mapping = [
  (* 声明和定义 *)
  (`HaveKeyword, HaveKeyword);
  (`OneKeyword, OneKeyword);
  (`NameKeyword, NameKeyword);
  (`SetKeyword, SetKeyword);
  
  (* 逻辑连接词 *)
  (`AlsoKeyword, AlsoKeyword);
  (`ThenGetKeyword, ThenGetKeyword);
  (`AsForKeyword, AsForKeyword);
  
  (* 函数和调用 *)
  (`CallKeyword, CallKeyword);
  (`ValueKeyword, ValueKeyword);
  (`WantExecuteKeyword, WantExecuteKeyword);
  (`MustFirstGetKeyword, MustFirstGetKeyword);
  
  (* 循环和计数 *)
  (`ForThisKeyword, ForThisKeyword);
  (`TimesKeyword, TimesKeyword);
  (`NumberKeyword, NumberKeyword);
  
  (* 控制结构 *)
  (`EndCloudKeyword, EndCloudKeyword);
  (`IfWenyanKeyword, IfWenyanKeyword);
  (`ThenWenyanKeyword, ThenWenyanKeyword);
  
  (* 比较运算符 *)
  (`GreaterThanWenyan, GreaterThanWenyan);
  (`LessThanWenyan, LessThanWenyan);
]

(** 文言文风格关键字转换 - 数据驱动实现 *)
let convert_wenyan_keywords pos variant =
  try
    Ok (List.assoc variant wenyan_keyword_mapping)
  with Not_found -> 
    unsupported_keyword_error "未知的文言文关键字" pos

(** 古文关键字转换表 - 数据与逻辑分离 *)
let ancient_keyword_mapping = [
  (* 基础语言结构关键词 *)
  (`AncientDefineKeyword, AncientDefineKeyword);
  (`AncientEndKeyword, AncientEndKeyword);
  (`AncientAlgorithmKeyword, AncientAlgorithmKeyword);
  (`AncientCompleteKeyword, AncientCompleteKeyword);
  (`AncientObserveKeyword, AncientObserveKeyword);
  (`AncientNatureKeyword, AncientNatureKeyword);
  (`AncientThenKeyword, AncientThenKeyword);
  (`AncientOtherwiseKeyword, AncientOtherwiseKeyword);
  (`AncientAnswerKeyword, AncientAnswerKeyword);
  (`AncientCombineKeyword, AncientCombineKeyword);
  (`AncientAsOneKeyword, AncientAsOneKeyword);
  (`AncientTakeKeyword, AncientTakeKeyword);
  (`AncientReceiveKeyword, AncientReceiveKeyword);
  
  (* 语法助词 *)
  (`AncientParticleThe, AncientParticleThe);
  (`AncientParticleFun, AncientParticleFun);
  (`AncientParticleOf, AncientParticleOf);
  
  (* 函数和调用相关 *)
  (`AncientCallItKeyword, AncientCallItKeyword);
  
  (* 列表操作关键词 *)
  (`AncientListStartKeyword, AncientListStartKeyword);
  (`AncientListEndKeyword, AncientListEndKeyword);
  (`AncientItsFirstKeyword, AncientItsFirstKeyword);
  (`AncientItsSecondKeyword, AncientItsSecondKeyword);
  (`AncientItsThirdKeyword, AncientItsThirdKeyword);
  (`AncientEmptyKeyword, AncientEmptyKeyword);
  (`AncientHasHeadTailKeyword, AncientHasHeadTailKeyword);
  (`AncientHeadNameKeyword, AncientHeadNameKeyword);
  (`AncientTailNameKeyword, AncientTailNameKeyword);
  (`AncientThusAnswerKeyword, AncientThusAnswerKeyword);
  
  (* 运算和操作关键词 *)
  (`AncientAddToKeyword, AncientAddToKeyword);
  (`AncientObserveEndKeyword, AncientObserveEndKeyword);
  (`AncientBeginKeyword, AncientBeginKeyword);
  (`AncientEndCompleteKeyword, AncientEndCompleteKeyword);
  (`AncientIsKeyword, AncientIsKeyword);
  (`AncientArrowKeyword, AncientArrowKeyword);
  (`AncientWhenKeyword, AncientWhenKeyword);
  
  (* 标点符号关键词 *)
  (`AncientCommaKeyword, AncientCommaKeyword);
  (`AncientPeriodKeyword, AncientPeriodKeyword);
  
  (* 条件和递归 *)
  (`AncientIfKeyword, AncientIfKeyword);
  (`AncientRecursiveKeyword, AncientRecursiveKeyword);
  (`AfterThatKeyword, AfterThatKeyword);
  
  (* 古雅体记录类型关键词 *)
  (`AncientRecordStartKeyword, AncientRecordStartKeyword);
  (`AncientRecordEndKeyword, AncientRecordEndKeyword);
  (`AncientRecordEmptyKeyword, AncientRecordEmptyKeyword);
  (`AncientRecordUpdateKeyword, AncientRecordUpdateKeyword);
  (`AncientRecordFinishKeyword, AncientRecordFinishKeyword);
]

(** 古文关键字转换 - 数据驱动实现 *)
let convert_ancient_keywords pos variant =
  try
    Ok (List.assoc variant ancient_keyword_mapping)
  with Not_found -> 
    unsupported_keyword_error "未知的古文关键字" pos

(** 自然语言关键字转换表 - 数据与逻辑分离 *)
let natural_keyword_mapping = [
  (* 函数定义和控制 *)
  (`DefineKeyword, DefineKeyword);
  (`AcceptKeyword, AcceptKeyword);
  (`ReturnWhenKeyword, ReturnWhenKeyword);
  (`ElseReturnKeyword, ElseReturnKeyword);
  
  (* 数学运算 *)
  (`MultiplyKeyword, MultiplyKeyword);
  (`DivideKeyword, DivideKeyword);
  (`AddToKeyword, AddToKeyword);
  (`SubtractKeyword, SubtractKeyword);
  (`PlusKeyword, PlusKeyword);
  (`MinusOneKeyword, MinusOneKeyword);
  
  (* 比较和逻辑 *)
  (`EqualToKeyword, EqualToKeyword);
  (`LessThanEqualToKeyword, LessThanEqualToKeyword);
  (`IsKeyword, IsKeyword);
  
  (* 列表和数据结构 *)
  (`FirstElementKeyword, FirstElementKeyword);
  (`RemainingKeyword, RemainingKeyword);
  (`EmptyKeyword, EmptyKeyword);
  (`CharacterCountKeyword, CharacterCountKeyword);
  
  (* 输入输出 *)
  (`InputKeyword, InputKeyword);
  (`OutputKeyword, OutputKeyword);
  
  (* 语法助词和修饰符 *)
  (`WhereKeyword, WhereKeyword);
  (`SmallKeyword, SmallKeyword);
  (`ShouldGetKeyword, ShouldGetKeyword);
  (`OfParticle, OfParticle);
  (`TopicMarker, TopicMarker);
]

(** 自然语言关键字转换 - 数据驱动实现 *)
let convert_natural_keywords pos variant =
  try
    Ok (List.assoc variant natural_keyword_mapping)
  with Not_found -> 
    unsupported_keyword_error "未知的自然语言关键字" pos

(** 类型关键字转换表 - 数据与逻辑分离 *)
let type_keyword_mapping = [
  (* 基础类型 *)
  (`IntTypeKeyword, IntTypeKeyword);
  (`FloatTypeKeyword, FloatTypeKeyword);
  (`StringTypeKeyword, StringTypeKeyword);
  (`BoolTypeKeyword, BoolTypeKeyword);
  (`UnitTypeKeyword, UnitTypeKeyword);
  
  (* 复合类型 *)
  (`ListTypeKeyword, ListTypeKeyword);
  (`ArrayTypeKeyword, ArrayTypeKeyword);
  
  (* 高级类型 *)
  (`VariantKeyword, VariantKeyword);
  (`TagKeyword, TagKeyword);
]

(** 类型关键字转换 - 数据驱动实现 *)
let convert_type_keywords pos variant =
  try
    Ok (List.assoc variant type_keyword_mapping)
  with Not_found -> 
    unsupported_keyword_error "未知的类型关键字" pos

(** 古典诗词关键字转换表 - 数据与逻辑分离 *)
let poetry_keyword_mapping = [
  (* 韵律相关 *)
  (`RhymeKeyword, RhymeKeyword);
  (`MeterKeyword, MeterKeyword);
  (`CadenceKeyword, CadenceKeyword);
  
  (* 声调系统 *)
  (`ToneKeyword, ToneKeyword);
  (`ToneLevelKeyword, ToneLevelKeyword);
  (`ToneFallingKeyword, ToneFallingKeyword);
  (`ToneRisingKeyword, ToneRisingKeyword);
  (`ToneDepartingKeyword, ToneDepartingKeyword);
  (`ToneEnteringKeyword, ToneEnteringKeyword);
  
  (* 对仗和平行结构 *)
  (`ParallelKeyword, ParallelKeyword);
  (`PairedKeyword, PairedKeyword);
  (`AntitheticKeyword, AntitheticKeyword);
  (`BalancedKeyword, BalancedKeyword);
  (`ParallelStructKeyword, ParallelStructKeyword);
  (`AntithesisKeyword, AntithesisKeyword);
  
  (* 诗体分类 *)
  (`PoetryKeyword, PoetryKeyword);
  (`RegulatedVerseKeyword, RegulatedVerseKeyword);
  (`QuatrainKeyword, QuatrainKeyword);
  (`CoupletKeyword, CoupletKeyword);
  
  (* 字数分类 *)
  (`FourCharKeyword, FourCharKeyword);
  (`FiveCharKeyword, FiveCharKeyword);
  (`SevenCharKeyword, SevenCharKeyword);
]

(** 古典诗词关键字转换 - 数据驱动实现 *)
let convert_poetry_keywords pos variant =
  try
    Ok (List.assoc variant poetry_keyword_mapping)
  with Not_found -> 
    unsupported_keyword_error "未知的诗词关键字" pos

(** 特殊标识符转换 *)
let convert_special_identifier pos = function
  | `IdentifierTokenSpecial -> Ok (IdentifierTokenSpecial "数值")
  | _ -> unsupported_keyword_error "未知的特殊标识符" pos

(** 转换基础和语义关键字 *)
let convert_core_keywords pos = function
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
  | _ -> unsupported_keyword_error "不是核心关键字" pos

(** 转换系统关键字 *)
let convert_system_keywords pos = function
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
  | _ -> unsupported_keyword_error "不是系统关键字" pos

(** 转换中文风格关键字 *)
let convert_chinese_style_keywords pos = function
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
  | _ -> unsupported_keyword_error "不是中文风格关键字" pos

(** 转换特殊类型关键字 *)
let convert_special_type_keywords pos = function
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
