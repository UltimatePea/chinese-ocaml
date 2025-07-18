(** 骆言解释器工具函数模块 - Chinese Programming Language Interpreter Utilities *)

open Ast
open Value_operations
open Error_recovery
open Interpreter_state

(** 找到最相似的变量名 *)
let find_closest_var target_var available_vars =
  if List.length available_vars = 0 then None
  else
    let distances =
      List.map (fun var -> (var, levenshtein_distance target_var var)) available_vars
    in
    let sorted_distances = List.sort (fun (_, d1) (_, d2) -> compare d1 d2) distances in
    match sorted_distances with
    | (closest_var, distance) :: _ ->
        if distance <= 2 && distance < String.length target_var then Some closest_var else None
    | [] -> None

(** 在环境中查找变量（带错误恢复） *)
let rec lookup_var env name =
  match String.split_on_char '.' name with
  | [] -> raise (RuntimeError "空变量名")
  | [ var_name ] -> (
      (* 简单变量查找 *)
      try List.assoc var_name env
      with Not_found -> (
        (* 检查递归函数表 *)
        match find_recursive_function var_name with
        | Some func_val -> func_val
        | None ->
            let config = Error_recovery.get_recovery_config () in
            if config.enabled && config.spell_correction then
              let available_vars = get_available_vars env in
              match find_closest_var var_name available_vars with
              | Some closest_var ->
                  Error_recovery.log_recovery_type "spell_correction"
                    (Printf.sprintf "变量名'%s'未找到，使用最接近的'%s'" var_name closest_var);
                  lookup_var env closest_var
              | None -> raise (RuntimeError ("未定义的变量: " ^ var_name))
            else raise (RuntimeError ("未定义的变量: " ^ var_name))))
  | module_name :: member_path -> (
      (* 模块成员访问 *)
      match find_module module_name with
      | Some module_bindings -> (
          let member_name = String.concat "." member_path in
          try List.assoc member_name module_bindings
          with Not_found -> raise (RuntimeError ("模块中未找到成员: " ^ member_name)))
      | None -> raise (RuntimeError ("未找到模块: " ^ module_name)))

(** 变量绑定 *)
let bind_var env var_name value = (var_name, value) :: env

(** 求值字面量 *)
let eval_literal literal =
  match literal with
  | IntLit n -> IntValue n
  | FloatLit f -> FloatValue f
  | StringLit s -> StringValue s
  | BoolLit b -> BoolValue b
  | UnitLit -> UnitValue

(** 宏展开：将宏体中的参数替换为实际参数 *)
let expand_macro (macro_def : Ast.macro_def) args =
  (* 创建参数到表达式的映射 *)
  let param_map = Hashtbl.create (List.length macro_def.params) in

  (* 将宏参数与实际参数关联 *)
  let rec bind_params params args =
    match (params, args) with
    | [], [] -> ()
    | ExprParam param_name :: rest_params, arg_expr :: rest_args ->
        Hashtbl.replace param_map param_name arg_expr;
        bind_params rest_params rest_args
    | StmtParam param_name :: rest_params, arg_expr :: rest_args ->
        (* 语句参数也暂时当作表达式处理 *)
        Hashtbl.replace param_map param_name arg_expr;
        bind_params rest_params rest_args
    | TypeParam param_name :: rest_params, arg_expr :: rest_args ->
        (* 类型参数暂时当作表达式处理 *)
        Hashtbl.replace param_map param_name arg_expr;
        bind_params rest_params rest_args
    | _, _ ->
        (* 参数数量不匹配，记录警告但继续处理 *)
        ()
  in

  bind_params macro_def.params args;

  (* 递归替换宏体中的参数引用 *)
  let rec substitute_expr expr =
    match expr with
    | VarExpr var_name -> (
        match Hashtbl.find_opt param_map var_name with
        | Some replacement_expr -> replacement_expr
        | None -> expr)
    | BinaryOpExpr (left, op, right) ->
        BinaryOpExpr (substitute_expr left, op, substitute_expr right)
    | UnaryOpExpr (op, operand) -> UnaryOpExpr (op, substitute_expr operand)
    | FunCallExpr (func_expr, arg_exprs) ->
        FunCallExpr (substitute_expr func_expr, List.map substitute_expr arg_exprs)
    | CondExpr (cond, then_branch, else_branch) ->
        CondExpr (substitute_expr cond, substitute_expr then_branch, substitute_expr else_branch)
    | LetExpr (var_name, value_expr, body_expr) ->
        LetExpr (var_name, substitute_expr value_expr, substitute_expr body_expr)
    | ListExpr exprs -> ListExpr (List.map substitute_expr exprs)
    | TupleExpr exprs -> TupleExpr (List.map substitute_expr exprs)
    | ArrayExpr exprs -> ArrayExpr (List.map substitute_expr exprs)
    | RecordExpr fields ->
        RecordExpr (List.map (fun (name, expr) -> (name, substitute_expr expr)) fields)
    (* 其他表达式类型保持不变或递归处理 *)
    | _ -> expr
  in

  substitute_expr macro_def.body
