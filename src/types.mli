(** 骆言类型系统接口 - Chinese Programming Language Type System Interface *)

(** {1 基础类型定义} *)

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
  | RecordType_T of (string * typ) list  (** 记录类型: [(field_name, field_type); ...] *)
  | ArrayType_T of typ  (** 数组类型: [|element_type|] *)
  | ClassType_T of string * (string * typ) list  (** 类类型: 类名 和方法类型列表 *)
  | ObjectType_T of (string * typ) list  (** 对象类型: 方法类型列表 *)
  | PrivateType_T of string * typ  (** 私有类型: 类型名 和底层类型 *)
  | PolymorphicVariantType_T of (string * typ option) list  (** 多态变体类型: [(标签, 类型); ...] *)
[@@deriving show, eq]

(** 类型方案 *)
type type_scheme = TypeScheme of string list * typ

module TypeEnv : Map.S with type key = string
(** 类型环境 - 变量名到类型方案的映射 *)

type env = type_scheme TypeEnv.t

module OverloadMap : Map.S with type key = string
(** 函数重载表 - 存储同名函数的不同类型签名 *)

type overload_env = type_scheme list OverloadMap.t

(** {1 异常定义} *)

exception TypeError of string
(** 类型错误异常 *)

exception ParseError of string * int * int
(** 解析错误异常: (消息, 行号, 列号) *)

exception CodegenError of string * string
(** 代码生成错误异常: (消息, 上下文) *)

exception SemanticError of string * string
(** 语义分析错误异常: (消息, 上下文) *)

(** {1 类型替换相关} *)

module SubstMap : Map.S with type key = string
(** 类型替换映射 *)

type type_subst = typ SubstMap.t

val empty_subst : type_subst
(** 空替换 *)

val single_subst : string -> typ -> type_subst
(** 单一替换 *)

(** {1 性能优化模块} *)

(** 记忆化缓存模块 - 缓存类型推断结果 *)
module MemoizationCache : sig
  val get_cache_stats : unit -> int * int
  (** 获取缓存统计信息 (命中次数, 未命中次数) *)

  val reset_cache : unit -> unit
  (** 重置缓存 *)
end

(** 性能统计模块 *)
module PerformanceStats : sig
  val get_stats : unit -> int * int * int
  (** 获取性能统计信息 (类型推断调用次数, 缓存命中次数, 缓存未命中次数) *)

  val reset_stats : unit -> unit
  (** 重置统计信息 *)

  val enable_cache : unit -> unit
  (** 启用缓存 *)

  val disable_cache : unit -> unit
  (** 禁用缓存 *)

  val is_cache_enabled : unit -> bool
  (** 检查缓存是否启用 *)
end

(** {1 类型操作函数} *)

val new_type_var : unit -> typ
(** 生成新的类型变量 *)

val apply_subst : type_subst -> typ -> typ
(** 应用替换到类型 *)

val apply_subst_to_scheme : type_subst -> type_scheme -> type_scheme
(** 应用替换到类型方案 *)

val apply_subst_to_env : type_subst -> env -> env
(** 应用替换到环境 *)

val compose_subst : type_subst -> type_subst -> type_subst
(** 合成替换 *)

val free_vars : typ -> string list
(** 获取类型中的自由变量 *)

val scheme_free_vars : type_scheme -> string list
(** 获取类型方案中的自由变量 *)

val env_free_vars : env -> string list
(** 获取环境中的自由变量 *)

val generalize : env -> typ -> type_scheme
(** 类型泛化 *)

val instantiate : type_scheme -> typ
(** 类型实例化 *)

val unify : typ -> typ -> type_subst
(** 类型合一 *)

(** {1 类型转换函数} *)

val from_base_type : Ast.base_type -> typ
(** 从基础类型转换 *)

val type_expr_to_typ : Ast.type_expr -> typ
(** 从类型表达式转换为类型 *)

val literal_type : Ast.literal -> typ
(** 从字面量推断类型 *)

val binary_op_type : Ast.binary_op -> typ * typ * typ
(** 从二元运算符推断类型 *)

val unary_op_type : Ast.unary_op -> typ * typ
(** 从一元运算符推断类型 *)

(** {1 模式匹配相关} *)

val extract_pattern_bindings : Ast.pattern -> (string * type_scheme) list
(** 从模式中提取变量绑定 *)

(** {1 类型推断} *)

val builtin_env : env
(** 内置函数环境 *)

val infer_type : env -> Ast.expr -> type_subst * typ
(** 类型推断 - 主要的类型推断函数 *)

(** {1 工具函数} *)

val type_to_chinese_string : typ -> string
(** 类型转换为中文显示 *)

val show_expr_type : env -> Ast.expr -> unit
(** 显示表达式的类型信息 *)

val show_program_types : Ast.program -> unit
(** 显示程序中所有变量的类型信息 *)
