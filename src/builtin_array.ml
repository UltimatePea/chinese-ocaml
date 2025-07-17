(** 骆言内置数组操作函数模块 - Chinese Programming Language Builtin Array Functions *)

open Value_operations
open Builtin_error

(** 创建数组函数 *)
let create_array_function args =
  let (size_val, initial_value) = check_double_args args "创建数组" in
  let size = expect_non_negative size_val "创建数组" in
  let array = Array.make size initial_value in
  ArrayValue array

(** 数组长度函数 *)
let array_length_function args =
  let arr = expect_array (check_single_arg args "数组长度") "数组长度" in
  IntValue (Array.length arr)

(** 复制数组函数 *)
let copy_array_function args =
  let arr = expect_array (check_single_arg args "复制数组") "复制数组" in
  ArrayValue (Array.copy arr)

(** 数组获取元素函数 *)
let array_get_function args =
  let (arr_val, index_val) = check_double_args args "数组获取" in
  let arr = expect_array arr_val "数组获取" in
  let index = expect_int index_val "数组获取" in
  check_array_bounds index (Array.length arr) "数组获取";
  arr.(index)

(** 数组设置元素函数 *)
let array_set_function args =
  match args with
  | [arr_val; index_val; value] ->
      let arr = expect_array arr_val "数组设置" in
      let index = expect_int index_val "数组设置" in
      check_array_bounds index (Array.length arr) "数组设置";
      arr.(index) <- value;
      UnitValue
  | _ -> runtime_error "数组设置函数期望三个参数：数组、索引、值"

(** 数组转列表函数 *)
let array_to_list_function args =
  let arr = expect_array (check_single_arg args "数组转列表") "数组转列表" in
  ListValue (Array.to_list arr)

(** 列表转数组函数 *)
let list_to_array_function args =
  let lst = expect_list (check_single_arg args "列表转数组") "列表转数组" in
  ArrayValue (Array.of_list lst)

(** 数组函数表 *)
let array_functions = [
  ("创建数组", BuiltinFunctionValue create_array_function);
  ("数组长度", BuiltinFunctionValue array_length_function);
  ("复制数组", BuiltinFunctionValue copy_array_function);
  ("数组获取", BuiltinFunctionValue array_get_function);
  ("数组设置", BuiltinFunctionValue array_set_function);
  ("数组转列表", BuiltinFunctionValue array_to_list_function);
  ("列表转数组", BuiltinFunctionValue list_to_array_function);
]