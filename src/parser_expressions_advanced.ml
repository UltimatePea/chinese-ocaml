(** 骆言语法分析器高级表达式解析模块 - Advanced Expression Parser (Refactored) *)

(* 重新导出分拆后的模块功能以保持向后兼容性 *)

open Parser_expressions_conditional
open Parser_expressions_match
open Parser_expressions_function
open Parser_expressions_record
open Parser_expressions_exception
open Parser_expressions_postfix
open Parser_expressions_arrays

(* 重新导出所有函数以保持API兼容性 *)
let parse_conditional_expression = parse_conditional_expression
let parse_match_expression = parse_match_expression
let parse_function_expression = parse_function_expression
let parse_labeled_function_expression = parse_labeled_function_expression
let parse_label_param = parse_label_param
let parse_let_expression = parse_let_expression
let parse_array_expression = parse_array_expression
let parse_combine_expression = parse_combine_expression
let parse_record_expression = parse_record_expression
let parse_record_updates = parse_record_updates
let parse_ancient_record_expression = parse_ancient_record_expression
let parse_try_expression = parse_try_expression
let parse_raise_expression = parse_raise_expression
let parse_ref_expression = parse_ref_expression
let parse_postfix_expression = parse_postfix_expression
