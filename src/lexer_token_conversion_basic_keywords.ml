(** 基础关键字Token转换模块 - 重构版本以提升可维护性 *)

open Lexer_tokens

(** 转换控制流关键字 *)
let convert_control_flow_keywords = function
  | Token_mapping.Token_definitions_unified.LetKeyword -> LetKeyword
  | Token_mapping.Token_definitions_unified.RecKeyword -> RecKeyword
  | Token_mapping.Token_definitions_unified.InKeyword -> InKeyword
  | Token_mapping.Token_definitions_unified.FunKeyword -> FunKeyword
  | Token_mapping.Token_definitions_unified.IfKeyword -> IfKeyword
  | Token_mapping.Token_definitions_unified.ThenKeyword -> ThenKeyword
  | Token_mapping.Token_definitions_unified.ElseKeyword -> ElseKeyword
  | Token_mapping.Token_definitions_unified.MatchKeyword -> MatchKeyword
  | Token_mapping.Token_definitions_unified.WithKeyword -> WithKeyword
  | _ -> raise (Failure "Not a control flow keyword")

(** 转换逻辑运算关键字 *)
let convert_logical_keywords = function
  | Token_mapping.Token_definitions_unified.AndKeyword -> AndKeyword
  | Token_mapping.Token_definitions_unified.OrKeyword -> OrKeyword
  | Token_mapping.Token_definitions_unified.NotKeyword -> NotKeyword
  | Token_mapping.Token_definitions_unified.OtherKeyword -> OtherKeyword
  | Token_mapping.Token_definitions_unified.OfKeyword -> OfKeyword
  | _ -> raise (Failure "Not a logical keyword")

(** 转换语义关键字 *)
let convert_semantic_keywords = function
  | Token_mapping.Token_definitions_unified.AsKeyword -> AsKeyword
  | Token_mapping.Token_definitions_unified.CombineKeyword -> CombineKeyword
  | Token_mapping.Token_definitions_unified.WithOpKeyword -> WithOpKeyword
  | Token_mapping.Token_definitions_unified.WhenKeyword -> WhenKeyword
  | _ -> raise (Failure "Not a semantic keyword")

(** 转换错误恢复关键字 *)
let convert_error_handling_keywords = function
  | Token_mapping.Token_definitions_unified.WithDefaultKeyword -> WithDefaultKeyword
  | Token_mapping.Token_definitions_unified.ExceptionKeyword -> ExceptionKeyword
  | Token_mapping.Token_definitions_unified.RaiseKeyword -> RaiseKeyword
  | Token_mapping.Token_definitions_unified.TryKeyword -> TryKeyword
  | Token_mapping.Token_definitions_unified.CatchKeyword -> CatchKeyword
  | Token_mapping.Token_definitions_unified.FinallyKeyword -> FinallyKeyword
  | _ -> raise (Failure "Not an error handling keyword")

(** 转换模块系统关键字 *)
let convert_module_keywords = function
  | Token_mapping.Token_definitions_unified.ModuleKeyword -> ModuleKeyword
  | Token_mapping.Token_definitions_unified.ModuleTypeKeyword -> ModuleTypeKeyword
  | Token_mapping.Token_definitions_unified.RefKeyword -> RefKeyword
  | Token_mapping.Token_definitions_unified.IncludeKeyword -> IncludeKeyword
  | Token_mapping.Token_definitions_unified.FunctorKeyword -> FunctorKeyword
  | Token_mapping.Token_definitions_unified.SigKeyword -> SigKeyword
  | Token_mapping.Token_definitions_unified.EndKeyword -> EndKeyword
  | _ -> raise (Failure "Not a module keyword")

(** 转换宏和类型系统关键字 *)
let convert_macro_and_type_keywords = function
  | Token_mapping.Token_definitions_unified.MacroKeyword -> MacroKeyword
  | Token_mapping.Token_definitions_unified.ExpandKeyword -> ExpandKeyword
  | Token_mapping.Token_definitions_unified.TypeKeyword -> TypeKeyword
  | Token_mapping.Token_definitions_unified.PrivateKeyword -> PrivateKeyword
  | Token_mapping.Token_definitions_unified.ParamKeyword -> ParamKeyword
  | _ -> raise (Failure "Not a macro or type keyword")

(** 转换自然语言关键字 *)
let convert_natural_language_keywords = function
  | Token_mapping.Token_definitions_unified.DefineKeyword -> DefineKeyword
  | Token_mapping.Token_definitions_unified.AcceptKeyword -> AcceptKeyword
  | Token_mapping.Token_definitions_unified.ReturnWhenKeyword -> ReturnWhenKeyword
  | Token_mapping.Token_definitions_unified.ElseReturnKeyword -> ElseReturnKeyword
  | Token_mapping.Token_definitions_unified.MultiplyKeyword -> MultiplyKeyword
  | Token_mapping.Token_definitions_unified.DivideKeyword -> DivideKeyword
  | Token_mapping.Token_definitions_unified.AddToKeyword -> AddToKeyword
  | Token_mapping.Token_definitions_unified.SubtractKeyword -> SubtractKeyword
  | Token_mapping.Token_definitions_unified.EqualToKeyword -> EqualToKeyword
  | Token_mapping.Token_definitions_unified.LessThanEqualToKeyword -> LessThanEqualToKeyword
  | Token_mapping.Token_definitions_unified.FirstElementKeyword -> FirstElementKeyword
  | Token_mapping.Token_definitions_unified.RemainingKeyword -> RemainingKeyword
  | Token_mapping.Token_definitions_unified.EmptyKeyword -> EmptyKeyword
  | Token_mapping.Token_definitions_unified.CharacterCountKeyword -> CharacterCountKeyword
  | Token_mapping.Token_definitions_unified.OfParticle -> OfParticle
  | Token_mapping.Token_definitions_unified.MinusOneKeyword -> MinusOneKeyword
  | Token_mapping.Token_definitions_unified.PlusKeyword -> PlusKeyword
  | Token_mapping.Token_definitions_unified.WhereKeyword -> WhereKeyword
  | Token_mapping.Token_definitions_unified.SmallKeyword -> SmallKeyword
  | Token_mapping.Token_definitions_unified.ShouldGetKeyword -> ShouldGetKeyword
  | _ -> raise (Failure "Not a natural language keyword")

(** 转换文言文关键字 *)
let convert_wenyan_keywords = function
  | Token_mapping.Token_definitions_unified.HaveKeyword -> HaveKeyword
  | Token_mapping.Token_definitions_unified.OneKeyword -> OneKeyword
  | Token_mapping.Token_definitions_unified.NameKeyword -> NameKeyword
  | Token_mapping.Token_definitions_unified.SetKeyword -> SetKeyword
  | Token_mapping.Token_definitions_unified.AlsoKeyword -> AlsoKeyword
  | Token_mapping.Token_definitions_unified.ThenGetKeyword -> ThenGetKeyword
  | Token_mapping.Token_definitions_unified.CallKeyword -> CallKeyword
  | Token_mapping.Token_definitions_unified.ValueKeyword -> ValueKeyword
  | Token_mapping.Token_definitions_unified.AsForKeyword -> AsForKeyword
  | Token_mapping.Token_definitions_unified.NumberKeyword -> NumberKeyword
  | Token_mapping.Token_definitions_unified.WantExecuteKeyword -> WantExecuteKeyword
  | Token_mapping.Token_definitions_unified.MustFirstGetKeyword -> MustFirstGetKeyword
  | Token_mapping.Token_definitions_unified.ForThisKeyword -> ForThisKeyword
  | Token_mapping.Token_definitions_unified.TimesKeyword -> TimesKeyword
  | Token_mapping.Token_definitions_unified.EndCloudKeyword -> EndCloudKeyword
  | Token_mapping.Token_definitions_unified.IfWenyanKeyword -> IfWenyanKeyword
  | Token_mapping.Token_definitions_unified.ThenWenyanKeyword -> ThenWenyanKeyword
  | Token_mapping.Token_definitions_unified.GreaterThanWenyan -> GreaterThanWenyan
  | Token_mapping.Token_definitions_unified.LessThanWenyan -> LessThanWenyan
  | _ -> raise (Failure "Not a wenyan keyword")

(** 转换古雅体关键字 *)
let convert_ancient_keywords = function
  | Token_mapping.Token_definitions_unified.AncientDefineKeyword -> AncientDefineKeyword
  | Token_mapping.Token_definitions_unified.AncientEndKeyword -> AncientEndKeyword
  | Token_mapping.Token_definitions_unified.AncientAlgorithmKeyword -> AncientAlgorithmKeyword
  | Token_mapping.Token_definitions_unified.AncientCompleteKeyword -> AncientCompleteKeyword
  | Token_mapping.Token_definitions_unified.AncientObserveKeyword -> AncientObserveKeyword
  | Token_mapping.Token_definitions_unified.AncientNatureKeyword -> AncientNatureKeyword
  | Token_mapping.Token_definitions_unified.AncientThenKeyword -> AncientThenKeyword
  | Token_mapping.Token_definitions_unified.AncientOtherwiseKeyword -> AncientOtherwiseKeyword
  | Token_mapping.Token_definitions_unified.AncientAnswerKeyword -> AncientAnswerKeyword
  | Token_mapping.Token_definitions_unified.AncientCombineKeyword -> AncientCombineKeyword
  | Token_mapping.Token_definitions_unified.AncientAsOneKeyword -> AncientAsOneKeyword
  | Token_mapping.Token_definitions_unified.AncientTakeKeyword -> AncientTakeKeyword
  | Token_mapping.Token_definitions_unified.AncientReceiveKeyword -> AncientReceiveKeyword
  | Token_mapping.Token_definitions_unified.AncientParticleThe -> AncientParticleThe
  | Token_mapping.Token_definitions_unified.AncientParticleFun -> AncientParticleFun
  | Token_mapping.Token_definitions_unified.AncientCallItKeyword -> AncientCallItKeyword
  | Token_mapping.Token_definitions_unified.AncientListStartKeyword -> AncientListStartKeyword
  | Token_mapping.Token_definitions_unified.AncientListEndKeyword -> AncientListEndKeyword
  | Token_mapping.Token_definitions_unified.AncientItsFirstKeyword -> AncientItsFirstKeyword
  | Token_mapping.Token_definitions_unified.AncientItsSecondKeyword -> AncientItsSecondKeyword
  | Token_mapping.Token_definitions_unified.AncientItsThirdKeyword -> AncientItsThirdKeyword
  | Token_mapping.Token_definitions_unified.AncientEmptyKeyword -> AncientEmptyKeyword
  | Token_mapping.Token_definitions_unified.AncientHasHeadTailKeyword -> AncientHasHeadTailKeyword
  | Token_mapping.Token_definitions_unified.AncientHeadNameKeyword -> AncientHeadNameKeyword
  | Token_mapping.Token_definitions_unified.AncientTailNameKeyword -> AncientTailNameKeyword
  | Token_mapping.Token_definitions_unified.AncientThusAnswerKeyword -> AncientThusAnswerKeyword
  | Token_mapping.Token_definitions_unified.AncientAddToKeyword -> AncientAddToKeyword
  | Token_mapping.Token_definitions_unified.AncientObserveEndKeyword -> AncientObserveEndKeyword
  | Token_mapping.Token_definitions_unified.AncientBeginKeyword -> AncientBeginKeyword
  | Token_mapping.Token_definitions_unified.AncientEndCompleteKeyword -> AncientEndCompleteKeyword
  | Token_mapping.Token_definitions_unified.AncientIsKeyword -> AncientIsKeyword
  | Token_mapping.Token_definitions_unified.AncientArrowKeyword -> AncientArrowKeyword
  | Token_mapping.Token_definitions_unified.AncientWhenKeyword -> AncientWhenKeyword
  | Token_mapping.Token_definitions_unified.AncientCommaKeyword -> AncientCommaKeyword
  | Token_mapping.Token_definitions_unified.AfterThatKeyword -> AfterThatKeyword
  | Token_mapping.Token_definitions_unified.AncientRecordStartKeyword -> AncientRecordStartKeyword
  | Token_mapping.Token_definitions_unified.AncientRecordEndKeyword -> AncientRecordEndKeyword
  | Token_mapping.Token_definitions_unified.AncientRecordEmptyKeyword -> AncientRecordEmptyKeyword
  | Token_mapping.Token_definitions_unified.AncientRecordUpdateKeyword -> AncientRecordUpdateKeyword
  | Token_mapping.Token_definitions_unified.AncientRecordFinishKeyword -> AncientRecordFinishKeyword
  | _ -> raise (Failure "Not an ancient keyword")

(** 转换基础关键字tokens - 重构后的主函数，按功能分组处理 *)
let convert_basic_keyword_token token =
  try convert_control_flow_keywords token
  with Failure _ -> (
    try convert_logical_keywords token
    with Failure _ -> (
      try convert_semantic_keywords token
      with Failure _ -> (
        try convert_error_handling_keywords token
        with Failure _ -> (
          try convert_module_keywords token
          with Failure _ -> (
            try convert_macro_and_type_keywords token
            with Failure _ -> (
              try convert_natural_language_keywords token
              with Failure _ -> (
                try convert_wenyan_keywords token
                with Failure _ -> (
                  try convert_ancient_keywords token
                  with Failure _ -> raise (Failure "Not a basic keyword token")))))))))
