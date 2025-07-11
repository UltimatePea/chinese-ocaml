(** 骆言代码生成器/解释器 - Chinese Programming Language Code Generator/Interpreter *)

open Ast

(** 运行时值 *)
type runtime_value =
  | IntValue of int
  | FloatValue of float
  | StringValue of string
  | BoolValue of bool
  | UnitValue
  | ListValue of runtime_value list
  | FunctionValue of string list * expr * runtime_env  (* 参数列表, 函数体, 闭包环境 *)
  | BuiltinFunctionValue of (runtime_value list -> runtime_value)

(** 运行时环境 *)
and runtime_env = (string * runtime_value) list

(** 运行时错误 *)
exception RuntimeError of string

(* 全局模块表 *)
let module_table : (string, (string * runtime_value) list) Hashtbl.t = Hashtbl.create 8

(* Global table for recursive functions to handle self-reference *)
let recursive_functions : (string, runtime_value) Hashtbl.t = Hashtbl.create 8

(** 创建空环境 *)
let empty_env = []

(** 在环境中查找变量 *)
let rec lookup_var env name =
  match String.split_on_char '.' name with
  | [] -> raise (RuntimeError ("空变量名"))
  | [var] ->
    (try List.assoc var env
     with Not_found -> 
       (* Check if it's a recursive function *)
       try Hashtbl.find recursive_functions var
       with Not_found -> raise (RuntimeError ("未定义的变量: " ^ var)))
  | mod_name :: rest ->
    let mod_env =
      try Hashtbl.find module_table mod_name
      with Not_found -> raise (RuntimeError ("未定义的模块: " ^ mod_name))
    in
    lookup_var mod_env (String.concat "." rest)

(** 在环境中绑定变量 *)
let bind_var env var_name value = (var_name, value) :: env

(** 值转换为字符串 *)
let rec value_to_string value =
  match value with
  | IntValue n -> string_of_int n
  | FloatValue f -> string_of_float f
  | StringValue s -> s
  | BoolValue b -> if b then "真" else "假"
  | UnitValue -> "()"
  | ListValue lst -> "[" ^ String.concat "; " (List.map value_to_string lst) ^ "]"
  | FunctionValue (_, _, _) -> "<函数>"
  | BuiltinFunctionValue _ -> "<内置函数>"

(** 值转换为布尔值 *)
and value_to_bool value =
  match value with
  | BoolValue b -> b
  | IntValue 0 -> false
  | IntValue _ -> true
  | StringValue "" -> false
  | StringValue _ -> true
  | UnitValue -> false
  | _ -> true

(** 二元运算实现 *)
and execute_binary_op op left_val right_val =
  match (op, left_val, right_val) with
  (* 算术运算 *)
  | (Add, IntValue a, IntValue b) -> IntValue (a + b)
  | (Sub, IntValue a, IntValue b) -> IntValue (a - b)
  | (Mul, IntValue a, IntValue b) -> IntValue (a * b)
  | (Div, IntValue a, IntValue b) -> 
    if b = 0 then raise (RuntimeError "除零错误")
    else IntValue (a / b)
  | (Mod, IntValue a, IntValue b) -> 
    if b = 0 then raise (RuntimeError "取模零错误")
    else IntValue (a mod b)
  | (Add, FloatValue a, FloatValue b) -> FloatValue (a +. b)
  | (Sub, FloatValue a, FloatValue b) -> FloatValue (a -. b)
  | (Mul, FloatValue a, FloatValue b) -> FloatValue (a *. b)
  | (Div, FloatValue a, FloatValue b) -> FloatValue (a /. b)
  
  (* 字符串连接 *)
  | (Add, StringValue a, StringValue b) -> StringValue (a ^ b)
  
  (* 比较运算 *)
  | (Eq, a, b) -> BoolValue (a = b)
  | (Neq, a, b) -> BoolValue (a <> b)
  | (Lt, IntValue a, IntValue b) -> BoolValue (a < b)
  | (Le, IntValue a, IntValue b) -> BoolValue (a <= b)
  | (Gt, IntValue a, IntValue b) -> BoolValue (a > b)
  | (Ge, IntValue a, IntValue b) -> BoolValue (a >= b)
  | (Lt, FloatValue a, FloatValue b) -> BoolValue (a < b)
  | (Le, FloatValue a, FloatValue b) -> BoolValue (a <= b)
  | (Gt, FloatValue a, FloatValue b) -> BoolValue (a > b)
  | (Ge, FloatValue a, FloatValue b) -> BoolValue (a >= b)
  
  (* 逻辑运算 *)
  | (And, a, b) -> BoolValue (value_to_bool a && value_to_bool b)
  | (Or, a, b) -> BoolValue (value_to_bool a || value_to_bool b)
  
  | _ -> raise (RuntimeError ("不支持的二元运算: " ^ value_to_string left_val ^ " " ^ value_to_string right_val))

(** 一元运算实现 *)
and execute_unary_op op value =
  match (op, value) with
  | (Neg, IntValue n) -> IntValue (-n)
  | (Neg, FloatValue f) -> FloatValue (-.f)
  | (Not, v) -> BoolValue (not (value_to_bool v))
  | _ -> raise (RuntimeError ("不支持的一元运算: " ^ value_to_string value))

(** 模式匹配 *)
and match_pattern pattern value env =
  match (pattern, value) with
  | (WildcardPattern, _) -> Some env
  | (VarPattern var_name, value) -> Some (bind_var env var_name value)
  | (LitPattern (IntLit n1), IntValue n2) when n1 = n2 -> Some env
  | (LitPattern (FloatLit f1), FloatValue f2) when f1 = f2 -> Some env
  | (LitPattern (StringLit s1), StringValue s2) when s1 = s2 -> Some env
  | (LitPattern (BoolLit b1), BoolValue b2) when b1 = b2 -> Some env
  | (LitPattern UnitLit, UnitValue) -> Some env
  | (EmptyListPattern, ListValue []) -> Some env
  | (ConsPattern (head_pattern, tail_pattern), ListValue (head_value :: tail_values)) ->
    (match match_pattern head_pattern head_value env with
     | Some new_env -> match_pattern tail_pattern (ListValue tail_values) new_env
     | None -> None)
  | _ -> None

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
    if value_to_bool cond_val then
      eval_expr env then_branch
    else
      eval_expr env else_branch
      
  | FunExpr (param_list, body) ->
    FunctionValue (param_list, body, env)
    
  | LetExpr (var_name, val_expr, body_expr) ->
    let value = eval_expr env val_expr in
    let new_env = bind_var env var_name value in
    eval_expr new_env body_expr
    
  | MatchExpr (expr, branch_list) ->
    let value = eval_expr env expr in
    execute_match env value branch_list
    
  | ListExpr expr_list ->
    let values = List.map (eval_expr env) expr_list in
    ListValue values
    
  | _ -> raise (RuntimeError "不支持的表达式类型")

(** 求值字面量 *)
and eval_literal literal =
  match literal with
  | IntLit n -> IntValue n
  | FloatLit f -> FloatValue f
  | StringLit s -> StringValue s
  | BoolLit b -> BoolValue b
  | UnitLit -> UnitValue

(** 调用函数 *)
and call_function func_val arg_vals =
  match func_val with
  | BuiltinFunctionValue f -> f arg_vals
  | FunctionValue (param_list, body, closure_env) ->
    if List.length param_list <> List.length arg_vals then
      raise (RuntimeError "函数参数数量不匹配")
    else
      let new_env = List.fold_left2 (fun acc_env param_name arg_val ->
        bind_var acc_env param_name arg_val
      ) closure_env param_list arg_vals in
      eval_expr new_env body
  | _ -> raise (RuntimeError "尝试调用非函数值")

(** 执行模式匹配 *)
and execute_match env value branch_list =
  match branch_list with
  | [] -> raise (RuntimeError "模式匹配失败：没有匹配的分支")
  | (pattern, expr) :: rest_branches ->
    (match match_pattern pattern value env with
     | Some new_env -> eval_expr new_env expr
     | None -> execute_match env value rest_branches)

(** 内置函数实现 *)
let builtin_functions = [
  ("打印", BuiltinFunctionValue (function
    | [StringValue s] -> print_endline s; UnitValue
    | [value] -> print_endline (value_to_string value); UnitValue
    | _ -> raise (RuntimeError "打印函数期望一个参数")));
    
  ("读取", BuiltinFunctionValue (function
    | [UnitValue] -> StringValue (read_line ())
    | [] -> StringValue (read_line ())
    | _ -> raise (RuntimeError "读取函数不需要参数")));
    
  ("长度", BuiltinFunctionValue (function
    | [StringValue s] -> IntValue (String.length s)
    | _ -> raise (RuntimeError "长度函数期望一个字符串参数")));
]

(** 执行语句 *)
let rec execute_stmt env stmt =
  match stmt with
  | ExprStmt expr ->
    let value = eval_expr env expr in
    (env, value)
  | LetStmt (var_name, expr) ->
    let value = eval_expr env expr in
    let new_env = bind_var env var_name value in
    (new_env, value)
  | RecLetStmt (func_name, expr) ->
    let func_val =
      match expr with
      | FunExpr (param_list, body) ->
        (* Create function with current environment *)
        let func_value = FunctionValue (param_list, body, env) in
        (* Store in global recursive functions table for self-reference *)
        Hashtbl.replace recursive_functions func_name func_value;
        func_value
      | _ -> raise (RuntimeError "递归让语句期望函数表达式")
    in
    let new_env = bind_var env func_name func_val in
    (new_env, func_val)
  | TypeDefStmt (_type_name, _type_def) ->
    (env, UnitValue)
  | ModuleDefStmt mdef ->
    let mod_env = List.fold_left (fun e s -> fst (execute_stmt e s)) [] mdef.statements in
    Hashtbl.replace module_table mdef.module_def_name mod_env;
    (env, UnitValue)
  | ModuleImportStmt _ ->
    (env, UnitValue)
  | MacroDefStmt _ ->
    (env, UnitValue)

(** 执行程序 *)
let execute_program program =
  let initial_env = builtin_functions @ empty_env in
  
  let rec execute_stmt_list env stmts last_val =
    match stmts with
    | [] -> last_val
    | stmt :: rest_stmts ->
      let (new_env, value) = execute_stmt env stmt in
      execute_stmt_list new_env rest_stmts value
  in
  
  try
    let result = execute_stmt_list initial_env program UnitValue in
    Ok result
  with
  | RuntimeError msg -> Error ("运行时错误: " ^ msg)
  | e -> Error ("未知错误: " ^ Printexc.to_string e)

(** 解释执行入口函数 *)
let interpret program =
  match execute_program program with
  | Ok result -> 
    Printf.printf "程序执行完成，结果: %s\n" (value_to_string result);
    true
  | Error error_msg ->
    Printf.printf "执行错误: %s\n" error_msg;
    false

(** 安静模式解释执行 - 用于测试 *)
let interpret_quiet program =
  match execute_program program with
  | Ok _result -> true
  | Error _error_msg -> false

(** 交互式求值 *)
let interactive_eval expr env =
  try
    let result = eval_expr env expr in
    Printf.printf "=> %s\n" (value_to_string result);
    env
  with
  | RuntimeError msg ->
    Printf.printf "错误: %s\n" msg;
    env
  | e ->
    Printf.printf "未知错误: %s\n" (Printexc.to_string e);
    env