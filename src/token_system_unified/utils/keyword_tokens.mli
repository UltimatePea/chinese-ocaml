(** 骆言词法分析器 - 关键字令牌类型定义接口 *)

(** 基础关键字词元类型 *)
type basic_keyword =
  | LetKeyword
  | RecKeyword
  | InKeyword
  | FunKeyword
  | ParamKeyword
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
[@@deriving show, eq]

(** 语义类型系统关键字 *)
type semantic_keyword = AsKeyword | CombineKeyword | WithOpKeyword | WhenKeyword
[@@deriving show, eq]

(** 错误恢复关键字 *)
type error_recovery_keyword = OrElseKeyword | WithDefaultKeyword [@@deriving show, eq]

(** 异常处理关键字 *)
type exception_keyword =
  | ExceptionKeyword
  | RaiseKeyword
  | TryKeyword
  | CatchKeyword
  | FinallyKeyword
[@@deriving show, eq]

(** 类型关键字 *)
type type_keyword =
  | OfKeyword
  | IntTypeKeyword
  | FloatTypeKeyword
  | StringTypeKeyword
  | BoolTypeKeyword
  | UnitTypeKeyword
  | ListTypeKeyword
  | ArrayTypeKeyword
  | VariantKeyword
  | TagKeyword
[@@deriving show, eq]

(** 模块系统关键字 *)
type module_keyword =
  | ModuleKeyword
  | ModuleTypeKeyword
  | SigKeyword
  | EndKeyword
  | FunctorKeyword
  | IncludeKeyword
  | RefKeyword
[@@deriving show, eq]

(** 宏系统关键字 *)
type macro_keyword = MacroKeyword | ExpandKeyword [@@deriving show, eq]

(** 统一关键字类型 *)
type keyword_token =
  | Basic of basic_keyword
  | Semantic of semantic_keyword
  | ErrorRecovery of error_recovery_keyword
  | Exception of exception_keyword
  | Type of type_keyword
  | Module of module_keyword
  | Macro of macro_keyword
[@@deriving show, eq]

val keyword_token_to_string : keyword_token -> string
(** 关键字转换为字符串 *)

val is_control_flow_keyword : keyword_token -> bool
(** 判断是否为控制流关键字 *)

val is_type_related_keyword : keyword_token -> bool
(** 判断是否为类型相关关键字 *)
