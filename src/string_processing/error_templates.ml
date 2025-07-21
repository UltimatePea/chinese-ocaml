(** 统一错误消息模板模块

    本模块提供了所有错误消息的统一格式化功能， 用于确保错误消息的一致性和可维护性。

    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 Issue #708 重构 *)

(* 使用统一字符串工具模块 *)

(** 函数参数错误模板 *)
let function_param_error function_name expected_count actual_count =
  let message = Printf.sprintf "期望%d个参数，但获得%d个参数" expected_count actual_count in
  Utils_formatting.String_utils.Formatting.format_error (function_name ^ "函数") message

let function_param_type_error function_name expected_type =
  Utils_formatting.String_utils.Formatting.format_error (function_name ^ "函数") ("期望" ^ expected_type ^ "参数")

let function_single_param_error function_name = 
  Utils_formatting.String_utils.Formatting.format_error (function_name ^ "函数") "期望一个参数"

let function_double_param_error function_name = 
  Utils_formatting.String_utils.Formatting.format_error (function_name ^ "函数") "期望两个参数"

let function_no_param_error function_name = 
  Utils_formatting.String_utils.Formatting.format_error (function_name ^ "函数") "不需要参数"

(** 类型错误模板 *)
let type_mismatch_error expected_type actual_type =
  let message = Printf.sprintf "期望 %s，但得到 %s" expected_type actual_type in
  Utils_formatting.String_utils.Formatting.format_error "类型不匹配" message

let undefined_variable_error var_name = 
  Utils_formatting.String_utils.Formatting.format_error "未定义的变量" var_name

let index_out_of_bounds_error index length = 
  let message = Printf.sprintf "索引 %d 超出范围，数组长度为 %d" index length in
  Utils_formatting.String_utils.Formatting.format_error "索引错误" message

(** 文件操作错误模板 *)
let file_operation_error operation filename = 
  let message = Printf.sprintf "无法%s文件: %s" operation filename in
  Utils_formatting.String_utils.Formatting.format_error "文件操作错误" message

(** 通用功能错误模板 *)
let generic_function_error function_name error_desc =
  Utils_formatting.String_utils.Formatting.format_error (function_name ^ "函数") error_desc

