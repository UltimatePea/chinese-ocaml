(** 骆言内置数学函数模块 - Chinese Programming Language Builtin Math Functions *)

open Value_operations
open Builtin_error

(** 范围生成函数 *)
let range_function args =
  let (start_val, end_val) = check_double_args args "范围" in
  let start = expect_int start_val "范围" in
  let end_num = expect_int end_val "范围" in
  let rec range s e acc =
    if s > e then ListValue (List.rev acc) 
    else range (s + 1) e (IntValue s :: acc)
  in
  range start end_num []

(** 求和函数 *)
let sum_function args =
  let lst = expect_list (check_single_arg args "求和") "求和" in
  let sum = List.fold_left (fun acc elem ->
    match (acc, elem) with
    | IntValue a, IntValue b -> IntValue (a + b)
    | FloatValue a, FloatValue b -> FloatValue (a +. b)
    | IntValue a, FloatValue b -> FloatValue (float_of_int a +. b)
    | FloatValue a, IntValue b -> FloatValue (a +. float_of_int b)
    | _ -> runtime_error "求和函数只能用于数字列表"
  ) (IntValue 0) lst in
  sum

(** 最大值函数 *)
let max_function args =
  let lst = expect_nonempty_list (check_single_arg args "最大值") "最大值" in
  match lst with
  | first :: rest ->
      List.fold_left (fun acc elem ->
        match (acc, elem) with
        | IntValue a, IntValue b -> IntValue (max a b)
        | FloatValue a, FloatValue b -> FloatValue (max a b)
        | IntValue a, FloatValue b -> FloatValue (max (float_of_int a) b)
        | FloatValue a, IntValue b -> FloatValue (max a (float_of_int b))
        | _ -> runtime_error "最大值函数只能用于数字列表"
      ) first rest
  | [] -> runtime_error "最大值函数不能用于空列表"

(** 最小值函数 *)
let min_function args =
  let lst = expect_nonempty_list (check_single_arg args "最小值") "最小值" in
  match lst with
  | first :: rest ->
      List.fold_left (fun acc elem ->
        match (acc, elem) with
        | IntValue a, IntValue b -> IntValue (min a b)
        | FloatValue a, FloatValue b -> FloatValue (min a b)
        | IntValue a, FloatValue b -> FloatValue (min (float_of_int a) b)
        | FloatValue a, IntValue b -> FloatValue (min a (float_of_int b))
        | _ -> runtime_error "最小值函数只能用于数字列表"
      ) first rest
  | [] -> runtime_error "最小值函数不能用于空列表"

(** 数学函数表 *)
let math_functions = [
  ("范围", BuiltinFunctionValue range_function);
  ("求和", BuiltinFunctionValue sum_function);
  ("最大值", BuiltinFunctionValue max_function);
  ("最小值", BuiltinFunctionValue min_function);
]