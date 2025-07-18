(** 词法分析器关键字处理模块 *)

open Lexer_tokens

(** 将Token_mapping.Token_definitions.token转换为Lexer_tokens.token *)
let convert_token = function
  (* 字面量 *)
  | Token_mapping.Token_definitions.IntToken i -> IntToken i
  | Token_mapping.Token_definitions.FloatToken f -> FloatToken f
  | Token_mapping.Token_definitions.ChineseNumberToken s -> ChineseNumberToken s
  | Token_mapping.Token_definitions.StringToken s -> StringToken s
  | Token_mapping.Token_definitions.BoolToken b -> BoolToken b
  (* 标识符 *)
  | Token_mapping.Token_definitions.QuotedIdentifierToken s -> QuotedIdentifierToken s
  | Token_mapping.Token_definitions.IdentifierTokenSpecial s -> IdentifierTokenSpecial s
  (* 基础关键字 *)
  | Token_mapping.Token_definitions.LetKeyword -> LetKeyword
  | Token_mapping.Token_definitions.RecKeyword -> RecKeyword
  | Token_mapping.Token_definitions.InKeyword -> InKeyword
  | Token_mapping.Token_definitions.FunKeyword -> FunKeyword
  | Token_mapping.Token_definitions.IfKeyword -> IfKeyword
  | Token_mapping.Token_definitions.ThenKeyword -> ThenKeyword
  | Token_mapping.Token_definitions.ElseKeyword -> ElseKeyword
  | Token_mapping.Token_definitions.MatchKeyword -> MatchKeyword
  | Token_mapping.Token_definitions.WithKeyword -> WithKeyword
  | Token_mapping.Token_definitions.OtherKeyword -> OtherKeyword
  | Token_mapping.Token_definitions.AndKeyword -> AndKeyword
  | Token_mapping.Token_definitions.OrKeyword -> OrKeyword
  | Token_mapping.Token_definitions.NotKeyword -> NotKeyword
  | Token_mapping.Token_definitions.OfKeyword -> OfKeyword
  (* 类型关键字 *)
  | Token_mapping.Token_definitions.TypeKeyword -> TypeKeyword
  | Token_mapping.Token_definitions.PrivateKeyword -> PrivateKeyword
  | Token_mapping.Token_definitions.InputKeyword -> InputKeyword
  | Token_mapping.Token_definitions.OutputKeyword -> OutputKeyword
  | Token_mapping.Token_definitions.IntTypeKeyword -> IntTypeKeyword
  | Token_mapping.Token_definitions.FloatTypeKeyword -> FloatTypeKeyword
  | Token_mapping.Token_definitions.StringTypeKeyword -> StringTypeKeyword
  | Token_mapping.Token_definitions.BoolTypeKeyword -> BoolTypeKeyword
  | Token_mapping.Token_definitions.UnitTypeKeyword -> UnitTypeKeyword
  | Token_mapping.Token_definitions.ListTypeKeyword -> ListTypeKeyword
  | Token_mapping.Token_definitions.ArrayTypeKeyword -> ArrayTypeKeyword
  | Token_mapping.Token_definitions.VariantKeyword -> VariantKeyword
  | Token_mapping.Token_definitions.TagKeyword -> TagKeyword
  (* 语义关键字 *)
  | Token_mapping.Token_definitions.AsKeyword -> AsKeyword
  | Token_mapping.Token_definitions.CombineKeyword -> CombineKeyword
  | Token_mapping.Token_definitions.WithOpKeyword -> WithOpKeyword
  | Token_mapping.Token_definitions.WhenKeyword -> WhenKeyword
  (* 错误恢复关键字 *)
  | Token_mapping.Token_definitions.WithDefaultKeyword -> WithDefaultKeyword
  | Token_mapping.Token_definitions.ExceptionKeyword -> ExceptionKeyword
  | Token_mapping.Token_definitions.RaiseKeyword -> RaiseKeyword
  | Token_mapping.Token_definitions.TryKeyword -> TryKeyword
  | Token_mapping.Token_definitions.CatchKeyword -> CatchKeyword
  | Token_mapping.Token_definitions.FinallyKeyword -> FinallyKeyword
  (* 模块关键字 *)
  | Token_mapping.Token_definitions.ModuleKeyword -> ModuleKeyword
  | Token_mapping.Token_definitions.ModuleTypeKeyword -> ModuleTypeKeyword
  | Token_mapping.Token_definitions.RefKeyword -> RefKeyword
  | Token_mapping.Token_definitions.IncludeKeyword -> IncludeKeyword
  | Token_mapping.Token_definitions.FunctorKeyword -> FunctorKeyword
  | Token_mapping.Token_definitions.SigKeyword -> SigKeyword
  | Token_mapping.Token_definitions.EndKeyword -> EndKeyword
  (* 宏关键字 *)
  | Token_mapping.Token_definitions.MacroKeyword -> MacroKeyword
  | Token_mapping.Token_definitions.ExpandKeyword -> ExpandKeyword
  (* 文言文关键字 *)
  | Token_mapping.Token_definitions.HaveKeyword -> HaveKeyword
  | Token_mapping.Token_definitions.OneKeyword -> OneKeyword
  | Token_mapping.Token_definitions.NameKeyword -> NameKeyword
  | Token_mapping.Token_definitions.SetKeyword -> SetKeyword
  | Token_mapping.Token_definitions.AlsoKeyword -> AlsoKeyword
  | Token_mapping.Token_definitions.ThenGetKeyword -> ThenGetKeyword
  | Token_mapping.Token_definitions.CallKeyword -> CallKeyword
  | Token_mapping.Token_definitions.ValueKeyword -> ValueKeyword
  | Token_mapping.Token_definitions.AsForKeyword -> AsForKeyword
  | Token_mapping.Token_definitions.NumberKeyword -> NumberKeyword
  | Token_mapping.Token_definitions.WantExecuteKeyword -> WantExecuteKeyword
  | Token_mapping.Token_definitions.MustFirstGetKeyword -> MustFirstGetKeyword
  | Token_mapping.Token_definitions.ForThisKeyword -> ForThisKeyword
  | Token_mapping.Token_definitions.TimesKeyword -> TimesKeyword
  | Token_mapping.Token_definitions.EndCloudKeyword -> EndCloudKeyword
  | Token_mapping.Token_definitions.IfWenyanKeyword -> IfWenyanKeyword
  | Token_mapping.Token_definitions.ThenWenyanKeyword -> ThenWenyanKeyword
  | Token_mapping.Token_definitions.GreaterThanWenyan -> GreaterThanWenyan
  | Token_mapping.Token_definitions.LessThanWenyan -> LessThanWenyan
  (* 自然语言关键字 *)
  | Token_mapping.Token_definitions.DefineKeyword -> DefineKeyword
  | Token_mapping.Token_definitions.AcceptKeyword -> AcceptKeyword
  | Token_mapping.Token_definitions.ReturnWhenKeyword -> ReturnWhenKeyword
  | Token_mapping.Token_definitions.ElseReturnKeyword -> ElseReturnKeyword
  | Token_mapping.Token_definitions.MultiplyKeyword -> MultiplyKeyword
  | Token_mapping.Token_definitions.DivideKeyword -> DivideKeyword
  | Token_mapping.Token_definitions.AddToKeyword -> AddToKeyword
  | Token_mapping.Token_definitions.SubtractKeyword -> SubtractKeyword
  | Token_mapping.Token_definitions.EqualToKeyword -> EqualToKeyword
  | Token_mapping.Token_definitions.LessThanEqualToKeyword -> LessThanEqualToKeyword
  | Token_mapping.Token_definitions.FirstElementKeyword -> FirstElementKeyword
  | Token_mapping.Token_definitions.RemainingKeyword -> RemainingKeyword
  | Token_mapping.Token_definitions.EmptyKeyword -> EmptyKeyword
  | Token_mapping.Token_definitions.CharacterCountKeyword -> CharacterCountKeyword
  | Token_mapping.Token_definitions.OfParticle -> OfParticle
  | Token_mapping.Token_definitions.MinusOneKeyword -> MinusOneKeyword
  | Token_mapping.Token_definitions.PlusKeyword -> PlusKeyword
  | Token_mapping.Token_definitions.WhereKeyword -> WhereKeyword
  | Token_mapping.Token_definitions.SmallKeyword -> SmallKeyword
  | Token_mapping.Token_definitions.ShouldGetKeyword -> ShouldGetKeyword
  (* 古雅体关键字 *)
  | Token_mapping.Token_definitions.AncientDefineKeyword -> AncientDefineKeyword
  | Token_mapping.Token_definitions.AncientEndKeyword -> AncientEndKeyword
  | Token_mapping.Token_definitions.AncientAlgorithmKeyword -> AncientAlgorithmKeyword
  | Token_mapping.Token_definitions.AncientCompleteKeyword -> AncientCompleteKeyword
  | Token_mapping.Token_definitions.AncientObserveKeyword -> AncientObserveKeyword
  | Token_mapping.Token_definitions.AncientNatureKeyword -> AncientNatureKeyword
  | Token_mapping.Token_definitions.AncientThenKeyword -> AncientThenKeyword
  | Token_mapping.Token_definitions.AncientOtherwiseKeyword -> AncientOtherwiseKeyword
  | Token_mapping.Token_definitions.AncientAnswerKeyword -> AncientAnswerKeyword
  | Token_mapping.Token_definitions.AncientCombineKeyword -> AncientCombineKeyword
  | Token_mapping.Token_definitions.AncientAsOneKeyword -> AncientAsOneKeyword
  | Token_mapping.Token_definitions.AncientTakeKeyword -> AncientTakeKeyword
  | Token_mapping.Token_definitions.AncientReceiveKeyword -> AncientReceiveKeyword
  | Token_mapping.Token_definitions.AncientParticleThe -> AncientParticleThe
  | Token_mapping.Token_definitions.AncientParticleFun -> AncientParticleFun
  | Token_mapping.Token_definitions.AncientCallItKeyword -> AncientCallItKeyword
  | Token_mapping.Token_definitions.AncientListStartKeyword -> AncientListStartKeyword
  | Token_mapping.Token_definitions.AncientListEndKeyword -> AncientListEndKeyword
  | Token_mapping.Token_definitions.AncientItsFirstKeyword -> AncientItsFirstKeyword
  | Token_mapping.Token_definitions.AncientItsSecondKeyword -> AncientItsSecondKeyword
  | Token_mapping.Token_definitions.AncientItsThirdKeyword -> AncientItsThirdKeyword
  | Token_mapping.Token_definitions.AncientEmptyKeyword -> AncientEmptyKeyword
  | Token_mapping.Token_definitions.AncientHasHeadTailKeyword -> AncientHasHeadTailKeyword
  | Token_mapping.Token_definitions.AncientHeadNameKeyword -> AncientHeadNameKeyword
  | Token_mapping.Token_definitions.AncientTailNameKeyword -> AncientTailNameKeyword
  | Token_mapping.Token_definitions.AncientThusAnswerKeyword -> AncientThusAnswerKeyword
  | Token_mapping.Token_definitions.AncientAddToKeyword -> AncientAddToKeyword
  | Token_mapping.Token_definitions.AncientObserveEndKeyword -> AncientObserveEndKeyword
  | Token_mapping.Token_definitions.AncientBeginKeyword -> AncientBeginKeyword
  | Token_mapping.Token_definitions.AncientEndCompleteKeyword -> AncientEndCompleteKeyword
  | Token_mapping.Token_definitions.AncientIsKeyword -> AncientIsKeyword
  | Token_mapping.Token_definitions.AncientArrowKeyword -> AncientArrowKeyword
  | Token_mapping.Token_definitions.AncientWhenKeyword -> AncientWhenKeyword
  | Token_mapping.Token_definitions.AncientCommaKeyword -> AncientCommaKeyword
  | Token_mapping.Token_definitions.AfterThatKeyword -> AfterThatKeyword
  | Token_mapping.Token_definitions.AncientRecordStartKeyword -> AncientRecordStartKeyword
  | Token_mapping.Token_definitions.AncientRecordEndKeyword -> AncientRecordEndKeyword
  | Token_mapping.Token_definitions.AncientRecordEmptyKeyword -> AncientRecordEmptyKeyword
  | Token_mapping.Token_definitions.AncientRecordUpdateKeyword -> AncientRecordUpdateKeyword
  | Token_mapping.Token_definitions.AncientRecordFinishKeyword -> AncientRecordFinishKeyword

(** 将关键字变体转换为对应的token *)
let variant_to_token variant =
  try
    (* 尝试基础关键字映射 *)
    Token_mapping.Basic_token_mapping.map_basic_variant variant |> convert_token
  with
  | Failure _ ->
    try
      (* 尝试类型关键字映射 *)
      Token_mapping.Type_token_mapping.map_type_variant variant |> convert_token
    with
    | Failure _ ->
      try
        (* 尝试文言文关键字映射 *)
        Token_mapping.Classical_token_mapping.map_wenyan_variant variant |> convert_token
      with
      | Failure _ ->
        try
          (* 尝试古雅体关键字映射 *)
          Token_mapping.Classical_token_mapping.map_ancient_variant variant |> convert_token
        with
        | Failure _ ->
          try
            (* 尝试自然语言关键字映射 *)
            Token_mapping.Classical_token_mapping.map_natural_language_variant variant |> convert_token
          with
          | Failure _ ->
            try
              (* 尝试特殊关键字映射 *)
              Token_mapping.Special_token_mapping.map_special_variant variant |> convert_token
            with
            | Failure _ -> failwith ("Unknown keyword variant: " ^ (Obj.repr variant |> Obj.tag |> string_of_int))

(** 查找关键字 *)
let find_keyword str =
  match Keyword_tables.Keywords.find_keyword str with
  | Some variant -> Some (variant_to_token variant)
  | None -> None