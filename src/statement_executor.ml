(** 骆言解释器语句执行模块 - Chinese Programming Language Interpreter Statement Executor *)

open Ast
open Value_operations
open Interpreter_utils
open Interpreter_state
open Pattern_matcher
open Function_caller
open Expression_evaluator

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
  | RecLetStmt (func_name, expr) -> handle_recursive_let env func_name expr
  | RecLetStmtWithType (func_name, _type_expr, expr) ->
      (* 带类型注解的递归let语句：忽略类型信息，按普通递归let处理 *)
      handle_recursive_let env func_name expr
  | TypeDefStmt (_type_name, type_def) ->
      (* 注册构造器函数 *)
      let new_env = register_constructors env type_def in
      (new_env, UnitValue)
  | ModuleDefStmt mdef ->
      let mod_env = List.fold_left (fun e s -> fst (execute_stmt e s)) [] mdef.statements in
      add_module mdef.module_def_name mod_env;
      (env, UnitValue)
  | ModuleImportStmt _ -> (env, UnitValue)
  | ModuleTypeDefStmt (_type_name, _module_type) ->
      (* 模块类型定义在运行时不需要执行操作 *)
      (env, UnitValue)
  | MacroDefStmt ast_macro_def ->
      (* 将宏定义保存到全局宏表 *)
      add_macro ast_macro_def.macro_def_name ast_macro_def;
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
  let initial_env = List.rev_append (List.rev Builtin_functions.builtin_functions) empty_env in

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
