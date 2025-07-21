(** 骆言语法分析器表达式解析模块 - Chinese Programming Language Parser Expressions

    本模块为表达式解析的主协调器，采用模块化架构设计：
    - 大部分具体解析逻辑已委托给专门的子模块
    - 保持向后兼容的API接口
    - 支持中文编程语言的各种表达式类型

    模块化重构进展（Fix #654）：
    - ✅ 已实现模块化架构，主要功能委托给专门模块
    - ✅ 保持API兼容性
    - ✅ 维持337行，满足技术债务清理目标

    @version 2.0 - 技术债务清理后的模块化版本 *)

open Lexer
open Parser_utils

(** 主表达式解析函数 - 模块化架构的协调器 *)
let rec parse_expression state =
  (* 首先检查特殊的表达式关键字 *)
  let token, _ = current_token state in
  match token with
  | HaveKeyword -> Parser_ancient.parse_wenyan_let_expression parse_expression state
  | SetKeyword -> Parser_ancient.parse_wenyan_simple_let_expression parse_expression state
  | IfKeyword -> parse_conditional_expression state
  | IfWenyanKeyword -> Parser_ancient.parse_ancient_conditional_expression parse_expression state
  | MatchKeyword -> parse_match_expression state
  | AncientObserveKeyword ->
      Parser_ancient.parse_ancient_match_expression parse_expression Parser_patterns.parse_pattern
        state
  | FunKeyword -> parse_function_expression state
  | LetKeyword -> parse_let_expression state
  | TryKeyword -> parse_try_expression state
  | RaiseKeyword -> parse_raise_expression state
  | RefKeyword -> parse_ref_expression state
  | CombineKeyword -> parse_combine_expression state
  | _ -> parse_assignment_expression state

(** 解析赋值表达式 *)
and parse_assignment_expression state =
  Parser_expressions_basic.parse_assignment_expression parse_expression parse_or_else_expression
    state

(** 解析否则返回表达式 *)
and parse_or_else_expression state =
  Parser_expressions_core.parse_or_else_expression parse_or_expression state

(** 解析逻辑或表达式 *)
and parse_or_expression state =
  Parser_expressions_core.parse_or_expression parse_and_expression state

(** 解析逻辑与表达式 *)
and parse_and_expression state =
  Parser_expressions_core.parse_and_expression parse_comparison_expression state

(** 解析比较表达式 *)
and parse_comparison_expression state =
  Parser_expressions_core.parse_comparison_expression parse_arithmetic_expression state

(** 解析算术表达式 *)
and parse_arithmetic_expression state =
  Parser_expressions_arithmetic.parse_arithmetic_expression parse_expression state

(** 解析乘除表达式 *)
and parse_multiplicative_expression state =
  Parser_expressions_arithmetic.parse_multiplicative_expression parse_expression state

(** 解析一元表达式 *)
and parse_unary_expression state =
  Parser_expressions_basic.parse_unary_expression parse_unary_expression parse_primary_expression
    state

(** 解析基础表达式 *)

(** 解析字面量表达式（整数、浮点数、字符串、布尔值） *)
and parse_literal_expressions state =
  Parser_expressions_basic.parse_literal_expressions parse_function_call_or_variable state

(** 解析类型关键字表达式（在表达式上下文中作为标识符处理） *)
and parse_type_keyword_expressions state =
  Parser_expressions_type_keywords.parse_type_keyword_expressions parse_function_call_or_variable
    state

(** 解析复合表达式（数组、记录、模块等） *)
and parse_compound_expressions state =
  Parser_expressions_basic.parse_compound_expressions parse_expression
    parse_function_call_or_variable parse_postfix_expression parse_array_expression
    parse_record_expression parse_combine_expression parse_module_expression state

(** 解析关键字表达式（标签、数值等特殊关键字） *)
and parse_keyword_expressions state =
  Parser_expressions_basic.parse_keyword_expressions parse_expression
    parse_function_call_or_variable parse_primary_expression state

(** 解析古典诗词表达式 *)
and parse_poetry_expressions state = Parser_expressions_basic.parse_poetry_expressions state

(** 重构后的主表达式解析函数 - 分派到各个专门的解析函数 *)
and parse_primary_expression state =
  let token, pos = current_token state in
  try
    match token with
    (* 字面量表达式 *)
    | IntToken _ | ChineseNumberToken _ | FloatToken _ | StringToken _ | BoolToken _ ->
        parse_literal_expressions state
    (* 类型关键字表达式 *)
    | IntTypeKeyword | FloatTypeKeyword | StringTypeKeyword | BoolTypeKeyword | UnitTypeKeyword
    | ListTypeKeyword | ArrayTypeKeyword ->
        parse_type_keyword_expressions state
    (* 复合表达式 *)
    | QuotedIdentifierToken _ | LeftParen | ChineseLeftParen | LeftArray | ChineseLeftArray
    | LeftBrace | ModuleKeyword | CombineKeyword | LeftBracket | ChineseLeftBracket ->
        parse_compound_expressions state
    (* 关键字表达式 *)
    | TagKeyword | NumberKeyword | OneKeyword | DefineKeyword | AncientDefineKeyword
    | AncientObserveKeyword | AncientListStartKeyword | EmptyKeyword | TypeKeyword | ThenKeyword
    | ElseKeyword | WithKeyword | TrueKeyword | FalseKeyword | AndKeyword | OrKeyword | NotKeyword
    | ValueKeyword ->
        parse_keyword_expressions state
    (* 古典诗词表达式 *)
    | ParallelStructKeyword | FiveCharKeyword | SevenCharKeyword -> parse_poetry_expressions state
    | _ -> raise (Parser_utils.make_unexpected_token_error (show_token token) pos)
  with Failure _ -> raise (Parser_utils.make_unexpected_token_error (show_token token) pos)

(** 解析后缀表达式 *)
and parse_postfix_expression expr state =
  Parser_expressions_postfix.parse_postfix_expression parse_expression expr state

(** 解析条件表达式 *)
and parse_conditional_expression state =
  Parser_expressions_structured_consolidated.parse_conditional_expression parse_expression state

(** 解析匹配表达式 *)
and parse_match_expression state =
  Parser_expressions_structured_consolidated.parse_match_expression parse_expression state

(** 解析函数表达式 *)
and parse_function_expression state =
  Parser_expressions_structured_consolidated.parse_function_expression parse_expression state

(** 解析标签函数表达式 *)
and parse_labeled_function_expression state =
  Parser_expressions_structured_consolidated.parse_function_expression parse_expression state

(** 解析让表达式 *)
and parse_let_expression state =
  Parser_expressions_structured_consolidated.parse_let_expression parse_expression state

(** 解析数组表达式 *)
and parse_array_expression state =
  Parser_expressions_structured_consolidated.parse_array_expression parse_expression state

(** 解析记录表达式 *)
and parse_record_expression state =
  Parser_expressions_structured_consolidated.parse_record_expression parse_expression state

(** 解析古雅体记录表达式 *)
and parse_ancient_record_expression state =
  Parser_expressions_structured_consolidated.parse_record_expression parse_expression state

(** 解析组合表达式 *)
and parse_combine_expression state =
  Parser_expressions_structured_consolidated.parse_combine_expression parse_expression state

(** 解析try表达式 *)
and parse_try_expression state =
  Parser_expressions_structured_consolidated.parse_try_expression parse_expression state

(** 解析raise表达式 *)
and parse_raise_expression state =
  Parser_expressions_structured_consolidated.parse_raise_expression parse_expression state

(** 解析ref表达式 *)
and parse_ref_expression state =
  Parser_expressions_structured_consolidated.parse_ref_expression parse_expression state

(* 已移除未使用的函数包装器 - 这些函数已在 parser_expressions_calls.ml 中实现 *)

(** 解析函数调用或变量 *)

(** 解析函数调用或变量引用的主入口函数 *)
and parse_function_call_or_variable name state =
  Parser_expressions_consolidated.parse_function_call_or_variable name state

(** 解析标签参数 *)
and parse_label_param state = Parser_expressions_consolidated.parse_label_param state

(** 解析标签参数列表 *)
and parse_label_arg_list arg_list state =
  Parser_expressions_consolidated.parse_label_arg_list parse_primary_expression arg_list state

(** 解析单个标签参数 *)
and parse_label_arg state = Parser_expressions_consolidated.parse_label_arg parse_primary_expression state

(** 解析记录更新字段 *)
and parse_record_updates state =
  Parser_expressions_structured_consolidated.parse_record_updates parse_expression state

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
