(** Token兼容性桥接模块 - 技术债务清理 Issue #1375
    
    为现有代码提供向后兼容性支持，允许渐进式迁移到统一Token系统。
    支持与旧Token模块的双向转换。
    
    Author: Beta, 代码审查专员
    Date: 2025-07-26 *)

open Token_unified

(** 转换异常 *)
exception Incompatible_token of string
exception Legacy_conversion_failed of string

(** 将统一Token转换为Lexer_tokens.token *)
module ToLexerToken = struct
  
  let convert = function
    (* 字面量转换 *)
    | IntToken i -> Lexer_tokens.IntToken i
    | FloatToken f -> Lexer_tokens.FloatToken f
    | StringToken s -> Lexer_tokens.StringToken s
    | BoolToken b -> Lexer_tokens.BoolToken b
    | ChineseNumberToken s -> Lexer_tokens.ChineseNumberToken s
    | UnitToken -> Lexer_tokens.IntToken 0  (* 临时映射 *)
    
    (* 标识符转换 *)
    | IdentifierToken s -> Lexer_tokens.IdentifierTokenSpecial s
    | QuotedIdentifierToken s -> Lexer_tokens.QuotedIdentifierToken s
    | ConstructorToken s -> Lexer_tokens.IdentifierTokenSpecial s
    | ModuleNameToken s -> Lexer_tokens.IdentifierTokenSpecial s
    | TypeNameToken s -> Lexer_tokens.IdentifierTokenSpecial s
    
    (* 基础关键字转换 *)
    | BasicKeyword `Let -> Lexer_tokens.LetKeyword
    | BasicKeyword `Fun -> Lexer_tokens.FunKeyword
    | BasicKeyword `In -> Lexer_tokens.InKeyword
    | BasicKeyword `Rec -> Lexer_tokens.RecKeyword
    | BasicKeyword `Type -> Lexer_tokens.TypeKeyword
    | BasicKeyword `Private -> Lexer_tokens.PrivateKeyword
    | BasicKeyword `And -> Lexer_tokens.AndKeyword
    | BasicKeyword `As -> Lexer_tokens.AsKeyword
    
    (* 类型关键字转换 *)
    | TypeKeyword `Int -> Lexer_tokens.IntTypeKeyword
    | TypeKeyword `Float -> Lexer_tokens.FloatTypeKeyword
    | TypeKeyword `String -> Lexer_tokens.StringTypeKeyword
    | TypeKeyword `Bool -> Lexer_tokens.BoolTypeKeyword
    | TypeKeyword `Unit -> Lexer_tokens.UnitTypeKeyword
    | TypeKeyword `List -> Lexer_tokens.ListTypeKeyword
    | TypeKeyword `Array -> Lexer_tokens.ArrayTypeKeyword
    | TypeKeyword `Option -> Lexer_tokens.IdentifierTokenSpecial "option"
    | TypeKeyword `Ref -> Lexer_tokens.IdentifierTokenSpecial "ref"
    
    (* 控制流关键字转换 *)
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
    
    (* 古典语言关键字转换 *)
    | ClassicalKeyword `Have -> Lexer_tokens.HaveKeyword
    | ClassicalKeyword `One -> Lexer_tokens.OneKeyword
    | ClassicalKeyword `Name -> Lexer_tokens.NameKeyword
    | ClassicalKeyword `Set -> Lexer_tokens.SetKeyword
    | ClassicalKeyword `Also -> Lexer_tokens.AlsoKeyword
    | ClassicalKeyword `Call -> Lexer_tokens.CallKeyword
    | ClassicalKeyword `ThenGet -> Lexer_tokens.ThenGetKeyword
    | ClassicalKeyword `AlsoHave -> Lexer_tokens.AlsoKeyword  (* 映射到已有Token *)
    
    (* 操作符转换 *)
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
    
    (* 分隔符转换 *)
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
    
    (* 特殊Token转换 *)
    | EOF -> Lexer_tokens.EOFToken
    | Error msg -> failwith ("Cannot convert error token: " ^ msg)
end

(** 从Lexer_tokens.token转换为统一Token *)
module FromLexerToken = struct
  
  let convert = function
    (* 字面量转换 *)
    | Lexer_tokens.IntToken i -> IntToken i
    | Lexer_tokens.FloatToken f -> FloatToken f
    | Lexer_tokens.StringToken s -> StringToken s
    | Lexer_tokens.BoolToken b -> BoolToken b
    | Lexer_tokens.ChineseNumberToken s -> ChineseNumberToken s
    
    (* 标识符转换 *)
    | Lexer_tokens.QuotedIdentifierToken s -> QuotedIdentifierToken s
    | Lexer_tokens.IdentifierTokenSpecial s -> IdentifierToken s
    
    (* 基础关键字转换 *)
    | Lexer_tokens.LetKeyword -> BasicKeyword `Let
    | Lexer_tokens.FunKeyword -> BasicKeyword `Fun
    | Lexer_tokens.InKeyword -> BasicKeyword `In
    | Lexer_tokens.RecKeyword -> BasicKeyword `Rec
    | Lexer_tokens.TypeKeyword -> BasicKeyword `Type
    | Lexer_tokens.PrivateKeyword -> BasicKeyword `Private
    | Lexer_tokens.AndKeyword -> BasicKeyword `And
    | Lexer_tokens.AsKeyword -> BasicKeyword `As
    
    (* 类型关键字转换 *)
    | Lexer_tokens.IntTypeKeyword -> TypeKeyword `Int
    | Lexer_tokens.FloatTypeKeyword -> TypeKeyword `Float
    | Lexer_tokens.StringTypeKeyword -> TypeKeyword `String
    | Lexer_tokens.BoolTypeKeyword -> TypeKeyword `Bool
    | Lexer_tokens.UnitTypeKeyword -> TypeKeyword `Unit
    | Lexer_tokens.ListTypeKeyword -> TypeKeyword `List
    | Lexer_tokens.ArrayTypeKeyword -> TypeKeyword `Array
    (* Option和Ref映射到IdentifierTokenSpecial，无法直接反向转换 *)
    
    (* 控制流关键字转换 *)
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
    
    (* 古典语言关键字转换 *)
    | Lexer_tokens.HaveKeyword -> ClassicalKeyword `Have
    | Lexer_tokens.OneKeyword -> ClassicalKeyword `One
    | Lexer_tokens.NameKeyword -> ClassicalKeyword `Name
    | Lexer_tokens.SetKeyword -> ClassicalKeyword `Set
    | Lexer_tokens.AlsoKeyword -> ClassicalKeyword `Also
    | Lexer_tokens.CallKeyword -> ClassicalKeyword `Call
    | Lexer_tokens.ThenGetKeyword -> ClassicalKeyword `ThenGet
    
    (* 操作符转换 *)
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
    
    (* 分隔符转换 *)
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
    
    (* 特殊Token转换 *)
    | Lexer_tokens.EOFToken -> EOF
    | other -> Error ("Unsupported legacy token: " ^ (Lexer_tokens.token_to_string other))
end

(** 高级转换函数 *)

(** 将统一Token转换为旧版本Token *)
let to_lexer_token = ToLexerToken.convert

(** 从旧版本Token转换为统一Token *)
let from_lexer_token = FromLexerToken.convert

(** 批量转换：统一Token列表 -> 旧Token列表 *)
let to_lexer_tokens tokens =
  List.map to_lexer_token tokens

(** 批量转换：旧Token列表 -> 统一Token列表 *)
let from_lexer_tokens tokens =
  List.map from_lexer_token tokens

(** 转换验证：检查转换是否保持一致性 *)
let verify_conversion unified_token =
  try
    let legacy_token = to_lexer_token unified_token in
    let back_to_unified = from_lexer_token legacy_token in
    unified_token = back_to_unified
  with _ -> false

(** 兼容性检查：检查Token是否可以安全转换 *)
let is_compatible_with_legacy = function
  | Error _ -> false  (* Error Token无法转换 *)
  | UnitToken -> false  (* UnitToken需要特殊处理 *)
  | _ -> true

(** 安全转换：失败时返回Error Token *)
let safe_to_lexer_token token =
  try to_lexer_token token
  with _ -> Lexer_tokens.IdentifierTokenSpecial "CONVERSION_ERROR"

(** 安全转换：失败时返回Error Token *)
let safe_from_lexer_token token =
  try from_lexer_token token
  with _ -> Error "LEGACY_CONVERSION_ERROR"