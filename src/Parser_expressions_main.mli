(** 骆言语法分析器表达式解析主模块接口 - Main Expression Parser Interface *)

open Parser_utils

val parse_expression : parser_state -> Ast.expr * parser_state
(** 主表达式解析函数 - 使用模块化的解析器 *)

val parse_assignment_expression : parser_state -> Ast.expr * parser_state
(** 解析赋值表达式 *)

val parse_or_else_expression : parser_state -> Ast.expr * parser_state
(** 解析否则返回表达式 *)

val parse_or_expression : parser_state -> Ast.expr * parser_state
(** 解析逻辑或表达式 *)

val parse_and_expression : parser_state -> Ast.expr * parser_state
(** 解析逻辑与表达式 *)

val parse_comparison_expression : parser_state -> Ast.expr * parser_state
(** 解析比较表达式 *)

val parse_arithmetic_expression : parser_state -> Ast.expr * parser_state
(** 解析算术表达式 *)

val parse_multiplicative_expression : parser_state -> Ast.expr * parser_state
(** 解析乘除表达式 *)

val parse_unary_expression : parser_state -> Ast.expr * parser_state
(** 解析一元表达式 *)

val parse_primary_expression : parser_state -> Ast.expr * parser_state
(** 解析基础表达式 *)

val parse_postfix_expression : Ast.expr -> parser_state -> Ast.expr * parser_state
(** 解析后缀表达式 *)

val parse_conditional_expression : parser_state -> Ast.expr * parser_state
(** 解析条件表达式 *)

val parse_match_expression : parser_state -> Ast.expr * parser_state
(** 解析匹配表达式 *)

val parse_function_expression : parser_state -> Ast.expr * parser_state
(** 解析函数表达式 *)

val parse_labeled_function_expression : parser_state -> Ast.expr * parser_state
(** 解析标签函数表达式 *)

val parse_let_expression : parser_state -> Ast.expr * parser_state
(** 解析让表达式 *)

val parse_array_expression : parser_state -> Ast.expr * parser_state
(** 解析数组表达式 *)

val parse_record_expression : parser_state -> Ast.expr * parser_state
(** 解析记录表达式 *)

val parse_combine_expression : parser_state -> Ast.expr * parser_state
(** 解析组合表达式 *)

val parse_try_expression : parser_state -> Ast.expr * parser_state
(** 解析try表达式 *)

val parse_raise_expression : parser_state -> Ast.expr * parser_state
(** 解析raise表达式 *)

val parse_ref_expression : parser_state -> Ast.expr * parser_state
(** 解析ref表达式 *)

val parse_function_call_or_variable : string -> parser_state -> Ast.expr * parser_state
(** 解析函数调用或变量 *)

val parse_label_param : parser_state -> Ast.label_param * parser_state
(** 解析标签参数 *)

val parse_label_arg_list : Ast.label_arg list -> parser_state -> Ast.label_arg list * parser_state
(** 解析标签参数列表 *)

val parse_label_arg : parser_state -> Ast.label_arg * parser_state
(** 解析单个标签参数 *)

val parse_record_updates : parser_state -> (string * Ast.expr) list * parser_state
(** 解析记录更新字段 *)

val parse_natural_function_definition : parser_state -> Ast.expr * parser_state
(** 自然语言函数定义解析 *)

val parse_natural_function_body : string -> parser_state -> Ast.expr * parser_state
(** 自然语言函数体解析 *)

val parse_natural_conditional : string -> parser_state -> Ast.expr * parser_state
(** 自然语言条件表达式解析 *)

val parse_natural_expression : string -> parser_state -> Ast.expr * parser_state
(** 自然语言表达式解析 *)

val parse_natural_arithmetic_expression : string -> parser_state -> Ast.expr * parser_state
(** 自然语言算术表达式解析 *)

val parse_natural_arithmetic_tail : Ast.expr -> string -> parser_state -> Ast.expr * parser_state
(** 自然语言算术表达式尾部解析 *)

val parse_natural_primary : string -> parser_state -> Ast.expr * parser_state
(** 自然语言基础表达式解析 *)

val parse_natural_identifier_patterns : string -> string -> parser_state -> Ast.expr * parser_state
(** 自然语言标识符模式解析 *)

val parse_natural_input_patterns : string -> parser_state -> Ast.expr * parser_state
(** 自然语言输入模式解析 *)

val parse_natural_comparison_patterns : string -> parser_state -> Ast.expr * parser_state
(** 自然语言比较模式解析 *)

val parse_natural_arithmetic_continuation :
  Ast.expr -> string -> parser_state -> Ast.expr * parser_state
(** 自然语言算术延续表达式解析 *)

val parse_module_expression : parser_state -> Ast.expr * parser_state
(** 解析模块表达式 *)

val skip_newlines : parser_state -> parser_state
(** 跳过换行符辅助函数 *)
