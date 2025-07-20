(** 核心Token类型定义模块接口 *)

(** Token优先级定义 *)
type token_priority =
  | HighPriority  (** 高优先级：关键字、保留字 *)
  | MediumPriority  (** 中优先级：运算符、分隔符 *)
  | LowPriority  (** 低优先级：标识符、字面量 *)

(** Token分类 *)
type token_category =
  | Literal  (** 字面量 *)
  | Identifier  (** 标识符 *)
  | Keyword  (** 关键字 *)
  | Operator  (** 运算符 *)
  | Delimiter  (** 分隔符 *)
  | Special  (** 特殊token *)

(** 位置信息 *)
type position = { 
  filename : string; 
  line : int; 
  column : int; 
  offset : int 
}

(** Token元数据 *)
type token_metadata = {
  category : token_category;
  priority : token_priority;
  description : string;
  chinese_name : string option;  (** 中文名称 *)
  aliases : string list;  (** 别名列表 *)
  deprecated : bool;  (** 是否已弃用 *)
}

(** 统一的Token定义 *)
type unified_token =
  (* 字面量Token *)
  | IntToken of int | FloatToken of float | StringToken of string | BoolToken of bool
  | ChineseNumberToken of string | UnitToken
  (* 标识符Token *)
  | IdentifierToken of string | QuotedIdentifierToken of string | ConstructorToken of string
  | IdentifierTokenSpecial of string | ModuleNameToken of string | TypeNameToken of string
  (* 基础关键字Token *)
  | LetKeyword | FunKeyword | IfKeyword | ThenKeyword | ElseKeyword
  | MatchKeyword | WithKeyword | WhenKeyword | AndKeyword | OrKeyword
  | NotKeyword | TrueKeyword | FalseKeyword | InKeyword | RecKeyword
  | MutableKeyword | RefKeyword | BeginKeyword | EndKeyword
  | ForKeyword | WhileKeyword | DoKeyword | DoneKeyword | ToKeyword
  | DowntoKeyword | BreakKeyword | ContinueKeyword | ReturnKeyword
  | TryKeyword | RaiseKeyword | FailwithKeyword | AssertKeyword
  | LazyKeyword | ExceptionKeyword | ModuleKeyword | StructKeyword
  | SigKeyword | FunctorKeyword | IncludeKeyword | OpenKeyword
  | TypeKeyword | ValKeyword | ExternalKeyword | PrivateKeyword
  | VirtualKeyword | MethodKeyword | InheritKeyword | InitializerKeyword
  | NewKeyword | ObjectKeyword | ClassKeyword | ConstraintKeyword
  | AsKeyword | OfKeyword
  (* 数字关键字Token *)
  | ZeroKeyword | OneKeyword | TwoKeyword | ThreeKeyword | FourKeyword
  | FiveKeyword | SixKeyword | SevenKeyword | EightKeyword | NineKeyword
  | TenKeyword | HundredKeyword | ThousandKeyword | TenThousandKeyword
  (* 类型关键字Token *)
  | IntTypeKeyword | FloatTypeKeyword | StringTypeKeyword | BoolTypeKeyword
  | UnitTypeKeyword | ListTypeKeyword | ArrayTypeKeyword | RefTypeKeyword
  | FunctionTypeKeyword | TupleTypeKeyword | RecordTypeKeyword | VariantTypeKeyword
  | OptionTypeKeyword | ResultTypeKeyword
  (* 文言文关键字Token *)
  | WenyanIfKeyword | WenyanThenKeyword | WenyanElseKeyword | WenyanWhileKeyword
  | WenyanForKeyword | WenyanFunctionKeyword | WenyanReturnKeyword
  | WenyanTrueKeyword | WenyanFalseKeyword | WenyanLetKeyword
  (* 古雅体关键字Token *)
  | ClassicalIfKeyword | ClassicalThenKeyword | ClassicalElseKeyword
  | ClassicalWhileKeyword | ClassicalForKeyword | ClassicalFunctionKeyword
  | ClassicalReturnKeyword | ClassicalTrueKeyword | ClassicalFalseKeyword
  | ClassicalLetKeyword
  (* 运算符Token *)
  | PlusOp | MinusOp | MultiplyOp | DivideOp | ModOp | PowerOp
  | EqualOp | NotEqualOp | LessOp | GreaterOp | LessEqualOp | GreaterEqualOp
  | LogicalAndOp | LogicalOrOp | LogicalNotOp
  | BitwiseAndOp | BitwiseOrOp | BitwiseXorOp | BitwiseNotOp
  | LeftShiftOp | RightShiftOp
  | AssignOp | PlusAssignOp | MinusAssignOp | MultiplyAssignOp | DivideAssignOp
  | AppendOp | ConsOp | ComposeOp | PipeOp | PipeBackOp | ArrowOp | DoubleArrowOp
  (* 分隔符Token *)
  | LeftParen | RightParen | LeftBracket | RightBracket | LeftBrace | RightBrace
  | Comma | Semicolon | Colon | DoubleColon | Dot | DoubleDot | TripleDot
  | Question | Exclamation | AtSymbol | SharpSymbol | DollarSymbol
  | Underscore | Backquote | SingleQuote | DoubleQuote | Backslash
  | VerticalBar | Ampersand | Tilde | Caret | Percent
  (* 特殊Token *)
  | EOF | Newline | Whitespace
  | Comment of string | LineComment of string | BlockComment of string | DocComment of string
  (* 错误Token *)
  | ErrorToken of string * position

(** 带位置信息的Token *)
type positioned_token = {
  token : unified_token;
  position : position;
  metadata : token_metadata option;
}