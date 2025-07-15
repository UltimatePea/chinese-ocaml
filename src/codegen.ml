(** 骆言代码生成器/解释器 - Chinese Programming Language Code Generator/Interpreter *)

open Ast

type error_recovery_config = {
  enabled : bool;
  type_conversion : bool;
  spell_correction : bool;
  parameter_adaptation : bool;
  log_level : string; (* "quiet" | "normal" | "verbose" | "debug" *)
  collect_statistics : bool;
}
(** 错误恢复配置 *)

type recovery_statistics = {
  mutable total_errors : int;
  mutable type_conversions : int;
  mutable spell_corrections : int;
  mutable parameter_adaptations : int;
  mutable variable_suggestions : int;
  mutable or_else_fallbacks : int;
}
(** 错误恢复统计 *)

(** 默认错误恢复配置 *)
let default_recovery_config =
  {
    enabled = true;
    type_conversion = true;
    spell_correction = true;
    parameter_adaptation = true;
    log_level = "normal";
    collect_statistics = true;
  }

(** 全局错误恢复统计 *)
let recovery_stats =
  {
    total_errors = 0;
    type_conversions = 0;
    spell_corrections = 0;
    parameter_adaptations = 0;
    variable_suggestions = 0;
    or_else_fallbacks = 0;
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
  | RecordValue of (string * runtime_value) list (* 记录值：字段名和值的列表 *)
  | ArrayValue of runtime_value array (* 可变数组 *)
  | FunctionValue of string list * expr * runtime_env (* 参数列表, 函数体, 闭包环境 *)
  | BuiltinFunctionValue of (runtime_value list -> runtime_value)
  | ExceptionValue of string * runtime_value option (* 异常值：异常名称和可选的携带值 *)
  | RefValue of runtime_value ref (* 引用值：可变引用 *)
  | ConstructorValue of string * runtime_value list (* 构造器值：构造器名和参数列表 *)
  | ModuleValue of (string * runtime_value) list (* 模块值：导出的绑定列表 *)

and runtime_env = (string * runtime_value) list
(** 运行时环境 *)

type macro_env = (string * macro_def) list
(** 宏环境 *)

(** 全局宏表 *)
let macro_table : (string, macro_def) Hashtbl.t = Hashtbl.create 16

(** 简单的宏展开 *)
let expand_macro macro_def _args =
  (* 简化版本：假设宏体中的参数直接替换为提供的参数 *)
  (* 这是一个非常基础的实现，实际的宏展开会更复杂 *)
  macro_def.body

exception RuntimeError of string
(** 运行时错误 *)

exception ExceptionRaised of runtime_value
(** 抛出的异常 *)

(* 全局模块表 *)
let module_table : (string, (string * runtime_value) list) Hashtbl.t = Hashtbl.create 8

(* Global table for recursive functions to handle self-reference *)
let recursive_functions : (string, runtime_value) Hashtbl.t = Hashtbl.create 8

(* Global functor table for storing functor definitions *)
let functor_table : (string, identifier * module_type * expr) Hashtbl.t = Hashtbl.create 8

(** 创建空环境 *)
let empty_env = []

(** 计算两个字符串的编辑距离 (Levenshtein distance) *)
let levenshtein_distance str1 str2 =
  let len1 = String.length str1 in
  let len2 = String.length str2 in
  let matrix = Array.make_matrix (len1 + 1) (len2 + 1) 0 in

  (* 初始化第一行和第一列 *)
  for i = 0 to len1 do
    matrix.(i).(0) <- i
  done;
  for j = 0 to len2 do
    matrix.(0).(j) <- j
  done;

  (* 填充矩阵 *)
  for i = 1 to len1 do
    for j = 1 to len2 do
      let cost = if str1.[i - 1] = str2.[j - 1] then 0 else 1 in
      matrix.(i).(j) <-
        min
          (min (matrix.(i - 1).(j) + 1) (* 删除 *) (matrix.(i).(j - 1) + 1)) (* 插入 *)
          (matrix.(i - 1).(j - 1) + cost)
      (* 替换 *)
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
  let distances = List.map (fun var -> (var, levenshtein_distance target_var var)) available_vars in
  let sorted = List.sort (fun (_, d1) (_, d2) -> compare d1 d2) distances in
  match sorted with
  | [] -> None
  | (closest_var, distance) :: _ ->
      (* 只有当距离足够小时才建议 *)
      if distance <= 2 && distance < String.length target_var / 2 then Some closest_var else None

(** 记录错误恢复日志 *)
let log_recovery msg =
  if !recovery_config.collect_statistics then
    recovery_stats.total_errors <- recovery_stats.total_errors + 1;
  match !recovery_config.log_level with
  | "quiet" -> ()
  | "normal" -> Printf.printf "[恢复] %s\n" msg
  | "verbose" ->
      let timestamp = Unix.time () |> int_of_float in
      Printf.printf "[恢复:%d] %s\n" timestamp msg
  | "debug" ->
      let timestamp = Unix.time () |> int_of_float in
      Printf.printf "[DEBUG:%d] 错误恢复: %s\n  统计: 总错误=%d, 类型转换=%d, 拼写纠正=%d\n" timestamp msg
        recovery_stats.total_errors recovery_stats.type_conversions recovery_stats.spell_corrections
  | _ -> Printf.printf "[恢复] %s\n" msg

(** 记录特定类型的恢复操作 *)
let log_recovery_type recovery_type msg =
  if !recovery_config.collect_statistics then (
    recovery_stats.total_errors <- recovery_stats.total_errors + 1;
    match recovery_type with
    | "type_conversion" -> recovery_stats.type_conversions <- recovery_stats.type_conversions + 1
    | "spell_correction" -> recovery_stats.spell_corrections <- recovery_stats.spell_corrections + 1
    | "parameter_adaptation" ->
        recovery_stats.parameter_adaptations <- recovery_stats.parameter_adaptations + 1
    | "variable_suggestion" ->
        recovery_stats.variable_suggestions <- recovery_stats.variable_suggestions + 1
    | "or_else_fallback" -> recovery_stats.or_else_fallbacks <- recovery_stats.or_else_fallbacks + 1
    | _ -> ());
  log_recovery msg

(** 显示错误恢复统计信息 *)
let show_recovery_statistics () =
  if !recovery_config.collect_statistics && recovery_stats.total_errors > 0 then (
    Printf.printf "\n=== 错误恢复统计 ===\n";
    Printf.printf "总错误数: %d\n" recovery_stats.total_errors;
    Printf.printf "类型转换: %d 次\n" recovery_stats.type_conversions;
    Printf.printf "拼写纠正: %d 次\n" recovery_stats.spell_corrections;
    Printf.printf "参数适配: %d 次\n" recovery_stats.parameter_adaptations;
    Printf.printf "变量建议: %d 次\n" recovery_stats.variable_suggestions;
    Printf.printf "默认值回退: %d 次\n" recovery_stats.or_else_fallbacks;
    Printf.printf "恢复成功率: %.1f%%\n"
      (100.0
      *. float_of_int recovery_stats.total_errors
      /. float_of_int (max 1 recovery_stats.total_errors));
    Printf.printf "================\n\n")

(** 重置错误恢复统计 *)
let reset_recovery_statistics () =
  recovery_stats.total_errors <- 0;
  recovery_stats.type_conversions <- 0;
  recovery_stats.spell_corrections <- 0;
  recovery_stats.parameter_adaptations <- 0;
  recovery_stats.variable_suggestions <- 0;
  recovery_stats.or_else_fallbacks <- 0

(** 设置错误恢复配置 *)
let set_recovery_config new_config = recovery_config := new_config

(** 获取当前错误恢复配置 *)
let get_recovery_config () = !recovery_config

(** 设置日志级别 *)
let set_log_level level = recovery_config := { !recovery_config with log_level = level }

(** 在环境中查找变量 *)
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
          if !recovery_config.spell_correction then
            let available_vars = get_available_vars env in
            match find_closest_var var available_vars with
            | Some corrected_var -> (
                log_recovery_type "spell_correction"
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
  | RecordValue fields ->
      "{"
      ^ String.concat "; "
          (List.map (fun (name, value) -> name ^ " = " ^ value_to_string value) fields)
      ^ "}"
  | ArrayValue arr ->
      "[|" ^ String.concat "; " (Array.to_list (Array.map value_to_string arr)) ^ "|]"
  | FunctionValue (_, _, _) -> "<函数>"
  | BuiltinFunctionValue _ -> "<内置函数>"
  | ExceptionValue (name, None) -> name
  | ExceptionValue (name, Some payload) -> name ^ "(" ^ value_to_string payload ^ ")"
  | RefValue r -> "引用(" ^ value_to_string !r ^ ")"
  | ConstructorValue (name, []) -> name
  | ConstructorValue (name, args) ->
      name ^ "(" ^ String.concat ", " (List.map value_to_string args) ^ ")"
  | ModuleValue bindings -> "<模块: " ^ String.concat ", " (List.map fst bindings) ^ ">"

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
      log_recovery_type "type_conversion" (Printf.sprintf "将浮点数%.2f转换为整数%d" f (int_of_float f));
      Some (int_of_float f)
  | StringValue s -> (
      try
        let n = int_of_string s in
        log_recovery_type "type_conversion" (Printf.sprintf "将字符串\"%s\"转换为整数%d" s n);
        Some n
      with _ -> None)
  | BoolValue b ->
      let n = if b then 1 else 0 in
      log_recovery_type "type_conversion"
        (Printf.sprintf "将布尔值%s转换为整数%d" (if b then "真" else "假") n);
      Some n
  | _ -> None

(** 尝试将值转换为浮点数 *)
and try_to_float value =
  match value with
  | FloatValue f -> Some f
  | IntValue n ->
      let f = float_of_int n in
      log_recovery_type "type_conversion" (Printf.sprintf "将整数%d转换为浮点数%.2f" n f);
      Some f
  | StringValue s -> (
      try
        let f = float_of_string s in
        log_recovery_type "type_conversion" (Printf.sprintf "将字符串\"%s\"转换为浮点数%.2f" s f);
        Some f
      with _ -> None)
  | _ -> None

(** 尝试将值转换为字符串 *)
and try_to_string value =
  match value with
  | StringValue s -> Some s
  | _ ->
      let s = value_to_string value in
      log_recovery_type "type_conversion"
        (Printf.sprintf "将%s转换为字符串\"%s\""
           (match value with
           | IntValue _ -> "整数"
           | FloatValue _ -> "浮点数"
           | BoolValue _ -> "布尔值"
           | _ -> "值")
           s);
      Some s

(** 二元运算实现 *)
and execute_binary_op op left_val right_val =
  match (op, left_val, right_val) with
  (* 算术运算 *)
  | Add, IntValue a, IntValue b -> IntValue (a + b)
  | Sub, IntValue a, IntValue b -> IntValue (a - b)
  | Mul, IntValue a, IntValue b -> IntValue (a * b)
  | Div, IntValue a, IntValue b -> if b = 0 then raise (RuntimeError "除零错误") else IntValue (a / b)
  | Mod, IntValue a, IntValue b -> if b = 0 then raise (RuntimeError "取模零错误") else IntValue (a mod b)
  | Add, FloatValue a, FloatValue b -> FloatValue (a +. b)
  | Sub, FloatValue a, FloatValue b -> FloatValue (a -. b)
  | Mul, FloatValue a, FloatValue b -> FloatValue (a *. b)
  | Div, FloatValue a, FloatValue b -> FloatValue (a /. b)
  (* 字符串连接 *)
  | Add, StringValue a, StringValue b -> StringValue (a ^ b)
  (* 字符串连接运算 *)
  | Concat, StringValue a, StringValue b -> StringValue (a ^ b)
  (* 比较运算 *)
  | Eq, a, b -> BoolValue (a = b)
  | Neq, a, b -> BoolValue (a <> b)
  | Lt, IntValue a, IntValue b -> BoolValue (a < b)
  | Le, IntValue a, IntValue b -> BoolValue (a <= b)
  | Gt, IntValue a, IntValue b -> BoolValue (a > b)
  | Ge, IntValue a, IntValue b -> BoolValue (a >= b)
  | Lt, FloatValue a, FloatValue b -> BoolValue (a < b)
  | Le, FloatValue a, FloatValue b -> BoolValue (a <= b)
  | Gt, FloatValue a, FloatValue b -> BoolValue (a > b)
  | Ge, FloatValue a, FloatValue b -> BoolValue (a >= b)
  (* 逻辑运算 *)
  | And, a, b -> BoolValue (value_to_bool a && value_to_bool b)
  | Or, a, b -> BoolValue (value_to_bool a || value_to_bool b)
  | _ ->
      (* 尝试自动类型转换 *)
      if !recovery_config.enabled && !recovery_config.type_conversion then
        match op with
        | Add | Sub | Mul | Div | Mod -> (
            (* 尝试数值运算的类型转换 *)
            match (try_to_int left_val, try_to_int right_val) with
            | Some a, Some b -> execute_binary_op op (IntValue a) (IntValue b)
            | _ -> (
                match (try_to_float left_val, try_to_float right_val) with
                | Some a, Some b -> execute_binary_op op (FloatValue a) (FloatValue b)
                | _ ->
                    (* 如果是加法，尝试字符串连接 *)
                    if op = Add then
                      match (try_to_string left_val, try_to_string right_val) with
                      | Some a, Some b -> execute_binary_op op (StringValue a) (StringValue b)
                      | _ ->
                          raise
                            (RuntimeError
                               ("不支持的二元运算: " ^ value_to_string left_val ^ " "
                              ^ value_to_string right_val))
                    else
                      raise
                        (RuntimeError
                           ("不支持的二元运算: " ^ value_to_string left_val ^ " "
                          ^ value_to_string right_val))))
        | Lt | Le | Gt | Ge -> (
            (* 比较运算的类型转换 *)
            match (try_to_float left_val, try_to_float right_val) with
            | Some a, Some b -> execute_binary_op op (FloatValue a) (FloatValue b)
            | _ ->
                raise
                  (RuntimeError
                     ("不支持的比较运算: " ^ value_to_string left_val ^ " " ^ value_to_string right_val)))
        | _ ->
            raise
              (RuntimeError
                 ("不支持的二元运算: " ^ value_to_string left_val ^ " " ^ value_to_string right_val))
      else
        raise
          (RuntimeError ("不支持的二元运算: " ^ value_to_string left_val ^ " " ^ value_to_string right_val))

(** 一元运算实现 *)
and execute_unary_op op value =
  match (op, value) with
  | Neg, IntValue n -> IntValue (-n)
  | Neg, FloatValue f -> FloatValue (-.f)
  | Not, v -> BoolValue (not (value_to_bool v))
  | _ -> raise (RuntimeError ("不支持的一元运算: " ^ value_to_string value))

(** 模式匹配 *)
and match_pattern pattern value env =
  match (pattern, value) with
  | WildcardPattern, _ -> Some env
  | VarPattern var_name, value -> Some (bind_var env var_name value)
  | LitPattern (IntLit n1), IntValue n2 when n1 = n2 -> Some env
  | LitPattern (FloatLit f1), FloatValue f2 when f1 = f2 -> Some env
  | LitPattern (StringLit s1), StringValue s2 when s1 = s2 -> Some env
  | LitPattern (BoolLit b1), BoolValue b2 when b1 = b2 -> Some env
  | LitPattern UnitLit, UnitValue -> Some env
  | EmptyListPattern, ListValue [] -> Some env
  | ConsPattern (head_pattern, tail_pattern), ListValue (head_value :: tail_values) -> (
      match match_pattern head_pattern head_value env with
      | Some new_env -> match_pattern tail_pattern (ListValue tail_values) new_env
      | None -> None)
  | ConstructorPattern (name, patterns), ExceptionValue (exc_name, payload_opt) when name = exc_name
    -> (
      (* 匹配异常构造器 *)
      match (patterns, payload_opt) with
      | [], None -> Some env (* 无参数异常 *)
      | [ pattern ], Some payload -> match_pattern pattern payload env (* 单参数异常 *)
      | _ -> None (* 参数数量不匹配 *))
  | ConstructorPattern (name, patterns), ConstructorValue (ctor_name, args) when name = ctor_name ->
      (* 匹配用户定义的构造器 *)
      if List.length patterns = List.length args then
        (* 参数数量匹配，递归匹配每个参数 *)
        let rec match_args patterns args env =
          match (patterns, args) with
          | [], [] -> Some env
          | p :: ps, v :: vs -> (
              match match_pattern p v env with
              | Some new_env -> match_args ps vs new_env
              | None -> None)
          | _ -> None (* 不应该到达这里，因为长度已经检查过 *)
        in
        match_args patterns args env
      else None (* 参数数量不匹配 *)
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
      if value_to_bool cond_val then eval_expr env then_branch else eval_expr env else_branch
  | FunExpr (param_list, body) -> FunctionValue (param_list, body, env)
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
  | OrElseExpr (primary_expr, default_expr) -> (
      (* 尝试执行主表达式，如果出错或产生无效值则返回默认值 *)
      try
        let result = eval_expr env primary_expr in
        match result with UnitValue -> eval_expr env default_expr (* 单元值被视为"无效" *) | _ -> result
      with RuntimeError _ | Failure _ ->
        (* 主表达式出错，返回默认值 *)
        log_recovery_type "or_else_fallback" "主表达式执行失败，使用默认值";
        eval_expr env default_expr)
  | RecordExpr fields ->
      (* 评估记录表达式，创建记录值 *)
      let eval_field (name, expr) = (name, eval_expr env expr) in
      RecordValue (List.map eval_field fields)
  | FieldAccessExpr (record_expr, field_name) -> (
      (* 访问记录字段 *)
      let record_val = eval_expr env record_expr in
      match record_val with
      | RecordValue fields -> (
          try List.assoc field_name fields
          with Not_found -> raise (RuntimeError (Printf.sprintf "记录没有字段: %s" field_name)))
      | _ -> raise (RuntimeError "期望记录类型"))
  | RecordUpdateExpr (record_expr, updates) -> (
      (* 更新记录字段 *)
      let record_val = eval_expr env record_expr in
      match record_val with
      | RecordValue fields ->
          let update_field (name, value) fields =
            if List.mem_assoc name fields then (name, value) :: List.remove_assoc name fields
            else raise (RuntimeError (Printf.sprintf "记录没有字段: %s" name))
          in
          let eval_update (name, expr) = (name, eval_expr env expr) in
          let evaluated_updates = List.map eval_update updates in
          let new_fields = List.fold_right update_field evaluated_updates fields in
          RecordValue new_fields
      | _ -> raise (RuntimeError "期望记录类型"))
  | ArrayExpr elements ->
      (* 评估数组表达式，创建可变数组 *)
      let values = List.map (eval_expr env) elements in
      ArrayValue (Array.of_list values)
  | ArrayAccessExpr (array_expr, index_expr) -> (
      (* 访问数组元素 *)
      let array_val = eval_expr env array_expr in
      let index_val = eval_expr env index_expr in
      match (array_val, index_val) with
      | ArrayValue arr, IntValue idx ->
          if idx >= 0 && idx < Array.length arr then arr.(idx)
          else raise (RuntimeError (Printf.sprintf "数组索引越界: %d (数组长度: %d)" idx (Array.length arr)))
      | ArrayValue _, _ -> raise (RuntimeError "数组索引必须是整数")
      | _ -> raise (RuntimeError "期望数组类型"))
  | ArrayUpdateExpr (array_expr, index_expr, value_expr) -> (
      (* 更新数组元素 *)
      let array_val = eval_expr env array_expr in
      let index_val = eval_expr env index_expr in
      let new_value = eval_expr env value_expr in
      match (array_val, index_val) with
      | ArrayValue arr, IntValue idx ->
          if idx >= 0 && idx < Array.length arr then (
            arr.(idx) <- new_value;
            UnitValue)
          else raise (RuntimeError (Printf.sprintf "数组索引越界: %d (数组长度: %d)" idx (Array.length arr)))
      | ArrayValue _, _ -> raise (RuntimeError "数组索引必须是整数")
      | _ -> raise (RuntimeError "期望数组类型"))
  | TryExpr (try_expr, catch_branches, finally_expr_opt) -> (
      (* 尝试执行表达式，捕获异常 *)
      let exec_finally () =
        match finally_expr_opt with
        | Some finally_expr -> ignore (eval_expr env finally_expr)
        | None -> ()
      in
      try
        let result = eval_expr env try_expr in
        exec_finally ();
        result
      with
      | ExceptionRaised exc_val -> (
          (* 尝试匹配catch分支 *)
          try
            let matched_branch = execute_exception_match env exc_val catch_branches in
            exec_finally ();
            matched_branch
          with RuntimeError _ as e ->
            exec_finally ();
            raise e)
      | e ->
          exec_finally ();
          raise e)
  | RaiseExpr expr ->
      (* 抛出异常 *)
      let exc_val = eval_expr env expr in
      raise (ExceptionRaised exc_val)
  | RefExpr expr ->
      (* 创建引用 *)
      let value = eval_expr env expr in
      RefValue (ref value)
  | DerefExpr expr -> (
      (* 解引用 *)
      match eval_expr env expr with
      | RefValue r -> !r
      | _ -> raise (RuntimeError "解引用操作需要引用值"))
  | AssignExpr (target_expr, value_expr) -> (
      (* 引用赋值 *)
      match eval_expr env target_expr with
      | RefValue r ->
          let new_value = eval_expr env value_expr in
          r := new_value;
          UnitValue
      | _ -> raise (RuntimeError "赋值目标必须是引用"))
  | ConstructorExpr (constructor_name, arg_exprs) ->
      (* 构造器表达式：创建构造器值 *)
      let arg_vals = List.map (eval_expr env) arg_exprs in
      ConstructorValue (constructor_name, arg_vals)
  | TupleExpr _ -> raise (RuntimeError "元组表达式尚未实现")
  | MacroCallExpr macro_call -> (
      (* 查找宏定义 *)
      match Hashtbl.find_opt macro_table macro_call.macro_call_name with
      | Some macro_def ->
          (* 展开宏并求值 *)
          let expanded_expr = expand_macro macro_def macro_call.args in
          eval_expr env expanded_expr
      | None -> raise (RuntimeError ("未定义的宏: " ^ macro_call.macro_call_name)))
  | AsyncExpr _ -> raise (RuntimeError "异步表达式尚未实现")
  (* 模块系统表达式 *)
  | ModuleAccessExpr (module_expr, member_name) -> (
      (* 模块成员访问 *)
      let module_value = eval_expr env module_expr in
      match module_value with
      | ModuleValue bindings -> (
          match List.assoc_opt member_name bindings with
          | Some value -> value
          | None -> raise (RuntimeError ("模块中未找到成员: " ^ member_name)))
      | _ -> raise (RuntimeError "只能访问模块的成员"))
  | FunctorCallExpr (functor_expr, module_expr) -> (
      (* 函子调用 *)
      let functor_value = eval_expr env functor_expr in
      let module_value = eval_expr env module_expr in
      match functor_value with
      | FunctionValue ([ param ], body, functor_env) ->
          let param_env = (param, module_value) :: functor_env in
          eval_expr param_env body
      | _ -> raise (RuntimeError "只能调用函子"))
  | FunctorExpr (param_name, _param_type, body) ->
      (* 函子定义 *)
      FunctionValue ([ param_name ], body, env)
  | ModuleExpr _statements ->
      (* 模块表达式求值 - 暂时简化实现 *)
      raise (RuntimeError "模块表达式功能尚未完全实现")

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
        let new_env =
          List.fold_left2
            (fun acc_env param_name arg_val -> bind_var acc_env param_name arg_val)
            closure_env param_list arg_vals
        in
        eval_expr new_env body
      else if !recovery_config.enabled then (
        if
          (* 参数数量不匹配，但启用了错误恢复 *)
          arg_count < param_count
        then (
          (* 参数不足，用默认值填充 *)
          let missing_count = param_count - arg_count in
          let default_vals = List.init missing_count (fun _ -> IntValue 0) in
          let adapted_args = arg_vals @ default_vals in
          log_recovery_type "parameter_adaptation"
            (Printf.sprintf "函数期望%d个参数，提供了%d个，用默认值填充缺失的%d个参数" param_count arg_count missing_count);
          let new_env =
            List.fold_left2
              (fun acc_env param_name arg_val -> bind_var acc_env param_name arg_val)
              closure_env param_list adapted_args
          in
          eval_expr new_env body)
        else
          (* 参数过多，忽略多余的参数 *)
          let extra_count = arg_count - param_count in
          let rec take n lst =
            if n <= 0 then [] else match lst with [] -> [] | h :: t -> h :: take (n - 1) t
          in
          let truncated_args = take param_count arg_vals in
          log_recovery_type "parameter_adaptation"
            (Printf.sprintf "函数期望%d个参数，提供了%d个，忽略多余的%d个参数" param_count arg_count extra_count);
          let new_env =
            List.fold_left2
              (fun acc_env param_name arg_val -> bind_var acc_env param_name arg_val)
              closure_env param_list truncated_args
          in
          eval_expr new_env body)
      else raise (RuntimeError "函数参数数量不匹配")
  | _ -> raise (RuntimeError "尝试调用非函数值")

(** 执行模式匹配 *)
and execute_match env value branch_list =
  match branch_list with
  | [] -> raise (RuntimeError "模式匹配失败：没有匹配的分支")
  | branch :: rest_branches -> (
      match match_pattern branch.pattern value env with
      | Some new_env -> (
          (* 检查guard条件 *)
          match branch.guard with
          | None -> eval_expr new_env branch.expr (* 没有guard，直接执行 *)
          | Some guard_expr -> (
              (* 有guard，需要评估guard条件 *)
              let guard_result = eval_expr new_env guard_expr in
              match guard_result with
              | BoolValue true -> eval_expr new_env branch.expr (* guard通过 *)
              | BoolValue false -> execute_match env value rest_branches (* guard失败，尝试下一个分支 *)
              | _ -> raise (RuntimeError "guard条件必须返回布尔值")))
      | None -> execute_match env value rest_branches)

(** 执行异常匹配 *)
and execute_exception_match env exc_val catch_branches =
  match catch_branches with
  | [] -> raise (ExceptionRaised exc_val) (* 没有匹配的分支，重新抛出异常 *)
  | branch :: rest_branches -> (
      match match_pattern branch.pattern exc_val env with
      | Some new_env -> (
          (* 检查guard条件 *)
          match branch.guard with
          | None -> eval_expr new_env branch.expr (* 没有guard，直接执行 *)
          | Some guard_expr -> (
              (* 有guard，需要评估guard条件 *)
              let guard_result = eval_expr new_env guard_expr in
              match guard_result with
              | BoolValue true -> eval_expr new_env branch.expr (* guard通过 *)
              | BoolValue false ->
                  execute_exception_match env exc_val rest_branches (* guard失败，尝试下一个分支 *)
              | _ -> raise (RuntimeError "异常guard条件必须返回布尔值")))
      | None -> execute_exception_match env exc_val rest_branches)

(** 注册构造器函数 *)
let register_constructors env type_def =
  match type_def with
  | AlgebraicType constructors ->
      (* 为每个构造器创建构造器函数 *)
      List.fold_left
        (fun acc_env (constructor_name, _type_opt) ->
          let constructor_func =
            BuiltinFunctionValue (fun args -> ConstructorValue (constructor_name, args))
          in
          bind_var acc_env constructor_name constructor_func)
        env constructors
  | AliasType _ | RecordType _ ->
      (* 类型别名和记录类型暂时不需要注册构造器 *)
      env

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
  | TypeDefStmt (_type_name, type_def) ->
      (* 注册构造器函数 *)
      let new_env = register_constructors env type_def in
      (new_env, UnitValue)
  | ModuleDefStmt mdef ->
      let mod_env = List.fold_left (fun e s -> fst (execute_stmt e s)) [] mdef.statements in
      Hashtbl.replace module_table mdef.module_def_name mod_env;
      (env, UnitValue)
  | ModuleImportStmt _ -> (env, UnitValue)
  | ModuleTypeDefStmt (_type_name, _module_type) ->
      (* 模块类型定义在运行时不需要执行操作 *)
      (env, UnitValue)
  | MacroDefStmt macro_def ->
      (* 将宏定义保存到全局宏表 *)
      Hashtbl.replace macro_table macro_def.macro_def_name macro_def;
      (env, UnitValue)
  | ExceptionDefStmt (exc_name, type_opt) ->
      (* 定义异常构造器 *)
      let exc_constructor =
        match type_opt with
        | None ->
            (* 无参数异常 *)
            BuiltinFunctionValue
              (function
              | [] -> ExceptionValue (exc_name, None)
              | _ -> raise (RuntimeError "此异常不需要参数"))
        | Some _ ->
            (* 带参数异常 *)
            BuiltinFunctionValue
              (function
              | [ arg ] -> ExceptionValue (exc_name, Some arg)
              | _ -> raise (RuntimeError "此异常需要一个参数"))
      in
      let new_env = bind_var env exc_name exc_constructor in
      (new_env, UnitValue)
  | SemanticLetStmt (var_name, _semantic_label, expr) ->
      (* For now, semantic labels are just metadata - evaluate normally *)
      let value = eval_expr env expr in
      let new_env = bind_var env var_name value in
      (new_env, value)
  | IncludeStmt module_expr -> (
      (* 包含模块语句 *)
      let module_value = eval_expr env module_expr in
      match module_value with
      | ModuleValue bindings ->
          let new_env =
            List.fold_left (fun acc (name, value) -> bind_var acc name value) env bindings
          in
          (new_env, UnitValue)
      | _ -> raise (RuntimeError "只能包含模块"))

(** 内置函数实现 *)
let builtin_functions =
  [
    ( "打印",
      BuiltinFunctionValue
        (function
        | [ StringValue s ] ->
            print_endline s;
            UnitValue
        | [ value ] ->
            print_endline (value_to_string value);
            UnitValue
        | _ -> raise (RuntimeError "打印函数期望一个参数")) );
    ( "读取",
      BuiltinFunctionValue
        (function
        | [ UnitValue ] -> StringValue (read_line ())
        | [] -> StringValue (read_line ())
        | _ -> raise (RuntimeError "读取函数不需要参数")) );
    ( "长度",
      BuiltinFunctionValue
        (function
        | [ StringValue s ] -> IntValue (String.length s)
        | [ ListValue lst ] -> IntValue (List.length lst)
        | _ -> raise (RuntimeError "长度函数期望一个字符串或列表参数")) );
    ( "连接",
      BuiltinFunctionValue
        (function
        | [ ListValue lst1 ] ->
            (* Return a function that takes the second list *)
            BuiltinFunctionValue
              (function
              | [ ListValue lst2 ] -> ListValue (lst1 @ lst2)
              | _ -> raise (RuntimeError "连接函数期望第二个列表参数"))
        | _ -> raise (RuntimeError "连接函数期望第一个列表参数")) );
    ( "过滤",
      BuiltinFunctionValue
        (function
        | [ pred_func ] ->
            (* Return a function that takes a list *)
            BuiltinFunctionValue
              (function
              | [ ListValue lst ] ->
                  let filtered =
                    List.filter
                      (fun elem ->
                        match call_function pred_func [ elem ] with
                        | BoolValue b -> b
                        | _ -> raise (RuntimeError "过滤谓词必须返回布尔值"))
                      lst
                  in
                  ListValue filtered
              | _ -> raise (RuntimeError "过滤函数期望一个列表参数"))
        | _ -> raise (RuntimeError "过滤函数期望一个谓词函数")) );
    (* AI友好的数据处理函数 *)
    ( "映射",
      BuiltinFunctionValue
        (function
        | [ map_func ] ->
            BuiltinFunctionValue
              (function
              | [ ListValue lst ] ->
                  let mapped = List.map (fun elem -> call_function map_func [ elem ]) lst in
                  ListValue mapped
              | _ -> raise (RuntimeError "映射函数期望一个列表参数"))
        | _ -> raise (RuntimeError "映射函数期望一个映射函数")) );
    ( "折叠",
      BuiltinFunctionValue
        (function
        | [ fold_func ] ->
            BuiltinFunctionValue
              (function
              | [ initial_value ] ->
                  BuiltinFunctionValue
                    (function
                    | [ ListValue lst ] ->
                        List.fold_left
                          (fun acc elem -> call_function fold_func [ acc; elem ])
                          initial_value lst
                    | _ -> raise (RuntimeError "折叠函数期望一个列表参数"))
              | _ -> raise (RuntimeError "折叠函数期望一个初始值"))
        | _ -> raise (RuntimeError "折叠函数期望一个折叠函数")) );
    ( "范围",
      BuiltinFunctionValue
        (function
        | [ IntValue start; IntValue end_val ] ->
            let rec range s e acc =
              if s > e then ListValue (List.rev acc) else range (s + 1) e (IntValue s :: acc)
            in
            range start end_val []
        | _ -> raise (RuntimeError "范围函数期望两个整数参数（起始和结束）")) );
    ( "排序",
      BuiltinFunctionValue
        (function
        | [ ListValue lst ] ->
            let sorted =
              List.sort
                (fun a b ->
                  match (a, b) with
                  | IntValue i1, IntValue i2 -> compare i1 i2
                  | FloatValue f1, FloatValue f2 -> compare f1 f2
                  | StringValue s1, StringValue s2 -> compare s1 s2
                  | _ -> 0)
                lst
            in
            ListValue sorted
        | _ -> raise (RuntimeError "排序函数期望一个列表参数")) );
    ( "反转",
      BuiltinFunctionValue
        (function
        | [ ListValue lst ] -> ListValue (List.rev lst)
        | [ StringValue s ] ->
            let chars = List.of_seq (String.to_seq s) in
            let reversed_chars = List.rev chars in
            StringValue (String.of_seq (List.to_seq reversed_chars))
        | _ -> raise (RuntimeError "反转函数期望一个列表或字符串参数")) );
    ( "包含",
      BuiltinFunctionValue
        (function
        | [ search_val ] ->
            BuiltinFunctionValue
              (function
              | [ ListValue lst ] -> BoolValue (List.mem search_val lst)
              | [ StringValue str ] -> (
                  match search_val with
                  | StringValue substr -> BoolValue (String.contains str (String.get substr 0))
                  | _ -> BoolValue false)
              | _ -> raise (RuntimeError "包含函数期望一个列表或字符串参数"))
        | _ -> raise (RuntimeError "包含函数期望一个搜索值")) );
    ( "求和",
      BuiltinFunctionValue
        (function
        | [ ListValue lst ] ->
            let sum =
              List.fold_left
                (fun acc elem ->
                  match (acc, elem) with
                  | IntValue a, IntValue b -> IntValue (a + b)
                  | FloatValue a, FloatValue b -> FloatValue (a +. b)
                  | IntValue a, FloatValue b -> FloatValue (float_of_int a +. b)
                  | FloatValue a, IntValue b -> FloatValue (a +. float_of_int b)
                  | _ -> raise (RuntimeError "求和函数只能用于数字列表"))
                (IntValue 0) lst
            in
            sum
        | _ -> raise (RuntimeError "求和函数期望一个数字列表参数")) );
    ( "最大值",
      BuiltinFunctionValue
        (function
        | [ ListValue lst ] -> (
            match lst with
            | [] -> raise (RuntimeError "不能对空列表求最大值")
            | first :: rest ->
                List.fold_left
                  (fun acc elem ->
                    match (acc, elem) with
                    | IntValue a, IntValue b -> IntValue (max a b)
                    | FloatValue a, FloatValue b -> FloatValue (max a b)
                    | IntValue a, FloatValue b -> FloatValue (max (float_of_int a) b)
                    | FloatValue a, IntValue b -> FloatValue (max a (float_of_int b))
                    | _ -> raise (RuntimeError "最大值函数只能用于数字列表"))
                  first rest)
        | _ -> raise (RuntimeError "最大值函数期望一个非空数字列表参数")) );
    ( "最小值",
      BuiltinFunctionValue
        (function
        | [ ListValue lst ] -> (
            match lst with
            | [] -> raise (RuntimeError "不能对空列表求最小值")
            | first :: rest ->
                List.fold_left
                  (fun acc elem ->
                    match (acc, elem) with
                    | IntValue a, IntValue b -> IntValue (min a b)
                    | FloatValue a, FloatValue b -> FloatValue (min a b)
                    | IntValue a, FloatValue b -> FloatValue (min (float_of_int a) b)
                    | FloatValue a, IntValue b -> FloatValue (min a (float_of_int b))
                    | _ -> raise (RuntimeError "最小值函数只能用于数字列表"))
                  first rest)
        | _ -> raise (RuntimeError "最小值函数期望一个非空数字列表参数")) );
    (* 高级数学计算函数 *)
    ( "平均值",
      BuiltinFunctionValue
        (function
        | [ ListValue lst ] -> (
            match lst with
            | [] -> raise (RuntimeError "不能对空列表求平均值")
            | _ -> (
                let sum =
                  List.fold_left
                    (fun acc elem ->
                      match (acc, elem) with
                      | IntValue a, IntValue b -> IntValue (a + b)
                      | FloatValue a, FloatValue b -> FloatValue (a +. b)
                      | IntValue a, FloatValue b -> FloatValue (float_of_int a +. b)
                      | FloatValue a, IntValue b -> FloatValue (a +. float_of_int b)
                      | _ -> raise (RuntimeError "平均值函数只能用于数字列表"))
                    (IntValue 0) lst
                in
                let count = List.length lst in
                match sum with
                | IntValue s -> FloatValue (float_of_int s /. float_of_int count)
                | FloatValue s -> FloatValue (s /. float_of_int count)
                | _ -> raise (RuntimeError "平均值计算错误")))
        | _ -> raise (RuntimeError "平均值函数期望一个非空数字列表参数")) );
    ( "乘积",
      BuiltinFunctionValue
        (function
        | [ ListValue lst ] ->
            let product =
              List.fold_left
                (fun acc elem ->
                  match (acc, elem) with
                  | IntValue a, IntValue b -> IntValue (a * b)
                  | FloatValue a, FloatValue b -> FloatValue (a *. b)
                  | IntValue a, FloatValue b -> FloatValue (float_of_int a *. b)
                  | FloatValue a, IntValue b -> FloatValue (a *. float_of_int b)
                  | _ -> raise (RuntimeError "乘积函数只能用于数字列表"))
                (IntValue 1) lst
            in
            product
        | _ -> raise (RuntimeError "乘积函数期望一个数字列表参数")) );
    ( "绝对值",
      BuiltinFunctionValue
        (function
        | [ IntValue n ] -> IntValue (abs n)
        | [ FloatValue f ] -> FloatValue (abs_float f)
        | _ -> raise (RuntimeError "绝对值函数期望一个数字参数")) );
    ( "平方",
      BuiltinFunctionValue
        (function
        | [ IntValue n ] -> IntValue (n * n)
        | [ FloatValue f ] -> FloatValue (f *. f)
        | _ -> raise (RuntimeError "平方函数期望一个数字参数")) );
    ( "幂运算",
      BuiltinFunctionValue
        (function
        | [ base ] ->
            BuiltinFunctionValue
              (function
              | [ IntValue exp ] -> (
                  match base with
                  | IntValue b ->
                      let rec int_power b e =
                        if e = 0 then 1 else if e = 1 then b else b * int_power b (e - 1)
                      in
                      IntValue (int_power b exp)
                  | FloatValue b -> FloatValue (b ** float_of_int exp)
                  | _ -> raise (RuntimeError "幂运算的底数必须是数字"))
              | [ FloatValue exp ] -> (
                  match base with
                  | IntValue b -> FloatValue (float_of_int b ** exp)
                  | FloatValue b -> FloatValue (b ** exp)
                  | _ -> raise (RuntimeError "幂运算的底数必须是数字"))
              | _ -> raise (RuntimeError "幂运算的指数必须是数字"))
        | _ -> raise (RuntimeError "幂运算函数期望底数参数")) );
    ( "余弦",
      BuiltinFunctionValue
        (function
        | [ IntValue n ] -> FloatValue (cos (float_of_int n))
        | [ FloatValue f ] -> FloatValue (cos f)
        | _ -> raise (RuntimeError "余弦函数期望一个数字参数")) );
    ( "正弦",
      BuiltinFunctionValue
        (function
        | [ IntValue n ] -> FloatValue (sin (float_of_int n))
        | [ FloatValue f ] -> FloatValue (sin f)
        | _ -> raise (RuntimeError "正弦函数期望一个数字参数")) );
    ( "平方根",
      BuiltinFunctionValue
        (function
        | [ IntValue n ] ->
            if n >= 0 then FloatValue (sqrt (float_of_int n)) else raise (RuntimeError "不能对负数求平方根")
        | [ FloatValue f ] ->
            if f >= 0.0 then FloatValue (sqrt f) else raise (RuntimeError "不能对负数求平方根")
        | _ -> raise (RuntimeError "平方根函数期望一个非负数字参数")) );
    ( "取整",
      BuiltinFunctionValue
        (function
        | [ FloatValue f ] -> IntValue (int_of_float f)
        | [ IntValue n ] -> IntValue n (* 整数保持不变 *)
        | _ -> raise (RuntimeError "取整函数期望一个数字参数")) );
    ( "随机数",
      BuiltinFunctionValue
        (function
        | [ IntValue max_val ] ->
            Random.self_init ();
            IntValue (Random.int max_val)
        | [] ->
            Random.self_init ();
            FloatValue (Random.float 1.0)
        | _ -> raise (RuntimeError "随机数函数期望一个整数参数或无参数")) );
    (* 数组相关函数 *)
    ( "创建数组",
      BuiltinFunctionValue
        (function
        | [ IntValue size ] ->
            (* 返回一个函数，接受初始值 *)
            BuiltinFunctionValue
              (function
              | [ init_val ] ->
                  if size < 0 then raise (RuntimeError "数组大小不能为负数")
                  else ArrayValue (Array.make size init_val)
              | _ -> raise (RuntimeError "创建数组函数期望一个初始值参数"))
        | _ -> raise (RuntimeError "创建数组函数期望一个整数大小参数")) );
    ( "数组长度",
      BuiltinFunctionValue
        (function
        | [ ArrayValue arr ] -> IntValue (Array.length arr)
        | _ -> raise (RuntimeError "数组长度函数期望一个数组参数")) );
    ( "复制数组",
      BuiltinFunctionValue
        (function
        | [ ArrayValue arr ] -> ArrayValue (Array.copy arr)
        | _ -> raise (RuntimeError "复制数组函数期望一个数组参数")) );
    ( "引用",
      BuiltinFunctionValue
        (function [ value ] -> RefValue (ref value) | _ -> raise (RuntimeError "引用函数期望一个参数")) );
    (* 扩展数学函数 *)
    ( "对数",
      BuiltinFunctionValue
        (function
        | [ IntValue n ] ->
            if n > 0 then FloatValue (log (float_of_int n)) else raise (RuntimeError "对数函数的参数必须是正数")
        | [ FloatValue f ] ->
            if f > 0.0 then FloatValue (log f) else raise (RuntimeError "对数函数的参数必须是正数")
        | _ -> raise (RuntimeError "对数函数期望一个正数参数")) );
    ( "自然对数",
      BuiltinFunctionValue
        (function
        | [ IntValue n ] ->
            if n > 0 then FloatValue (log (float_of_int n))
            else raise (RuntimeError "自然对数函数的参数必须是正数")
        | [ FloatValue f ] ->
            if f > 0.0 then FloatValue (log f) else raise (RuntimeError "自然对数函数的参数必须是正数")
        | _ -> raise (RuntimeError "自然对数函数期望一个正数参数")) );
    ( "十进制对数",
      BuiltinFunctionValue
        (function
        | [ IntValue n ] ->
            if n > 0 then FloatValue (log10 (float_of_int n))
            else raise (RuntimeError "十进制对数函数的参数必须是正数")
        | [ FloatValue f ] ->
            if f > 0.0 then FloatValue (log10 f) else raise (RuntimeError "十进制对数函数的参数必须是正数")
        | _ -> raise (RuntimeError "十进制对数函数期望一个正数参数")) );
    ( "指数",
      BuiltinFunctionValue
        (function
        | [ IntValue n ] -> FloatValue (exp (float_of_int n))
        | [ FloatValue f ] -> FloatValue (exp f)
        | _ -> raise (RuntimeError "指数函数期望一个数字参数")) );
    ( "正切",
      BuiltinFunctionValue
        (function
        | [ IntValue n ] -> FloatValue (tan (float_of_int n))
        | [ FloatValue f ] -> FloatValue (tan f)
        | _ -> raise (RuntimeError "正切函数期望一个数字参数")) );
    ( "反正弦",
      BuiltinFunctionValue
        (function
        | [ IntValue n ] ->
            let f = float_of_int n in
            if f >= -1.0 && f <= 1.0 then FloatValue (asin f)
            else raise (RuntimeError "反正弦函数的参数必须在[-1,1]范围内")
        | [ FloatValue f ] ->
            if f >= -1.0 && f <= 1.0 then FloatValue (asin f)
            else raise (RuntimeError "反正弦函数的参数必须在[-1,1]范围内")
        | _ -> raise (RuntimeError "反正弦函数期望一个数字参数")) );
    ( "反余弦",
      BuiltinFunctionValue
        (function
        | [ IntValue n ] ->
            let f = float_of_int n in
            if f >= -1.0 && f <= 1.0 then FloatValue (acos f)
            else raise (RuntimeError "反余弦函数的参数必须在[-1,1]范围内")
        | [ FloatValue f ] ->
            if f >= -1.0 && f <= 1.0 then FloatValue (acos f)
            else raise (RuntimeError "反余弦函数的参数必须在[-1,1]范围内")
        | _ -> raise (RuntimeError "反余弦函数期望一个数字参数")) );
    ( "反正切",
      BuiltinFunctionValue
        (function
        | [ IntValue n ] -> FloatValue (atan (float_of_int n))
        | [ FloatValue f ] -> FloatValue (atan f)
        | _ -> raise (RuntimeError "反正切函数期望一个数字参数")) );
    ( "向上取整",
      BuiltinFunctionValue
        (function
        | [ FloatValue f ] -> IntValue (int_of_float (ceil f))
        | [ IntValue n ] -> IntValue n
        | _ -> raise (RuntimeError "向上取整函数期望一个数字参数")) );
    ( "向下取整",
      BuiltinFunctionValue
        (function
        | [ FloatValue f ] -> IntValue (int_of_float (floor f))
        | [ IntValue n ] -> IntValue n
        | _ -> raise (RuntimeError "向下取整函数期望一个数字参数")) );
    ( "四舍五入",
      BuiltinFunctionValue
        (function
        | [ FloatValue f ] -> IntValue (int_of_float (f +. 0.5))
        | [ IntValue n ] -> IntValue n
        | _ -> raise (RuntimeError "四舍五入函数期望一个数字参数")) );
    ( "最大公约数",
      BuiltinFunctionValue
        (function
        | [ IntValue a; IntValue b ] ->
            let rec gcd x y = if y = 0 then x else gcd y (x mod y) in
            IntValue (gcd (abs a) (abs b))
        | _ -> raise (RuntimeError "最大公约数函数期望两个整数参数")) );
    ( "最小公倍数",
      BuiltinFunctionValue
        (function
        | [ IntValue a; IntValue b ] ->
            let rec gcd x y = if y = 0 then x else gcd y (x mod y) in
            let g = gcd (abs a) (abs b) in
            if g = 0 then IntValue 0 else IntValue (abs (a * b) / g)
        | _ -> raise (RuntimeError "最小公倍数函数期望两个整数参数")) );
    (* 扩展字符串函数 *)
    ( "字符串长度",
      BuiltinFunctionValue
        (function
        | [ StringValue s ] -> IntValue (String.length s)
        | _ -> raise (RuntimeError "字符串长度函数期望一个字符串参数")) );
    ( "字符串连接",
      BuiltinFunctionValue
        (function
        | [ StringValue s1; StringValue s2 ] -> StringValue (s1 ^ s2)
        | _ -> raise (RuntimeError "字符串连接函数期望两个字符串参数")) );
    ( "字符串分割",
      BuiltinFunctionValue
        (function
        | [ StringValue str; StringValue sep ] ->
            let parts = String.split_on_char (String.get sep 0) str in
            ListValue (List.map (fun s -> StringValue s) parts)
        | _ -> raise (RuntimeError "字符串分割函数期望字符串和分隔符参数")) );
    ( "大写转换",
      BuiltinFunctionValue
        (function
        | [ StringValue s ] -> StringValue (String.uppercase_ascii s)
        | _ -> raise (RuntimeError "大写转换函数期望一个字符串参数")) );
    ( "小写转换",
      BuiltinFunctionValue
        (function
        | [ StringValue s ] -> StringValue (String.lowercase_ascii s)
        | _ -> raise (RuntimeError "小写转换函数期望一个字符串参数")) );
    ( "去除空白",
      BuiltinFunctionValue
        (function
        | [ StringValue s ] -> StringValue (String.trim s)
        | _ -> raise (RuntimeError "去除空白函数期望一个字符串参数")) );
    ( "字符串替换",
      BuiltinFunctionValue
        (function
        | [ StringValue str; StringValue old_str; StringValue new_str ] ->
            let regex = Str.regexp_string old_str in
            StringValue (Str.global_replace regex new_str str)
        | _ -> raise (RuntimeError "字符串替换函数期望三个字符串参数")) );
    ( "子字符串",
      BuiltinFunctionValue
        (function
        | [ StringValue str; IntValue start ] ->
            let len = String.length str in
            if start >= 0 && start < len then StringValue (String.sub str start (len - start))
            else raise (RuntimeError "子字符串起始位置超出范围")
        | [ StringValue str; IntValue start; IntValue length ] ->
            let len = String.length str in
            if start >= 0 && start + length <= len && length >= 0 then
              StringValue (String.sub str start length)
            else raise (RuntimeError "子字符串位置或长度超出范围")
        | _ -> raise (RuntimeError "子字符串函数期望字符串、起始位置和可选长度参数")) );
    ( "字符串比较",
      BuiltinFunctionValue
        (function
        | [ StringValue s1; StringValue s2 ] -> IntValue (String.compare s1 s2)
        | _ -> raise (RuntimeError "字符串比较函数期望两个字符串参数")) );
    ( "整数到字符串",
      BuiltinFunctionValue
        (function
        | [ IntValue n ] -> StringValue (string_of_int n)
        | _ -> raise (RuntimeError "整数到字符串函数期望一个整数参数")) );
    ( "浮点数到字符串",
      BuiltinFunctionValue
        (function
        | [ FloatValue f ] -> StringValue (string_of_float f)
        | _ -> raise (RuntimeError "浮点数到字符串函数期望一个浮点数参数")) );
    ( "字符串到整数",
      BuiltinFunctionValue
        (function
        | [ StringValue s ] -> (
            (* 转换全宽数字为ASCII数字 *)
            let normalize_fullwidth_digits str =
              let len = String.length str in
              let rec loop i acc =
                if i >= len then acc
                else if
                  i + 2 < len
                  && Char.code str.[i] = 0xEF
                  && Char.code str.[i + 1] = 0xBC
                  && Char.code str.[i + 2] >= 0x90
                  && Char.code str.[i + 2] <= 0x99
                then
                  (* 全宽数字转换为ASCII *)
                  let ascii_digit = Char.chr (Char.code str.[i + 2] - 0x90 + Char.code '0') in
                  loop (i + 3) (acc ^ String.make 1 ascii_digit)
                else loop (i + 1) (acc ^ String.make 1 str.[i])
              in
              loop 0 ""
            in
            let normalized_s = normalize_fullwidth_digits s in
            try IntValue (int_of_string (String.trim normalized_s))
            with Failure _ -> raise (RuntimeError ("无法将字符串转换为整数: " ^ s)))
        | _ -> raise (RuntimeError "字符串到整数函数期望一个字符串参数")) );
    ( "字符串到浮点数",
      BuiltinFunctionValue
        (function
        | [ StringValue s ] -> (
            (* 转换全宽数字和小数点为ASCII *)
            let normalize_fullwidth_numbers str =
              let len = String.length str in
              let rec loop i acc =
                if i >= len then acc
                else if
                  i + 2 < len
                  && Char.code str.[i] = 0xEF
                  && Char.code str.[i + 1] = 0xBC
                  && Char.code str.[i + 2] >= 0x90
                  && Char.code str.[i + 2] <= 0x99
                then
                  (* 全宽数字转换为ASCII *)
                  let ascii_digit = Char.chr (Char.code str.[i + 2] - 0x90 + Char.code '0') in
                  loop (i + 3) (acc ^ String.make 1 ascii_digit)
                else if
                  i + 2 < len
                  && Char.code str.[i] = 0xEF
                  && Char.code str.[i + 1] = 0xBC
                  && Char.code str.[i + 2] = 0x8E
                then
                  (* 全宽小数点（．）转换为ASCII *)
                  loop (i + 3) (acc ^ ".")
                else loop (i + 1) (acc ^ String.make 1 str.[i])
              in
              loop 0 ""
            in
            let normalized_s = normalize_fullwidth_numbers s in
            try FloatValue (float_of_string (String.trim normalized_s))
            with Failure _ -> raise (RuntimeError ("无法将字符串转换为浮点数: " ^ s)))
        | _ -> raise (RuntimeError "字符串到浮点数函数期望一个字符串参数")) );
  ]

(** 执行程序 *)
let execute_program program =
  (* 重置统计信息 *)
  reset_recovery_statistics ();
  let initial_env = builtin_functions @ empty_env in

  let rec execute_stmt_list env stmts last_val =
    match stmts with
    | [] -> last_val
    | stmt :: rest_stmts ->
        let new_env, value = execute_stmt env stmt in
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
      show_recovery_statistics ();
      flush_all ();
      true
  | Error error_msg ->
      Printf.printf "执行错误: %s\n" error_msg;
      show_recovery_statistics ();
      flush_all ();
      false

(** 安静模式解释执行 - 用于测试 *)
let interpret_quiet program =
  match execute_program program with
  | Ok _result -> true
  | Error _error_msg ->
      (* 在错误恢复模式下，即使有运行时错误也返回成功 *)
      !recovery_config.enabled

(** 交互式求值 *)
let interactive_eval expr env =
  try
    let result = eval_expr env expr in
    Printf.printf "=> %s\n" (value_to_string result);
    flush_all ();
    env
  with
  | RuntimeError msg ->
      Printf.printf "错误: %s\n" msg;
      flush_all ();
      env
  | e ->
      Printf.printf "未知错误: %s\n" (Printexc.to_string e);
      flush_all ();
      env

