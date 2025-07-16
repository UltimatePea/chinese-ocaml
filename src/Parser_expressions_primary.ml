(** 骆言语法分析器基础表达式解析模块 - Primary Expression Parser *)

open Ast
open Lexer
open Parser_utils
open Parser_expressions_utils

(** 解析函数调用或变量 *)
let rec parse_function_call_or_variable name state =
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

  let token, _ = current_token state_after_name in
  if token = Tilde then
    (* 标签函数调用 *)
    let label_args, state1 = parse_label_arg_list [] state_after_name in
    let expr = LabeledFunCallExpr (VarExpr final_name, label_args) in
    parse_postfix_expr expr state1
  else
    (* 普通函数调用 *)
    let rec collect_args arg_list state =
      let token, _ = current_token state in
      match token with
      | LeftParen | ChineseLeftParen | QuotedIdentifierToken _ | IntToken _ | ChineseNumberToken _
      | FloatToken _ | StringToken _ | BoolToken _ | OneKeyword ->
          let arg, state1 = parse_primary_expr state in
          collect_args (arg :: arg_list) state1
      | _ -> (List.rev arg_list, state)
    in
    let arg_list, state1 = collect_args [] state_after_name in
    let expr =
      if arg_list = [] then VarExpr final_name else FunCallExpr (VarExpr final_name, arg_list)
    in
    (* Handle postfix operations like field access *)
    parse_postfix_expr expr state1

(** 解析后缀表达式（字段访问等） *)
and parse_postfix_expr expr state =
  let token, _ = current_token state in
  match token with
  | Dot -> (
      let state1 = advance_parser state in
      let token2, _ = current_token state1 in
      match token2 with
      | QuotedIdentifierToken field_name ->
          let state2 = advance_parser state1 in
          let new_expr = FieldAccessExpr (expr, field_name) in
          parse_postfix_expr new_expr state2
      | _ -> (expr, state))
  | LeftBracket | ChineseLeftBracket ->
      (* 数组索引 *)
      let state1 = advance_parser state in
      let index_expr, state2 = Parser_expressions.parse_expression state1 in
      let state3 = expect_token_punctuation state2 is_right_bracket "right bracket" in
      let new_expr = ArrayAccessExpr (expr, index_expr) in
      parse_postfix_expr new_expr state3
  | _ -> (expr, state)

(** 解析基础表达式 *)
and parse_primary_expr state =
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
      if looks_like_string_literal name then (LitExpr (StringLit name), state1)
      (* According to Issue #176: ALL quoted identifiers should be treated as identifiers, not as numbers *)
        else parse_function_call_or_variable name state1
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
      let tag_name, state2 = parse_identifier state1 in
      let token, _ = current_token state2 in
      if is_identifier_like token then
        (* 有值的多态变体: 标签 「标签名」 值 *)
        let value_expr, state3 = parse_primary_expr state2 in
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
      let expr, state2 = Parser_expressions.parse_expression state1 in
      (* 检查是否有类型注解 *)
      let token, _ = current_token state2 in
      if is_double_colon token then
        (* 类型注解表达式 (expr :: type) *)
        let state3 = advance_parser state2 in
        let type_expr, state4 = Parser_types.parse_type_expression state3 in
        let state5 = expect_token_punctuation state4 is_right_paren "right parenthesis" in
        let annotated_expr = TypeAnnotationExpr (expr, type_expr) in
        parse_postfix_expr annotated_expr state5
      else
        (* 普通括号表达式 *)
        let state3 = expect_token_punctuation state2 is_right_paren "right parenthesis" in
        parse_postfix_expr expr state3
  | IfKeyword -> Parser_expressions.parse_conditional_expression state
  | IfWenyanKeyword ->
      Parser_ancient.parse_ancient_conditional_expression Parser_expressions.parse_expression state
  | MatchKeyword -> Parser_expressions.parse_match_expression state
  | FunKeyword -> Parser_expressions.parse_function_expression state
  | LetKeyword -> Parser_expressions.parse_let_expression state
  | DefineKeyword ->
      (* 调用主解析器中的自然语言函数定义解析 *)
      let _token, pos = current_token state in
      raise (Types.ParseError ("DefineKeyword应由主解析器处理", pos.line, pos.column))
  | HaveKeyword ->
      Parser_ancient.parse_wenyan_let_expression Parser_expressions.parse_expression state
  | SetKeyword ->
      Parser_ancient.parse_wenyan_simple_let_expression Parser_expressions.parse_expression state
  | AncientDefineKeyword ->
      Parser_ancient.parse_ancient_function_definition Parser_expressions.parse_expression state
  | AncientObserveKeyword ->
      Parser_ancient.parse_ancient_match_expression Parser_expressions.parse_expression
        Parser_patterns.parse_pattern state
  | AncientListStartKeyword ->
      Parser_ancient.parse_ancient_list_expression Parser_expressions.parse_expression state
  | LeftBracket | ChineseLeftBracket ->
      (* 禁用现代列表语法，提示使用古雅体语法 *)
      raise
        (SyntaxError
           ( "请使用古雅体列表语法替代 [...]。\n" ^ "空列表：空空如也\n" ^ "有元素的列表：列开始 元素1 其一 元素2 其二 元素3 其三 列结束\n"
             ^ "模式匹配：有首有尾 首名为「变量名」尾名为「尾部变量名」",
             snd (current_token state) ))
  | LeftArray | ChineseLeftArray -> Parser_expressions.parse_array_expression state
  | CombineKeyword -> Parser_expressions.parse_combine_expression state
  | LeftBrace ->
      let record_expr, state1 = Parser_expressions.parse_record_expression state in
      parse_postfix_expr record_expr state1
  | TryKeyword -> Parser_expressions.parse_try_expression state
  | RaiseKeyword -> Parser_expressions.parse_raise_expression state
  | RefKeyword -> Parser_expressions.parse_ref_expression state
  | ModuleKeyword -> Parser_expressions.parse_module_expression state
  | OneKeyword ->
      (* 将"一"关键字转换为数字字面量1 *)
      let state1 = advance_parser state in
      (LitExpr (IntLit 1), state1)
  (* 古典诗词关键字处理 *)
  | ParallelStructKeyword | FiveCharKeyword | SevenCharKeyword ->
      Parser_poetry.parse_poetry_expression state
  | EmptyKeyword | TypeKeyword | ThenKeyword | ElseKeyword | WithKeyword | TrueKeyword
  | FalseKeyword | AndKeyword | OrKeyword | NotKeyword | ValueKeyword ->
      (* Handle keywords that might be part of compound identifiers *)
      let name, state1 = parse_identifier_allow_keywords state in
      parse_function_call_or_variable name state1
  | _ -> raise (SyntaxError ("意外的词元: " ^ show_token token, pos))

(** 解析标签参数列表 *)
and parse_label_arg_list arg_list state =
  let token, _ = current_token state in
  match token with
  | Tilde ->
      let state1 = advance_parser state in
      let label_arg, state2 = parse_label_arg state1 in
      parse_label_arg_list (label_arg :: arg_list) state2
  | _ -> (List.rev arg_list, state)

(** 解析单个标签参数 *)
and parse_label_arg state =
  let label_name, state1 = parse_identifier state in
  let state2 = expect_token state1 Colon in
  let arg_expr, state3 = parse_primary_expr state2 in
  ({ arg_label = label_name; arg_value = arg_expr }, state3)
