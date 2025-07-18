(** 骆言语法分析器表达式解析模块 - Chinese Programming Language Parser Expressions *)

open Ast
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
  let left_expr, state1 = parse_or_else_expression state in
  let token, _ = current_token state1 in
  if token = RefAssign then
    let state2 = advance_parser state1 in
    let right_expr, state3 = parse_expression state2 in
    (AssignExpr (left_expr, right_expr), state3)
  else (left_expr, state1)

(** 解析否则返回表达式 *)
and parse_or_else_expression state =
  let rec parse_tail left_expr state =
    let token, _ = current_token state in
    if token = OrElseKeyword then
      let state1 = advance_parser state in
      let right_expr, state2 = parse_or_expression state1 in
      let new_expr = OrElseExpr (left_expr, right_expr) in
      parse_tail new_expr state2
    else (left_expr, state)
  in
  let expr, state1 = parse_or_expression state in
  parse_tail expr state1

(** 解析逻辑或表达式 *)
and parse_or_expression state =
  let rec parse_tail left_expr state =
    let token, _ = current_token state in
    match Parser_utils.token_to_binary_op token with
    | Some Or ->
        let state1 = advance_parser state in
        let right_expr, state2 = parse_and_expression state1 in
        let new_expr = BinaryOpExpr (left_expr, Or, right_expr) in
        parse_tail new_expr state2
    | _ -> (left_expr, state)
  in
  let expr, state1 = parse_and_expression state in
  parse_tail expr state1

(** 解析逻辑与表达式 *)
and parse_and_expression state =
  let rec parse_tail left_expr state =
    let token, _ = current_token state in
    match Parser_utils.token_to_binary_op token with
    | Some And ->
        let state1 = advance_parser state in
        let right_expr, state2 = parse_comparison_expression state1 in
        let new_expr = BinaryOpExpr (left_expr, And, right_expr) in
        parse_tail new_expr state2
    | _ -> (left_expr, state)
  in
  let expr, state1 = parse_comparison_expression state in
  parse_tail expr state1

(** 解析比较表达式 *)
and parse_comparison_expression state =
  let rec parse_tail left_expr state =
    let token, _ = current_token state in
    match Parser_utils.token_to_binary_op token with
    | Some ((Eq | Neq | Lt | Le | Gt | Ge) as op) ->
        let state1 = advance_parser state in
        let right_expr, state2 = parse_arithmetic_expression state1 in
        let new_expr = BinaryOpExpr (left_expr, op, right_expr) in
        parse_tail new_expr state2
    | _ -> (left_expr, state)
  in
  let expr, state1 = parse_arithmetic_expression state in
  parse_tail expr state1

(** 解析算术表达式 *)
and parse_arithmetic_expression state =
  Parser_expressions_arithmetic.parse_arithmetic_expression parse_expression state

(** 解析乘除表达式 *)
and parse_multiplicative_expression state =
  Parser_expressions_arithmetic.parse_multiplicative_expression parse_expression state

(** 解析一元表达式 *)
and parse_unary_expression state =
  let token, _pos = current_token state in
  match token with
  | Minus ->
      let state1 = advance_parser state in
      let expr, state2 = parse_unary_expression state1 in
      (UnaryOpExpr (Neg, expr), state2)
  | NotKeyword ->
      let state1 = advance_parser state in
      let expr, state2 = parse_unary_expression state1 in
      (UnaryOpExpr (Not, expr), state2)
  | Bang ->
      let state1 = advance_parser state in
      let expr, state2 = parse_unary_expression state1 in
      (DerefExpr expr, state2)
  | _ -> parse_primary_expression state

(** 解析基础表达式 *)
(** 解析字面量表达式（整数、浮点数、字符串、布尔值） *)
and parse_literal_expressions state =
  let token, _ = current_token state in
  match token with
  | IntToken _ | ChineseNumberToken _ | FloatToken _ | StringToken _ ->
      let literal, state1 = parse_literal state in
      (LitExpr literal, state1)
  | BoolToken _ -> (
      (* 检查是否是复合标识符的开始（如"真值"、"假值"） *)
      let token_after, _ = peek_token state in
      match token_after with
      | QuotedIdentifierToken _ ->
          (* 可能是复合标识符，使用parse_identifier_allow_keywords解析 *)
          let name, state1 = parse_identifier_allow_keywords state in
          parse_function_call_or_variable name state1
      | _ ->
          (* 解析为布尔字面量 *)
          let literal, state1 = parse_literal state in
          (LitExpr literal, state1))
  | _ -> failwith "Not a literal token"

(** 解析类型关键字表达式（在表达式上下文中作为标识符处理） *)
and parse_type_keyword_expressions state =
  let token, _ = current_token state in
  match token with
  | IntTypeKeyword ->
      let state1 = advance_parser state in
      parse_function_call_or_variable "整数" state1
  | FloatTypeKeyword ->
      let state1 = advance_parser state in
      parse_function_call_or_variable "浮点数" state1
  | StringTypeKeyword ->
      let state1 = advance_parser state in
      parse_function_call_or_variable "字符串" state1
  | BoolTypeKeyword ->
      let state1 = advance_parser state in
      parse_function_call_or_variable "布尔" state1
  | UnitTypeKeyword ->
      let state1 = advance_parser state in
      parse_function_call_or_variable "单元" state1
  | ListTypeKeyword ->
      let state1 = advance_parser state in
      parse_function_call_or_variable "列表" state1
  | ArrayTypeKeyword ->
      let state1 = advance_parser state in
      parse_function_call_or_variable "数组" state1
  | _ -> failwith "Not a type keyword token"

(** 解析复合表达式（数组、记录、模块等） *)
and parse_compound_expressions state =
  let token, _pos = current_token state in
  match token with
  | QuotedIdentifierToken name ->
      let state1 = advance_parser state in
      (* Check if this looks like a string literal rather than a variable name *)
      if Parser_expressions_utils.looks_like_string_literal name then
        (LitExpr (StringLit name), state1)
      else parse_function_call_or_variable name state1
  | LeftParen | ChineseLeftParen ->
      let state1 = advance_parser state in
      let expr, state2 = parse_expression state1 in
      let state3 = expect_token_punctuation state2 is_right_paren "right parenthesis" in
      parse_postfix_expression expr state3
  | LeftArray | ChineseLeftArray -> parse_array_expression state
  | LeftBrace ->
      let record_expr, state1 = parse_record_expression state in
      parse_postfix_expression record_expr state1
  | ModuleKeyword -> parse_module_expression state
  | CombineKeyword -> parse_combine_expression state
  | LeftBracket | ChineseLeftBracket ->
      (* 禁用现代列表语法，提示使用古雅体语法 *)
      raise
        (SyntaxError
           ( "请使用古雅体列表语法替代 [...]。\n" ^ "空列表：空空如也\n" ^ "有元素的列表：列开始 元素1 其一 元素2 其二 元素3 其三 列结束\n"
             ^ "模式匹配：有首有尾 首名为「变量名」尾名为「尾部变量名」",
             snd (current_token state) ))
  | _ -> failwith "Not a compound expression token"

(** 解析关键字表达式（标签、数值等特殊关键字） *)
and parse_keyword_expressions state =
  let token, _ = current_token state in
  match token with
  | TagKeyword ->
      (* 多态变体表达式: 标签 「标签名」 [值] *)
      let state1 = advance_parser state in
      let tag_name, state2 = parse_identifier state1 in
      let token, _ = current_token state2 in
      if is_identifier_like token then
        (* 有值的多态变体: 标签 「标签名」 值 *)
        let value_expr, state3 = parse_primary_expression state2 in
        (PolymorphicVariantExpr (tag_name, Some value_expr), state3)
      else
        (* 无值的多态变体: 标签 「标签名」 *)
        (PolymorphicVariantExpr (tag_name, None), state2)
  | NumberKeyword ->
      (* 尝试解析wenyan复合标识符，如"数值" *)
      let name, state1 = parse_wenyan_compound_identifier state in
      parse_function_call_or_variable name state1
  | OneKeyword ->
      (* 将"一"关键字转换为数字字面量1 *)
      let state1 = advance_parser state in
      (LitExpr (IntLit 1), state1)
  | DefineKeyword ->
      (* 调用主解析器中的自然语言函数定义解析 *)
      let _token, pos = current_token state in
      raise (Types.ParseError ("DefineKeyword应由主解析器处理", pos.line, pos.column))
  | AncientDefineKeyword -> Parser_ancient.parse_ancient_function_definition parse_expression state
  | AncientObserveKeyword ->
      Parser_ancient.parse_ancient_match_expression parse_expression Parser_patterns.parse_pattern state
  | AncientListStartKeyword -> Parser_ancient.parse_ancient_list_expression parse_expression state
  | EmptyKeyword | TypeKeyword | ThenKeyword | ElseKeyword | WithKeyword | TrueKeyword
  | FalseKeyword | AndKeyword | OrKeyword | NotKeyword | ValueKeyword ->
      (* Handle keywords that might be part of compound identifiers *)
      let name, state1 = parse_identifier_allow_keywords state in
      parse_function_call_or_variable name state1
  | _ -> failwith "Not a keyword expression token"

(** 解析古典诗词表达式 *)
and parse_poetry_expressions state =
  let token, _ = current_token state in
  match token with
  | ParallelStructKeyword | FiveCharKeyword | SevenCharKeyword ->
      Parser_poetry.parse_poetry_expression state
  | _ -> failwith "Not a poetry expression token"

(** 重构后的主表达式解析函数 - 分派到各个专门的解析函数 *)
and parse_primary_expression state =
  let token, pos = current_token state in
  try
    match token with
    (* 字面量表达式 *)
    | IntToken _ | ChineseNumberToken _ | FloatToken _ | StringToken _ | BoolToken _ ->
        parse_literal_expressions state
    (* 类型关键字表达式 *)
    | IntTypeKeyword | FloatTypeKeyword | StringTypeKeyword | BoolTypeKeyword 
    | UnitTypeKeyword | ListTypeKeyword | ArrayTypeKeyword ->
        parse_type_keyword_expressions state
    (* 复合表达式 *)
    | QuotedIdentifierToken _ | LeftParen | ChineseLeftParen | LeftArray | ChineseLeftArray 
    | LeftBrace | ModuleKeyword | CombineKeyword | LeftBracket | ChineseLeftBracket ->
        parse_compound_expressions state
    (* 关键字表达式 *)
    | TagKeyword | NumberKeyword | OneKeyword | DefineKeyword | AncientDefineKeyword 
    | AncientObserveKeyword | AncientListStartKeyword | EmptyKeyword | TypeKeyword 
    | ThenKeyword | ElseKeyword | WithKeyword | TrueKeyword | FalseKeyword 
    | AndKeyword | OrKeyword | NotKeyword | ValueKeyword ->
        parse_keyword_expressions state
    (* 古典诗词表达式 *)
    | ParallelStructKeyword | FiveCharKeyword | SevenCharKeyword ->
        parse_poetry_expressions state
    | _ -> raise (SyntaxError ("意外的词元: " ^ show_token token, pos))
  with
  | Failure _ -> raise (SyntaxError ("意外的词元: " ^ show_token token, pos))

(** 解析后缀表达式 *)
and parse_postfix_expression expr state =
  let token, _ = current_token state in
  match token with
  | Dot -> (
      let state1 = advance_parser state in
      let token2, _ = current_token state1 in
      match token2 with
      | LeftParen -> (
          (* 数组访问 expr.(index) *)
          let state2 = advance_parser state1 in
          let index_expr, state3 = parse_expression state2 in
          let state4 = expect_token state3 RightParen in
          (* 检查是否是数组更新 *)
          let token3, _ = current_token state4 in
          match token3 with
          | AssignArrow ->
              (* 数组更新 expr.(index) <- value *)
              let state5 = advance_parser state4 in
              let value_expr, state6 = parse_expression state5 in
              (ArrayUpdateExpr (expr, index_expr, value_expr), state6)
          | _ ->
              (* 只是数组访问 *)
              let new_expr = ArrayAccessExpr (expr, index_expr) in
              parse_postfix_expression new_expr state4)
      | QuotedIdentifierToken field_name ->
          (* 记录字段访问 expr.field *)
          let state2 = advance_parser state1 in
          let new_expr = FieldAccessExpr (expr, field_name) in
          parse_postfix_expression new_expr state2
      | _ -> raise (SyntaxError ("期望字段名或左括号", snd (current_token state1))))
  | LeftBracket | ChineseLeftBracket ->
      (* 数组索引 *)
      let state1 = advance_parser state in
      let index_expr, state2 = parse_expression state1 in
      let state3 = expect_token_punctuation state2 is_right_bracket "right bracket" in
      let new_expr = ArrayAccessExpr (expr, index_expr) in
      parse_postfix_expression new_expr state3
  | _ -> (expr, state)

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
(** 解析带标签的函数调用 *)
and parse_labeled_function_call name state =
  let label_args, state1 = parse_label_arg_list [] state in
  let expr = LabeledFunCallExpr (VarExpr name, label_args) in
  parse_postfix_expression expr state1

(** 解析括号内的函数参数列表 *)
and parse_parenthesized_function_args state =
  let parse_function_args acc state =
    let token, _ = current_token state in
    if token = RightParen || token = ChineseRightParen then
      let state_after_paren = advance_parser state in
      (List.rev acc, state_after_paren)
    else
      let arg, state_after_arg = parse_expression state in
      let rec parse_more_args acc state =
        let token, _ = current_token state in
        if token = RightParen || token = ChineseRightParen then
          let state_after_paren = advance_parser state in
          (List.rev acc, state_after_paren)
        else if token = Comma || token = ChineseComma then
          let state_after_comma = advance_parser state in
          let next_arg, state_after_next_arg = parse_expression state_after_comma in
          parse_more_args (next_arg :: acc) state_after_next_arg
        else
          raise (SyntaxError ("期望 ')' 或 ','", snd (current_token state)))
      in
      parse_more_args (arg :: acc) state_after_arg
  in
  parse_function_args [] state

(** 解析括号形式的函数调用 *)
and parse_parenthesized_function_call name state =
  let state1 = advance_parser state in
  let args, state2 = parse_parenthesized_function_args state1 in
  let expr = FunCallExpr (VarExpr name, args) in
  parse_postfix_expression expr state2

(** 收集无括号函数调用的参数 *)
and collect_function_arguments state =
  let rec collect_args arg_list state =
    let token, _ = current_token state in
    match token with
    | QuotedIdentifierToken _ | IntToken _ | ChineseNumberToken _ | FloatToken _ | StringToken _
    | BoolToken _ ->
        let arg, state1 = parse_primary_expression state in
        collect_args (arg :: arg_list) state1
    | _ -> (List.rev arg_list, state)
  in
  collect_args [] state

(** 解析无括号形式的函数调用或变量引用 *)
and parse_unparenthesized_function_call_or_variable name state =
  let arg_list, state1 = collect_function_arguments state in
  let expr = if arg_list = [] then VarExpr name else FunCallExpr (VarExpr name, arg_list) in
  parse_postfix_expression expr state1

(** 解析函数调用或变量引用的主入口函数 *)
and parse_function_call_or_variable name state =
  let token, _ = current_token state in
  match token with
  | Tilde -> parse_labeled_function_call name state
  | LeftParen | ChineseLeftParen -> parse_parenthesized_function_call name state
  | _ -> parse_unparenthesized_function_call_or_variable name state

(** 解析标签参数 *)
and parse_label_param state = Parser_expressions_advanced.parse_label_param state

(** 解析标签参数列表 *)
and parse_label_arg_list arg_list state =
  let rec parse_label_arg_list_impl arg_list state =
    let token, _ = current_token state in
    match token with
    | Tilde ->
        let state1 = advance_parser state in
        let label_arg, state2 = parse_label_arg state1 in
        parse_label_arg_list_impl (label_arg :: arg_list) state2
    | _ -> (List.rev arg_list, state)
  in
  parse_label_arg_list_impl arg_list state

(** 解析单个标签参数 *)
and parse_label_arg state =
  let label_name, state1 = parse_identifier state in
  let state2 = expect_token state1 Colon in
  let arg_expr, state3 = parse_primary_expression state2 in
  ({ arg_label = label_name; arg_value = arg_expr }, state3)

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
