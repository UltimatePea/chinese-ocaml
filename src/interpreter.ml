(** 骆言解释器模块 - Chinese Programming Language Interpreter Module *)

open Ast
open Value_operations
open Error_recovery

(** 宏定义类型 *)
type macro_def = { body : expr; args : string list; } [@@warning "-34"]

(** 宏环境类型 *)
type macro_env = (string * macro_def) list [@@warning "-34"]

(** 全局宏表 *)
let macro_table : (string, macro_def) Hashtbl.t = Hashtbl.create 16

(** 全局模块表 *)
let module_table : (string, (string * runtime_value) list) Hashtbl.t = Hashtbl.create 8

(** 全局递归函数表 *)
let recursive_functions : (string, runtime_value) Hashtbl.t = Hashtbl.create 8

(** 全局函子表 *)
let functor_table : (string, identifier * module_type * expr) Hashtbl.t = Hashtbl.create 8

(** 简单的宏展开 *)
let expand_macro macro_def _args =
  (* 简化版本：假设宏体中的参数直接替换为提供的参数 *)
  (* 这是一个非常基础的实现，实际的宏展开会更复杂 *)
  macro_def.body

(** 从环境中获取所有可用的变量名 *)
let get_available_vars env =
  let env_vars = List.map fst env in
  let recursive_vars = Hashtbl.fold (fun k _ acc -> k :: acc) recursive_functions [] in
  env_vars @ recursive_vars

(** 找到最相似的变量名 *)
let find_closest_var target_var available_vars =
  if List.length available_vars = 0 then None
  else
    let distances = List.map (fun var -> (var, levenshtein_distance target_var var)) available_vars in
    let sorted_distances = List.sort (fun (_, d1) (_, d2) -> compare d1 d2) distances in
    match sorted_distances with
    | (closest_var, distance) :: _ ->
        if distance <= 2 && distance < String.length target_var then Some closest_var else None
    | [] -> None

(** 在环境中查找变量（带错误恢复） *)
let rec lookup_var env name =
  match String.split_on_char '.' name with
  | [] -> raise (RuntimeError "空变量名")
  | [ var ] -> (
      try List.assoc var env
      with Not_found -> (
        (* Check if it's a recursive function *)
        try Hashtbl.find recursive_functions var
        with Not_found ->
          (* 尝试拼写纠正 *)
          if Error_recovery.spell_correction_enabled () then
            let available_vars = get_available_vars env in
            match find_closest_var var available_vars with
            | Some corrected_var -> (
                Error_recovery.log_recovery_type "spell_correction"
                  (Printf.sprintf "将变量名\"%s\"纠正为\"%s\"" var corrected_var);
                try List.assoc corrected_var env
                with Not_found -> Hashtbl.find recursive_functions corrected_var)
            | None ->
                raise
                  (RuntimeError
                     ("未定义的变量: " ^ var ^ " (可用变量: " ^ String.concat ", " available_vars ^ ")"))
          else raise (RuntimeError ("未定义的变量: " ^ var))))
  | mod_name :: rest ->
      let mod_env =
        try Hashtbl.find module_table mod_name
        with Not_found -> raise (RuntimeError ("未定义的模块: " ^ mod_name))
      in
      lookup_var mod_env (String.concat "." rest)

(** 求值字面量 *)
let eval_literal = function
  | IntLit i -> IntValue i
  | FloatLit f -> FloatValue f
  | StringLit s -> StringValue s
  | BoolLit b -> BoolValue b
  | UnitLit -> UnitValue

(** 二元运算实现 *)
let execute_binary_op op left_val right_val =
  match op with
  | Add -> (
      match (left_val, right_val) with
      | IntValue l, IntValue r -> IntValue (l + r)
      | FloatValue l, FloatValue r -> FloatValue (l +. r)
      | IntValue l, FloatValue r -> FloatValue (float_of_int l +. r)
      | FloatValue l, IntValue r -> FloatValue (l +. float_of_int r)
      | StringValue l, StringValue r -> StringValue (l ^ r)
      | _ -> raise (RuntimeError "类型错误：不支持的加法操作"))
  | Sub -> (
      match (left_val, right_val) with
      | IntValue l, IntValue r -> IntValue (l - r)
      | FloatValue l, FloatValue r -> FloatValue (l -. r)
      | IntValue l, FloatValue r -> FloatValue (float_of_int l -. r)
      | FloatValue l, IntValue r -> FloatValue (l -. float_of_int r)
      | _ -> raise (RuntimeError "类型错误：不支持的减法操作"))
  | Mul -> (
      match (left_val, right_val) with
      | IntValue l, IntValue r -> IntValue (l * r)
      | FloatValue l, FloatValue r -> FloatValue (l *. r)
      | IntValue l, FloatValue r -> FloatValue (float_of_int l *. r)
      | FloatValue l, IntValue r -> FloatValue (l *. float_of_int r)
      | _ -> raise (RuntimeError "类型错误：不支持的乘法操作"))
  | Div -> (
      match (left_val, right_val) with
      | IntValue l, IntValue r -> if r = 0 then raise (RuntimeError "除零错误") else IntValue (l / r)
      | FloatValue l, FloatValue r -> if r = 0.0 then raise (RuntimeError "除零错误") else FloatValue (l /. r)
      | IntValue l, FloatValue r -> if r = 0.0 then raise (RuntimeError "除零错误") else FloatValue (float_of_int l /. r)
      | FloatValue l, IntValue r -> if r = 0 then raise (RuntimeError "除零错误") else FloatValue (l /. float_of_int r)
      | _ -> raise (RuntimeError "类型错误：不支持的除法操作"))
  | Equal -> BoolValue (left_val = right_val)
  | NotEqual -> BoolValue (left_val <> right_val)
  | LessThan -> (
      match (left_val, right_val) with
      | IntValue l, IntValue r -> BoolValue (l < r)
      | FloatValue l, FloatValue r -> BoolValue (l < r)
      | IntValue l, FloatValue r -> BoolValue (float_of_int l < r)
      | FloatValue l, IntValue r -> BoolValue (l < float_of_int r)
      | _ -> raise (RuntimeError "类型错误：不支持的比较操作"))
  | LessEqual -> (
      match (left_val, right_val) with
      | IntValue l, IntValue r -> BoolValue (l <= r)
      | FloatValue l, FloatValue r -> BoolValue (l <= r)
      | IntValue l, FloatValue r -> BoolValue (float_of_int l <= r)
      | FloatValue l, IntValue r -> BoolValue (l <= float_of_int r)
      | _ -> raise (RuntimeError "类型错误：不支持的比较操作"))
  | GreaterThan -> (
      match (left_val, right_val) with
      | IntValue l, IntValue r -> BoolValue (l > r)
      | FloatValue l, FloatValue r -> BoolValue (l > r)
      | IntValue l, FloatValue r -> BoolValue (float_of_int l > r)
      | FloatValue l, IntValue r -> BoolValue (l > float_of_int r)
      | _ -> raise (RuntimeError "类型错误：不支持的比较操作"))
  | GreaterEqual -> (
      match (left_val, right_val) with
      | IntValue l, IntValue r -> BoolValue (l >= r)
      | FloatValue l, FloatValue r -> BoolValue (l >= r)
      | IntValue l, FloatValue r -> BoolValue (float_of_int l >= r)
      | FloatValue l, IntValue r -> BoolValue (l >= float_of_int r)
      | _ -> raise (RuntimeError "类型错误：不支持的比较操作"))
  | And -> BoolValue (value_to_bool left_val && value_to_bool right_val)
  | Or -> BoolValue (value_to_bool left_val || value_to_bool right_val)

(** 一元运算实现 *)
let execute_unary_op op value =
  match op with
  | Neg -> (
      match value with
      | IntValue i -> IntValue (-i)
      | FloatValue f -> FloatValue (-.f)
      | _ -> raise (RuntimeError "类型错误：不支持的负号操作"))
  | Not -> BoolValue (not (value_to_bool value))

(** 调用函数 *)
let rec call_function func_val arg_vals =
  match func_val with
  | BuiltinFunctionValue f -> f arg_vals
  | FunctionValue (param_list, body, closure_env) ->
      let param_count = List.length param_list in
      let arg_count = List.length arg_vals in
      
      if param_count = arg_count then
        (* 参数数量匹配，正常执行 *)
        let new_env =
          List.fold_left2
            (fun acc_env param_name arg_val -> bind_var acc_env param_name arg_val)
            closure_env param_list arg_vals
        in
        eval_expr new_env body
      else 
        raise (RuntimeError "函数参数数量不匹配")
  | _ -> raise (RuntimeError "尝试调用非函数值")

(** 求值表达式 *)
and eval_expr env expr =
  match expr with
  | LitExpr literal -> eval_literal literal
  | VarExpr var_name -> lookup_var env var_name
  | BinaryOpExpr (left_expr, op, right_expr) ->
      let left_val = eval_expr env left_expr in
      let right_val = eval_expr env right_expr in
      execute_binary_op op left_val right_val
  | UnaryOpExpr (op, expr) ->
      let value = eval_expr env expr in
      execute_unary_op op value
  | FunCallExpr (func_expr, arg_list) ->
      let func_val = eval_expr env func_expr in
      let arg_vals = List.map (eval_expr env) arg_list in
      call_function func_val arg_vals
  | CondExpr (cond, then_branch, else_branch) ->
      let cond_val = eval_expr env cond in
      if value_to_bool cond_val then eval_expr env then_branch else eval_expr env else_branch
  | FunExpr (param_list, body) -> FunctionValue (param_list, body, env)
  | LetExpr (var_name, val_expr, body_expr) ->
      let value = eval_expr env val_expr in
      let new_env = bind_var env var_name value in
      eval_expr new_env body_expr
  | ListExpr expr_list ->
      let values = List.map (eval_expr env) expr_list in
      ListValue values
  | SemanticLetExpr (var_name, _semantic_label, val_expr, body_expr) ->
      (* For now, semantic labels are just metadata - evaluate normally *)
      let value = eval_expr env val_expr in
      let new_env = bind_var env var_name value in
      eval_expr new_env body_expr
  | CombineExpr expr_list ->
      (* Combine expressions into a list of values *)
      let values = List.map (eval_expr env) expr_list in
      ListValue values
  | OrElseExpr (primary_expr, default_expr) -> (
      (* 尝试执行主表达式，如果出错或产生无效值则返回默认值 *)
      try
        let result = eval_expr env primary_expr in
        match result with UnitValue -> eval_expr env default_expr (* 单元值被视为"无效" *) | _ -> result
      with RuntimeError _ | Failure _ ->
        (* 主表达式出错，返回默认值 *)
        Error_recovery.log_recovery_type "or_else_fallback" "主表达式执行失败，使用默认值";
        eval_expr env default_expr)
  | _ -> raise (RuntimeError "暂不支持的表达式类型")

(** 执行语句 *)
let rec execute_stmt env stmt =
  match stmt with
  | ExprStmt expr ->
      let _ = eval_expr env expr in
      env
  | LetStmt (var_name, value_expr) ->
      let value = eval_expr env value_expr in
      bind_var env var_name value
  | LetStmtWithType (var_name, _type_annotation, value_expr) ->
      (* For now, ignore type annotations during execution *)
      let value = eval_expr env value_expr in
      bind_var env var_name value
  | _ -> raise (RuntimeError "暂不支持的语句类型")

(** 执行程序 *)
let execute_program program =
  (* 重置统计信息 *)
  Error_recovery.reset_recovery_statistics ();
  let initial_env = Builtin_functions.builtin_functions @ empty_env in

  let rec execute_stmt_list env stmts last_val =
    match stmts with
    | [] -> last_val
    | stmt :: rest_stmts ->
        let new_env = execute_stmt env stmt in
        execute_stmt_list new_env rest_stmts UnitValue
  in

  let _ = execute_stmt_list initial_env program UnitValue in
  ()

(** 解释程序（带输出） *)
let interpret program =
  try
    execute_program program;
    true
  with
  | RuntimeError msg ->
      Printf.eprintf "运行时错误: %s\n" msg;
      false
  | ex ->
      Printf.eprintf "未处理的异常: %s\n" (Printexc.to_string ex);
      false

(** 静默解释程序 *)
let interpret_quiet program =
  try
    execute_program program;
    true
  with
  | _ -> false

(** 交互式表达式求值 *)
let interactive_eval expr env =
  try
    let result = eval_expr env expr in
    (result, env)
  with
  | RuntimeError msg ->
      Printf.eprintf "运行时错误: %s\n" msg;
      (UnitValue, env)