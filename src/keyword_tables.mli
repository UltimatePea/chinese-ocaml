(** 骆言关键字表模块接口 - Chinese Programming Language Keyword Tables Interface *)

module StringMap : Map.S with type key = string
(** 字符串Map模块 *)

module StringSet : Set.S with type elt = string
(** 字符串Set模块 *)

(** 关键字映射模块 *)
module Keywords : sig
  val find_keyword :
    string ->
    [ `LetKeyword
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
    | `AncientObserveEndKeyword
    | `IdentifierTokenSpecial ]
    option
  (** 高效关键字查找 *)

  val is_keyword : string -> bool
  (** 检查是否为关键字 *)

  val all_keywords : unit -> string list
  (** 获取所有关键字列表 *)

  val all_keywords_list :
    (string
    * [ `LetKeyword
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
      | `AncientObserveEndKeyword
      | `IdentifierTokenSpecial ])
    list
  (** 保持向后兼容性的关键字列表 *)
end

(** 保留词模块 *)
module ReservedWords : sig
  val is_reserved_word : string -> bool
  (** 检查是否为保留词 *)

  val all_reserved_words : unit -> string list
  (** 获取所有保留词列表 *)
end
