(** Token字符串转换模块 - 从unified_token_core.ml重构而来 *)

open Token_types_core

(** 将Token转换为字符串表示 *)
let string_of_token token =
  match token with
  (* 字面量 *)
  | IntToken i -> string_of_int i | FloatToken f -> string_of_float f
  | StringToken s -> "\"" ^ s ^ "\"" | BoolToken b -> string_of_bool b
  | ChineseNumberToken s -> s | UnitToken -> "()"
  (* 标识符 *)
  | IdentifierToken s | ConstructorToken s | IdentifierTokenSpecial s 
  | ModuleNameToken s | TypeNameToken s -> s
  | QuotedIdentifierToken s -> "「" ^ s ^ "」"
  (* 基础关键字 *)
  | LetKeyword -> "let" | FunKeyword -> "fun" | IfKeyword -> "if"
  | ThenKeyword -> "then" | ElseKeyword -> "else" | MatchKeyword -> "match"
  | WithKeyword -> "with" | WhenKeyword -> "when" | AndKeyword -> "and"
  | OrKeyword -> "or" | NotKeyword -> "not" | TrueKeyword -> "true"
  | FalseKeyword -> "false" | InKeyword -> "in" | RecKeyword -> "rec"
  | MutableKeyword -> "mutable" | RefKeyword -> "ref" | BeginKeyword -> "begin"
  | EndKeyword -> "end" | ForKeyword -> "for" | WhileKeyword -> "while"
  | DoKeyword -> "do" | DoneKeyword -> "done" | ToKeyword -> "to"
  | DowntoKeyword -> "downto" | BreakKeyword -> "break" | ContinueKeyword -> "continue"
  | ReturnKeyword -> "return" | TryKeyword -> "try" | RaiseKeyword -> "raise"
  | FailwithKeyword -> "failwith" | AssertKeyword -> "assert" | LazyKeyword -> "lazy"
  | ExceptionKeyword -> "exception" | ModuleKeyword -> "module" | StructKeyword -> "struct"
  | SigKeyword -> "sig" | FunctorKeyword -> "functor" | IncludeKeyword -> "include"
  | OpenKeyword -> "open" | TypeKeyword -> "type" | ValKeyword -> "val"
  | ExternalKeyword -> "external" | PrivateKeyword -> "private" | VirtualKeyword -> "virtual"
  | MethodKeyword -> "method" | InheritKeyword -> "inherit" | InitializerKeyword -> "initializer"
  | NewKeyword -> "new" | ObjectKeyword -> "object" | ClassKeyword -> "class"
  | ConstraintKeyword -> "constraint" | AsKeyword -> "as" | OfKeyword -> "of"
  (* 数字关键字 *)
  | ZeroKeyword -> "零" | OneKeyword -> "一" | TwoKeyword -> "二" | ThreeKeyword -> "三"
  | FourKeyword -> "四" | FiveKeyword -> "五" | SixKeyword -> "六" | SevenKeyword -> "七"
  | EightKeyword -> "八" | NineKeyword -> "九" | TenKeyword -> "十"
  | HundredKeyword -> "百" | ThousandKeyword -> "千" | TenThousandKeyword -> "万"
  (* 类型关键字 *)
  | IntTypeKeyword -> "int" | FloatTypeKeyword -> "float" | StringTypeKeyword -> "string"
  | BoolTypeKeyword -> "bool" | UnitTypeKeyword -> "unit" | ListTypeKeyword -> "list"
  | ArrayTypeKeyword -> "array" | RefTypeKeyword -> "ref" | FunctionTypeKeyword -> "function"
  | TupleTypeKeyword -> "tuple" | RecordTypeKeyword -> "record" | VariantTypeKeyword -> "variant"
  | OptionTypeKeyword -> "option" | ResultTypeKeyword -> "result"
  (* 文言文关键字 *)
  | WenyanIfKeyword -> "若" | WenyanThenKeyword -> "则" | WenyanElseKeyword -> "不然"
  | WenyanWhileKeyword -> "当" | WenyanForKeyword -> "为" | WenyanFunctionKeyword -> "函数"
  | WenyanReturnKeyword -> "返回" | WenyanTrueKeyword -> "真" | WenyanFalseKeyword -> "假"
  | WenyanLetKeyword -> "设"
  (* 古雅体关键字 *)
  | ClassicalIfKeyword -> "倘" | ClassicalThenKeyword -> "便" | ClassicalElseKeyword -> "否则"
  | ClassicalWhileKeyword -> "当" | ClassicalForKeyword -> "遍" | ClassicalFunctionKeyword -> "函"
  | ClassicalReturnKeyword -> "返" | ClassicalTrueKeyword -> "是" | ClassicalFalseKeyword -> "否"
  | ClassicalLetKeyword -> "令"
  (* 运算符 *)
  | PlusOp -> "+" | MinusOp -> "-" | MultiplyOp -> "*" | DivideOp -> "/"
  | ModOp -> "mod" | PowerOp -> "**" | EqualOp -> "=" | NotEqualOp -> "<>"
  | LessOp -> "<" | GreaterOp -> ">" | LessEqualOp -> "<=" | GreaterEqualOp -> ">="
  | LogicalAndOp -> "&&" | LogicalOrOp -> "||" | LogicalNotOp -> "not"
  | BitwiseAndOp -> "land" | BitwiseOrOp -> "lor" | BitwiseXorOp -> "lxor"
  | BitwiseNotOp -> "lnot" | LeftShiftOp -> "lsl" | RightShiftOp -> "lsr"
  | AssignOp -> ":=" | PlusAssignOp -> "+=" | MinusAssignOp -> "-="
  | MultiplyAssignOp -> "*=" | DivideAssignOp -> "/=" | AppendOp -> "@"
  | ConsOp -> "::" | ComposeOp -> "%" | PipeOp -> "|>" | PipeBackOp -> "<|"
  | ArrowOp -> "->" | DoubleArrowOp -> "=>"
  (* 分隔符 *)
  | LeftParen -> "(" | RightParen -> ")" | LeftBracket -> "[" | RightBracket -> "]"
  | LeftBrace -> "{" | RightBrace -> "}" | Comma -> "," | Semicolon -> ";"
  | Colon -> ":" | DoubleColon -> "::" | Dot -> "." | DoubleDot -> ".."
  | TripleDot -> "..." | Question -> "?" | Exclamation -> "!" | AtSymbol -> "@"
  | SharpSymbol -> "#" | DollarSymbol -> "$" | Underscore -> "_"
  | Backquote -> "`" | SingleQuote -> "'" | DoubleQuote -> "\""
  | Backslash -> "\\" | VerticalBar -> "|" | Ampersand -> "&"
  | Tilde -> "~" | Caret -> "^" | Percent -> "%"
  (* 特殊Token *)
  | EOF -> "<EOF>" | Newline -> "\\n" | Whitespace -> " "
  | Comment s -> "(* " ^ s ^ " *)" | LineComment s -> "// " ^ s
  | BlockComment s -> "(* " ^ s ^ " *)" | DocComment s -> "(** " ^ s ^ " *)"
  | ErrorToken (s, _) -> "<ERROR: " ^ s ^ ">"