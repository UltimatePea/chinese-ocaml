(** 骆言类型系统性能优化模块 - Type System Performance Optimization *)

open Core_types

(* 使用统一日志系统 *)
let log_debug, log_info, log_warn, log_error = Unified_logging.create_module_logger "TypesCache"

(** 记忆化缓存模块 - 缓存类型推断结果 *)
module MemoizationCache = struct
  (* 使用 Hashtable 来缓存表达式到类型的映射 *)
  (* Key: 表达式的哈希值, Value: (替换, 类型) *)
  module ExprHash = struct
    open Ast

    let rec hash_expr expr =
      match expr with
      | LitExpr lit -> Hashtbl.hash ("LitExpr", lit)
      | VarExpr name -> Hashtbl.hash ("VarExpr", name)
      | BinaryOpExpr (left, op, right) ->
          Hashtbl.hash ("BinaryOpExpr", hash_expr left, op, hash_expr right)
      | UnaryOpExpr (op, expr) -> Hashtbl.hash ("UnaryOpExpr", op, hash_expr expr)
      | CondExpr (cond, then_br, else_br) ->
          Hashtbl.hash ("CondExpr", hash_expr cond, hash_expr then_br, hash_expr else_br)
      | FunExpr (params, body) -> Hashtbl.hash ("FunExpr", params, hash_expr body)
      | ListExpr exprs -> Hashtbl.hash ("ListExpr", List.map hash_expr exprs)
      | TupleExpr exprs -> Hashtbl.hash ("TupleExpr", List.map hash_expr exprs)
      | _ -> Hashtbl.hash expr (* 对于其他复杂表达式使用默认哈希 *)
  end

  let cache : (int, type_subst * typ) Hashtbl.t =
    Hashtbl.create (Constants.BufferSizes.large_buffer ())

  let cache_hits = ref 0
  let cache_misses = ref 0
  let get_cache_stats () = (!cache_hits, !cache_misses)

  let reset_cache () =
    Hashtbl.clear cache;
    cache_hits := 0;
    cache_misses := 0

  let lookup expr =
    let hash = ExprHash.hash_expr expr in
    try
      let result = Hashtbl.find cache hash in
      incr cache_hits;
      Some result
    with Not_found ->
      incr cache_misses;
      None

  let store expr subst typ =
    let hash = ExprHash.hash_expr expr in
    Hashtbl.replace cache hash (subst, typ)

  let cache_size () = Hashtbl.length cache
  let clear_cache () = Hashtbl.clear cache
end

(** 性能统计模块 *)
module PerformanceStats = struct
  let infer_type_calls = ref 0
  let unify_calls = ref 0
  let subst_applications = ref 0
  let cache_enabled = ref true

  let get_stats () =
    let hits, misses = MemoizationCache.get_cache_stats () in
    (!infer_type_calls, !unify_calls, !subst_applications, hits, misses)

  let reset_stats () =
    infer_type_calls := 0;
    unify_calls := 0;
    subst_applications := 0;
    MemoizationCache.reset_cache ()

  let increment_infer_calls () = incr infer_type_calls
  let increment_unify_calls () = incr unify_calls
  let increment_subst_applications () = incr subst_applications
  let enable_cache () = cache_enabled := true
  let disable_cache () = cache_enabled := false
  let is_cache_enabled () = !cache_enabled

  let get_cache_hit_rate () =
    let hits, misses = MemoizationCache.get_cache_stats () in
    if hits + misses = Constants.Numbers.zero then Constants.Metrics.zero_division_fallback
    else float_of_int hits /. float_of_int (hits + misses)

  let print_stats () =
    if Config.Get.debug_mode () then (
      let infer_calls, unify_calls, subst_apps, hits, misses = get_stats () in
      let hit_rate = get_cache_hit_rate () in
      log_info Constants.Messages.performance_stats_header;
      log_info (Printf.sprintf "  推断调用: %d" infer_calls);
      log_info (Printf.sprintf "  合一调用: %d" unify_calls);
      log_info (Printf.sprintf "  替换应用: %d" subst_apps);
      log_info (Printf.sprintf "  缓存命中: %d" hits);
      log_info (Printf.sprintf "  缓存未命中: %d" misses);
      log_info (Printf.sprintf "  命中率: %.2f%%" (hit_rate *. Constants.Metrics.percentage_multiplier));
      log_info (Printf.sprintf "  缓存大小: %d" (MemoizationCache.cache_size ())))
end

(** 合一优化模块 *)
module UnificationOptimization = struct
  (* 优化合一算法的性能 *)
  let quick_type_check t1 t2 =
    match (t1, t2) with
    | IntType_T, IntType_T
    | FloatType_T, FloatType_T
    | StringType_T, StringType_T
    | BoolType_T, BoolType_T
    | UnitType_T, UnitType_T ->
        true
    | TypeVar_T _, _ | _, TypeVar_T _ -> true
    | _ -> false

  (* 检查类型是否相同（快速路径） *)
  let types_equal t1 t2 =
    match (t1, t2) with
    | IntType_T, IntType_T
    | FloatType_T, FloatType_T
    | StringType_T, StringType_T
    | BoolType_T, BoolType_T
    | UnitType_T, UnitType_T ->
        true
    | TypeVar_T n1, TypeVar_T n2 -> n1 = n2
    | _ -> false

  (* 检查类型复杂度 *)
  let type_complexity = function
    | IntType_T | FloatType_T | StringType_T | BoolType_T | UnitType_T ->
        Constants.Numbers.type_complexity_basic
    | TypeVar_T _ -> Constants.Numbers.type_complexity_basic
    | FunType_T (_, _) -> Constants.Numbers.type_complexity_composite
    | ListType_T _ | RefType_T _ -> Constants.Numbers.type_complexity_composite
    | TupleType_T ts -> Constants.Numbers.type_complexity_basic + List.length ts
    | RecordType_T fields -> Constants.Numbers.type_complexity_basic + List.length fields
    | ArrayType_T _ -> Constants.Numbers.type_complexity_composite
    | ConstructType_T (_, args) -> Constants.Numbers.type_complexity_basic + List.length args
    | ClassType_T (_, methods) -> Constants.Numbers.type_complexity_composite + List.length methods
    | ObjectType_T methods -> Constants.Numbers.type_complexity_composite + List.length methods
    | PrivateType_T (_, _) -> Constants.Numbers.type_complexity_composite
    | PolymorphicVariantType_T variants ->
        Constants.Numbers.type_complexity_basic + List.length variants
end

(** 缓存管理函数 *)
let enable_cache = PerformanceStats.enable_cache

let disable_cache = PerformanceStats.disable_cache
let is_cache_enabled = PerformanceStats.is_cache_enabled
let get_cache_stats = PerformanceStats.get_stats
let reset_stats = PerformanceStats.reset_stats
let print_performance_stats = PerformanceStats.print_stats

(** 缓存操作函数 *)
let cache_lookup = MemoizationCache.lookup

let cache_store = MemoizationCache.store
let cache_clear = MemoizationCache.clear_cache
let cache_size = MemoizationCache.cache_size
