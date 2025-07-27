(** 词法器Token转换器 - 兼容性桥接模块
    
    为 lexer_keywords.ml 提供向后兼容性接口
    将 Token_definitions_unified.token 转换为 Lexer_tokens.token
    
    @author Alpha, 主工作代理 - Phase 6.2 兼容性桥接修复
    @version 2.1 - 类型转换修复  
    @since 2025-07-25
    @fixes Issue #1340 *)

open Lexer_tokens

(** 引入统一错误处理系统 *)
module TokenConversionError = struct
  type error = UnsupportedTokenType of string

  let error_to_string = function UnsupportedTokenType token_info -> "不支持的令牌类型: " ^ token_info

  let create_error error = error_to_string error
end

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

(** 主转换函数 - 按优先级顺序尝试不同类型的令牌转换
    
    转换优先级顺序 (从高到低):
    1. 字面量令牌 (数字、字符串等基础类型)
    2. 基础关键词 (核心语言结构关键词)  
    3. 语义关键词 (语义相关的高级关键词)
    4. 模块关键词 (模块系统相关关键词)
    5. 类型关键词 (类型系统相关关键词)
    6. 文言关键词 (古典文言文语法关键词)
    7. 古代关键词 (古代汉语特殊关键词)
    8. 自然关键词 (自然语言处理关键词)
    
    采用优先级策略确保最常用和最基础的令牌类型优先匹配,
    提高转换效率并保持语义一致性。每个转换器返回 Some result 
    表示成功转换，返回 None 则尝试下一个转换器。
    
    @param token 待转换的统一令牌定义
    @return Result类型: Ok(转换后的词法分析器令牌) 或 Error(错误信息)
    @updated Phase 5.1 - 错误处理现代化：替换failwith为Result类型
 *)
let convert_token_safe (token : Token_mapping.Token_definitions_unified.token) :
    (Lexer_tokens.token, string) result =
  (* 优先级1: 尝试字面量转换 (数字、字符串、布尔值等) *)
  match convert_literal_token token with
  | Some result -> Ok result
  | None -> (
      (* 优先级2: 尝试基础关键词转换 (if, let, fun等核心语法) *)
      match convert_basic_keyword_token token with
      | Some result -> Ok result
      | None -> (
          (* 优先级3: 尝试语义关键词转换 (高级语义结构) *)
          match convert_semantic_keyword_token token with
          | Some result -> Ok result
          | None -> (
              (* 优先级4: 尝试模块关键词转换 (module, open等) *)
              match convert_module_keyword_token token with
              | Some result -> Ok result
              | None -> (
                  (* 优先级5: 尝试类型关键词转换 (type, val等) *)
                  match convert_type_keyword_token token with
                  | Some result -> Ok result
                  | None -> (
                      (* 优先级6: 尝试文言关键词转换 (古典文言语法) *)
                      match convert_wenyan_keyword_token token with
                      | Some result -> Ok result
                      | None -> (
                          (* 优先级7: 尝试古代关键词转换 (古汉语特殊词汇) *)
                          match convert_ancient_keyword_token token with
                          | Some result -> Ok result
                          | None -> (
                              (* 优先级8: 尝试自然关键词转换 (自然语言处理) *)
                              match convert_natural_keyword_token token with
                              | Some result -> Ok result
                              | None ->
                                  (* 所有转换器都无法处理此令牌，返回详细错误 *)
                                  let token_debug_info = "Token类型未知" in
                                  Error
                                    (TokenConversionError.create_error
                                       (TokenConversionError.UnsupportedTokenType token_debug_info))
                              )))))))

(** 向后兼容包装器 - 保持原有API不变

    此函数保持与原有代码的兼容性，内部使用新的安全转换函数 但保持原有的异常抛出行为。建议新代码使用 convert_token_safe。

    @param token 待转换的统一令牌定义
    @return 转换后的词法分析器令牌
    @raise Failure 当转换失败时 (保持向后兼容)
    @deprecated 建议使用 convert_token_safe 获得更好的错误处理 *)
let convert_token (token : Token_mapping.Token_definitions_unified.token) : Lexer_tokens.token =
  match convert_token_safe token with Ok result -> result | Error error_msg -> failwith error_msg
