(** 骆言类型系统 - 类型合一模块接口 *)

open Core_types

(** 类型合一 - 尝试统一两个类型，返回类型替换 *)
val unify : typ -> typ -> type_subst

(** 统一多态变体类型 *)
val unify_polymorphic_variants : (string * typ option) list -> (string * typ option) list -> type_subst

(** 变量合一 *)
val var_unify : string -> typ -> type_subst

(** 合一类型列表 *)
val unify_list : typ list -> typ list -> type_subst

(** 合一记录字段 *)
val unify_record_fields : (string * typ) list -> (string * typ) list -> type_subst

(** 类型替换应用 *)
val apply_subst : type_subst -> typ -> typ

(** 替换合成 *)
val compose_subst : type_subst -> type_subst -> type_subst