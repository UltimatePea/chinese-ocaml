(** Token字符串转换模块 - 优化重构版本

    从300行优化为紧凑结构，提升可维护性 第六阶段技术债务清理：内部函数重组，消除冗余

    @author 骆言技术债务清理团队
    @version 3.0 (第六阶段优化版)
    @since 2025-07-21 Issue #788 超长文件重构优化 *)

open Token_types_core
open Unified_errors

(** 统一的类型错误创建函数 *)
let create_token_type_error category =
  unified_error_to_exception (TypeError ("不是" ^ category ^ "Token"))

(** 字面量Token转换表 *)
let literal_table = function
  | IntToken i -> string_of_int i
  | FloatToken f -> string_of_float f
  | StringToken s -> "\"" ^ s ^ "\""
  | BoolToken b -> string_of_bool b
  | ChineseNumberToken s -> s
  | UnitToken -> "()"
  | _ -> raise (create_token_type_error "字面量")

(** 标识符Token转换表 *)
let identifier_table = function
  | IdentifierToken s
  | ConstructorToken s
  | IdentifierTokenSpecial s
  | ModuleNameToken s
  | TypeNameToken s ->
      s
  | QuotedIdentifierToken s -> "「" ^ s ^ "」"
  | _ -> raise (create_token_type_error "标识符")

(** 控制流关键字Token转换表 *)
let control_flow_mappings =
  [
    (IfKeyword, "if");
    (ThenKeyword, "then");
    (ElseKeyword, "else");
    (MatchKeyword, "match");
    (WithKeyword, "with");
    (WhenKeyword, "when");
    (ForKeyword, "for");
    (WhileKeyword, "while");
    (DoKeyword, "do");
    (DoneKeyword, "done");
    (ToKeyword, "to");
    (DowntoKeyword, "downto");
    (BreakKeyword, "break");
    (ContinueKeyword, "continue");
    (ReturnKeyword, "return");
    (TryKeyword, "try");
    (RaiseKeyword, "raise");
    (FailwithKeyword, "failwith");
  ]

(** 变量和函数定义关键字Token转换表 *)
let definition_mappings =
  [
    (LetKeyword, "let");
    (FunKeyword, "fun");
    (RecKeyword, "rec");
    (MutableKeyword, "mutable");
    (RefKeyword, "ref");
    (InKeyword, "in");
    (LazyKeyword, "lazy");
    (AndKeyword, "and");
    (AsKeyword, "as");
    (OfKeyword, "of");
  ]

(** 模块和类型系统关键字Token转换表 *)
let module_type_mappings =
  [
    (ModuleKeyword, "module");
    (StructKeyword, "struct");
    (SigKeyword, "sig");
    (FunctorKeyword, "functor");
    (IncludeKeyword, "include");
    (OpenKeyword, "open");
    (TypeKeyword, "type");
    (ValKeyword, "val");
    (ExternalKeyword, "external");
    (PrivateKeyword, "private");
    (VirtualKeyword, "virtual");
    (ConstraintKeyword, "constraint");
  ]

(** 面向对象关键字Token转换表 *)
let object_oriented_mappings =
  [
    (MethodKeyword, "method");
    (InheritKeyword, "inherit");
    (InitializerKeyword, "initializer");
    (NewKeyword, "new");
    (ObjectKeyword, "object");
    (ClassKeyword, "class");
  ]

(** 基础值和逻辑关键字Token转换表 *)
let basic_value_mappings =
  [
    (TrueKeyword, "true");
    (FalseKeyword, "false");
    (OrKeyword, "or");
    (NotKeyword, "not");
    (BeginKeyword, "begin");
    (EndKeyword, "end");
    (AssertKeyword, "assert");
  ]

(** 合并的基础关键字映射表 - 向后兼容性保证 *)
let keyword_mappings =
  control_flow_mappings @ definition_mappings @ module_type_mappings @ object_oriented_mappings
  @ basic_value_mappings

(** 数字关键字Token转换表 *)
let number_mappings =
  [
    (ZeroKeyword, "零");
    (OneKeyword, "一");
    (TwoKeyword, "二");
    (ThreeKeyword, "三");
    (FourKeyword, "四");
    (FiveKeyword, "五");
    (SixKeyword, "六");
    (SevenKeyword, "七");
    (EightKeyword, "八");
    (NineKeyword, "九");
    (TenKeyword, "十");
    (HundredKeyword, "百");
    (ThousandKeyword, "千");
    (TenThousandKeyword, "万");
  ]

(** 类型关键字Token转换表 *)
let type_mappings =
  [
    (IntTypeKeyword, "int");
    (FloatTypeKeyword, "float");
    (StringTypeKeyword, "string");
    (BoolTypeKeyword, "bool");
    (UnitTypeKeyword, "unit");
    (ListTypeKeyword, "list");
    (ArrayTypeKeyword, "array");
    (RefTypeKeyword, "ref");
    (FunctionTypeKeyword, "function");
    (TupleTypeKeyword, "tuple");
    (RecordTypeKeyword, "record");
    (VariantTypeKeyword, "variant");
    (OptionTypeKeyword, "option");
    (ResultTypeKeyword, "result");
  ]

(** 文言文关键字Token转换表 *)
let wenyan_mappings =
  [
    (WenyanIfKeyword, "若");
    (WenyanThenKeyword, "则");
    (WenyanElseKeyword, "不然");
    (WenyanWhileKeyword, "当");
    (WenyanForKeyword, "为");
    (WenyanFunctionKeyword, "函数");
    (WenyanReturnKeyword, "返回");
    (WenyanTrueKeyword, "真");
    (WenyanFalseKeyword, "假");
    (WenyanLetKeyword, "设");
  ]

(** 古雅体关键字Token转换表 *)
let classical_mappings =
  [
    (ClassicalIfKeyword, "倘");
    (ClassicalThenKeyword, "便");
    (ClassicalElseKeyword, "否则");
    (ClassicalWhileKeyword, "当");
    (ClassicalForKeyword, "遍");
    (ClassicalFunctionKeyword, "函");
    (ClassicalReturnKeyword, "返");
    (ClassicalTrueKeyword, "是");
    (ClassicalFalseKeyword, "否");
    (ClassicalLetKeyword, "令");
  ]

(** 运算符Token转换表 *)
let operator_mappings =
  [
    (PlusOp, "+");
    (MinusOp, "-");
    (MultiplyOp, "*");
    (DivideOp, "/");
    (ModOp, "mod");
    (PowerOp, "**");
    (EqualOp, "=");
    (NotEqualOp, "<>");
    (LessOp, "<");
    (GreaterOp, ">");
    (LessEqualOp, "<=");
    (GreaterEqualOp, ">=");
    (LogicalAndOp, "&&");
    (LogicalOrOp, "||");
    (LogicalNotOp, "not");
    (BitwiseAndOp, "land");
    (BitwiseOrOp, "lor");
    (BitwiseXorOp, "lxor");
    (BitwiseNotOp, "lnot");
    (LeftShiftOp, "lsl");
    (RightShiftOp, "lsr");
    (AssignOp, ":=");
    (PlusAssignOp, "+=");
    (MinusAssignOp, "-=");
    (MultiplyAssignOp, "*=");
    (DivideAssignOp, "/=");
    (AppendOp, "@");
    (ConsOp, "::");
    (ComposeOp, "%");
    (PipeOp, "|>");
    (PipeBackOp, "<|");
    (ArrowOp, "->");
    (DoubleArrowOp, "=>");
  ]

(** 分隔符Token转换表 *)
let delimiter_mappings =
  [
    (LeftParen, "(");
    (RightParen, ")");
    (LeftBracket, "[");
    (RightBracket, "]");
    (LeftBrace, "{");
    (RightBrace, "}");
    (Comma, ",");
    (Semicolon, ";");
    (Colon, ":");
    (DoubleColon, "::");
    (Dot, ".");
    (DoubleDot, "..");
    (TripleDot, "...");
    (Question, "?");
    (Exclamation, "!");
    (AtSymbol, "@");
    (SharpSymbol, "#");
    (DollarSymbol, "$");
    (Underscore, "_");
    (Backquote, "`");
    (SingleQuote, "'");
    (DoubleQuote, "\"");
    (Backslash, "\\");
    (VerticalBar, "|");
    (Ampersand, "&");
    (Tilde, "~");
    (Caret, "^");
    (Percent, "%");
  ]

(** 统一的表格查找器 - 消除错误处理重复 *)
let lookup_in_table mappings token fallback =
  try List.assoc token mappings with Not_found -> fallback ()

(** 统一的类型化表格查找器 - 自动生成错误消息 *)
let lookup_in_typed_table mappings token type_name =
  lookup_in_table mappings token (fun () -> raise (create_token_type_error type_name))

(** 特殊Token转换 *)
let special_table = function
  | EOF -> "<EOF>"
  | Newline -> "\\n"
  | Whitespace -> " "
  | Comment s -> "(* " ^ s ^ " *)"
  | LineComment s -> "// " ^ s
  | BlockComment s -> "(* " ^ s ^ " *)"
  | DocComment s -> "(** " ^ s ^ " *)"
  | ErrorToken (s, _) -> "<ERROR: " ^ s ^ ">"
  | _ -> raise (create_token_type_error "特殊")

(** 主分类器和转换器 *)
let classify_and_convert_token token =
  match token with
  (* 直接处理的类型 *)
  | IntToken _ | FloatToken _ | StringToken _ | BoolToken _ | ChineseNumberToken _ | UnitToken ->
      literal_table token
  | IdentifierToken _ | ConstructorToken _ | IdentifierTokenSpecial _ | ModuleNameToken _
  | TypeNameToken _ | QuotedIdentifierToken _ ->
      identifier_table token
  | EOF | Newline | Whitespace | Comment _ | LineComment _ | BlockComment _ | DocComment _
  | ErrorToken _ ->
      special_table token
  (* 表格查找类型 *)
  | ZeroKeyword | OneKeyword | TwoKeyword | ThreeKeyword | FourKeyword | FiveKeyword | SixKeyword
  | SevenKeyword | EightKeyword | NineKeyword | TenKeyword | HundredKeyword | ThousandKeyword
  | TenThousandKeyword ->
      lookup_in_typed_table number_mappings token "数字关键字"
  | IntTypeKeyword | FloatTypeKeyword | StringTypeKeyword | BoolTypeKeyword | UnitTypeKeyword
  | ListTypeKeyword | ArrayTypeKeyword | RefTypeKeyword | FunctionTypeKeyword | TupleTypeKeyword
  | RecordTypeKeyword | VariantTypeKeyword | OptionTypeKeyword | ResultTypeKeyword ->
      lookup_in_typed_table type_mappings token "类型关键字"
  | WenyanIfKeyword | WenyanThenKeyword | WenyanElseKeyword | WenyanWhileKeyword | WenyanForKeyword
  | WenyanFunctionKeyword | WenyanReturnKeyword | WenyanTrueKeyword | WenyanFalseKeyword
  | WenyanLetKeyword ->
      lookup_in_typed_table wenyan_mappings token "文言文关键字"
  | ClassicalIfKeyword | ClassicalThenKeyword | ClassicalElseKeyword | ClassicalWhileKeyword
  | ClassicalForKeyword | ClassicalFunctionKeyword | ClassicalReturnKeyword | ClassicalTrueKeyword
  | ClassicalFalseKeyword | ClassicalLetKeyword ->
      lookup_in_typed_table classical_mappings token "古雅体关键字"
  | PlusOp | MinusOp | MultiplyOp | DivideOp | ModOp | PowerOp | EqualOp | NotEqualOp | LessOp
  | GreaterOp | LessEqualOp | GreaterEqualOp | LogicalAndOp | LogicalOrOp | LogicalNotOp
  | BitwiseAndOp | BitwiseOrOp | BitwiseXorOp | BitwiseNotOp | LeftShiftOp | RightShiftOp | AssignOp
  | PlusAssignOp | MinusAssignOp | MultiplyAssignOp | DivideAssignOp | AppendOp | ConsOp | ComposeOp
  | PipeOp | PipeBackOp | ArrowOp | DoubleArrowOp ->
      lookup_in_typed_table operator_mappings token "运算符"
  | LeftParen | RightParen | LeftBracket | RightBracket | LeftBrace | RightBrace | Comma | Semicolon
  | Colon | DoubleColon | Dot | DoubleDot | TripleDot | Question | Exclamation | AtSymbol
  | SharpSymbol | DollarSymbol | Underscore | Backquote | SingleQuote | DoubleQuote | Backslash
  | VerticalBar | Ampersand | Tilde | Caret | Percent ->
      lookup_in_typed_table delimiter_mappings token "分隔符"
  (* 基础关键字 - 默认情况 *)
  | _ -> lookup_in_typed_table keyword_mappings token "基础关键字"

(** 安全版本和兼容版本 *)
let string_of_token_safe token = safe_execute (fun () -> classify_and_convert_token token)

let string_of_token token =
  match string_of_token_safe token with Ok result -> result | Error _ -> "<UNKNOWN_TOKEN>"
