(** 骆言内置类型转换函数模块 - Chinese Programming Language Builtin Type Conversion Functions *)

open Value_operations
open Builtin_error

(** 整数转字符串函数 *)
let int_to_string_function args =
  let n = expect_int (check_single_arg args "整数转字符串") "整数转字符串" in
  StringValue (string_of_int n)

(** 浮点数转字符串函数 *)
let float_to_string_function args =
  let f = expect_float (check_single_arg args "浮点数转字符串") "浮点数转字符串" in
  StringValue (string_of_float f)

(** 字符串转整数函数 *)
let string_to_int_function args =
  let s = expect_string (check_single_arg args "字符串转整数") "字符串转整数" in
  try
    IntValue (int_of_string s)
  with Failure _ -> runtime_error ("无法将字符串转换为整数: " ^ s)

(** 字符串转浮点数函数 *)
let string_to_float_function args =
  let s = expect_string (check_single_arg args "字符串转浮点数") "字符串转浮点数" in
  try
    FloatValue (float_of_string s)
  with Failure _ -> runtime_error ("无法将字符串转换为浮点数: " ^ s)

(** 整数转浮点数函数 *)
let int_to_float_function args =
  let n = expect_int (check_single_arg args "整数转浮点数") "整数转浮点数" in
  FloatValue (float_of_int n)

(** 浮点数转整数函数 *)
let float_to_int_function args =
  let f = expect_float (check_single_arg args "浮点数转整数") "浮点数转整数" in
  IntValue (int_of_float f)

(** 布尔值转字符串函数 *)
let bool_to_string_function args =
  let b = expect_bool (check_single_arg args "布尔值转字符串") "布尔值转字符串" in
  StringValue (if b then "真" else "假")

(** 类型转换函数表 *)
let type_conversion_functions = [
  ("整数转字符串", BuiltinFunctionValue int_to_string_function);
  ("浮点数转字符串", BuiltinFunctionValue float_to_string_function);
  ("字符串转整数", BuiltinFunctionValue string_to_int_function);
  ("字符串转浮点数", BuiltinFunctionValue string_to_float_function);
  ("整数转浮点数", BuiltinFunctionValue int_to_float_function);
  ("浮点数转整数", BuiltinFunctionValue float_to_int_function);
  ("布尔值转字符串", BuiltinFunctionValue bool_to_string_function);
]