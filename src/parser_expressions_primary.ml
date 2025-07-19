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
    let parse_atomic_expr state =
      let token, pos = current_token state in
      match token with
      | IntToken _ | ChineseNumberToken _ | FloatToken _ | StringToken _ ->
          let literal, state1 = parse_literal state in
          (LitExpr literal, state1)
      | BoolToken _ ->
          let literal, state1 = parse_literal state in
          (LitExpr literal, state1)
      | QuotedIdentifierToken name ->
          let state1 = advance_parser state in
          if looks_like_string_literal name then (LitExpr (StringLit name), state1)
          else (VarExpr name, state1)
      | OneKeyword ->
          let state1 = advance_parser state in
          (LitExpr (IntLit 1), state1)
      | LeftParen | ChineseLeftParen ->
          let state1 = advance_parser state in
          let expr, state2 = Parser_expressions.parse_expression state1 in
          let state3 = expect_token_punctuation state2 is_right_paren "right parenthesis" in
          (expr, state3)
      | _ -> raise (SyntaxError ("期待参数表达式: " ^ show_token token, pos))
    in
    let rec collect_args arg_list state =
      let token, _ = current_token state in
      match token with
      | LeftParen | ChineseLeftParen | QuotedIdentifierToken _ | IntToken _ | ChineseNumberToken _
      | FloatToken _ | StringToken _ | BoolToken _ | OneKeyword ->
          let arg, state1 = parse_atomic_expr state in
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

(** 解析字面量表达式 *)
and parse_literal_expr state =
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
  | OneKeyword ->
      (* 将"一"关键字转换为数字字面量1 *)
      let state1 = advance_parser state in
      (LitExpr (IntLit 1), state1)
  | _ ->
      raise
        (Parser_utils.make_unexpected_token_error
           ("parse_literal_expr: " ^ show_token token)
           (snd (current_token state)))

(** 解析标识符表达式 *)
and parse_identifier_expr state =
  let token, _ = current_token state in
  match token with
  | QuotedIdentifierToken name ->
      let state1 = advance_parser state in
      (* Check if this looks like a string literal rather than a variable name *)
      if looks_like_string_literal name then (LitExpr (StringLit name), state1)
      (* According to Issue #176: ALL quoted identifiers should be treated as identifiers, not as numbers *)
        else parse_function_call_or_variable name state1
  | NumberKeyword ->
      (* 尝试解析wenyan复合标识符，如"数值" *)
      let name, state1 = parse_wenyan_compound_identifier state in
      parse_function_call_or_variable name state1
  | EmptyKeyword | TypeKeyword | ThenKeyword | ElseKeyword | WithKeyword | TrueKeyword
  | FalseKeyword | AndKeyword | OrKeyword | NotKeyword | ValueKeyword ->
      (* Handle keywords that might be part of compound identifiers *)
      let name, state1 = parse_identifier_allow_keywords state in
      parse_function_call_or_variable name state1
  | _ ->
      raise
        (Parser_utils.make_unexpected_token_error
           ("parse_identifier_expr: " ^ show_token token)
           (snd (current_token state)))

(** 解析类型关键字表达式 *)
and parse_type_keyword_expr state =
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
  | _ ->
      raise
        (Parser_utils.make_unexpected_token_error
           ("parse_type_keyword_expr: " ^ show_token token)
           (snd (current_token state)))

(** 解析特殊关键字表达式 *)
and parse_special_keyword_expr state =
  let token, pos = current_token state in
  match token with
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
  | DefineKeyword ->
      (* 调用主解析器中的自然语言函数定义解析 *)
      raise (Types.ParseError ("DefineKeyword应由主解析器处理", pos.line, pos.column))
  | LeftBracket | ChineseLeftBracket ->
      (* 禁用现代列表语法，提示使用古雅体语法 *)
      raise
        (SyntaxError
           ( "请使用古雅体列表语法替代 [...]。\n" ^ "空列表：空空如也\n" ^ "有元素的列表：列开始 元素1 其一 元素2 其二 元素3 其三 列结束\n"
             ^ "模式匹配：有首有尾 首名为「变量名」尾名为「尾部变量名」",
             snd (current_token state) ))
  | _ ->
      raise
        (Parser_utils.make_unexpected_token_error
           ("parse_special_keyword_expr: " ^ show_token token)
           (snd (current_token state)))

(** 解析括号表达式 (带类型注解支持) *)
and parse_parentheses_expr state =
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

(** 解析控制流关键字表达式 *)
and parse_control_flow_expr state token =
  match token with
  | IfKeyword -> Parser_expressions.parse_conditional_expression state
  | MatchKeyword -> Parser_expressions.parse_match_expression state
  | FunKeyword -> Parser_expressions.parse_function_expression state
  | LetKeyword -> Parser_expressions.parse_let_expression state
  | TryKeyword -> Parser_expressions.parse_try_expression state
  | RaiseKeyword -> Parser_expressions.parse_raise_expression state
  | CombineKeyword -> Parser_expressions.parse_combine_expression state
  | _ -> failwith "parse_control_flow_expr: 不是控制流关键字"

(** 解析文言/古雅体关键字表达式 *)
and parse_ancient_expr state token =
  match token with
  | IfWenyanKeyword ->
      Parser_ancient.parse_ancient_conditional_expression Parser_expressions.parse_expression state
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
  | AncientRecordStartKeyword | AncientRecordEmptyKeyword | AncientRecordUpdateKeyword ->
      let record_expr, state1 = Parser_expressions.parse_ancient_record_expression state in
      parse_postfix_expr record_expr state1
  | _ -> failwith "parse_ancient_expr: 不是古雅体关键字"

(** 解析数据结构表达式 *)
and parse_data_structure_expr state token =
  match token with
  | LeftArray | ChineseLeftArray -> Parser_expressions.parse_array_expression state
  | LeftBrace ->
      let record_expr, state1 = Parser_expressions.parse_record_expression state in
      parse_postfix_expr record_expr state1
  | RefKeyword -> Parser_expressions.parse_ref_expression state
  | ModuleKeyword -> Parser_expressions.parse_module_expression state
  | _ -> failwith "parse_data_structure_expr: 不是数据结构关键字"

(** 解析诗词表达式 *)
and parse_poetry_expr state token =
  match token with
  | ParallelStructKeyword | FiveCharKeyword | SevenCharKeyword ->
      Parser_poetry.parse_poetry_expression state
  | _ -> failwith "parse_poetry_expr: 不是诗词关键字"

(** 解析复合表达式 - 重构后的主函数 *)
and parse_compound_expr state =
  let token, _ = current_token state in
  match token with
  (* 括号表达式 *)
  | LeftParen | ChineseLeftParen -> parse_parentheses_expr state
  (* 控制流关键字 *)
  | IfKeyword | MatchKeyword | FunKeyword | LetKeyword | TryKeyword | RaiseKeyword | CombineKeyword
    ->
      parse_control_flow_expr state token
  (* 古雅体/文言关键字 *)
  | IfWenyanKeyword | HaveKeyword | SetKeyword | AncientDefineKeyword | AncientObserveKeyword
  | AncientListStartKeyword | AncientRecordStartKeyword | AncientRecordEmptyKeyword
  | AncientRecordUpdateKeyword ->
      parse_ancient_expr state token
  (* 数据结构关键字 *)
  | LeftArray | ChineseLeftArray | LeftBrace | RefKeyword | ModuleKeyword ->
      parse_data_structure_expr state token
  (* 诗词关键字 *)
  | ParallelStructKeyword | FiveCharKeyword | SevenCharKeyword -> parse_poetry_expr state token
  | _ ->
      raise
        (Parser_utils.make_unexpected_token_error
           ("parse_compound_expr: " ^ show_token token)
           (snd (current_token state)))

(** 解析字面量表达式（重构后） *)
and parse_literal_expressions state =
  let token, _ = current_token state in
  match token with
  | IntToken _ | ChineseNumberToken _ | FloatToken _ | StringToken _ | BoolToken _ | OneKeyword ->
      Some (parse_literal_expr state)
  | _ -> None

(** 解析类型关键字表达式（重构后） *)
and parse_type_keyword_expressions state =
  let token, _ = current_token state in
  match token with
  | IntTypeKeyword | FloatTypeKeyword | StringTypeKeyword | BoolTypeKeyword | UnitTypeKeyword
  | ListTypeKeyword | ArrayTypeKeyword ->
      Some (parse_type_keyword_expr state)
  | _ -> None

(** 解析复合表达式（重构后） *)
and parse_compound_expressions state =
  let token, _ = current_token state in
  match token with
  | LeftParen | ChineseLeftParen | IfKeyword | MatchKeyword | FunKeyword | LetKeyword | TryKeyword
  | RaiseKeyword | CombineKeyword | IfWenyanKeyword | HaveKeyword | SetKeyword
  | AncientDefineKeyword | AncientObserveKeyword | AncientListStartKeyword
  | AncientRecordStartKeyword | AncientRecordEmptyKeyword | AncientRecordUpdateKeyword | LeftArray
  | ChineseLeftArray | LeftBrace | RefKeyword | ModuleKeyword ->
      Some (parse_compound_expr state)
  | _ -> None

(** 解析关键字表达式（重构后） *)
and parse_keyword_expressions state =
  let token, _ = current_token state in
  match token with
  | TagKeyword | DefineKeyword | LeftBracket | ChineseLeftBracket ->
      Some (parse_special_keyword_expr state)
  | QuotedIdentifierToken _ | NumberKeyword | EmptyKeyword | TypeKeyword | ThenKeyword | ElseKeyword
  | WithKeyword | TrueKeyword | FalseKeyword | AndKeyword | OrKeyword | NotKeyword | ValueKeyword ->
      Some (parse_identifier_expr state)
  | _ -> None

(** 解析诗词表达式（重构后） *)
and parse_poetry_expressions state =
  let token, _ = current_token state in
  match token with
  | ParallelStructKeyword | FiveCharKeyword | SevenCharKeyword ->
      Some (parse_poetry_expr state token)
  | _ -> None

(** 解析基础表达式（重构后的主函数） *)
and parse_primary_expr state =
  let token, pos = current_token state in
  (* 按优先级尝试各种表达式类型 *)
  match parse_literal_expressions state with
  | Some result -> result
  | None -> (
      match parse_type_keyword_expressions state with
      | Some result -> result
      | None -> (
          match parse_keyword_expressions state with
          | Some result -> result
          | None -> (
              match parse_compound_expressions state with
              | Some result -> result
              | None -> (
                  match parse_poetry_expressions state with
                  | Some result -> result
                  | None -> raise (Parser_utils.make_unexpected_token_error (show_token token) pos))
              )))

(** 解析标签参数列表 *)

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
