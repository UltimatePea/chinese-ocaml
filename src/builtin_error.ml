(** 骆言内置函数错误处理模块 - Chinese Programming Language Builtin Functions Error Handling *)

open Value_operations

(** 错误处理辅助函数 *)
let runtime_error msg = raise (RuntimeError msg)

(** 参数数量检查 *)
let check_args_count expected_count actual_count function_name =
  if actual_count <> expected_count then
    runtime_error (Printf.sprintf "%s函数期望%d个参数，但获得%d个参数" function_name expected_count actual_count)

(** 单参数检查 *)
let check_single_arg args function_name =
  match args with [ arg ] -> arg | _ -> runtime_error (Printf.sprintf "%s函数期望一个参数" function_name)

(** 双参数检查 *)
let check_double_args args function_name =
  match args with
  | [ arg1; arg2 ] -> (arg1, arg2)
  | _ -> runtime_error (Printf.sprintf "%s函数期望两个参数" function_name)

(** 无参数检查 *)
let check_no_args args function_name =
  match args with [] -> () | _ -> runtime_error (Printf.sprintf "%s函数不需要参数" function_name)

(** 类型检查辅助函数 *)
let expect_string value function_name =
  match value with
  | StringValue s -> s
  | _ -> runtime_error (Printf.sprintf "%s函数期望字符串参数" function_name)

let expect_int value function_name =
  match value with
  | IntValue i -> i
  | _ -> runtime_error (Printf.sprintf "%s函数期望整数参数" function_name)

let expect_float value function_name =
  match value with
  | FloatValue f -> f
  | _ -> runtime_error (Printf.sprintf "%s函数期望浮点数参数" function_name)

let expect_bool value function_name =
  match value with
  | BoolValue b -> b
  | _ -> runtime_error (Printf.sprintf "%s函数期望布尔值参数" function_name)

let expect_list value function_name =
  match value with
  | ListValue lst -> lst
  | _ -> runtime_error (Printf.sprintf "%s函数期望列表参数" function_name)

let expect_array value function_name =
  match value with
  | ArrayValue arr -> arr
  | _ -> runtime_error (Printf.sprintf "%s函数期望数组参数" function_name)

let expect_builtin_function value function_name =
  match value with
  | BuiltinFunctionValue f -> f
  | _ -> runtime_error (Printf.sprintf "%s函数期望内置函数参数" function_name)

(** 数值类型检查 *)
let expect_number value function_name =
  match value with
  | IntValue _ | FloatValue _ -> value
  | _ -> runtime_error (Printf.sprintf "%s函数期望数值参数" function_name)

(** 字符串或列表检查 *)
let expect_string_or_list value function_name =
  match value with
  | StringValue _ | ListValue _ -> value
  | _ -> runtime_error (Printf.sprintf "%s函数期望字符串或列表参数" function_name)

(** 非空列表检查 *)
let expect_nonempty_list value function_name =
  match value with
  | ListValue [] -> runtime_error (Printf.sprintf "%s函数不能用于空列表" function_name)
  | ListValue lst -> lst
  | _ -> runtime_error (Printf.sprintf "%s函数期望非空列表参数" function_name)

(** 文件操作错误处理 *)
let handle_file_error operation filename f =
  try f () with Sys_error _ -> runtime_error (Printf.sprintf "无法%s文件: %s" operation filename)

(** 高阶函数错误处理 *)
let handle_higher_order_error function_name =
  runtime_error (Printf.sprintf "高阶函数%s不支持用户定义函数" function_name)

(** 数组索引检查 *)
let check_array_bounds index array_length function_name =
  if index < 0 || index >= array_length then
    runtime_error (Printf.sprintf "%s函数：数组索引越界: %d (数组长度: %d)" function_name index array_length)

(** 非负数检查 *)
let expect_non_negative value function_name =
  match value with
  | IntValue i when i >= 0 -> i
  | IntValue i -> runtime_error (Printf.sprintf "%s函数期望非负整数，获得: %d" function_name i)
  | _ -> runtime_error (Printf.sprintf "%s函数期望非负整数参数" function_name)
