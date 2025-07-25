(** 骆言内置类型转换函数模块 - Chinese Programming Language Builtin Type Conversion Functions *)

open Value_operations
open Builtin_error
open Builtin_function_helpers

(** 整数转字符串函数 *)
let int_to_string_function = single_to_string_builtin "整数转字符串" expect_int string_of_int

(** 浮点数转字符串函数 *)
let float_to_string_function = single_to_string_builtin "浮点数转字符串" expect_float string_of_float

(** 字符串转整数函数 *)
let string_to_int_function =
  single_conversion_builtin "字符串转整数" expect_string int_of_string (fun x -> IntValue x)

(** 字符串转浮点数函数 *)
let string_to_float_function =
  single_conversion_builtin "字符串转浮点数" expect_string float_of_string (fun x -> FloatValue x)

(** 整数转浮点数函数 *)
let int_to_float_function =
  single_conversion_builtin "整数转浮点数" expect_int float_of_int (fun x -> FloatValue x)

(** 浮点数转整数函数 *)
let float_to_int_function =
  single_conversion_builtin "浮点数转整数" expect_float int_of_float (fun x -> IntValue x)

(** 布尔值转字符串函数 *)
let bool_to_string_function =
  single_to_string_builtin "布尔值转字符串" expect_bool (fun b -> if b then "真" else "假")

(** 类型转换函数表 *)
let type_conversion_functions =
  [
    ("整数转字符串", BuiltinFunctionValue int_to_string_function);
    ("浮点数转字符串", BuiltinFunctionValue float_to_string_function);
    ("字符串转整数", BuiltinFunctionValue string_to_int_function);
    ("字符串转浮点数", BuiltinFunctionValue string_to_float_function);
    ("整数转浮点数", BuiltinFunctionValue int_to_float_function);
    ("浮点数转整数", BuiltinFunctionValue float_to_int_function);
    ("布尔值转字符串", BuiltinFunctionValue bool_to_string_function);
  ]
