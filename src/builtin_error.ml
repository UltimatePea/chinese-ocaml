(** 骆言内置函数错误处理模块 - Chinese Programming Language Builtin Functions Error Handling
    
    Phase 8 技术债务: 完整迁移到使用Phase 7通用工具模块
    
    使用新的通用模式消除代码重复，提高可维护性和一致性。
    迁移前: 4095字节，多个重复的let绑定和错误处理模式
    迁移后: 使用Common_patterns模块的统一工具函数
    
    @author Alpha, 主要工作代理
    @version 3.0 - Phase 8 完整迁移版本  
    @since 2025-07-27 - Fix #1431 *)

open Value_operations
open String_processing_utils.ErrorMessageTemplates
open Param_validator
open Unified_formatter
open Utils.Common_patterns

(** ========================================================================
    模块上下文配置 - 统一错误上下文创建 (使用Phase 7工具)
    ======================================================================== *)

(** 模块错误上下文创建器 - 消除重复的create_error_context调用 *)
let make_builtin_error_context = 
  make_error_context ~module_name:"Builtin_error"

(** ========================================================================
    核心错误处理函数 - 保持公共接口兼容性
    ======================================================================== *)

(** 错误处理辅助函数 *)
let runtime_error msg = raise (RuntimeError msg)

(** ========================================================================
    参数数量检查 - 使用Phase 7通用模式
    ======================================================================== *)

(** 参数数量检查 - 使用统一错误处理模式 *)
let check_args_count expected_count actual_count function_name =
  let context = make_builtin_error_context ~function_name () in
  if actual_count <> expected_count then
    runtime_error (format_contextual_error context (function_param_error function_name expected_count actual_count))

(** 单参数检查 - 使用统一错误处理模式 *)
let check_single_arg args function_name =
  let context = make_builtin_error_context ~function_name () in
  match args with 
  | [ arg ] -> arg
  | _ -> runtime_error (format_contextual_error context (function_single_param_error function_name))

(** 双参数检查 - 使用统一错误处理模式 *)
let check_double_args args function_name =
  let context = make_builtin_error_context ~function_name () in
  match args with 
  | [ arg1; arg2 ] -> (arg1, arg2)
  | _ -> runtime_error (format_contextual_error context (function_double_param_error function_name))

(** 无参数检查 - 使用统一错误处理模式 *)
let check_no_args args function_name =
  let context = make_builtin_error_context ~function_name () in
  match args with 
  | [] -> ()
  | _ -> runtime_error (format_contextual_error context (function_no_param_error function_name))

(** ========================================================================
    类型检查辅助函数 - 使用Phase 7通用验证模式
    ======================================================================== *)

(** 类型检查辅助函数 - 使用统一参数验证框架和错误上下文 *)
let expect_string value function_name = 
  let context = make_builtin_error_context ~function_name () in
  match validate_with_context (with_function_name validate_string function_name) context value with
  | Ok result -> result
  | Error msg -> runtime_error (format_contextual_error context msg)

let expect_int value function_name = 
  let context = make_builtin_error_context ~function_name () in
  match validate_with_context (with_function_name validate_int function_name) context value with
  | Ok result -> result
  | Error msg -> runtime_error (format_contextual_error context msg)

let expect_float value function_name = 
  let context = make_builtin_error_context ~function_name () in
  match validate_with_context (with_function_name validate_float function_name) context value with
  | Ok result -> result
  | Error msg -> runtime_error (format_contextual_error context msg)

let expect_bool value function_name = 
  let context = make_builtin_error_context ~function_name () in
  match validate_with_context (with_function_name validate_bool function_name) context value with
  | Ok result -> result
  | Error msg -> runtime_error (format_contextual_error context msg)

let expect_list value function_name = 
  let context = make_builtin_error_context ~function_name () in
  match validate_with_context (with_function_name validate_list function_name) context value with
  | Ok result -> result
  | Error msg -> runtime_error (format_contextual_error context msg)

let expect_array value function_name = 
  let context = make_builtin_error_context ~function_name () in
  match validate_with_context (with_function_name validate_array function_name) context value with
  | Ok result -> result
  | Error msg -> runtime_error (format_contextual_error context msg)

let expect_builtin_function value function_name =
  let context = make_builtin_error_context ~function_name () in
  match validate_with_context (with_function_name validate_builtin_function function_name) context value with
  | Ok result -> result
  | Error msg -> runtime_error (format_contextual_error context msg)

let expect_number value function_name = 
  let context = make_builtin_error_context ~function_name () in
  match validate_with_context (with_function_name validate_number function_name) context value with
  | Ok result -> result
  | Error msg -> runtime_error (format_contextual_error context msg)

let expect_string_or_list value function_name =
  let context = make_builtin_error_context ~function_name () in
  match validate_with_context (with_function_name validate_string_or_list function_name) context value with
  | Ok result -> result
  | Error msg -> runtime_error (format_contextual_error context msg)

let expect_nonempty_list value function_name =
  let context = make_builtin_error_context ~function_name () in
  match safe_operation 
    ~error_handler:(fun _ -> generic_function_error function_name "不能用于空列表")
    (fun () -> with_function_name validate_nonempty_list function_name value) with
  | Ok result -> result
  | Error msg -> runtime_error (format_contextual_error context msg)

(** ========================================================================
    专门错误处理函数 - 使用Phase 7通用模式
    ======================================================================== *)

(** 文件操作错误处理 - 使用统一错误处理模式 *)
let handle_file_error operation filename f =
  let context = make_builtin_error_context ~function_name:operation () in
  match safe_operation 
    ~error_handler:(fun _ -> file_operation_error operation filename)
    f with
  | Ok result -> result
  | Error msg -> runtime_error (format_contextual_error context msg)

(** 高阶函数错误处理 - 使用统一错误生成模式 *)
let handle_higher_order_error function_name =
  let context = make_builtin_error_context ~function_name:("高阶函数" ^ function_name) () in
  runtime_error (format_contextual_error context "不支持用户定义函数")

(** 数组索引检查 - 使用统一边界检查模式 *)
let check_array_bounds index array_length function_name =
  let context = make_builtin_error_context ~function_name () in
  if index < 0 || index >= array_length then
    runtime_error (format_contextual_error context 
      (generic_function_error function_name (Collections.array_bounds_error index array_length)))

(** 非负数检查 - 使用统一验证和错误处理模式 *)
let expect_non_negative value function_name =
  let context = make_builtin_error_context ~function_name () in
  match safe_operation 
    ~error_handler:(fun msg -> generic_function_error function_name msg)
    (fun () -> with_function_name validate_non_negative function_name value) with
  | Ok result -> result
  | Error msg -> runtime_error (format_contextual_error context msg)