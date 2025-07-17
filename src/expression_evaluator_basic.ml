(** 骆言基础表达式求值模块 - Chinese Programming Language Basic Expression Evaluator *)

open Ast
open Value_operations
open Unified_errors
open Interpreter_state
open Binary_operations

(** 字面量求值 *)
let eval_literal literal =
  Result.Ok (
    match literal with
    | IntLit i -> IntValue i
    | FloatLit f -> FloatValue f
    | StringLit s -> StringValue s
    | BoolLit b -> BoolValue b
    | CharLit c -> CharValue c
    | UnitLit -> UnitValue
  )

(** 变量查找 *)
let eval_variable env var_name =
  to_result (fun () -> lookup_var env var_name)

(** 二元运算表达式求值 *)
let eval_binary_op env left_expr right_expr op eval_expr_func =
  match eval_expr_func env left_expr with
  | Result.Ok left_val ->
      (match eval_expr_func env right_expr with
      | Result.Ok right_val ->
          to_result (fun () -> execute_binary_op op left_val right_val)
      | Result.Error e -> Result.Error e)
  | Result.Error e -> Result.Error e

(** 一元运算表达式求值 *)
let eval_unary_op env expr op eval_expr_func =
  match eval_expr_func env expr with
  | Result.Ok value ->
      to_result (fun () -> execute_unary_op op value)
  | Result.Error e -> Result.Error e

(** 基本表达式求值 - 字面量、变量、运算符 *)
let eval_basic_expr env expr =
  (* 创建一个递归评估函数 *)
  let rec eval_expr_func env = function
    | LitExpr literal -> eval_literal literal
    | VarExpr var_name -> eval_variable env var_name
    | BinaryOpExpr (left_expr, op, right_expr) ->
        eval_binary_op env left_expr right_expr op eval_expr_func
    | UnaryOpExpr (op, expr) ->
        eval_unary_op env expr op eval_expr_func
    | _ -> 
        make_runtime_error "不支持的基本表达式类型" None
  in
  eval_expr_func env expr