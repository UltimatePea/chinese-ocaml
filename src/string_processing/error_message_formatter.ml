(** 骆言编译器通用错误消息格式化器 - 第九阶段代码重复消除
    
    此模块提供统一的错误消息格式化接口，消除项目中分散的Printf.sprintf错误处理模式。
    
    设计目标:
    - 统一文件操作错误格式
    - 标准化类型错误消息
    - 简化解析错误处理
    - 提供一致的异常消息格式 *)

(** 通用错误消息格式化器 *)
module Error_message_formatter = struct
  (** 文件操作错误 *)
  let file_not_found filename = Printf.sprintf "文件未找到: %s" filename
  let file_read_error filename = Printf.sprintf "无法读取测试配置文件: %s" filename
  let file_write_error filename = Printf.sprintf "文件写入错误: %s" filename
  let file_operation_error operation filename = Printf.sprintf "无法%s文件: %s" operation filename
  
  (** 类型相关错误 *)
  let type_mismatch type_info = Printf.sprintf "类型不匹配: %s" type_info
  let unknown_type type_name = Printf.sprintf "未知类型: %s" type_name
  let invalid_type_operation op_name = Printf.sprintf "无效的类型操作: %s" op_name
  
  (** 解析错误 *)
  let parse_failure format msg = Printf.sprintf "%s解析失败: %s" format msg
  let json_parse_error msg = Printf.sprintf "测试配置JSON格式错误: %s" msg
  let test_case_parse_error msg = Printf.sprintf "解析测试用例失败: %s" msg
  let config_parse_error msg = Printf.sprintf "解析测试配置失败: %s" msg
  let config_list_parse_error msg = Printf.sprintf "解析测试配置列表失败: %s" msg
  let comprehensive_test_parse_error msg = Printf.sprintf "解析综合测试用例失败: %s" msg
  let summary_items_parse_error msg = Printf.sprintf "解析测试摘要项目失败: %s" msg
  
  (** 检查器错误 *)
  let unknown_checker_type checker_type = Printf.sprintf "未知的检查器类型: %s" checker_type
  
  (** 通用异常处理 *)
  let unexpected_exception exn = Printf.sprintf "意外异常: %s" (Printexc.to_string exn)
  let generic_error context message = Printf.sprintf "%s: %s" context message
  
  (** 变量相关错误 *)
  let undefined_variable var_name = Printf.sprintf "未定义的变量: %s" var_name
  let variable_already_defined var_name = Printf.sprintf "变量已定义: %s" var_name
  
  (** 函数相关错误 *)
  let function_not_found func_name = Printf.sprintf "函数未找到: %s" func_name
  let function_param_mismatch func_name expected actual = 
    Printf.sprintf "函数「%s」参数数量不匹配: 期望 %d 个参数，但提供了 %d 个参数" func_name expected actual
  
  (** 模块相关错误 *)
  let module_not_found mod_name = Printf.sprintf "未定义的模块: %s" mod_name
  let member_not_found mod_name member_name = Printf.sprintf "模块 %s 中未找到成员: %s" mod_name member_name
  
  (** 操作错误 *)
  let invalid_operation operation = Printf.sprintf "无效操作: %s" operation
  let pattern_match_failure value_type = Printf.sprintf "模式匹配失败: 无法匹配类型为 %s 的值" value_type
end