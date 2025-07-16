(** 骆言解释器模块 - Chinese Programming Language Interpreter Module *)

open Ast
open Value_operations
open Error_recovery

(** 全局宏表：使用AST中定义的macro_def类型 *)
let macro_table : (string, Ast.macro_def) Hashtbl.t = Hashtbl.create 16

(** 全局模块表 *)
let module_table : (string, (string * runtime_value) list) Hashtbl.t = Hashtbl.create 8

(** 全局递归函数表 *)
let recursive_functions : (string, runtime_value) Hashtbl.t = Hashtbl.create 8

(** 全局函子表 *)
let functor_table : (string, identifier * module_type * expr) Hashtbl.t = Hashtbl.create 8

(** 宏展开：将宏体中的参数替换为实际参数 *)
let expand_macro (macro_def : Ast.macro_def) args =
  (* 创建参数到表达式的映射 *)
  let param_map = Hashtbl.create (List.length macro_def.params) in
  
  (* 将宏参数与实际参数关联 *)
  let rec bind_params params args =
    match params, args with
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
    | VarExpr var_name ->
        (match Hashtbl.find_opt param_map var_name with
        | Some replacement_expr -> replacement_expr
        | None -> expr)
    | BinaryOpExpr (left, op, right) ->
        BinaryOpExpr (substitute_expr left, op, substitute_expr right)
    | UnaryOpExpr (op, operand) ->
        UnaryOpExpr (op, substitute_expr operand)
    | FunCallExpr (func_expr, arg_exprs) ->
        FunCallExpr (substitute_expr func_expr, List.map substitute_expr arg_exprs)
    | CondExpr (cond, then_branch, else_branch) ->
        CondExpr (substitute_expr cond, substitute_expr then_branch, substitute_expr else_branch)
    | LetExpr (var_name, value_expr, body_expr) ->
        LetExpr (var_name, substitute_expr value_expr, substitute_expr body_expr)
    | ListExpr exprs ->
        ListExpr (List.map substitute_expr exprs)
    | TupleExpr exprs ->
        TupleExpr (List.map substitute_expr exprs)
    | ArrayExpr exprs ->
        ArrayExpr (List.map substitute_expr exprs)
    | RecordExpr fields ->
        RecordExpr (List.map (fun (name, expr) -> (name, substitute_expr expr)) fields)
    (* 其他表达式类型保持不变或递归处理 *)
    | _ -> expr
  in
  
  substitute_expr macro_def.body

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
  | [var_name] -> (
      (* 简单变量查找 *)
      try List.assoc var_name env
      with Not_found -> (
        (* 检查递归函数表 *)
        match Hashtbl.find_opt recursive_functions var_name with
        | Some func_val -> func_val
        | None ->
            let config = Error_recovery.get_recovery_config () in
            if config.enabled && config.spell_correction then (
              let available_vars = get_available_vars env in
              match find_closest_var var_name available_vars with
              | Some closest_var ->
                  Error_recovery.log_recovery_type "spell_correction"
                    (Printf.sprintf "变量名'%s'未找到，使用最接近的'%s'" var_name closest_var);
                  lookup_var env closest_var
              | None -> raise (RuntimeError ("未定义的变量: " ^ var_name)))
            else raise (RuntimeError ("未定义的变量: " ^ var_name))))
  | module_name :: member_path -> (
      (* 模块成员访问 *)
      match Hashtbl.find_opt module_table module_name with
      | Some module_bindings -> (
          let member_name = String.concat "." member_path in
          try List.assoc member_name module_bindings
          with Not_found -> raise (RuntimeError ("模块中未找到成员: " ^ member_name)))
      | None -> raise (RuntimeError ("未找到模块: " ^ module_name)))

(** 求值字面量 *)
and eval_literal literal =
  match literal with
  | IntLit n -> IntValue n
  | FloatLit f -> FloatValue f
  | StringLit s -> StringValue s
  | BoolLit b -> BoolValue b
  | UnitLit -> UnitValue

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
      let config = Error_recovery.get_recovery_config () in
      if config.enabled && config.type_conversion then
        match op with
        | Add | Sub | Mul | Div | Mod -> (
            (* 尝试数值运算的类型转换 *)
            match (Value_operations.try_to_int left_val, Value_operations.try_to_int right_val) with
            | Some a, Some b -> execute_binary_op op (IntValue a) (IntValue b)
            | _ -> (
                match (Value_operations.try_to_float left_val, Value_operations.try_to_float right_val) with
                | Some a, Some b -> execute_binary_op op (FloatValue a) (FloatValue b)
                | _ ->
                    (* 如果是加法，尝试字符串连接 *)
                    if op = Add then
                      match (Value_operations.try_to_string left_val, Value_operations.try_to_string right_val) with
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
            match (Value_operations.try_to_float left_val, Value_operations.try_to_float right_val) with
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
  | PolymorphicVariantPattern (tag_name, pattern_opt), PolymorphicVariantValue (tag_val, value_opt) ->
    (* 匹配多态变体 *)
    if tag_name = tag_val then
      match (pattern_opt, value_opt) with
      | None, None -> Some env  (* 无值的变体 *)
      | Some pattern, Some value -> match_pattern pattern value env  (* 有值的变体 *)
      | _ -> None  (* 模式和值不匹配 *)
    else
      None  (* 标签不匹配 *)
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
        Error_recovery.log_recovery_type "or_else_fallback" "主表达式执行失败，使用默认值";
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
      | Value_operations.ExceptionRaised exc_val -> (
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
      raise (Value_operations.ExceptionRaised exc_val)
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
  | TupleExpr exprs ->
      (* 元组表达式：求值所有元素并创建元组值 *)
      let values = List.map (eval_expr env) exprs in
      TupleValue values
  | MacroCallExpr macro_call -> (
      (* 查找宏定义 *)
      match Hashtbl.find_opt macro_table macro_call.macro_call_name with
      | Some macro_def ->
          (* 展开宏并求值 *)
          let expanded_expr = expand_macro macro_def macro_call.args in
          eval_expr env expanded_expr
      | None -> raise (RuntimeError ("未定义的宏: " ^ macro_call.macro_call_name)))
  | AsyncExpr async_expr -> (
      (* 异步表达式：基础实现，当前同步执行 *)
      (* 在真实的异步实现中，这应该返回一个Promise或Future值 *)
      match async_expr with
      | AsyncFunc expr ->
          (* 异步函数：当前同步执行 *)
          eval_expr env expr
      | AwaitExpr expr ->
          (* 等待表达式：当前同步执行 *)
          eval_expr env expr
      | SpawnExpr expr ->
          (* 创建任务：当前同步执行 *)
          eval_expr env expr
      | ChannelExpr expr ->
          (* 通道操作：当前同步执行 *)
          eval_expr env expr)
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
  | TypeAnnotationExpr (expr, _type_expr) ->
    (* 类型注解表达式：忽略类型信息，只求值表达式 *)
    eval_expr env expr
    
  | FunExprWithType (param_list, _return_type, body) ->
    (* 带类型注解的函数表达式：忽略类型信息，按普通函数处理 *)
    let param_names = List.map fst param_list in
    FunctionValue (param_names, body, env)
    
  | LetExprWithType (var_name, _type_expr, value_expr, body_expr) ->
    (* 带类型注解的let表达式：忽略类型信息，按普通let处理 *)
    let value = eval_expr env value_expr in
    let new_env = bind_var env var_name value in
    eval_expr new_env body_expr
    
  | PolymorphicVariantExpr (tag_name, value_expr_opt) ->
    (* 多态变体表达式：创建多态变体值 *)
    let value_opt = match value_expr_opt with
      | Some expr -> Some (eval_expr env expr)
      | None -> None
    in
    PolymorphicVariantValue (tag_name, value_opt)
    
  | LabeledFunExpr (label_params, body) ->
    (* 标签函数表达式：创建标签函数值 *)
    LabeledFunctionValue (label_params, body, env)
    
  | LabeledFunCallExpr (func_expr, label_args) ->
    (* 标签函数调用表达式：调用标签函数 *)
    let func_val = eval_expr env func_expr in
    call_labeled_function func_val label_args env
    
  | PoetryAnnotatedExpr (expr, _poetry_form) ->
    (* 诗词注解表达式：求值内部表达式 *)
    eval_expr env expr
    
  | ParallelStructureExpr (left_expr, right_expr) ->
    (* 对偶结构表达式：创建包含两个元素的元组 *)
    let left_val = eval_expr env left_expr in
    let right_val = eval_expr env right_expr in
    ListValue [left_val; right_val]
    
  | RhymeAnnotatedExpr (expr, _rhyme_info) ->
    (* 押韵注解表达式：求值内部表达式 *)
    eval_expr env expr
    
  | ToneAnnotatedExpr (expr, _tone_pattern) ->
    (* 平仄注解表达式：求值内部表达式 *)
    eval_expr env expr
    
  | MeterValidatedExpr (expr, _meter_constraint) ->
    (* 韵律验证表达式：求值内部表达式 *)
    eval_expr env expr
  

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
      else 
        let config = Error_recovery.get_recovery_config () in
        if config.enabled then (
        if
          (* 参数数量不匹配，但启用了错误恢复 *)
          arg_count < param_count
        then (
          (* 参数不足，用默认值填充 *)
          let missing_count = param_count - arg_count in
          let default_vals = List.init missing_count (fun _ -> IntValue 0) in
          let adapted_args = arg_vals @ default_vals in
          Error_recovery.log_recovery_type "parameter_adaptation"
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
          Error_recovery.log_recovery_type "parameter_adaptation"
            (Printf.sprintf "函数期望%d个参数，提供了%d个，忽略多余的%d个参数" param_count arg_count extra_count);
          let new_env =
            List.fold_left2
              (fun acc_env param_name arg_val -> bind_var acc_env param_name arg_val)
              closure_env param_list truncated_args
          in
          eval_expr new_env body)
      else raise (RuntimeError "函数参数数量不匹配")
  | _ -> raise (RuntimeError "尝试调用非函数值")

(** 调用标签函数 *)
and call_labeled_function func_val label_args caller_env =
  match func_val with
  | LabeledFunctionValue (label_params, body, closure_env) ->
    (* 创建参数名到值的映射 *)
    let param_bindings = Hashtbl.create (List.length label_params) in
    
    (* 处理传入的标签参数 *)
    List.iter (fun label_arg ->
      let param_found = List.find_opt (fun label_param -> 
        label_param.label_name = label_arg.arg_label) label_params in
      match param_found with
      | Some param -> 
        let arg_value = eval_expr caller_env label_arg.arg_value in
        Hashtbl.replace param_bindings param.param_name arg_value
      | None -> raise (RuntimeError ("未知的标签参数: " ^ label_arg.arg_label))
    ) label_args;
    
    (* 处理默认值和检查必需参数 *)
    let final_env = List.fold_left (fun acc_env label_param ->
      let param_name = label_param.param_name in
      let param_value = 
        if Hashtbl.mem param_bindings param_name then
          Hashtbl.find param_bindings param_name
        else if label_param.is_optional then
          (* 可选参数，使用默认值 *)
          match label_param.default_value with
          | Some default_expr -> eval_expr closure_env default_expr
          | None -> UnitValue  (* 没有默认值的可选参数使用Unit *)
        else
          (* 必需参数，但没有提供 *)
          raise (RuntimeError ("缺少必需的标签参数: " ^ label_param.label_name))
      in
      bind_var acc_env param_name param_value
    ) closure_env label_params in
    
    (* 在绑定了所有参数的环境中执行函数体 *)
    eval_expr final_env body
    
  | _ -> raise (RuntimeError "尝试调用标签函数，但值不是标签函数")

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
  | [] -> raise (Value_operations.ExceptionRaised exc_val) (* 没有匹配的分支，重新抛出异常 *)
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
    List.fold_left (fun acc_env (constructor_name, _type_opt) ->
      let constructor_func = BuiltinFunctionValue (fun args ->
        ConstructorValue (constructor_name, args)
      ) in
      bind_var acc_env constructor_name constructor_func
    ) env constructors
  | PolymorphicVariantTypeDef variants ->
    (* 为多态变体类型注册标签构造器 *)
    List.fold_left (fun acc_env (tag_name, _type_opt) ->
      let tag_func = BuiltinFunctionValue (fun args ->
        match args with
        | [] -> PolymorphicVariantValue (tag_name, None)
        | [arg] -> PolymorphicVariantValue (tag_name, Some arg)
        | _ -> raise (RuntimeError ("多态变体标签 " ^ tag_name ^ " 只能接受0或1个参数"))
      ) in
      bind_var acc_env tag_name tag_func
    ) env variants
  | _ -> env

(** 处理递归let语句的通用逻辑 *)
let handle_recursive_let env func_name expr =
  let func_val =
    match expr with
    | FunExpr (param_list, body) ->
      (* Create function with current environment *)
      let func_value = FunctionValue (param_list, body, env) in
      (* Store in global recursive functions table for self-reference *)
      Hashtbl.replace recursive_functions func_name func_value;
      func_value
    | FunExprWithType (param_list, _return_type, body) ->
      (* Handle typed function expressions *)
      let param_names = List.map fst param_list in
      let func_value = FunctionValue (param_names, body, env) in
      Hashtbl.replace recursive_functions func_name func_value;
      func_value
    | LabeledFunExpr (label_params, body) ->
      (* Handle labeled function expressions *)
      let func_value = LabeledFunctionValue (label_params, body, env) in
      Hashtbl.replace recursive_functions func_name func_value;
      func_value
    | _ -> raise (RuntimeError "递归让语句期望函数表达式")
  in
  let new_env = bind_var env func_name func_val in
  (new_env, func_val)

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
  | LetStmtWithType (var_name, _type_expr, expr) ->
    (* 带类型注解的let语句：忽略类型信息，按普通let处理 *)
    let value = eval_expr env expr in
    let new_env = bind_var env var_name value in
    (new_env, value)
  | RecLetStmt (func_name, expr) ->
    handle_recursive_let env func_name expr
  | RecLetStmtWithType (func_name, _type_expr, expr) ->
    (* 带类型注解的递归let语句：忽略类型信息，按普通递归let处理 *)
    handle_recursive_let env func_name expr
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
  | MacroDefStmt ast_macro_def ->
      (* 将宏定义保存到全局宏表 *)
      Hashtbl.replace macro_table ast_macro_def.macro_def_name ast_macro_def;
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

(** 执行程序 *)
let execute_program program =
  (* 重置统计信息 *)
  Error_recovery.reset_recovery_statistics ();
  let initial_env = Builtin_functions.builtin_functions @ empty_env in

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

(** 解释程序（带输出） *)
let interpret program =
  match execute_program program with
  | Ok result ->
      print_endline ("结果: " ^ value_to_string result);
      let config = Error_recovery.get_recovery_config () in
      if config.enabled then Error_recovery.show_recovery_statistics ();
      true
  | Error msg ->
      print_endline msg;
      false

(** 静默解释程序 *)
let interpret_quiet program =
  match execute_program program with
  | Ok _ -> true
  | Error _ -> false

(** 交互式表达式求值 *)
let interactive_eval expr env =
  let result = eval_expr env expr in
  (result, env)