(** Token转换 - 古典语言专门模块 (Phase 4.2重构版)

    实现策略模式统一古典语言转换逻辑，消除代码重复，解决Issue #1336。 从96行长函数和4个重复模块重构为统一的策略化实现。

    重构改进：
    - 实现策略模式消除代码重复 (从80% → <10%)
    - 统一转换接口支持动态策略选择
    - 保持完整向后兼容性
    - 支持扩展新的古典语言类型

    @author Alpha, 主工作代理 - Issue #1336
    @version 2.0 - Phase 4.2重构版
    @since 2025-07-25 *)

open Yyocamlc_lib.Lexer_tokens

exception Unknown_classical_token of string
(** 异常定义 *)

(** 古典语言转换策略类型 - 核心重构改进 *)
type classical_conversion_strategy =
  | Wenyan  (** 文言文转换策略 *)
  | Natural_Language  (** 自然语言转换策略 *)
  | Ancient_Style  (** 古雅体转换策略 *)

(** 策略描述辅助函数 *)
let strategy_description = function
  | Wenyan -> "文言文"
  | Natural_Language -> "自然语言"
  | Ancient_Style -> "古雅体"

(** 文言文关键字转换模块 - 分解的小函数 *)
let convert_wenyan_core_tokens = function
  | Token_mapping.Token_definitions_unified.HaveKeyword -> Some HaveKeyword
  | Token_mapping.Token_definitions_unified.OneKeyword -> Some OneKeyword
  | Token_mapping.Token_definitions_unified.NameKeyword -> Some NameKeyword
  | Token_mapping.Token_definitions_unified.SetKeyword -> Some SetKeyword
  | Token_mapping.Token_definitions_unified.AlsoKeyword -> Some AlsoKeyword
  | Token_mapping.Token_definitions_unified.ThenGetKeyword -> Some ThenGetKeyword
  | Token_mapping.Token_definitions_unified.CallKeyword -> Some CallKeyword
  | Token_mapping.Token_definitions_unified.ValueKeyword -> Some ValueKeyword
  | Token_mapping.Token_definitions_unified.AsForKeyword -> Some AsForKeyword
  | Token_mapping.Token_definitions_unified.NumberKeyword -> Some NumberKeyword
  | _ -> None

let convert_wenyan_execution_tokens = function
  | Token_mapping.Token_definitions_unified.WantExecuteKeyword -> Some WantExecuteKeyword
  | Token_mapping.Token_definitions_unified.MustFirstGetKeyword -> Some MustFirstGetKeyword
  | Token_mapping.Token_definitions_unified.ForThisKeyword -> Some ForThisKeyword
  | Token_mapping.Token_definitions_unified.TimesKeyword -> Some TimesKeyword
  | Token_mapping.Token_definitions_unified.EndCloudKeyword -> Some EndCloudKeyword
  | _ -> None

let convert_wenyan_control_tokens = function
  | Token_mapping.Token_definitions_unified.IfWenyanKeyword -> Some IfWenyanKeyword
  | Token_mapping.Token_definitions_unified.ThenWenyanKeyword -> Some ThenWenyanKeyword
  | Token_mapping.Token_definitions_unified.GreaterThanWenyan -> Some GreaterThanWenyan
  | Token_mapping.Token_definitions_unified.LessThanWenyan -> Some LessThanWenyan
  | _ -> None

(** 自然语言关键字转换模块 - 分解的小函数 *)
let convert_natural_basic_tokens = function
  | Token_mapping.Token_definitions_unified.DefineKeyword -> Some DefineKeyword
  | Token_mapping.Token_definitions_unified.AcceptKeyword -> Some AcceptKeyword
  | Token_mapping.Token_definitions_unified.ReturnWhenKeyword -> Some ReturnWhenKeyword
  | Token_mapping.Token_definitions_unified.ElseReturnKeyword -> Some ElseReturnKeyword
  | _ -> None

let convert_natural_arithmetic_tokens = function
  | Token_mapping.Token_definitions_unified.MultiplyKeyword -> Some MultiplyKeyword
  | Token_mapping.Token_definitions_unified.DivideKeyword -> Some DivideKeyword
  | Token_mapping.Token_definitions_unified.AddToKeyword -> Some AddToKeyword
  | Token_mapping.Token_definitions_unified.SubtractKeyword -> Some SubtractKeyword
  | Token_mapping.Token_definitions_unified.EqualToKeyword -> Some EqualToKeyword
  | Token_mapping.Token_definitions_unified.LessThanEqualToKeyword -> Some LessThanEqualToKeyword
  | Token_mapping.Token_definitions_unified.MinusOneKeyword -> Some MinusOneKeyword
  | Token_mapping.Token_definitions_unified.PlusKeyword -> Some PlusKeyword
  | _ -> None

let convert_natural_collection_tokens = function
  | Token_mapping.Token_definitions_unified.FirstElementKeyword -> Some FirstElementKeyword
  | Token_mapping.Token_definitions_unified.RemainingKeyword -> Some RemainingKeyword
  | Token_mapping.Token_definitions_unified.EmptyKeyword -> Some EmptyKeyword
  | Token_mapping.Token_definitions_unified.CharacterCountKeyword -> Some CharacterCountKeyword
  | Token_mapping.Token_definitions_unified.OfParticle -> Some OfParticle
  | Token_mapping.Token_definitions_unified.WhereKeyword -> Some WhereKeyword
  | Token_mapping.Token_definitions_unified.SmallKeyword -> Some SmallKeyword
  | Token_mapping.Token_definitions_unified.ShouldGetKeyword -> Some ShouldGetKeyword
  | _ -> None

(** 古雅体关键字转换模块 - 分解的小函数 *)
let convert_ancient_core_tokens = function
  | Token_mapping.Token_definitions_unified.AncientDefineKeyword -> Some AncientDefineKeyword
  | Token_mapping.Token_definitions_unified.AncientEndKeyword -> Some AncientEndKeyword
  | Token_mapping.Token_definitions_unified.AncientAlgorithmKeyword -> Some AncientAlgorithmKeyword
  | Token_mapping.Token_definitions_unified.AncientCompleteKeyword -> Some AncientCompleteKeyword
  | Token_mapping.Token_definitions_unified.AncientObserveKeyword -> Some AncientObserveKeyword
  | Token_mapping.Token_definitions_unified.AncientNatureKeyword -> Some AncientNatureKeyword
  | _ -> None

let convert_ancient_control_tokens = function
  | Token_mapping.Token_definitions_unified.AncientThenKeyword -> Some AncientThenKeyword
  | Token_mapping.Token_definitions_unified.AncientOtherwiseKeyword -> Some AncientOtherwiseKeyword
  | Token_mapping.Token_definitions_unified.AncientAnswerKeyword -> Some AncientAnswerKeyword
  | Token_mapping.Token_definitions_unified.AncientCombineKeyword -> Some AncientCombineKeyword
  | Token_mapping.Token_definitions_unified.AncientAsOneKeyword -> Some AncientAsOneKeyword
  | Token_mapping.Token_definitions_unified.AncientWhenKeyword -> Some AncientWhenKeyword
  | _ -> None

let convert_ancient_data_tokens = function
  | Token_mapping.Token_definitions_unified.AncientTakeKeyword -> Some AncientTakeKeyword
  | Token_mapping.Token_definitions_unified.AncientReceiveKeyword -> Some AncientReceiveKeyword
  | Token_mapping.Token_definitions_unified.AncientParticleThe -> Some AncientParticleThe
  | Token_mapping.Token_definitions_unified.AncientParticleFun -> Some AncientParticleFun
  | Token_mapping.Token_definitions_unified.AncientCallItKeyword -> Some AncientCallItKeyword
  | Token_mapping.Token_definitions_unified.AncientIsKeyword -> Some AncientIsKeyword
  | Token_mapping.Token_definitions_unified.AncientArrowKeyword -> Some AncientArrowKeyword
  | Token_mapping.Token_definitions_unified.AncientCommaKeyword -> Some AncientCommaKeyword
  | Token_mapping.Token_definitions_unified.AfterThatKeyword -> Some AfterThatKeyword
  | _ -> None

let convert_ancient_list_tokens = function
  | Token_mapping.Token_definitions_unified.AncientListStartKeyword -> Some AncientListStartKeyword
  | Token_mapping.Token_definitions_unified.AncientListEndKeyword -> Some AncientListEndKeyword
  | Token_mapping.Token_definitions_unified.AncientItsFirstKeyword -> Some AncientItsFirstKeyword
  | Token_mapping.Token_definitions_unified.AncientItsSecondKeyword -> Some AncientItsSecondKeyword
  | Token_mapping.Token_definitions_unified.AncientItsThirdKeyword -> Some AncientItsThirdKeyword
  | Token_mapping.Token_definitions_unified.AncientEmptyKeyword -> Some AncientEmptyKeyword
  | Token_mapping.Token_definitions_unified.AncientHasHeadTailKeyword ->
      Some AncientHasHeadTailKeyword
  | Token_mapping.Token_definitions_unified.AncientHeadNameKeyword -> Some AncientHeadNameKeyword
  | Token_mapping.Token_definitions_unified.AncientTailNameKeyword -> Some AncientTailNameKeyword
  | Token_mapping.Token_definitions_unified.AncientThusAnswerKeyword ->
      Some AncientThusAnswerKeyword
  | Token_mapping.Token_definitions_unified.AncientAddToKeyword -> Some AncientAddToKeyword
  | _ -> None

let convert_ancient_record_tokens = function
  | Token_mapping.Token_definitions_unified.AncientRecordStartKeyword ->
      Some AncientRecordStartKeyword
  | Token_mapping.Token_definitions_unified.AncientRecordEndKeyword -> Some AncientRecordEndKeyword
  | Token_mapping.Token_definitions_unified.AncientRecordEmptyKeyword ->
      Some AncientRecordEmptyKeyword
  | Token_mapping.Token_definitions_unified.AncientRecordUpdateKeyword ->
      Some AncientRecordUpdateKeyword
  | Token_mapping.Token_definitions_unified.AncientRecordFinishKeyword ->
      Some AncientRecordFinishKeyword
  | Token_mapping.Token_definitions_unified.AncientObserveEndKeyword ->
      Some AncientObserveEndKeyword
  | Token_mapping.Token_definitions_unified.AncientBeginKeyword -> Some AncientBeginKeyword
  | Token_mapping.Token_definitions_unified.AncientEndCompleteKeyword ->
      Some AncientEndCompleteKeyword
  | _ -> None

(** 统一古典语言转换策略接口 - 重构为小函数调用 *)
let convert_with_classical_strategy strategy token =
  let error_context = strategy_description strategy in
  let converters =
    match strategy with
    | Wenyan ->
        [
          convert_wenyan_core_tokens; convert_wenyan_execution_tokens; convert_wenyan_control_tokens;
        ]
    | Natural_Language ->
        [
          convert_natural_basic_tokens;
          convert_natural_arithmetic_tokens;
          convert_natural_collection_tokens;
        ]
    | Ancient_Style ->
        [
          convert_ancient_core_tokens;
          convert_ancient_control_tokens;
          convert_ancient_data_tokens;
          convert_ancient_list_tokens;
          convert_ancient_record_tokens;
        ]
  in
  let rec try_converters = function
    | [] -> raise (Unknown_classical_token ("不是" ^ error_context ^ "token"))
    | converter :: rest -> (
        match converter token with Some result -> result | None -> try_converters rest)
  in
  try try_converters converters with
  | Unknown_classical_token msg -> raise (Unknown_classical_token msg)
  | exn -> raise (Unknown_classical_token (error_context ^ "转换失败: " ^ Printexc.to_string exn))

(** 转换古典语言tokens - 使用统一模式匹配优化性能 (保留向后兼容) *)
let convert_classical_token token =
  (* 尝试按顺序使用不同策略进行转换 *)
  let strategies = [ Wenyan; Natural_Language; Ancient_Style ] in
  let rec try_strategies = function
    | [] -> raise (Unknown_classical_token "未知的古典语言token")
    | strategy :: rest -> (
        try convert_with_classical_strategy strategy token
        with Unknown_classical_token _ -> try_strategies rest)
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
  let convert_wenyan_token token = convert_with_classical_strategy Wenyan token
end

module Natural = struct
  let convert_natural_language_token token = convert_with_classical_strategy Natural_Language token
end

module Ancient = struct
  let convert_ancient_token token = convert_with_classical_strategy Ancient_Style token
end
