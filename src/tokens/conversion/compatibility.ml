(** 骆言Token系统整合重构 - 向后兼容性层
    确保新的Token系统与现有代码完全兼容 *)

open Tokens_core.Token_types
open Tokens_core.Token_utils

(** 兼容性别名模块 - 保持旧API可用 *)
module Compatibility = struct
  
  (** 旧版Token类型别名 *)
  type legacy_token = token
  type legacy_position = position
  type legacy_positioned_token = positioned_token
  
  (** 旧版Token创建函数别名 *)
  let make_int_token = TokenCreator.make_int_token
  let make_float_token = TokenCreator.make_float_token
  let make_string_token = TokenCreator.make_string_token
  let make_bool_token = TokenCreator.make_bool_token
  let make_chinese_number_token = TokenCreator.make_chinese_number_token
  
  let make_let_keyword = TokenCreator.make_let_keyword
  let make_if_keyword = TokenCreator.make_if_keyword
  let make_then_keyword = TokenCreator.make_then_keyword
  let make_else_keyword = TokenCreator.make_else_keyword
  
  let make_plus_op = TokenCreator.make_plus_op
  let make_minus_op = TokenCreator.make_minus_op
  let make_multiply_op = TokenCreator.make_multiply_op
  let make_divide_op = TokenCreator.make_divide_op
  let make_assign_op = TokenCreator.make_assign_op
  let make_equal_op = TokenCreator.make_equal_op
  
  let make_left_paren = TokenCreator.make_left_paren
  let make_right_paren = TokenCreator.make_right_paren
  let make_left_bracket = TokenCreator.make_left_bracket
  let make_right_bracket = TokenCreator.make_right_bracket
  let make_comma = TokenCreator.make_comma
  let make_semicolon = TokenCreator.make_semicolon
  
  let make_quoted_identifier = TokenCreator.make_quoted_identifier
  let make_special_identifier = TokenCreator.make_special_identifier
  
  (** 旧版位置和定位Token函数别名 *)
  let make_position = TokenCreator.make_position
  let make_positioned_token = TokenCreator.make_positioned_token
  
  (** 旧版Token分类函数别名 *)
  let is_literal = TokenClassifier.is_literal
  let is_keyword = TokenClassifier.is_keyword
  let is_operator = TokenClassifier.is_operator
  let is_delimiter = TokenClassifier.is_delimiter
  let is_identifier = TokenClassifier.is_identifier
  let is_wenyan = TokenClassifier.is_wenyan
  let is_natural_language = TokenClassifier.is_natural_language
  let is_poetry = TokenClassifier.is_poetry
  
  let is_numeric_token = TokenClassifier.is_numeric_token
  let is_string_token = TokenClassifier.is_string_token
  let is_control_flow_token = TokenClassifier.is_control_flow_token
  let is_binary_op_token = TokenClassifier.is_binary_op_token
  let is_unary_op_token = TokenClassifier.is_unary_op_token
  let is_left_delimiter_token = TokenClassifier.is_left_delimiter_token
  let is_right_delimiter_token = TokenClassifier.is_right_delimiter_token
  
  (** 旧版Token转换函数别名 *)
  let token_to_string = TokenConverter.token_to_string
  let position_to_string = TokenConverter.position_to_string
  let positioned_token_to_string = TokenConverter.positioned_token_to_string
  
  (** 旧版Token比较函数别名 *)
  let equal_token = TokenComparator.equal_token
  let equal_position = TokenComparator.equal_position
  let equal_positioned_token = TokenComparator.equal_positioned_token
  
  (** 旧版优先级函数别名 *)
  let get_token_precedence = token_precedence
  
  (** 旧版异常别名 *)
  exception LexError = LexError
end

(** 原有模块接口的兼容性包装 *)
module LiteralTokensCompat = struct
  type literal_token = literal_type
  
  let literal_token_to_string = function
    | IntToken i -> string_of_int i
    | FloatToken f -> string_of_float f
    | StringToken s -> "\"" ^ s ^ "\""
    | BoolToken true -> "真"
    | BoolToken false -> "假"
    | ChineseNumberToken s -> s
  
  let is_numeric_literal = function
    | IntToken _ | FloatToken _ | ChineseNumberToken _ -> true
    | _ -> false
  
  let is_string_literal = function
    | StringToken _ -> true
    | _ -> false
end

module KeywordTokensCompat = struct
  type keyword_token = keyword_type
  
  let keyword_token_to_string = function
    | Basic LetKeyword -> "让"
    | Basic IfKeyword -> "如果"
    | Basic ThenKeyword -> "那么"
    | Basic ElseKeyword -> "否则"
    | Basic FunctionKeyword -> "函数"
    | Basic RecKeyword -> "递归"
    | Type IntKeyword -> "整数"
    | Type FloatKeyword -> "小数"
    | Type StringKeyword -> "字符串"
    | Type BoolKeyword -> "布尔"
    | Type ListKeyword -> "列表"
    | Type TypeKeyword -> "类型"
    | Control MatchKeyword -> "匹配"
    | Control WithKeyword -> "与"
    | Control WhenKeyword -> "当"
    | Control TryKeyword -> "尝试"
    | Control WhileKeyword -> "循环"
    | Control ForKeyword -> "遍历"
    | Module ModuleKeyword -> "模块"
    | Module OpenKeyword -> "打开"
    | Module IncludeKeyword -> "包含"
    | Module StructKeyword -> "结构"
    | Module SigKeyword -> "签名"
  
  let is_control_flow_keyword = function
    | Control _ -> true
    | _ -> false
end

module OperatorTokensCompat = struct
  type operator_token = operator_type
  
  let operator_token_to_string = function
    | Arithmetic Plus -> "+"
    | Arithmetic Minus -> "-"
    | Arithmetic Multiply -> "*"
    | Arithmetic Divide -> "/"
    | Arithmetic Modulo -> "%"
    | Arithmetic Power -> "**"
    | Comparison Equal -> "="
    | Comparison NotEqual -> "!="
    | Comparison LessThan -> "<"
    | Comparison LessEqual -> "<="
    | Comparison GreaterThan -> ">"
    | Comparison GreaterEqual -> ">="
    | Logical And -> "并且"
    | Logical Or -> "或者"
    | Logical Not -> "非"
    | Assignment Assign -> ":="
    | Assignment PlusAssign -> "+="
    | Assignment MinusAssign -> "-="
    | Assignment MultiplyAssign -> "*="
    | Assignment DivideAssign -> "/="
    | Bitwise BitwiseAnd -> "&"
    | Bitwise BitwiseOr -> "|"
    | Bitwise BitwiseXor -> "^"
    | Bitwise BitwiseNot -> "~"
    | Bitwise LeftShift -> "<<"
    | Bitwise RightShift -> ">>"
  
  let is_binary_operator = function
    | Arithmetic _ | Comparison _ | Logical (And | Or) | Assignment _ | Bitwise (BitwiseAnd | BitwiseOr | BitwiseXor | LeftShift | RightShift) -> true
    | _ -> false
  
  let is_unary_operator = function
    | Logical Not | Bitwise BitwiseNot -> true
    | _ -> false
  
  let get_operator_precedence = function
    | Arithmetic Power -> 7
    | Arithmetic (Multiply | Divide | Modulo) -> 6
    | Arithmetic (Plus | Minus) -> 5
    | Comparison _ -> 4
    | Logical And -> 3
    | Logical Or -> 2
    | Assignment _ -> 1
    | _ -> 0
end

module DelimiterTokensCompat = struct
  type delimiter_token = delimiter_type
  
  let delimiter_token_to_string = function
    | Parenthesis LeftParen -> "("
    | Parenthesis RightParen -> ")"
    | Parenthesis LeftBracket -> "["
    | Parenthesis RightBracket -> "]"
    | Parenthesis LeftBrace -> "{"
    | Parenthesis RightBrace -> "}"
    | Punctuation Comma -> ","
    | Punctuation Semicolon -> ";"
    | Punctuation Colon -> ":"
    | Punctuation Dot -> "."
    | Punctuation QuestionMark -> "?"
    | Punctuation ExclamationMark -> "!"
    | Special Newline -> "\n"
    | Special Whitespace -> " "
    | Special Tab -> "\t"
    | Special EOF -> "<EOF>"
  
  let is_left_delimiter = function
    | Parenthesis (LeftParen | LeftBracket | LeftBrace) -> true
    | _ -> false
  
  let is_right_delimiter = function
    | Parenthesis (RightParen | RightBracket | RightBrace) -> true
    | _ -> false
end

module IdentifierTokensCompat = struct
  type identifier_token = identifier_type
  
  let identifier_token_to_string = function
    | QuotedIdentifierToken s -> "'" ^ s ^ "'"
    | IdentifierTokenSpecial s -> s
    | Variable s -> s
    | Function s -> s ^ "()"
    | Type s -> s ^ "_t"
    | Module s -> s ^ "_mod"
end

module WenyanTokensCompat = struct
  type wenyan_token = wenyan_type
  
  let wenyan_token_to_string = function
    | WenyanKeyword s -> "文言:" ^ s
    | WenyanOperator s -> "操作:" ^ s
    | WenyanNumber s -> "数字:" ^ s
    | WenyanText s -> "文本:" ^ s
end

module NaturalLanguageTokensCompat = struct
  type natural_language_token = natural_language_type
  
  let natural_language_token_to_string = function
    | ChineseText s -> "中文:" ^ s
    | EnglishText s -> "英文:" ^ s
    | MixedText s -> "混合:" ^ s
    | PunctuationText s -> "标点:" ^ s
end

module PoetryTokensCompat = struct
  type poetry_token = poetry_type
  
  let poetry_token_to_string = function
    | ClassicalPoetry s -> "古诗:" ^ s
    | ModernPoetry s -> "现代诗:" ^ s
    | Couplet s -> "对联:" ^ s
    | Haiku s -> "俳句:" ^ s
    | Sonnet s -> "十四行诗:" ^ s
end