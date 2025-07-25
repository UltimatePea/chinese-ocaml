(** 关键字Token转换模块
 *
 *  从token_conversion_core.ml重构而来，专门处理基础关键字和类型关键字的Token转换
 *  
 *  @author 骆言技术债务清理团队 Issue #1276
 *  @version 2.0
 *  @since 2025-07-25 *)

open Lexer_tokens

(** 异常定义 *)
exception Unknown_basic_keyword_token of string
exception Unknown_type_keyword_token of string

(** 支持的基础关键字转换规则数量 *)
let get_basic_keyword_rule_count () = 
  let basic_language = 14 in (* convert_basic_language_keywords *)
  let semantic = 4 in (* convert_semantic_keywords *)
  let error_recovery = 6 in (* convert_error_recovery_keywords *)
  let module_keywords = 12 in (* convert_module_keywords *)
  let natural_language = 20 in (* convert_natural_language_keywords *)
  let wenyan = 18 in (* convert_wenyan_keywords *)
  let ancient = 52 in (* convert_ancient_keywords *)
  basic_language + semantic + error_recovery + module_keywords + natural_language + wenyan + ancient

(** 支持的类型关键字转换规则数量 *)
let get_type_keyword_rule_count () = 13

(** 转换基础语言关键字 *)
let convert_basic_language_keywords = function
  | Token_mapping.Token_definitions_unified.LetKeyword -> LetKeyword
  | Token_mapping.Token_definitions_unified.RecKeyword -> RecKeyword
  | Token_mapping.Token_definitions_unified.InKeyword -> InKeyword
  | Token_mapping.Token_definitions_unified.FunKeyword -> FunKeyword
  | Token_mapping.Token_definitions_unified.IfKeyword -> IfKeyword
  | Token_mapping.Token_definitions_unified.ThenKeyword -> ThenKeyword
  | Token_mapping.Token_definitions_unified.ElseKeyword -> ElseKeyword
  | Token_mapping.Token_definitions_unified.MatchKeyword -> MatchKeyword
  | Token_mapping.Token_definitions_unified.WithKeyword -> WithKeyword
  | Token_mapping.Token_definitions_unified.OtherKeyword -> OtherKeyword
  | Token_mapping.Token_definitions_unified.AndKeyword -> AndKeyword
  | Token_mapping.Token_definitions_unified.OrKeyword -> OrKeyword
  | Token_mapping.Token_definitions_unified.NotKeyword -> NotKeyword
  | Token_mapping.Token_definitions_unified.OfKeyword -> OfKeyword
  | token -> 
      let error_msg = "不是基础语言关键字: " ^ (Obj.tag (Obj.repr token) |> string_of_int) in
      raise (Unknown_basic_keyword_token error_msg)

(** 转换语义关键字 *)
let convert_semantic_keywords = function
  | Token_mapping.Token_definitions_unified.AsKeyword -> AsKeyword
  | Token_mapping.Token_definitions_unified.CombineKeyword -> CombineKeyword
  | Token_mapping.Token_definitions_unified.WithOpKeyword -> WithOpKeyword
  | Token_mapping.Token_definitions_unified.WhenKeyword -> WhenKeyword
  | token -> 
      let error_msg = "不是语义关键字: " ^ (Obj.tag (Obj.repr token) |> string_of_int) in
      raise (Unknown_basic_keyword_token error_msg)

(** 转换错误恢复关键字 *)
let convert_error_recovery_keywords = function
  | Token_mapping.Token_definitions_unified.WithDefaultKeyword -> WithDefaultKeyword
  | Token_mapping.Token_definitions_unified.ExceptionKeyword -> ExceptionKeyword
  | Token_mapping.Token_definitions_unified.RaiseKeyword -> RaiseKeyword
  | Token_mapping.Token_definitions_unified.TryKeyword -> TryKeyword
  | Token_mapping.Token_definitions_unified.CatchKeyword -> CatchKeyword
  | Token_mapping.Token_definitions_unified.FinallyKeyword -> FinallyKeyword
  | token -> 
      let error_msg = "不是错误恢复关键字: " ^ (Obj.tag (Obj.repr token) |> string_of_int) in
      raise (Unknown_basic_keyword_token error_msg)

(** 转换模块关键字 *)
let convert_module_keywords = function
  | Token_mapping.Token_definitions_unified.ModuleKeyword -> ModuleKeyword
  | Token_mapping.Token_definitions_unified.ModuleTypeKeyword -> ModuleTypeKeyword
  | Token_mapping.Token_definitions_unified.RefKeyword -> RefKeyword
  | Token_mapping.Token_definitions_unified.IncludeKeyword -> IncludeKeyword
  | Token_mapping.Token_definitions_unified.FunctorKeyword -> FunctorKeyword
  | Token_mapping.Token_definitions_unified.SigKeyword -> SigKeyword
  | Token_mapping.Token_definitions_unified.EndKeyword -> EndKeyword
  | Token_mapping.Token_definitions_unified.MacroKeyword -> MacroKeyword
  | Token_mapping.Token_definitions_unified.ExpandKeyword -> ExpandKeyword
  | Token_mapping.Token_definitions_unified.TypeKeyword -> TypeKeyword
  | Token_mapping.Token_definitions_unified.PrivateKeyword -> PrivateKeyword
  | Token_mapping.Token_definitions_unified.ParamKeyword -> ParamKeyword
  | token -> 
      let error_msg = "不是模块关键字: " ^ (Obj.tag (Obj.repr token) |> string_of_int) in
      raise (Unknown_basic_keyword_token error_msg)

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
  | token -> 
      let error_msg = "不是自然语言关键字: " ^ (Obj.tag (Obj.repr token) |> string_of_int) in
      raise (Unknown_basic_keyword_token error_msg)

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
  | token -> 
      let error_msg = "不是文言文关键字: " ^ (Obj.tag (Obj.repr token) |> string_of_int) in
      raise (Unknown_basic_keyword_token error_msg)

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
  | token -> 
      let error_msg = "不是古雅体关键字: " ^ (Obj.tag (Obj.repr token) |> string_of_int) in
      raise (Unknown_basic_keyword_token error_msg)

(** 转换基础关键字tokens - 重构后的统一入口 *)
let convert_basic_keyword_token token =
  try convert_basic_language_keywords token with
  | Failure _ -> (
    try convert_semantic_keywords token with
    | Failure _ -> (
      try convert_error_recovery_keywords token with
      | Failure _ -> (
        try convert_module_keywords token with
        | Failure _ -> (
          try convert_natural_language_keywords token with
          | Failure _ -> (
            try convert_wenyan_keywords token with
            | Failure _ -> (
              try convert_ancient_keywords token with
              | Failure _ -> (
                let error_msg = "不是基础关键字token: " ^ (Obj.tag (Obj.repr token) |> string_of_int) in
                raise (Unknown_basic_keyword_token error_msg))))))))

(** 转换类型关键字tokens *)
let convert_type_keyword_token = function
  | Token_mapping.Token_definitions_unified.TypeKeyword -> TypeKeyword
  | Token_mapping.Token_definitions_unified.PrivateKeyword -> PrivateKeyword
  | Token_mapping.Token_definitions_unified.InputKeyword -> InputKeyword
  | Token_mapping.Token_definitions_unified.OutputKeyword -> OutputKeyword
  | Token_mapping.Token_definitions_unified.IntTypeKeyword -> IntTypeKeyword  
  | Token_mapping.Token_definitions_unified.FloatTypeKeyword -> FloatTypeKeyword
  | Token_mapping.Token_definitions_unified.StringTypeKeyword -> StringTypeKeyword
  | Token_mapping.Token_definitions_unified.BoolTypeKeyword -> BoolTypeKeyword
  | Token_mapping.Token_definitions_unified.UnitTypeKeyword -> UnitTypeKeyword
  | Token_mapping.Token_definitions_unified.ListTypeKeyword -> ListTypeKeyword
  | Token_mapping.Token_definitions_unified.ArrayTypeKeyword -> ArrayTypeKeyword
  | Token_mapping.Token_definitions_unified.VariantKeyword -> VariantKeyword
  | Token_mapping.Token_definitions_unified.TagKeyword -> TagKeyword
  | token -> 
      let error_msg = "不是类型关键字token: " ^ (Obj.tag (Obj.repr token) |> string_of_int) in
      raise (Unknown_type_keyword_token error_msg)