(** 骆言内置函数错误处理模块 - Chinese Programming Language Builtin Functions Error Handling *)

open Value_operations
open String_processing_utils.ErrorMessageTemplates

(** 错误处理辅助函数 *)
let runtime_error msg = raise (RuntimeError msg)

(** 参数数量检查 *)
let check_args_count expected_count actual_count function_name =
  if actual_count <> expected_count then
    runtime_error (function_param_error function_name expected_count actual_count)

(** 单参数检查 *)
let check_single_arg args function_name =
  match args with [ arg ] -> arg | _ -> runtime_error (function_single_param_error function_name)

(** 双参数检查 *)
let check_double_args args function_name =
  match args with
  | [ arg1; arg2 ] -> (arg1, arg2)
  | _ -> runtime_error (function_double_param_error function_name)

(** 无参数检查 *)
let check_no_args args function_name =
  match args with [] -> () | _ -> runtime_error (function_no_param_error function_name)

(** 类型检查辅助函数 *)
let expect_string value function_name =
  match value with
  | StringValue s -> s
  | _ -> runtime_error (function_param_type_error function_name "字符串")

let expect_int value function_name =
  match value with
  | IntValue i -> i
  | _ -> runtime_error (function_param_type_error function_name "整数")

let expect_float value function_name =
  match value with
  | FloatValue f -> f
  | _ -> runtime_error (function_param_type_error function_name "浮点数")

let expect_bool value function_name =
  match value with
  | BoolValue b -> b
  | _ -> runtime_error (function_param_type_error function_name "布尔值")

let expect_list value function_name =
  match value with
  | ListValue lst -> lst
  | _ -> runtime_error (function_param_type_error function_name "列表")

let expect_array value function_name =
  match value with
  | ArrayValue arr -> arr
  | _ -> runtime_error (function_param_type_error function_name "数组")

let expect_builtin_function value function_name =
  match value with
  | BuiltinFunctionValue f -> f
  | _ -> runtime_error (function_param_type_error function_name "内置函数")

(** 数值类型检查 *)
let expect_number value function_name =
  match value with
  | IntValue _ | FloatValue _ -> value
  | _ -> runtime_error (function_param_type_error function_name "数值")

(** 字符串或列表检查 *)
let expect_string_or_list value function_name =
  match value with
  | StringValue _ | ListValue _ -> value
  | _ -> runtime_error (function_param_type_error function_name "字符串或列表")

(** 非空列表检查 *)
let expect_nonempty_list value function_name =
  match value with
  | ListValue [] -> runtime_error (generic_function_error function_name "不能用于空列表")
  | ListValue lst -> lst
  | _ -> runtime_error (function_param_type_error function_name "非空列表")

(** 文件操作错误处理 *)
let handle_file_error operation filename f =
  try f () with Sys_error _ -> runtime_error (file_operation_error operation filename)

(** 高阶函数错误处理 *)
let handle_higher_order_error function_name =
  runtime_error (generic_function_error ("高阶函数" ^ function_name) "不支持用户定义函数")

(** 数组索引检查 *)
let check_array_bounds index array_length function_name =
  if index < 0 || index >= array_length then
    runtime_error (generic_function_error function_name (Printf.sprintf "数组索引越界: %d (数组长度: %d)" index array_length))

(** 非负数检查 *)
let expect_non_negative value function_name =
  match value with
  | IntValue i when i >= 0 -> i
  | IntValue i -> runtime_error (generic_function_error function_name (Printf.sprintf "期望非负整数，获得: %d" i))
  | _ -> runtime_error (function_param_type_error function_name "非负整数")
