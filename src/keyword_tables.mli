(** 骆言关键字表模块接口 - Chinese Programming Language Keyword Tables Interface *)

(** 字符串比较模块 *)
module StringCompare : sig
  type t = string

  val compare : t -> t -> int
end

module StringMap : Map.S with type key = string
(** 字符串Map模块 *)

module StringSet : Set.S with type elt = string
(** 字符串Set模块 *)

(** 关键字映射模块 *)
module Keywords : sig
  val basic_keywords :
    (string
    * [> `LetKeyword
      | `RecKeyword
      | `InKeyword
      | `FunKeyword
      | `ParamKeyword
      | `CallKeyword
      | `IfKeyword
      | `ThenKeyword
      | `ElseKeyword
      | `MatchKeyword
      | `WithKeyword
      | `OtherKeyword
      | `TypeKeyword
      | `PrivateKeyword
      | `TrueKeyword
      | `FalseKeyword
      | `AndKeyword
      | `OrKeyword
      | `NotKeyword ])
    list
  (** 基础关键字映射表 *)

  val semantic_keywords :
    (string * [> `AsKeyword | `CombineKeyword | `WithOpKeyword | `WhenKeyword ]) list
  (** 语义类型系统关键字 *)

  val error_recovery_keywords :
    (string
    * [> `WithDefaultKeyword
      | `ExceptionKeyword
      | `RaiseKeyword
      | `TryKeyword
      | `CatchKeyword
      | `FinallyKeyword ])
    list
  (** 错误恢复关键字 *)

  val type_keywords : (string * [> `OfKeyword ]) list
  (** 类型关键字 *)

  val module_keywords :
    (string
    * [> `ModuleKeyword
      | `ModuleTypeKeyword
      | `RefKeyword
      | `IncludeKeyword
      | `FunctorKeyword
      | `SigKeyword
      | `EndKeyword ])
    list
  (** 模块系统关键字 *)

  val macro_keywords : (string * [> `MacroKeyword | `ExpandKeyword ]) list
  (** 宏系统关键字 *)

  val wenyan_keywords :
    (string
    * [> `HaveKeyword
      | `OneKeyword
      | `NameKeyword
      | `SetKeyword
      | `AlsoKeyword
      | `ThenGetKeyword
      | `CallKeyword
      | `ValueKeyword
      | `AsForKeyword
      | `NumberKeyword ])
    list
  (** wenyan风格关键字 *)

  val wenyan_extended_keywords :
    (string
    * [> `WantExecuteKeyword
      | `MustFirstGetKeyword
      | `ForThisKeyword
      | `TimesKeyword
      | `EndCloudKeyword
      | `IfWenyanKeyword
      | `ThenWenyanKeyword
      | `GreaterThanWenyan
      | `LessThanWenyan
      | `OfParticle ])
    list
  (** wenyan扩展关键字 *)

  val natural_language_keywords :
    (string
    * [> `DefineKeyword
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
      | `ParamKeyword
      | `MinusOneKeyword
      | `PlusKeyword
      | `WhereKeyword
      | `SmallKeyword
      | `ShouldGetKeyword ])
    list
  (** 自然语言函数定义关键字 *)

  val type_annotation_keywords :
    (string
    * [> `IntTypeKeyword
      | `FloatTypeKeyword
      | `StringTypeKeyword
      | `BoolTypeKeyword
      | `UnitTypeKeyword
      | `ListTypeKeyword
      | `ArrayTypeKeyword ])
    list
  (** 基本类型关键字 *)

  val variant_keywords : (string * [> `VariantKeyword | `TagKeyword ]) list
  (** 多态变体关键字 *)

  val ancient_keywords :
    (string
    * [> `AncientDefineKeyword
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
      | `AncientRecordFinishKeyword ])
    list
  (** 古雅体关键字 *)

  val special_keywords : (string * [> `IdentifierTokenSpecial ]) list
  (** 特殊关键字 *)

  val all_keywords_list :
    (string
    * [> `LetKeyword
      | `RecKeyword
      | `InKeyword
      | `FunKeyword
      | `IfKeyword
      | `ThenKeyword
      | `ElseKeyword
      | `MatchKeyword
      | `WithKeyword
      | `OtherKeyword
      | `TypeKeyword
      | `PrivateKeyword
      | `TrueKeyword
      | `FalseKeyword
      | `AndKeyword
      | `OrKeyword
      | `NotKeyword
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
      | `OfKeyword
      | `ModuleKeyword
      | `ModuleTypeKeyword
      | `RefKeyword
      | `IncludeKeyword
      | `FunctorKeyword
      | `SigKeyword
      | `EndKeyword
      | `MacroKeyword
      | `ExpandKeyword
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
      | `OfParticle
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
      | `ParamKeyword
      | `MinusOneKeyword
      | `PlusKeyword
      | `WhereKeyword
      | `SmallKeyword
      | `ShouldGetKeyword
      | `IntTypeKeyword
      | `FloatTypeKeyword
      | `StringTypeKeyword
      | `BoolTypeKeyword
      | `UnitTypeKeyword
      | `ListTypeKeyword
      | `ArrayTypeKeyword
      | `VariantKeyword
      | `TagKeyword
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
      | `IdentifierTokenSpecial ])
    list
  (** 合并所有关键字 *)

  val keyword_map :
    [> `LetKeyword
    | `RecKeyword
    | `InKeyword
    | `FunKeyword
    | `IfKeyword
    | `ThenKeyword
    | `ElseKeyword
    | `MatchKeyword
    | `WithKeyword
    | `OtherKeyword
    | `TypeKeyword
    | `PrivateKeyword
    | `TrueKeyword
    | `FalseKeyword
    | `AndKeyword
    | `OrKeyword
    | `NotKeyword
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
    | `OfKeyword
    | `ModuleKeyword
    | `ModuleTypeKeyword
    | `RefKeyword
    | `IncludeKeyword
    | `FunctorKeyword
    | `SigKeyword
    | `EndKeyword
    | `MacroKeyword
    | `ExpandKeyword
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
    | `OfParticle
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
    | `ParamKeyword
    | `MinusOneKeyword
    | `PlusKeyword
    | `WhereKeyword
    | `SmallKeyword
    | `ShouldGetKeyword
    | `IntTypeKeyword
    | `FloatTypeKeyword
    | `StringTypeKeyword
    | `BoolTypeKeyword
    | `UnitTypeKeyword
    | `ListTypeKeyword
    | `ArrayTypeKeyword
    | `VariantKeyword
    | `TagKeyword
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
    | `IdentifierTokenSpecial ]
    StringMap.t
  (** 高效关键字映射表 *)

  val find_keyword :
    string ->
    [> `LetKeyword
    | `RecKeyword
    | `InKeyword
    | `FunKeyword
    | `IfKeyword
    | `ThenKeyword
    | `ElseKeyword
    | `MatchKeyword
    | `WithKeyword
    | `OtherKeyword
    | `TypeKeyword
    | `PrivateKeyword
    | `TrueKeyword
    | `FalseKeyword
    | `AndKeyword
    | `OrKeyword
    | `NotKeyword
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
    | `OfKeyword
    | `ModuleKeyword
    | `ModuleTypeKeyword
    | `RefKeyword
    | `IncludeKeyword
    | `FunctorKeyword
    | `SigKeyword
    | `EndKeyword
    | `MacroKeyword
    | `ExpandKeyword
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
    | `OfParticle
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
    | `ParamKeyword
    | `MinusOneKeyword
    | `PlusKeyword
    | `WhereKeyword
    | `SmallKeyword
    | `ShouldGetKeyword
    | `IntTypeKeyword
    | `FloatTypeKeyword
    | `StringTypeKeyword
    | `BoolTypeKeyword
    | `UnitTypeKeyword
    | `ListTypeKeyword
    | `ArrayTypeKeyword
    | `VariantKeyword
    | `TagKeyword
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
    | `IdentifierTokenSpecial ]
    option
  (** 高效关键字查找 *)

  val is_keyword : string -> bool
  (** 检查是否为关键字 *)

  val all_keywords : unit -> string list
  (** 获取所有关键字列表 *)
end

(** 保留词模块 *)
module ReservedWords : sig
  val reserved_words_list : string list
  (** 保留词列表 *)

  val reserved_words_set : StringSet.t
  (** 高效保留词集合 *)

  val is_reserved_word : string -> bool
  (** 检查是否为保留词 *)

  val all_reserved_words : unit -> string list
  (** 获取所有保留词列表 *)
end
