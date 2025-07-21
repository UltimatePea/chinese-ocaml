(** 基础关键字Token映射模块 - 优化版本，保持向后兼容 第五阶段系统一致性优化：改进错误消息的清晰性和一致性。

    @version 3.0 (错误处理改进版)
    @since 2025-07-20 Issue #718 系统一致性优化 *)

open Token_definitions_unified

exception TokenMappingError of string * string (* error_type * message *)
(** 统一的映射错误异常类型 *)

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
  | _ -> raise (TokenMappingError ("TypeError", "不是基础编程关键字"))

(** 映射语义相关关键字（as, combine等） *)
let map_semantic_keywords = function
  | `AsKeyword -> AsKeyword
  | `CombineKeyword -> CombineKeyword
  | `WithOpKeyword -> WithOpKeyword
  | `WhenKeyword -> WhenKeyword
  | _ -> raise (TokenMappingError ("TypeError", "不是语义关键字"))

(** 映射错误处理关键字（try, catch等） *)
let map_error_recovery_keywords = function
  | `WithDefaultKeyword -> WithDefaultKeyword
  | `ExceptionKeyword -> ExceptionKeyword
  | `RaiseKeyword -> RaiseKeyword
  | `TryKeyword -> TryKeyword
  | `CatchKeyword -> CatchKeyword
  | `FinallyKeyword -> FinallyKeyword
  | _ -> raise (TokenMappingError ("TypeError", "不是错误处理关键字"))

(** 映射模块系统关键字（module, functor等） *)
let map_module_keywords = function
  | `ModuleKeyword -> ModuleKeyword
  | `ModuleTypeKeyword -> ModuleTypeKeyword
  | `RefKeyword -> RefKeyword
  | `IncludeKeyword -> IncludeKeyword
  | `FunctorKeyword -> FunctorKeyword
  | `SigKeyword -> SigKeyword
  | `EndKeyword -> EndKeyword
  | _ -> raise (TokenMappingError ("TypeError", "不是模块关键字"))

(** 映射宏系统关键字 *)
let map_macro_keywords = function
  | `MacroKeyword -> MacroKeyword
  | `ExpandKeyword -> ExpandKeyword
  | _ -> raise (TokenMappingError ("TypeError", "不是宏关键字"))

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
  | _ -> raise (TokenMappingError ("TypeError", "不是类型标注关键字"))

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
  | _ -> raise (TokenMappingError ("TypeError", "不是文言文关键字"))

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
  | _ -> raise (TokenMappingError ("TypeError", "不是自然语言关键字"))

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
  | _ -> raise (TokenMappingError ("TypeError", "不是古雅体关键字"))

(** 映射特殊标识符 *)
let map_special_identifiers = function
  | `IdentifierTokenSpecial -> IdentifierTokenSpecial ""
  | _ -> raise (TokenMappingError ("TypeError", "不是特殊标识符"))

(** 关键字映射器列表 - 重构：消除深度嵌套的try-catch *)
let keyword_mappers =
  [
    ("基础编程关键字", map_basic_programming_keywords);
    ("语义关键字", map_semantic_keywords);
    ("错误处理关键字", map_error_recovery_keywords);
    ("模块关键字", map_module_keywords);
    ("宏关键字", map_macro_keywords);
    ("类型标注关键字", map_type_annotation_keywords);
    ("文言文关键字", map_wenyan_keywords);
    ("自然语言关键字", map_natural_language_keywords);
    ("古雅体关键字", map_ancient_keywords);
    ("特殊标识符", map_special_identifiers);
  ]

(** 尝试按顺序应用映射器 - 重构：减少嵌套层次 *)
let try_mappers variant mappers =
  let rec try_next = function
    | [] -> None
    | (_, mapper) :: rest -> (
        try Some (mapper variant) with TokenMappingError _ -> try_next rest)
  in
  try_next mappers

(** 映射基础关键字变体到Token - 重构：消除深度嵌套 *)
let map_basic_variant variant =
  match try_mappers variant keyword_mappers with
  | Some token -> token
  | None ->
      raise (TokenMappingError ("CompilerError", "Unmapped keyword variant - needs manual review"))
