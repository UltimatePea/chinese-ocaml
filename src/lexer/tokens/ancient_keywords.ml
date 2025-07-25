(** 骆言词法分析器 - 古雅体关键字 *)

type ancient_keyword =
  | AncientDefineKeyword
  | AncientEndKeyword
  | AncientAlgorithmKeyword
  | AncientCompleteKeyword
  | AncientObserveKeyword
  | AncientNatureKeyword
  | AncientIfKeyword
  | AncientThenKeyword
  | AncientOtherwiseKeyword
  | AncientAnswerKeyword
  | AncientRecursiveKeyword
  | AncientCombineKeyword
  | AncientAsOneKeyword
  | AncientTakeKeyword
  | AncientReceiveKeyword
  | AncientParticleOf
  | AncientParticleFun
  | AncientParticleThe
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
  | AncientRecordStartKeyword
  | AncientRecordEndKeyword
  | AncientRecordEmptyKeyword
  | AncientRecordUpdateKeyword
  | AncientRecordFinishKeyword
  | AncientIsKeyword
  | AncientArrowKeyword
  | AncientWhenKeyword
  | AncientCommaKeyword
  | AncientPeriodKeyword
  | AfterThatKeyword
[@@deriving show, eq]

let to_string = function
  | AncientDefineKeyword -> "夫...者"
  | AncientEndKeyword -> "也"
  | AncientAlgorithmKeyword -> "算法"
  | AncientCompleteKeyword -> "竟"
  | AncientObserveKeyword -> "观"
  | AncientNatureKeyword -> "性"
  | AncientIfKeyword -> "若"
  | AncientThenKeyword -> "则"
  | AncientOtherwiseKeyword -> "余者"
  | AncientAnswerKeyword -> "答"
  | AncientRecursiveKeyword -> "递归"
  | AncientCombineKeyword -> "合"
  | AncientAsOneKeyword -> "为一"
  | AncientTakeKeyword -> "取"
  | AncientReceiveKeyword -> "受"
  | AncientParticleOf -> "之"
  | AncientParticleFun -> "焉"
  | AncientParticleThe -> "其"
  | AncientCallItKeyword -> "名曰"
  | AncientListStartKeyword -> "列开始"
  | AncientListEndKeyword -> "列结束"
  | AncientItsFirstKeyword -> "其一"
  | AncientItsSecondKeyword -> "其二"
  | AncientItsThirdKeyword -> "其三"
  | AncientEmptyKeyword -> "空空如也"
  | AncientHasHeadTailKeyword -> "有首有尾"
  | AncientHeadNameKeyword -> "首名为"
  | AncientTailNameKeyword -> "尾名为"
  | AncientThusAnswerKeyword -> "则答"
  | AncientAddToKeyword -> "并加"
  | AncientObserveEndKeyword -> "观察毕"
  | AncientBeginKeyword -> "始"
  | AncientEndCompleteKeyword -> "毕"
  | AncientRecordStartKeyword -> "据开始"
  | AncientRecordEndKeyword -> "据结束"
  | AncientRecordEmptyKeyword -> "据空"
  | AncientRecordUpdateKeyword -> "据更新"
  | AncientRecordFinishKeyword -> "据毕"
  | AncientIsKeyword -> "乃"
  | AncientArrowKeyword -> "故"
  | AncientWhenKeyword -> "当"
  | AncientCommaKeyword -> "且"
  | AncientPeriodKeyword -> "也"
  | AfterThatKeyword -> "而后"

let from_string = function
  | "夫...者" -> Some AncientDefineKeyword
  | "也" -> Some AncientEndKeyword
  | "算法" -> Some AncientAlgorithmKeyword
  | "竟" -> Some AncientCompleteKeyword
  | "观" -> Some AncientObserveKeyword
  | "性" -> Some AncientNatureKeyword
  | "若" -> Some AncientIfKeyword
  | "则" -> Some AncientThenKeyword
  | "余者" -> Some AncientOtherwiseKeyword
  | "答" -> Some AncientAnswerKeyword
  | "递归" -> Some AncientRecursiveKeyword
  | "合" -> Some AncientCombineKeyword
  | "为一" -> Some AncientAsOneKeyword
  | "取" -> Some AncientTakeKeyword
  | "受" -> Some AncientReceiveKeyword
  | "之" -> Some AncientParticleOf
  | "焉" -> Some AncientParticleFun
  | "其" -> Some AncientParticleThe
  | "名曰" -> Some AncientCallItKeyword
  | "列开始" -> Some AncientListStartKeyword
  | "列结束" -> Some AncientListEndKeyword
  | "其一" -> Some AncientItsFirstKeyword
  | "其二" -> Some AncientItsSecondKeyword
  | "其三" -> Some AncientItsThirdKeyword
  | "空空如也" -> Some AncientEmptyKeyword
  | "有首有尾" -> Some AncientHasHeadTailKeyword
  | "首名为" -> Some AncientHeadNameKeyword
  | "尾名为" -> Some AncientTailNameKeyword
  | "则答" -> Some AncientThusAnswerKeyword
  | "并加" -> Some AncientAddToKeyword
  | "观察毕" -> Some AncientObserveEndKeyword
  | "始" -> Some AncientBeginKeyword
  | "毕" -> Some AncientEndCompleteKeyword
  | "据开始" -> Some AncientRecordStartKeyword
  | "据结束" -> Some AncientRecordEndKeyword
  | "据空" -> Some AncientRecordEmptyKeyword
  | "据更新" -> Some AncientRecordUpdateKeyword
  | "据毕" -> Some AncientRecordFinishKeyword
  | "乃" -> Some AncientIsKeyword
  | "故" -> Some AncientArrowKeyword
  | "当" -> Some AncientWhenKeyword
  | "且" -> Some AncientCommaKeyword
  | "而后" -> Some AfterThatKeyword
  | _ -> None

let is_definition = function AncientDefineKeyword | AncientCallItKeyword -> true | _ -> false

let is_control_flow = function
  | AncientIfKeyword | AncientThenKeyword | AncientOtherwiseKeyword | AncientWhenKeyword -> true
  | _ -> false

let is_particle = function
  | AncientParticleOf | AncientParticleFun | AncientParticleThe | AncientCommaKeyword
  | AncientPeriodKeyword ->
      true
  | _ -> false

let is_list_operation = function
  | AncientListStartKeyword | AncientListEndKeyword | AncientItsFirstKeyword
  | AncientItsSecondKeyword | AncientItsThirdKeyword | AncientEmptyKeyword
  | AncientHasHeadTailKeyword | AncientHeadNameKeyword | AncientTailNameKeyword
  | AncientAddToKeyword ->
      true
  | _ -> false
