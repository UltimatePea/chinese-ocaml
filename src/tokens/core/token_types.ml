(** 骆言Token系统整合重构 - 核心Token类型定义 统一定义所有Token类型，为整个系统提供一致的类型基础 *)

(** 关键字类型 *)
type keyword_type =
  | Basic of basic_keyword
  | Type of type_keyword
  | Control of control_keyword
  | Module of module_keyword
[@@deriving show, eq]

and basic_keyword =
  | LetKeyword
  | IfKeyword
  | ThenKeyword
  | ElseKeyword
  | FunctionKeyword
  | RecKeyword
[@@deriving show, eq]

and type_keyword =
  | IntKeyword
  | FloatKeyword
  | StringKeyword
  | BoolKeyword
  | ListKeyword
  | TypeKeyword
[@@deriving show, eq]

and control_keyword =
  | MatchKeyword
  | WithKeyword
  | WhenKeyword
  | TryKeyword
  | WhileKeyword
  | ForKeyword
[@@deriving show, eq]

and module_keyword = ModuleKeyword | OpenKeyword | IncludeKeyword | StructKeyword | SigKeyword
[@@deriving show, eq]

(** 字面量类型 *)
type literal_type =
  | IntToken of int
  | FloatToken of float
  | StringToken of string
  | BoolToken of bool
  | ChineseNumberToken of string
[@@deriving show, eq]

(** 操作符类型 *)
type operator_type =
  | Arithmetic of arithmetic_op
  | Comparison of comparison_op
  | Logical of logical_op
  | Assignment of assignment_op
  | Bitwise of bitwise_op
[@@deriving show, eq]

and arithmetic_op = Plus | Minus | Multiply | Divide | Modulo | Power [@@deriving show, eq]

and comparison_op = Equal | NotEqual | LessThan | LessEqual | GreaterThan | GreaterEqual
[@@deriving show, eq]

and logical_op = And | Or | Not [@@deriving show, eq]

and assignment_op = Assign | PlusAssign | MinusAssign | MultiplyAssign | DivideAssign
[@@deriving show, eq]

and bitwise_op = BitwiseAnd | BitwiseOr | BitwiseXor | BitwiseNot | LeftShift | RightShift
[@@deriving show, eq]

(** 分隔符类型 *)
type delimiter_type =
  | Parenthesis of parenthesis_type
  | Punctuation of punctuation_type
  | Special of special_type
[@@deriving show, eq]

and parenthesis_type =
  | LeftParen
  | RightParen
  | LeftBracket
  | RightBracket
  | LeftBrace
  | RightBrace
[@@deriving show, eq]

and punctuation_type = Comma | Semicolon | Colon | Dot | QuestionMark | ExclamationMark
[@@deriving show, eq]

and special_type = Newline | Whitespace | Tab | EOF [@@deriving show, eq]

(** 标识符类型 *)
type identifier_type =
  | QuotedIdentifierToken of string
  | IdentifierTokenSpecial of string
  | Variable of string
  | Function of string
  | Type of string
  | Module of string
[@@deriving show, eq]

(** 文言文Token类型 *)
type wenyan_type =
  | WenyanKeyword of string
  | WenyanOperator of string
  | WenyanNumber of string
  | WenyanText of string
[@@deriving show, eq]

(** 自然语言Token类型 *)
type natural_language_type =
  | ChineseText of string
  | EnglishText of string
  | MixedText of string
  | PunctuationText of string
[@@deriving show, eq]

(** 诗词Token类型 *)
type poetry_type =
  | ClassicalPoetry of string
  | ModernPoetry of string
  | Couplet of string
  | Haiku of string
  | Sonnet of string
[@@deriving show, eq]

(** 统一Token类型 *)
type token =
  | Keyword of keyword_type
  | Literal of literal_type
  | Operator of operator_type
  | Delimiter of delimiter_type
  | Identifier of identifier_type
  | Wenyan of wenyan_type
  | NaturalLanguage of natural_language_type
  | Poetry of poetry_type
[@@deriving show, eq]

type position = { line : int; column : int; filename : string } [@@deriving show, eq]
(** 位置信息 *)

type positioned_token = token * position [@@deriving show, eq]
(** 带位置的Token *)

type token_metadata = {
  creation_time : float;
  source_module : string;
  token_id : int;
  priority : int;
}
(** Token元数据 *)

type extended_token = { token : token; position : position; metadata : token_metadata }
(** 扩展Token（包含元数据） *)

(** Token分类枚举 *)
type token_category =
  | KeywordCategory
  | LiteralCategory
  | OperatorCategory
  | DelimiterCategory
  | IdentifierCategory
  | WenyanCategory
  | NaturalLanguageCategory
  | PoetryCategory
[@@deriving show, eq]

exception LexError of string * position
(** 词法错误类型 *)

exception ParseError of string * positioned_token
exception TokenError of string * token

(** Token优先级定义 *)
let token_precedence = function
  | Operator (Arithmetic Power) -> 7
  | Operator (Arithmetic (Multiply | Divide | Modulo)) -> 6
  | Operator (Arithmetic (Plus | Minus)) -> 5
  | Operator (Comparison _) -> 4
  | Operator (Logical And) -> 3
  | Operator (Logical Or) -> 2
  | Operator (Assignment _) -> 1
  | _ -> 0

(** Token结合性定义 *)
type associativity = LeftAssoc | RightAssoc | NonAssoc

let token_associativity = function
  | Operator (Arithmetic Power) -> RightAssoc
  | Operator (Assignment _) -> RightAssoc
  | Operator (Arithmetic _) -> LeftAssoc
  | Operator (Comparison _) -> NonAssoc
  | Operator (Logical _) -> LeftAssoc
  | _ -> NonAssoc
