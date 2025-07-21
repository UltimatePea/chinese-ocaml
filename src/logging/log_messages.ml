(** 骆言日志消息模块 - 包含所有预定义的消息格式 *)

(** 错误消息模块 *)
module Error = struct
  let undefined_variable var_name = Printf.sprintf "未定义的变量: %s" var_name

  let function_arity_mismatch func_name expected actual =
    Printf.sprintf "函数「%s」参数数量不匹配: 期望 %d 个参数，但提供了 %d 个参数" func_name expected actual

  let type_mismatch expected actual = Printf.sprintf "类型不匹配: 期望 %s，但得到 %s" expected actual

  let file_not_found filename = Printf.sprintf "文件未找到: %s" filename

  let module_member_not_found mod_name member_name =
    Printf.sprintf "模块 %s 中未找到成员: %s" mod_name member_name
end

(** 编译器消息模块 *)
module Compiler = struct
  let compiling_file filename = Printf.sprintf "正在编译文件: %s" filename

  let compilation_complete files_count time_taken =
    Printf.sprintf "编译完成: %d 个文件，耗时 %.2f 秒" files_count time_taken

  let analysis_stats total_functions duplicate_functions =
    Printf.sprintf "分析统计: 总函数 %d 个，重复函数 %d 个" total_functions duplicate_functions
end

(** 调试消息模块 *)
module Debug = struct
  let variable_value var_name value = Printf.sprintf "变量 %s = %s" var_name value

  let function_call func_name args =
    Printf.sprintf "调用函数 %s(%s)" func_name (String.concat ", " args)

  let type_inference expr type_result = Printf.sprintf "类型推断: %s : %s" expr type_result
end
