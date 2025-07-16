(** 骆言类型系统 - Chinese Programming Language Type System *)

open Ast

(** 初始化模块日志器 *)
let _, log_info, _, log_error = Logger.init_module_logger "Types"

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

(** 重新导出核心模块 *)
module TypeEnv = Core_types.TypeEnv
module OverloadMap = Core_types.OverloadMap
module SubstMap = Core_types.SubstMap

(** 重新导出核心函数 *)
let new_type_var = Core_types.new_type_var
let empty_subst = Core_types.empty_subst
let single_subst = Core_types.single_subst
let free_vars = Core_types.free_vars

(** 重新导出错误异常 *)
exception TypeError = Types_errors.TypeError
exception ParseError = Types_errors.ParseError
exception CodegenError = Types_errors.CodegenError
exception SemanticError = Types_errors.SemanticError

(** 重新导出缓存模块 *)
module MemoizationCache = Types_cache.MemoizationCache
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

(** 简化的类型推断函数 - 将在下一个PR中完成提取 *)
let rec infer_type env expr =
  (* 检查是否启用缓存 *)
  if Types_cache.PerformanceStats.is_cache_enabled () then (
    (* 尝试从缓存中获取结果 *)
    match Types_cache.MemoizationCache.lookup expr with
    | Some (cached_subst, cached_type) ->
        (* 缓存命中，返回缓存的结果 *)
        log_info "类型推断缓存命中";
        (cached_subst, cached_type)
    | None ->
        (* 缓存未命中，进行正常的类型推断 *)
        let result = infer_type_uncached env expr in
        (* 将结果存入缓存 *)
        let subst, typ = result in
        Types_cache.MemoizationCache.store expr subst typ;
        result)
  else
    (* 缓存关闭，直接进行类型推断 *)
    infer_type_uncached env expr

(** 实际的类型推断实现（未缓存版本） *)
and infer_type_uncached env expr =
  (* 内部辅助函数：二元操作表达式类型推断 *)
  let infer_binary_op env left_expr op right_expr =
    let subst1, left_type = infer_type env left_expr in
    let subst2, right_type = infer_type (apply_subst_to_env subst1 env) right_expr in
    let expected_left_type, expected_right_type, result_type = binary_op_type op in
    let subst3 = unify (apply_subst subst2 left_type) expected_left_type in
    let subst4 = unify (apply_subst subst3 right_type) (apply_subst subst3 expected_right_type) in
    let final_subst = compose_subst (compose_subst (compose_subst subst1 subst2) subst3) subst4 in
    (final_subst, apply_subst final_subst result_type)
  in
  (* 内部辅助函数：一元操作表达式类型推断 *)
  let infer_unary_op env op expr =
    let subst, expr_type = infer_type env expr in
    let expected_type, result_type = unary_op_type op in
    let subst2 = unify expr_type expected_type in
    let final_subst = compose_subst subst subst2 in
    (final_subst, apply_subst final_subst result_type)
  in
  (* 内部辅助函数：条件表达式类型推断 *)
  let infer_conditional env cond then_branch else_branch =
    let subst1, cond_type = infer_type env cond in
    let subst2 = unify cond_type BoolType_T in
    let env1 = apply_subst_to_env (compose_subst subst1 subst2) env in
    let subst3, then_type = infer_type env1 then_branch in
    let env2 = apply_subst_to_env subst3 env1 in
    let subst4, else_type = infer_type env2 else_branch in
    let subst5 = unify (apply_subst subst4 then_type) else_type in
    let final_subst =
      List.fold_left compose_subst empty_subst [ subst1; subst2; subst3; subst4; subst5 ]
    in
    (final_subst, apply_subst final_subst else_type)
  in
  (* 内部辅助函数：Let表达式类型推断 *)
  let infer_let_binding env var_name value_expr body_expr =
    let subst1, value_type = infer_type env value_expr in
    let env1 = apply_subst_to_env subst1 env in
    let generalized_type = generalize env1 value_type in
    let env2 = TypeEnv.add var_name generalized_type env1 in
    let subst2, body_type = infer_type env2 body_expr in
    let final_subst = compose_subst subst1 subst2 in
    (final_subst, body_type)
  in
  (* 内部辅助函数：列表表达式类型推断 *)
  let infer_list_expr env expr_list =
    match expr_list with
    | [] -> (empty_subst, ListType_T (new_type_var ()))
    | first_expr :: rest_exprs ->
        let subst1, first_type = infer_type env first_expr in
        let final_subst, final_type =
          List.fold_left
            (fun (acc_subst, acc_type) expr ->
              let expr_subst, expr_type = infer_type (apply_subst_to_env acc_subst env) expr in
              let unified_subst = unify (apply_subst expr_subst acc_type) expr_type in
              let combined_subst = compose_subst (compose_subst acc_subst expr_subst) unified_subst in
              (combined_subst, apply_subst combined_subst expr_type))
            (subst1, first_type) rest_exprs
        in
        (final_subst, ListType_T final_type)
  in
  (* 实际的类型推断逻辑 *)
  match expr with
  | LitExpr literal ->
      let typ = literal_type literal in
      (empty_subst, typ)
  | VarExpr var_name -> (
      try
        let scheme = TypeEnv.find var_name env in
        let typ = instantiate scheme in
        (empty_subst, typ)
      with Not_found ->
        log_error ("变量未定义: " ^ var_name);
        raise (TypeError ("变量未定义: " ^ var_name)))
  | BinaryOpExpr (left_expr, op, right_expr) -> infer_binary_op env left_expr op right_expr
  | UnaryOpExpr (op, expr) -> infer_unary_op env op expr
  | CondExpr (cond, then_branch, else_branch) -> infer_conditional env cond then_branch else_branch
  | LetExpr (var_name, value_expr, body_expr) -> infer_let_binding env var_name value_expr body_expr
  | ListExpr expr_list -> infer_list_expr env expr_list
  | FunCallExpr (func_expr, arg_exprs) ->
      let subst1, func_type = infer_type env func_expr in
      let result_type = new_type_var () in
      let expected_func_type = 
        List.fold_right (fun _ acc -> FunType_T (new_type_var (), acc)) arg_exprs result_type
      in
      let subst2 = unify func_type expected_func_type in
      let final_subst = compose_subst subst1 subst2 in
      (final_subst, apply_subst final_subst result_type)
  | TupleExpr expr_list ->
      let subst_list, type_list =
        List.fold_left
          (fun (acc_subst, acc_types) expr ->
            let expr_subst, expr_type = infer_type (apply_subst_to_env acc_subst env) expr in
            let combined_subst = compose_subst acc_subst expr_subst in
            (combined_subst, expr_type :: acc_types))
          (empty_subst, []) expr_list
      in
      (subst_list, TupleType_T (List.rev type_list))
  | _ ->
      (* 其他表达式类型的简化处理 *)
      log_info "使用简化的类型推断";
      (empty_subst, new_type_var ())

(** 显示表达式的类型 *)
let show_expr_type env expr =
  try
    let subst, inferred_type = infer_type env expr in
    let final_type = apply_subst subst inferred_type in
    log_info ("  表达式类型: " ^ type_to_chinese_string final_type)
  with TypeError msg -> log_error ("  类型推断失败: " ^ msg)

(** 显示程序中所有变量的类型信息 *)
let show_program_types program =
  log_info "=== 类型推断信息 ===";
  let env = ref TypeEnv.empty in
  let show_stmt stmt =
    match stmt with
    | LetStmt (var_name, expr) -> (
        try
          let subst, expr_type = infer_type !env expr in
          let final_type = apply_subst subst expr_type in
          log_info ("变量 " ^ var_name ^ ": " ^ type_to_chinese_string final_type);
          let generalized_scheme = generalize !env final_type in
          env := TypeEnv.add var_name generalized_scheme !env
        with TypeError msg -> log_error ("变量 " ^ var_name ^ ": 类型错误 - " ^ msg))
    | ExprStmt expr -> (
        try
          let subst, expr_type = infer_type !env expr in
          let final_type = apply_subst subst expr_type in
          log_info ("表达式结果: " ^ type_to_chinese_string final_type)
        with TypeError msg -> log_error ("表达式: 类型错误 - " ^ msg))
    | _ -> () (* 其他语句暂不显示类型 *)
  in
  List.iter show_stmt program;
  log_info ""