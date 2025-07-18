(** 统一Token转换接口模块 - 重构后的模块化设计替代144行巨型函数 *)

(** 主要的token转换函数，将原来的144行巨型函数重构为模块化的设计 *)
let convert_token = function
  (* 字面量tokens - 使用Lexer_token_conversion_literals模块 *)
  | ( Token_mapping.Token_definitions.IntToken _ | Token_mapping.Token_definitions.FloatToken _
    | Token_mapping.Token_definitions.ChineseNumberToken _
    | Token_mapping.Token_definitions.StringToken _ | Token_mapping.Token_definitions.BoolToken _ )
    as token ->
      Lexer_token_conversion_literals.convert_literal_token token
  (* 标识符tokens - 使用Lexer_token_conversion_identifiers模块 *)
  | ( Token_mapping.Token_definitions.QuotedIdentifierToken _
    | Token_mapping.Token_definitions.IdentifierTokenSpecial _ ) as token ->
      Lexer_token_conversion_identifiers.convert_identifier_token token
  (* 基础关键字tokens - 使用Lexer_token_conversion_basic_keywords模块 *)
  | ( Token_mapping.Token_definitions.LetKeyword | Token_mapping.Token_definitions.RecKeyword
    | Token_mapping.Token_definitions.InKeyword | Token_mapping.Token_definitions.FunKeyword
    | Token_mapping.Token_definitions.IfKeyword | Token_mapping.Token_definitions.ThenKeyword
    | Token_mapping.Token_definitions.ElseKeyword | Token_mapping.Token_definitions.MatchKeyword
    | Token_mapping.Token_definitions.WithKeyword | Token_mapping.Token_definitions.OtherKeyword
    | Token_mapping.Token_definitions.AndKeyword | Token_mapping.Token_definitions.OrKeyword
    | Token_mapping.Token_definitions.NotKeyword | Token_mapping.Token_definitions.OfKeyword
    | Token_mapping.Token_definitions.AsKeyword | Token_mapping.Token_definitions.CombineKeyword
    | Token_mapping.Token_definitions.WithOpKeyword | Token_mapping.Token_definitions.WhenKeyword
    | Token_mapping.Token_definitions.WithDefaultKeyword
    | Token_mapping.Token_definitions.ExceptionKeyword
    | Token_mapping.Token_definitions.RaiseKeyword | Token_mapping.Token_definitions.TryKeyword
    | Token_mapping.Token_definitions.CatchKeyword | Token_mapping.Token_definitions.FinallyKeyword
    | Token_mapping.Token_definitions.ModuleKeyword
    | Token_mapping.Token_definitions.ModuleTypeKeyword | Token_mapping.Token_definitions.RefKeyword
    | Token_mapping.Token_definitions.IncludeKeyword
    | Token_mapping.Token_definitions.FunctorKeyword | Token_mapping.Token_definitions.SigKeyword
    | Token_mapping.Token_definitions.EndKeyword | Token_mapping.Token_definitions.MacroKeyword
    | Token_mapping.Token_definitions.ExpandKeyword ) as token ->
      Lexer_token_conversion_basic_keywords.convert_basic_keyword_token token
  (* 类型关键字tokens - 使用Lexer_token_conversion_type_keywords模块 *)
  | ( Token_mapping.Token_definitions.TypeKeyword | Token_mapping.Token_definitions.PrivateKeyword
    | Token_mapping.Token_definitions.InputKeyword | Token_mapping.Token_definitions.OutputKeyword
    | Token_mapping.Token_definitions.IntTypeKeyword
    | Token_mapping.Token_definitions.FloatTypeKeyword
    | Token_mapping.Token_definitions.StringTypeKeyword
    | Token_mapping.Token_definitions.BoolTypeKeyword
    | Token_mapping.Token_definitions.UnitTypeKeyword
    | Token_mapping.Token_definitions.ListTypeKeyword
    | Token_mapping.Token_definitions.ArrayTypeKeyword
    | Token_mapping.Token_definitions.VariantKeyword | Token_mapping.Token_definitions.TagKeyword )
    as token ->
      Lexer_token_conversion_type_keywords.convert_type_keyword_token token
  (* 古典语言tokens - 使用Lexer_token_conversion_classical模块 *)
  | _ as token -> Lexer_token_conversion_classical.convert_classical_token token
