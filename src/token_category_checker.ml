(** Token分类检查模块 - 从unified_token_core.ml重构而来 第五阶段系统一致性优化：统一错误处理系统，替换failwith为统一错误处理。

    @version 2.1 (错误处理统一化版)
    @since 2025-07-20 Issue #718 系统一致性优化 *)

open Token_types_core
open Unified_errors

let is_literal_token = function
  | IntToken _ | FloatToken _ | StringToken _ | BoolToken _ | ChineseNumberToken _ | UnitToken ->
      true
  | _ -> false

let is_identifier_token = function
  | IdentifierToken _ | QuotedIdentifierToken _ | ConstructorToken _ | IdentifierTokenSpecial _
  | ModuleNameToken _ | TypeNameToken _ ->
      true
  | _ -> false

let is_basic_keyword_token = function
  | LetKeyword | FunKeyword | IfKeyword | ThenKeyword | ElseKeyword | MatchKeyword | WithKeyword
  | WhenKeyword | AndKeyword | OrKeyword | NotKeyword | TrueKeyword | FalseKeyword | InKeyword
  | RecKeyword | MutableKeyword | RefKeyword | BeginKeyword | EndKeyword | ForKeyword | WhileKeyword
  | DoKeyword | DoneKeyword | ToKeyword | DowntoKeyword | BreakKeyword | ContinueKeyword
  | ReturnKeyword | TryKeyword | RaiseKeyword | FailwithKeyword | AssertKeyword | LazyKeyword
  | ExceptionKeyword | ModuleKeyword | StructKeyword | SigKeyword | FunctorKeyword | IncludeKeyword
  | OpenKeyword | TypeKeyword | ValKeyword | ExternalKeyword | PrivateKeyword | VirtualKeyword
  | MethodKeyword | InheritKeyword | InitializerKeyword | NewKeyword | ObjectKeyword | ClassKeyword
  | ConstraintKeyword | AsKeyword | OfKeyword ->
      true
  | _ -> false

let is_number_keyword_token = function
  | ZeroKeyword | OneKeyword | TwoKeyword | ThreeKeyword | FourKeyword | FiveKeyword | SixKeyword
  | SevenKeyword | EightKeyword | NineKeyword | TenKeyword | HundredKeyword | ThousandKeyword
  | TenThousandKeyword ->
      true
  | _ -> false

let is_type_keyword_token = function
  | IntTypeKeyword | FloatTypeKeyword | StringTypeKeyword | BoolTypeKeyword | UnitTypeKeyword
  | ListTypeKeyword | ArrayTypeKeyword | RefTypeKeyword | FunctionTypeKeyword | TupleTypeKeyword
  | RecordTypeKeyword | VariantTypeKeyword | OptionTypeKeyword | ResultTypeKeyword ->
      true
  | _ -> false

let is_wenyan_keyword_token = function
  | WenyanIfKeyword | WenyanThenKeyword | WenyanElseKeyword | WenyanWhileKeyword | WenyanForKeyword
  | WenyanFunctionKeyword | WenyanReturnKeyword | WenyanTrueKeyword | WenyanFalseKeyword
  | WenyanLetKeyword ->
      true
  | _ -> false

let is_classical_keyword_token = function
  | ClassicalIfKeyword | ClassicalThenKeyword | ClassicalElseKeyword | ClassicalWhileKeyword
  | ClassicalForKeyword | ClassicalFunctionKeyword | ClassicalReturnKeyword | ClassicalTrueKeyword
  | ClassicalFalseKeyword | ClassicalLetKeyword ->
      true
  | _ -> false

let is_keyword_token token =
  is_basic_keyword_token token || is_number_keyword_token token || is_type_keyword_token token
  || is_wenyan_keyword_token token || is_classical_keyword_token token

let is_operator_token = function
  | PlusOp | MinusOp | MultiplyOp | DivideOp | ModOp | PowerOp | EqualOp | NotEqualOp | LessOp
  | GreaterOp | LessEqualOp | GreaterEqualOp | LogicalAndOp | LogicalOrOp | LogicalNotOp
  | BitwiseAndOp | BitwiseOrOp | BitwiseXorOp | BitwiseNotOp | LeftShiftOp | RightShiftOp | AssignOp
  | PlusAssignOp | MinusAssignOp | MultiplyAssignOp | DivideAssignOp | AppendOp | ConsOp | ComposeOp
  | PipeOp | PipeBackOp | ArrowOp | DoubleArrowOp ->
      true
  | _ -> false

let is_delimiter_token = function
  | LeftParen | RightParen | LeftBracket | RightBracket | LeftBrace | RightBrace | Comma | Semicolon
  | Colon | DoubleColon | Dot | DoubleDot | TripleDot | Question | Exclamation | AtSymbol
  | SharpSymbol | DollarSymbol | Underscore | Backquote | SingleQuote | DoubleQuote | Backslash
  | VerticalBar | Ampersand | Tilde | Caret | Percent ->
      true
  | _ -> false

let is_special_token = function
  | EOF | Newline | Whitespace | Comment _ | LineComment _ | BlockComment _ | DocComment _
  | ErrorToken _ ->
      true
  | _ -> false

(** 获取Token分类（安全版本，返回Result类型） *)
let get_token_category_safe token =
  safe_execute (fun () ->
      if is_literal_token token then Literal
      else if is_identifier_token token then Identifier
      else if is_keyword_token token then Keyword
      else if is_operator_token token then Operator
      else if is_delimiter_token token then Delimiter
      else if is_special_token token then Special
      else raise (unified_error_to_exception (TypeError "Unknown token category")))

(** 获取Token分类（兼容性版本） *)
let get_token_category token =
  match get_token_category_safe token with
  | Ok category -> category
  | Error _ -> (* 默认返回Special作为未知类型 *) Special
