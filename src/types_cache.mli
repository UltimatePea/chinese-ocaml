(** 骆言类型系统性能优化模块接口 - Type System Performance Optimization Interface *)

open Core_types

(** 记忆化缓存模块 *)
module MemoizationCache : sig
  val lookup : Ast.expr -> (type_subst * typ) option
  (** 缓存查找 *)

  val store : Ast.expr -> type_subst -> typ -> unit
  (** 缓存存储 *)

  val get_cache_stats : unit -> int * int
  (** 获取缓存统计 *)

  val reset_cache : unit -> unit
  (** 重置缓存 *)

  val cache_size : unit -> int
  (** 缓存大小 *)

  val clear_cache : unit -> unit
  (** 清空缓存 *)
end

(** 性能统计模块 *)
module PerformanceStats : sig
  val get_stats : unit -> int * int * int * int * int
  (** 获取性能统计 *)

  val reset_stats : unit -> unit
  (** 重置统计 *)

  val increment_infer_calls : unit -> unit
  (** 增加推断调用计数 *)

  val increment_unify_calls : unit -> unit
  (** 增加合一调用计数 *)

  val increment_subst_applications : unit -> unit
  (** 增加替换应用计数 *)

  val enable_cache : unit -> unit
  (** 启用缓存 *)

  val disable_cache : unit -> unit
  (** 禁用缓存 *)

  val is_cache_enabled : unit -> bool
  (** 检查缓存是否启用 *)

  val get_cache_hit_rate : unit -> float
  (** 获取缓存命中率 *)

  val print_stats : unit -> unit
  (** 打印性能统计 *)
end

(** 合一优化模块 *)
module UnificationOptimization : sig
  val quick_type_check : typ -> typ -> bool
  (** 快速类型检查 *)

  val types_equal : typ -> typ -> bool
  (** 类型相等性检查 *)

  val type_complexity : typ -> int
  (** 类型复杂度计算 *)
end

val enable_cache : unit -> unit
(** 缓存管理函数 *)

val disable_cache : unit -> unit
val is_cache_enabled : unit -> bool
val get_cache_stats : unit -> int * int * int * int * int
val reset_stats : unit -> unit
val print_performance_stats : unit -> unit

val cache_lookup : Ast.expr -> (type_subst * typ) option
(** 缓存操作函数 *)

val cache_store : Ast.expr -> type_subst -> typ -> unit
val cache_clear : unit -> unit
val cache_size : unit -> int
