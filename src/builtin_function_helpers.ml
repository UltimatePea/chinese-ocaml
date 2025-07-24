(** 骆言内置函数辅助工具模块 - 消除参数验证代码重复 
 * Chinese Programming Language Builtin Function Helpers - Eliminate Parameter Validation Code Duplication *)

open Value_operations
open Builtin_error

(** 单参数字符串内置函数辅助器 *)
let single_string_builtin func_name string_operation args =
  let str_param = expect_string (check_single_arg args func_name) func_name in
  StringValue (string_operation str_param)

(** 单参数整数内置函数辅助器 *)
let single_int_builtin func_name int_operation args =
  let int_param = expect_int (check_single_arg args func_name) func_name in
  IntValue (int_operation int_param)

(** 单参数浮点数内置函数辅助器 *)
let single_float_builtin func_name float_operation args =
  let float_param = expect_float (check_single_arg args func_name) func_name in
  FloatValue (float_operation float_param)

(** 单参数布尔值内置函数辅助器 *)
let single_bool_builtin func_name bool_operation args =
  let bool_param = expect_bool (check_single_arg args func_name) func_name in
  BoolValue (bool_operation bool_param)

(** 单参数转字符串内置函数辅助器 *)
let single_to_string_builtin func_name expect_func value_converter args =
  let param = expect_func (check_single_arg args func_name) func_name in
  StringValue (value_converter param)

(** 单参数类型转换内置函数辅助器 *)
let single_conversion_builtin func_name expect_func converter_func result_wrapper args =
  let param = expect_func (check_single_arg args func_name) func_name in
  try
    result_wrapper (converter_func param)
  with
  | Failure _ -> runtime_error ("无法将参数转换: " ^ func_name)

(** 双参数字符串内置函数辅助器 *)
let double_string_builtin func_name string_operation args =
  let (first_param, second_args) = check_double_args args func_name in
  let str1 = expect_string first_param func_name in
  let str2 = expect_string second_args func_name in
  StringValue (string_operation str1 str2)

(** 双参数字符串返回布尔值内置函数辅助器 *)
let double_string_to_bool_builtin func_name string_predicate args =
  let (first_param, second_args) = check_double_args args func_name in
  let str1 = expect_string first_param func_name in
  let str2 = expect_string second_args func_name in
  BoolValue (string_predicate str1 str2)

(** 单参数列表内置函数辅助器 *)
let single_list_builtin func_name list_operation args =
  let list_param = expect_list (check_single_arg args func_name) func_name in
  ListValue (list_operation list_param)

(** 单参数文件操作内置函数辅助器 *)
let single_file_builtin func_name file_operation args =
  let filename = expect_string (check_single_arg args func_name) func_name in
  handle_file_error func_name filename (fun () -> file_operation filename)

(** 复合内置函数构建器 - 支持柯里化风格的双参数函数 *)
let curried_double_string_builtin func_name string_operation args =
  let first_param = expect_string (check_single_arg args func_name) func_name in
  BuiltinFunctionValue (fun second_args ->
    let second_param = expect_string (check_single_arg second_args func_name) func_name in
    StringValue (string_operation first_param second_param)
  )

(** 复合内置函数构建器 - 支持柯里化风格的双参数返回布尔值函数 *)
let curried_double_string_to_bool_builtin func_name string_predicate args =
  let first_param = expect_string (check_single_arg args func_name) func_name in
  BuiltinFunctionValue (fun second_args ->
    let second_param = expect_string (check_single_arg second_args func_name) func_name in
    BoolValue (string_predicate first_param second_param)
  )

(** 复合内置函数构建器 - 支持柯里化风格的双参数列表函数 *)
let curried_string_to_list_builtin func_name string_operation args =
  let first_param = expect_string (check_single_arg args func_name) func_name in
  BuiltinFunctionValue (fun second_args ->
    let second_param = expect_string (check_single_arg second_args func_name) func_name in
    ListValue (List.map (fun s -> StringValue s) (string_operation first_param second_param))
  )