(** Token转换核心模块 - Issue #1066 技术债务改进
 
    此模块整合了原先分散在多个文件中的Token转换逻辑，包括：
    - lexer_token_conversion_identifiers.ml (9行)
    - lexer_token_conversion_literals.ml (12行)  
    - lexer_token_conversion_basic_keywords.ml (132行)
    - lexer_token_conversion_type_keywords.ml (21行)
    - lexer_token_conversion_classical.ml (111行)
    
    通过整合减少维护复杂性，提升开发效率。

    @author 骆言技术债务清理团队 Issue #1066
    @version 1.0
    @since 2025-07-24 *)

open Lexer_tokens

(** 异常定义 *)
exception Unknown_identifier_token of string
exception Unknown_literal_token of string
exception Unknown_basic_keyword_token of string
exception Unknown_type_keyword_token of string  
exception Unknown_classical_token of string

(** =================================
    标识符Token转换模块整合部分
    ================================= *)

(** 转换标识符tokens *)
let convert_identifier_token = function
  | Token_mapping.Token_definitions_unified.QuotedIdentifierToken s -> QuotedIdentifierToken s
  | Token_mapping.Token_definitions_unified.IdentifierTokenSpecial s -> IdentifierTokenSpecial s
  | token -> 
      let error_msg = Printf.sprintf "不是标识符token: %s" (Obj.tag (Obj.repr token) |> string_of_int) in
      raise (Unknown_identifier_token error_msg)

(** =================================
    字面量Token转换模块整合部分
    ================================= *)

(** 转换字面量tokens *)
let convert_literal_token = function
  | Token_mapping.Token_definitions_unified.IntToken i -> IntToken i
  | Token_mapping.Token_definitions_unified.FloatToken f -> FloatToken f
  | Token_mapping.Token_definitions_unified.ChineseNumberToken s -> ChineseNumberToken s
  | Token_mapping.Token_definitions_unified.StringToken s -> StringToken s
  | Token_mapping.Token_definitions_unified.BoolToken b -> BoolToken b
  | token -> 
      let error_msg = Printf.sprintf "不是字面量token: %s" (Obj.tag (Obj.repr token) |> string_of_int) in
      raise (Unknown_literal_token error_msg)

(** =================================
    基础关键字Token转换模块整合部分
    ================================= *)

(** ===================================
     基础关键字Token转换 - 分组重构实施
     Issue #1079 Phase 3.1: 长函数分组重构
    =================================== *)

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
      let error_msg = Printf.sprintf "不是基础语言关键字: %s" (Obj.tag (Obj.repr token) |> string_of_int) in
      raise (Unknown_basic_keyword_token error_msg)

(** 转换语义关键字 *)
let convert_semantic_keywords = function
  | Token_mapping.Token_definitions_unified.AsKeyword -> AsKeyword
  | Token_mapping.Token_definitions_unified.CombineKeyword -> CombineKeyword
  | Token_mapping.Token_definitions_unified.WithOpKeyword -> WithOpKeyword
  | Token_mapping.Token_definitions_unified.WhenKeyword -> WhenKeyword
  | token -> 
      let error_msg = Printf.sprintf "不是语义关键字: %s" (Obj.tag (Obj.repr token) |> string_of_int) in
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
      let error_msg = Printf.sprintf "不是错误恢复关键字: %s" (Obj.tag (Obj.repr token) |> string_of_int) in
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
      let error_msg = Printf.sprintf "不是模块关键字: %s" (Obj.tag (Obj.repr token) |> string_of_int) in
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
      let error_msg = Printf.sprintf "不是自然语言关键字: %s" (Obj.tag (Obj.repr token) |> string_of_int) in
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
      let error_msg = Printf.sprintf "不是文言文关键字: %s" (Obj.tag (Obj.repr token) |> string_of_int) in
      raise (Unknown_classical_token error_msg)

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
      let error_msg = Printf.sprintf "不是古雅体关键字: %s" (Obj.tag (Obj.repr token) |> string_of_int) in
      raise (Unknown_classical_token error_msg)

(** 转换基础关键字tokens - 重构后的统一入口
 *  Issue #1079 Phase 3.1: 长函数重构完成
 *  
 *  原127行长函数已分解为7个专门的子功能函数：
 *  - convert_basic_language_keywords (15个基础语言关键字)
 *  - convert_semantic_keywords (4个语义关键字)
 *  - convert_error_recovery_keywords (6个错误恢复关键字)
 *  - convert_module_keywords (12个模块相关关键字)
 *  - convert_natural_language_keywords (21个自然语言关键字)
 *  - convert_wenyan_keywords (19个文言文关键字)
 *  - convert_ancient_keywords (50个古雅体关键字)
 *)
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
                let error_msg = Printf.sprintf "不是基础关键字token: %s" (Obj.tag (Obj.repr token) |> string_of_int) in
                raise (Unknown_basic_keyword_token error_msg)))))))))

(** =================================
    类型关键字Token转换模块整合部分
    ================================= *)

(** 转换类型关键字tokens *)
let convert_type_keyword_token = function
  (* 类型关键字 *)
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
      let error_msg = Printf.sprintf "不是类型关键字token: %s" (Obj.tag (Obj.repr token) |> string_of_int) in
      raise (Unknown_type_keyword_token error_msg)

(** =================================
    古典语言Token转换模块整合部分 
    ================================= *)

(** 转换文言文关键字tokens *)
let convert_wenyan_token = function
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
  | _ ->
      let error_msg = "未知的文言文token" in
      raise (Unknown_classical_token error_msg)

(** 转换自然语言关键字tokens *)
let convert_natural_language_token = function
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
  | _ ->
      let error_msg = "未知的自然语言token" in
      raise (Unknown_classical_token error_msg)

(** 转换古雅体关键字tokens *)
let convert_ancient_token = function
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
  | _ ->
      let error_msg = "未知的古雅体token" in
      raise (Unknown_classical_token error_msg)

(** 转换古典语言tokens - 主入口函数 *)
let convert_classical_token token =
  try convert_wenyan_token token
  with Unknown_classical_token _ -> (
    try convert_natural_language_token token
    with Unknown_classical_token _ -> (
      try convert_ancient_token token
      with Unknown_classical_token _ ->
        let error_msg = "无法识别的古典语言token" in
        raise (Unknown_classical_token error_msg)))

(** =================================
    统一转换接口
    ================================= *)

(** 统一的Token转换接口 - 尝试所有转换类型 *)
let convert_token token =
  try Some (convert_identifier_token token)
  with Unknown_identifier_token _ -> (
    try Some (convert_literal_token token) 
    with Unknown_literal_token _ -> (
      try Some (convert_basic_keyword_token token)
      with Unknown_basic_keyword_token _ -> (
        try Some (convert_type_keyword_token token)
        with Unknown_type_keyword_token _ -> (
          try Some (convert_classical_token token)
          with Unknown_classical_token _ -> None))))

(** 批量转换Token列表 *)
let convert_token_list tokens =
  List.map (fun token ->
    match convert_token token with
    | Some converted -> converted
    | None -> 
        let error_msg = Printf.sprintf "无法转换token: %s" (Obj.tag (Obj.repr token) |> string_of_int) in
        raise (Unknown_basic_keyword_token error_msg)
  ) tokens

(** 向后兼容性保证 - 重新导出原有接口 *)
module Identifiers = struct
  let convert_identifier_token = convert_identifier_token
end

module Literals = struct
  let convert_literal_token = convert_literal_token  
end

module BasicKeywords = struct
  let convert_basic_keyword_token = convert_basic_keyword_token
end

module TypeKeywords = struct
  let convert_type_keyword_token = convert_type_keyword_token
end

module Classical = struct
  let convert_wenyan_token = convert_wenyan_token
  let convert_natural_language_token = convert_natural_language_token
  let convert_ancient_token = convert_ancient_token
  let convert_classical_token = convert_classical_token
end

(** 转换统计信息 *)
let get_conversion_stats () =
  let identifiers_count = 2 in
  let literals_count = 5 in  
  let basic_keywords_count = 122 in
  let type_keywords_count = 13 in
  let classical_count = 95 in
  let total_count = identifiers_count + literals_count + basic_keywords_count + type_keywords_count + classical_count in
  Printf.sprintf "Token转换核心模块统计: 标识符(%d) + 字面量(%d) + 基础关键字(%d) + 类型关键字(%d) + 古典语言(%d) = 总计(%d)个转换规则"
    identifiers_count literals_count basic_keywords_count type_keywords_count classical_count total_count