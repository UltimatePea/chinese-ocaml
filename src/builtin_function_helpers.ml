(** 骆言内置函数辅助工具模块 - 消除参数验证代码重复 
 * Chinese Programming Language Builtin Function Helpers - Eliminate Parameter Validation Code Duplication 
 * Phase 10.1 - Reduce code duplication and standardize error handling *)

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

(** 三参数内置函数辅助器 - 处理三个参数的常见模式 *)
let triple_args_builtin func_name param1_expect param2_expect param3_expect operation args =
  match args with
  | [arg1; arg2; arg3] ->
      let p1 = param1_expect arg1 func_name in
      let p2 = param2_expect arg2 func_name in
      let p3 = param3_expect arg3 func_name in
      operation p1 p2 p3
  | _ -> runtime_error (func_name ^ "函数期望三个参数")

(** 数组操作辅助函数 - 简化数组相关的重复代码 *)
let single_array_builtin func_name array_operation result_wrapper args =
  let arr = expect_array (check_single_arg args func_name) func_name in
  result_wrapper (array_operation arr)

(** 双参数数组操作辅助函数 *)
let double_array_builtin func_name array_operation result_wrapper args =
  let (first_param, second_param) = check_double_args args func_name in
  let arr = expect_array first_param func_name in
  let idx = expect_int second_param func_name in
  result_wrapper (array_operation arr idx)

(** 高阶函数辅助器 - 处理需要函数参数的内置函数 *)
let higher_order_builtin func_name expect_func2 operation args =
  let func_param = expect_builtin_function (check_single_arg args func_name) func_name in
  BuiltinFunctionValue (fun second_args ->
    let data_param = expect_func2 (check_single_arg second_args func_name) func_name in
    operation func_param data_param
  )

(** 集合操作统一接口 - 支持字符串、列表、数组的统一操作 *)
let collection_operation_builtin func_name operation args =
  let param = check_single_arg args func_name in
  match param with
  | StringValue s -> operation (`String s)
  | ListValue lst -> operation (`List lst)
  | ArrayValue arr -> operation (`Array arr)
  | _ -> runtime_error (func_name ^ "函数需要集合类型参数（字符串、列表或数组）")

(** 错误处理包装器 - 统一异常处理模式 *)
let with_error_handling func_name operation args =
  try
    operation args
  with
  | Sys_error msg -> runtime_error (func_name ^ "系统错误: " ^ msg)
  | Failure msg -> runtime_error (func_name ^ "操作失败: " ^ msg)
  | exn -> runtime_error (func_name ^ "未知错误: " ^ (Printexc.to_string exn))

(** 文件操作错误处理 - 专门处理文件操作的常见错误 *)
let with_file_error_handling func_name filename operation =
  try
    operation ()
  with
  | Sys_error msg -> runtime_error (func_name ^ "文件操作错误 (" ^ filename ^ "): " ^ msg)
  | _ -> runtime_error (func_name ^ "文件操作失败: " ^ filename)

(** 通用高阶函数包装器 - 消除集合操作中的重复模式 *)
let higher_order_list_builtin func_name operation args =
  let func_param = expect_builtin_function (check_single_arg args func_name) func_name in
  BuiltinFunctionValue (fun lst_args ->
    let lst = expect_list (check_single_arg lst_args func_name) func_name in
    operation func_param lst
  )

(** 柯里化列表操作辅助函数 *)
let curried_list_builtin func_name operation args =
  let first_param = expect_list (check_single_arg args func_name) func_name in
  BuiltinFunctionValue (fun second_args ->
    let second_param = expect_list (check_single_arg second_args func_name) func_name in
    ListValue (operation first_param second_param)
  )

(** 参数验证简化宏 - 减少重复的check_single_arg + expect_* 模式 *)
let validate_and_extract expect_func args func_name =
  expect_func (check_single_arg args func_name) func_name

(** 标准化错误消息格式 - 统一内置函数的错误报告格式 *)
let format_builtin_error func_name error_type details =
  Printf.sprintf "【%s】%s: %s" func_name error_type details

(** 通用参数数量错误 *)
let wrong_arg_count_error func_name expected actual =
  format_builtin_error func_name "参数数量错误" 
    (Printf.sprintf "期望%d个参数，实际收到%d个参数" expected actual)

(** 通用类型错误 *)
let type_mismatch_error func_name expected_type actual_value =
  let actual_type = match actual_value with
    | IntValue _ -> "整数"
    | FloatValue _ -> "浮点数"
    | StringValue _ -> "字符串"
    | BoolValue _ -> "布尔值"
    | ListValue _ -> "列表"
    | ArrayValue _ -> "数组"
    | UnitValue -> "单元类型"
    | BuiltinFunctionValue _ -> "内置函数"
    | FunctionValue _ -> "函数"
    | LabeledFunctionValue _ -> "标签函数"
    | RecordValue _ -> "记录"
    | ExceptionValue _ -> "异常"
    | RefValue _ -> "引用"
    | ConstructorValue _ -> "构造器"
    | ModuleValue _ -> "模块"
    | PolymorphicVariantValue _ -> "多态变体"
    | TupleValue _ -> "元组"
  in
  format_builtin_error func_name "类型错误"
    (Printf.sprintf "期望%s类型，收到%s" expected_type actual_type)