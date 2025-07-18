(** 骆言语法分析器表达式解析主模块 - Main Expression Parser *)

(** 主表达式解析函数 - 使用模块化的解析器 *)
let rec parse_expression state = parse_assignment_expression state

(** 解析赋值表达式 *)
and parse_assignment_expression state =
  Parser_expressions_assignment.parse_assignment_expression parse_expression state

(** 解析否则返回表达式 *)
and parse_or_else_expression state =
  Parser_expressions_assignment.parse_or_else_expression parse_expression state

(** 解析逻辑或表达式 *)
and parse_or_expression state =
  Parser_expressions_assignment.parse_or_expression parse_expression state

(** 解析逻辑与表达式 *)
and parse_and_expression state =
  Parser_expressions_assignment.parse_and_expression parse_expression state

(** 解析比较表达式 *)
and parse_comparison_expression state =
  Parser_expressions_assignment.parse_comparison_expression parse_expression state

(** 解析算术表达式 *)
and parse_arithmetic_expression state =
  Parser_expressions_arithmetic.parse_arithmetic_expression parse_expression state

(** 解析乘除表达式 *)
and parse_multiplicative_expression state =
  Parser_expressions_arithmetic.parse_multiplicative_expression parse_expression state

(** 解析一元表达式 *)
and parse_unary_expression state =
  Parser_expressions_arithmetic.parse_unary_expression parse_expression state

(** 解析基础表达式 *)
and parse_primary_expression state = Parser_expressions_primary.parse_primary_expr state

(** 解析后缀表达式 *)
and parse_postfix_expression expr state =
  Parser_expressions_advanced.parse_postfix_expression parse_expression expr state

(** 解析条件表达式 *)
and parse_conditional_expression state =
  Parser_expressions_advanced.parse_conditional_expression parse_expression state

(** 解析匹配表达式 *)
and parse_match_expression state =
  Parser_expressions_advanced.parse_match_expression parse_expression state

(** 解析函数表达式 *)
and parse_function_expression state =
  Parser_expressions_advanced.parse_function_expression parse_expression state

(** 解析标签函数表达式 *)
and parse_labeled_function_expression state =
  Parser_expressions_advanced.parse_labeled_function_expression parse_expression state

(** 解析让表达式 *)
and parse_let_expression state =
  Parser_expressions_advanced.parse_let_expression parse_expression state

(** 解析数组表达式 *)
and parse_array_expression state =
  Parser_expressions_advanced.parse_array_expression parse_expression state

(** 解析记录表达式 *)
and parse_record_expression state =
  Parser_expressions_advanced.parse_record_expression parse_expression state

(** 解析古雅体记录表达式 *)
and parse_ancient_record_expression state =
  Parser_expressions_advanced.parse_ancient_record_expression parse_expression state

(** 解析组合表达式 *)
and parse_combine_expression state =
  Parser_expressions_advanced.parse_combine_expression parse_expression state

(** 解析try表达式 *)
and parse_try_expression state =
  Parser_expressions_advanced.parse_try_expression parse_expression state

(** 解析raise表达式 *)
and parse_raise_expression state =
  Parser_expressions_advanced.parse_raise_expression parse_expression state

(** 解析ref表达式 *)
and parse_ref_expression state =
  Parser_expressions_advanced.parse_ref_expression parse_expression state

(** 解析函数调用或变量 *)
and parse_function_call_or_variable name state =
  Parser_expressions_primary.parse_function_call_or_variable name state

(** 解析标签参数 *)
and parse_label_param state = Parser_expressions_advanced.parse_label_param state

(** 解析记录更新字段 *)
and parse_record_updates state =
  Parser_expressions_advanced.parse_record_updates parse_expression state

(** 自然语言函数定义解析 *)
and parse_natural_function_definition state =
  Parser_expressions_natural_language.parse_natural_function_definition parse_expression state

(** 自然语言函数体解析 *)
and parse_natural_function_body param_name state =
  Parser_expressions_natural_language.parse_natural_function_body parse_expression param_name state

(** 自然语言条件表达式解析 *)
and parse_natural_conditional param_name state =
  Parser_expressions_natural_language.parse_natural_conditional parse_expression param_name state

(** 自然语言表达式解析 *)
and parse_natural_expression param_name state =
  Parser_expressions_natural_language.parse_natural_expression parse_expression param_name state

(** 自然语言算术表达式解析 *)
and parse_natural_arithmetic_expression param_name state =
  Parser_expressions_natural_language.parse_natural_arithmetic_expression parse_expression
    param_name state

(** 自然语言算术表达式尾部解析 *)
and parse_natural_arithmetic_tail left_expr param_name state =
  Parser_expressions_natural_language.parse_natural_arithmetic_tail parse_expression left_expr
    param_name state

(** 自然语言基础表达式解析 *)
and parse_natural_primary param_name state =
  Parser_expressions_natural_language.parse_natural_primary parse_expression param_name state

(** 自然语言标识符模式解析 *)
and parse_natural_identifier_patterns name param_name state =
  Parser_expressions_natural_language.parse_natural_identifier_patterns parse_expression name
    param_name state

(** 自然语言输入模式解析 *)
and parse_natural_input_patterns param_name state =
  Parser_expressions_natural_language.parse_natural_input_patterns parse_expression param_name state

(** 自然语言比较模式解析 *)
and parse_natural_comparison_patterns param_name state =
  Parser_expressions_natural_language.parse_natural_comparison_patterns parse_expression param_name
    state

(** 自然语言算术延续表达式解析 *)
and parse_natural_arithmetic_continuation expr param_name state =
  Parser_expressions_natural_language.parse_natural_arithmetic_continuation expr param_name state

(** 解析模块表达式 *)
and parse_module_expression state = Parser_expressions_utils.parse_module_expression state

(** 跳过换行符辅助函数 *)
and skip_newlines state = Parser_expressions_utils.skip_newlines state
