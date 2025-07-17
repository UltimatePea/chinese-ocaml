(** 骆言解释器表达式求值模块 - Chinese Programming Language Interpreter Expression Evaluator *)

open Ast
open Value_operations
open Compiler_errors

(* Error_recovery qualified usage *)
open Interpreter_utils
open Interpreter_state
open Binary_operations
open Pattern_matcher
open Function_caller

(** 位置转换函数 - 表达式求值中暂时使用简化位置 *)
let create_eval_position line_hint : Compiler_errors.position =
  { filename = "<expression_evaluator>"; line = line_hint; column = 0 }

(** 基本表达式求值 - 字面量、变量、运算符 *)
let rec eval_basic_expr env expr =
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
  | _ -> raise (RuntimeError "不支持的基本表达式类型")

(** 控制流表达式求值 - 函数调用、条件、匹配 *)
and eval_control_flow_expr env expr =
  match expr with
  | FunCallExpr (func_expr, arg_list) ->
      let func_val = eval_expr env func_expr in
      let arg_vals = List.map (eval_expr env) arg_list in
      call_function func_val arg_vals eval_expr
  | CondExpr (cond, then_branch, else_branch) ->
      let cond_val = eval_expr env cond in
      if value_to_bool cond_val then eval_expr env then_branch 
      else eval_expr env else_branch
  | FunExpr (param_list, body) -> 
      FunctionValue (param_list, body, env)
  | LetExpr (var_name, val_expr, body_expr) ->
      let value = eval_expr env val_expr in
      let new_env = bind_var env var_name value in
      eval_expr new_env body_expr
  | MatchExpr (expr, branch_list) ->
      let value = eval_expr env expr in
      execute_match env value branch_list eval_expr
  | SemanticLetExpr (var_name, _semantic_label, val_expr, body_expr) ->
      (* For now, semantic labels are just metadata - evaluate normally *)
      let value = eval_expr env val_expr in
      let new_env = bind_var env var_name value in
      eval_expr new_env body_expr
  | _ -> raise (RuntimeError "不支持的控制流表达式类型")

(** 数据结构表达式求值 - 记录、数组、元组 *)
and eval_data_structure_expr env expr =
  match expr with
  | RecordExpr fields ->
      let eval_field (name, expr) = (name, eval_expr env expr) in
      RecordValue (List.map eval_field fields)
  | FieldAccessExpr (record_expr, field_name) ->
      let record_val = eval_expr env record_expr in
      (match record_val with
      | RecordValue fields -> 
          (try List.assoc field_name fields
           with Not_found -> 
             let pos = create_eval_position 71 in
             match runtime_error (Printf.sprintf "记录没有字段: %s" field_name) (Some pos) with
             | Error error_info -> raise (CompilerError error_info)
             | Ok _ -> failwith "不应该到达此处")
      | _ -> 
          let pos = create_eval_position 81 in
          match runtime_error "期望记录类型" (Some pos) with
          | Error error_info -> raise (CompilerError error_info)
          | Ok _ -> failwith "不应该到达此处")
  | TupleExpr exprs ->
      let values = List.map (eval_expr env) exprs in
      TupleValue values
  | ArrayExpr elements ->
      let values = List.map (eval_expr env) elements in
      ArrayValue (Array.of_list values)
  | RecordUpdateExpr (record_expr, updates) ->
      let record_val = eval_expr env record_expr in
      (match record_val with
      | RecordValue fields ->
          let update_field (name, value) fields =
            if List.mem_assoc name fields then 
              (name, value) :: List.remove_assoc name fields
            else 
              raise (RuntimeError (Printf.sprintf "记录没有字段: %s" name))
          in
          let eval_update (name, expr) = (name, eval_expr env expr) in
          let evaluated_updates = List.map eval_update updates in
          let new_fields = List.fold_right update_field evaluated_updates fields in
          RecordValue new_fields
      | _ -> raise (RuntimeError "期望记录类型"))
  | ArrayAccessExpr (array_expr, index_expr) ->
      let array_val = eval_expr env array_expr in
      let index_val = eval_expr env index_expr in
      (match (array_val, index_val) with
      | ArrayValue arr, IntValue idx ->
          if idx >= 0 && idx < Array.length arr then arr.(idx)
          else
            let pos = create_eval_position 111 in
            (match runtime_error 
              (Printf.sprintf "数组索引越界: %d (数组长度: %d)" idx (Array.length arr))
              (Some pos) with
            | Error error_info -> raise (CompilerError error_info)
            | Ok _ -> failwith "不应该到达此处")
      | ArrayValue _, _ ->
          let pos = create_eval_position 116 in
          (match runtime_error "数组索引必须是整数" (Some pos) with
          | Error error_info -> raise (CompilerError error_info)
          | Ok _ -> failwith "不应该到达此处")
      | _ ->
          let pos = create_eval_position 117 in
          (match runtime_error "期望数组类型" (Some pos) with
          | Error error_info -> raise (CompilerError error_info)
          | Ok _ -> failwith "不应该到达此处"))
  | ArrayUpdateExpr (array_expr, index_expr, value_expr) ->
      let array_val = eval_expr env array_expr in
      let index_val = eval_expr env index_expr in
      let new_value = eval_expr env value_expr in
      (match (array_val, index_val) with
      | ArrayValue arr, IntValue idx ->
          if idx >= 0 && idx < Array.length arr then (
            arr.(idx) <- new_value;
            UnitValue
          ) else 
            raise (RuntimeError (Printf.sprintf "数组索引越界: %d (数组长度: %d)" idx (Array.length arr)))
      | ArrayValue _, _ -> 
          raise (RuntimeError "数组索引必须是整数")
      | _ -> 
          raise (RuntimeError "期望数组类型"))
  | ListExpr expr_list ->
      let values = List.map (eval_expr env) expr_list in
      ListValue values
  | _ -> raise (RuntimeError "不支持的数据结构表达式类型")

(** 异常处理表达式求值 - try/catch/raise *)
and eval_exception_expr env expr =
  match expr with
  | TryExpr (try_expr, catch_branches, finally_expr_opt) ->
      let exec_finally () =
        match finally_expr_opt with
        | Some finally_expr -> ignore (eval_expr env finally_expr)
        | None -> ()
      in
      (try
        let result = eval_expr env try_expr in
        exec_finally ();
        result
      with
      | Value_operations.ExceptionRaised exc_val ->
          (try
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
      let exc_val = eval_expr env expr in
      raise (Value_operations.ExceptionRaised exc_val)
  | _ -> raise (RuntimeError "不支持的异常表达式类型")

(** 引用表达式求值 - ref/deref/assign *)
and eval_reference_expr env expr =
  match expr with
  | RefExpr expr ->
      let value = eval_expr env expr in
      RefValue (ref value)
  | DerefExpr expr ->
      (match eval_expr env expr with
      | RefValue r -> !r
      | _ -> raise (RuntimeError "解引用操作需要引用值"))
  | AssignExpr (target_expr, value_expr) ->
      (match eval_expr env target_expr with
      | RefValue r ->
          let new_value = eval_expr env value_expr in
          r := new_value;
          UnitValue
      | _ -> raise (RuntimeError "赋值目标必须是引用"))
  | _ -> raise (RuntimeError "不支持的引用表达式类型")

(** 构造器和类型表达式求值 *)
and eval_constructor_expr env expr =
  match expr with
  | ConstructorExpr (constructor_name, arg_exprs) ->
      let arg_vals = List.map (eval_expr env) arg_exprs in
      ConstructorValue (constructor_name, arg_vals)
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
        match value_expr_opt with 
        | Some expr -> Some (eval_expr env expr) 
        | None -> None
      in
      PolymorphicVariantValue (tag_name, value_opt)
  | _ -> raise (RuntimeError "不支持的构造器表达式类型")

(** 模块和函子表达式求值 *)
and eval_module_expr env expr =
  match expr with
  | ModuleAccessExpr (module_expr, member_name) ->
      let module_value = eval_expr env module_expr in
      (match module_value with
      | ModuleValue bindings ->
          (match List.assoc_opt member_name bindings with
          | Some value -> value
          | None -> raise (RuntimeError ("模块中未找到成员: " ^ member_name)))
      | _ -> raise (RuntimeError "只能访问模块的成员"))
  | FunctorCallExpr (functor_expr, module_expr) ->
      let functor_value = eval_expr env functor_expr in
      let module_value = eval_expr env module_expr in
      (match functor_value with
      | FunctionValue ([ param ], body, functor_env) ->
          let param_env = (param, module_value) :: functor_env in
          eval_expr param_env body
      | _ -> raise (RuntimeError "只能调用函子"))
  | FunctorExpr (param_name, _param_type, body) ->
      FunctionValue ([ param_name ], body, env)
  | ModuleExpr _statements ->
      (* 模块表达式求值 - 暂时简化实现 *)
      raise (RuntimeError "模块表达式功能尚未完全实现")
  | _ -> raise (RuntimeError "不支持的模块表达式类型")

(** 标签函数表达式求值 *)
and eval_labeled_function_expr env expr =
  match expr with
  | LabeledFunExpr (label_params, body) ->
      LabeledFunctionValue (label_params, body, env)
  | LabeledFunCallExpr (func_expr, label_args) ->
      let func_val = eval_expr env func_expr in
      call_labeled_function func_val label_args env eval_expr
  | _ -> raise (RuntimeError "不支持的标签函数表达式类型")

(** 宏和异步表达式求值 *)
and eval_macro_async_expr env expr =
  match expr with
  | MacroCallExpr macro_call ->
      (match find_macro macro_call.macro_call_name with
      | Some macro_def ->
          let expanded_expr = expand_macro macro_def macro_call.args in
          eval_expr env expanded_expr
      | None -> raise (RuntimeError ("未定义的宏: " ^ macro_call.macro_call_name)))
  | AsyncExpr async_expr ->
      (* 异步表达式：基础实现，当前同步执行 *)
      (match async_expr with
      | AsyncFunc expr -> eval_expr env expr
      | AwaitExpr expr -> eval_expr env expr
      | SpawnExpr expr -> eval_expr env expr
      | ChannelExpr expr -> eval_expr env expr)
  | _ -> raise (RuntimeError "不支持的宏或异步表达式类型")

(** 诗词相关表达式求值 *)
and eval_poetry_expr env expr =
  match expr with
  | PoetryAnnotatedExpr (expr, _poetry_form) ->
      eval_expr env expr
  | ParallelStructureExpr (left_expr, right_expr) ->
      let left_val = eval_expr env left_expr in
      let right_val = eval_expr env right_expr in
      ListValue [ left_val; right_val ]
  | RhymeAnnotatedExpr (expr, _rhyme_info) ->
      eval_expr env expr
  | ToneAnnotatedExpr (expr, _tone_pattern) ->
      eval_expr env expr
  | MeterValidatedExpr (expr, _meter_constraint) ->
      eval_expr env expr
  | _ -> raise (RuntimeError "不支持的诗词表达式类型")

(** 组合和容错表达式求值 *)
and eval_composition_expr env expr =
  match expr with
  | CombineExpr expr_list ->
      let values = List.map (eval_expr env) expr_list in
      ListValue values
  | OrElseExpr (primary_expr, default_expr) ->
      (try
        let result = eval_expr env primary_expr in
        match result with 
        | UnitValue -> eval_expr env default_expr (* 单元值被视为"无效" *)
        | _ -> result
      with RuntimeError _ | Failure _ ->
        (* 主表达式出错，返回默认值 *)
        Error_recovery.log_recovery_type "or_else_fallback" "主表达式执行失败，使用默认值";
        eval_expr env default_expr)
  | _ -> raise (RuntimeError "不支持的组合表达式类型")

(** Phase 3 重构优化 - 主表达式求值函数 *)
and eval_expr env expr =
  let dispatch_expr_eval () =
    match expr with
    (* 基本表达式 *)
    | LitExpr _ | VarExpr _ | BinaryOpExpr _ | UnaryOpExpr _ ->
        eval_basic_expr env expr
    
    (* 控制流表达式 *)
    | FunCallExpr _ | CondExpr _ | FunExpr _ | LetExpr _ | MatchExpr _ | SemanticLetExpr _ ->
        eval_control_flow_expr env expr
    
    (* 数据结构表达式 *)
    | RecordExpr _ | FieldAccessExpr _ | TupleExpr _ | ArrayExpr _ | RecordUpdateExpr _ 
    | ArrayAccessExpr _ | ArrayUpdateExpr _ | ListExpr _ ->
        eval_data_structure_expr env expr
    
    (* 异常处理表达式 *)
    | TryExpr _ | RaiseExpr _ ->
        eval_exception_expr env expr
    
    (* 引用表达式 *)
    | RefExpr _ | DerefExpr _ | AssignExpr _ ->
        eval_reference_expr env expr
    
    (* 构造器和类型表达式 *)
    | ConstructorExpr _ | TypeAnnotationExpr _ | FunExprWithType _ 
    | LetExprWithType _ | PolymorphicVariantExpr _ ->
        eval_constructor_expr env expr
    
    (* 模块和函子表达式 *)
    | ModuleAccessExpr _ | FunctorCallExpr _ | FunctorExpr _ | ModuleExpr _ ->
        eval_module_expr env expr
    
    (* 标签函数表达式 *)
    | LabeledFunExpr _ | LabeledFunCallExpr _ ->
        eval_labeled_function_expr env expr
    
    (* 宏和异步表达式 *)
    | MacroCallExpr _ | AsyncExpr _ ->
        eval_macro_async_expr env expr
    
    (* 诗词相关表达式 *)
    | PoetryAnnotatedExpr _ | ParallelStructureExpr _ | RhymeAnnotatedExpr _ 
    | ToneAnnotatedExpr _ | MeterValidatedExpr _ ->
        eval_poetry_expr env expr
    
    (* 组合和容错表达式 *)
    | CombineExpr _ | OrElseExpr _ ->
        eval_composition_expr env expr
  in
  try
    dispatch_expr_eval ()
  with
  | RuntimeError msg -> raise (RuntimeError msg)
  | CompilerError _ as e -> raise e
  | exn -> raise (RuntimeError ("表达式求值失败: " ^ Printexc.to_string exn))