(** Token工具函数模块 - 从unified_token_core.ml重构而来 *)

open Token_system_unified_core.Token_types_core

(** 工具函数 *)
let make_positioned_token token position metadata = { token; position; metadata }

let make_simple_token token filename line column =
  let position = { filename; line; column; offset = 0 } in
  { token; position; metadata = None }

let get_token_priority token =
  match token with
  (* 关键字 - 高优先级 *)
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
  | ZeroKeyword | OneKeyword | TwoKeyword | ThreeKeyword | FourKeyword
  | FiveKeyword | SixKeyword | SevenKeyword | EightKeyword | NineKeyword
  | TenKeyword | HundredKeyword | ThousandKeyword | TenThousandKeyword
  | IntTypeKeyword | FloatTypeKeyword | StringTypeKeyword | BoolTypeKeyword
  | UnitTypeKeyword | ListTypeKeyword | ArrayTypeKeyword | RefTypeKeyword
  | FunctionTypeKeyword | TupleTypeKeyword | RecordTypeKeyword
  | VariantTypeKeyword | OptionTypeKeyword | ResultTypeKeyword
  | WenyanIfKeyword | WenyanThenKeyword | WenyanElseKeyword
  | WenyanWhileKeyword | WenyanForKeyword | WenyanFunctionKeyword
  | WenyanReturnKeyword | WenyanTrueKeyword | WenyanFalseKeyword | WenyanLetKeyword
  | ClassicalIfKeyword | ClassicalThenKeyword | ClassicalElseKeyword
  | ClassicalWhileKeyword | ClassicalForKeyword | ClassicalFunctionKeyword
  | ClassicalReturnKeyword | ClassicalTrueKeyword | ClassicalFalseKeyword
  | ClassicalLetKeyword -> HighPriority
  (* 运算符和分隔符 - 中优先级 *)
  | PlusOp | MinusOp | MultiplyOp | DivideOp | ModOp | PowerOp
  | EqualOp | NotEqualOp | LessOp | GreaterOp | LessEqualOp | GreaterEqualOp
  | LogicalAndOp | LogicalOrOp | LogicalNotOp | BitwiseAndOp | BitwiseOrOp
  | BitwiseXorOp | BitwiseNotOp | LeftShiftOp | RightShiftOp
  | AssignOp | PlusAssignOp | MinusAssignOp | MultiplyAssignOp | DivideAssignOp
  | AppendOp | ConsOp | ComposeOp | PipeOp | PipeBackOp | ArrowOp | DoubleArrowOp
  | LeftParen | RightParen | LeftBracket | RightBracket | LeftBrace | RightBrace
  | Comma | Semicolon | Colon | DoubleColon | Dot | DoubleDot | TripleDot
  | Question | Exclamation | AtSymbol | SharpSymbol | DollarSymbol
  | Underscore | Backquote | SingleQuote | DoubleQuote | Backslash
  | VerticalBar | Ampersand | Tilde | Caret | Percent -> MediumPriority
  (* 字面量、标识符和特殊token - 低优先级 *)
  | IntToken _ | FloatToken _ | StringToken _ | BoolToken _ | ChineseNumberToken _
  | UnitToken | IdentifierToken _ | QuotedIdentifierToken _ | ConstructorToken _
  | IdentifierTokenSpecial _ | ModuleNameToken _ | TypeNameToken _
  | EOF | Newline | Whitespace | Comment _ | LineComment _ | BlockComment _
  | DocComment _ | ErrorToken _ -> LowPriority

let default_position filename = { filename; line = 1; column = 1; offset = 0 }

(** 简化的equal_token函数 - 只比较token构造器 *)
let equal_token t1 t2 =
  match (t1, t2) with
  | IntToken i1, IntToken i2 -> i1 = i2
  | FloatToken f1, FloatToken f2 -> Float.equal f1 f2
  | StringToken s1, StringToken s2 -> String.equal s1 s2
  | BoolToken b1, BoolToken b2 -> Bool.equal b1 b2
  | ChineseNumberToken s1, ChineseNumberToken s2 -> String.equal s1 s2
  | UnitToken, UnitToken -> true
  | IdentifierToken s1, IdentifierToken s2 -> String.equal s1 s2
  | QuotedIdentifierToken s1, QuotedIdentifierToken s2 -> String.equal s1 s2
  | ConstructorToken s1, ConstructorToken s2 -> String.equal s1 s2
  | IdentifierTokenSpecial s1, IdentifierTokenSpecial s2 -> String.equal s1 s2
  | ModuleNameToken s1, ModuleNameToken s2 -> String.equal s1 s2
  | TypeNameToken s1, TypeNameToken s2 -> String.equal s1 s2
  | Comment s1, Comment s2 -> String.equal s1 s2
  | LineComment s1, LineComment s2 -> String.equal s1 s2
  | BlockComment s1, BlockComment s2 -> String.equal s1 s2
  | DocComment s1, DocComment s2 -> String.equal s1 s2
  | ErrorToken (s1, _), ErrorToken (s2, _) -> String.equal s1 s2
  | EOF, EOF | Newline, Newline | Whitespace, Whitespace -> true
  | a, b when a = b -> true (* 对于不携带数据的构造器 *)
  | _ -> false
