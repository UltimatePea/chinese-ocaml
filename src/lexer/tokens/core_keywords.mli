(** 骆言词法分析器 - 核心语言关键字 *)

(** 核心语言关键字，包括基本的程序控制结构 *)
type core_keyword =
  (* 基础关键字 *)
  | LetKeyword  (** 让 - let *)
  | RecKeyword  (** 递归 - rec *)
  | InKeyword  (** 在 - in *)
  | FunKeyword  (** 函数 - fun *)
  | ParamKeyword  (** 参数 - param *)
  (* 控制流关键字 *)
  | IfKeyword  (** 如果 - if *)
  | ThenKeyword  (** 那么 - then *)
  | ElseKeyword  (** 否则 - else *)
  | MatchKeyword  (** 匹配 - match *)
  | WithKeyword  (** 与 - with *)
  | OtherKeyword  (** 其他 - other/wildcard *)
  (* 类型相关 *)
  | TypeKeyword  (** 类型 - type *)
  | PrivateKeyword  (** 私有 - private *)
  | OfKeyword  (** of - for type constructors *)
  (* 布尔逻辑 *)
  | TrueKeyword  (** 真 - true *)
  | FalseKeyword  (** 假 - false *)
  | AndKeyword  (** 并且 - and *)
  | OrKeyword  (** 或者 - or *)
  | NotKeyword  (** 非 - not *)
  (* 语义类型系统 *)
  | AsKeyword  (** 作为 - as *)
  | CombineKeyword  (** 组合 - combine *)
  | WithOpKeyword  (** 以及 - with_op *)
  | WhenKeyword  (** 当 - when *)
  (* 错误恢复 *)
  | OrElseKeyword  (** 否则返回 - or_else *)
  | WithDefaultKeyword  (** 默认为 - with_default *)
  (* 异常处理 *)
  | ExceptionKeyword  (** 异常 - exception *)
  | RaiseKeyword  (** 抛出 - raise *)
  | TryKeyword  (** 尝试 - try *)
  | CatchKeyword  (** 捕获 - catch/with *)
  | FinallyKeyword  (** 最终 - finally *)
  (* 模块系统 *)
  | ModuleKeyword  (** 模块 - module *)
  | ModuleTypeKeyword  (** 模块类型 - module type *)
  | SigKeyword  (** 签名 - sig *)
  | EndKeyword  (** 结束 - end *)
  | FunctorKeyword  (** 函子 - functor *)
  | IncludeKeyword  (** 包含 - include *)
  (* 可变性 *)
  | RefKeyword  (** 引用 - ref *)
  (* 宏系统 *)
  | MacroKeyword  (** 宏 - macro *)
  | ExpandKeyword  (** 展开 - expand *)
[@@deriving show, eq]

val to_string : core_keyword -> string
(** 将核心关键字转换为字符串表示 *)

val from_string : string -> core_keyword option
(** 将字符串转换为核心关键字（如果匹配） *)

val is_control_flow : core_keyword -> bool
(** 检查是否为控制流关键字 *)

val is_type_related : core_keyword -> bool
(** 检查是否为类型相关关键字 *)

val is_module_system : core_keyword -> bool
(** 检查是否为模块系统关键字 *)
