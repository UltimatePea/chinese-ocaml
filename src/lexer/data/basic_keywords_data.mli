(** 骆言基础关键字数据模块接口
    
    本模块提供骆言编程语言的所有关键字数据定义，
    经过模块化重构以提升可维护性和访问效率。
    
    @since Phase8 技术债务重构
    @author 骆言团队 *)

(** {1 基础关键字分组} *)

(** 基础控制流和语法关键字 *)
val basic_keywords : (string * [> `LetKeyword | `RecKeyword | `InKeyword | `FunKeyword 
                                | `IfKeyword | `ThenKeyword | `ElseKeyword | `MatchKeyword 
                                | `WithKeyword | `OtherKeyword | `TypeKeyword | `PrivateKeyword
                                | `TrueKeyword | `FalseKeyword | `AndKeyword | `OrKeyword | `NotKeyword ]) list

(** 语义类型系统关键字 *)
val semantic_keywords : (string * [> `AsKeyword | `CombineKeyword | `WithOpKeyword | `WhenKeyword ]) list

(** 错误处理和恢复关键字 *)
val error_recovery_keywords : (string * [> `WithDefaultKeyword | `ExceptionKeyword | `RaiseKeyword 
                                          | `TryKeyword | `CatchKeyword | `FinallyKeyword ]) list

(** {1 类型系统关键字} *)

(** 类型定义关键字 *)
val type_keywords : (string * [> `OfKeyword ]) list

(** 类型注解关键字 *)
val type_annotation_keywords : (string * [> `IntTypeKeyword | `FloatTypeKeyword | `StringTypeKeyword 
                                          | `BoolTypeKeyword | `UnitTypeKeyword | `ListTypeKeyword 
                                          | `ArrayTypeKeyword ]) list

(** 多态变体关键字 *)
val variant_keywords : (string * [> `VariantKeyword | `TagKeyword ]) list

(** {1 模块系统关键字} *)

(** 模块定义和操作关键字 *)
val module_keywords : (string * [> `ModuleKeyword | `ModuleTypeKeyword | `RefKeyword 
                                 | `IncludeKeyword | `FunctorKeyword | `SigKeyword | `EndKeyword ]) list

(** 宏系统关键字 *)
val macro_keywords : (string * [> `MacroKeyword | `ExpandKeyword ]) list

(** {1 文言文风格关键字} *)

(** wenyan基础关键字 *)
val wenyan_keywords : (string * [> `HaveKeyword | `OneKeyword | `NameKeyword | `SetKeyword 
                                 | `AlsoKeyword | `ThenGetKeyword | `CallKeyword | `ValueKeyword 
                                 | `AsForKeyword | `NumberKeyword ]) list

(** wenyan扩展关键字 *)
val wenyan_extended_keywords : (string * [> `WantExecuteKeyword | `MustFirstGetKeyword | `ForThisKeyword 
                                          | `TimesKeyword | `EndCloudKeyword | `IfWenyanKeyword 
                                          | `ThenWenyanKeyword | `GreaterThanWenyan | `LessThanWenyan 
                                          | `OfParticle ]) list

(** {1 自然语言关键字} *)

(** 自然语言函数定义关键字 *)
val natural_language_keywords : (string * [> `DefineKeyword | `AcceptKeyword | `ReturnWhenKeyword 
                                           | `ElseReturnKeyword | `MultiplyKeyword | `DivideKeyword 
                                           | `AddToKeyword | `SubtractKeyword | `EqualToKeyword 
                                           | `LessThanEqualToKeyword | `FirstElementKeyword | `RemainingKeyword 
                                           | `EmptyKeyword | `CharacterCountKeyword | `InputKeyword 
                                           | `OutputKeyword | `MinusOneKeyword | `PlusKeyword 
                                           | `WhereKeyword | `SmallKeyword | `ShouldGetKeyword ]) list

(** {1 古雅体关键字} *)

(** 古雅体语法关键字 *)
val ancient_keywords : (string * [> `AncientDefineKeyword | `AncientEndKeyword | `AncientAlgorithmKeyword 
                                  | `AncientCompleteKeyword | `AncientObserveKeyword | `AncientNatureKeyword 
                                  | `AncientThenKeyword | `AncientOtherwiseKeyword | `AncientAnswerKeyword 
                                  | `AncientCombineKeyword | `AncientAsOneKeyword | `AncientTakeKeyword 
                                  | `AncientReceiveKeyword | `AncientParticleThe | `AncientParticleFun 
                                  | `AncientCallItKeyword | `AncientListStartKeyword | `AncientListEndKeyword 
                                  | `AncientItsFirstKeyword | `AncientItsSecondKeyword | `AncientItsThirdKeyword 
                                  | `AncientEmptyKeyword | `AncientHasHeadTailKeyword | `AncientHeadNameKeyword 
                                  | `AncientTailNameKeyword | `AncientThusAnswerKeyword | `AncientAddToKeyword 
                                  | `AncientObserveEndKeyword | `AncientBeginKeyword | `AncientEndCompleteKeyword 
                                  | `AncientIsKeyword | `AncientArrowKeyword | `AncientWhenKeyword 
                                  | `AncientCommaKeyword | `AfterThatKeyword | `AncientRecordStartKeyword 
                                  | `AncientRecordEndKeyword | `AncientRecordEmptyKeyword | `AncientRecordUpdateKeyword 
                                  | `AncientRecordFinishKeyword ]) list

(** {1 特殊关键字} *)

(** 特殊处理关键字 *)
val special_keywords : (string * [> `IdentifierTokenSpecial ]) list

(** {1 聚合访问} *)

(** 所有关键字的合并列表 
    @return 包含所有关键字分类的完整列表 *)
val all_keywords_list : (string * [> `LetKeyword | `RecKeyword | `InKeyword | `FunKeyword 
                                    | `IfKeyword | `ThenKeyword | `ElseKeyword | `MatchKeyword 
                                    | `WithKeyword | `OtherKeyword | `TypeKeyword | `PrivateKeyword
                                    | `TrueKeyword | `FalseKeyword | `AndKeyword | `OrKeyword | `NotKeyword
                                    | `AsKeyword | `CombineKeyword | `WithOpKeyword | `WhenKeyword
                                    | `WithDefaultKeyword | `ExceptionKeyword | `RaiseKeyword 
                                    | `TryKeyword | `CatchKeyword | `FinallyKeyword
                                    | `OfKeyword | `IntTypeKeyword | `FloatTypeKeyword | `StringTypeKeyword 
                                    | `BoolTypeKeyword | `UnitTypeKeyword | `ListTypeKeyword | `ArrayTypeKeyword
                                    | `VariantKeyword | `TagKeyword | `ModuleKeyword | `ModuleTypeKeyword 
                                    | `RefKeyword | `IncludeKeyword | `FunctorKeyword | `SigKeyword | `EndKeyword
                                    | `MacroKeyword | `ExpandKeyword | `HaveKeyword | `OneKeyword | `NameKeyword 
                                    | `SetKeyword | `AlsoKeyword | `ThenGetKeyword | `CallKeyword | `ValueKeyword 
                                    | `AsForKeyword | `NumberKeyword | `WantExecuteKeyword | `MustFirstGetKeyword 
                                    | `ForThisKeyword | `TimesKeyword | `EndCloudKeyword | `IfWenyanKeyword 
                                    | `ThenWenyanKeyword | `GreaterThanWenyan | `LessThanWenyan | `OfParticle
                                    | `DefineKeyword | `AcceptKeyword | `ReturnWhenKeyword | `ElseReturnKeyword 
                                    | `MultiplyKeyword | `DivideKeyword | `AddToKeyword | `SubtractKeyword 
                                    | `EqualToKeyword | `LessThanEqualToKeyword | `FirstElementKeyword 
                                    | `RemainingKeyword | `EmptyKeyword | `CharacterCountKeyword | `InputKeyword 
                                    | `OutputKeyword | `MinusOneKeyword | `PlusKeyword | `WhereKeyword 
                                    | `SmallKeyword | `ShouldGetKeyword | `AncientDefineKeyword | `AncientEndKeyword 
                                    | `AncientAlgorithmKeyword | `AncientCompleteKeyword | `AncientObserveKeyword 
                                    | `AncientNatureKeyword | `AncientThenKeyword | `AncientOtherwiseKeyword 
                                    | `AncientAnswerKeyword | `AncientCombineKeyword | `AncientAsOneKeyword 
                                    | `AncientTakeKeyword | `AncientReceiveKeyword | `AncientParticleThe 
                                    | `AncientParticleFun | `AncientCallItKeyword | `AncientListStartKeyword 
                                    | `AncientListEndKeyword | `AncientItsFirstKeyword | `AncientItsSecondKeyword 
                                    | `AncientItsThirdKeyword | `AncientEmptyKeyword | `AncientHasHeadTailKeyword 
                                    | `AncientHeadNameKeyword | `AncientTailNameKeyword | `AncientThusAnswerKeyword 
                                    | `AncientAddToKeyword | `AncientObserveEndKeyword | `AncientBeginKeyword 
                                    | `AncientEndCompleteKeyword | `AncientIsKeyword | `AncientArrowKeyword 
                                    | `AncientWhenKeyword | `AncientCommaKeyword | `AfterThatKeyword 
                                    | `AncientRecordStartKeyword | `AncientRecordEndKeyword | `AncientRecordEmptyKeyword 
                                    | `AncientRecordUpdateKeyword | `AncientRecordFinishKeyword | `IdentifierTokenSpecial ]) list