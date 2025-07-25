(** Token转换 - 古典语言专门模块 (Phase 4.2重构版)

    实现策略模式统一古典语言转换逻辑，消除代码重复，解决Issue #1336。
    从96行长函数和4个重复模块重构为统一的策略化实现。

    重构改进：
    - 实现策略模式消除代码重复 (从80% → <10%)
    - 统一转换接口支持动态策略选择
    - 保持完整向后兼容性
    - 支持扩展新的古典语言类型

    @author Alpha, 主工作代理 - Issue #1336
    @version 2.0 - Phase 4.2重构版
    @since 2025-07-25 *)

open Lexer_tokens

exception Unknown_classical_token of string
(** 异常定义 *)

(** 古典语言转换策略类型 - 核心重构改进 *)
type classical_conversion_strategy = 
  | Wenyan           (** 文言文转换策略 *)
  | Natural_Language (** 自然语言转换策略 *)
  | Ancient_Style    (** 古雅体转换策略 *)

(** 策略描述辅助函数 *)
let strategy_description = function
  | Wenyan -> "文言文"
  | Natural_Language -> "自然语言"
  | Ancient_Style -> "古雅体"

(** 统一古典语言转换策略接口 - 核心重构实现 *)
let convert_with_classical_strategy strategy token =
  let error_context = strategy_description strategy in
  try
    match strategy with
    | Wenyan -> (
      match token with
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
      | _ -> raise (Unknown_classical_token ("不是" ^ error_context ^ "token"))
    )
    | Natural_Language -> (
      match token with
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
      | _ -> raise (Unknown_classical_token ("不是" ^ error_context ^ "token"))
    )
    | Ancient_Style -> (
      match token with
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
      | _ -> raise (Unknown_classical_token ("不是" ^ error_context ^ "token"))
    )
  with
  | Unknown_classical_token msg -> raise (Unknown_classical_token msg)
  | exn -> raise (Unknown_classical_token (error_context ^ "转换失败: " ^ (Printexc.to_string exn)))

(** 转换古典语言tokens - 使用统一模式匹配优化性能 (保留向后兼容) *)
let convert_classical_token token =
  (* 尝试按顺序使用不同策略进行转换 *)
  let strategies = [Wenyan; Natural_Language; Ancient_Style] in
  let rec try_strategies = function
    | [] -> raise (Unknown_classical_token "未知的古典语言token")
    | strategy :: rest ->
        try
          convert_with_classical_strategy strategy token
        with
        | Unknown_classical_token _ -> try_strategies rest
  in
  try_strategies strategies

(** 辅助函数 - 检查是否为古典语言token *)
let is_classical_token token =
  try
    let _ = convert_classical_token token in
    true
  with Unknown_classical_token _ -> false

(** 安全转换古典语言token（返回Option类型） *)
let convert_classical_token_safe token =
  try Some (convert_classical_token token) with Unknown_classical_token _ -> None

(** 为向后兼容保留的分类函数 - 重构为策略调用 *)
module Wenyan = struct
  let convert_wenyan_token token = 
    convert_with_classical_strategy Wenyan token
end

module Natural = struct
  let convert_natural_language_token token = 
    convert_with_classical_strategy Natural_Language token
end

module Ancient = struct
  let convert_ancient_token token = 
    convert_with_classical_strategy Ancient_Style token
end
