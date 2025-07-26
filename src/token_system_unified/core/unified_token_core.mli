(** 统一Token核心系统接口 - 消除项目中token定义的重复 *)

(** Token优先级定义 *)
type token_priority =
  | HighPriority  (** 高优先级：关键字、保留字 *)
  | MediumPriority  (** 中优先级：运算符、分隔符 *)
  | LowPriority  (** 低优先级：标识符、字面量 *)

(** Token分类 *)
type token_category =
  | KeywordCategory  (** 关键字 *)
  | LiteralCategory  (** 字面量 *)
  | OperatorCategory  (** 运算符 *)
  | DelimiterCategory  (** 分隔符 *)
  | IdentifierCategory  (** 标识符 *)
  | WenyanCategory  (** 文言文特殊token *)
  | NaturalLanguageCategory  (** 自然语言token *)
  | PoetryCategory  (** 诗歌相关token *)
  | SpecialCategory  (** 特殊token *)

type position = { line : int; column : int; filename : string }
(** 位置信息 *)

type token_metadata = {
  creation_time : float;
  source_module : string;
  token_id : int;
  priority : int;
}
(** Token元数据 *)

(** 统一的Token定义 - 消除各种重复定义 *)
type unified_token =
  (* 字面量Token *)
  | IntToken of int
  | FloatToken of float
  | StringToken of string
  | BoolToken of bool
  | ChineseNumberToken of string
  | UnitToken
  (* 标识符Token *)
  | IdentifierToken of string
  | QuotedIdentifierToken of string
  | ConstructorToken of string
  | IdentifierTokenSpecial of string
  | ModuleNameToken of string
  | TypeNameToken of string
  (* 基础关键字Token *)
  | LetKeyword
  | FunKeyword
  | IfKeyword
  | ThenKeyword
  | ElseKeyword
  | MatchKeyword
  | WithKeyword
  | WhenKeyword
  | AndKeyword
  | OrKeyword
  | NotKeyword
  | TrueKeyword
  | FalseKeyword
  | InKeyword
  | RecKeyword
  | MutableKeyword
  | RefKeyword
  | BeginKeyword
  | EndKeyword
  | ForKeyword
  | WhileKeyword
  | DoKeyword
  | DoneKeyword
  | ToKeyword
  | DowntoKeyword
  | BreakKeyword
  | ContinueKeyword
  | ReturnKeyword
  | TryKeyword
  | RaiseKeyword
  | FailwithKeyword
  | AssertKeyword
  | LazyKeyword
  | ExceptionKeyword
  | ModuleKeyword
  | StructKeyword
  | SigKeyword
  | FunctorKeyword
  | IncludeKeyword
  | OpenKeyword
  | TypeKeyword
  | ValKeyword
  | ExternalKeyword
  | PrivateKeyword
  | VirtualKeyword
  | MethodKeyword
  | InheritKeyword
  | InitializerKeyword
  | NewKeyword
  | ObjectKeyword
  | ClassKeyword
  | ConstraintKeyword
  | AsKeyword
  | OfKeyword
  (* 数字相关关键字 *)
  | ZeroKeyword
  | OneKeyword
  | TwoKeyword
  | ThreeKeyword
  | FourKeyword
  | FiveKeyword
  | SixKeyword
  | SevenKeyword
  | EightKeyword
  | NineKeyword
  | TenKeyword
  | HundredKeyword
  | ThousandKeyword
  | TenThousandKeyword
  (* 类型关键字 *)
  | IntTypeKeyword
  | FloatTypeKeyword
  | StringTypeKeyword
  | BoolTypeKeyword
  | UnitTypeKeyword
  | ListTypeKeyword
  | ArrayTypeKeyword
  | RefTypeKeyword
  | FunctionTypeKeyword
  | TupleTypeKeyword
  | RecordTypeKeyword
  | VariantTypeKeyword
  | OptionTypeKeyword
  | ResultTypeKeyword
  (* 文言文关键字 *)
  | WenyanIfKeyword
  | WenyanThenKeyword
  | WenyanElseKeyword
  | WenyanWhileKeyword
  | WenyanForKeyword
  | WenyanFunctionKeyword
  | WenyanReturnKeyword
  | WenyanTrueKeyword
  | WenyanFalseKeyword
  | WenyanLetKeyword
  (* 古雅体关键字 *)
  | ClassicalIfKeyword
  | ClassicalThenKeyword
  | ClassicalElseKeyword
  | ClassicalWhileKeyword
  | ClassicalForKeyword
  | ClassicalFunctionKeyword
  | ClassicalReturnKeyword
  | ClassicalTrueKeyword
  | ClassicalFalseKeyword
  | ClassicalLetKeyword
  (* 运算符Token *)
  | PlusOp
  | MinusOp
  | MultiplyOp
  | DivideOp
  | ModOp
  | PowerOp
  | EqualOp
  | NotEqualOp
  | LessOp
  | GreaterOp
  | LessEqualOp
  | GreaterEqualOp
  | LogicalAndOp
  | LogicalOrOp
  | LogicalNotOp
  | BitwiseAndOp
  | BitwiseOrOp
  | BitwiseXorOp
  | BitwiseNotOp
  | LeftShiftOp
  | RightShiftOp
  | AssignOp
  | PlusAssignOp
  | MinusAssignOp
  | MultiplyAssignOp
  | DivideAssignOp
  | AppendOp
  | ConsOp
  | ComposeOp
  | PipeOp
  | PipeBackOp
  | ArrowOp
  | DoubleArrowOp
  (* 分隔符Token *)
  | LeftParen
  | RightParen
  | LeftBracket
  | RightBracket
  | LeftBrace
  | RightBrace
  | Comma
  | Semicolon
  | Colon
  | DoubleColon
  | Dot
  | DoubleDot
  | TripleDot
  | Question
  | Exclamation
  | AtSymbol
  | SharpSymbol
  | DollarSymbol
  | Underscore
  | Backquote
  | SingleQuote
  | DoubleQuote
  | Backslash
  | VerticalBar
  | Ampersand
  | Tilde
  | Caret
  | Percent
  (* 特殊Token *)
  | EOF
  | Newline
  | Whitespace
  | Comment of string
  | LineComment of string
  | BlockComment of string
  | DocComment of string
  (* 错误Token *)
  | ErrorToken of string * position

type positioned_token = {
  token : unified_token;
  position : position;
  metadata : token_metadata option;
}
(** 带位置信息的Token *)

val string_of_token : unified_token -> string
(** Token到字符串的转换 *)

val make_positioned_token : unified_token -> position -> token_metadata option -> positioned_token
(** 创建带位置信息的token *)

val make_simple_token : unified_token -> string -> int -> int -> positioned_token
(** 创建简单的positioned token *)

val get_token_category : unified_token -> token_category
(** 获取token的分类 *)

val get_token_priority : unified_token -> token_priority
(** 获取token的默认优先级 *)

val equal_token : unified_token -> unified_token -> bool
(** Token相等性比较 *)

val default_position : string -> position
(** 创建默认位置 *)
