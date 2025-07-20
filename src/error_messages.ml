(** 骆言错误消息模块 - Chinese Programming Language Error Messages *)

(* 模块化的错误消息系统 - 重新导出所有功能以保持API兼容性 *)

(* 重新导出翻译函数 *)
let chinese_type_error_message = Error_messages_translation.chinese_type_error_message
let chinese_runtime_error_message = Error_messages_translation.chinese_runtime_error_message

(* 重新导出生成函数 *)
let type_mismatch_error = Error_messages_generation.type_mismatch_error
let undefined_variable_error = Error_messages_generation.undefined_variable_error
let function_arity_error = Error_messages_generation.function_arity_error
let pattern_match_error = Error_messages_generation.pattern_match_error

(* 重新导出分析类型和函数 *)
type error_analysis = Error_messages_analysis.error_analysis = {
  error_type : string;
  error_message : string;
  context : string option;
  suggestions : string list;
  fix_hints : string list;
  confidence : float;
}

let levenshtein_distance = Error_messages_analysis.levenshtein_distance
let find_similar_variables = Error_messages_analysis.find_similar_variables
let analyze_undefined_variable = Error_messages_analysis.analyze_undefined_variable
let analyze_type_mismatch = Error_messages_analysis.analyze_type_mismatch
let analyze_function_arity = Error_messages_analysis.analyze_function_arity
let analyze_pattern_match_error = Error_messages_analysis.analyze_pattern_match_error
let intelligent_error_analysis = Error_messages_analysis.intelligent_error_analysis

(* 重新导出报告函数 *)
let generate_intelligent_error_report = Error_messages_reporting.generate_intelligent_error_report
let generate_error_suggestions = Error_messages_reporting.generate_error_suggestions