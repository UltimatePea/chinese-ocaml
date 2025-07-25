(** Token转换 - 古典语言专门模块
    
    从token_conversion_core.ml中提取的古典语言（文言文、自然语言、古雅体）转换逻辑，
    使用统一的模式匹配优化性能。
    
    @author 骆言技术债务清理团队 Issue #1256
    @version 1.0
    @since 2025-07-25 *)

open Lexer_tokens

(** 异常定义 *)
exception Unknown_classical_token of string

(** 转换古典语言tokens - 使用统一模式匹配优化性能 *)
let convert_classical_token = function
  (* 文言文关键字 *)
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

  (* 自然语言关键字 *)
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

  (* 古雅体关键字 *)
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

  | _token -> 
      raise (Unknown_classical_token "未知的古典语言token")

(** 检查是否为古典语言token *)
let is_classical_token token =
  try 
    let _ = convert_classical_token token in 
    true
  with Unknown_classical_token _ -> false

(** 安全转换古典语言token（返回Option类型） *)
let convert_classical_token_safe token =
  try Some (convert_classical_token token)
  with Unknown_classical_token _ -> None

(** 为向后兼容保留的分类函数 *)
module Wenyan = struct
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
    | _ -> raise (Unknown_classical_token "不是文言文token")
end

module Natural = struct
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
    | _ -> raise (Unknown_classical_token "不是自然语言token")
end

module Ancient = struct
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
    | _ -> raise (Unknown_classical_token "不是古雅体token")
end