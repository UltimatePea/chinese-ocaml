(** 骆言类型系统接口 - Chinese Programming Language Type System Interface *)

(** 类型 *)
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
  | ArrayType_T of typ                   (** 数组类型: [|element_type|] *)
  | ClassType_T of string * (string * typ) list  (** 类类型: 类名 和方法类型列表 *)
  | ObjectType_T of (string * typ) list          (** 对象类型: 方法类型列表 *)
[@@deriving show, eq]

(** 类型方案 *)
type type_scheme = TypeScheme of string list * typ

(** 类型环境 *)
module TypeEnv : Map.S with type key = string
type env = type_scheme TypeEnv.t

(** 函数重载表 - 存储同名函数的不同类型签名 *)
module OverloadMap : Map.S with type key = string
type overload_env = type_scheme list OverloadMap.t

(** 类型替换 *)
module SubstMap : Map.S with type key = string
type type_subst = typ SubstMap.t

(** 类型错误 *)
exception TypeError of string

(** 生成新的类型变量 *)
val new_type_var : unit -> typ

(** 类型替换操作 *)
val empty_subst : type_subst
val single_subst : string -> typ -> type_subst
val apply_subst : type_subst -> typ -> typ
val apply_subst_to_scheme : type_subst -> type_scheme -> type_scheme
val apply_subst_to_env : type_subst -> env -> env
val compose_subst : type_subst -> type_subst -> type_subst

(** 类型变量和泛化 *)
val free_vars : typ -> string list
val scheme_free_vars : type_scheme -> string list
val env_free_vars : env -> string list
val generalize : env -> typ -> type_scheme
val instantiate : type_scheme -> typ

(** 类型统一 *)
val unify : typ -> typ -> type_subst
val var_unify : string -> typ -> type_subst
val unify_list : typ list -> typ list -> type_subst
val unify_record_fields : (string * typ) list -> (string * typ) list -> type_subst

(** 类型转换函数 *)
val from_base_type : Ast.base_type -> typ
val literal_type : Ast.literal -> typ
val binary_op_type : Ast.binary_op -> typ * typ * typ
val unary_op_type : Ast.unary_op -> typ * typ

(** 模式匹配类型提取 *)
val extract_pattern_bindings : Ast.pattern -> (string * type_scheme) list

(** 内置环境 *)
val builtin_env : env

(** 类型推断 *)
val infer_type : env -> Ast.expr -> type_subst * typ
val infer_fun_call : env -> typ -> Ast.expr list -> type_subst -> type_subst * typ
val infer_fun_expr : env -> string list -> Ast.expr -> type_subst * typ

(** 显示函数 *)
val type_to_chinese_string : typ -> string
val show_expr_type : env -> Ast.expr -> unit
val show_program_types : Ast.program -> unit