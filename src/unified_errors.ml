(** 骆言统一错误处理系统 - 主入口模块（重构版） *)

(* 重新导出错误类型，保持向后兼容 *)
include Error_types

(* 重新导出转换函数 *)
let unified_error_to_string = Error_conversion.unified_error_to_string
let unified_error_to_exception = Error_conversion.unified_error_to_exception

(* 重新导出工具函数 *)
let result_to_value = Unified_error_utils.result_to_value
let create_eval_position = Unified_error_utils.create_eval_position
let safe_execute = Unified_error_utils.safe_execute
let result_to_unified_result = Unified_error_utils.result_to_unified_result
let ( >>= ) = Unified_error_utils.( >>= )
let map_error = Unified_error_utils.map_error
let with_default = Unified_error_utils.with_default
let log_error = Unified_error_utils.log_error

(* 重新导出便捷创建函数 *)
let create_lexical_error = Unified_error_utils.create_lexical_error
let create_parse_error = Unified_error_utils.create_parse_error
let create_runtime_error = Unified_error_utils.create_runtime_error
let create_poetry_error = Unified_error_utils.create_poetry_error
let create_system_error = Unified_error_utils.create_system_error

let invalid_character_error = Unified_error_utils.invalid_character_error
let unterminated_quoted_identifier_error = Unified_error_utils.unterminated_quoted_identifier_error
let invalid_type_keyword_error = Unified_error_utils.invalid_type_keyword_error
let arithmetic_error = Unified_error_utils.arithmetic_error
let rhyme_data_error = Unified_error_utils.rhyme_data_error
let json_parse_error = Unified_error_utils.json_parse_error
let file_load_error = Unified_error_utils.file_load_error
let parallelism_error = Unified_error_utils.parallelism_error

let error_to_result = Unified_error_utils.error_to_result
let safe_failwith_to_error = Unified_error_utils.safe_failwith_to_error