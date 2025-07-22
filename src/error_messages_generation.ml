(** 错误消息生成模块 - Error Message Generation Module *)

open Types
open Utils.Base_formatter
module EMT = String_processing_utils.ErrorMessageTemplates
module CF = String_processing_utils.CollectionFormatting

(** 生成详细的类型不匹配错误消息 *)
let type_mismatch_error expected_type actual_type =
  EMT.type_mismatch_error
    (type_to_chinese_string expected_type)
    (type_to_chinese_string actual_type)

(** 生成未定义变量的建议错误消息 *)
let undefined_variable_error var_name available_vars =
  let base_msg = EMT.undefined_variable_error var_name in
  if List.length available_vars = 0 then base_msg ^ "（当前作用域中没有可用变量）"
  else if List.length available_vars <= 5 then
    Unified_formatter.ErrorMessages.variable_suggestion var_name available_vars
  else
    let rec take n lst =
      if n <= 0 then [] else match lst with [] -> [] | h :: t -> h :: take (n - 1) t
    in
    let first_five = take 5 available_vars in
    base_msg ^ concat_strings ["（可用变量包括: "; CF.join_chinese first_five; " 等）"]

(** 生成函数调用参数不匹配的详细错误消息 *)
let function_arity_error expected_count actual_count =
  Unified_formatter.ErrorMessages.function_param_count_mismatch_simple expected_count actual_count

(** 生成模式匹配失败的详细错误消息 *)
let pattern_match_error value_type =
  Unified_formatter.ErrorMessages.pattern_match_failure (type_to_chinese_string value_type)
