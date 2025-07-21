(** 统一错误消息模板模块

    本模块提供了所有错误消息的统一格式化功能， 用于确保错误消息的一致性和可维护性。

    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 Issue #708 重构 *)

(** 函数参数错误模板 *)
let function_param_error function_name expected_count actual_count =
  Printf.sprintf "%s函数期望%d个参数，但获得%d个参数" function_name expected_count actual_count

let function_param_type_error function_name expected_type =
  Printf.sprintf "%s函数期望%s参数" function_name expected_type

let function_single_param_error function_name = Printf.sprintf "%s函数期望一个参数" function_name

let function_double_param_error function_name = Printf.sprintf "%s函数期望两个参数" function_name

let function_no_param_error function_name = Printf.sprintf "%s函数不需要参数" function_name

(** 类型错误模板 *)
let type_mismatch_error expected_type actual_type =
  Printf.sprintf "类型不匹配: 期望 %s，但得到 %s" expected_type actual_type

let undefined_variable_error var_name = Printf.sprintf "未定义的变量: %s" var_name

let index_out_of_bounds_error index length = Printf.sprintf "索引 %d 超出范围，数组长度为 %d" index length

(** 文件操作错误模板 *)
let file_operation_error operation filename = Printf.sprintf "无法%s文件: %s" operation filename

(** 通用功能错误模板 *)
let generic_function_error function_name error_desc =
  Printf.sprintf "%s函数：%s" function_name error_desc

