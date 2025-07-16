(** 骆言类型系统核心类型定义接口 - Core Type Definitions Interface *)

(** 类型定义 *)
type typ =
  | IntType_T
  | FloatType_T
  | StringType_T
  | BoolType_T
  | UnitType_T
  | FunType_T of typ * typ
  | TupleType_T of typ list
  | ListType_T of typ
  | TypeVar_T of string
  | ConstructType_T of string * typ list
  | RefType_T of typ
  | RecordType_T of (string * typ) list
  | ArrayType_T of typ
  | ClassType_T of string * (string * typ) list
  | ObjectType_T of (string * typ) list
  | PrivateType_T of string * typ
  | PolymorphicVariantType_T of (string * typ option) list
[@@deriving show, eq]

(** 类型方案 *)
type type_scheme = TypeScheme of string list * typ

module TypeEnv : Map.S with type key = string
(** 类型环境模块 *)

type env = type_scheme TypeEnv.t
(** 类型环境 *)

module OverloadMap : Map.S with type key = string
(** 函数重载表模块 *)

type overload_env = type_scheme list OverloadMap.t
(** 函数重载环境 *)

module SubstMap : Map.S with type key = string
(** 类型替换模块 *)

type type_subst = typ SubstMap.t
(** 类型替换 *)

val new_type_var : unit -> typ
(** 生成新的类型变量 *)

val empty_subst : type_subst
(** 空替换 *)

val single_subst : string -> typ -> type_subst
(** 单一替换 *)

val string_of_typ : typ -> string
(** 类型显示函数 *)

val free_vars : typ -> string list
(** 获取类型中的自由变量 *)

val contains_type_var : string -> typ -> bool
(** 检查类型是否包含类型变量 *)

val is_base_type : typ -> bool
(** 检查类型是否是基础类型 *)

val is_compound_type : typ -> bool
(** 检查类型是否是复合类型 *)
