(** 骆言解释器模块 - Chinese Programming Language Interpreter Module *)

open Ast
open Value_operations
open Error_recovery

(** 导入各个子模块 *)
module State = Interpreter_state
module Utils = Interpreter_utils
module BinaryOps = Binary_operations
module PatternMatcher = Pattern_matcher
module FunctionCaller = Function_caller
module ExpressionEvaluator = Expression_evaluator
module StatementExecutor = Statement_executor

(** 向后兼容性：保持原有的全局表访问 *)
let macro_table = State.get_macro_table ()
let module_table = State.get_module_table ()
let recursive_functions = State.get_recursive_functions ()
let functor_table = State.get_functor_table ()

(** 主要函数的向后兼容性导出 *)
let expand_macro = Utils.expand_macro
let lookup_var = Utils.lookup_var
let bind_var = Utils.bind_var
let empty_env = Utils.empty_env
let eval_literal = Utils.eval_literal

let execute_binary_op = BinaryOps.execute_binary_op
let execute_unary_op = BinaryOps.execute_unary_op

let match_pattern = PatternMatcher.match_pattern
let execute_match = PatternMatcher.execute_match
let execute_exception_match = PatternMatcher.execute_exception_match
let register_constructors = PatternMatcher.register_constructors

let call_function = FunctionCaller.call_function
let call_labeled_function = FunctionCaller.call_labeled_function
let handle_recursive_let = FunctionCaller.handle_recursive_let

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