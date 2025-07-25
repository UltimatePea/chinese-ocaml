(** 骆言词法分析器 - 核心语言关键字 *)

type core_keyword =
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
  | OfKeyword
  | TrueKeyword
  | FalseKeyword
  | AndKeyword
  | OrKeyword
  | NotKeyword
  | AsKeyword
  | CombineKeyword
  | WithOpKeyword
  | WhenKeyword
  | OrElseKeyword
  | WithDefaultKeyword
  | ExceptionKeyword
  | RaiseKeyword
  | TryKeyword
  | CatchKeyword
  | FinallyKeyword
  | ModuleKeyword
  | ModuleTypeKeyword
  | SigKeyword
  | EndKeyword
  | FunctorKeyword
  | IncludeKeyword
  | RefKeyword
  | MacroKeyword
  | ExpandKeyword
[@@deriving show, eq]

let to_string = function
  | LetKeyword -> "让"
  | RecKeyword -> "递归"
  | InKeyword -> "在"
  | FunKeyword -> "函数"
  | ParamKeyword -> "参数"
  | IfKeyword -> "如果"
  | ThenKeyword -> "那么"
  | ElseKeyword -> "否则"
  | MatchKeyword -> "匹配"
  | WithKeyword -> "与"
  | OtherKeyword -> "其他"
  | TypeKeyword -> "类型"
  | PrivateKeyword -> "私有"
  | OfKeyword -> "of"
  | TrueKeyword -> "真"
  | FalseKeyword -> "假"
  | AndKeyword -> "并且"
  | OrKeyword -> "或者"
  | NotKeyword -> "非"
  | AsKeyword -> "作为"
  | CombineKeyword -> "组合"
  | WithOpKeyword -> "以及"
  | WhenKeyword -> "当"
  | OrElseKeyword -> "否则返回"
  | WithDefaultKeyword -> "默认为"
  | ExceptionKeyword -> "异常"
  | RaiseKeyword -> "抛出"
  | TryKeyword -> "尝试"
  | CatchKeyword -> "捕获"
  | FinallyKeyword -> "最终"
  | ModuleKeyword -> "模块"
  | ModuleTypeKeyword -> "模块类型"
  | SigKeyword -> "签名"
  | EndKeyword -> "结束"
  | FunctorKeyword -> "函子"
  | IncludeKeyword -> "包含"
  | RefKeyword -> "引用"
  | MacroKeyword -> "宏"
  | ExpandKeyword -> "展开"

let from_string = function
  | "让" -> Some LetKeyword
  | "递归" -> Some RecKeyword
  | "在" -> Some InKeyword
  | "函数" -> Some FunKeyword
  | "参数" -> Some ParamKeyword
  | "如果" -> Some IfKeyword
  | "那么" -> Some ThenKeyword
  | "否则" -> Some ElseKeyword
  | "匹配" -> Some MatchKeyword
  | "与" -> Some WithKeyword
  | "其他" -> Some OtherKeyword
  | "类型" -> Some TypeKeyword
  | "私有" -> Some PrivateKeyword
  | "of" -> Some OfKeyword
  | "真" -> Some TrueKeyword
  | "假" -> Some FalseKeyword
  | "并且" -> Some AndKeyword
  | "或者" -> Some OrKeyword
  | "非" -> Some NotKeyword
  | "作为" -> Some AsKeyword
  | "组合" -> Some CombineKeyword
  | "以及" -> Some WithOpKeyword
  | "当" -> Some WhenKeyword
  | "否则返回" -> Some OrElseKeyword
  | "默认为" -> Some WithDefaultKeyword
  | "异常" -> Some ExceptionKeyword
  | "抛出" -> Some RaiseKeyword
  | "尝试" -> Some TryKeyword
  | "捕获" -> Some CatchKeyword
  | "最终" -> Some FinallyKeyword
  | "模块" -> Some ModuleKeyword
  | "模块类型" -> Some ModuleTypeKeyword
  | "签名" -> Some SigKeyword
  | "结束" -> Some EndKeyword
  | "函子" -> Some FunctorKeyword
  | "包含" -> Some IncludeKeyword
  | "引用" -> Some RefKeyword
  | "宏" -> Some MacroKeyword
  | "展开" -> Some ExpandKeyword
  | _ -> None

let is_control_flow = function
  | IfKeyword | ThenKeyword | ElseKeyword | MatchKeyword | WithKeyword -> true
  | _ -> false

let is_type_related = function TypeKeyword | PrivateKeyword | OfKeyword -> true | _ -> false

let is_module_system = function
  | ModuleKeyword | ModuleTypeKeyword | SigKeyword | EndKeyword | FunctorKeyword | IncludeKeyword ->
      true
  | _ -> false
