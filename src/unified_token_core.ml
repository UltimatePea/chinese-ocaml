(** 统一Token核心系统 - 简化重构版本
    减少文件长度，保持自包含，避免循环依赖 *)

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

(** Token分类检查模块 - 模块化但在同一文件内 *)
module TokenCategoryChecker = struct
  let is_literal_token = function
    | IntToken _ | FloatToken _ | StringToken _ | BoolToken _ 
    | ChineseNumberToken _ | UnitToken -> true | _ -> false
    
  let is_identifier_token = function
    | IdentifierToken _ | QuotedIdentifierToken _ | ConstructorToken _ 
    | IdentifierTokenSpecial _ | ModuleNameToken _ | TypeNameToken _ -> true | _ -> false
    
  let is_basic_keyword_token = function
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
    | AsKeyword | OfKeyword -> true | _ -> false
    
  let is_number_keyword_token = function
    | ZeroKeyword | OneKeyword | TwoKeyword | ThreeKeyword | FourKeyword
    | FiveKeyword | SixKeyword | SevenKeyword | EightKeyword | NineKeyword
    | TenKeyword | HundredKeyword | ThousandKeyword | TenThousandKeyword -> true | _ -> false
    
  let is_type_keyword_token = function
    | IntTypeKeyword | FloatTypeKeyword | StringTypeKeyword | BoolTypeKeyword
    | UnitTypeKeyword | ListTypeKeyword | ArrayTypeKeyword | RefTypeKeyword
    | FunctionTypeKeyword | TupleTypeKeyword | RecordTypeKeyword | VariantTypeKeyword
    | OptionTypeKeyword | ResultTypeKeyword -> true | _ -> false
    
  let is_wenyan_keyword_token = function
    | WenyanIfKeyword | WenyanThenKeyword | WenyanElseKeyword | WenyanWhileKeyword
    | WenyanForKeyword | WenyanFunctionKeyword | WenyanReturnKeyword
    | WenyanTrueKeyword | WenyanFalseKeyword | WenyanLetKeyword -> true | _ -> false
    
  let is_classical_keyword_token = function
    | ClassicalIfKeyword | ClassicalThenKeyword | ClassicalElseKeyword
    | ClassicalWhileKeyword | ClassicalForKeyword | ClassicalFunctionKeyword
    | ClassicalReturnKeyword | ClassicalTrueKeyword | ClassicalFalseKeyword
    | ClassicalLetKeyword -> true | _ -> false
    
  let is_keyword_token token =
    is_basic_keyword_token token || is_number_keyword_token token ||
    is_type_keyword_token token || is_wenyan_keyword_token token ||
    is_classical_keyword_token token
    
  let is_operator_token = function
    | PlusOp | MinusOp | MultiplyOp | DivideOp | ModOp | PowerOp
    | EqualOp | NotEqualOp | LessOp | GreaterOp | LessEqualOp | GreaterEqualOp
    | LogicalAndOp | LogicalOrOp | LogicalNotOp
    | BitwiseAndOp | BitwiseOrOp | BitwiseXorOp | BitwiseNotOp
    | LeftShiftOp | RightShiftOp
    | AssignOp | PlusAssignOp | MinusAssignOp | MultiplyAssignOp | DivideAssignOp
    | AppendOp | ConsOp | ComposeOp | PipeOp | PipeBackOp | ArrowOp | DoubleArrowOp -> true | _ -> false
    
  let is_delimiter_token = function
    | LeftParen | RightParen | LeftBracket | RightBracket | LeftBrace | RightBrace
    | Comma | Semicolon | Colon | DoubleColon | Dot | DoubleDot | TripleDot
    | Question | Exclamation | AtSymbol | SharpSymbol | DollarSymbol
    | Underscore | Backquote | SingleQuote | DoubleQuote | Backslash
    | VerticalBar | Ampersand | Tilde | Caret | Percent -> true | _ -> false
    
  let is_special_token = function
    | EOF | Newline | Whitespace | Comment _ | LineComment _ | BlockComment _ 
    | DocComment _ | ErrorToken _ -> true | _ -> false
end

(** 获取Token分类 *)
let get_token_category token =
  if TokenCategoryChecker.is_literal_token token then Literal
  else if TokenCategoryChecker.is_identifier_token token then Identifier
  else if TokenCategoryChecker.is_keyword_token token then Keyword
  else if TokenCategoryChecker.is_operator_token token then Operator
  else if TokenCategoryChecker.is_delimiter_token token then Delimiter
  else if TokenCategoryChecker.is_special_token token then Special
  else failwith "Unknown token category"

(** 简化的内联转换函数 - 无外部依赖 *)
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

(** 工具函数 *)
let make_positioned_token token position metadata = { token; position; metadata }

let make_simple_token token filename line column =
  let position = { filename; line; column; offset = 0 } in
  { token; position; metadata = None }

let get_token_priority token =
  match get_token_category token with
  | Keyword -> HighPriority
  | Operator | Delimiter -> MediumPriority
  | Literal | Identifier | Special -> LowPriority

let default_position filename = { filename; line = 1; column = 1; offset = 0 }

(* 简化的equal_token函数 - 只比较token构造器 *)
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
  | a, b when a = b -> true  (* 对于不携带数据的构造器 *)
  | _ -> false