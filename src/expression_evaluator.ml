(** 骆言解释器表达式求值模块 - Chinese Programming Language Interpreter Expression Evaluator *)

open Ast
open Value_operations

(* Error_recovery qualified usage *)
open Interpreter_utils
open Interpreter_state
open Binary_operations
open Pattern_matcher
open Function_caller

(** 求值表达式 *)
let rec eval_expr env expr =
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
      call_function func_val arg_vals eval_expr
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
      execute_match env value branch_list eval_expr
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
            let matched_branch = execute_exception_match env exc_val catch_branches eval_expr in
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
      match find_macro macro_call.macro_call_name with
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
      let value_opt =
        match value_expr_opt with Some expr -> Some (eval_expr env expr) | None -> None
      in
      PolymorphicVariantValue (tag_name, value_opt)
  | LabeledFunExpr (label_params, body) ->
      (* 标签函数表达式：创建标签函数值 *)
      LabeledFunctionValue (label_params, body, env)
  | LabeledFunCallExpr (func_expr, label_args) ->
      (* 标签函数调用表达式：调用标签函数 *)
      let func_val = eval_expr env func_expr in
      call_labeled_function func_val label_args env eval_expr
  | PoetryAnnotatedExpr (expr, _poetry_form) ->
      (* 诗词注解表达式：求值内部表达式 *)
      eval_expr env expr
  | ParallelStructureExpr (left_expr, right_expr) ->
      (* 对偶结构表达式：创建包含两个元素的元组 *)
      let left_val = eval_expr env left_expr in
      let right_val = eval_expr env right_expr in
      ListValue [ left_val; right_val ]
  | RhymeAnnotatedExpr (expr, _rhyme_info) ->
      (* 押韵注解表达式：求值内部表达式 *)
      eval_expr env expr
  | ToneAnnotatedExpr (expr, _tone_pattern) ->
      (* 平仄注解表达式：求值内部表达式 *)
      eval_expr env expr
  | MeterValidatedExpr (expr, _meter_constraint) ->
      (* 韵律验证表达式：求值内部表达式 *)
      eval_expr env expr
