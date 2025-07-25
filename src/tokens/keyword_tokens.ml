(** 骆言词法分析器 - 关键字令牌类型定义 *)

(** 基础关键字词元类型 *)
type basic_keyword =
  | LetKeyword (* 让 - let *)
  | RecKeyword (* 递归 - rec *)
  | InKeyword (* 在 - in *)
  | FunKeyword (* 函数 - fun *)
  | ParamKeyword (* 参数 - param *)
  | IfKeyword (* 如果 - if *)
  | ThenKeyword (* 那么 - then *)
  | ElseKeyword (* 否则 - else *)
  | MatchKeyword (* 匹配 - match *)
  | WithKeyword (* 与 - with *)
  | OtherKeyword (* 其他 - other/wildcard *)
  | TypeKeyword (* 类型 - type *)
  | PrivateKeyword (* 私有 - private *)
  | TrueKeyword (* 真 - true *)
  | FalseKeyword (* 假 - false *)
  | AndKeyword (* 并且 - and *)
  | OrKeyword (* 或者 - or *)
  | NotKeyword (* 非 - not *)
[@@deriving show, eq]

(** 语义类型系统关键字 *)
type semantic_keyword =
  | AsKeyword (* 作为 - as *)
  | CombineKeyword (* 组合 - combine *)
  | WithOpKeyword (* 以及 - with_op *)
  | WhenKeyword (* 当 - when *)
[@@deriving show, eq]

(** 错误恢复关键字 *)
type error_recovery_keyword =
  | OrElseKeyword (* 否则返回 - or_else *)
  | WithDefaultKeyword (* 默认为 - with_default *)
[@@deriving show, eq]

(** 异常处理关键字 *)
type exception_keyword =
  | ExceptionKeyword (* 异常 - exception *)
  | RaiseKeyword (* 抛出 - raise *)
  | TryKeyword (* 尝试 - try *)
  | CatchKeyword (* 捕获 - catch/with *)
  | FinallyKeyword (* 最终 - finally *)
[@@deriving show, eq]

(** 类型关键字 *)
type type_keyword =
  | OfKeyword (* of - for type constructors *)
  | IntTypeKeyword (* 整数 - int *)
  | FloatTypeKeyword (* 浮点数 - float *)
  | StringTypeKeyword (* 字符串 - string *)
  | BoolTypeKeyword (* 布尔 - bool *)
  | UnitTypeKeyword (* 单元 - unit *)
  | ListTypeKeyword (* 列表 - list *)
  | ArrayTypeKeyword (* 数组 - array *)
  | VariantKeyword (* 变体 - variant *)
  | TagKeyword (* 标签 - tag (for polymorphic variants) *)
[@@deriving show, eq]

(** 模块系统关键字 *)
type module_keyword =
  | ModuleKeyword (* 模块 - module *)
  | ModuleTypeKeyword (* 模块类型 - module type *)
  | SigKeyword (* 签名 - sig *)
  | EndKeyword (* 结束 - end *)
  | FunctorKeyword (* 函子 - functor *)
  | IncludeKeyword (* 包含 - include *)
  | RefKeyword (* 引用 - ref *)
[@@deriving show, eq]

(** 宏系统关键字 *)
type macro_keyword =
  | MacroKeyword
  (* 宏 - macro *)
  | ExpandKeyword (* 展开 - expand *)
[@@deriving show, eq]

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

(** 关键字转换为字符串 *)
let keyword_token_to_string = function
  | Basic bk -> (
      match bk with
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
      | TrueKeyword -> "真"
      | FalseKeyword -> "假"
      | AndKeyword -> "并且"
      | OrKeyword -> "或者"
      | NotKeyword -> "非")
  | Semantic sk -> (
      match sk with
      | AsKeyword -> "作为"
      | CombineKeyword -> "组合"
      | WithOpKeyword -> "以及"
      | WhenKeyword -> "当")
  | ErrorRecovery erk -> ( match erk with OrElseKeyword -> "否则返回" | WithDefaultKeyword -> "默认为")
  | Exception ek -> (
      match ek with
      | ExceptionKeyword -> "异常"
      | RaiseKeyword -> "抛出"
      | TryKeyword -> "尝试"
      | CatchKeyword -> "捕获"
      | FinallyKeyword -> "最终")
  | Type tk -> (
      match tk with
      | OfKeyword -> "of"
      | IntTypeKeyword -> "整数"
      | FloatTypeKeyword -> "浮点数"
      | StringTypeKeyword -> "字符串"
      | BoolTypeKeyword -> "布尔"
      | UnitTypeKeyword -> "单元"
      | ListTypeKeyword -> "列表"
      | ArrayTypeKeyword -> "数组"
      | VariantKeyword -> "变体"
      | TagKeyword -> "标签")
  | Module mk -> (
      match mk with
      | ModuleKeyword -> "模块"
      | ModuleTypeKeyword -> "模块类型"
      | SigKeyword -> "签名"
      | EndKeyword -> "结束"
      | FunctorKeyword -> "函子"
      | IncludeKeyword -> "包含"
      | RefKeyword -> "引用")
  | Macro mk -> ( match mk with MacroKeyword -> "宏" | ExpandKeyword -> "展开")

(** 判断是否为控制流关键字 *)
let is_control_flow_keyword = function
  | Basic (IfKeyword | ThenKeyword | ElseKeyword | MatchKeyword | WithKeyword) -> true
  | _ -> false

(** 判断是否为类型相关关键字 *)
let is_type_related_keyword = function Type _ | Basic TypeKeyword -> true | _ -> false
