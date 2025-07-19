(** 统一Token转换接口模块 - 重构后的模块化设计替代144行巨型函数 *)

(** 主要的token转换函数，将原来的144行巨型函数重构为模块化的设计 *)
let convert_token = function
  (* 字面量tokens - 使用Lexer_token_conversion_literals模块 *)
  | ( Token_mapping.Token_definitions_unified.IntToken _
    | Token_mapping.Token_definitions_unified.FloatToken _
    | Token_mapping.Token_definitions_unified.ChineseNumberToken _
    | Token_mapping.Token_definitions_unified.StringToken _
    | Token_mapping.Token_definitions_unified.BoolToken _ ) as token ->
      Lexer_token_conversion_literals.convert_literal_token token
  (* 标识符tokens - 使用Lexer_token_conversion_identifiers模块 *)
  | ( Token_mapping.Token_definitions_unified.QuotedIdentifierToken _
    | Token_mapping.Token_definitions_unified.IdentifierTokenSpecial _ ) as token ->
      Lexer_token_conversion_identifiers.convert_identifier_token token
  (* 基础关键字tokens - 使用Lexer_token_conversion_basic_keywords模块 *)
  | ( Token_mapping.Token_definitions_unified.LetKeyword
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
    | Token_mapping.Token_definitions_unified.WhenKeyword
    | Token_mapping.Token_definitions_unified.WithDefaultKeyword
    | Token_mapping.Token_definitions_unified.ExceptionKeyword
    | Token_mapping.Token_definitions_unified.RaiseKeyword
    | Token_mapping.Token_definitions_unified.TryKeyword
    | Token_mapping.Token_definitions_unified.CatchKeyword
    | Token_mapping.Token_definitions_unified.FinallyKeyword
    | Token_mapping.Token_definitions_unified.ModuleKeyword
    | Token_mapping.Token_definitions_unified.ModuleTypeKeyword
    | Token_mapping.Token_definitions_unified.RefKeyword
    | Token_mapping.Token_definitions_unified.IncludeKeyword
    | Token_mapping.Token_definitions_unified.FunctorKeyword
    | Token_mapping.Token_definitions_unified.SigKeyword
    | Token_mapping.Token_definitions_unified.EndKeyword
    | Token_mapping.Token_definitions_unified.MacroKeyword
    | Token_mapping.Token_definitions_unified.ExpandKeyword ) as token ->
      Lexer_token_conversion_basic_keywords.convert_basic_keyword_token token
  (* 类型关键字tokens - 使用Lexer_token_conversion_type_keywords模块 *)
  | ( Token_mapping.Token_definitions_unified.TypeKeyword
    | Token_mapping.Token_definitions_unified.PrivateKeyword
    | Token_mapping.Token_definitions_unified.InputKeyword
    | Token_mapping.Token_definitions_unified.OutputKeyword
    | Token_mapping.Token_definitions_unified.IntTypeKeyword
    | Token_mapping.Token_definitions_unified.FloatTypeKeyword
    | Token_mapping.Token_definitions_unified.StringTypeKeyword
    | Token_mapping.Token_definitions_unified.BoolTypeKeyword
    | Token_mapping.Token_definitions_unified.UnitTypeKeyword
    | Token_mapping.Token_definitions_unified.ListTypeKeyword
    | Token_mapping.Token_definitions_unified.ArrayTypeKeyword
    | Token_mapping.Token_definitions_unified.VariantKeyword
    | Token_mapping.Token_definitions_unified.TagKeyword ) as token ->
      Lexer_token_conversion_type_keywords.convert_type_keyword_token token
  (* 古典语言tokens - 使用Lexer_token_conversion_classical模块 *)
  | _ as token -> Lexer_token_conversion_classical.convert_classical_token token
