(** 骆言代码生成器/解释器 - Chinese Programming Language Code Generator/Interpreter *)

open Ast

(** 错误恢复配置 *)
type error_recovery_config = {
  enabled: bool;
  type_conversion: bool;
  spell_correction: bool;
  log_level: string; (* "quiet" | "normal" | "verbose" *)
}

(** 默认错误恢复配置 *)
let default_recovery_config = {
  enabled = true;
  type_conversion = true;
  spell_correction = true;
  log_level = "normal";
}

(** 全局错误恢复配置 *)
let recovery_config = ref default_recovery_config

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

(** 计算两个字符串的编辑距离 (Levenshtein distance) *)
let levenshtein_distance str1 str2 =
  let len1 = String.length str1 in
  let len2 = String.length str2 in
  let matrix = Array.make_matrix (len1 + 1) (len2 + 1) 0 in
  
  (* 初始化第一行和第一列 *)
  for i = 0 to len1 do matrix.(i).(0) <- i done;
  for j = 0 to len2 do matrix.(0).(j) <- j done;
  
  (* 填充矩阵 *)
  for i = 1 to len1 do
    for j = 1 to len2 do
      let cost = if str1.[i-1] = str2.[j-1] then 0 else 1 in
      matrix.(i).(j) <- min (min 
        (matrix.(i-1).(j) + 1)    (* 删除 *)
        (matrix.(i).(j-1) + 1))   (* 插入 *)
        (matrix.(i-1).(j-1) + cost) (* 替换 *)
    done
  done;
  matrix.(len1).(len2)

(** 从环境中获取所有可用的变量名 *)
let get_available_vars env =
  let env_vars = List.map fst env in
  let recursive_vars = Hashtbl.fold (fun k _ acc -> k :: acc) recursive_functions [] in
  env_vars @ recursive_vars

(** 找到最相似的变量名 *)
let find_closest_var target_var available_vars =
  let distances = List.map (fun var -> 
    (var, levenshtein_distance target_var var)
  ) available_vars in
  let sorted = List.sort (fun (_, d1) (_, d2) -> compare d1 d2) distances in
  match sorted with
  | [] -> None
  | (closest_var, distance) :: _ ->
    (* 只有当距离足够小时才建议 *)
    if distance <= 2 && distance < String.length target_var / 2 then
      Some closest_var
    else
      None

(** 记录错误恢复日志 *)
let log_recovery msg =
  if !recovery_config.log_level <> "quiet" then
    Printf.printf "[恢复] %s\n" msg

(** 在环境中查找变量 *)
let rec lookup_var env name =
  match String.split_on_char '.' name with
  | [] -> raise (RuntimeError ("空变量名"))
  | [var] ->
    (try List.assoc var env
     with Not_found -> 
       (* Check if it's a recursive function *)
       try Hashtbl.find recursive_functions var
       with Not_found -> 
         (* 尝试拼写纠正 *)
         if !recovery_config.spell_correction then
           let available_vars = get_available_vars env in
           match find_closest_var var available_vars with
           | Some corrected_var ->
             log_recovery (Printf.sprintf "将变量名\"%s\"纠正为\"%s\"" var corrected_var);
             (try List.assoc corrected_var env
              with Not_found -> Hashtbl.find recursive_functions corrected_var)
           | None ->
             raise (RuntimeError ("未定义的变量: " ^ var ^ 
               " (可用变量: " ^ String.concat ", " available_vars ^ ")"))
         else
           raise (RuntimeError ("未定义的变量: " ^ var)))
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



(** 尝试将值转换为整数 *)
and try_to_int value =
  match value with
  | IntValue n -> Some n
  | FloatValue f -> 
    log_recovery (Printf.sprintf "将浮点数%.2f转换为整数%d" f (int_of_float f));
    Some (int_of_float f)
  | StringValue s ->
    (try
       let n = int_of_string s in
       log_recovery (Printf.sprintf "将字符串\"%s\"转换为整数%d" s n);
       Some n
     with _ -> None)
  | BoolValue b -> 
    let n = if b then 1 else 0 in
    log_recovery (Printf.sprintf "将布尔值%s转换为整数%d" (if b then "真" else "假") n);
    Some n
  | _ -> None

(** 尝试将值转换为浮点数 *)
and try_to_float value =
  match value with
  | FloatValue f -> Some f
  | IntValue n -> 
    let f = float_of_int n in
    log_recovery (Printf.sprintf "将整数%d转换为浮点数%.2f" n f);
    Some f
  | StringValue s ->
    (try
       let f = float_of_string s in
       log_recovery (Printf.sprintf "将字符串\"%s\"转换为浮点数%.2f" s f);
       Some f
     with _ -> None)
  | _ -> None

(** 尝试将值转换为字符串 *)
and try_to_string value =
  match value with
  | StringValue s -> Some s
  | _ -> 
    let s = value_to_string value in
    log_recovery (Printf.sprintf "将%s转换为字符串\"%s\"" 
      (match value with
       | IntValue _ -> "整数"
       | FloatValue _ -> "浮点数"
       | BoolValue _ -> "布尔值"
       | _ -> "值") s);
    Some s

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
  
  | _ ->
    (* 尝试自动类型转换 *)
    if !recovery_config.enabled && !recovery_config.type_conversion then
      match op with
      | Add | Sub | Mul | Div | Mod ->
        (* 尝试数值运算的类型转换 *)
        (match (try_to_int left_val, try_to_int right_val) with
         | (Some a, Some b) -> 
           execute_binary_op op (IntValue a) (IntValue b)
         | _ ->
           match (try_to_float left_val, try_to_float right_val) with
           | (Some a, Some b) ->
             execute_binary_op op (FloatValue a) (FloatValue b)
           | _ ->
             (* 如果是加法，尝试字符串连接 *)
             if op = Add then
               match (try_to_string left_val, try_to_string right_val) with
               | (Some a, Some b) ->
                 execute_binary_op op (StringValue a) (StringValue b)
               | _ -> raise (RuntimeError ("不支持的二元运算: " ^ value_to_string left_val ^ " " ^ value_to_string right_val))
             else
               raise (RuntimeError ("不支持的二元运算: " ^ value_to_string left_val ^ " " ^ value_to_string right_val)))
      | Lt | Le | Gt | Ge ->
        (* 比较运算的类型转换 *)
        (match (try_to_float left_val, try_to_float right_val) with
         | (Some a, Some b) ->
           execute_binary_op op (FloatValue a) (FloatValue b)
         | _ -> raise (RuntimeError ("不支持的比较运算: " ^ value_to_string left_val ^ " " ^ value_to_string right_val)))
      | _ -> raise (RuntimeError ("不支持的二元运算: " ^ value_to_string left_val ^ " " ^ value_to_string right_val))
    else
      raise (RuntimeError ("不支持的二元运算: " ^ value_to_string left_val ^ " " ^ value_to_string right_val))

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
    
  | SemanticLetExpr (var_name, _semantic_label, val_expr, body_expr) ->
    (* For now, semantic labels are just metadata - evaluate normally *)
    let value = eval_expr env val_expr in
    let new_env = bind_var env var_name value in
    eval_expr new_env body_expr
    
  | CombineExpr expr_list ->
    (* Combine expressions into a list of values *)
    let values = List.map (eval_expr env) expr_list in
    ListValue values
    
  | OrElseExpr (primary_expr, default_expr) ->
    (* 尝试执行主表达式，如果出错或产生无效值则返回默认值 *)
    (try
      let result = eval_expr env primary_expr in
      match result with
      | UnitValue -> eval_expr env default_expr  (* 单元值被视为"无效" *)
      | _ -> result
    with
    | RuntimeError _ | Failure _ ->
      (* 主表达式出错，返回默认值 *)
      log_recovery "主表达式执行失败，使用默认值";
      eval_expr env default_expr)
    
  | TupleExpr _ -> raise (RuntimeError "元组表达式尚未实现")
  | MacroCallExpr _ -> raise (RuntimeError "宏调用尚未实现")
  | AsyncExpr _ -> raise (RuntimeError "异步表达式尚未实现")

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
    let param_count = List.length param_list in
    let arg_count = List.length arg_vals in
    
    if param_count = arg_count then
      (* 参数数量匹配，正常执行 *)
      let new_env = List.fold_left2 (fun acc_env param_name arg_val ->
        bind_var acc_env param_name arg_val
      ) closure_env param_list arg_vals in
      eval_expr new_env body
    else if !recovery_config.enabled then
      (* 参数数量不匹配，但启用了错误恢复 *)
      if arg_count < param_count then
        (* 参数不足，用默认值填充 *)
        let missing_count = param_count - arg_count in
        let default_vals = List.init missing_count (fun _ -> IntValue 0) in
        let adapted_args = arg_vals @ default_vals in
        log_recovery (Printf.sprintf "函数期望%d个参数，提供了%d个，用默认值填充缺失的%d个参数" 
                      param_count arg_count missing_count);
        let new_env = List.fold_left2 (fun acc_env param_name arg_val ->
          bind_var acc_env param_name arg_val
        ) closure_env param_list adapted_args in
        eval_expr new_env body
      else
        (* 参数过多，忽略多余的参数 *)
        let extra_count = arg_count - param_count in
        let rec take n lst = 
          if n <= 0 then [] 
          else match lst with 
          | [] -> [] 
          | h :: t -> h :: take (n-1) t in
        let truncated_args = take param_count arg_vals in
        log_recovery (Printf.sprintf "函数期望%d个参数，提供了%d个，忽略多余的%d个参数" 
                      param_count arg_count extra_count);
        let new_env = List.fold_left2 (fun acc_env param_name arg_val ->
          bind_var acc_env param_name arg_val
        ) closure_env param_list truncated_args in
        eval_expr new_env body
    else
      raise (RuntimeError "函数参数数量不匹配")
  | _ -> raise (RuntimeError "尝试调用非函数值")

(** 执行模式匹配 *)
and execute_match env value branch_list =
  match branch_list with
  | [] -> raise (RuntimeError "模式匹配失败：没有匹配的分支")
  | (pattern, expr) :: rest_branches ->
    (match match_pattern pattern value env with
     | Some new_env -> eval_expr new_env expr
     | None -> execute_match env value rest_branches)

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
  | SemanticLetStmt (var_name, _semantic_label, expr) ->
    (* For now, semantic labels are just metadata - evaluate normally *)
    let value = eval_expr env expr in
    let new_env = bind_var env var_name value in
    (new_env, value)

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
    | [ListValue lst] -> IntValue (List.length lst)
    | _ -> raise (RuntimeError "长度函数期望一个字符串或列表参数")));
    
  ("连接", BuiltinFunctionValue (function
    | [ListValue lst1] ->
      (* Return a function that takes the second list *)
      BuiltinFunctionValue (function
        | [ListValue lst2] -> ListValue (lst1 @ lst2)
        | _ -> raise (RuntimeError "连接函数期望第二个列表参数"))
    | _ -> raise (RuntimeError "连接函数期望第一个列表参数")));
    
  ("过滤", BuiltinFunctionValue (function
    | [pred_func] ->
      (* Return a function that takes a list *)
      BuiltinFunctionValue (function
        | [ListValue lst] ->
          let filtered = List.filter (fun elem ->
            match call_function pred_func [elem] with
            | BoolValue b -> b
            | _ -> raise (RuntimeError "过滤谓词必须返回布尔值")
          ) lst in
          ListValue filtered
        | _ -> raise (RuntimeError "过滤函数期望一个列表参数"))
    | _ -> raise (RuntimeError "过滤函数期望一个谓词函数")));
]

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
    Printf.printf "程序执行完成，结果: %s\n" (value_to_string result); flush_all ();
    true
  | Error error_msg ->
    Printf.printf "执行错误: %s\n" error_msg; flush_all ();
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
    Printf.printf "=> %s\n" (value_to_string result); flush_all ();
    env
  with
  | RuntimeError msg ->
    Printf.printf "错误: %s\n" msg; flush_all ();
    env
  | e ->
    Printf.printf "未知错误: %s\n" (Printexc.to_string e); flush_all ();
    env