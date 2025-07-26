(** Token兼容性桥接模块 - 技术债务清理 Issue #1375

    为现有代码提供向后兼容性支持，允许渐进式迁移到统一Token系统。 支持与旧Token模块的双向转换。

    Author: Beta, 代码审查专员 Date: 2025-07-26 *)

open Token_unified

exception Incompatible_token of string
(** 转换异常 *)

exception Legacy_conversion_failed of string

(** 将统一Token转换为Lexer_tokens.token *)
module ToLexerToken = struct
  (** 字面量Token转换 *)
  let convert_literal = function
    | IntToken i -> Lexer_tokens.IntToken i
    | FloatToken f -> Lexer_tokens.FloatToken f
    | StringToken s -> Lexer_tokens.StringToken s
    | BoolToken b -> Lexer_tokens.BoolToken b
    | ChineseNumberToken s -> Lexer_tokens.ChineseNumberToken s
    | UnitToken -> Lexer_tokens.IntToken 0 (* 临时映射 *)
    | _ -> failwith "Not a literal token"

  (** 标识符Token转换 *)
  let convert_identifier = function
    | IdentifierToken s -> Lexer_tokens.IdentifierTokenSpecial s
    | QuotedIdentifierToken s -> Lexer_tokens.QuotedIdentifierToken s
    | ConstructorToken s -> Lexer_tokens.IdentifierTokenSpecial s
    | ModuleNameToken s -> Lexer_tokens.IdentifierTokenSpecial s
    | TypeNameToken s -> Lexer_tokens.IdentifierTokenSpecial s
    | _ -> failwith "Not an identifier token"

  (** 基础关键字转换 *)
  let convert_basic_keyword = function
    | BasicKeyword `Let -> Lexer_tokens.LetKeyword
    | BasicKeyword `Fun -> Lexer_tokens.FunKeyword
    | BasicKeyword `In -> Lexer_tokens.InKeyword
    | BasicKeyword `Rec -> Lexer_tokens.RecKeyword
    | BasicKeyword `Type -> Lexer_tokens.TypeKeyword
    | BasicKeyword `Private -> Lexer_tokens.PrivateKeyword
    | BasicKeyword `And -> Lexer_tokens.AndKeyword
    | BasicKeyword `As -> Lexer_tokens.AsKeyword
    | _ -> failwith "Not a basic keyword token"

  (** 类型关键字转换 *)
  let convert_type_keyword = function
    | TypeKeyword `Int -> Lexer_tokens.IntTypeKeyword
    | TypeKeyword `Float -> Lexer_tokens.FloatTypeKeyword
    | TypeKeyword `String -> Lexer_tokens.StringTypeKeyword
    | TypeKeyword `Bool -> Lexer_tokens.BoolTypeKeyword
    | TypeKeyword `Unit -> Lexer_tokens.UnitTypeKeyword
    | TypeKeyword `List -> Lexer_tokens.ListTypeKeyword
    | TypeKeyword `Array -> Lexer_tokens.ArrayTypeKeyword
    | TypeKeyword `Option -> Lexer_tokens.IdentifierTokenSpecial "option"
    | TypeKeyword `Ref -> Lexer_tokens.IdentifierTokenSpecial "ref"
    | _ -> failwith "Not a type keyword token"

  (** 控制流关键字转换 *)
  let convert_control_keyword = function
    | ControlKeyword `If -> Lexer_tokens.IfKeyword
    | ControlKeyword `Then -> Lexer_tokens.ThenKeyword
    | ControlKeyword `Else -> Lexer_tokens.ElseKeyword
    | ControlKeyword `Match -> Lexer_tokens.MatchKeyword
    | ControlKeyword `With -> Lexer_tokens.WithKeyword
    | ControlKeyword `When -> Lexer_tokens.WhenKeyword
    | ControlKeyword `Try -> Lexer_tokens.TryKeyword
    | ControlKeyword `Catch -> Lexer_tokens.CatchKeyword
    | ControlKeyword `Finally -> Lexer_tokens.FinallyKeyword
    | ControlKeyword `Raise -> Lexer_tokens.RaiseKeyword
    | _ -> failwith "Not a control keyword token"

  (** 古典语言关键字转换 *)
  let convert_classical_keyword = function
    | ClassicalKeyword `Have -> Lexer_tokens.HaveKeyword
    | ClassicalKeyword `One -> Lexer_tokens.OneKeyword
    | ClassicalKeyword `Name -> Lexer_tokens.NameKeyword
    | ClassicalKeyword `Set -> Lexer_tokens.SetKeyword
    | ClassicalKeyword `Also -> Lexer_tokens.AlsoKeyword
    | ClassicalKeyword `Call -> Lexer_tokens.CallKeyword
    | ClassicalKeyword `ThenGet -> Lexer_tokens.ThenGetKeyword
    | ClassicalKeyword `AlsoHave -> Lexer_tokens.AlsoKeyword (* 映射到已有Token *)
    | _ -> failwith "Not a classical keyword token"

  (** 操作符转换 *)
  let convert_operator = function
    | OperatorToken `Plus -> Lexer_tokens.Plus
    | OperatorToken `Minus -> Lexer_tokens.Minus
    | OperatorToken `Multiply -> Lexer_tokens.Multiply
    | OperatorToken `Divide -> Lexer_tokens.Divide
    | OperatorToken `Modulo -> Lexer_tokens.Modulo
    | OperatorToken `Power -> Lexer_tokens.IdentifierTokenSpecial "**"
    | OperatorToken `Equal -> Lexer_tokens.Equal
    | OperatorToken `NotEqual -> Lexer_tokens.NotEqual
    | OperatorToken `LessThan -> Lexer_tokens.Less
    | OperatorToken `LessEqual -> Lexer_tokens.LessEqual
    | OperatorToken `GreaterThan -> Lexer_tokens.Greater
    | OperatorToken `GreaterEqual -> Lexer_tokens.GreaterEqual
    | OperatorToken `LogicalAnd -> Lexer_tokens.AndKeyword
    | OperatorToken `LogicalOr -> Lexer_tokens.OrKeyword
    | OperatorToken `LogicalNot -> Lexer_tokens.NotKeyword
    | OperatorToken `Assign -> Lexer_tokens.Assign
    | OperatorToken `Dereference -> Lexer_tokens.Bang
    | OperatorToken `Reference -> Lexer_tokens.RefKeyword
    | OperatorToken `Arrow -> Lexer_tokens.Arrow
    | OperatorToken `DoubleArrow -> Lexer_tokens.DoubleArrow
    | OperatorToken `PipeForward -> Lexer_tokens.PipeForward
    | OperatorToken `PipeBackward -> Lexer_tokens.PipeBackward
    | _ -> failwith "Not an operator token"

  (** 分隔符转换 *)
  let convert_delimiter = function
    | DelimiterToken `LeftParen -> Lexer_tokens.LeftParenToken
    | DelimiterToken `RightParen -> Lexer_tokens.RightParenToken
    | DelimiterToken `LeftBrace -> Lexer_tokens.LeftBraceToken
    | DelimiterToken `RightBrace -> Lexer_tokens.RightBraceToken
    | DelimiterToken `LeftBracket -> Lexer_tokens.LeftBracketToken
    | DelimiterToken `RightBracket -> Lexer_tokens.RightBracketToken
    | DelimiterToken `Semicolon -> Lexer_tokens.SemicolonToken
    | DelimiterToken `Comma -> Lexer_tokens.CommaToken
    | DelimiterToken `Dot -> Lexer_tokens.DotToken
    | DelimiterToken `Colon -> Lexer_tokens.ColonToken
    | DelimiterToken `DoubleColon -> Lexer_tokens.DoubleColonToken
    | _ -> failwith "Not a delimiter token"

  (** 主转换函数：使用专门的转换器处理不同类型的Token *)
  let convert = function
    (* 字面量Token *)
    | IntToken _ | FloatToken _ | StringToken _ | BoolToken _ 
    | ChineseNumberToken _ | UnitToken as token -> convert_literal token
    (* 标识符Token *)
    | IdentifierToken _ | QuotedIdentifierToken _ | ConstructorToken _
    | ModuleNameToken _ | TypeNameToken _ as token -> convert_identifier token
    (* 关键字Token *)
    | BasicKeyword _ as token -> convert_basic_keyword token
    | TypeKeyword _ as token -> convert_type_keyword token
    | ControlKeyword _ as token -> convert_control_keyword token
    | ClassicalKeyword _ as token -> convert_classical_keyword token
    (* 操作符和分隔符Token *)
    | OperatorToken _ as token -> convert_operator token
    | DelimiterToken _ as token -> convert_delimiter token
    (* 特殊Token *)
    | EOF -> Lexer_tokens.EOFToken
    | Error msg -> failwith ("Cannot convert error token: " ^ msg)
end

(** 从Lexer_tokens.token转换为统一Token *)
module FromLexerToken = struct
  (** 字面量Token转换 *)
  let convert_literal = function
    | Lexer_tokens.IntToken i -> IntToken i
    | Lexer_tokens.FloatToken f -> FloatToken f
    | Lexer_tokens.StringToken s -> StringToken s
    | Lexer_tokens.BoolToken b -> BoolToken b
    | Lexer_tokens.ChineseNumberToken s -> ChineseNumberToken s
    | _ -> failwith "Not a literal token"

  (** 标识符Token转换 *)
  let convert_identifier = function
    | Lexer_tokens.QuotedIdentifierToken s -> QuotedIdentifierToken s
    | Lexer_tokens.IdentifierTokenSpecial s -> IdentifierToken s
    | _ -> failwith "Not an identifier token"

  (** 基础关键字转换 *)
  let convert_basic_keyword = function
    | Lexer_tokens.LetKeyword -> BasicKeyword `Let
    | Lexer_tokens.FunKeyword -> BasicKeyword `Fun
    | Lexer_tokens.InKeyword -> BasicKeyword `In
    | Lexer_tokens.RecKeyword -> BasicKeyword `Rec
    | Lexer_tokens.TypeKeyword -> BasicKeyword `Type
    | Lexer_tokens.PrivateKeyword -> BasicKeyword `Private
    | Lexer_tokens.AndKeyword -> BasicKeyword `And
    | Lexer_tokens.AsKeyword -> BasicKeyword `As
    | _ -> failwith "Not a basic keyword token"

  (** 类型关键字转换 *)
  let convert_type_keyword = function
    | Lexer_tokens.IntTypeKeyword -> TypeKeyword `Int
    | Lexer_tokens.FloatTypeKeyword -> TypeKeyword `Float
    | Lexer_tokens.StringTypeKeyword -> TypeKeyword `String
    | Lexer_tokens.BoolTypeKeyword -> TypeKeyword `Bool
    | Lexer_tokens.UnitTypeKeyword -> TypeKeyword `Unit
    | Lexer_tokens.ListTypeKeyword -> TypeKeyword `List
    | Lexer_tokens.ArrayTypeKeyword -> TypeKeyword `Array
    | _ -> failwith "Not a type keyword token"

  (** 控制流关键字转换 *)
  let convert_control_keyword = function
    | Lexer_tokens.IfKeyword -> ControlKeyword `If
    | Lexer_tokens.ThenKeyword -> ControlKeyword `Then
    | Lexer_tokens.ElseKeyword -> ControlKeyword `Else
    | Lexer_tokens.MatchKeyword -> ControlKeyword `Match
    | Lexer_tokens.WithKeyword -> ControlKeyword `With
    | Lexer_tokens.WhenKeyword -> ControlKeyword `When
    | Lexer_tokens.TryKeyword -> ControlKeyword `Try
    | Lexer_tokens.CatchKeyword -> ControlKeyword `Catch
    | Lexer_tokens.FinallyKeyword -> ControlKeyword `Finally
    | Lexer_tokens.RaiseKeyword -> ControlKeyword `Raise
    | _ -> failwith "Not a control keyword token"

  (** 古典语言关键字转换 *)
  let convert_classical_keyword = function
    | Lexer_tokens.HaveKeyword -> ClassicalKeyword `Have
    | Lexer_tokens.OneKeyword -> ClassicalKeyword `One
    | Lexer_tokens.NameKeyword -> ClassicalKeyword `Name
    | Lexer_tokens.SetKeyword -> ClassicalKeyword `Set
    | Lexer_tokens.AlsoKeyword -> ClassicalKeyword `Also
    | Lexer_tokens.CallKeyword -> ClassicalKeyword `Call
    | Lexer_tokens.ThenGetKeyword -> ClassicalKeyword `ThenGet
    | _ -> failwith "Not a classical keyword token"

  (** 操作符转换 *)
  let convert_operator = function
    | Lexer_tokens.PlusToken -> OperatorToken `Plus
    | Lexer_tokens.MinusToken -> OperatorToken `Minus
    | Lexer_tokens.MultiplyToken -> OperatorToken `Multiply
    | Lexer_tokens.DivideToken -> OperatorToken `Divide
    | Lexer_tokens.ModuloToken -> OperatorToken `Modulo
    | Lexer_tokens.PowerToken -> OperatorToken `Power
    | Lexer_tokens.EqualToken -> OperatorToken `Equal
    | Lexer_tokens.NotEqualToken -> OperatorToken `NotEqual
    | Lexer_tokens.LessThanToken -> OperatorToken `LessThan
    | Lexer_tokens.LessEqualToken -> OperatorToken `LessEqual
    | Lexer_tokens.GreaterThanToken -> OperatorToken `GreaterThan
    | Lexer_tokens.GreaterEqualToken -> OperatorToken `GreaterEqual
    | Lexer_tokens.AndToken -> OperatorToken `LogicalAnd
    | Lexer_tokens.OrToken -> OperatorToken `LogicalOr
    | Lexer_tokens.NotKeyword -> OperatorToken `LogicalNot
    | Lexer_tokens.AssignToken -> OperatorToken `Assign
    | Lexer_tokens.BangToken -> OperatorToken `Dereference
    | Lexer_tokens.RefToken -> OperatorToken `Reference
    | Lexer_tokens.ArrowToken -> OperatorToken `Arrow
    | Lexer_tokens.DoubleArrowToken -> OperatorToken `DoubleArrow
    | Lexer_tokens.PipeForwardToken -> OperatorToken `PipeForward
    | Lexer_tokens.PipeBackwardToken -> OperatorToken `PipeBackward
    | _ -> failwith "Not an operator token"

  (** 分隔符转换 *)
  let convert_delimiter = function
    | Lexer_tokens.LeftParenToken -> DelimiterToken `LeftParen
    | Lexer_tokens.RightParenToken -> DelimiterToken `RightParen
    | Lexer_tokens.LeftBraceToken -> DelimiterToken `LeftBrace
    | Lexer_tokens.RightBraceToken -> DelimiterToken `RightBrace
    | Lexer_tokens.LeftBracketToken -> DelimiterToken `LeftBracket
    | Lexer_tokens.RightBracketToken -> DelimiterToken `RightBracket
    | Lexer_tokens.SemicolonToken -> DelimiterToken `Semicolon
    | Lexer_tokens.CommaToken -> DelimiterToken `Comma
    | Lexer_tokens.DotToken -> DelimiterToken `Dot
    | Lexer_tokens.ColonToken -> DelimiterToken `Colon
    | Lexer_tokens.DoubleColonToken -> DelimiterToken `DoubleColon
    | _ -> failwith "Not a delimiter token"

  (** 主转换函数：使用专门的转换器处理不同类型的Token *)
  let convert = function
    (* 字面量Token - 先尝试特定的转换器 *)
    | Lexer_tokens.IntToken _ | Lexer_tokens.FloatToken _ | Lexer_tokens.StringToken _
    | Lexer_tokens.BoolToken _ | Lexer_tokens.ChineseNumberToken _ as token -> 
        convert_literal token
    (* 标识符Token *)
    | Lexer_tokens.QuotedIdentifierToken _ | Lexer_tokens.IdentifierTokenSpecial _ as token -> 
        convert_identifier token
    (* 基础关键字Token *)
    | Lexer_tokens.LetKeyword | Lexer_tokens.FunKeyword | Lexer_tokens.InKeyword
    | Lexer_tokens.RecKeyword | Lexer_tokens.TypeKeyword | Lexer_tokens.PrivateKeyword
    | Lexer_tokens.AndKeyword | Lexer_tokens.AsKeyword as token -> 
        convert_basic_keyword token
    (* 类型关键字Token *)
    | Lexer_tokens.IntTypeKeyword | Lexer_tokens.FloatTypeKeyword | Lexer_tokens.StringTypeKeyword
    | Lexer_tokens.BoolTypeKeyword | Lexer_tokens.UnitTypeKeyword | Lexer_tokens.ListTypeKeyword
    | Lexer_tokens.ArrayTypeKeyword as token -> 
        convert_type_keyword token
    (* 控制流关键字Token *)
    | Lexer_tokens.IfKeyword | Lexer_tokens.ThenKeyword | Lexer_tokens.ElseKeyword
    | Lexer_tokens.MatchKeyword | Lexer_tokens.WithKeyword | Lexer_tokens.WhenKeyword
    | Lexer_tokens.TryKeyword | Lexer_tokens.CatchKeyword | Lexer_tokens.FinallyKeyword
    | Lexer_tokens.RaiseKeyword as token -> 
        convert_control_keyword token
    (* 古典语言关键字Token *)
    | Lexer_tokens.HaveKeyword | Lexer_tokens.OneKeyword | Lexer_tokens.NameKeyword
    | Lexer_tokens.SetKeyword | Lexer_tokens.AlsoKeyword | Lexer_tokens.CallKeyword
    | Lexer_tokens.ThenGetKeyword as token -> 
        convert_classical_keyword token
    (* 操作符Token *)
    | Lexer_tokens.PlusToken | Lexer_tokens.MinusToken | Lexer_tokens.MultiplyToken
    | Lexer_tokens.DivideToken | Lexer_tokens.ModuloToken | Lexer_tokens.PowerToken
    | Lexer_tokens.EqualToken | Lexer_tokens.NotEqualToken | Lexer_tokens.LessThanToken
    | Lexer_tokens.LessEqualToken | Lexer_tokens.GreaterThanToken | Lexer_tokens.GreaterEqualToken
    | Lexer_tokens.AndToken | Lexer_tokens.OrToken | Lexer_tokens.NotKeyword
    | Lexer_tokens.AssignToken | Lexer_tokens.BangToken | Lexer_tokens.RefToken
    | Lexer_tokens.ArrowToken | Lexer_tokens.DoubleArrowToken | Lexer_tokens.PipeForwardToken
    | Lexer_tokens.PipeBackwardToken as token -> 
        convert_operator token
    (* 分隔符Token *)
    | Lexer_tokens.LeftParenToken | Lexer_tokens.RightParenToken | Lexer_tokens.LeftBraceToken
    | Lexer_tokens.RightBraceToken | Lexer_tokens.LeftBracketToken | Lexer_tokens.RightBracketToken
    | Lexer_tokens.SemicolonToken | Lexer_tokens.CommaToken | Lexer_tokens.DotToken
    | Lexer_tokens.ColonToken | Lexer_tokens.DoubleColonToken as token -> 
        convert_delimiter token
    (* 特殊Token *)
    | Lexer_tokens.EOFToken -> EOF
    | other -> Error ("Unsupported legacy token: " ^ Lexer_tokens.token_to_string other)
end

(** 高级转换函数 *)

(** 将统一Token转换为旧版本Token *)
let to_lexer_token = ToLexerToken.convert

(** 从旧版本Token转换为统一Token *)
let from_lexer_token = FromLexerToken.convert

(** 批量转换：统一Token列表 -> 旧Token列表 *)
let to_lexer_tokens tokens = List.map to_lexer_token tokens

(** 批量转换：旧Token列表 -> 统一Token列表 *)
let from_lexer_tokens tokens = List.map from_lexer_token tokens

(** 转换验证：检查转换是否保持一致性 *)
let verify_conversion unified_token =
  try
    let legacy_token = to_lexer_token unified_token in
    let back_to_unified = from_lexer_token legacy_token in
    unified_token = back_to_unified
  with _ -> false

(** 兼容性检查：检查Token是否可以安全转换 *)
let is_compatible_with_legacy = function
  | Error _ -> false (* Error Token无法转换 *)
  | UnitToken -> false (* UnitToken需要特殊处理 *)
  | _ -> true

(** 安全转换：失败时返回Error Token *)
let safe_to_lexer_token token =
  try to_lexer_token token with _ -> Lexer_tokens.IdentifierTokenSpecial "CONVERSION_ERROR"

(** 安全转换：失败时返回Error Token *)
let safe_from_lexer_token token =
  try from_lexer_token token with _ -> Error "LEGACY_CONVERSION_ERROR"
