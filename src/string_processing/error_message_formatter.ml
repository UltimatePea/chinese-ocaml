(** 骆言编译器通用错误消息格式化器 - Printf.sprintf统一化重构

    此模块提供统一的错误消息格式化接口，基于Base_formatter底层基础设施， 消除项目中分散的Printf.sprintf错误处理模式。

    设计目标:
    - 统一文件操作错误格式
    - 标准化类型错误消息
    - 简化解析错误处理
    - 提供一致的异常消息格式
    - 零Printf.sprintf依赖 *)

open Utils.Base_formatter

(** 通用错误消息格式化器 *)
module Error_message_formatter = struct
  (** 文件操作错误 *)
  let file_not_found filename = file_not_found_pattern filename

  let file_read_error filename = file_read_error_pattern filename
  let file_write_error filename = file_write_error_pattern filename
  let file_operation_error operation filename = file_operation_error_pattern operation filename

  (** 类型相关错误 *)
  let type_mismatch type_info = type_mismatch_error_pattern type_info

  let unknown_type type_name = unknown_type_pattern type_name
  let invalid_type_operation op_name = invalid_type_operation_pattern op_name

  (** 解析错误 *)
  let parse_failure format msg = parse_failure_pattern format msg

  let json_parse_error msg = json_parse_error_pattern msg
  let test_case_parse_error msg = test_case_parse_error_pattern msg
  let config_parse_error msg = config_parse_error_pattern msg
  let config_list_parse_error msg = config_list_parse_error_pattern msg
  let comprehensive_test_parse_error msg = comprehensive_test_parse_error_pattern msg
  let summary_items_parse_error msg = summary_items_parse_error_pattern msg

  (** 检查器错误 *)
  let unknown_checker_type checker_type = unknown_checker_type_pattern checker_type

  (** 通用异常处理 *)
  let unexpected_exception exn = unexpected_exception_pattern (Printexc.to_string exn)

  let generic_error context message = generic_error_pattern context message

  (** 变量相关错误 *)
  let undefined_variable var_name = undefined_variable_pattern var_name

  let variable_already_defined var_name = variable_already_defined_pattern var_name

  (** 函数相关错误 *)
  let function_not_found func_name = function_not_found_pattern func_name

  let function_param_mismatch func_name expected actual =
    function_param_mismatch_pattern func_name expected actual

  (** 模块相关错误 *)
  let module_not_found mod_name = module_not_found_pattern mod_name

  let member_not_found mod_name member_name = member_not_found_pattern mod_name member_name

  (** 操作错误 *)
  let invalid_operation operation = invalid_operation_pattern operation

  let pattern_match_failure value_type = pattern_match_failure_pattern value_type
end
