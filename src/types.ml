(** 骆言类型系统 - Chinese Programming Language Type System *)

open Ast

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
[@@deriving show, eq]

(** 类型环境 *)
module TypeEnv = Map.Make(String)
type env = typ TypeEnv.t

(** 类型错误 *)
exception TypeError of string

(** 类型变量计数器 *)
let type_var_counter = ref 0

(** 生成新的类型变量 *)
let new_type_var () =
  incr type_var_counter;
  TypeVar_T ("'a" ^ string_of_int !type_var_counter)

(** 类型替换 *)
module SubstMap = Map.Make(String)
type type_subst = typ SubstMap.t

(** 空替换 *)
let empty_subst = SubstMap.empty

(** 单一替换 *)
let single_subst var_name typ = SubstMap.singleton var_name typ

(** 应用替换到类型 *)
let rec apply_subst subst typ =
  match typ with
  | TypeVar_T name ->
    (try SubstMap.find name subst
     with Not_found -> typ)
  | FunType_T (param_type, return_type) ->
    FunType_T (apply_subst subst param_type, apply_subst subst return_type)
  | TupleType_T type_list ->
    TupleType_T (List.map (apply_subst subst) type_list)
  | ListType_T elem_type ->
    ListType_T (apply_subst subst elem_type)
  | ConstructType_T (name, type_list) ->
    ConstructType_T (name, List.map (apply_subst subst) type_list)
  | _ -> typ

(** 应用替换到环境 *)
let apply_subst_to_env subst env =
  TypeEnv.map (apply_subst subst) env

(** 合成替换 *)
let compose_subst subst1 subst2 =
  let applied_subst1 = SubstMap.map (apply_subst subst2) subst1 in
  SubstMap.fold SubstMap.add subst2 applied_subst1

(** 获取类型中的自由变量 *)
let rec free_vars typ =
  match typ with
  | TypeVar_T name -> [name]
  | FunType_T (param_type, return_type) ->
    free_vars param_type @ free_vars return_type
  | TupleType_T type_list ->
    List.flatten (List.map free_vars type_list)
  | ListType_T elem_type ->
    free_vars elem_type
  | ConstructType_T (_, type_list) ->
    List.flatten (List.map free_vars type_list)
  | _ -> []

(** 获取环境中的自由变量 *)
let env_free_vars env =
  TypeEnv.fold (fun _ typ acc -> free_vars typ @ acc) env []

(** 类型泛化 *)
let generalize env typ =
  let env_vars = env_free_vars env in
  let type_vars = free_vars typ in
  let free_type_vars = List.filter (fun v -> not (List.mem v env_vars)) type_vars in
  (free_type_vars, typ)

(** 类型实例化 *)
let instantiate (quantified_vars, typ) =
  let subst = List.fold_left (fun acc var ->
    SubstMap.add var (new_type_var ()) acc
  ) empty_subst quantified_vars in
  apply_subst subst typ

(** 类型合一 *)
let rec unify typ1 typ2 =
  match (typ1, typ2) with
  | (t1, t2) when t1 = t2 -> empty_subst
  | (TypeVar_T name, t) -> var_unify name t
  | (t, TypeVar_T name) -> var_unify name t
  | (FunType_T (param1, return1), FunType_T (param2, return2)) ->
    let subst1 = unify param1 param2 in
    let subst2 = unify (apply_subst subst1 return1) (apply_subst subst1 return2) in
    compose_subst subst1 subst2
  | (TupleType_T type_list1, TupleType_T type_list2) ->
    unify_list type_list1 type_list2
  | (ListType_T elem1, ListType_T elem2) ->
    unify elem1 elem2
  | (ConstructType_T (name1, type_list1), ConstructType_T (name2, type_list2)) when name1 = name2 ->
    unify_list type_list1 type_list2
  | _ -> raise (TypeError ("Cannot unify types: " ^ show_typ typ1 ^ " with " ^ show_typ typ2))

(** 变量合一 *)
and var_unify var_name typ =
  if typ = TypeVar_T var_name then
    empty_subst
  else if List.mem var_name (free_vars typ) then
    raise (TypeError ("Occurs check failure: " ^ var_name ^ " occurs in " ^ show_typ typ))
  else
    single_subst var_name typ

(** 合一类型列表 *)
and unify_list type_list1 type_list2 =
  match (type_list1, type_list2) with
  | ([], []) -> empty_subst
  | (t1 :: ts1, t2 :: ts2) ->
    let subst1 = unify t1 t2 in
    let subst2 = unify_list (List.map (apply_subst subst1) ts1) (List.map (apply_subst subst1) ts2) in
    compose_subst subst1 subst2
  | _ -> raise (TypeError "Type list length mismatch")

(** 从基础类型转换 *)
let from_base_type base_type =
  match base_type with
  | IntType -> IntType_T
  | FloatType -> FloatType_T
  | StringType -> StringType_T
  | BoolType -> BoolType_T
  | UnitType -> UnitType_T

(** 从字面量推断类型 *)
let literal_type literal =
  match literal with
  | IntLit _ -> IntType_T
  | FloatLit _ -> FloatType_T
  | StringLit _ -> StringType_T
  | BoolLit _ -> BoolType_T
  | UnitLit -> UnitType_T

(** 从二元运算符推断类型 *)
let binary_op_type op =
  match op with
  | Add | Sub | Mul | Div ->
    (IntType_T, IntType_T, IntType_T)  (* (左操作数, 右操作数, 结果) *)
  | Eq | Neq ->
    let var = new_type_var () in
    (var, var, BoolType_T)
  | Lt | Le | Gt | Ge ->
    (IntType_T, IntType_T, BoolType_T)
  | And | Or ->
    (BoolType_T, BoolType_T, BoolType_T)

(** 从一元运算符推断类型 *)
let unary_op_type op =
  match op with
  | Neg -> (IntType_T, IntType_T)  (* (操作数, 结果) *)
  | Not -> (BoolType_T, BoolType_T)

(** 内置函数环境 *)
let builtin_env = 
  let env = TypeEnv.empty in
  let env = TypeEnv.add "print" (FunType_T (StringType_T, UnitType_T)) env in
  let env = TypeEnv.add "read" (FunType_T (UnitType_T, StringType_T)) env in
  env

(** 类型推断 *)
let rec infer_type env expr =
  match expr with
  | LitExpr literal ->
    let typ = literal_type literal in
    (empty_subst, typ)
    
  | VarExpr var_name ->
    (try
       let scheme = TypeEnv.find var_name env in
       let typ = instantiate ([], scheme) in  (* 简化版，暂不支持多态 *)
       (empty_subst, typ)
     with Not_found ->
       raise (TypeError ("Undefined variable: " ^ var_name)))
       
  | BinaryOpExpr (left_expr, op, right_expr) ->
    let (subst1, left_type) = infer_type env left_expr in
    let (subst2, right_type) = infer_type (apply_subst_to_env subst1 env) right_expr in
    let (expected_left_type, expected_right_type, result_type) = binary_op_type op in
    let subst3 = unify (apply_subst subst2 left_type) expected_left_type in
    let subst4 = unify (apply_subst subst3 right_type) (apply_subst subst3 expected_right_type) in
    let final_subst = compose_subst (compose_subst (compose_subst subst1 subst2) subst3) subst4 in
    (final_subst, apply_subst final_subst result_type)
    
  | UnaryOpExpr (op, expr) ->
    let (subst, expr_type) = infer_type env expr in
    let (expected_type, result_type) = unary_op_type op in
    let subst2 = unify expr_type expected_type in
    let final_subst = compose_subst subst subst2 in
    (final_subst, apply_subst final_subst result_type)
    
  | FunCallExpr (fun_expr, param_list) ->
    let (subst1, fun_type) = infer_type env fun_expr in
    let env1 = apply_subst_to_env subst1 env in
    infer_fun_call env1 fun_type param_list subst1
    
  | CondExpr (cond, then_branch, else_branch) ->
    let (subst1, cond_type) = infer_type env cond in
    let subst2 = unify cond_type BoolType_T in
    let env1 = apply_subst_to_env (compose_subst subst1 subst2) env in
    let (subst3, then_type) = infer_type env1 then_branch in
    let env2 = apply_subst_to_env subst3 env1 in
    let (subst4, else_type) = infer_type env2 else_branch in
    let subst5 = unify (apply_subst subst4 then_type) else_type in
    let final_subst = List.fold_left compose_subst empty_subst [subst1; subst2; subst3; subst4; subst5] in
    (final_subst, apply_subst final_subst else_type)
    
  | FunExpr (param_list, body) ->
    infer_fun_expr env param_list body
    
  | LetExpr (var_name, value_expr, body_expr) ->
    let (subst1, value_type) = infer_type env value_expr in
    let env1 = apply_subst_to_env subst1 env in
    let generalized_type = generalize env1 value_type in
    let env2 = TypeEnv.add var_name (snd generalized_type) env1 in
    let (subst2, body_type) = infer_type env2 body_expr in
    let final_subst = compose_subst subst1 subst2 in
    (final_subst, body_type)
    
  | _ -> raise (TypeError "Unsupported expression type")

(** 推断函数调用 *)
and infer_fun_call env fun_type param_list initial_subst =
  let rec process_params fun_type param_list acc_subst =
    match param_list with
    | [] -> (acc_subst, fun_type)
    | param :: remaining_params ->
      let return_type_var = new_type_var () in
      let expected_fun_type = FunType_T (new_type_var (), return_type_var) in
      let subst1 = unify fun_type expected_fun_type in
      let latest_subst = compose_subst acc_subst subst1 in
      let env1 = apply_subst_to_env latest_subst env in
      let (subst2, param_type) = infer_type env1 param in
      let final_subst = compose_subst latest_subst subst2 in
      let unified_fun_type = apply_subst final_subst expected_fun_type in
      (match unified_fun_type with
       | FunType_T (expected_param_type, actual_return_type) ->
         let subst3 = unify param_type expected_param_type in
         let new_acc_subst = compose_subst final_subst subst3 in
         let new_return_type = apply_subst new_acc_subst actual_return_type in
         process_params new_return_type remaining_params new_acc_subst
       | _ -> raise (TypeError ("Expected function type but got: " ^ show_typ unified_fun_type)))
  in
  process_params fun_type param_list initial_subst

(** 推断函数表达式 *)
and infer_fun_expr env param_list body =
  let rec process_params param_list env param_type_list =
    match param_list with
    | [] -> (env, List.rev param_type_list)
    | param_name :: remaining_params ->
      let param_type = new_type_var () in
      let new_env = TypeEnv.add param_name param_type env in
      process_params remaining_params new_env (param_type :: param_type_list)
  in
  let (extended_env, param_type_list) = process_params param_list env [] in
  let (subst, body_type) = infer_type extended_env body in
  let applied_param_type_list = List.map (apply_subst subst) param_type_list in
  let fun_type = List.fold_right (fun param_type acc -> FunType_T (param_type, acc)) applied_param_type_list body_type in
  (subst, fun_type)