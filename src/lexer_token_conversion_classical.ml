(** 古典语言Token转换模块 - 包含文言文、古雅体和自然语言关键字 *)

open Lexer_tokens

(** 转换文言文关键字tokens *)
let convert_wenyan_token = function
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
  | _ -> failwith "Not a wenyan token"

(** 转换自然语言关键字tokens *)
let convert_natural_language_token = function
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
  | _ -> failwith "Not a natural language token"

(** 转换古雅体关键字tokens *)
let convert_ancient_token = function
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
  | _ -> failwith "Not an ancient token"

(** 转换古典语言tokens - 主入口函数 *)
let convert_classical_token token =
  try convert_wenyan_token token
  with Failure _ -> (
    try convert_natural_language_token token
    with Failure _ -> (
      try convert_ancient_token token with Failure _ -> failwith "Not a classical token"))
