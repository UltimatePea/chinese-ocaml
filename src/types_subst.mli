(** 骆言类型系统 - 类型替换模块接口 *)

open Core_types

val apply_subst : type_subst -> typ -> typ
(** 类型替换应用 *)

val apply_subst_to_scheme : type_subst -> type_scheme -> type_scheme
(** 对类型方案应用替换 *)

val apply_subst_to_env : type_subst -> env -> env
(** 对类型环境应用替换 *)

val compose_subst : type_subst -> type_subst -> type_subst
(** 替换合成 *)

val scheme_free_vars : type_scheme -> string list
(** 获取类型方案的自由变量 *)

val env_free_vars : env -> string list
(** 获取类型环境的自由变量 *)

val generalize : env -> typ -> type_scheme
(** 泛化类型 *)

val instantiate : type_scheme -> typ
(** 实例化类型方案 *)
