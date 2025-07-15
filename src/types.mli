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
  | RecordType_T of (string * typ) list (** 记录类型: [(field_name, field_type); ...] *)
  | ArrayType_T of typ (** 数组类型: [|element_type|] *)
  | ClassType_T of string * (string * typ) list (** 类类型: 类名 和方法类型列表 *)
  | ObjectType_T of (string * typ) list (** 对象类型: 方法类型列表 *)
  | PrivateType_T of string * typ (** 私有类型: 类型名 和底层类型 *)
  | PolymorphicVariantType_T of (string * typ option) list (** 多态变体类型: [(标签, 类型); ...] *)
[@@deriving show, eq]

(** 类型方案 *)
type type_scheme = TypeScheme of string list * typ

(** 类型环境 - 变量名到类型方案的映射 *)
module TypeEnv : Map.S with type key = string
type env = type_scheme TypeEnv.t

(** 函数重载表 - 存储同名函数的不同类型签名 *)
module OverloadMap : Map.S with type key = string
type overload_env = type_scheme list OverloadMap.t

(** {1 异常定义} *)

(** 类型错误异常 *)
exception TypeError of string

(** {1 类型替换相关} *)

(** 类型替换映射 *)
module SubstMap : Map.S with type key = string
type type_subst = typ SubstMap.t

(** 空替换 *)
val empty_subst : type_subst

(** 单一替换 *)
val single_subst : string -> typ -> type_subst

(** {1 性能优化模块} *)

(** 记忆化缓存模块 - 缓存类型推断结果 *)
module MemoizationCache : sig
  (** 获取缓存统计信息 (命中次数, 未命中次数) *)
  val get_cache_stats : unit -> int * int
  
  (** 重置缓存 *)
  val reset_cache : unit -> unit
end

(** 性能统计模块 *)
module PerformanceStats : sig
  (** 获取性能统计信息 (类型推断调用次数, 缓存命中次数, 缓存未命中次数) *)
  val get_stats : unit -> int * int * int
  
  (** 重置统计信息 *)
  val reset_stats : unit -> unit
  
  (** 启用缓存 *)
  val enable_cache : unit -> unit
  
  (** 禁用缓存 *)
  val disable_cache : unit -> unit
  
  (** 检查缓存是否启用 *)
  val is_cache_enabled : unit -> bool
end

(** {1 类型操作函数} *)

(** 生成新的类型变量 *)
val new_type_var : unit -> typ

(** 应用替换到类型 *)
val apply_subst : type_subst -> typ -> typ

(** 应用替换到类型方案 *)
val apply_subst_to_scheme : type_subst -> type_scheme -> type_scheme

(** 应用替换到环境 *)
val apply_subst_to_env : type_subst -> env -> env

(** 合成替换 *)
val compose_subst : type_subst -> type_subst -> type_subst

(** 获取类型中的自由变量 *)
val free_vars : typ -> string list

(** 获取类型方案中的自由变量 *)
val scheme_free_vars : type_scheme -> string list

(** 获取环境中的自由变量 *)
val env_free_vars : env -> string list

(** 类型泛化 *)
val generalize : env -> typ -> type_scheme

(** 类型实例化 *)
val instantiate : type_scheme -> typ

(** 类型合一 *)
val unify : typ -> typ -> type_subst

(** {1 类型转换函数} *)

(** 从基础类型转换 *)
val from_base_type : Ast.base_type -> typ

(** 从类型表达式转换为类型 *)
val type_expr_to_typ : Ast.type_expr -> typ

(** 从字面量推断类型 *)
val literal_type : Ast.literal -> typ

(** 从二元运算符推断类型 *)
val binary_op_type : Ast.binary_op -> typ * typ * typ

(** 从一元运算符推断类型 *)
val unary_op_type : Ast.unary_op -> typ * typ

(** {1 模式匹配相关} *)

(** 从模式中提取变量绑定 *)
val extract_pattern_bindings : Ast.pattern -> (string * type_scheme) list

(** {1 类型推断} *)

(** 内置函数环境 *)
val builtin_env : env

(** 类型推断 - 主要的类型推断函数 *)
val infer_type : env -> Ast.expr -> type_subst * typ

(** {1 工具函数} *)

(** 类型转换为中文显示 *)
val type_to_chinese_string : typ -> string

(** 显示表达式的类型信息 *)
val show_expr_type : env -> Ast.expr -> unit

(** 显示程序中所有变量的类型信息 *)
val show_program_types : Ast.program -> unit