(** Token字符串转换模块 - 从unified_token_core.ml重构而来

    重构说明：将原来80行的巨大string_of_token函数按Token类别拆分为多个小函数， 显著提升代码的可维护性和可读性。
    第五阶段系统一致性优化：统一错误处理系统，替换failwith为统一错误处理。

    @author 骆言技术债务清理团队
    @version 2.2 (代码重复消除版)
    @since 2025-07-21 Issue #759 大型模块重构优化 *)

open Token_types_core
open Unified_errors

(** 统一的类型错误创建函数，消除重复的错误处理代码 *)
let create_token_type_error token_category =
  unified_error_to_exception (TypeError ("不是" ^ token_category ^ "Token"))

(** 转换字面量Token为字符串 *)
let string_of_literal_token = function
  | IntToken i -> string_of_int i
  | FloatToken f -> string_of_float f
  | StringToken s -> "\"" ^ s ^ "\""
  | BoolToken b -> string_of_bool b
  | ChineseNumberToken s -> s
  | UnitToken -> "()"
  | _ -> raise (create_token_type_error "字面量")

(** 转换标识符Token为字符串 *)
let string_of_identifier_token = function
  | IdentifierToken s
  | ConstructorToken s
  | IdentifierTokenSpecial s
  | ModuleNameToken s
  | TypeNameToken s ->
      s
  | QuotedIdentifierToken s -> "「" ^ s ^ "」"
  | _ -> raise (create_token_type_error "标识符")

(** 转换基础关键字Token为字符串 *)
let string_of_basic_keyword_token = function
  | LetKeyword -> "let"
  | FunKeyword -> "fun"
  | IfKeyword -> "if"
  | ThenKeyword -> "then"
  | ElseKeyword -> "else"
  | MatchKeyword -> "match"
  | WithKeyword -> "with"
  | WhenKeyword -> "when"
  | AndKeyword -> "and"
  | OrKeyword -> "or"
  | NotKeyword -> "not"
  | TrueKeyword -> "true"
  | FalseKeyword -> "false"
  | InKeyword -> "in"
  | RecKeyword -> "rec"
  | MutableKeyword -> "mutable"
  | RefKeyword -> "ref"
  | BeginKeyword -> "begin"
  | EndKeyword -> "end"
  | ForKeyword -> "for"
  | WhileKeyword -> "while"
  | DoKeyword -> "do"
  | DoneKeyword -> "done"
  | ToKeyword -> "to"
  | DowntoKeyword -> "downto"
  | BreakKeyword -> "break"
  | ContinueKeyword -> "continue"
  | ReturnKeyword -> "return"
  | TryKeyword -> "try"
  | RaiseKeyword -> "raise"
  | FailwithKeyword -> "failwith"
  | AssertKeyword -> "assert"
  | LazyKeyword -> "lazy"
  | ExceptionKeyword -> "exception"
  | ModuleKeyword -> "module"
  | StructKeyword -> "struct"
  | SigKeyword -> "sig"
  | FunctorKeyword -> "functor"
  | IncludeKeyword -> "include"
  | OpenKeyword -> "open"
  | TypeKeyword -> "type"
  | ValKeyword -> "val"
  | ExternalKeyword -> "external"
  | PrivateKeyword -> "private"
  | VirtualKeyword -> "virtual"
  | MethodKeyword -> "method"
  | InheritKeyword -> "inherit"
  | InitializerKeyword -> "initializer"
  | NewKeyword -> "new"
  | ObjectKeyword -> "object"
  | ClassKeyword -> "class"
  | ConstraintKeyword -> "constraint"
  | AsKeyword -> "as"
  | OfKeyword -> "of"
  | _ -> raise (create_token_type_error "基础关键字")

(** 转换数字关键字Token为字符串 *)
let string_of_number_keyword_token = function
  | ZeroKeyword -> "零"
  | OneKeyword -> "一"
  | TwoKeyword -> "二"
  | ThreeKeyword -> "三"
  | FourKeyword -> "四"
  | FiveKeyword -> "五"
  | SixKeyword -> "六"
  | SevenKeyword -> "七"
  | EightKeyword -> "八"
  | NineKeyword -> "九"
  | TenKeyword -> "十"
  | HundredKeyword -> "百"
  | ThousandKeyword -> "千"
  | TenThousandKeyword -> "万"
  | _ -> raise (create_token_type_error "数字关键字")

(** 转换类型关键字Token为字符串 *)
let string_of_type_keyword_token = function
  | IntTypeKeyword -> "int"
  | FloatTypeKeyword -> "float"
  | StringTypeKeyword -> "string"
  | BoolTypeKeyword -> "bool"
  | UnitTypeKeyword -> "unit"
  | ListTypeKeyword -> "list"
  | ArrayTypeKeyword -> "array"
  | RefTypeKeyword -> "ref"
  | FunctionTypeKeyword -> "function"
  | TupleTypeKeyword -> "tuple"
  | RecordTypeKeyword -> "record"
  | VariantTypeKeyword -> "variant"
  | OptionTypeKeyword -> "option"
  | ResultTypeKeyword -> "result"
  | _ -> raise (create_token_type_error "类型关键字")

(** 转换文言文关键字Token为字符串 *)
let string_of_wenyan_keyword_token = function
  | WenyanIfKeyword -> "若"
  | WenyanThenKeyword -> "则"
  | WenyanElseKeyword -> "不然"
  | WenyanWhileKeyword -> "当"
  | WenyanForKeyword -> "为"
  | WenyanFunctionKeyword -> "函数"
  | WenyanReturnKeyword -> "返回"
  | WenyanTrueKeyword -> "真"
  | WenyanFalseKeyword -> "假"
  | WenyanLetKeyword -> "设"
  | _ -> raise (create_token_type_error "文言文关键字")

(** 转换古雅体关键字Token为字符串 *)
let string_of_classical_keyword_token = function
  | ClassicalIfKeyword -> "倘"
  | ClassicalThenKeyword -> "便"
  | ClassicalElseKeyword -> "否则"
  | ClassicalWhileKeyword -> "当"
  | ClassicalForKeyword -> "遍"
  | ClassicalFunctionKeyword -> "函"
  | ClassicalReturnKeyword -> "返"
  | ClassicalTrueKeyword -> "是"
  | ClassicalFalseKeyword -> "否"
  | ClassicalLetKeyword -> "令"
  | _ -> raise (create_token_type_error "古雅体关键字")

(** 转换运算符Token为字符串 *)
let string_of_operator_token = function
  | PlusOp -> "+"
  | MinusOp -> "-"
  | MultiplyOp -> "*"
  | DivideOp -> "/"
  | ModOp -> "mod"
  | PowerOp -> "**"
  | EqualOp -> "="
  | NotEqualOp -> "<>"
  | LessOp -> "<"
  | GreaterOp -> ">"
  | LessEqualOp -> "<="
  | GreaterEqualOp -> ">="
  | LogicalAndOp -> "&&"
  | LogicalOrOp -> "||"
  | LogicalNotOp -> "not"
  | BitwiseAndOp -> "land"
  | BitwiseOrOp -> "lor"
  | BitwiseXorOp -> "lxor"
  | BitwiseNotOp -> "lnot"
  | LeftShiftOp -> "lsl"
  | RightShiftOp -> "lsr"
  | AssignOp -> ":="
  | PlusAssignOp -> "+="
  | MinusAssignOp -> "-="
  | MultiplyAssignOp -> "*="
  | DivideAssignOp -> "/="
  | AppendOp -> "@"
  | ConsOp -> "::"
  | ComposeOp -> "%"
  | PipeOp -> "|>"
  | PipeBackOp -> "<|"
  | ArrowOp -> "->"
  | DoubleArrowOp -> "=>"
  | _ -> raise (create_token_type_error "运算符")

(** 转换分隔符Token为字符串 *)
let string_of_delimiter_token = function
  | LeftParen -> "("
  | RightParen -> ")"
  | LeftBracket -> "["
  | RightBracket -> "]"
  | LeftBrace -> "{"
  | RightBrace -> "}"
  | Comma -> ","
  | Semicolon -> ";"
  | Colon -> ":"
  | DoubleColon -> "::"
  | Dot -> "."
  | DoubleDot -> ".."
  | TripleDot -> "..."
  | Question -> "?"
  | Exclamation -> "!"
  | AtSymbol -> "@"
  | SharpSymbol -> "#"
  | DollarSymbol -> "$"
  | Underscore -> "_"
  | Backquote -> "`"
  | SingleQuote -> "'"
  | DoubleQuote -> "\""
  | Backslash -> "\\"
  | VerticalBar -> "|"
  | Ampersand -> "&"
  | Tilde -> "~"
  | Caret -> "^"
  | Percent -> "%"
  | _ -> raise (create_token_type_error "分隔符")

(** 转换特殊Token为字符串 *)
let string_of_special_token = function
  | EOF -> "<EOF>"
  | Newline -> "\\n"
  | Whitespace -> " "
  | Comment s -> "(* " ^ s ^ " *)"
  | LineComment s -> "// " ^ s
  | BlockComment s -> "(* " ^ s ^ " *)"
  | DocComment s -> "(** " ^ s ^ " *)"
  | ErrorToken (s, _) -> "<ERROR: " ^ s ^ ">"
  | _ -> raise (create_token_type_error "特殊")

(** 将Token转换为字符串表示（重构后的主函数）

    使用模式分类的方式，将不同类型的Token分发到对应的处理函数， 大幅提升了代码的可读性和可维护性。 第五阶段系统一致性优化：使用统一错误处理Result类型。 *)
let string_of_token_safe token =
  safe_execute (fun () ->
      match token with
      (* 字面量Token *)
      | IntToken _ | FloatToken _ | StringToken _ | BoolToken _ | ChineseNumberToken _ | UnitToken
        ->
          string_of_literal_token token
      (* 标识符Token *)
      | IdentifierToken _ | ConstructorToken _ | IdentifierTokenSpecial _ | ModuleNameToken _
      | TypeNameToken _ | QuotedIdentifierToken _ ->
          string_of_identifier_token token
      (* 数字关键字Token *)
      | ZeroKeyword | OneKeyword | TwoKeyword | ThreeKeyword | FourKeyword | FiveKeyword
      | SixKeyword | SevenKeyword | EightKeyword | NineKeyword | TenKeyword | HundredKeyword
      | ThousandKeyword | TenThousandKeyword ->
          string_of_number_keyword_token token
      (* 类型关键字Token *)
      | IntTypeKeyword | FloatTypeKeyword | StringTypeKeyword | BoolTypeKeyword | UnitTypeKeyword
      | ListTypeKeyword | ArrayTypeKeyword | RefTypeKeyword | FunctionTypeKeyword | TupleTypeKeyword
      | RecordTypeKeyword | VariantTypeKeyword | OptionTypeKeyword | ResultTypeKeyword ->
          string_of_type_keyword_token token
      (* 文言文关键字Token *)
      | WenyanIfKeyword | WenyanThenKeyword | WenyanElseKeyword | WenyanWhileKeyword
      | WenyanForKeyword | WenyanFunctionKeyword | WenyanReturnKeyword | WenyanTrueKeyword
      | WenyanFalseKeyword | WenyanLetKeyword ->
          string_of_wenyan_keyword_token token
      (* 古雅体关键字Token *)
      | ClassicalIfKeyword | ClassicalThenKeyword | ClassicalElseKeyword | ClassicalWhileKeyword
      | ClassicalForKeyword | ClassicalFunctionKeyword | ClassicalReturnKeyword
      | ClassicalTrueKeyword | ClassicalFalseKeyword | ClassicalLetKeyword ->
          string_of_classical_keyword_token token
      (* 运算符Token *)
      | PlusOp | MinusOp | MultiplyOp | DivideOp | ModOp | PowerOp | EqualOp | NotEqualOp | LessOp
      | GreaterOp | LessEqualOp | GreaterEqualOp | LogicalAndOp | LogicalOrOp | LogicalNotOp
      | BitwiseAndOp | BitwiseOrOp | BitwiseXorOp | BitwiseNotOp | LeftShiftOp | RightShiftOp
      | AssignOp | PlusAssignOp | MinusAssignOp | MultiplyAssignOp | DivideAssignOp | AppendOp
      | ConsOp | ComposeOp | PipeOp | PipeBackOp | ArrowOp | DoubleArrowOp ->
          string_of_operator_token token
      (* 分隔符Token *)
      | LeftParen | RightParen | LeftBracket | RightBracket | LeftBrace | RightBrace | Comma
      | Semicolon | Colon | DoubleColon | Dot | DoubleDot | TripleDot | Question | Exclamation
      | AtSymbol | SharpSymbol | DollarSymbol | Underscore | Backquote | SingleQuote | DoubleQuote
      | Backslash | VerticalBar | Ampersand | Tilde | Caret | Percent ->
          string_of_delimiter_token token
      (* 特殊Token *)
      | EOF | Newline | Whitespace | Comment _ | LineComment _ | BlockComment _ | DocComment _
      | ErrorToken _ ->
          string_of_special_token token
      (* 基础关键字Token - 放在最后作为默认情况 *)
      | _ -> string_of_basic_keyword_token token)

(** 兼容性函数：保持与现有代码的兼容性 *)
let string_of_token token =
  match string_of_token_safe token with Ok result -> result | Error _ -> "<UNKNOWN_TOKEN>"
