(** 骆言基础表达式求值模块 - Chinese Programming Language Basic Expression Evaluator *)

open Ast
open Value_operations
open Binary_operations

type eval_expr_func = runtime_env -> expr -> runtime_value
(** 评估函数类型 *)

(** 字面量求值 *)
let eval_literal = function
  | IntLit i -> IntValue i
  | FloatLit f -> FloatValue f
  | StringLit s -> StringValue s
  | BoolLit b -> BoolValue b
  | UnitLit -> UnitValue

(** 基本表达式求值 - 字面量、变量、运算符 *)
let eval_basic_expr env eval_expr_func = function
  | LitExpr literal -> eval_literal literal
  | VarExpr var_name -> Interpreter_utils.lookup_var env var_name
  | BinaryOpExpr (left_expr, op, right_expr) ->
      let left_val = eval_expr_func env left_expr in
      let right_val = eval_expr_func env right_expr in
      execute_binary_op op left_val right_val
  | UnaryOpExpr (op, expr) ->
      let value = eval_expr_func env expr in
      execute_unary_op op value
  | _ -> raise (RuntimeError "不支持的基本表达式类型")
