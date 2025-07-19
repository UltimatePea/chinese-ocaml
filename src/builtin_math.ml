(** 骆言内置数学函数模块 - Chinese Programming Language Builtin Math Functions *)

open Value_operations
open Builtin_error
open Numeric_ops

(** 范围生成函数 *)
let range_function args =
  let start_val, end_val = check_double_args args "范围" in
  let start = expect_int start_val "范围" in
  let end_num = expect_int end_val "范围" in
  let rec range s e acc =
    if s > e then ListValue (List.rev acc) else range (s + 1) e (IntValue s :: acc)
  in
  range start end_num []

(** 求和函数 - 使用统一数值操作 *)
let sum_function args =
  let lst = expect_list (check_single_arg args "求和") "求和" in
  let aggregator = create_numeric_aggregator add_op (IntValue 0) "求和函数" in
  aggregator lst

(** 最大值函数 - 使用统一数值操作 *)
let max_function args =
  let lst = expect_nonempty_list (check_single_arg args "最大值") "最大值" in
  let aggregator = create_nonempty_numeric_aggregator max_op "最大值函数" in
  aggregator lst

(** 最小值函数 - 使用统一数值操作 *)
let min_function args =
  let lst = expect_nonempty_list (check_single_arg args "最小值") "最小值" in
  let aggregator = create_nonempty_numeric_aggregator min_op "最小值函数" in
  aggregator lst

(** 数学函数表 *)
let math_functions =
  [
    ("范围", BuiltinFunctionValue range_function);
    ("求和", BuiltinFunctionValue sum_function);
    ("最大值", BuiltinFunctionValue max_function);
    ("最小值", BuiltinFunctionValue min_function);
  ]
