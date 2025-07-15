(** 骆言错误消息模块 - 中文错误消息处理和智能错误分析
    
    此模块提供了将英文错误消息转换为中文、生成详细错误消息、
    智能错误分析和错误建议生成等功能。
*)

(** 将英文类型错误消息转换为中文
    @param msg 英文错误消息
    @return 中文错误消息
*)
val chinese_type_error_message : string -> string

(** 将英文运行时错误消息转换为中文
    @param msg 英文错误消息
    @return 中文错误消息
*)
val chinese_runtime_error_message : string -> string

(** 生成详细的类型不匹配错误消息
    @param expected_type 期望的类型
    @param actual_type 实际的类型
    @return 格式化的类型不匹配错误消息
*)
val type_mismatch_error : Types.typ -> Types.typ -> string

(** 生成未定义变量的建议错误消息
    @param var_name 变量名
    @param available_vars 可用变量列表
    @return 带有建议的错误消息
*)
val undefined_variable_error : string -> string list -> string

(** 生成函数调用参数不匹配的详细错误消息
    @param expected_count 期望的参数数量
    @param actual_count 实际的参数数量
    @return 格式化的参数数量不匹配错误消息
*)
val function_arity_error : int -> int -> string

(** 生成模式匹配失败的详细错误消息
    @param value_type 值的类型
    @return 格式化的模式匹配失败错误消息
*)
val pattern_match_error : Types.typ -> string

(** 智能错误分析结果 *)
type error_analysis = {
  error_type : string;        (** 错误类型 *)
  error_message : string;     (** 错误消息 *)
  context : string option;    (** 错误上下文 *)
  suggestions : string list;  (** 修复建议列表 *)
  fix_hints : string list;    (** 修复提示列表 *)
  confidence : float;         (** AI置信度 (0.0-1.0) *)
}

(** 计算两个字符串之间的莱文斯坦距离（编辑距离）
    @param s1 第一个字符串
    @param s2 第二个字符串
    @return 编辑距离
*)
val levenshtein_distance : string -> string -> int

(** 在可用变量列表中寻找与目标变量相似的变量名
    @param target_var 目标变量名
    @param available_vars 可用变量列表
    @return 相似变量列表，按相似度排序，包含变量名和相似度
*)
val find_similar_variables : string -> string list -> (string * float) list

(** 分析未定义变量错误，提供智能建议
    @param var_name 未定义的变量名
    @param available_vars 当前作用域中可用的变量列表
    @return 错误分析结果
*)
val analyze_undefined_variable : string -> string list -> error_analysis

(** 分析类型不匹配错误，提供智能建议
    @param expected_type 期望的类型（中文字符串）
    @param actual_type 实际的类型（中文字符串）
    @return 错误分析结果
*)
val analyze_type_mismatch : string -> string -> error_analysis

(** 分析函数参数数量不匹配错误
    @param expected_count 期望的参数数量
    @param actual_count 实际的参数数量
    @param function_name 函数名
    @return 错误分析结果
*)
val analyze_function_arity : int -> int -> string -> error_analysis

(** 分析模式匹配错误
    @param missing_patterns 缺少的模式列表
    @return 错误分析结果
*)
val analyze_pattern_match_error : string list -> error_analysis

(** 智能错误分析主函数
    @param error_type 错误类型
    @param error_details 错误详细信息列表
    @param context 错误上下文
    @return 错误分析结果
*)
val intelligent_error_analysis : string -> string list -> string option -> error_analysis

(** 生成智能错误报告
    @param analysis 错误分析结果
    @return 格式化的错误报告字符串
*)
val generate_intelligent_error_report : error_analysis -> string

(** 为给定错误类型生成AI友好的错误建议
    @param error_type 错误类型
    @param _context 错误上下文（当前未使用）
    @return 错误建议字符串
*)
val generate_error_suggestions : string -> string -> string