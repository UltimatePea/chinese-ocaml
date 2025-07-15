(** 骆言语法分析器表达式解析模块 - Chinese Programming Language Parser Expressions *)

open Ast
open Lexer
open Parser_utils
open Parser_types
open Parser_patterns
open Parser_ancient

(** 初始化模块日志器 *)
let (_log_debug, _log_info, _log_warn, _log_error) = Logger.init_module_logger "Parser_expressions"

(** 检查标识符是否应该被视为字符串字面量 *)
let looks_like_string_literal name =
  (* 如果标识符包含空格或者看起来像自然语言短语，则视为字符串字面量 *)
  String.contains name ' ' || 
  String.contains name ',' ||
  String.contains name '.' ||
  String.contains name '?' ||
  String.contains name '!' ||
  (String.length name > 6 && not (String.contains name '_'))

(** 前向声明 *)
let rec parse_expression state = parse_assignment_expression state

(** 跳过换行符辅助函数 *)
and skip_newlines state =
  let token, _pos = current_token state in
  if token = Newline then skip_newlines (advance_parser state) else state

(** 解析模块表达式 *)
and parse_module_expression state =
  (* 简单实现：假设模块表达式是一个标识符 *)
  let module_name, state1 = parse_identifier state in
  (VarExpr module_name, state1)

(** 解析自然语言算术延续表达式 *)
and parse_natural_arithmetic_continuation expr _param_name state =
  let token_after, _ = current_token state in
  match token_after with
  | OfParticle ->
      (* 「减一」之「阶乘」 *)
      let state1 = advance_parser state in
      let func_name, state2 = parse_identifier state1 in
      (FunCallExpr (VarExpr func_name, [ expr ]), state2)
  | _ -> (expr, state)

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
    match token_to_binary_op token with
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
    match token_to_binary_op token with
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
    match token_to_binary_op token with
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
  let rec parse_tail left_expr state =
    let token, _ = current_token state in
    match token_to_binary_op token with
    | Some ((Add | Sub) as op) ->
        let state1 = advance_parser state in
        let right_expr, state2 = parse_multiplicative_expression state1 in
        let new_expr = BinaryOpExpr (left_expr, op, right_expr) in
        parse_tail new_expr state2
    | _ -> (left_expr, state)
  in
  let expr, state1 = parse_multiplicative_expression state in
  parse_tail expr state1

(** 解析乘除表达式 *)
and parse_multiplicative_expression state =
  let rec parse_tail left_expr state =
    let token, _ = current_token state in
    match token_to_binary_op token with
    | Some ((Mul | Div | Mod) as op) ->
        let state1 = advance_parser state in
        let right_expr, state2 = parse_unary_expression state1 in
        let new_expr = BinaryOpExpr (left_expr, op, right_expr) in
        parse_tail new_expr state2
    | _ -> (left_expr, state)
  in
  let expr, state1 = parse_unary_expression state in
  parse_tail expr state1

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
and parse_primary_expression state =
  let token, pos = current_token state in
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
  | QuotedIdentifierToken name ->
      let state1 = advance_parser state in
      (* Check if this looks like a string literal rather than a variable name *)
      if looks_like_string_literal name then
        (LitExpr (StringLit name), state1)
      else
        parse_function_call_or_variable name state1
  (* 类型关键字在表达式上下文中作为标识符处理（如函数名） *)
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
  | TagKeyword ->
    (* 多态变体表达式: 标签 「标签名」 [值] *)
    let state1 = advance_parser state in
    let (tag_name, state2) = parse_identifier state1 in
    let (token, _) = current_token state2 in
    if is_identifier_like token then
      (* 有值的多态变体: 标签 「标签名」 值 *)
      let (value_expr, state3) = parse_primary_expression state2 in
      (PolymorphicVariantExpr (tag_name, Some value_expr), state3)
    else
      (* 无值的多态变体: 标签 「标签名」 *)
      (PolymorphicVariantExpr (tag_name, None), state2)
  | NumberKeyword ->
      (* 尝试解析wenyan复合标识符，如"数值" *)
      let name, state1 = parse_wenyan_compound_identifier state in
      parse_function_call_or_variable name state1
  | LeftParen | ChineseLeftParen ->
      let state1 = advance_parser state in
      let (expr, state2) = parse_expression state1 in
      (* 检查是否有类型注解 *)
      let (token, _) = current_token state2 in
      if is_double_colon token then
        (* 类型注解表达式 (expr :: type) *)
        let state3 = advance_parser state2 in
        let (type_expr, state4) = parse_type_expression state3 in
        let state5 = expect_token_punctuation state4 is_right_paren "right parenthesis" in
        let annotated_expr = TypeAnnotationExpr (expr, type_expr) in
        parse_postfix_expression annotated_expr state5
      else
        (* 普通括号表达式 *)
        let state3 = expect_token_punctuation state2 is_right_paren "right parenthesis" in
        parse_postfix_expression expr state3
  | IfKeyword -> parse_conditional_expression state
  | IfWenyanKeyword -> parse_ancient_conditional_expression parse_expression state
  | MatchKeyword -> parse_match_expression state
  | FunKeyword -> parse_function_expression state
  | LetKeyword -> parse_let_expression state
  | DefineKeyword -> 
      (* 调用主解析器中的自然语言函数定义解析 *)
      failwith "DefineKeyword should be handled by main parser"
  | HaveKeyword -> parse_wenyan_let_expression parse_expression state
  | SetKeyword -> parse_wenyan_simple_let_expression parse_expression state
  | AncientDefineKeyword -> parse_ancient_function_definition parse_expression state
  | AncientObserveKeyword -> parse_ancient_match_expression parse_expression parse_pattern state
  | AncientListStartKeyword -> parse_ancient_list_expression parse_expression state
  | LeftBracket | ChineseLeftBracket ->
      (* 禁用现代列表语法，提示使用古雅体语法 *)
      raise
        (SyntaxError
           ( "请使用古雅体列表语法替代 [...]。\n" ^ "空列表：空空如也\n" ^ "有元素的列表：列开始 元素1 其一 元素2 其二 元素3 其三 列结束\n"
             ^ "模式匹配：有首有尾 首名为「变量名」尾名为「尾部变量名」",
             snd (current_token state) ))
  | LeftArray | ChineseLeftArray -> parse_array_expression state
  | CombineKeyword -> parse_combine_expression state
  | LeftBrace ->
      let record_expr, state1 = parse_record_expression state in
      parse_postfix_expression record_expr state1
  | TryKeyword -> parse_try_expression state
  | RaiseKeyword -> parse_raise_expression state
  | RefKeyword -> parse_ref_expression state
  | ModuleKeyword -> parse_module_expression state
  | OneKeyword ->
      (* 将"一"关键字转换为数字字面量1 *)
      let state1 = advance_parser state in
      (LitExpr (IntLit 1), state1)
  | EmptyKeyword | TypeKeyword | ThenKeyword | ElseKeyword | WithKeyword | TrueKeyword
  | FalseKeyword | AndKeyword | OrKeyword | NotKeyword | ValueKeyword ->
      (* Handle keywords that might be part of compound identifiers *)
      let name, state1 = parse_identifier_allow_keywords state in
      parse_function_call_or_variable name state1
  | _ -> raise (SyntaxError ("意外的词元: " ^ show_token token, pos))

(** 解析函数调用或变量 *)
and parse_function_call_or_variable name state =
  (* Check if this identifier should be part of a compound identifier *)
  let final_name, state_after_name =
    let token, _ = current_token state in
    match (name, token) with
    | "去除", EmptyKeyword -> (
        (* Handle "去除空白" specifically *)
        let state1 = advance_parser state in
        let token2, _ = current_token state1 in
        match token2 with
        | QuotedIdentifierToken "白" ->
            let state2 = advance_parser state1 in
            ("去除空白", state2)
        | _ -> (name, state))
    | _ -> (name, state)
  in

  let (token, _) = current_token state_after_name in
  if token = Tilde then
    (* 标签函数调用 *)
    let (label_args, state1) = parse_label_arg_list [] state_after_name in
    let expr = LabeledFunCallExpr (VarExpr final_name, label_args) in
    parse_postfix_expression expr state1
  else
    (* 普通函数调用 *)
    let rec collect_args arg_list state =
      let (token, _) = current_token state in
      match token with
      | LeftParen | ChineseLeftParen | QuotedIdentifierToken _ | IntToken _
      | ChineseNumberToken _ | FloatToken _ | StringToken _ | BoolToken _ ->
        let (arg, state1) = parse_primary_expression state in
        collect_args (arg :: arg_list) state1
      | _ -> (List.rev arg_list, state)
    in
    let (arg_list, state1) = collect_args [] state_after_name in
    let expr = 
      if arg_list = [] then
        VarExpr final_name
      else
        FunCallExpr (VarExpr final_name, arg_list)
    in
    (* Handle postfix operations like field access *)
    parse_postfix_expression expr state1

(** 解析后缀表达式（字段访问等） *)
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
  | _ -> (expr, state)

(** 解析条件表达式 *)
and parse_conditional_expression state =
  let state1 = expect_token state IfKeyword in
  let cond, state2 = parse_expression state1 in
  let state3 = expect_token state2 ThenKeyword in
  let state3_clean = skip_newlines state3 in
  let then_branch, state4 = parse_expression state3_clean in
  let state4_clean = skip_newlines state4 in
  let state5 = expect_token state4_clean ElseKeyword in
  let state5_clean = skip_newlines state5 in
  let else_branch, state6 = parse_expression state5_clean in
  (CondExpr (cond, then_branch, else_branch), state6)

(** 解析匹配表达式 *)
and parse_match_expression state =
  let state1 = expect_token state MatchKeyword in
  let expr, state2 = parse_expression state1 in
  let state3 = expect_token state2 WithKeyword in
  let state3_clean = skip_newlines state3 in
  let rec parse_branch_list branch_list state =
    let state = skip_newlines state in
    if is_punctuation state is_pipe then
      let state1 = advance_parser state in
      let pattern, state2 = parse_pattern state1 in
      (* 检查是否有guard条件 (当 expression) *)
      let guard, state3 =
        if is_token state2 WhenKeyword then
          let state2_1 = advance_parser state2 in
          let guard_expr, state2_2 = parse_expression state2_1 in
          (Some guard_expr, state2_2)
        else (None, state2)
      in
      let state4 = expect_token_punctuation state3 is_arrow "arrow" in
      let state4_clean = skip_newlines state4 in
      let expr, state5 = parse_expression state4_clean in
      let state5_clean = skip_newlines state5 in
      let branch = { pattern; guard; expr } in
      parse_branch_list (branch :: branch_list) state5_clean
    else (List.rev branch_list, state)
  in
  let branch_list, state4 = parse_branch_list [] state3_clean in
  (MatchExpr (expr, branch_list), state4)

(** 解析函数表达式 *)
and parse_function_expression state =
  let state1 = expect_token state FunKeyword in
  let (token, _) = current_token state1 in
  (* 检查是否有标签参数 *)
  if token = Tilde then
    parse_labeled_function_expression state1
  else
    (* 普通函数表达式 *)
    let rec parse_param_list param_list state =
      let (token, _) = current_token state in
      match token with
      | QuotedIdentifierToken name ->
        let state1 = advance_parser state in
        parse_param_list (name :: param_list) state1
      | Arrow | ChineseArrow | ShouldGetKeyword | AncientArrowKeyword ->
        let state1 = advance_parser state in
        (List.rev param_list, state1)
      | _ -> raise (SyntaxError ("期望参数或箭头", snd (current_token state)))
    in
    let (param_list, state2) = parse_param_list [] state1 in
    let state2_clean = skip_newlines state2 in
    let (expr, state3) = parse_expression state2_clean in
    (FunExpr (param_list, expr), state3)

(** 解析标签函数表达式 *)
and parse_labeled_function_expression state =
  let rec parse_labeled_param_list param_list state =
    let (token, pos) = current_token state in
    match token with
    | Tilde ->
      let state1 = advance_parser state in
      let (label_param, state2) = parse_label_param state1 in
      parse_labeled_param_list (label_param :: param_list) state2
    | Arrow | ChineseArrow ->
      let state1 = advance_parser state in
      (List.rev param_list, state1)
    | _ -> raise (SyntaxError ("期望标签参数或箭头", pos))
  in
  let (label_params, state1) = parse_labeled_param_list [] state in
  let state1_clean = skip_newlines state1 in
  let (expr, state2) = parse_expression state1_clean in
  (LabeledFunExpr (label_params, expr), state2)

(** 解析单个标签参数 *)
and parse_label_param state =
  let (label_name, state1) = parse_identifier state in
  let (token, _) = current_token state1 in
  match token with
  | QuestionMark ->
    (* 可选参数 *)
    let state2 = advance_parser state1 in
    let (token2, _) = current_token state2 in
    if token2 = Colon then
      (* 有默认值的可选参数: ~label?: default_value *)
      let state3 = advance_parser state2 in
      let (default_expr, state4) = parse_expression state3 in
      ({ label_name = label_name; param_name = label_name; param_type = None; 
         is_optional = true; default_value = Some default_expr }, state4)
    else
      (* 无默认值的可选参数: ~label? *)
      ({ label_name = label_name; param_name = label_name; param_type = None; 
         is_optional = true; default_value = None }, state2)
  | Colon ->
    (* 带类型注解的参数: ~label: type *)
    let state2 = advance_parser state1 in
      let (type_expr, state3) = parse_basic_type_expression state2 in
    ({ label_name = label_name; param_name = label_name; param_type = Some type_expr; 
       is_optional = false; default_value = None }, state3)
  | _ ->
    (* 普通标签参数: ~label *)
    ({ label_name = label_name; param_name = label_name; param_type = None; 
       is_optional = false; default_value = None }, state1)

(** 解析标签参数列表 *)
and parse_label_arg_list arg_list state =
  let (token, _) = current_token state in
  match token with
  | Tilde ->
    let state1 = advance_parser state in
    let (label_arg, state2) = parse_label_arg state1 in
    parse_label_arg_list (label_arg :: arg_list) state2
  | _ -> (List.rev arg_list, state)

(** 解析单个标签参数 *)
and parse_label_arg state =
  let (label_name, state1) = parse_identifier state in
  let state2 = expect_token state1 Colon in
  let (arg_expr, state3) = parse_primary_expression state2 in
  ({ arg_label = label_name; arg_value = arg_expr }, state3)

(** 解析让表达式 *)
and parse_let_expression state =
  let state1 = expect_token state LetKeyword in
  let name, state2 = parse_identifier_allow_keywords state1 in
  (* Check for semantic type annotation *)
  let semantic_label_opt, state_after_name =
    let token, _ = current_token state2 in
    if token = AsKeyword then
      let state3 = advance_parser state2 in
      let label, state4 = parse_identifier state3 in
      (Some label, state4)
    else (None, state2)
  in
  (* 检查是否有类型注解 *)
  let (type_annotation_opt, state_before_assign) = 
    let (token, _) = current_token state_after_name in
    if is_double_colon token then
      (* 类型注解 *)
      let state_after_colon = advance_parser state_after_name in
      let (type_expr, state_after_type) = parse_type_expression state_after_colon in
      (Some type_expr, state_after_type)
    else
      (None, state_after_name)
  in
  let state3 = expect_token state_before_assign AsForKeyword in
  let (val_expr, state4) = parse_expression state3 in
  let state4_clean = skip_newlines state4 in
  let token, _ = current_token state4_clean in
  let state5 = if token = InKeyword then advance_parser state4_clean else state4_clean in
  let state5_clean = skip_newlines state5 in
  let (body_expr, state6) = parse_expression state5_clean in
  match (semantic_label_opt, type_annotation_opt) with
  | (Some label, None) -> (SemanticLetExpr (name, label, val_expr, body_expr), state6)
  | (None, Some type_expr) -> (LetExprWithType (name, type_expr, val_expr, body_expr), state6)
  | (None, None) -> (LetExpr (name, val_expr, body_expr), state6)
  | (Some _, Some _) -> 
    (* 目前不支持同时有语义标签和类型注解 *)
    raise (SyntaxError ("不支持同时使用语义标签和类型注解", snd (current_token state6)))

(** 解析数组表达式 *)
and parse_array_expression state =
  let state1 = expect_token_punctuation state is_left_array "left array bracket" in
  let rec parse_array_elements elements state =
    let state = skip_newlines state in
    let token, _ = current_token state in
    match token with
    | RightArray | ChineseRightArray -> (ArrayExpr (List.rev elements), advance_parser state)
    | _ -> (
        let expr, state1 = parse_expression state in
        let token, _ = current_token state1 in
        match token with
        | Semicolon | ChineseSemicolon | AfterThatKeyword ->
            let state2 = advance_parser state1 in
            parse_array_elements (expr :: elements) state2
        | RightArray | ChineseRightArray ->
            (ArrayExpr (List.rev (expr :: elements)), advance_parser state1)
        | _ -> raise (SyntaxError ("期望分号或右数组括号", snd (current_token state1))))
  in
  let array_expr, state2 = parse_array_elements [] state1 in
  parse_postfix_expression array_expr state2

(** 解析组合表达式 *)
and parse_combine_expression state =
  let state1 = expect_token state CombineKeyword in
  (* Parse first expression *)
  let first_expr, state2 = parse_expression state1 in
  (* Parse remaining expressions with 以及 separator *)
  let rec parse_combine_list expr_list state =
    let token, _ = current_token state in
    if token = WithOpKeyword then
      let state1 = advance_parser state in
      let expr, state2 = parse_expression state1 in
      parse_combine_list (expr :: expr_list) state2
    else (List.rev expr_list, state)
  in
  let rest_exprs, final_state = parse_combine_list [ first_expr ] state2 in
  (CombineExpr rest_exprs, final_state)

(** 解析记录表达式 *)
and parse_record_expression state =
  let state1 = expect_token_punctuation state is_left_brace "left brace" in
  let rec parse_fields fields state =
    let state = skip_newlines state in
    let token, pos = current_token state in
    match token with
    | RightBrace -> (RecordExpr (List.rev fields), advance_parser state)
    | QuotedIdentifierToken field_name ->
        let state1 = advance_parser state in
        (* Check if this is a record update expression *)
        if fields = [] && is_token state1 WithKeyword then
          (* This is { expr 与 field = value } syntax *)
          let expr = VarExpr field_name in
          let state2 = expect_token state1 WithKeyword in
          let updates, state3 = parse_record_updates state2 in
          (RecordUpdateExpr (expr, updates), state3)
        else
          (* Regular field *)
          let state2 = expect_token state1 AsForKeyword in
          let value, state3 = parse_expression state2 in
          let state4 =
            let token, _ = current_token state3 in
            if is_semicolon token then advance_parser state3 else state3
          in
          parse_fields ((field_name, value) :: fields) state4
    | _ ->
        (* Could be { expr 与 ... } where expr is not just an identifier *)
        if fields = [] then
          let expr, state1 = parse_expression state in
          let state2 = expect_token state1 WithKeyword in
          let updates, state3 = parse_record_updates state2 in
          (RecordUpdateExpr (expr, updates), state3)
        else raise (SyntaxError ("期望字段名或右花括号", pos))
  in
  let fields_or_expr, state2 = parse_fields [] state1 in
  (fields_or_expr, state2)

(** 解析记录更新字段 *)
and parse_record_updates state =
  let rec parse_updates updates state =
    let state = skip_newlines state in
    let token, _ = current_token state in
    match token with
    | RightBrace -> (List.rev updates, advance_parser state)
    | QuotedIdentifierToken field_name ->
        let state1 = advance_parser state in
        let state2 = expect_token state1 AsForKeyword in
        let value, state3 = parse_expression state2 in
        let state4 =
          let token, _ = current_token state3 in
          if is_semicolon token then advance_parser state3 else state3
        in
        parse_updates ((field_name, value) :: updates) state4
    | _ -> raise (SyntaxError ("期望字段名", snd (current_token state)))
  in
  parse_updates [] state

(** 解析try表达式 *)
and parse_try_expression state =
  let state1 = expect_token state TryKeyword in
  let state1 = skip_newlines state1 in
  let try_expr, state2 = parse_expression state1 in
  let state2 = skip_newlines state2 in
  let state3 = expect_token state2 CatchKeyword in
  let state3 = skip_newlines state3 in

  (* 解析catch分支 *)
  let rec parse_catch_branches branches state =
    let state = skip_newlines state in
    let token, _ = current_token state in
    match token with
    | Pipe ->
        let state1 = advance_parser state in
        let pattern, state2 = parse_pattern state1 in
        (* Exception handling typically doesn't use guards, but we support it *)
        let guard, state3 =
          if is_token state2 WhenKeyword then
            let state2_1 = advance_parser state2 in
            let guard_expr, state2_2 = parse_expression state2_1 in
            (Some guard_expr, state2_2)
          else (None, state2)
        in
        let state4 = expect_token state3 Arrow in
        let state4 = skip_newlines state4 in
        let expr, state5 = parse_expression state4 in
        let state5 = skip_newlines state5 in
        let branch = { pattern; guard; expr } in
        parse_catch_branches (branch :: branches) state5
    | _ -> (List.rev branches, state)
  in

  let catch_branches, state4 = parse_catch_branches [] state3 in

  (* 检查是否有finally块 *)
  let state4 = skip_newlines state4 in
  let token, _ = current_token state4 in
  match token with
  | FinallyKeyword ->
      let state5 = advance_parser state4 in
      let state5 = skip_newlines state5 in
      let finally_expr, state6 = parse_expression state5 in
      (TryExpr (try_expr, catch_branches, Some finally_expr), state6)
  | _ -> (TryExpr (try_expr, catch_branches, None), state4)

(** 解析raise表达式 *)
and parse_raise_expression state =
  let state1 = expect_token state RaiseKeyword in
  let expr, state2 = parse_expression state1 in
  (RaiseExpr expr, state2)

(** 解析ref表达式 *)
and parse_ref_expression state =
  let state1 = expect_token state RefKeyword in
  let expr, state2 = parse_expression state1 in
  (RefExpr expr, state2)

(** 自然语言函数定义解析 *)
and parse_natural_function_definition state =
  let state1 = expect_token state DefineKeyword in
  let function_name, state2 = parse_identifier state1 in
  let state3 = expect_token state2 AcceptKeyword in
  let param_name, state4 = parse_identifier state3 in
  let state5 = Parser_utils.expect_token_punctuation state4 Parser_utils.is_colon "colon" in
  let state5_clean = skip_newlines state5 in
  let body_expr, state6 = parse_natural_function_body param_name state5_clean in
  let fun_expr = FunExpr ([ param_name ], body_expr) in
  (LetExpr (function_name, fun_expr, VarExpr function_name), state6)

(** 自然语言函数体解析 *)
and parse_natural_function_body param_name state =
  let token, _ = current_token state in
  match token with
  | WhenKeyword -> parse_natural_conditional param_name state
  | ElseReturnKeyword ->
      let state1 = advance_parser state in
      parse_natural_expression param_name state1
  | InputKeyword -> parse_natural_expression param_name state
  | _ -> parse_natural_expression param_name state

(** 自然语言条件表达式解析 *)
and parse_natural_conditional param_name state =
  let state1 = expect_token state WhenKeyword in
  let param_ref, state2 = parse_identifier state1 in
  let token, _ = current_token state2 in
  let comparison_op, state3 =
    match token with
    | IsKeyword -> (Eq, advance_parser state2)
    | AsForKeyword -> (Eq, advance_parser state2)
    | QuotedIdentifierToken "为" -> (Eq, advance_parser state2)
    | EqualToKeyword -> (Eq, advance_parser state2)
    | LessThanEqualToKeyword -> (Le, advance_parser state2)
    | _ -> raise (SyntaxError ("期望条件关系词，如「为」或「等于」", snd (current_token state2)))
  in
  let condition_value, state4 = parse_expression state3 in
  let state5 = expect_token state4 ReturnWhenKeyword in
  let return_value, state6 = parse_natural_expression param_name state5 in
  let state6_clean = skip_newlines state6 in
  let token_after, _ = current_token state6_clean in
  if token_after = ElseReturnKeyword then
    let state7 = advance_parser state6_clean in
    let else_expr, state8 = parse_natural_expression param_name state7 in
    let condition_expr = BinaryOpExpr (VarExpr param_ref, comparison_op, condition_value) in
    (CondExpr (condition_expr, return_value, else_expr), state8)
  else
    let condition_expr = BinaryOpExpr (VarExpr param_ref, comparison_op, condition_value) in
    (CondExpr (condition_expr, return_value, LitExpr UnitLit), state6)

(** 自然语言表达式解析 *)
and parse_natural_expression param_name state =
  let token, _ = current_token state in
  match token with
  | QuotedIdentifierToken _ ->
      let expr, state1 = parse_natural_arithmetic_expression param_name state in
      (expr, state1)
  | InputKeyword ->
      let expr, state1 = parse_natural_arithmetic_expression param_name state in
      (expr, state1)
  | IntToken _ | ChineseNumberToken _ | FloatToken _ | StringToken _ ->
      let literal, state1 = parse_literal state in
      (LitExpr literal, state1)
  | _ -> parse_expression state

(** 自然语言算术表达式解析 *)
and parse_natural_arithmetic_expression param_name state =
  let left_expr, state1 = parse_natural_primary param_name state in
  parse_natural_arithmetic_tail left_expr param_name state1

(** 自然语言算术表达式尾部解析 *)
and parse_natural_arithmetic_tail left_expr param_name state =
  let token, _ = current_token state in
  match token with
  | MultiplyKeyword ->
      let state1 = advance_parser state in
      let right_expr, state2 = parse_natural_primary param_name state1 in
      let new_expr = BinaryOpExpr (left_expr, Mul, right_expr) in
      parse_natural_arithmetic_tail new_expr param_name state2
  | DivideKeyword ->
      let state1 = advance_parser state in
      let right_expr, state2 = parse_natural_primary param_name state1 in
      let new_expr = BinaryOpExpr (left_expr, Div, right_expr) in
      parse_natural_arithmetic_tail new_expr param_name state2
  | AddToKeyword ->
      let state1 = advance_parser state in
      let right_expr, state2 = parse_natural_primary param_name state1 in
      let new_expr = BinaryOpExpr (left_expr, Add, right_expr) in
      parse_natural_arithmetic_tail new_expr param_name state2
  | SubtractKeyword ->
      let state1 = advance_parser state in
      let right_expr, state2 = parse_natural_primary param_name state1 in
      let new_expr = BinaryOpExpr (left_expr, Sub, right_expr) in
      parse_natural_arithmetic_tail new_expr param_name state2
  | _ -> (left_expr, state)

(** 自然语言基础表达式解析 *)
and parse_natural_primary param_name state =
  let token, _ = current_token state in
  match token with
  | QuotedIdentifierToken name ->
      let state1 = advance_parser state in
      parse_natural_identifier_patterns name param_name state1
  | InputKeyword ->
      let state1 = advance_parser state in
      parse_natural_input_patterns param_name state1
  | IntToken _ | ChineseNumberToken _ | FloatToken _ | StringToken _ ->
      let literal, state1 = parse_literal state in
      (LitExpr literal, state1)
  | LeftParen ->
      let state1 = advance_parser state in
      let expr, state2 = parse_expression state1 in
      let state3 = expect_token state2 RightParen in
      (expr, state3)
  | _ -> parse_expression state

(** 自然语言标识符模式解析 *)
and parse_natural_identifier_patterns name param_name state =
  let token_after, _ = current_token state in
  match token_after with
  | OfParticle ->
      let state2 = advance_parser state in
      let func_name, state3 = parse_identifier state2 in
      (FunCallExpr (VarExpr func_name, [ VarExpr name ]), state3)
  | MinusOneKeyword ->
      let state2 = advance_parser state in
      let minus_one_expr = BinaryOpExpr (VarExpr name, Sub, LitExpr (IntLit 1)) in
      parse_natural_arithmetic_continuation minus_one_expr param_name state2
  | _ -> (VarExpr name, state)

(** 自然语言输入模式解析 *)
and parse_natural_input_patterns param_name state =
  let token_after, _ = current_token state in
  match token_after with
  | MinusOneKeyword ->
      let state1 = advance_parser state in
      let minus_one_expr = BinaryOpExpr (VarExpr param_name, Sub, LitExpr (IntLit 1)) in
      parse_natural_arithmetic_continuation minus_one_expr param_name state1
  | SmallKeyword ->
      let state1 = advance_parser state in
      parse_natural_comparison_patterns param_name state1
  | _ -> (VarExpr param_name, state)

(** 自然语言比较模式解析 *)
and parse_natural_comparison_patterns param_name state =
  let token_after, _ = current_token state in
  match token_after with
  | LessThanEqualToKeyword ->
      let state1 = advance_parser state in
      let right_expr, state2 = parse_expression state1 in
      (BinaryOpExpr (VarExpr param_name, Le, right_expr), state2)
  | _ -> (VarExpr param_name, state)