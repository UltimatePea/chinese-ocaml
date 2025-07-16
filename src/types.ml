(** 骆言类型系统 - Chinese Programming Language Type System *)

(** 重新导出核心类型 *)
type typ = Core_types.typ =
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

type type_scheme = Core_types.type_scheme = TypeScheme of string list * typ
type env = Core_types.env
type overload_env = Core_types.overload_env
type type_subst = Core_types.type_subst

module TypeEnv = Core_types.TypeEnv
(** 重新导出核心模块 *)

module OverloadMap = Core_types.OverloadMap
module SubstMap = Core_types.SubstMap

(** 重新导出核心函数 *)
let new_type_var = Core_types.new_type_var

let empty_subst = Core_types.empty_subst
let single_subst = Core_types.single_subst
let free_vars = Core_types.free_vars

exception TypeError = Types_errors.TypeError
(** 重新导出错误异常 *)

exception ParseError = Types_errors.ParseError
exception CodegenError = Types_errors.CodegenError
exception SemanticError = Types_errors.SemanticError

module MemoizationCache = Types_cache.MemoizationCache
(** 重新导出缓存模块 *)

module PerformanceStats = Types_cache.PerformanceStats

(** 重新导出类型替换模块 *)
let apply_subst = Types_subst.apply_subst

let apply_subst_to_scheme = Types_subst.apply_subst_to_scheme
let apply_subst_to_env = Types_subst.apply_subst_to_env
let compose_subst = Types_subst.compose_subst
let scheme_free_vars = Types_subst.scheme_free_vars
let env_free_vars = Types_subst.env_free_vars
let generalize = Types_subst.generalize
let instantiate = Types_subst.instantiate

(** 重新导出类型合一模块 *)
let unify = Types_unify.unify
(* let unify_polymorphic_variants = Types_unify.unify_polymorphic_variants *)
(* let var_unify = Types_unify.var_unify *)
(* let unify_list = Types_unify.unify_list *)
(* let unify_record_fields = Types_unify.unify_record_fields *)

(** 重新导出类型转换模块 *)
let from_base_type = Types_convert.from_base_type

let type_expr_to_typ = Types_convert.type_expr_to_typ
let literal_type = Types_convert.literal_type
let binary_op_type = Types_convert.binary_op_type
let unary_op_type = Types_convert.unary_op_type
let extract_pattern_bindings = Types_convert.extract_pattern_bindings

(* let convert_module_type_to_typ = Types_convert.convert_module_type_to_typ *)
(* let convert_type_expr_to_typ = Types_convert.convert_type_expr_to_typ *)
let type_to_chinese_string = Types_convert.type_to_chinese_string

(** 重新导出内置环境 *)
let builtin_env = Types_builtin.builtin_env

(** 重新导出类型推断模块 *)
let infer_type = Types_infer.infer_type

let show_expr_type = Types_infer.show_expr_type
let show_program_types = Types_infer.show_program_types
