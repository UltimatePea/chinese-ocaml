(** 骆言词法分析器 - 向后兼容层 *)

open Token_unified
open Basic_tokens
open Identifier_tokens
open Core_keywords
open Operator_tokens
open Delimiter_tokens
open Chinese_delimiters

type token = Token_unified.token
type position = Token_unified.position = { line : int; column : int; filename : string }
type positioned_token = Token_unified.positioned_token
exception LexError of string * position

(* 字面量构造函数 *)
let int_token i = Basic (IntToken i)
let float_token f = Basic (FloatToken f)
let chinese_number_token s = Basic (ChineseNumberToken s)
let string_token s = Basic (StringToken s)
let bool_token b = Basic (BoolToken b)

(* 标识符构造函数 *)
let quoted_identifier_token s = Identifier (QuotedIdentifierToken s)
let identifier_token_special s = Identifier (IdentifierTokenSpecial s)

(* 核心关键字构造函数 *)
let let_keyword = CoreKeyword LetKeyword
let rec_keyword = CoreKeyword RecKeyword
let in_keyword = CoreKeyword InKeyword
let fun_keyword = CoreKeyword FunKeyword
let param_keyword = CoreKeyword ParamKeyword
let if_keyword = CoreKeyword IfKeyword
let then_keyword = CoreKeyword ThenKeyword
let else_keyword = CoreKeyword ElseKeyword
let match_keyword = CoreKeyword MatchKeyword
let with_keyword = CoreKeyword WithKeyword
let other_keyword = CoreKeyword OtherKeyword
let type_keyword = CoreKeyword TypeKeyword
let private_keyword = CoreKeyword PrivateKeyword
let true_keyword = CoreKeyword TrueKeyword
let false_keyword = CoreKeyword FalseKeyword
let and_keyword = CoreKeyword AndKeyword
let or_keyword = CoreKeyword OrKeyword
let not_keyword = CoreKeyword NotKeyword
let as_keyword = CoreKeyword AsKeyword
let combine_keyword = CoreKeyword CombineKeyword
let with_op_keyword = CoreKeyword WithOpKeyword
let when_keyword = CoreKeyword WhenKeyword
let or_else_keyword = CoreKeyword OrElseKeyword
let with_default_keyword = CoreKeyword WithDefaultKeyword
let exception_keyword = CoreKeyword ExceptionKeyword
let raise_keyword = CoreKeyword RaiseKeyword
let try_keyword = CoreKeyword TryKeyword
let catch_keyword = CoreKeyword CatchKeyword
let finally_keyword = CoreKeyword FinallyKeyword
let of_keyword = CoreKeyword OfKeyword
let module_keyword = CoreKeyword ModuleKeyword
let module_type_keyword = CoreKeyword ModuleTypeKeyword
let sig_keyword = CoreKeyword SigKeyword
let end_keyword = CoreKeyword EndKeyword
let functor_keyword = CoreKeyword FunctorKeyword
let ref_keyword = CoreKeyword RefKeyword
let include_keyword = CoreKeyword IncludeKeyword
let macro_keyword = CoreKeyword MacroKeyword
let expand_keyword = CoreKeyword ExpandKeyword

(* 运算符构造函数 *)
let plus = Operator Plus
let minus = Operator Minus
let multiply = Operator Multiply
let star = Operator Star
let divide = Operator Divide
let slash = Operator Slash
let modulo = Operator Modulo
let concat = Operator Concat
let assign = Operator Assign
let equal = Operator Equal
let not_equal = Operator NotEqual
let less = Operator Less
let less_equal = Operator LessEqual
let greater = Operator Greater
let greater_equal = Operator GreaterEqual
let arrow = Operator Arrow
let double_arrow = Operator DoubleArrow
let dot = Operator Dot
let double_dot = Operator DoubleDot
let triple_dot = Operator TripleDot
let bang = Operator Bang
let ref_assign = Operator RefAssign

(* 分隔符构造函数 *)
let left_paren = Delimiter LeftParen
let right_paren = Delimiter RightParen
let left_bracket = Delimiter LeftBracket
let right_bracket = Delimiter RightBracket
let left_brace = Delimiter LeftBrace
let right_brace = Delimiter RightBrace
let comma = Delimiter Comma
let semicolon = Delimiter Semicolon
let colon = Delimiter Colon
let question_mark = Operator QuestionMark
let tilde = Operator Tilde
let pipe = Delimiter Pipe
let underscore = Delimiter Underscore
let left_array = Delimiter LeftArray
let right_array = Delimiter RightArray
let assign_arrow = Operator AssignArrow
let left_quote = Delimiter LeftQuote
let right_quote = Delimiter RightQuote
let newline = Delimiter Newline
let eof = Delimiter EOF

(* 中文标点构造函数 *)
let chinese_left_paren = ChineseDelimiter ChineseLeftParen
let chinese_right_paren = ChineseDelimiter ChineseRightParen
let chinese_left_bracket = ChineseDelimiter ChineseLeftBracket
let chinese_right_bracket = ChineseDelimiter ChineseRightBracket
let chinese_square_left_bracket = ChineseDelimiter ChineseSquareLeftBracket
let chinese_square_right_bracket = ChineseDelimiter ChineseSquareRightBracket
let chinese_comma = ChineseDelimiter ChineseComma
let chinese_semicolon = ChineseDelimiter ChineseSemicolon
let chinese_colon = ChineseDelimiter ChineseColon
let chinese_double_colon = ChineseDelimiter ChineseDoubleColon
let chinese_pipe = ChineseDelimiter ChinesePipe
let chinese_left_array = ChineseDelimiter ChineseLeftArray
let chinese_right_array = ChineseDelimiter ChineseRightArray
let chinese_arrow = ChineseDelimiter ChineseArrow
let chinese_double_arrow = ChineseDelimiter ChineseDoubleArrow
let chinese_assign_arrow = ChineseDelimiter ChineseAssignArrow

(* 转换和检查函数 *)
let to_legacy_string = Token_unified.to_string
let is_literal_token = Token_unified.is_literal
let is_keyword_token = Token_unified.is_keyword
let is_operator_token = Token_unified.is_operator
let is_delimiter_token = Token_unified.is_delimiter

(* Show函数 *)
let show_token = Token_unified.to_string
let show_position p = Printf.sprintf "{ line = %d; column = %d; filename = \"%s\" }" p.line p.column p.filename
let show_positioned_token (token, pos) = Printf.sprintf "(%s, %s)" (show_token token) (show_position pos)