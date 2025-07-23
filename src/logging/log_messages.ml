(** 骆言日志消息模块 - 包含所有预定义的消息格式 第五阶段Printf.sprintf统一化重构 - 基于Base_formatter *)

(** 内部格式化辅助函数 - 基于Base_formatter统一化 *)
module Internal_formatter = struct
  (* 导入Base_formatter模块以使用统一格式化函数 *)
  open Utils.Base_formatter

  let undefined_variable var_name = undefined_variable_pattern var_name

  let function_param_mismatch func_name expected actual =
    function_param_mismatch_pattern func_name expected actual

  let type_mismatch expected actual = type_mismatch_pattern expected actual
  let file_not_found filename = file_not_found_pattern filename
  let member_not_found mod_name member_name = member_not_found_pattern mod_name member_name
  let compiling_file filename = concat_strings [ "正在编译文件: "; filename ]

  let compilation_complete files_count time_taken =
    concat_strings
      [ "编译完成: "; int_to_string files_count; " 个文件，耗时 "; float_to_string time_taken; " 秒" ]

  let analysis_stats total_functions duplicate_functions =
    concat_strings
      [
        "分析统计: 总函数 ";
        int_to_string total_functions;
        " 个，重复函数 ";
        int_to_string duplicate_functions;
        " 个";
      ]

  let variable_value var_name value = concat_strings [ "变量 "; var_name; " = "; value ]

  let function_call func_name args =
    concat_strings [ "调用函数 "; func_name; "("; String.concat ", " args; ")" ]

  let type_inference expr type_result = concat_strings [ "类型推断: "; expr; " : "; type_result ]
end

(** 错误消息模块 *)
module Error = struct
  let undefined_variable var_name = Internal_formatter.undefined_variable var_name

  let function_arity_mismatch func_name expected actual =
    Internal_formatter.function_param_mismatch func_name expected actual

  let type_mismatch expected actual = Internal_formatter.type_mismatch expected actual
  let file_not_found filename = Internal_formatter.file_not_found filename

  let module_member_not_found mod_name member_name =
    Internal_formatter.member_not_found mod_name member_name
end

(** 编译器消息模块 *)
module Compiler = struct
  let compiling_file filename = Internal_formatter.compiling_file filename

  let compilation_complete files_count time_taken =
    Internal_formatter.compilation_complete files_count time_taken

  let analysis_stats total_functions duplicate_functions =
    Internal_formatter.analysis_stats total_functions duplicate_functions
end

(** 调试消息模块 *)
module Debug = struct
  let variable_value var_name value = Internal_formatter.variable_value var_name value
  let function_call func_name args = Internal_formatter.function_call func_name args
  let type_inference expr type_result = Internal_formatter.type_inference expr type_result
end
