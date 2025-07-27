(** Token兼容性桥接模块 - 技术债务清理 Issue #1375

    为现有代码提供向后兼容性支持，允许渐进式迁移到统一Token系统。 支持与旧Token模块的双向转换。

    Author: Beta, 代码审查专员 Date: 2025-07-26 *)

open Token_unified

exception Incompatible_token of string
(** 转换异常 *)

exception Legacy_conversion_failed of string

(** 将统一Token转换为Lexer_tokens.token *)
module ToLexerToken = struct
  let convert_literals = function
    | IntToken i -> Ok (Lexer_tokens.IntToken i)
    | FloatToken f -> Ok (Lexer_tokens.FloatToken f)
    | StringToken s -> Ok (Lexer_tokens.StringToken s)
    | BoolToken b -> Ok (Lexer_tokens.BoolToken b)
    | ChineseNumberToken s -> Ok (Lexer_tokens.ChineseNumberToken s)
    | UnitToken -> Ok (Lexer_tokens.IntToken 0) (* 临时映射 *)
    | _ -> Error "Not a literal token"

  let convert_identifiers = function
    | IdentifierToken s -> Ok (Lexer_tokens.IdentifierTokenSpecial s)
    | QuotedIdentifierToken s -> Ok (Lexer_tokens.QuotedIdentifierToken s)
    | ConstructorToken s -> Ok (Lexer_tokens.IdentifierTokenSpecial s)
    | ModuleNameToken s -> Ok (Lexer_tokens.IdentifierTokenSpecial s)
    | TypeNameToken s -> Ok (Lexer_tokens.IdentifierTokenSpecial s)
    | _ -> Error "Not an identifier token"

  let convert_basic_keywords = function
    | BasicKeyword `Let -> Ok Lexer_tokens.LetKeyword
    | BasicKeyword `Fun -> Ok Lexer_tokens.FunKeyword
    | BasicKeyword `In -> Ok Lexer_tokens.InKeyword
    | BasicKeyword `Rec -> Ok Lexer_tokens.RecKeyword
    | BasicKeyword `Type -> Ok Lexer_tokens.TypeKeyword
    | BasicKeyword `Private -> Ok Lexer_tokens.PrivateKeyword
    | BasicKeyword `And -> Ok Lexer_tokens.AndKeyword
    | BasicKeyword `As -> Ok Lexer_tokens.AsKeyword
    | _ -> Error "Not a basic keyword"

  let convert_type_keywords = function
    | TypeKeyword `Int -> Ok Lexer_tokens.IntTypeKeyword
    | TypeKeyword `Float -> Ok Lexer_tokens.FloatTypeKeyword
    | TypeKeyword `String -> Ok Lexer_tokens.StringTypeKeyword
    | TypeKeyword `Bool -> Ok Lexer_tokens.BoolTypeKeyword
    | TypeKeyword `Unit -> Ok Lexer_tokens.UnitTypeKeyword
    | TypeKeyword `List -> Ok Lexer_tokens.ListTypeKeyword
    | TypeKeyword `Array -> Ok Lexer_tokens.ArrayTypeKeyword
    | TypeKeyword `Option -> Ok (Lexer_tokens.IdentifierTokenSpecial "option")
    | TypeKeyword `Ref -> Ok (Lexer_tokens.IdentifierTokenSpecial "ref")
    | _ -> Error "Not a type keyword"

  let convert_control_keywords = function
    | ControlKeyword `If -> Ok Lexer_tokens.IfKeyword
    | ControlKeyword `Then -> Ok Lexer_tokens.ThenKeyword
    | ControlKeyword `Else -> Ok Lexer_tokens.ElseKeyword
    | ControlKeyword `Match -> Ok Lexer_tokens.MatchKeyword
    | ControlKeyword `With -> Ok Lexer_tokens.WithKeyword
    | ControlKeyword `When -> Ok Lexer_tokens.WhenKeyword
    | ControlKeyword `Try -> Ok Lexer_tokens.TryKeyword
    | ControlKeyword `Catch -> Ok Lexer_tokens.CatchKeyword
    | ControlKeyword `Finally -> Ok Lexer_tokens.FinallyKeyword
    | ControlKeyword `Raise -> Ok Lexer_tokens.RaiseKeyword
    | _ -> Error "Not a control keyword"

  let convert_classical_keywords = function
    | ClassicalKeyword `Have -> Ok Lexer_tokens.HaveKeyword
    | ClassicalKeyword `One -> Ok Lexer_tokens.OneKeyword
    | ClassicalKeyword `Name -> Ok Lexer_tokens.NameKeyword
    | ClassicalKeyword `Set -> Ok Lexer_tokens.SetKeyword
    | ClassicalKeyword `Also -> Ok Lexer_tokens.AlsoKeyword
    | ClassicalKeyword `Call -> Ok Lexer_tokens.CallKeyword
    | ClassicalKeyword `ThenGet -> Ok Lexer_tokens.ThenGetKeyword
    | ClassicalKeyword `AlsoHave -> Ok Lexer_tokens.AlsoKeyword (* 映射到已有Token *)
    | _ -> Error "Not a classical keyword"

  let convert_operators = function
    | OperatorToken `Plus -> Ok Lexer_tokens.Plus
    | OperatorToken `Minus -> Ok Lexer_tokens.Minus
    | OperatorToken `Multiply -> Ok Lexer_tokens.Multiply
    | OperatorToken `Divide -> Ok Lexer_tokens.Divide
    | OperatorToken `Modulo -> Ok Lexer_tokens.Modulo
    | OperatorToken `Power -> Ok (Lexer_tokens.IdentifierTokenSpecial "**")
    | OperatorToken `Equal -> Ok Lexer_tokens.Equal
    | OperatorToken `NotEqual -> Ok Lexer_tokens.NotEqual
    | OperatorToken `LessThan -> Ok Lexer_tokens.Less
    | OperatorToken `LessEqual -> Ok Lexer_tokens.LessEqual
    | OperatorToken `GreaterThan -> Ok Lexer_tokens.Greater
    | OperatorToken `GreaterEqual -> Ok Lexer_tokens.GreaterEqual
    | OperatorToken `LogicalAnd -> Ok Lexer_tokens.AndKeyword
    | OperatorToken `LogicalOr -> Ok Lexer_tokens.OrKeyword
    | OperatorToken `LogicalNot -> Ok Lexer_tokens.NotKeyword
    | OperatorToken `Assign -> Ok Lexer_tokens.Assign
    | OperatorToken `Dereference -> Ok Lexer_tokens.Bang
    | OperatorToken `Reference -> Ok Lexer_tokens.RefKeyword
    | OperatorToken `Arrow -> Ok Lexer_tokens.Arrow
    | OperatorToken `DoubleArrow -> Ok Lexer_tokens.DoubleArrow
    | OperatorToken `PipeForward -> Ok (Lexer_tokens.IdentifierTokenSpecial "|>")
    | OperatorToken `PipeBackward -> Ok (Lexer_tokens.IdentifierTokenSpecial "<|")
    | _ -> Error "Not an operator token"

  let convert_delimiters = function
    | DelimiterToken `LeftParen -> Ok Lexer_tokens.LeftParen
    | DelimiterToken `RightParen -> Ok Lexer_tokens.RightParen
    | DelimiterToken `LeftBrace -> Ok Lexer_tokens.LeftBrace
    | DelimiterToken `RightBrace -> Ok Lexer_tokens.RightBrace
    | DelimiterToken `LeftBracket -> Ok Lexer_tokens.LeftBracket
    | DelimiterToken `RightBracket -> Ok Lexer_tokens.RightBracket
    | DelimiterToken `Semicolon -> Ok Lexer_tokens.Semicolon
    | DelimiterToken `Comma -> Ok Lexer_tokens.Comma
    | DelimiterToken `Dot -> Ok Lexer_tokens.Dot
    | DelimiterToken `Colon -> Ok Lexer_tokens.Colon
    | DelimiterToken `DoubleColon -> Ok Lexer_tokens.ChineseDoubleColon
    | _ -> Error "Not a delimiter token"

  let convert_special = function
    | EOF -> Ok Lexer_tokens.EOF
    | Error msg -> Error ("Cannot convert error token: " ^ msg)
    | _ -> Error "Not a special token"

  let convert token =
    match token with
    | (IntToken _ | FloatToken _ | StringToken _ | BoolToken _ | ChineseNumberToken _ | UnitToken)
      as token ->
        convert_literals token
    | ( IdentifierToken _ | QuotedIdentifierToken _ | ConstructorToken _ | ModuleNameToken _
      | TypeNameToken _ ) as token ->
        convert_identifiers token
    | BasicKeyword _ as token -> convert_basic_keywords token
    | TypeKeyword _ as token -> convert_type_keywords token
    | ControlKeyword _ as token -> convert_control_keywords token
    | ClassicalKeyword _ as token -> convert_classical_keywords token
    | OperatorToken _ as token -> convert_operators token
    | DelimiterToken _ as token -> convert_delimiters token
    | (EOF | Error _) as token -> convert_special token
end

(** 从Lexer_tokens.token转换为统一Token *)
module FromLexerToken = struct
  let convert_literals = function
    | Lexer_tokens.IntToken i -> Ok (IntToken i)
    | Lexer_tokens.FloatToken f -> Ok (FloatToken f)
    | Lexer_tokens.StringToken s -> Ok (StringToken s)
    | Lexer_tokens.BoolToken b -> Ok (BoolToken b)
    | Lexer_tokens.ChineseNumberToken s -> Ok (ChineseNumberToken s)
    | _ -> Error "Not a literal token"

  let convert_identifiers = function
    | Lexer_tokens.QuotedIdentifierToken s -> Ok (QuotedIdentifierToken s)
    | Lexer_tokens.IdentifierTokenSpecial s -> Ok (IdentifierToken s)
    | _ -> Error "Not an identifier token"

  let convert_basic_keywords = function
    | Lexer_tokens.LetKeyword -> Ok (BasicKeyword `Let)
    | Lexer_tokens.FunKeyword -> Ok (BasicKeyword `Fun)
    | Lexer_tokens.InKeyword -> Ok (BasicKeyword `In)
    | Lexer_tokens.RecKeyword -> Ok (BasicKeyword `Rec)
    | Lexer_tokens.TypeKeyword -> Ok (BasicKeyword `Type)
    | Lexer_tokens.PrivateKeyword -> Ok (BasicKeyword `Private)
    | Lexer_tokens.AndKeyword -> Ok (BasicKeyword `And)
    | Lexer_tokens.AsKeyword -> Ok (BasicKeyword `As)
    | _ -> Error "Not a basic keyword"

  let convert_type_keywords = function
    | Lexer_tokens.IntTypeKeyword -> Ok (TypeKeyword `Int)
    | Lexer_tokens.FloatTypeKeyword -> Ok (TypeKeyword `Float)
    | Lexer_tokens.StringTypeKeyword -> Ok (TypeKeyword `String)
    | Lexer_tokens.BoolTypeKeyword -> Ok (TypeKeyword `Bool)
    | Lexer_tokens.UnitTypeKeyword -> Ok (TypeKeyword `Unit)
    | Lexer_tokens.ListTypeKeyword -> Ok (TypeKeyword `List)
    | Lexer_tokens.ArrayTypeKeyword ->
        Ok (TypeKeyword `Array) (* Option和Ref映射到IdentifierTokenSpecial，无法直接反向转换 *)
    | _ -> Error "Not a type keyword"

  let convert_control_keywords = function
    | Lexer_tokens.IfKeyword -> Ok (ControlKeyword `If)
    | Lexer_tokens.ThenKeyword -> Ok (ControlKeyword `Then)
    | Lexer_tokens.ElseKeyword -> Ok (ControlKeyword `Else)
    | Lexer_tokens.MatchKeyword -> Ok (ControlKeyword `Match)
    | Lexer_tokens.WithKeyword -> Ok (ControlKeyword `With)
    | Lexer_tokens.WhenKeyword -> Ok (ControlKeyword `When)
    | Lexer_tokens.TryKeyword -> Ok (ControlKeyword `Try)
    | Lexer_tokens.CatchKeyword -> Ok (ControlKeyword `Catch)
    | Lexer_tokens.FinallyKeyword -> Ok (ControlKeyword `Finally)
    | Lexer_tokens.RaiseKeyword -> Ok (ControlKeyword `Raise)
    | _ -> Error "Not a control keyword"

  let convert_classical_keywords = function
    | Lexer_tokens.HaveKeyword -> Ok (ClassicalKeyword `Have)
    | Lexer_tokens.OneKeyword -> Ok (ClassicalKeyword `One)
    | Lexer_tokens.NameKeyword -> Ok (ClassicalKeyword `Name)
    | Lexer_tokens.SetKeyword -> Ok (ClassicalKeyword `Set)
    | Lexer_tokens.AlsoKeyword -> Ok (ClassicalKeyword `Also)
    | Lexer_tokens.CallKeyword -> Ok (ClassicalKeyword `Call)
    | Lexer_tokens.ThenGetKeyword -> Ok (ClassicalKeyword `ThenGet)
    | _ -> Error "Not a classical keyword"

  let convert_operators = function
    | Lexer_tokens.Plus -> Ok (OperatorToken `Plus)
    | Lexer_tokens.Minus -> Ok (OperatorToken `Minus)
    | Lexer_tokens.Multiply -> Ok (OperatorToken `Multiply)
    | Lexer_tokens.Star -> Ok (OperatorToken `Multiply) (* Alias for Multiply *)
    | Lexer_tokens.Divide -> Ok (OperatorToken `Divide)
    | Lexer_tokens.Slash -> Ok (OperatorToken `Divide) (* Alias for Divide *)
    | Lexer_tokens.Modulo -> Ok (OperatorToken `Modulo)
    | Lexer_tokens.Equal -> Ok (OperatorToken `Equal)
    | Lexer_tokens.NotEqual -> Ok (OperatorToken `NotEqual)
    | Lexer_tokens.Less -> Ok (OperatorToken `LessThan)
    | Lexer_tokens.LessEqual -> Ok (OperatorToken `LessEqual)
    | Lexer_tokens.Greater -> Ok (OperatorToken `GreaterThan)
    | Lexer_tokens.GreaterEqual -> Ok (OperatorToken `GreaterEqual)
    | Lexer_tokens.AndKeyword -> Ok (OperatorToken `LogicalAnd)
    | Lexer_tokens.OrKeyword -> Ok (OperatorToken `LogicalOr)
    | Lexer_tokens.NotKeyword -> Ok (OperatorToken `LogicalNot)
    | Lexer_tokens.Assign -> Ok (OperatorToken `Assign)
    | Lexer_tokens.Bang -> Ok (OperatorToken `Dereference)
    | Lexer_tokens.RefKeyword -> Ok (OperatorToken `Reference)
    | Lexer_tokens.Arrow -> Ok (OperatorToken `Arrow)
    | Lexer_tokens.DoubleArrow -> Ok (OperatorToken `DoubleArrow)
    | _ -> Error "Not an operator token"

  let convert_delimiters = function
    | Lexer_tokens.LeftParen -> Ok (DelimiterToken `LeftParen)
    | Lexer_tokens.RightParen -> Ok (DelimiterToken `RightParen)
    | Lexer_tokens.LeftBrace -> Ok (DelimiterToken `LeftBrace)
    | Lexer_tokens.RightBrace -> Ok (DelimiterToken `RightBrace)
    | Lexer_tokens.LeftBracket -> Ok (DelimiterToken `LeftBracket)
    | Lexer_tokens.RightBracket -> Ok (DelimiterToken `RightBracket)
    | Lexer_tokens.Semicolon -> Ok (DelimiterToken `Semicolon)
    | Lexer_tokens.Comma -> Ok (DelimiterToken `Comma)
    | Lexer_tokens.Dot -> Ok (DelimiterToken `Dot)
    | Lexer_tokens.Colon -> Ok (DelimiterToken `Colon)
    | Lexer_tokens.ChineseDoubleColon -> Ok (DelimiterToken `DoubleColon)
    | _ -> Error "Not a delimiter token"

  let convert_special = function Lexer_tokens.EOF -> Ok EOF | _ -> Error "Not a special token"

  let convert token =
    match token with
    (* Literals *)
    | ( Lexer_tokens.IntToken _ | Lexer_tokens.FloatToken _ | Lexer_tokens.StringToken _
      | Lexer_tokens.BoolToken _ | Lexer_tokens.ChineseNumberToken _ ) as token ->
        convert_literals token
    (* Identifiers *)
    | (Lexer_tokens.QuotedIdentifierToken _ | Lexer_tokens.IdentifierTokenSpecial _) as token ->
        convert_identifiers token
    (* Basic keywords *)
    | ( Lexer_tokens.LetKeyword | Lexer_tokens.FunKeyword | Lexer_tokens.InKeyword
      | Lexer_tokens.RecKeyword | Lexer_tokens.TypeKeyword | Lexer_tokens.PrivateKeyword
      | Lexer_tokens.AndKeyword | Lexer_tokens.AsKeyword ) as token ->
        convert_basic_keywords token
    (* Type keywords *)
    | ( Lexer_tokens.IntTypeKeyword | Lexer_tokens.FloatTypeKeyword | Lexer_tokens.StringTypeKeyword
      | Lexer_tokens.BoolTypeKeyword | Lexer_tokens.UnitTypeKeyword | Lexer_tokens.ListTypeKeyword
      | Lexer_tokens.ArrayTypeKeyword ) as token ->
        convert_type_keywords token
    (* Control keywords *)
    | ( Lexer_tokens.IfKeyword | Lexer_tokens.ThenKeyword | Lexer_tokens.ElseKeyword
      | Lexer_tokens.MatchKeyword | Lexer_tokens.WithKeyword | Lexer_tokens.WhenKeyword
      | Lexer_tokens.TryKeyword | Lexer_tokens.CatchKeyword | Lexer_tokens.FinallyKeyword
      | Lexer_tokens.RaiseKeyword ) as token ->
        convert_control_keywords token
    (* Classical keywords *)
    | ( Lexer_tokens.HaveKeyword | Lexer_tokens.OneKeyword | Lexer_tokens.NameKeyword
      | Lexer_tokens.SetKeyword | Lexer_tokens.AlsoKeyword | Lexer_tokens.CallKeyword
      | Lexer_tokens.ThenGetKeyword ) as token ->
        convert_classical_keywords token
    (* Operators *)
    | ( Lexer_tokens.Plus | Lexer_tokens.Minus | Lexer_tokens.Multiply | Lexer_tokens.Star
      | Lexer_tokens.Divide | Lexer_tokens.Slash | Lexer_tokens.Modulo | Lexer_tokens.Equal
      | Lexer_tokens.NotEqual | Lexer_tokens.Less | Lexer_tokens.LessEqual | Lexer_tokens.Greater
      | Lexer_tokens.GreaterEqual | Lexer_tokens.Assign | Lexer_tokens.Bang | Lexer_tokens.Arrow
      | Lexer_tokens.DoubleArrow ) as token ->
        convert_operators token
    (* Delimiters *)
    | ( Lexer_tokens.LeftParen | Lexer_tokens.RightParen | Lexer_tokens.LeftBrace
      | Lexer_tokens.RightBrace | Lexer_tokens.LeftBracket | Lexer_tokens.RightBracket
      | Lexer_tokens.Semicolon | Lexer_tokens.Comma | Lexer_tokens.Dot | Lexer_tokens.Colon
      | Lexer_tokens.ChineseDoubleColon ) as token ->
        convert_delimiters token
    (* Special tokens *)
    | Lexer_tokens.EOF as token -> convert_special token
    (* Unsupported token *)
    | _ -> Error "Unsupported legacy token conversion"
end

(** 高级转换函数 *)

(** 将统一Token转换为旧版本Token - Result版本 *)
let to_lexer_token_result = ToLexerToken.convert

(** 从旧版本Token转换为统一Token - Result版本 *)
let from_lexer_token_result = FromLexerToken.convert

(** 将统一Token转换为旧版本Token - 抛出异常版本 *)
let to_lexer_token token =
  match ToLexerToken.convert token with
  | Ok result -> result
  | Error msg -> raise (Incompatible_token msg)

(** 从旧版本Token转换为统一Token - 抛出异常版本 *)
let from_lexer_token token =
  match FromLexerToken.convert token with
  | Ok result -> result
  | Error msg -> raise (Legacy_conversion_failed msg)

(** 批量转换：统一Token列表 -> 旧Token列表 - Result版本 *)
let to_lexer_tokens_result tokens =
  let rec convert_all acc = function
    | [] -> Ok (List.rev acc)
    | token :: rest -> (
        match ToLexerToken.convert token with
        | Ok converted -> convert_all (converted :: acc) rest
        | Error msg -> Error msg)
  in
  convert_all [] tokens

(** 批量转换：旧Token列表 -> 统一Token列表 - Result版本 *)
let from_lexer_tokens_result tokens =
  let rec convert_all acc = function
    | [] -> Ok (List.rev acc)
    | token :: rest -> (
        match FromLexerToken.convert token with
        | Ok converted -> convert_all (converted :: acc) rest
        | Error msg -> Error msg)
  in
  convert_all [] tokens

(** 批量转换：统一Token列表 -> 旧Token列表 - 抛出异常版本 *)
let to_lexer_tokens tokens = List.map to_lexer_token tokens

(** 批量转换：旧Token列表 -> 统一Token列表 - 抛出异常版本 *)
let from_lexer_tokens tokens = List.map from_lexer_token tokens

(** 转换验证：检查转换是否保持一致性 *)
let verify_conversion unified_token =
  match ToLexerToken.convert unified_token with
  | Ok legacy_token -> (
      match FromLexerToken.convert legacy_token with
      | Ok back_to_unified -> unified_token = back_to_unified
      | Error _ -> false)
  | Error _ -> false

(** 兼容性检查：检查Token是否可以安全转换 *)
let is_compatible_with_legacy = function
  | Error _ -> false (* Error Token无法转换 *)
  | UnitToken -> false (* UnitToken需要特殊处理 *)
  | _ -> true

(** 安全转换：失败时返回Error Token *)
let safe_to_lexer_token token =
  match ToLexerToken.convert token with
  | Ok result -> result
  | Error _ -> Lexer_tokens.IdentifierTokenSpecial "CONVERSION_ERROR"

(** 安全转换：失败时返回Error Token *)
let safe_from_lexer_token token =
  match FromLexerToken.convert token with
  | Ok result -> result
  | Error _ -> Error "LEGACY_CONVERSION_ERROR"
