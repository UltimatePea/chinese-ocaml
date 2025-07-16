(** 骆言解释器模块 - Chinese Programming Language Interpreter Module *)

open Value_operations
open Error_recovery

(** 导入各个子模块 *)
module State = Interpreter_state
module Utils = Interpreter_utils
module ExpressionEvaluator = Expression_evaluator
module StatementExecutor = Statement_executor

(** 向后兼容性：保持原有的全局表访问 *)
let macro_table = State.get_macro_table ()
let module_table = State.get_module_table ()
let recursive_functions = State.get_recursive_functions ()
let functor_table = State.get_functor_table ()

(** 主要函数的向后兼容性导出 - 只保留接口中导出的函数 *)
let expand_macro = Utils.expand_macro
let eval_expr = ExpressionEvaluator.eval_expr
let execute_stmt = StatementExecutor.execute_stmt
let execute_program = StatementExecutor.execute_program

(** 解释程序（带输出） *)
let interpret program =
  match execute_program program with
  | Ok result ->
      Logger.print_user_output ("结果: " ^ value_to_string result);
      let config = Error_recovery.get_recovery_config () in
      if config.enabled then Error_recovery.show_recovery_statistics ();
      true
  | Error msg ->
      Logger.print_user_output msg;
      false

(** 静默解释程序 *)
let interpret_quiet program = match execute_program program with Ok _ -> true | Error _ -> false

(** 交互式表达式求值 *)
let interactive_eval expr env =
  let result = eval_expr env expr in
  (result, env)