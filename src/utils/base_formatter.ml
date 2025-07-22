(** 骆言编译器底层格式化基础设施
    
    此模块提供不依赖Printf.sprintf的基础字符串格式化工具，
    解决项目中Printf.sprintf重复使用导致的架构设计矛盾问题。
    
    设计原则:
    - 零Printf.sprintf依赖：底层模块不使用Printf.sprintf
    - 高性能字符串操作：使用最优化的字符串拼接
    - 模式化设计：提供常用格式化模式的专用函数
    - 类型安全：提供类型安全的格式化接口
    
    用途：作为所有上层格式化模块的基础设施
*)

(** 基础字符串格式化工具模块 *)
module Base_formatter = struct
  
  (** 基础字符串拼接函数 *)
  let concat_strings parts = String.concat "" parts
  
  (** 带分隔符的字符串拼接 *)
  let join_with_separator sep parts = String.concat sep parts
  
  (** 基础类型转换函数 *)
  let int_to_string = string_of_int
  let float_to_string = string_of_float
  let bool_to_string = string_of_bool
  let char_to_string c = String.make 1 c
  
  (** 常用格式化模式 *)
  
  (** Token模式: TokenType(value) *)
  let token_pattern token_type value = 
    concat_strings [token_type; "("; value; ")"]
  
  (** Token模式: TokenType('char') *)
  let char_token_pattern token_type char = 
    concat_strings [token_type; "('"; char_to_string char; "')"]
  
  (** 错误上下文模式: context: message *)
  let context_message_pattern context message = 
    concat_strings [context; ": "; message]
  
  (** 位置信息模式: filename:line:column *)
  let file_position_pattern filename line column = 
    concat_strings [filename; ":"; int_to_string line; ":"; int_to_string column]
  
  (** 位置信息模式: (line:column): message *)
  let line_col_message_pattern line col message = 
    concat_strings ["("; int_to_string line; ":"; int_to_string col; "): "; message]
  
  (** Token位置模式: token@line:column *)
  let token_position_pattern token line column = 
    concat_strings [token; "@"; int_to_string line; ":"; int_to_string column]
  
  (** 参数计数模式: 期望X个参数，但获得Y个参数 *)
  let param_count_pattern expected actual = 
    concat_strings [
      "期望"; int_to_string expected; "个参数，但获得"; 
      int_to_string actual; "个参数"
    ]
  
  (** 函数名模式: 函数名函数 *)
  let function_name_pattern func_name = 
    concat_strings [func_name; "函数"]
  
  (** 函数错误模式: 函数名函数期望X个参数，但获得Y个参数 *)
  let function_param_error_pattern func_name expected actual = 
    concat_strings [
      func_name; "函数"; param_count_pattern expected actual
    ]
  
  (** 类型期望模式: 期望X参数 *)
  let type_expectation_pattern expected_type = 
    concat_strings ["期望"; expected_type; "参数"]
  
  (** 函数类型错误模式: 函数名函数期望X参数 *)
  let function_type_error_pattern func_name expected_type = 
    concat_strings [func_name; "函数"; type_expectation_pattern expected_type]
  
  (** 类型不匹配模式: 期望 X，但得到 Y *)
  let type_mismatch_pattern expected actual = 
    concat_strings ["期望 "; expected; "，但得到 "; actual]
  
  (** 索引超出范围模式: 索引 X 超出范围，数组长度为 Y *)
  let index_out_of_bounds_pattern index length = 
    concat_strings [
      "索引 "; int_to_string index; " 超出范围，数组长度为 "; int_to_string length
    ]
  
  (** 文件操作错误模式: 无法X文件: Y *)
  let file_operation_error_pattern operation filename = 
    concat_strings ["无法"; operation; "文件: "; filename]
  
  (** C代码生成模式: luoyan_function_name(args) *)
  let luoyan_function_pattern func_name args = 
    concat_strings ["luoyan_"; func_name; "("; args; ")"]
  
  (** C环境绑定模式: luoyan_env_bind(env, "var", expr); *)
  let luoyan_env_bind_pattern var_name expr = 
    concat_strings ["luoyan_env_bind(env, \""; var_name; "\", "; expr; ");"]
  
  (** C代码结构模式: includes + functions + main *)
  let c_code_structure_pattern includes functions main = 
    concat_strings [includes; "\n\n"; functions; "\n\n"; main; "\n"]
  
  (** 统计报告模式: icon category: count 个 *)
  let stat_report_pattern icon category count = 
    concat_strings ["   "; icon; " "; category; ": "; int_to_string count; " 个"]
  
  (** 带换行的统计报告模式 *)
  let stat_report_line_pattern icon category count = 
    concat_strings [stat_report_pattern icon category count; "\n"]
  
  (** 分析消息模式: icon message *)
  let analysis_message_pattern icon message = 
    concat_strings [icon; " "; message]
  
  (** 带换行的分析消息模式 *)
  let analysis_message_line_pattern icon message = 
    concat_strings [analysis_message_pattern icon message; "\n\n"]
  
  (** 性能分析消息模式: 创建了包含X个元素的大型Y *)
  let performance_creation_pattern count item_type = 
    concat_strings ["创建了包含"; int_to_string count; "个元素的大型"; item_type]
  
  (** 性能字段分析模式: 创建了包含X个字段的大型Y *)
  let performance_field_pattern field_count record_type = 
    concat_strings ["创建了包含"; int_to_string field_count; "个字段的大型"; record_type]
  
  (** 诗词字符数不匹配模式: 字符数不匹配：期望X字，实际Y字 *)
  let poetry_char_count_pattern expected actual = 
    concat_strings [
      "字符数不匹配：期望"; int_to_string expected; "字，实际"; int_to_string actual; "字"
    ]
  
  (** 诗词对偶不匹配模式: 对偶字数不匹配：左联X字，右联Y字 *)
  let poetry_couplet_pattern left_count right_count = 
    concat_strings [
      "对偶字数不匹配：左联"; int_to_string left_count; "字，右联"; int_to_string right_count; "字"
    ]
  
  (** 绝句格式模式: 绝句包含X句，通常为4句 *)
  let poetry_quatrain_pattern verse_count = 
    concat_strings ["绝句包含"; int_to_string verse_count; "句，通常为4句"]
  
  (** 列表格式化 - 方括号包围，分号分隔 *)
  let list_format items = 
    concat_strings ["["; join_with_separator "; " items; "]"]
  
  (** 函数调用格式化: FunctionName(arg1, arg2, ...) *)
  let function_call_format func_name args = 
    concat_strings [func_name; "("; join_with_separator ", " args; ")"]
  
  (** 模块访问格式化: Module.member *)
  let module_access_format module_name member_name = 
    concat_strings [module_name; "."; member_name]
  
  (** 高级模板替换函数（用于复杂场景） *)
  let template_replace template replacements = 
    List.fold_left (fun acc (placeholder, value) ->
      Str.global_replace (Str.regexp_string placeholder) value acc
    ) template replacements
end

(** 导出常用函数到顶层，便于使用 *)
include Base_formatter