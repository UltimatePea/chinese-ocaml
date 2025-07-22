(** 统一错误消息模板模块 - Printf.sprintf统一化重构

    本模块提供了所有错误消息的统一格式化功能， 用于确保错误消息的一致性和可维护性。

    重构说明：完全消除Printf.sprintf依赖，使用Base_formatter底层基础设施，
    实现零重复的错误消息格式化。

    @author 骆言技术债务清理团队
    @version 2.0 - Printf.sprintf统一化第三阶段
    @since 2025-07-20 Issue #708 重构
    @updated 2025-07-22 Issue #862 Printf.sprintf统一化 *)

open Utils.Base_formatter

(** 函数参数错误模板 - 使用Base_formatter消除Printf.sprintf *)
let function_param_error function_name expected_count actual_count =
  let message = param_count_pattern expected_count actual_count in
  let func_name = function_name_pattern function_name in
  Utils_formatting.String_utils.Formatting.format_error func_name message

let function_param_type_error function_name expected_type =
  let func_name = function_name_pattern function_name in
  let message = type_expectation_pattern expected_type in
  Utils_formatting.String_utils.Formatting.format_error func_name message

let function_single_param_error function_name =
  let func_name = function_name_pattern function_name in
  Utils_formatting.String_utils.Formatting.format_error func_name "期望一个参数"

let function_double_param_error function_name =
  let func_name = function_name_pattern function_name in
  Utils_formatting.String_utils.Formatting.format_error func_name "期望两个参数"

let function_no_param_error function_name =
  let func_name = function_name_pattern function_name in
  Utils_formatting.String_utils.Formatting.format_error func_name "不需要参数"

(** 类型错误模板 - 使用Base_formatter消除Printf.sprintf *)
let type_mismatch_error expected_type actual_type =
  let message = type_mismatch_pattern expected_type actual_type in
  Utils_formatting.String_utils.Formatting.format_error "类型不匹配" message

let undefined_variable_error var_name =
  Utils_formatting.String_utils.Formatting.format_error "未定义的变量" var_name

let index_out_of_bounds_error index length =
  let message = index_out_of_bounds_pattern index length in
  Utils_formatting.String_utils.Formatting.format_error "索引错误" message

(** 文件操作错误模板 - 使用Base_formatter消除Printf.sprintf *)
let file_operation_error operation filename =
  let message = file_operation_error_pattern operation filename in
  Utils_formatting.String_utils.Formatting.format_error "文件操作错误" message

(** 通用功能错误模板 - 使用Base_formatter优化字符串拼接 *)
let generic_function_error function_name error_desc =
  let func_name = function_name_pattern function_name in
  Utils_formatting.String_utils.Formatting.format_error func_name error_desc
