(** Token转换 - 关键字专门模块

    从token_conversion_core.ml中提取的关键字转换逻辑， 使用统一的模式匹配优化性能，避免异常开销。

    @author 骆言技术债务清理团队 Issue #1256
    @version 1.0
    @since 2025-07-25 *)

open Lexer_tokens

exception Unknown_keyword_token of string
(** 异常定义 *)

(** 转换基础语言关键字 *)
let convert_basic_language_keywords = function
  | Token_mapping.Token_definitions_unified.LetKeyword -> Some LetKeyword
  | Token_mapping.Token_definitions_unified.RecKeyword -> Some RecKeyword
  | Token_mapping.Token_definitions_unified.InKeyword -> Some InKeyword
  | Token_mapping.Token_definitions_unified.FunKeyword -> Some FunKeyword
  | Token_mapping.Token_definitions_unified.IfKeyword -> Some IfKeyword
  | Token_mapping.Token_definitions_unified.ThenKeyword -> Some ThenKeyword
  | Token_mapping.Token_definitions_unified.ElseKeyword -> Some ElseKeyword
  | Token_mapping.Token_definitions_unified.MatchKeyword -> Some MatchKeyword
  | Token_mapping.Token_definitions_unified.WithKeyword -> Some WithKeyword
  | Token_mapping.Token_definitions_unified.OtherKeyword -> Some OtherKeyword
  | Token_mapping.Token_definitions_unified.AndKeyword -> Some AndKeyword
  | Token_mapping.Token_definitions_unified.OrKeyword -> Some OrKeyword
  | Token_mapping.Token_definitions_unified.NotKeyword -> Some NotKeyword
  | Token_mapping.Token_definitions_unified.OfKeyword -> Some OfKeyword
  | _ -> None

(** 转换语义关键字 *)
let convert_semantic_keywords = function
  | Token_mapping.Token_definitions_unified.AsKeyword -> Some AsKeyword
  | Token_mapping.Token_definitions_unified.CombineKeyword -> Some CombineKeyword
  | Token_mapping.Token_definitions_unified.WithOpKeyword -> Some WithOpKeyword
  | Token_mapping.Token_definitions_unified.WhenKeyword -> Some WhenKeyword
  | _ -> None

(** 转换错误恢复关键字 *)
let convert_error_recovery_keywords = function
  | Token_mapping.Token_definitions_unified.WithDefaultKeyword -> Some WithDefaultKeyword
  | Token_mapping.Token_definitions_unified.ExceptionKeyword -> Some ExceptionKeyword
  | Token_mapping.Token_definitions_unified.RaiseKeyword -> Some RaiseKeyword
  | Token_mapping.Token_definitions_unified.TryKeyword -> Some TryKeyword
  | Token_mapping.Token_definitions_unified.CatchKeyword -> Some CatchKeyword
  | Token_mapping.Token_definitions_unified.FinallyKeyword -> Some FinallyKeyword
  | _ -> None

(** 转换模块系统关键字 *)
let convert_module_system_keywords = function
  | Token_mapping.Token_definitions_unified.ModuleKeyword -> Some ModuleKeyword
  | Token_mapping.Token_definitions_unified.ModuleTypeKeyword -> Some ModuleTypeKeyword
  | Token_mapping.Token_definitions_unified.RefKeyword -> Some RefKeyword
  | Token_mapping.Token_definitions_unified.IncludeKeyword -> Some IncludeKeyword
  | Token_mapping.Token_definitions_unified.FunctorKeyword -> Some FunctorKeyword
  | Token_mapping.Token_definitions_unified.SigKeyword -> Some SigKeyword
  | Token_mapping.Token_definitions_unified.EndKeyword -> Some EndKeyword
  | Token_mapping.Token_definitions_unified.MacroKeyword -> Some MacroKeyword
  | Token_mapping.Token_definitions_unified.ExpandKeyword -> Some ExpandKeyword
  | Token_mapping.Token_definitions_unified.TypeKeyword -> Some TypeKeyword
  | Token_mapping.Token_definitions_unified.PrivateKeyword -> Some PrivateKeyword
  | Token_mapping.Token_definitions_unified.ParamKeyword -> Some ParamKeyword
  | _ -> None

(** 转换自然语言关键字 *)
let convert_natural_language_keywords = function
  | Token_mapping.Token_definitions_unified.DefineKeyword -> Some DefineKeyword
  | Token_mapping.Token_definitions_unified.AcceptKeyword -> Some AcceptKeyword
  | Token_mapping.Token_definitions_unified.ReturnWhenKeyword -> Some ReturnWhenKeyword
  | Token_mapping.Token_definitions_unified.ElseReturnKeyword -> Some ElseReturnKeyword
  | Token_mapping.Token_definitions_unified.MultiplyKeyword -> Some MultiplyKeyword
  | Token_mapping.Token_definitions_unified.DivideKeyword -> Some DivideKeyword
  | Token_mapping.Token_definitions_unified.AddToKeyword -> Some AddToKeyword
  | Token_mapping.Token_definitions_unified.SubtractKeyword -> Some SubtractKeyword
  | Token_mapping.Token_definitions_unified.EqualToKeyword -> Some EqualToKeyword
  | Token_mapping.Token_definitions_unified.LessThanEqualToKeyword -> Some LessThanEqualToKeyword
  | Token_mapping.Token_definitions_unified.FirstElementKeyword -> Some FirstElementKeyword
  | Token_mapping.Token_definitions_unified.RemainingKeyword -> Some RemainingKeyword
  | Token_mapping.Token_definitions_unified.EmptyKeyword -> Some EmptyKeyword
  | Token_mapping.Token_definitions_unified.CharacterCountKeyword -> Some CharacterCountKeyword
  | Token_mapping.Token_definitions_unified.OfParticle -> Some OfParticle
  | Token_mapping.Token_definitions_unified.MinusOneKeyword -> Some MinusOneKeyword
  | Token_mapping.Token_definitions_unified.PlusKeyword -> Some PlusKeyword
  | Token_mapping.Token_definitions_unified.WhereKeyword -> Some WhereKeyword
  | Token_mapping.Token_definitions_unified.SmallKeyword -> Some SmallKeyword
  | Token_mapping.Token_definitions_unified.ShouldGetKeyword -> Some ShouldGetKeyword
  | _ -> None

(** 转换文言文关键字 *)
let convert_wenyan_keywords = function
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
  | Token_mapping.Token_definitions_unified.WantExecuteKeyword -> Some WantExecuteKeyword
  | Token_mapping.Token_definitions_unified.MustFirstGetKeyword -> Some MustFirstGetKeyword
  | Token_mapping.Token_definitions_unified.ForThisKeyword -> Some ForThisKeyword
  | Token_mapping.Token_definitions_unified.TimesKeyword -> Some TimesKeyword
  | Token_mapping.Token_definitions_unified.EndCloudKeyword -> Some EndCloudKeyword
  | Token_mapping.Token_definitions_unified.IfWenyanKeyword -> Some IfWenyanKeyword
  | Token_mapping.Token_definitions_unified.ThenWenyanKeyword -> Some ThenWenyanKeyword
  | Token_mapping.Token_definitions_unified.GreaterThanWenyan -> Some GreaterThanWenyan
  | Token_mapping.Token_definitions_unified.LessThanWenyan -> Some LessThanWenyan
  | _ -> None

(** 转换古雅体关键字 *)
let convert_ancient_keywords = function
  | Token_mapping.Token_definitions_unified.AncientDefineKeyword -> Some AncientDefineKeyword
  | Token_mapping.Token_definitions_unified.AncientEndKeyword -> Some AncientEndKeyword
  | Token_mapping.Token_definitions_unified.AncientAlgorithmKeyword -> Some AncientAlgorithmKeyword
  | Token_mapping.Token_definitions_unified.AncientCompleteKeyword -> Some AncientCompleteKeyword
  | Token_mapping.Token_definitions_unified.AncientObserveKeyword -> Some AncientObserveKeyword
  | Token_mapping.Token_definitions_unified.AncientNatureKeyword -> Some AncientNatureKeyword
  | Token_mapping.Token_definitions_unified.AncientThenKeyword -> Some AncientThenKeyword
  | Token_mapping.Token_definitions_unified.AncientOtherwiseKeyword -> Some AncientOtherwiseKeyword
  | Token_mapping.Token_definitions_unified.AncientAnswerKeyword -> Some AncientAnswerKeyword
  | Token_mapping.Token_definitions_unified.AncientCombineKeyword -> Some AncientCombineKeyword
  | Token_mapping.Token_definitions_unified.AncientAsOneKeyword -> Some AncientAsOneKeyword
  | Token_mapping.Token_definitions_unified.AncientTakeKeyword -> Some AncientTakeKeyword
  | Token_mapping.Token_definitions_unified.AncientReceiveKeyword -> Some AncientReceiveKeyword
  | Token_mapping.Token_definitions_unified.AncientParticleThe -> Some AncientParticleThe
  | Token_mapping.Token_definitions_unified.AncientParticleFun -> Some AncientParticleFun
  | Token_mapping.Token_definitions_unified.AncientCallItKeyword -> Some AncientCallItKeyword
  | Token_mapping.Token_definitions_unified.AncientListStartKeyword -> Some AncientListStartKeyword
  | Token_mapping.Token_definitions_unified.AncientListEndKeyword -> Some AncientListEndKeyword
  | Token_mapping.Token_definitions_unified.AncientItsFirstKeyword -> Some AncientItsFirstKeyword
  | Token_mapping.Token_definitions_unified.AncientItsSecondKeyword -> Some AncientItsSecondKeyword
  | Token_mapping.Token_definitions_unified.AncientItsThirdKeyword -> Some AncientItsThirdKeyword
  | Token_mapping.Token_definitions_unified.AncientEmptyKeyword -> Some AncientEmptyKeyword
  | Token_mapping.Token_definitions_unified.AncientHasHeadTailKeyword -> Some AncientHasHeadTailKeyword
  | Token_mapping.Token_definitions_unified.AncientHeadNameKeyword -> Some AncientHeadNameKeyword
  | Token_mapping.Token_definitions_unified.AncientTailNameKeyword -> Some AncientTailNameKeyword
  | Token_mapping.Token_definitions_unified.AncientThusAnswerKeyword -> Some AncientThusAnswerKeyword
  | Token_mapping.Token_definitions_unified.AncientAddToKeyword -> Some AncientAddToKeyword
  | Token_mapping.Token_definitions_unified.AncientObserveEndKeyword -> Some AncientObserveEndKeyword
  | Token_mapping.Token_definitions_unified.AncientBeginKeyword -> Some AncientBeginKeyword
  | Token_mapping.Token_definitions_unified.AncientEndCompleteKeyword -> Some AncientEndCompleteKeyword
  | _ -> None

(** 转换基础关键字tokens - 重构后的主函数 *)
let convert_basic_keyword_token token =
  let converters = [
    convert_basic_language_keywords;
    convert_semantic_keywords;
    convert_error_recovery_keywords;
    convert_module_system_keywords;
    convert_natural_language_keywords;
    convert_wenyan_keywords;
    convert_ancient_keywords;
  ] in
  let rec try_converters = function
    | [] -> raise (Unknown_keyword_token "不是基础关键字token")
    | converter :: rest ->
        match converter token with
        | Some result -> result
        | None -> try_converters rest
  in
  try_converters converters

(** 安全转换基础关键字token（返回Option类型） - 性能优化版本 *)
let convert_basic_keyword_token_safe token =
  try Some (convert_basic_keyword_token token) with Unknown_keyword_token _ | Failure _ -> None

(** 检查是否为基础关键字token *)
let is_basic_keyword_token token =
  match convert_basic_keyword_token_safe token with Some _ -> true | None -> false
