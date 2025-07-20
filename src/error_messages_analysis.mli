(** 错误消息智能分析模块接口 - Error Message Analysis Module Interface *)

(** 错误分析类型定义 *)
type error_analysis = {
  error_type : string;
  error_message : string;
  context : string option;
  suggestions : string list;
  fix_hints : string list;
  confidence : float;
}

(** 计算两个字符串之间的Levenshtein编辑距离
    @param s1 第一个字符串
    @param s2 第二个字符串
    @return 编辑距离（整数） *)
val levenshtein_distance : string -> string -> int

(** 根据目标变量名在可用变量列表中寻找相似的变量
    @param target_var 目标变量名
    @param available_vars 可用变量名列表
    @return 相似变量名及其相似度的列表，按相似度降序排列 *)
val find_similar_variables : string -> string list -> (string * float) list

(** 分析未定义变量错误
    @param var_name 未定义的变量名
    @param available_vars 当前作用域中可用的变量名列表
    @return 错误分析结果 *)
val analyze_undefined_variable : string -> string list -> error_analysis

(** 分析类型不匹配错误
    @param expected_type 期望的类型
    @param actual_type 实际的类型
    @return 错误分析结果 *)
val analyze_type_mismatch : string -> string -> error_analysis

(** 分析函数参数数量错误
    @param expected_count 期望的参数数量
    @param actual_count 实际提供的参数数量
    @param function_name 函数名
    @return 错误分析结果 *)
val analyze_function_arity : int -> int -> string -> error_analysis

(** 分析模式匹配错误
    @param missing_patterns 缺失的模式列表
    @return 错误分析结果 *)
val analyze_pattern_match_error : string list -> error_analysis

(** 智能错误分析主函数
    @param error_type 错误类型
    @param error_details 错误详细信息列表
    @param context 错误上下文
    @return 错误分析结果 *)
val intelligent_error_analysis : string -> string list -> string option -> error_analysis