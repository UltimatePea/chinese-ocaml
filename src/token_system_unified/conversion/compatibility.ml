(** 骆言Token系统整合重构 - 向后兼容性层 确保新的Token系统与现有代码完全兼容 *)

open Yyocamlc_lib.Token_types
(* Token utilities are included via Yyocamlc_lib.Token_types *)
open Identifier_converter

(** 兼容性别名模块 - 保持旧API可用 *)
module Compatibility = struct
  type legacy_token = token
  (** 旧版Token类型别名 *)

  type legacy_position = position
  type legacy_positioned_token = positioned_token

  (** 旧版Token创建函数别名 *)
  let make_int_token i = LiteralToken (Literals.IntToken i)

  let make_float_token f = LiteralToken (Literals.FloatToken f)
  let make_string_token s = LiteralToken (Literals.StringToken s)
  let make_bool_token b = LiteralToken (Literals.BoolToken b)
  let make_chinese_number_token s = LiteralToken (Literals.ChineseNumberToken s)
  let make_let_keyword () = KeywordToken Keywords.LetKeyword
  let make_if_keyword () = KeywordToken Keywords.IfKeyword
  let make_then_keyword () = KeywordToken Keywords.ThenKeyword
  let make_else_keyword () = KeywordToken Keywords.ElseKeyword
  let make_plus_op () = OperatorToken Operators.Plus
  let make_minus_op () = OperatorToken Operators.Minus
  let make_multiply_op () = OperatorToken Operators.Multiply
  let make_divide_op () = OperatorToken Operators.Divide
  let make_assign_op () = OperatorToken Operators.Assign
  let make_equal_op () = OperatorToken Operators.Equal
  let make_left_paren () = DelimiterToken Delimiters.LeftParen
  let make_right_paren () = DelimiterToken Delimiters.RightParen
  let make_left_bracket () = DelimiterToken Delimiters.LeftBracket
  let make_right_bracket () = DelimiterToken Delimiters.RightBracket
  let make_comma () = DelimiterToken Delimiters.Comma
  let make_semicolon () = DelimiterToken Delimiters.Semicolon
  let make_quoted_identifier s = IdentifierToken (Identifiers.QuotedIdentifierToken s)
  let make_special_identifier s = IdentifierToken (Identifiers.IdentifierTokenSpecial s)

  (** 旧版位置和定位Token函数别名 *)
  let make_position ~line ~column ~filename = { line; column; filename }

  let make_positioned_token token position = (token, position)

  (** 旧版Token分类函数别名 *)
  let is_literal = TokenUtils.is_literal

  let is_keyword = TokenUtils.is_keyword
  let is_operator = TokenUtils.is_operator
  let is_delimiter = TokenUtils.is_delimiter
  let is_identifier = TokenUtils.is_identifier
  let is_wenyan _token = false (* Placeholder *)
  let is_natural_language _token = false (* Placeholder *)
  let is_poetry _token = false (* Placeholder *)
  let is_numeric_token = function | LiteralToken (Literals.IntToken _ | Literals.FloatToken _ | Literals.ChineseNumberToken _) -> true | _ -> false
  let is_string_token = function | LiteralToken (Literals.StringToken _) -> true | _ -> false
  let is_control_flow_token = function | KeywordToken (Keywords.IfKeyword | Keywords.ThenKeyword | Keywords.ElseKeyword | Keywords.MatchKeyword | Keywords.WithKeyword) -> true | _ -> false
  let is_binary_op_token = function | OperatorToken (Operators.Plus | Operators.Minus | Operators.Multiply | Operators.Divide | Operators.Equal) -> true | _ -> false
  let is_unary_op_token = function | OperatorToken Operators.LogicalNot -> true | _ -> false
  let is_left_delimiter_token = function | DelimiterToken (Delimiters.LeftParen | Delimiters.LeftBracket | Delimiters.LeftBrace) -> true | _ -> false
  let is_right_delimiter_token = function | DelimiterToken (Delimiters.RightParen | Delimiters.RightBracket | Delimiters.RightBrace) -> true | _ -> false

  (** 旧版Token转换函数别名 *)
  let token_to_string = TokenUtils.token_to_string

  let position_to_string pos = Printf.sprintf "line %d, column %d" pos.line pos.column
  let positioned_token_to_string (token, pos) = Printf.sprintf "%s at %s" (TokenUtils.token_to_string token) (position_to_string pos)

  (** 旧版Token比较函数别名 *)
  let equal_token = (=)

  let equal_position = (=)
  let equal_positioned_token = (=)

  (** 旧版优先级函数别名 *)
  let get_token_precedence _token = 0 (* Placeholder *)

  (* LexError exception would be defined in error handling module *)
  (** 旧版异常别名 *)
end

(** 原有模块接口的兼容性包装 *)
module LiteralTokensCompat = struct
  type literal_token = Literals.literal_token

  let literal_token_to_string = function
    | Literals.IntToken i -> string_of_int i
    | Literals.FloatToken f -> string_of_float f
    | Literals.StringToken s -> "\"" ^ s ^ "\""
    | Literals.BoolToken true -> "真"
    | Literals.BoolToken false -> "假"
    | Literals.ChineseNumberToken s -> s
    | Literals.UnitToken -> "()"
    | Literals.NullToken -> "null"
    | Literals.CharToken c -> "'" ^ String.make 1 c ^ "'"

  let is_numeric_literal = function
    | Literals.IntToken _ | Literals.FloatToken _ | Literals.ChineseNumberToken _ -> true
    | _ -> false

  let is_string_literal = function Literals.StringToken _ -> true | _ -> false
end

module KeywordTokensCompat = struct
  type keyword_token = Keywords.keyword_token

  let keyword_token_to_string = function
    | Keywords.LetKeyword -> "让"
    | Keywords.IfKeyword -> "如果"
    | Keywords.ThenKeyword -> "那么"
    | Keywords.ElseKeyword -> "否则"
    | Keywords.FunKeyword -> "函数"
    | Keywords.RecKeyword -> "递归"
    | Keywords.TypeKeyword -> "类型" (* Simplified *)
    (* Other type keywords not available *)
    | Keywords.MatchKeyword -> "匹配"
    | Keywords.WithKeyword -> "与"
    | Keywords.WhenKeyword -> "当"
    | Keywords.TryKeyword -> "尝试"
    | Keywords.WenyanWhile -> "循环"
    | Keywords.WenyanFor -> "遍历"
    | Keywords.ModuleKeyword -> "模块"
    | Keywords.OpenKeyword -> "打开"
    | Keywords.IncludeKeyword -> "包含"
    | Keywords.StructKeyword -> "结构"
    | Keywords.SigKeyword -> "签名"
    | _ -> "[Unknown Keyword]" (* Fallback for unhandled keywords *)

  let is_control_flow_keyword = function | Keywords.IfKeyword | Keywords.ThenKeyword | Keywords.ElseKeyword | Keywords.MatchKeyword | Keywords.WithKeyword -> true | _ -> false
end

module OperatorTokensCompat = struct
  type operator_token = Operators.operator_token

  let operator_token_to_string = function
    | Operators.Plus -> "+"
    | Operators.Minus -> "-"
    | Operators.Multiply -> "*"
    | Operators.Divide -> "/"
    | Operators.Modulo -> "%"
    | Operators.Power -> "**"
    | Operators.Equal -> "="
    | Operators.NotEqual -> "!="
    | Operators.LessThan -> "<"
    | Operators.LessEqual -> "<="
    | Operators.GreaterThan -> ">"
    | Operators.GreaterEqual -> ">="
    | Operators.LogicalAnd -> "并且"
    | Operators.LogicalOr -> "或者"
    | Operators.LogicalNot -> "非"
    | Operators.Assign -> ":="
    (* Assignment operators simplified *)
    | Operators.BitwiseAnd -> "&"
    | Operators.BitwiseOr -> "|"
    | Operators.BitwiseXor -> "^"
    | Operators.BitwiseNot -> "~"
    | Operators.ShiftLeft -> "<<"
    | Operators.ShiftRight -> ">>"
    | _ -> "[Unknown Operator]" (* Fallback *)

  let is_binary_operator = function
    | Operators.Plus | Operators.Minus | Operators.Multiply | Operators.Divide | Operators.Modulo | Operators.Power
    | Operators.Equal | Operators.NotEqual | Operators.LessThan | Operators.LessEqual | Operators.GreaterThan | Operators.GreaterEqual
    | Operators.LogicalAnd | Operators.LogicalOr
    | Operators.Assign
    | Operators.BitwiseAnd | Operators.BitwiseOr | Operators.BitwiseXor | Operators.ShiftLeft | Operators.ShiftRight ->
        true
    | _ -> false

  let is_unary_operator = function Operators.LogicalNot | Operators.BitwiseNot -> true | _ -> false

  let get_operator_precedence = function
    | Operators.Power -> 7
    | Operators.Multiply | Operators.Divide | Operators.Modulo -> 6
    | Operators.Plus | Operators.Minus -> 5
    | Operators.Equal | Operators.NotEqual | Operators.LessThan | Operators.LessEqual | Operators.GreaterThan | Operators.GreaterEqual -> 4
    | Operators.LogicalAnd -> 3
    | Operators.LogicalOr -> 2
    | Operators.Assign -> 1
    | _ -> 0
end

module DelimiterTokensCompat = struct
  type delimiter_token = Delimiters.delimiter_token

  let delimiter_token_to_string = function
    | Delimiters.LeftParen -> "("
    | Delimiters.RightParen -> ")"
    | Delimiters.LeftBracket -> "["
    | Delimiters.RightBracket -> "]"
    | Delimiters.LeftBrace -> "{"
    | Delimiters.RightBrace -> "}"
    | Delimiters.Comma -> ","
    | Delimiters.Semicolon -> ";"
    | Delimiters.Colon -> ":"
    | Delimiters.QuestionMark -> "?"
    | Delimiters.Tilde -> "~"
    | Delimiters.Pipe -> "|"
    | Delimiters.Underscore -> "_"
    | _ -> "?"  (* fallback for other delimiters *)

  let is_left_delimiter = function
    | Delimiters.LeftParen | Delimiters.LeftBracket | Delimiters.LeftBrace -> true
    | _ -> false

  let is_right_delimiter = function
    | Delimiters.RightParen | Delimiters.RightBracket | Delimiters.RightBrace -> true
    | _ -> false
end

module IdentifierTokensCompat = struct
  type identifier_token = identifier_type

  let identifier_token_to_string = function
    | Identifiers.QuotedIdentifierToken s -> "'" ^ s ^ "'"
    | Identifiers.IdentifierTokenSpecial s -> s
    | Identifiers.ConstructorToken s -> s
    | Identifiers.ModuleIdToken s -> s ^ "_mod"
    | Identifiers.TypeIdToken s -> s ^ "_t"
    | Identifiers.LabelToken s -> s
end

module WenyanTokensCompat = struct
  type wenyan_token = token

  let wenyan_token_to_string = function
    | KeywordToken kw -> "文言:" ^ (Keywords.show_keyword_token kw)
    | OperatorToken op -> "操作:" ^ (Operators.show_operator_token op)
    | LiteralToken (Literals.ChineseNumberToken s) -> "数字:" ^ s
    | SpecialToken (Special.ChineseComment s) -> "文本:" ^ s
    | token -> "其他:" ^ (show_token token)
end

module NaturalLanguageTokensCompat = struct
  type natural_language_type =
    | ChineseText of string
    | EnglishText of string
    | MixedText of string
    | PunctuationText of string

  type natural_language_token = natural_language_type

  let natural_language_token_to_string = function
    | ChineseText s -> "中文:" ^ s
    | EnglishText s -> "英文:" ^ s
    | MixedText s -> "混合:" ^ s
    | PunctuationText s -> "标点:" ^ s
end

module PoetryTokensCompat = struct
  type poetry_type =
    | ClassicalPoetry of string
    | ModernPoetry of string

  type poetry_token = poetry_type

  let poetry_token_to_string = function
    | ClassicalPoetry s -> "古诗:" ^ s
    | ModernPoetry s -> "现代诗:" ^ s
    | Couplet s -> "对联:" ^ s
    | Haiku s -> "俳句:" ^ s
    | Sonnet s -> "十四行诗:" ^ s
end
