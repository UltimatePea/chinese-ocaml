(** 骆言内置函数错误处理模块 - Chinese Programming Language Builtin Functions Error Handling *)

open Value_operations
open String_processing_utils.ErrorMessageTemplates
open Param_validator
open Unified_formatter
open Utils.Error_handling_utils

(** 错误处理辅助函数 *)
let runtime_error msg = raise (RuntimeError msg)

(** 新的错误处理函数 - 使用简化的error_handling_utils *)
let _safe_check_args_count expected_count actual_count function_name =
  let context = create_error_context 
    ~function_name 
    ~module_name:"Builtin_error" in
  match check_args_count actual_count ~expected:expected_count ~function_name with
  | Ok () -> Ok ()
  | Error msg -> Error (format_error_msg context msg)

(** 安全的类型检查示例 - 演示条件检查模式 *)
let _safe_check_positive_number x function_name =
  let context = create_error_context 
    ~function_name 
    ~module_name:"Builtin_error" in
  check_condition (x > 0) ~error_msg:"数值必须为正数"
  |> map_error_with_context context

(** 安全的数值运算示例 - 演示数值运算错误处理 *)
let _safe_numeric_divide x y function_name =
  let context = create_error_context 
    ~function_name 
    ~module_name:"Builtin_error" in
  safe_numeric_op (fun () -> x / y)
  |> map_error_with_context context

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

(* 所有expect函数现在都使用Param_validator模块提供的统一接口 *)

(** 类型检查辅助函数 - 使用统一参数验证框架 *)
let expect_string value function_name = with_function_name validate_string function_name value

let expect_int value function_name = with_function_name validate_int function_name value
let expect_float value function_name = with_function_name validate_float function_name value
let expect_bool value function_name = with_function_name validate_bool function_name value
let expect_list value function_name = with_function_name validate_list function_name value
let expect_array value function_name = with_function_name validate_array function_name value

let expect_builtin_function value function_name =
  with_function_name validate_builtin_function function_name value

let expect_number value function_name = with_function_name validate_number function_name value

let expect_string_or_list value function_name =
  with_function_name validate_string_or_list function_name value

let expect_nonempty_list value function_name =
  try with_function_name validate_nonempty_list function_name value
  with RuntimeError _ -> runtime_error (generic_function_error function_name "不能用于空列表")

(** 文件操作错误处理 *)
let handle_file_error operation filename f =
  try f () with Sys_error _ -> runtime_error (file_operation_error operation filename)

(** 高阶函数错误处理 *)
let handle_higher_order_error function_name =
  runtime_error (generic_function_error ("高阶函数" ^ function_name) "不支持用户定义函数")

(** 数组索引检查 *)
let check_array_bounds index array_length function_name =
  if index < 0 || index >= array_length then
    runtime_error
      (generic_function_error function_name (Collections.array_bounds_error index array_length))

(** 非负数检查 - 使用统一参数验证框架 *)
let expect_non_negative value function_name =
  try with_function_name validate_non_negative function_name value
  with RuntimeError msg -> runtime_error (generic_function_error function_name msg)
