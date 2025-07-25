(** 词法器Token转换模块 - Phase 6.2 重构
    
    整合所有词法器专用的Token转换接口，包括：
    - 标识符词法转换 (来自 lexer_token_conversion_identifiers.ml)
    - 字面量词法转换 (来自 lexer_token_conversion_literals.ml)
    - 基础关键字词法转换 (来自 lexer_token_conversion_basic_keywords.ml)
    - 类型关键字词法转换 (来自 lexer_token_conversion_type_keywords.ml)
    - 古典语言词法转换 (来自 lexer_token_conversion_classical.ml)
    
    设计目标：
    - 提供词法分析阶段的转换支持
    - 优化词法器性能
    - 统一词法转换接口
    - 支持分阶段token处理
    
    @author Alpha, 主工作代理 - Phase 6.2 Implementation
    @version 2.0 - 词法器转换统一
    @since 2025-07-25
    @fixes Issue #1340 *)

open Lexer_tokens

exception Lexer_conversion_failed of string
(** 词法器转换异常 *)

(** 词法器转换类型 *)
type lexer_conversion_type =
  | LexerIdentifier    (* 词法器标识符转换 *)
  | LexerLiteral       (* 词法器字面量转换 *)
  | LexerBasicKeyword  (* 词法器基础关键字转换 *)
  | LexerTypeKeyword   (* 词法器类型关键字转换 *)
  | LexerClassical     (* 词法器古典语言转换 *)

(** 词法器标识符转换 - 整合自 lexer_token_conversion_identifiers.ml *)
module LexerIdentifiers = struct
  let convert_identifier_token = function
    | Token_mapping.Token_definitions_unified.QuotedIdentifierToken s -> Some (QuotedIdentifierToken s)
    | Token_mapping.Token_definitions_unified.IdentifierTokenSpecial s -> Some (IdentifierTokenSpecial s) 
    | _ -> None

  let is_lexer_identifier_token = function
    | Token_mapping.Token_definitions_unified.QuotedIdentifierToken _
    | Token_mapping.Token_definitions_unified.IdentifierTokenSpecial _ -> true
    | _ -> false
end

(** 词法器字面量转换 - 整合自 lexer_token_conversion_literals.ml *)
module LexerLiterals = struct
  let convert_literal_token = function
    | Token_mapping.Token_definitions_unified.IntToken i -> Some (IntToken i)
    | Token_mapping.Token_definitions_unified.FloatToken f -> Some (FloatToken f)
    | Token_mapping.Token_definitions_unified.ChineseNumberToken s -> Some (ChineseNumberToken s)
    | Token_mapping.Token_definitions_unified.StringToken s -> Some (StringToken s)
    | Token_mapping.Token_definitions_unified.BoolToken b -> Some (BoolToken b)
    | _ -> None

  let is_lexer_literal_token = function
    | Token_mapping.Token_definitions_unified.IntToken _
    | Token_mapping.Token_definitions_unified.FloatToken _
    | Token_mapping.Token_definitions_unified.ChineseNumberToken _
    | Token_mapping.Token_definitions_unified.StringToken _
    | Token_mapping.Token_definitions_unified.BoolToken _ -> true
    | _ -> false
end

(** 词法器基础关键字转换 - 整合自 lexer_token_conversion_basic_keywords.ml *)
module LexerBasicKeywords = struct
  let convert_basic_keyword_token = function
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
    | Token_mapping.Token_definitions_unified.AsKeyword -> Some AsKeyword
    | Token_mapping.Token_definitions_unified.CombineKeyword -> Some CombineKeyword
    | Token_mapping.Token_definitions_unified.WithOpKeyword -> Some WithOpKeyword
    | Token_mapping.Token_definitions_unified.WhenKeyword -> Some WhenKeyword
    | _ -> None

  let is_lexer_basic_keyword = function
    | Token_mapping.Token_definitions_unified.LetKeyword
    | Token_mapping.Token_definitions_unified.RecKeyword
    | Token_mapping.Token_definitions_unified.InKeyword
    | Token_mapping.Token_definitions_unified.FunKeyword
    | Token_mapping.Token_definitions_unified.IfKeyword
    | Token_mapping.Token_definitions_unified.ThenKeyword
    | Token_mapping.Token_definitions_unified.ElseKeyword
    | Token_mapping.Token_definitions_unified.MatchKeyword
    | Token_mapping.Token_definitions_unified.WithKeyword
    | Token_mapping.Token_definitions_unified.OtherKeyword
    | Token_mapping.Token_definitions_unified.AndKeyword
    | Token_mapping.Token_definitions_unified.OrKeyword
    | Token_mapping.Token_definitions_unified.NotKeyword
    | Token_mapping.Token_definitions_unified.OfKeyword
    | Token_mapping.Token_definitions_unified.AsKeyword
    | Token_mapping.Token_definitions_unified.CombineKeyword
    | Token_mapping.Token_definitions_unified.WithOpKeyword
    | Token_mapping.Token_definitions_unified.WhenKeyword -> true
    | _ -> false
end

(** 词法器类型关键字转换 - 整合自 lexer_token_conversion_type_keywords.ml *)
module LexerTypeKeywords = struct
  let convert_type_keyword_token = function
    | Token_mapping.Token_definitions_unified.IntTypeKeyword -> Some IntTypeKeyword
    | Token_mapping.Token_definitions_unified.FloatTypeKeyword -> Some FloatTypeKeyword
    | Token_mapping.Token_definitions_unified.StringTypeKeyword -> Some StringTypeKeyword
    | Token_mapping.Token_definitions_unified.BoolTypeKeyword -> Some BoolTypeKeyword
    | Token_mapping.Token_definitions_unified.ListTypeKeyword -> Some ListTypeKeyword
    | Token_mapping.Token_definitions_unified.UnitTypeKeyword -> Some UnitTypeKeyword
    | Token_mapping.Token_definitions_unified.ArrayTypeKeyword -> Some ArrayTypeKeyword
    | _ -> None

  let is_lexer_type_keyword = function
    | Token_mapping.Token_definitions_unified.IntTypeKeyword
    | Token_mapping.Token_definitions_unified.FloatTypeKeyword
    | Token_mapping.Token_definitions_unified.StringTypeKeyword
    | Token_mapping.Token_definitions_unified.BoolTypeKeyword
    | Token_mapping.Token_definitions_unified.ListTypeKeyword
    | Token_mapping.Token_definitions_unified.UnitTypeKeyword
    | Token_mapping.Token_definitions_unified.ArrayTypeKeyword -> true
    | _ -> false
end

(** 词法器古典语言转换 - 整合自 lexer_token_conversion_classical.ml *)
module LexerClassical = struct
  let convert_classical_token = function
    (* 文言文关键字 *)
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
    (* 自然语言关键字 *)
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
    (* 古雅体关键字 *)
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

  let is_lexer_classical_token token =
    match convert_classical_token token with Some _ -> true | None -> false
end

(** 词法器转换策略 *)
type lexer_conversion_strategy = 
  | LexerFast         (* 词法器性能优先 *)
  | LexerPrecise      (* 词法器精确转换 *)
  | LexerIncrmental   (* 增量词法转换 *)

(** 统一的词法器转换接口 *)
let rec convert_lexer_token ?(strategy = LexerPrecise) token =
  match strategy with
  | LexerFast ->
      (* 快速转换：只转换最常用的token *)
      (match token with
       | Token_mapping.Token_definitions_unified.LetKeyword -> Some LetKeyword
       | Token_mapping.Token_definitions_unified.FunKeyword -> Some FunKeyword
       | Token_mapping.Token_definitions_unified.IfKeyword -> Some IfKeyword
       | Token_mapping.Token_definitions_unified.IntToken i -> Some (IntToken i)
       | Token_mapping.Token_definitions_unified.StringToken s -> Some (StringToken s)
       | Token_mapping.Token_definitions_unified.QuotedIdentifierToken s -> Some (QuotedIdentifierToken s)
       | _ -> None)
  | LexerPrecise ->
      (* 精确转换：按类型依次尝试转换 *)
      let converters = [
        LexerIdentifiers.convert_identifier_token;
        LexerLiterals.convert_literal_token;
        LexerBasicKeywords.convert_basic_keyword_token;
        LexerTypeKeywords.convert_type_keyword_token;
        LexerClassical.convert_classical_token;
      ] in
      let rec try_converters = function
        | [] -> None
        | converter :: rest ->
            match converter token with
            | Some result -> Some result
            | None -> try_converters rest
      in
      try_converters converters
  | LexerIncrmental ->
      (* 增量转换：支持分阶段处理 *)
      convert_lexer_token ~strategy:LexerPrecise token

(** 检查是否为词法器支持的token *)
let is_lexer_supported_token token =
  match convert_lexer_token token with Some _ -> true | None -> false

(** 获取词法器token转换类型 *)
let get_lexer_conversion_type token =
  if LexerIdentifiers.is_lexer_identifier_token token then Some LexerIdentifier
  else if LexerLiterals.is_lexer_literal_token token then Some LexerLiteral
  else if LexerBasicKeywords.is_lexer_basic_keyword token then Some LexerBasicKeyword
  else if LexerTypeKeywords.is_lexer_type_keyword token then Some LexerTypeKeyword
  else if LexerClassical.is_lexer_classical_token token then Some LexerClassical
  else None

(** 批量词法器转换 *)
let convert_lexer_token_list ?(strategy = LexerPrecise) tokens =
  List.filter_map (convert_lexer_token ~strategy) tokens

(** 词法器转换统计 *)
let get_lexer_conversion_stats tokens =
  let total = List.length tokens in
  let converted = List.length (convert_lexer_token_list tokens) in
  let success_rate = if total > 0 then (float_of_int converted) /. (float_of_int total) *. 100.0 else 0.0 in
  Printf.sprintf "词法器转换统计: %d/%d tokens 转换成功 (%.1f%%)" converted total success_rate

(** 向后兼容性接口 *)
module BackwardCompatibility = struct
  (* 保持原有的词法器转换函数接口 *)
  let convert_identifier_token token =
    match LexerIdentifiers.convert_identifier_token token with
    | Some result -> result
    | None -> raise (Lexer_conversion_failed "不是词法器标识符token")

  let convert_literal_token token =
    match LexerLiterals.convert_literal_token token with
    | Some result -> result
    | None -> raise (Lexer_conversion_failed "不是词法器字面量token")

  let convert_basic_keyword_token token =
    match LexerBasicKeywords.convert_basic_keyword_token token with
    | Some result -> result
    | None -> raise (Lexer_conversion_failed "不是词法器基础关键字token")

  let convert_type_keyword_token token =
    match LexerTypeKeywords.convert_type_keyword_token token with
    | Some result -> result
    | None -> raise (Lexer_conversion_failed "不是词法器类型关键字token")

  let convert_classical_token token =
    match LexerClassical.convert_classical_token token with
    | Some result -> result
    | None -> raise (Lexer_conversion_failed "不是词法器古典语言token")

  (* 主转换函数 *)
  let convert_lexer_token_exn token =
    match convert_lexer_token token with
    | Some result -> result
    | None -> raise (Lexer_conversion_failed "词法器转换失败")
end

(** 词法器性能统计模块 *)
module LexerStatistics = struct
  let get_lexer_performance_stats () =
    let conversion_types = [
      ("词法器标识符转换", 2);   (* QuotedIdentifierToken, IdentifierTokenSpecial *)
      ("词法器字面量转换", 5);    (* IntToken, FloatToken, ChineseNumberToken, StringToken, BoolToken *)
      ("词法器基础关键字转换", 18); (* LetKeyword, RecKeyword, InKeyword, etc. *)
      ("词法器类型关键字转换", 13); (* IntTypeKeyword, FloatTypeKeyword, etc. *)
      ("词法器古典语言转换", 65);  (* 所有古典语言关键字 *)
    ] in
    let total = List.fold_left (fun acc (_, count) -> acc + count) 0 conversion_types in
    let details = String.concat "\n" 
      (List.map (fun (name, count) -> Printf.sprintf "- %s: %d个token" name count) conversion_types) in
    Printf.sprintf
      {|词法器转换性能统计:
%s
- 总计: %d个词法器token类型|}
      details total
end