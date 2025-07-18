(** Token类型定义(从主模块复制的必要部分) *)

(** 中文OCaml编程语言的Token类型定义 包含字面量、标识符、基础关键字、类型关键字、语义关键字、错误恢复关键字、 模块关键字、宏关键字、文言文关键字、自然语言关键字和古雅体关键字等 *)
type token =
  (* 字面量 *)
  | IntToken of int
  | FloatToken of float
  | ChineseNumberToken of string
  | StringToken of string
  | BoolToken of bool
  (* 标识符 *)
  | QuotedIdentifierToken of string
  | IdentifierTokenSpecial of string
  (* 基础关键字 *)
  | LetKeyword
  | RecKeyword
  | InKeyword
  | FunKeyword
  | IfKeyword
  | ThenKeyword
  | ElseKeyword
  | MatchKeyword
  | WithKeyword
  | OtherKeyword
  | AndKeyword
  | OrKeyword
  | NotKeyword
  | OfKeyword
  (* 类型关键字 *)
  | TypeKeyword
  | PrivateKeyword
  | InputKeyword
  | OutputKeyword
  | IntTypeKeyword
  | FloatTypeKeyword
  | StringTypeKeyword
  | BoolTypeKeyword
  | UnitTypeKeyword
  | ListTypeKeyword
  | ArrayTypeKeyword
  | VariantKeyword
  | TagKeyword
  (* 语义关键字 *)
  | AsKeyword
  | CombineKeyword
  | WithOpKeyword
  | WhenKeyword
  (* 错误恢复关键字 *)
  | WithDefaultKeyword
  | ExceptionKeyword
  | RaiseKeyword
  | TryKeyword
  | CatchKeyword
  | FinallyKeyword
  (* 模块关键字 *)
  | ModuleKeyword
  | ModuleTypeKeyword
  | RefKeyword
  | IncludeKeyword
  | FunctorKeyword
  | SigKeyword
  | EndKeyword
  (* 宏关键字 *)
  | MacroKeyword
  | ExpandKeyword
  (* 文言文关键字 *)
  | HaveKeyword
  | OneKeyword
  | NameKeyword
  | SetKeyword
  | AlsoKeyword
  | ThenGetKeyword
  | CallKeyword
  | ValueKeyword
  | AsForKeyword
  | NumberKeyword
  | WantExecuteKeyword
  | MustFirstGetKeyword
  | ForThisKeyword
  | TimesKeyword
  | EndCloudKeyword
  | IfWenyanKeyword
  | ThenWenyanKeyword
  | GreaterThanWenyan
  | LessThanWenyan
  (* 自然语言关键字 *)
  | DefineKeyword
  | AcceptKeyword
  | ReturnWhenKeyword
  | ElseReturnKeyword
  | MultiplyKeyword
  | DivideKeyword
  | AddToKeyword
  | SubtractKeyword
  | EqualToKeyword
  | LessThanEqualToKeyword
  | FirstElementKeyword
  | RemainingKeyword
  | EmptyKeyword
  | CharacterCountKeyword
  | OfParticle
  | MinusOneKeyword
  | PlusKeyword
  | WhereKeyword
  | SmallKeyword
  | ShouldGetKeyword
  (* 古雅体关键字 *)
  | AncientDefineKeyword
  | AncientEndKeyword
  | AncientAlgorithmKeyword
  | AncientCompleteKeyword
  | AncientObserveKeyword
  | AncientNatureKeyword
  | AncientThenKeyword
  | AncientOtherwiseKeyword
  | AncientAnswerKeyword
  | AncientCombineKeyword
  | AncientAsOneKeyword
  | AncientTakeKeyword
  | AncientReceiveKeyword
  | AncientParticleThe
  | AncientParticleFun
  | AncientCallItKeyword
  | AncientListStartKeyword
  | AncientListEndKeyword
  | AncientItsFirstKeyword
  | AncientItsSecondKeyword
  | AncientItsThirdKeyword
  | AncientEmptyKeyword
  | AncientHasHeadTailKeyword
  | AncientHeadNameKeyword
  | AncientTailNameKeyword
  | AncientThusAnswerKeyword
  | AncientAddToKeyword
  | AncientObserveEndKeyword
  | AncientBeginKeyword
  | AncientEndCompleteKeyword
  | AncientIsKeyword
  | AncientArrowKeyword
  | AncientWhenKeyword
  | AncientCommaKeyword
  | AfterThatKeyword
  | AncientRecordStartKeyword
  | AncientRecordEndKeyword
  | AncientRecordEmptyKeyword
  | AncientRecordUpdateKeyword
  | AncientRecordFinishKeyword
