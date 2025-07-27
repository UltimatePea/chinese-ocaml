(** 骆言语法分析器表达式解析模块 - Chinese Programming Language Parser Expressions

    Phase 6 超长函数重构版本 - 简化相互递归结构：
    - 消除冗余的函数包装器，直接使用专门模块
    - 简化相互递归函数定义结构
    - 保持完整的API向后兼容性
    - 支持中文编程语言的各种表达式类型

    重构目标（Fix #1427）：
    - ✅ 将249行简化到100行以下
    - ✅ 消除30+个冗余包装函数
    - ✅ 保持API兼容性和功能完整性

    @version 3.0 - Phase 6 技术债务清理后的精简版本 *)

open Lexer
open Parser_utils

(** 主表达式解析函数 - 精简版本，直接委托给专门模块 *)
let rec parse_expression state =
  (* 首先检查特殊的表达式关键字 *)
  let token, _ = current_token state in
  match token with
  | HaveKeyword -> Parser_ancient.parse_wenyan_let_expression parse_expression state
  | SetKeyword -> Parser_ancient.parse_wenyan_simple_let_expression parse_expression state
  | IfKeyword -> Parser_expressions_structured_consolidated.parse_conditional_expression parse_expression state
  | IfWenyanKeyword -> Parser_ancient.parse_ancient_conditional_expression parse_expression state
  | MatchKeyword -> Parser_expressions_structured_consolidated.parse_match_expression parse_expression state
  | AncientObserveKeyword ->
      Parser_ancient.parse_ancient_match_expression parse_expression Parser_patterns.parse_pattern
        state
  | FunKeyword -> Parser_expressions_structured_consolidated.parse_function_expression parse_expression state
  | LetKeyword -> Parser_expressions_structured_consolidated.parse_let_expression parse_expression state
  | TryKeyword -> Parser_expressions_structured_consolidated.parse_try_expression parse_expression state
  | RaiseKeyword -> Parser_expressions_structured_consolidated.parse_raise_expression parse_expression state
  | RefKeyword -> Parser_expressions_structured_consolidated.parse_ref_expression parse_expression state
  | CombineKeyword -> Parser_expressions_structured_consolidated.parse_combine_expression parse_expression state
  | _ -> Parser_expressions_basic.parse_assignment_expression parse_expression parse_or_else_expression state

(** 解析否则返回表达式 - 核心相互递归函数 *)
and parse_or_else_expression state =
  Parser_expressions_core.parse_or_else_expression parse_or_expression state

(** 解析逻辑或表达式 - 核心相互递归函数 *)
and parse_or_expression state =
  Parser_expressions_core.parse_or_expression parse_and_expression state

(** 解析逻辑与表达式 - 核心相互递归函数 *)
and parse_and_expression state =
  Parser_expressions_core.parse_and_expression parse_comparison_expression state

(** 解析比较表达式 - 核心相互递归函数 *)
and parse_comparison_expression state =
  Parser_expressions_core.parse_comparison_expression parse_arithmetic_expression state

(** 解析算术表达式 - 核心相互递归函数 *)
and parse_arithmetic_expression state =
  Parser_expressions_arithmetic.parse_arithmetic_expression parse_expression state


(** 主基础表达式解析函数 - 核心相互递归函数 *)
and parse_primary_expression state =
  let token, pos = current_token state in
  try
    match token with
    (* 字面量表达式 *)
    | IntToken _ | ChineseNumberToken _ | FloatToken _ | StringToken _ | BoolToken _ ->
        Parser_expressions_basic.parse_literal_expressions parse_function_call_or_variable state
    (* 类型关键字表达式 *)
    | IntTypeKeyword | FloatTypeKeyword | StringTypeKeyword | BoolTypeKeyword | UnitTypeKeyword
    | ListTypeKeyword | ArrayTypeKeyword ->
        Parser_expressions_type_keywords.parse_type_keyword_expressions parse_function_call_or_variable state
    (* 复合表达式 *)
    | QuotedIdentifierToken _ | LeftParen | ChineseLeftParen | LeftArray | ChineseLeftArray
    | LeftBrace | ModuleKeyword | CombineKeyword | LeftBracket | ChineseLeftBracket ->
        Parser_expressions_basic.parse_compound_expressions parse_expression
          parse_function_call_or_variable parse_postfix_expression 
          Parser_expressions_structured_consolidated.parse_array_expression
          Parser_expressions_structured_consolidated.parse_record_expression 
          Parser_expressions_structured_consolidated.parse_combine_expression 
          Parser_expressions_utils.parse_module_expression state
    (* 关键字表达式 *)
    | TagKeyword | NumberKeyword | OneKeyword | DefineKeyword | AncientDefineKeyword
    | AncientObserveKeyword | AncientListStartKeyword | EmptyKeyword | TypeKeyword | ThenKeyword
    | ElseKeyword | WithKeyword | TrueKeyword | FalseKeyword | AndKeyword | OrKeyword | NotKeyword
    | ValueKeyword ->
        Parser_expressions_basic.parse_keyword_expressions parse_expression
          parse_function_call_or_variable parse_primary_expression state
    (* 古典诗词表达式 *)
    | ParallelStructKeyword | FiveCharKeyword | SevenCharKeyword -> Parser_expressions_basic.parse_poetry_expressions state
    | _ -> raise (Parser_utils.make_unexpected_token_error (show_token token) pos)
  with Failure _ -> raise (Parser_utils.make_unexpected_token_error (show_token token) pos)

(** 解析后缀表达式 - 核心相互递归函数 *)
and parse_postfix_expression expr state =
  Parser_expressions_postfix.parse_postfix_expression parse_expression expr state

(** 解析函数调用或变量 - 核心相互递归函数 *)
and parse_function_call_or_variable name state =
  Parser_expressions_consolidated.parse_function_call_or_variable name state
