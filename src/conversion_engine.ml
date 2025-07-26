(** 统一Token转换引擎 - Phase 6.2 重构
    
    这是Token系统Phase 6.2重构的核心引擎，整合所有转换逻辑到统一架构中。
    实现了设计文档中定义的4层架构中的转换层核心。
    
    重构目标：
    - 统一错误处理机制
    - 实现统一转换接口设计
    - 支持转换策略动态选择
    - 提供性能优化的快速路径
    
    架构设计：
    - Core Layer: 统一类型定义和错误处理
    - Conversion Layer: 转换引擎核心（本模块）
    - Compatibility Layer: 兼容性处理
    - Interface Layer: 统一对外API
    
    @author Alpha, 主工作代理 - Phase 6.2 Implementation
    @version 2.0 - 统一转换引擎
    @since 2025-07-25
    @fixes Issue #1340 *)

open Unified_logger

(** 统一错误处理机制 - 符合设计文档规范 *)
type token_error =
  | ConversionError of string * string (* source, target *)
  | CompatibilityError of string (* compatibility issue *)
  | ValidationError of string (* validation failure *)
  | SystemError of string (* system level error *)

type 'a token_result = Success of 'a | Error of token_error

(* 统一的错误处理函数 *)
let handle_error = function
  | ConversionError (source, target) ->
      errorf "token_conversion" "转换错误: 无法从 %s 转换到 %s" source target
  | CompatibilityError issue -> error "compatibility" ("兼容性错误: " ^ issue)
  | ValidationError failure -> error "validation" ("验证错误: " ^ failure)
  | SystemError err -> error "system" ("系统错误: " ^ err)

let error_to_string = function
  | ConversionError (source, target) -> Printf.sprintf "转换错误: 无法从 %s 转换到 %s" source target
  | CompatibilityError issue -> Printf.sprintf "兼容性错误: %s" issue
  | ValidationError failure -> Printf.sprintf "验证错误: %s" failure
  | SystemError error -> Printf.sprintf "系统错误: %s" error

(** 转换策略类型 - 符合设计文档规范 *)
type conversion_strategy =
  | Classical (* 古典诗词转换 *)
  | Modern (* 现代中文转换 *)
  | Lexer (* 词法器转换 *)
  | Auto (* 自动选择策略 *)

type safe_converter_function =
  Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token option
(** 类型安全的转换器函数 *)

(** 类型安全的转换函数 - 消除Obj.magic使用 *)
(** 基础字面量token转换 *)
let convert_literal_tokens = function
  | Token_mapping.Token_definitions_unified.IntToken i -> Some (Lexer_tokens.IntToken i)
  | Token_mapping.Token_definitions_unified.FloatToken f -> Some (Lexer_tokens.FloatToken f)
  | Token_mapping.Token_definitions_unified.ChineseNumberToken s ->
      Some (Lexer_tokens.ChineseNumberToken s)
  | Token_mapping.Token_definitions_unified.StringToken s -> Some (Lexer_tokens.StringToken s)
  | Token_mapping.Token_definitions_unified.BoolToken b -> Some (Lexer_tokens.BoolToken b)
  | _ -> None

(** 标识符token转换 *)
let convert_identifier_tokens = function
  | Token_mapping.Token_definitions_unified.QuotedIdentifierToken s ->
      Some (Lexer_tokens.QuotedIdentifierToken s)
  | Token_mapping.Token_definitions_unified.IdentifierTokenSpecial s ->
      Some (Lexer_tokens.IdentifierTokenSpecial s)
  | _ -> None

(** 基础关键字token转换 *)
let convert_basic_keyword_tokens = function
  | Token_mapping.Token_definitions_unified.LetKeyword -> Some (Lexer_tokens.LetKeyword)
  | Token_mapping.Token_definitions_unified.RecKeyword -> Some (Lexer_tokens.RecKeyword)
  | Token_mapping.Token_definitions_unified.InKeyword -> Some (Lexer_tokens.InKeyword)
  | Token_mapping.Token_definitions_unified.FunKeyword -> Some (Lexer_tokens.FunKeyword)
  | Token_mapping.Token_definitions_unified.ParamKeyword -> Some (Lexer_tokens.ParamKeyword)
  | Token_mapping.Token_definitions_unified.IfKeyword -> Some (Lexer_tokens.IfKeyword)
  | Token_mapping.Token_definitions_unified.ThenKeyword -> Some (Lexer_tokens.ThenKeyword)
  | Token_mapping.Token_definitions_unified.ElseKeyword -> Some (Lexer_tokens.ElseKeyword)
  | Token_mapping.Token_definitions_unified.MatchKeyword -> Some (Lexer_tokens.MatchKeyword)
  | Token_mapping.Token_definitions_unified.WithKeyword -> Some (Lexer_tokens.WithKeyword)
  | Token_mapping.Token_definitions_unified.OtherKeyword -> Some (Lexer_tokens.OtherKeyword)
  | Token_mapping.Token_definitions_unified.AndKeyword -> Some (Lexer_tokens.AndKeyword)
  | Token_mapping.Token_definitions_unified.OrKeyword -> Some (Lexer_tokens.OrKeyword)
  | Token_mapping.Token_definitions_unified.NotKeyword -> Some (Lexer_tokens.NotKeyword)
  | Token_mapping.Token_definitions_unified.OfKeyword -> Some (Lexer_tokens.OfKeyword)
  | Token_mapping.Token_definitions_unified.TrueKeyword -> Some (Lexer_tokens.TrueKeyword)
  | Token_mapping.Token_definitions_unified.FalseKeyword -> Some (Lexer_tokens.FalseKeyword)
  | _ -> None

(** 语义关键字token转换 *)
let convert_semantic_keyword_tokens = function
  | Token_mapping.Token_definitions_unified.AsKeyword -> Some (Lexer_tokens.AsKeyword)
  | Token_mapping.Token_definitions_unified.CombineKeyword -> Some (Lexer_tokens.CombineKeyword)
  | Token_mapping.Token_definitions_unified.WithOpKeyword -> Some (Lexer_tokens.WithOpKeyword)
  | Token_mapping.Token_definitions_unified.WhenKeyword -> Some (Lexer_tokens.WhenKeyword)
  | Token_mapping.Token_definitions_unified.WithDefaultKeyword -> Some (Lexer_tokens.WithDefaultKeyword)
  | Token_mapping.Token_definitions_unified.ExceptionKeyword -> Some (Lexer_tokens.ExceptionKeyword)
  | Token_mapping.Token_definitions_unified.RaiseKeyword -> Some (Lexer_tokens.RaiseKeyword)
  | Token_mapping.Token_definitions_unified.TryKeyword -> Some (Lexer_tokens.TryKeyword)
  | Token_mapping.Token_definitions_unified.CatchKeyword -> Some (Lexer_tokens.CatchKeyword)
  | Token_mapping.Token_definitions_unified.FinallyKeyword -> Some (Lexer_tokens.FinallyKeyword)
  | _ -> None

(** 模块关键字token转换 *)
let convert_module_keyword_tokens = function
  | Token_mapping.Token_definitions_unified.ModuleKeyword -> Some (Lexer_tokens.ModuleKeyword)
  | Token_mapping.Token_definitions_unified.ModuleTypeKeyword -> Some (Lexer_tokens.ModuleTypeKeyword)
  | Token_mapping.Token_definitions_unified.RefKeyword -> Some (Lexer_tokens.RefKeyword)
  | Token_mapping.Token_definitions_unified.IncludeKeyword -> Some (Lexer_tokens.IncludeKeyword)
  | Token_mapping.Token_definitions_unified.FunctorKeyword -> Some (Lexer_tokens.FunctorKeyword)
  | Token_mapping.Token_definitions_unified.SigKeyword -> Some (Lexer_tokens.SigKeyword)
  | Token_mapping.Token_definitions_unified.EndKeyword -> Some (Lexer_tokens.EndKeyword)
  | Token_mapping.Token_definitions_unified.MacroKeyword -> Some (Lexer_tokens.MacroKeyword)
  | Token_mapping.Token_definitions_unified.ExpandKeyword -> Some (Lexer_tokens.ExpandKeyword)
  | _ -> None

(** 类型关键字token转换 *)
let convert_type_keyword_tokens = function
  | Token_mapping.Token_definitions_unified.TypeKeyword -> Some (Lexer_tokens.TypeKeyword)
  | Token_mapping.Token_definitions_unified.PrivateKeyword -> Some (Lexer_tokens.PrivateKeyword)
  | Token_mapping.Token_definitions_unified.InputKeyword -> Some (Lexer_tokens.InputKeyword)
  | Token_mapping.Token_definitions_unified.OutputKeyword -> Some (Lexer_tokens.OutputKeyword)
  | Token_mapping.Token_definitions_unified.IntTypeKeyword -> Some (Lexer_tokens.IntTypeKeyword)
  | Token_mapping.Token_definitions_unified.FloatTypeKeyword -> Some (Lexer_tokens.FloatTypeKeyword)
  | Token_mapping.Token_definitions_unified.StringTypeKeyword -> Some (Lexer_tokens.StringTypeKeyword)
  | Token_mapping.Token_definitions_unified.BoolTypeKeyword -> Some (Lexer_tokens.BoolTypeKeyword)
  | Token_mapping.Token_definitions_unified.UnitTypeKeyword -> Some (Lexer_tokens.UnitTypeKeyword)
  | Token_mapping.Token_definitions_unified.ListTypeKeyword -> Some (Lexer_tokens.ListTypeKeyword)
  | Token_mapping.Token_definitions_unified.ArrayTypeKeyword -> Some (Lexer_tokens.ArrayTypeKeyword)
  | Token_mapping.Token_definitions_unified.VariantKeyword -> Some (Lexer_tokens.VariantKeyword)
  | Token_mapping.Token_definitions_unified.TagKeyword -> Some (Lexer_tokens.TagKeyword)
  | _ -> None

(** 文言文关键字token转换 *)
let convert_wenyan_keyword_tokens = function
  | Token_mapping.Token_definitions_unified.HaveKeyword -> Some (Lexer_tokens.HaveKeyword)
  | Token_mapping.Token_definitions_unified.OneKeyword -> Some (Lexer_tokens.OneKeyword)
  | Token_mapping.Token_definitions_unified.NameKeyword -> Some (Lexer_tokens.NameKeyword)
  | Token_mapping.Token_definitions_unified.SetKeyword -> Some (Lexer_tokens.SetKeyword)
  | Token_mapping.Token_definitions_unified.AlsoKeyword -> Some (Lexer_tokens.AlsoKeyword)
  | Token_mapping.Token_definitions_unified.ThenGetKeyword -> Some (Lexer_tokens.ThenGetKeyword)
  | Token_mapping.Token_definitions_unified.CallKeyword -> Some (Lexer_tokens.CallKeyword)
  | Token_mapping.Token_definitions_unified.ValueKeyword -> Some (Lexer_tokens.ValueKeyword)
  | Token_mapping.Token_definitions_unified.AsForKeyword -> Some (Lexer_tokens.AsForKeyword)
  | Token_mapping.Token_definitions_unified.NumberKeyword -> Some (Lexer_tokens.NumberKeyword)
  | Token_mapping.Token_definitions_unified.WantExecuteKeyword -> Some (Lexer_tokens.WantExecuteKeyword)
  | Token_mapping.Token_definitions_unified.MustFirstGetKeyword -> Some (Lexer_tokens.MustFirstGetKeyword)
  | Token_mapping.Token_definitions_unified.ForThisKeyword -> Some (Lexer_tokens.ForThisKeyword)
  | Token_mapping.Token_definitions_unified.TimesKeyword -> Some (Lexer_tokens.TimesKeyword)
  | Token_mapping.Token_definitions_unified.EndCloudKeyword -> Some (Lexer_tokens.EndCloudKeyword)
  | Token_mapping.Token_definitions_unified.IfWenyanKeyword -> Some (Lexer_tokens.IfWenyanKeyword)
  | Token_mapping.Token_definitions_unified.ThenWenyanKeyword -> Some (Lexer_tokens.ThenWenyanKeyword)
  | Token_mapping.Token_definitions_unified.GreaterThanWenyan -> Some (Lexer_tokens.GreaterThanWenyan)
  | Token_mapping.Token_definitions_unified.LessThanWenyan -> Some (Lexer_tokens.LessThanWenyan)
  | _ -> None

(** 古雅体关键字token转换 *)
let convert_ancient_keyword_tokens = function
  | Token_mapping.Token_definitions_unified.AncientDefineKeyword ->
      Some (Lexer_tokens.AncientDefineKeyword)
  | Token_mapping.Token_definitions_unified.AncientEndKeyword -> Some (Lexer_tokens.AncientEndKeyword)
  | Token_mapping.Token_definitions_unified.AncientAlgorithmKeyword ->
      Some (Lexer_tokens.AncientAlgorithmKeyword)
  | Token_mapping.Token_definitions_unified.AncientCompleteKeyword ->
      Some (Lexer_tokens.AncientCompleteKeyword)
  | Token_mapping.Token_definitions_unified.AncientObserveKeyword ->
      Some (Lexer_tokens.AncientObserveKeyword)
  | Token_mapping.Token_definitions_unified.AncientNatureKeyword ->
      Some (Lexer_tokens.AncientNatureKeyword)
  | Token_mapping.Token_definitions_unified.AncientThenKeyword -> Some (Lexer_tokens.AncientThenKeyword)
  | Token_mapping.Token_definitions_unified.AncientOtherwiseKeyword ->
      Some (Lexer_tokens.AncientOtherwiseKeyword)
  | Token_mapping.Token_definitions_unified.AncientAnswerKeyword ->
      Some (Lexer_tokens.AncientAnswerKeyword)
  | Token_mapping.Token_definitions_unified.AncientCombineKeyword ->
      Some (Lexer_tokens.AncientCombineKeyword)
  | Token_mapping.Token_definitions_unified.AncientAsOneKeyword -> Some (Lexer_tokens.AncientAsOneKeyword)
  | Token_mapping.Token_definitions_unified.AncientTakeKeyword -> Some (Lexer_tokens.AncientTakeKeyword)
  | Token_mapping.Token_definitions_unified.AncientReceiveKeyword ->
      Some (Lexer_tokens.AncientReceiveKeyword)
  | Token_mapping.Token_definitions_unified.AncientParticleThe -> Some (Lexer_tokens.AncientParticleThe)
  | Token_mapping.Token_definitions_unified.AncientParticleFun -> Some (Lexer_tokens.AncientParticleFun)
  | Token_mapping.Token_definitions_unified.AncientCallItKeyword ->
      Some (Lexer_tokens.AncientCallItKeyword)
  | Token_mapping.Token_definitions_unified.AncientListStartKeyword ->
      Some (Lexer_tokens.AncientListStartKeyword)
  | Token_mapping.Token_definitions_unified.AncientListEndKeyword ->
      Some (Lexer_tokens.AncientListEndKeyword)
  | Token_mapping.Token_definitions_unified.AncientItsFirstKeyword ->
      Some (Lexer_tokens.AncientItsFirstKeyword)
  | Token_mapping.Token_definitions_unified.AncientItsSecondKeyword ->
      Some (Lexer_tokens.AncientItsSecondKeyword)
  | Token_mapping.Token_definitions_unified.AncientItsThirdKeyword ->
      Some (Lexer_tokens.AncientItsThirdKeyword)
  | Token_mapping.Token_definitions_unified.AncientEmptyKeyword -> Some (Lexer_tokens.AncientEmptyKeyword)
  | Token_mapping.Token_definitions_unified.AncientHasHeadTailKeyword ->
      Some (Lexer_tokens.AncientHasHeadTailKeyword)
  | Token_mapping.Token_definitions_unified.AncientHeadNameKeyword ->
      Some (Lexer_tokens.AncientHeadNameKeyword)
  | Token_mapping.Token_definitions_unified.AncientTailNameKeyword ->
      Some (Lexer_tokens.AncientTailNameKeyword)
  | Token_mapping.Token_definitions_unified.AncientThusAnswerKeyword ->
      Some (Lexer_tokens.AncientThusAnswerKeyword)
  | Token_mapping.Token_definitions_unified.AncientAddToKeyword -> Some (Lexer_tokens.AncientAddToKeyword)
  | Token_mapping.Token_definitions_unified.AncientObserveEndKeyword ->
      Some (Lexer_tokens.AncientObserveEndKeyword)
  | Token_mapping.Token_definitions_unified.AncientBeginKeyword -> Some (Lexer_tokens.AncientBeginKeyword)
  | Token_mapping.Token_definitions_unified.AncientEndCompleteKeyword ->
      Some (Lexer_tokens.AncientEndCompleteKeyword)
  | Token_mapping.Token_definitions_unified.AncientIsKeyword -> Some (Lexer_tokens.AncientIsKeyword)
  | Token_mapping.Token_definitions_unified.AncientArrowKeyword -> Some (Lexer_tokens.AncientArrowKeyword)
  | Token_mapping.Token_definitions_unified.AncientWhenKeyword -> Some (Lexer_tokens.AncientWhenKeyword)
  | Token_mapping.Token_definitions_unified.AncientCommaKeyword -> Some (Lexer_tokens.AncientCommaKeyword)
  | Token_mapping.Token_definitions_unified.AfterThatKeyword -> Some (Lexer_tokens.AfterThatKeyword)
  | Token_mapping.Token_definitions_unified.AncientRecordStartKeyword ->
      Some (Lexer_tokens.AncientRecordStartKeyword)
  | Token_mapping.Token_definitions_unified.AncientRecordEndKeyword ->
      Some (Lexer_tokens.AncientRecordEndKeyword)
  | Token_mapping.Token_definitions_unified.AncientRecordEmptyKeyword ->
      Some (Lexer_tokens.AncientRecordEmptyKeyword)
  | Token_mapping.Token_definitions_unified.AncientRecordUpdateKeyword ->
      Some (Lexer_tokens.AncientRecordUpdateKeyword)
  | Token_mapping.Token_definitions_unified.AncientRecordFinishKeyword ->
      Some (Lexer_tokens.AncientRecordFinishKeyword)
  | _ -> None

(** 自然语言关键字token转换 *)
let convert_natural_language_tokens = function
  | Token_mapping.Token_definitions_unified.DefineKeyword -> Some (Lexer_tokens.DefineKeyword)
  | Token_mapping.Token_definitions_unified.AcceptKeyword -> Some (Lexer_tokens.AcceptKeyword)
  | Token_mapping.Token_definitions_unified.ReturnWhenKeyword -> Some (Lexer_tokens.ReturnWhenKeyword)
  | Token_mapping.Token_definitions_unified.ElseReturnKeyword -> Some (Lexer_tokens.ElseReturnKeyword)
  | Token_mapping.Token_definitions_unified.MultiplyKeyword -> Some (Lexer_tokens.MultiplyKeyword)
  | Token_mapping.Token_definitions_unified.DivideKeyword -> Some (Lexer_tokens.DivideKeyword)
  | Token_mapping.Token_definitions_unified.AddToKeyword -> Some (Lexer_tokens.AddToKeyword)
  | Token_mapping.Token_definitions_unified.SubtractKeyword -> Some (Lexer_tokens.SubtractKeyword)
  | Token_mapping.Token_definitions_unified.EqualToKeyword -> Some (Lexer_tokens.EqualToKeyword)
  | Token_mapping.Token_definitions_unified.LessThanEqualToKeyword ->
      Some (Lexer_tokens.LessThanEqualToKeyword)
  | Token_mapping.Token_definitions_unified.FirstElementKeyword -> Some (Lexer_tokens.FirstElementKeyword)
  | Token_mapping.Token_definitions_unified.RemainingKeyword -> Some (Lexer_tokens.RemainingKeyword)
  | Token_mapping.Token_definitions_unified.EmptyKeyword -> Some (Lexer_tokens.EmptyKeyword)
  | Token_mapping.Token_definitions_unified.CharacterCountKeyword ->
      Some (Lexer_tokens.CharacterCountKeyword)
  | Token_mapping.Token_definitions_unified.OfParticle -> Some (Lexer_tokens.OfParticle)
  | Token_mapping.Token_definitions_unified.MinusOneKeyword -> Some (Lexer_tokens.MinusOneKeyword)
  | Token_mapping.Token_definitions_unified.PlusKeyword -> Some (Lexer_tokens.PlusKeyword)
  | Token_mapping.Token_definitions_unified.WhereKeyword -> Some (Lexer_tokens.WhereKeyword)
  | Token_mapping.Token_definitions_unified.SmallKeyword -> Some (Lexer_tokens.SmallKeyword)
  | Token_mapping.Token_definitions_unified.ShouldGetKeyword -> Some (Lexer_tokens.ShouldGetKeyword)
  | _ -> None

(** 重构后的safe_token_convert函数 - 使用分层转换 *)
let safe_token_convert (unified_token : Token_mapping.Token_definitions_unified.token) :
    Lexer_tokens.token =
  (* 尝试各种转换器，返回第一个成功的结果 *)
  let converters = [
    convert_literal_tokens;
    convert_identifier_tokens;
    convert_basic_keyword_tokens;
    convert_semantic_keyword_tokens;
    convert_module_keyword_tokens;
    convert_type_keyword_tokens;
    convert_wenyan_keyword_tokens;
    convert_ancient_keyword_tokens;
    convert_natural_language_tokens;
  ] in
  let rec try_converters = function
    | [] ->
        (* 如果所有转换器都失败，抛出异常 *)
        failwith ("未知的token类型: " ^ 
                 (* 这里可以添加token的字符串表示，暂时用占位符 *)
                 "unknown_token")
    | converter :: rest ->
        match converter unified_token with
        | Some result -> result
        | None -> try_converters rest
  in
  try_converters converters

(** 类型安全的可选转换函数 - 重构版本 *)
let safe_token_convert_option (unified_token : Token_mapping.Token_definitions_unified.token) :
    Lexer_tokens.token option =
  try Some (safe_token_convert unified_token) with _ -> None

type converter_function = Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token option
(** 转换器注册类型 - 保持原有API兼容性 *)

(** 转换器注册表 *)
module ConverterRegistry = struct
  let classical_converters = ref []
  let modern_converters = ref []
  let lexer_converters = ref []

  let register_classical_converter converter =
    classical_converters := converter :: !classical_converters

  let register_modern_converter converter = modern_converters := converter :: !modern_converters
  let register_lexer_converter converter = lexer_converters := converter :: !lexer_converters

  let get_converters = function
    | Classical -> !classical_converters
    | Modern -> !modern_converters
    | Lexer -> !lexer_converters
    | Auto -> !classical_converters @ !modern_converters @ !lexer_converters
end

(** 统一转换函数签名 - 类型安全版本 *)
let convert_token ~strategy ~(source : Token_mapping.Token_definitions_unified.token) ~target_format
    =
  let converters = ConverterRegistry.get_converters strategy in
  let source_name = "unified_token" in
  (* 用于错误报告的字符串 *)
  let rec try_converters = function
    | [] -> Error (ConversionError (source_name, target_format))
    | converter :: rest -> (
        match converter source with
        (* 类型安全转换 - 已消除Obj.magic *)
        | Some result -> Success result
        | None -> try_converters rest)
  in
  try_converters converters

(** 批量转换函数 - 符合设计文档规范 *)
let batch_convert ~strategy ~tokens ~target_format =
  let convert_single token = convert_token ~strategy ~source:token ~target_format in
  let rec convert_all acc = function
    | [] -> Success (List.rev acc)
    | token :: rest -> (
        match convert_single token with
        | Success result -> convert_all (result :: acc) rest
        | Error err -> Error err)
  in
  convert_all [] tokens

(** 性能优化的快速路径转换 *)
module FastPath = struct
  open Lexer_tokens

  (* 常用转换的直接映射 - 避免函数调用开销 *)
  let convert_common_token = function
    | Token_mapping.Token_definitions_unified.LetKeyword -> Some LetKeyword
    | Token_mapping.Token_definitions_unified.FunKeyword -> Some FunKeyword
    | Token_mapping.Token_definitions_unified.IfKeyword -> Some IfKeyword
    | Token_mapping.Token_definitions_unified.ThenKeyword -> Some ThenKeyword
    | Token_mapping.Token_definitions_unified.ElseKeyword -> Some ElseKeyword
    | Token_mapping.Token_definitions_unified.IntToken i -> Some (IntToken i)
    | Token_mapping.Token_definitions_unified.StringToken s -> Some (StringToken s)
    | Token_mapping.Token_definitions_unified.BoolToken b -> Some (BoolToken b)
    | _ -> None
end

(** 转换引擎核心逻辑 *)
module Core = struct
  (* 初始化默认转换器 *)
  let initialize_converters () =
    (* 注册现代语言转换器 - 使用类型安全转换 *)
    ConverterRegistry.register_modern_converter safe_token_convert_option;

    (* 注册古典语言转换器 - 使用现有的 Token_conversion_classical 模块 *)
    ConverterRegistry.register_classical_converter (fun token ->
        try Some (Token_conversion_classical.convert_classical_token token) with _ -> None)

  (* 主转换接口 *)
  let convert_with_fallback token =
    match FastPath.convert_common_token token with
    | Some result -> Success result
    | None ->
        (* 尝试不同策略按优先级顺序 *)
        let strategies = [ Modern; Classical; Lexer ] in
        let rec try_strategies = function
          | [] -> Error (ConversionError ("unknown", "lexer_token"))
          | strategy :: rest -> (
              match convert_token ~strategy ~source:token ~target_format:"lexer_token" with
              | Success result -> Success result
              | Error _ -> try_strategies rest)
        in
        try_strategies strategies
end

(** 向后兼容性接口 - 保持原有API *)
module BackwardCompatibility = struct
  let convert_token token =
    match Core.convert_with_fallback token with Success result -> Some result | Error _ -> None

  let convert_token_exn token =
    match Core.convert_with_fallback token with
    | Success result -> result
    | Error (ConversionError (source, target)) ->
        let error_msg = Printf.sprintf "转换失败: 无法从 %s 转换到 %s" source target in
        raise (Invalid_argument error_msg)
    | Error (CompatibilityError issue) ->
        let error_msg = Printf.sprintf "兼容性错误: %s" issue in
        raise (Invalid_argument error_msg)
    | Error (ValidationError issue) ->
        let error_msg = Printf.sprintf "验证错误: %s" issue in
        raise (Invalid_argument error_msg)
    | Error (SystemError issue) ->
        let error_msg = Printf.sprintf "系统错误: %s" issue in
        raise (Invalid_argument error_msg)

  let convert_token_list tokens = List.filter_map convert_token tokens
end

(** 统计信息模块 *)
module Statistics = struct
  let get_engine_stats () =
    let classical_count = List.length !ConverterRegistry.classical_converters in
    let modern_count = List.length !ConverterRegistry.modern_converters in
    let lexer_count = List.length !ConverterRegistry.lexer_converters in
    Printf.sprintf {|转换引擎统计信息:
- 古典语言转换器: %d个
- 现代语言转换器: %d个  
- 词法器转换器: %d个
- 总计: %d个转换器|}
      classical_count modern_count lexer_count
      (classical_count + modern_count + lexer_count)
end

(* 初始化转换引擎 *)
let () = Core.initialize_converters ()
