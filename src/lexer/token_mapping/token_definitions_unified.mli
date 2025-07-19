(** 统一Token定义引用 - 指向主要的token定义 *)

(** {1 类型定义} *)

(** 为了避免循环依赖，我们直接定义最小化的token类型子集 *)
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
  | LetKeyword | RecKeyword | InKeyword | FunKeyword 
  | IfKeyword | ThenKeyword | ElseKeyword | MatchKeyword 
  | WithKeyword | OtherKeyword | AndKeyword | OrKeyword 
  | NotKeyword | OfKeyword 
  | TrueKeyword | FalseKeyword
  (* 语义关键字 *)
  | AsKeyword | CombineKeyword | WithOpKeyword | WhenKeyword 
  | WithDefaultKeyword | ExceptionKeyword | RaiseKeyword 
  | TryKeyword | CatchKeyword | FinallyKeyword
  (* 模块关键字 *)
  | ModuleKeyword | ModuleTypeKeyword | RefKeyword 
  | IncludeKeyword | FunctorKeyword | SigKeyword | EndKeyword
  (* 宏关键字 *)
  | MacroKeyword | ExpandKeyword
  (* 类型关键字 *)
  | TypeKeyword | PrivateKeyword | InputKeyword | OutputKeyword
  | IntTypeKeyword | FloatTypeKeyword | StringTypeKeyword 
  | BoolTypeKeyword | UnitTypeKeyword | ListTypeKeyword 
  | ArrayTypeKeyword | VariantKeyword | TagKeyword
  (* 文言文关键字 *)
  | HaveKeyword | OneKeyword | NameKeyword | SetKeyword
  | AlsoKeyword | ThenGetKeyword | CallKeyword | ValueKeyword
  | AsForKeyword | NumberKeyword | WantExecuteKeyword
  | MustFirstGetKeyword | ForThisKeyword | TimesKeyword
  | EndCloudKeyword | IfWenyanKeyword | ThenWenyanKeyword
  | GreaterThanWenyan | LessThanWenyan
  (* 古雅体关键字 *)
  | AncientDefineKeyword | AncientEndKeyword | AncientAlgorithmKeyword
  | AncientCompleteKeyword | AncientObserveKeyword | AncientNatureKeyword
  | AncientThenKeyword | AncientOtherwiseKeyword | AncientAnswerKeyword
  | AncientCombineKeyword | AncientAsOneKeyword | AncientTakeKeyword
  | AncientReceiveKeyword | AncientParticleThe | AncientParticleFun
  | AncientCallItKeyword | AncientListStartKeyword | AncientListEndKeyword
  | AncientItsFirstKeyword | AncientItsSecondKeyword | AncientItsThirdKeyword
  | AncientEmptyKeyword | AncientHasHeadTailKeyword | AncientHeadNameKeyword
  | AncientTailNameKeyword | AncientThusAnswerKeyword | AncientAddToKeyword
  | AncientObserveEndKeyword | AncientBeginKeyword | AncientEndCompleteKeyword
  | AncientIsKeyword | AncientArrowKeyword | AncientWhenKeyword
  | AncientCommaKeyword | AfterThatKeyword | AncientRecordStartKeyword
  | AncientRecordEndKeyword | AncientRecordEmptyKeyword | AncientRecordUpdateKeyword
  | AncientRecordFinishKeyword
  (* 自然语言关键字 *)
  | DefineKeyword | AcceptKeyword | ReturnWhenKeyword | ElseReturnKeyword
  | MultiplyKeyword | DivideKeyword | AddToKeyword | SubtractKeyword
  | EqualToKeyword | LessThanEqualToKeyword | FirstElementKeyword
  | RemainingKeyword | EmptyKeyword | CharacterCountKeyword
  | OfParticle | MinusOneKeyword | PlusKeyword | WhereKeyword
  | SmallKeyword | ShouldGetKeyword