(** 骆言词法分析器Token类型模块接口 *)

(** 操作符类型Token模块 *)
module Operators : sig
  type operator_token =
    (* 算术操作符 *)
    | Plus
    | Minus
    | Multiply
    | Divide
    | Modulo
    | Power
    (* 比较操作符 *)
    | Equal
    | NotEqual
    | LessThan
    | LessEqual
    | GreaterThan
    | GreaterEqual
    (* 逻辑操作符 *)
    | LogicalAnd
    | LogicalOr
    | LogicalNot
    (* 位操作符 *)
    | BitwiseAnd
    | BitwiseOr
    | BitwiseXor
    | BitwiseNot
    | ShiftLeft
    | ShiftRight
    | ArithShiftRight
    (* 赋值和引用 *)
    | Assign
    | Dereference
    | Reference
    (* 函数组合 *)
    | Compose
    | PipeForward
    | PipeBackward
    (* 其他操作符 *)
    | Arrow
    | DoubleArrow
    | DoubleDot
    | TripleDot
    | Bang
    | RefAssign
  [@@deriving show, eq]
end

(** 关键字类型Token模块 *)
module Keywords : sig
  type keyword_token =
    (* 基础关键字 *)
    | LetKeyword
    | RecKeyword
    | InKeyword
    | FunKeyword
    | IfKeyword
    | ThenKeyword
    | ElseKeyword
    | MatchKeyword
    | WithKeyword
    | OtherKeyword
    | TypeKeyword
    | PrivateKeyword
    | TrueKeyword
    | FalseKeyword
    | AndKeyword
    | OrKeyword
    | NotKeyword
    (* 语义类型系统关键字 *)
    | AsKeyword
    | CombineKeyword
    | WithOpKeyword
    | WhenKeyword
    (* 错误恢复关键字 *)
    | OrElseKeyword
    | WithDefaultKeyword
    (* 异常处理关键字 *)
    | ExceptionKeyword
    | RaiseKeyword
    | TryKeyword
    | CatchKeyword
    | FinallyKeyword
    (* 类型关键字 *)
    | OfKeyword
    (* 模块系统关键字 *)
    | ModuleKeyword
    | ModuleTypeKeyword
    | OpenKeyword
    | IncludeKeyword
    | SigKeyword
    | StructKeyword
    | EndKeyword
    | FunctorKeyword
    | ValKeyword
    | ExternalKeyword
    (* 古雅体增强关键字 *)
    | BeginKeyword
    | FinishKeyword
    | DefinedKeyword
    | DefinedAsKeyword
    | ReturnKeyword
    | ResultKeyword
    | CallKeyword
    | ParamKeyword
    | InvokeKeyword
    | ApplyKeyword
    (* wenyan风格关键字 *)
    | WenyanNow
    | WenyanHave
    | WenyanIs
    | WenyanNot
    | WenyanAll
    | WenyanSome
    | WenyanFor
    | WenyanWhile
    | WenyanIf
    | WenyanThen
    | WenyanElse
    (* 古文关键字 *)
    | ClassicalLet
    | ClassicalIn
    | ClassicalBe
    | ClassicalDo
    | ClassicalEnd
    | ClassicalReturn
    | ClassicalCall
    | ClassicalDefine
    | ClassicalCreate
    | ClassicalDestroy
    | ClassicalTransform
    | ClassicalCombine
    | ClassicalSeparate
    (* 诗词语法关键字 *)
    | PoetryStart
    | PoetryEnd
    | VerseStart
    | VerseEnd
    | RhymePattern
    | TonePattern
    | ParallelStart
    | ParallelEnd
  [@@deriving show, eq]
end

(** 字面量类型Token模块 *)
module Literals : sig
  type literal_token =
    (* 数值字面量 *)
    | IntToken of int
    | FloatToken of float
    | ChineseNumberToken of string
    (* 文本字面量 *)
    | StringToken of string
    | CharToken of char
    (* 布尔字面量 *)
    | BoolToken of bool
    (* 特殊字面量 *)
    | UnitToken
    | NullToken
  [@@deriving show, eq]
end

(** 标识符类型Token模块 *)
module Identifiers : sig
  type identifier_token =
    | QuotedIdentifierToken of string
    | IdentifierTokenSpecial of string
    | ConstructorToken of string
    | ModuleIdToken of string
    | TypeIdToken of string
    | LabelToken of string
  [@@deriving show, eq]
end

(** 分隔符类型Token模块 *)
module Delimiters : sig
  type delimiter_token =
    (* ASCII分隔符 *)
    | LeftParen
    | RightParen
    | LeftBracket
    | RightBracket
    | LeftBrace
    | RightBrace
    | Comma
    | Semicolon
    | Colon
    | QuestionMark
    | Tilde
    | Pipe
    | Underscore
    | LeftArray
    | RightArray
    | AssignArrow
    | LeftQuote
    | RightQuote
    (* 中文分隔符 *)
    | ChineseLeftParen
    | ChineseRightParen
    | ChineseLeftBracket
    | ChineseRightBracket
    | ChineseComma
    | ChineseSemicolon
    | ChineseColon
    | ChineseDoubleColon
    | ChinesePipe
    | ChineseLeftArray
    | ChineseRightArray
    | ChineseArrow
    | ChineseDoubleArrow
    | ChineseAssignArrow
  [@@deriving show, eq]
end

(** 特殊Token模块 *)
module Special : sig
  type special_token =
    | Newline
    | EOF
    | Comment of string
    | ChineseComment of string
    | Whitespace of string
  [@@deriving show, eq]
end

(** 统一的Token类型 *)
type token =
  | OperatorToken of Operators.operator_token
  | KeywordToken of Keywords.keyword_token
  | LiteralToken of Literals.literal_token
  | IdentifierToken of Identifiers.identifier_token
  | DelimiterToken of Delimiters.delimiter_token
  | SpecialToken of Special.special_token
[@@deriving show, eq]

type position = { line : int; column : int; filename : string } [@@deriving show, eq]
(** 位置信息 *)

type positioned_token = token * position [@@deriving show, eq]
(** 带位置的词元 *)

(** Token分类和工具函数模块 *)
module TokenUtils : sig
  val is_operator : token -> bool
  val is_keyword : token -> bool
  val is_literal : token -> bool
  val is_identifier : token -> bool
  val is_delimiter : token -> bool
  val is_special : token -> bool
  val is_eof : token -> bool
  val is_newline : token -> bool
  val token_to_string : token -> string
end
