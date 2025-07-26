(** 词法器Token转换器 - 兼容性桥接模块
    
    为 lexer_keywords.ml 提供向后兼容性接口
    将 Token_definitions_unified.token 转换为 Lexer_tokens.token
    
    @author Alpha, 主工作代理 - Phase 6.2 兼容性桥接修复
    @version 2.1 - 类型转换修复  
    @since 2025-07-25
    @fixes Issue #1340 *)

open Lexer_tokens

(** 字面量token转换辅助函数 *)
let convert_literal_token (token : Token_mapping.Token_definitions_unified.token) :
    Lexer_tokens.token option =
  match token with
  | Token_mapping.Token_definitions_unified.IntToken i -> Some (IntToken i)
  | Token_mapping.Token_definitions_unified.FloatToken f -> Some (FloatToken f)
  | Token_mapping.Token_definitions_unified.ChineseNumberToken s -> Some (ChineseNumberToken s)
  | Token_mapping.Token_definitions_unified.StringToken s -> Some (StringToken s)
  | Token_mapping.Token_definitions_unified.BoolToken b -> Some (BoolToken b)
  | Token_mapping.Token_definitions_unified.QuotedIdentifierToken s ->
      Some (QuotedIdentifierToken s)
  | Token_mapping.Token_definitions_unified.IdentifierTokenSpecial s ->
      Some (IdentifierTokenSpecial s)
  | _ -> None

(** 基础关键字token转换辅助函数 *)
let convert_basic_keyword_token (token : Token_mapping.Token_definitions_unified.token) :
    Lexer_tokens.token option =
  match token with
  | Token_mapping.Token_definitions_unified.LetKeyword -> Some LetKeyword
  | Token_mapping.Token_definitions_unified.RecKeyword -> Some RecKeyword
  | Token_mapping.Token_definitions_unified.InKeyword -> Some InKeyword
  | Token_mapping.Token_definitions_unified.FunKeyword -> Some FunKeyword
  | Token_mapping.Token_definitions_unified.ParamKeyword -> Some ParamKeyword
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
  | Token_mapping.Token_definitions_unified.TrueKeyword -> Some TrueKeyword
  | Token_mapping.Token_definitions_unified.FalseKeyword -> Some FalseKeyword
  | _ -> None

(** 语义关键字token转换辅助函数 *)
let convert_semantic_keyword_token (token : Token_mapping.Token_definitions_unified.token) :
    Lexer_tokens.token option =
  match token with
  | Token_mapping.Token_definitions_unified.AsKeyword -> Some AsKeyword
  | Token_mapping.Token_definitions_unified.CombineKeyword -> Some CombineKeyword
  | Token_mapping.Token_definitions_unified.WithOpKeyword -> Some WithOpKeyword
  | Token_mapping.Token_definitions_unified.WhenKeyword -> Some WhenKeyword
  | Token_mapping.Token_definitions_unified.WithDefaultKeyword -> Some WithDefaultKeyword
  | Token_mapping.Token_definitions_unified.ExceptionKeyword -> Some ExceptionKeyword
  | Token_mapping.Token_definitions_unified.RaiseKeyword -> Some RaiseKeyword
  | Token_mapping.Token_definitions_unified.TryKeyword -> Some TryKeyword
  | Token_mapping.Token_definitions_unified.CatchKeyword -> Some CatchKeyword
  | Token_mapping.Token_definitions_unified.FinallyKeyword -> Some FinallyKeyword
  | _ -> None

(** 模块关键字token转换辅助函数 *)
let convert_module_keyword_token (token : Token_mapping.Token_definitions_unified.token) :
    Lexer_tokens.token option =
  match token with
  | Token_mapping.Token_definitions_unified.ModuleKeyword -> Some ModuleKeyword
  | Token_mapping.Token_definitions_unified.ModuleTypeKeyword -> Some ModuleTypeKeyword
  | Token_mapping.Token_definitions_unified.RefKeyword -> Some RefKeyword
  | Token_mapping.Token_definitions_unified.IncludeKeyword -> Some IncludeKeyword
  | Token_mapping.Token_definitions_unified.FunctorKeyword -> Some FunctorKeyword
  | Token_mapping.Token_definitions_unified.SigKeyword -> Some SigKeyword
  | Token_mapping.Token_definitions_unified.EndKeyword -> Some EndKeyword
  | Token_mapping.Token_definitions_unified.MacroKeyword -> Some MacroKeyword
  | Token_mapping.Token_definitions_unified.ExpandKeyword -> Some ExpandKeyword
  | _ -> None

(** 类型关键字token转换辅助函数 *)
let convert_type_keyword_token (token : Token_mapping.Token_definitions_unified.token) :
    Lexer_tokens.token option =
  match token with
  | Token_mapping.Token_definitions_unified.TypeKeyword -> Some TypeKeyword
  | Token_mapping.Token_definitions_unified.PrivateKeyword -> Some PrivateKeyword
  | Token_mapping.Token_definitions_unified.InputKeyword -> Some InputKeyword
  | Token_mapping.Token_definitions_unified.OutputKeyword -> Some OutputKeyword
  | Token_mapping.Token_definitions_unified.IntTypeKeyword -> Some IntTypeKeyword
  | Token_mapping.Token_definitions_unified.FloatTypeKeyword -> Some FloatTypeKeyword
  | Token_mapping.Token_definitions_unified.StringTypeKeyword -> Some StringTypeKeyword
  | Token_mapping.Token_definitions_unified.BoolTypeKeyword -> Some BoolTypeKeyword
  | Token_mapping.Token_definitions_unified.UnitTypeKeyword -> Some UnitTypeKeyword
  | Token_mapping.Token_definitions_unified.ListTypeKeyword -> Some ListTypeKeyword
  | Token_mapping.Token_definitions_unified.ArrayTypeKeyword -> Some ArrayTypeKeyword
  | Token_mapping.Token_definitions_unified.VariantKeyword -> Some VariantKeyword
  | Token_mapping.Token_definitions_unified.TagKeyword -> Some TagKeyword
  | _ -> None

(** 文言文关键字token转换辅助函数 *)
let convert_wenyan_keyword_token (token : Token_mapping.Token_definitions_unified.token) :
    Lexer_tokens.token option =
  match token with
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

(** 古雅体关键字token转换辅助函数 *)
let convert_ancient_keyword_token (token : Token_mapping.Token_definitions_unified.token) :
    Lexer_tokens.token option =
  match token with
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
  | Token_mapping.Token_definitions_unified.AncientHasHeadTailKeyword ->
      Some AncientHasHeadTailKeyword
  | Token_mapping.Token_definitions_unified.AncientHeadNameKeyword -> Some AncientHeadNameKeyword
  | Token_mapping.Token_definitions_unified.AncientTailNameKeyword -> Some AncientTailNameKeyword
  | Token_mapping.Token_definitions_unified.AncientThusAnswerKeyword ->
      Some AncientThusAnswerKeyword
  | Token_mapping.Token_definitions_unified.AncientAddToKeyword -> Some AncientAddToKeyword
  | Token_mapping.Token_definitions_unified.AncientObserveEndKeyword ->
      Some AncientObserveEndKeyword
  | Token_mapping.Token_definitions_unified.AncientBeginKeyword -> Some AncientBeginKeyword
  | Token_mapping.Token_definitions_unified.AncientEndCompleteKeyword ->
      Some AncientEndCompleteKeyword
  | Token_mapping.Token_definitions_unified.AncientIsKeyword -> Some AncientIsKeyword
  | Token_mapping.Token_definitions_unified.AncientArrowKeyword -> Some AncientArrowKeyword
  | Token_mapping.Token_definitions_unified.AncientWhenKeyword -> Some AncientWhenKeyword
  | Token_mapping.Token_definitions_unified.AncientCommaKeyword -> Some AncientCommaKeyword
  | Token_mapping.Token_definitions_unified.AfterThatKeyword -> Some AfterThatKeyword
  | Token_mapping.Token_definitions_unified.AncientRecordStartKeyword ->
      Some AncientRecordStartKeyword
  | Token_mapping.Token_definitions_unified.AncientRecordEndKeyword -> Some AncientRecordEndKeyword
  | Token_mapping.Token_definitions_unified.AncientRecordEmptyKeyword ->
      Some AncientRecordEmptyKeyword
  | Token_mapping.Token_definitions_unified.AncientRecordUpdateKeyword ->
      Some AncientRecordUpdateKeyword
  | Token_mapping.Token_definitions_unified.AncientRecordFinishKeyword ->
      Some AncientRecordFinishKeyword
  | _ -> None

(** 自然语言关键字token转换辅助函数 *)
let convert_natural_keyword_token (token : Token_mapping.Token_definitions_unified.token) :
    Lexer_tokens.token option =
  match token with
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

(** 主转换函数 - 使用辅助函数进行分类转换 *)
let convert_token (token : Token_mapping.Token_definitions_unified.token) : Lexer_tokens.token =
  match convert_literal_token token with
  | Some result -> result
  | None -> (
      match convert_basic_keyword_token token with
      | Some result -> result
      | None -> (
          match convert_semantic_keyword_token token with
          | Some result -> result
          | None -> (
              match convert_module_keyword_token token with
              | Some result -> result
              | None -> (
                  match convert_type_keyword_token token with
                  | Some result -> result
                  | None -> (
                      match convert_wenyan_keyword_token token with
                      | Some result -> result
                      | None -> (
                          match convert_ancient_keyword_token token with
                          | Some result -> result
                          | None -> (
                              match convert_natural_keyword_token token with
                              | Some result -> result
                              | None ->
                                  failwith "Unhandled token conversion: unsupported token type")))))
          ))
