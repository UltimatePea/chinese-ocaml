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

(** 类型方案 *)
type type_scheme = TypeScheme of string list * typ

(** 类型环境 *)
module TypeEnv = Map.Make(String)
type env = type_scheme TypeEnv.t

(** 函数重载表 - 存储同名函数的不同类型签名 *)
module OverloadMap = Map.Make(String)
type overload_env = type_scheme list OverloadMap.t

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

(** 应用替换到类型方案 *)
let apply_subst_to_scheme subst (TypeScheme (vars, typ)) =
  (* 过滤掉被量化的变量 *)
  let filtered_subst = List.fold_left (fun acc var ->
    SubstMap.remove var acc
  ) subst vars in
  TypeScheme (vars, apply_subst filtered_subst typ)

(** 应用替换到环境 *)
let apply_subst_to_env subst env =
  TypeEnv.map (apply_subst_to_scheme subst) env

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

(** 获取类型方案中的自由变量 *)
let scheme_free_vars (TypeScheme (vars, typ)) =
  let type_vars = free_vars typ in
  List.filter (fun v -> not (List.mem v vars)) type_vars

(** 获取环境中的自由变量 *)
let env_free_vars env =
  TypeEnv.fold (fun _ scheme acc -> scheme_free_vars scheme @ acc) env []

(** 类型泛化 *)
let generalize env typ =
  let env_vars = env_free_vars env in
  let type_vars = free_vars typ in
  let free_type_vars = List.filter (fun v -> not (List.mem v env_vars)) type_vars in
  TypeScheme (free_type_vars, typ)

(** 类型实例化 *)
let instantiate (TypeScheme (quantified_vars, typ)) =
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
  | _ -> raise (TypeError ("无法统一类型: " ^ show_typ typ1 ^ " 与 " ^ show_typ typ2))

(** 变量合一 *)
and var_unify var_name typ =
  if typ = TypeVar_T var_name then
    empty_subst
  else if List.mem var_name (free_vars typ) then
    raise (TypeError ("循环类型检查失败: " ^ var_name ^ " 出现在 " ^ show_typ typ))
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
  | _ -> raise (TypeError "类型列表长度不匹配")

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
  | Add | Sub | Mul | Div | Mod ->
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

(** 从模式中提取变量绑定 *)
let rec extract_pattern_bindings pattern =
  match pattern with
  | WildcardPattern -> []
  | VarPattern var_name -> [(var_name, TypeScheme ([], new_type_var ()))]
  | LitPattern _ -> []
  | ConstructorPattern (_, sub_patterns) ->
    List.flatten (List.map extract_pattern_bindings sub_patterns)
  | TuplePattern patterns ->
    List.flatten (List.map extract_pattern_bindings patterns)
  | ListPattern patterns ->
    List.flatten (List.map extract_pattern_bindings patterns)
  | ConsPattern (head_pattern, tail_pattern) ->
    (extract_pattern_bindings head_pattern) @ (extract_pattern_bindings tail_pattern)
  | EmptyListPattern -> []
  | OrPattern (pattern1, pattern2) ->
    (extract_pattern_bindings pattern1) @ (extract_pattern_bindings pattern2)

(** 内置函数环境 *)
let builtin_env = 
  let env = TypeEnv.empty in
  let env = TypeEnv.add "print" (TypeScheme ([], FunType_T (StringType_T, UnitType_T))) env in
  let env = TypeEnv.add "read" (TypeScheme ([], FunType_T (UnitType_T, StringType_T))) env in
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
       let typ = instantiate scheme in  (* 现在支持多态 *)
       (empty_subst, typ)
     with Not_found ->
       raise (TypeError ("未定义的变量: " ^ var_name)))
       
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
    let env2 = TypeEnv.add var_name generalized_type env1 in
    let (subst2, body_type) = infer_type env2 body_expr in
    let final_subst = compose_subst subst1 subst2 in
    (final_subst, body_type)
    
  | MatchExpr (expr, branch_list) ->
    let (subst1, _expr_type) = infer_type env expr in
    let env1 = apply_subst_to_env subst1 env in
    (* Infer the type of the first branch to establish the expected return type *)
    (match branch_list with
     | [] -> raise (TypeError "匹配表达式必须至少有一个分支")
     | (first_pattern, first_branch_expr) :: rest_branches ->
       (* Add pattern variables to environment for first branch *)
       let first_pattern_bindings = extract_pattern_bindings first_pattern in
       let first_extended_env = List.fold_left (fun acc_env (var_name, var_type) ->
         TypeEnv.add var_name var_type acc_env
       ) env1 first_pattern_bindings in
       let (subst2, first_branch_type) = infer_type first_extended_env first_branch_expr in
       let env2 = apply_subst_to_env subst2 env1 in
       (* Check that all other branches have the same type *)
       let (final_subst, _) = List.fold_left (fun (acc_subst, expected_type) (pattern, branch_expr) ->
         let current_env = apply_subst_to_env acc_subst env2 in
         (* Add pattern variables to environment for this branch *)
         let pattern_bindings = extract_pattern_bindings pattern in
         let extended_env = List.fold_left (fun acc_env (var_name, var_type) ->
           TypeEnv.add var_name var_type acc_env
         ) current_env pattern_bindings in
         let (branch_subst, branch_type) = infer_type extended_env branch_expr in
         let unified_subst = unify (apply_subst branch_subst expected_type) branch_type in
         let new_subst = compose_subst (compose_subst acc_subst branch_subst) unified_subst in
         (new_subst, apply_subst new_subst expected_type)
       ) (compose_subst subst1 subst2, first_branch_type) rest_branches in
       (final_subst, apply_subst final_subst first_branch_type))
    
  | ListExpr expr_list ->
    (match expr_list with
     | [] -> 
       (* Empty list has polymorphic type *)
       let elem_type_var = new_type_var () in
       (empty_subst, ListType_T elem_type_var)
     | first_expr :: rest_exprs ->
       (* Infer type of first element *)
       let (subst1, first_type) = infer_type env first_expr in
       let env1 = apply_subst_to_env subst1 env in
       (* Check that all other elements have the same type *)
       let (final_subst, unified_type) = List.fold_left (fun (acc_subst, expected_type) expr ->
         let current_env = apply_subst_to_env acc_subst env1 in
         let (expr_subst, expr_type) = infer_type current_env expr in
         let unified_subst = unify (apply_subst expr_subst expected_type) expr_type in
         let new_subst = compose_subst (compose_subst acc_subst expr_subst) unified_subst in
         (new_subst, apply_subst new_subst expected_type)
       ) (subst1, first_type) rest_exprs in
       (final_subst, ListType_T unified_type))
    
  | SemanticLetExpr (var_name, _semantic_label, value_expr, body_expr) ->
    (* Similar to LetExpr - semantic labels don't affect type inference *)
    let (subst1, value_type) = infer_type env value_expr in
    let env1 = apply_subst_to_env subst1 env in
    let generalized_type = generalize env1 value_type in
    let env2 = TypeEnv.add var_name generalized_type env1 in
    let (subst2, body_type) = infer_type env2 body_expr in
    let final_subst = compose_subst subst1 subst2 in
    (final_subst, body_type)
    
  | CombineExpr expr_list ->
    (* Combine expressions into a list type *)
    infer_type env (ListExpr expr_list)
    
  | TupleExpr expr_list ->
    (* Infer types for each expression in the tuple *)
    let (final_subst, type_list) = List.fold_left (fun (acc_subst, acc_types) expr ->
      let current_env = apply_subst_to_env acc_subst env in
      let (expr_subst, expr_type) = infer_type current_env expr in
      let new_subst = compose_subst acc_subst expr_subst in
      (new_subst, acc_types @ [apply_subst new_subst expr_type])
    ) (empty_subst, []) expr_list in
    (final_subst, TupleType_T type_list)
    
  | OrElseExpr (primary_expr, default_expr) ->
    (* 推断主表达式和默认表达式的类型，它们应该兼容 *)
    let (primary_subst, primary_type) = infer_type env primary_expr in
    let env_after_primary = apply_subst_to_env primary_subst env in
    let (default_subst, default_type) = infer_type env_after_primary default_expr in
    let combined_subst = compose_subst primary_subst default_subst in
    
    (* 尝试统一两个类型 *)
    (try
      let unify_subst = unify (apply_subst combined_subst primary_type) 
                              (apply_subst combined_subst default_type) in
      let final_subst = compose_subst combined_subst unify_subst in
      (final_subst, apply_subst final_subst primary_type)
    with
    | TypeError _ ->
      (* 如果类型不能统一，返回主表达式的类型 *)
      (combined_subst, apply_subst combined_subst primary_type))
    
  | MacroCallExpr _ -> raise (TypeError "暂不支持宏调用")
  | AsyncExpr _ -> raise (TypeError "暂不支持异步表达式")
  
  | RecordExpr _fields ->
    (* 记录类型推断暂时返回一个新的类型变量 *)
    let typ_var = new_type_var () in
    (empty_subst, typ_var)
    
  | FieldAccessExpr (_record_expr, _field_name) ->
    (* 字段访问类型推断暂时返回一个新的类型变量 *)
    let typ_var = new_type_var () in
    (empty_subst, typ_var)
    
  | RecordUpdateExpr (_record_expr, _updates) ->
    (* 记录更新类型推断暂时返回一个新的类型变量 *)
    let typ_var = new_type_var () in
    (empty_subst, typ_var)

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
       | _ -> raise (TypeError ("期望函数类型但得到: " ^ show_typ unified_fun_type)))
  in
  process_params fun_type param_list initial_subst

(** 推断函数表达式 *)
and infer_fun_expr env param_list body =
  let rec process_params param_list env param_type_list =
    match param_list with
    | [] -> (env, List.rev param_type_list)
    | param_name :: remaining_params ->
      let param_type = new_type_var () in
      let new_env = TypeEnv.add param_name (TypeScheme ([], param_type)) env in
      process_params remaining_params new_env (param_type :: param_type_list)
  in
  let (extended_env, param_type_list) = process_params param_list env [] in
  let (subst, body_type) = infer_type extended_env body in
  let applied_param_type_list = List.map (apply_subst subst) param_type_list in
  let fun_type = List.fold_right (fun param_type acc -> FunType_T (param_type, acc)) applied_param_type_list body_type in
  (subst, fun_type)

(** 类型转换为中文显示 *)
let rec type_to_chinese_string typ =
  match typ with
  | IntType_T -> "整数"
  | FloatType_T -> "浮点数"
  | StringType_T -> "字符串"
  | BoolType_T -> "布尔值"
  | UnitType_T -> "单元"
  | FunType_T (param_type, return_type) ->
    Printf.sprintf "%s -> %s" 
      (type_to_chinese_string param_type) 
      (type_to_chinese_string return_type)
  | TupleType_T type_list ->
    let type_strs = List.map type_to_chinese_string type_list in
    "(" ^ String.concat " * " type_strs ^ ")"
  | ListType_T elem_type ->
    (type_to_chinese_string elem_type) ^ " 列表"
  | TypeVar_T name -> "'" ^ name
  | ConstructType_T (name, []) -> name
  | ConstructType_T (name, type_list) ->
    let type_strs = List.map type_to_chinese_string type_list in
    name ^ " of " ^ String.concat " * " type_strs

(** 显示表达式的类型信息 *)
let show_expr_type env expr =
  try
    let (subst, inferred_type) = infer_type env expr in
    let final_type = apply_subst subst inferred_type in
    Printf.printf "  表达式类型: %s\n" (type_to_chinese_string final_type)
  with
  | TypeError msg -> Printf.printf "  类型推断失败: %s\n" msg

(** 显示程序中所有变量的类型信息 *)
let show_program_types program =
  Printf.printf "=== 类型推断信息 ===\n";
  let env = ref TypeEnv.empty in
  let show_stmt stmt =
    match stmt with
    | LetStmt (var_name, expr) ->
      (try
        let (subst, expr_type) = infer_type !env expr in
        let final_type = apply_subst subst expr_type in
        Printf.printf "变量 %s: %s\n" var_name (type_to_chinese_string final_type);
        let generalized_scheme = generalize !env final_type in
        env := TypeEnv.add var_name generalized_scheme !env
      with
      | TypeError msg -> Printf.printf "变量 %s: 类型错误 - %s\n" var_name msg)
    | ExprStmt expr ->
      (try
        let (subst, expr_type) = infer_type !env expr in
        let final_type = apply_subst subst expr_type in
        Printf.printf "表达式结果: %s\n" (type_to_chinese_string final_type)
      with
      | TypeError msg -> Printf.printf "表达式: 类型错误 - %s\n" msg)
    | _ -> () (* 其他语句暂不显示类型 *)
  in
  List.iter show_stmt program;
  Printf.printf "\n"