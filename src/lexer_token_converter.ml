(** 统一Token转换接口模块 - 进一步优化的模块化设计 *)

(** Token类型判断辅助函数 *)
module TokenClassifier = struct
  open Token_mapping.Token_definitions_unified

  let is_literal_token = function
    | IntToken _ | FloatToken _ | ChineseNumberToken _ | StringToken _ | BoolToken _ -> true
    | _ -> false

  let is_identifier_token = function
    | QuotedIdentifierToken _ | IdentifierTokenSpecial _ -> true
    | _ -> false

  let is_basic_keyword_token = function
    (* Basic programming keywords *)
    | LetKeyword | RecKeyword | InKeyword | FunKeyword | IfKeyword | ThenKeyword | ElseKeyword
    | MatchKeyword | WithKeyword | OtherKeyword | AndKeyword | OrKeyword | NotKeyword | OfKeyword
    | TypeKeyword | PrivateKeyword | ParamKeyword
    (* Semantic keywords *)
    | AsKeyword | CombineKeyword | WithOpKeyword | WhenKeyword | WithDefaultKeyword
    (* Error recovery keywords *)
    | ExceptionKeyword | RaiseKeyword | TryKeyword | CatchKeyword | FinallyKeyword
    (* Module keywords *)
    | ModuleKeyword | ModuleTypeKeyword | RefKeyword | IncludeKeyword | FunctorKeyword 
    | SigKeyword | EndKeyword
    (* Macro keywords *)
    | MacroKeyword | ExpandKeyword
    (* Natural language keywords *)
    | DefineKeyword | AcceptKeyword | ReturnWhenKeyword | ElseReturnKeyword
    | MultiplyKeyword | DivideKeyword | AddToKeyword | SubtractKeyword
    | EqualToKeyword | LessThanEqualToKeyword | FirstElementKeyword | RemainingKeyword
    | EmptyKeyword | CharacterCountKeyword | OfParticle | MinusOneKeyword | PlusKeyword
    | WhereKeyword | SmallKeyword | ShouldGetKeyword
    (* Wenyan keywords *)
    | HaveKeyword | OneKeyword | NameKeyword | SetKeyword | AlsoKeyword | ThenGetKeyword
    | CallKeyword | ValueKeyword | AsForKeyword | NumberKeyword | WantExecuteKeyword
    | MustFirstGetKeyword | ForThisKeyword | TimesKeyword | EndCloudKeyword
    | IfWenyanKeyword | ThenWenyanKeyword | GreaterThanWenyan | LessThanWenyan
    (* Ancient keywords *)
    | AncientDefineKeyword | AncientEndKeyword | AncientAlgorithmKeyword | AncientCompleteKeyword
    | AncientObserveKeyword | AncientNatureKeyword | AncientThenKeyword | AncientOtherwiseKeyword
    | AncientAnswerKeyword | AncientCombineKeyword | AncientAsOneKeyword | AncientTakeKeyword
    | AncientReceiveKeyword | AncientParticleThe | AncientParticleFun | AncientCallItKeyword
    | AncientListStartKeyword | AncientListEndKeyword | AncientItsFirstKeyword
    | AncientItsSecondKeyword | AncientItsThirdKeyword | AncientEmptyKeyword
    | AncientHasHeadTailKeyword | AncientHeadNameKeyword | AncientTailNameKeyword
    | AncientThusAnswerKeyword | AncientAddToKeyword | AncientObserveEndKeyword
    | AncientBeginKeyword | AncientEndCompleteKeyword | AncientIsKeyword | AncientArrowKeyword
    | AncientWhenKeyword | AncientCommaKeyword | AfterThatKeyword | AncientRecordStartKeyword
    | AncientRecordEndKeyword | AncientRecordEmptyKeyword | AncientRecordUpdateKeyword
    | AncientRecordFinishKeyword ->
        true
    | _ -> false

  let is_type_keyword_token = function
    | InputKeyword | OutputKeyword | IntTypeKeyword | FloatTypeKeyword | StringTypeKeyword 
    | BoolTypeKeyword | UnitTypeKeyword | ListTypeKeyword | ArrayTypeKeyword 
    | VariantKeyword | TagKeyword ->
        true
    | _ -> false
end

(** 主要的token转换函数 - 重构为简洁的模块化设计 *)
let convert_token token =
  if TokenClassifier.is_literal_token token then
    Lexer_token_conversion_literals.convert_literal_token token
  else if TokenClassifier.is_identifier_token token then
    Lexer_token_conversion_identifiers.convert_identifier_token token
  else if TokenClassifier.is_basic_keyword_token token then
    Lexer_token_conversion_basic_keywords.convert_basic_keyword_token token
  else if TokenClassifier.is_type_keyword_token token then
    Lexer_token_conversion_type_keywords.convert_type_keyword_token token
  else Lexer_token_conversion_classical.convert_classical_token token
