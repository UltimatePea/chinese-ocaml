(** 骆言语法分析器 - Chinese Programming Language Parser *)

(** 导入基础模块 *)
open Ast
open Lexer

(** 初始化模块日志器 *)
let (log_debug, _log_info, _log_warn, _log_error) = Logger.init_module_logger "Parser"

(** 导出核心类型和异常 *)
type parser_state = Parser_utils.parser_state
exception SyntaxError = Parser_utils.SyntaxError

(** 主要入口点函数 *)

(** 解析表达式 - 主要入口点 *)
let parse_expression = Parser_expressions.parse_expression

(** 解析语句 - 主要入口点 *)
let parse_statement = Parser_statements.parse_statement

(** 解析程序 - 主要入口点 *)
let parse_program = Parser_statements.parse_program

(** 解析模式 - 主要入口点 *)
let parse_pattern = Parser_patterns.parse_pattern

(** 解析类型表达式 - 主要入口点 *)
let parse_type_expression = Parser_types.parse_type_expression

(** 解析类型定义 - 主要入口点 *)
let parse_type_definition = Parser_types.parse_type_definition

(** 基础工具函数转发 *)
let create_parser_state = Parser_utils.create_parser_state
let current_token = Parser_utils.current_token
let peek_token = Parser_utils.peek_token
let advance_parser = Parser_utils.advance_parser
let expect_token = Parser_utils.expect_token
let is_token = Parser_utils.is_token
let parse_identifier = Parser_utils.parse_identifier
let parse_identifier_allow_keywords = Parser_utils.parse_identifier_allow_keywords
let parse_literal = Parser_utils.parse_literal
let token_to_binary_op = Parser_utils.token_to_binary_op

(** 跳过换行符辅助函数 *)
let rec skip_newlines state =
  let token, _pos = current_token state in
  if token = Newline then skip_newlines (advance_parser state) else state

(** 跳过可选的语句终结符 *)
let skip_optional_statement_terminator state =
  let token, _ = current_token state in
  if Parser_utils.is_semicolon token || token = AlsoKeyword then advance_parser state else state

(** 解析宏参数 *)
let rec parse_macro_params acc state =
  let token, _ = current_token state in
  match token with
  | RightParen -> (List.rev acc, state)
  | QuotedIdentifierToken param_name -> (
      let state1 = advance_parser state in
      let state2 = expect_token state1 Colon in
      let token, _ = current_token state2 in
      match token with
      | QuotedIdentifierToken "表达式" ->
          let state3 = advance_parser state2 in
          let new_param = ExprParam param_name in
          let next_token, _ = current_token state3 in
          if next_token = Comma then
            let state4 = advance_parser state3 in
            parse_macro_params (new_param :: acc) state4
          else parse_macro_params (new_param :: acc) state3
      | QuotedIdentifierToken "语句" ->
          let state3 = advance_parser state2 in
          let new_param = StmtParam param_name in
          let next_token, _ = current_token state3 in
          if next_token = Comma then
            let state4 = advance_parser state3 in
            parse_macro_params (new_param :: acc) state4
          else parse_macro_params (new_param :: acc) state3
      | QuotedIdentifierToken "类型" ->
          let state3 = advance_parser state2 in
          let new_param = TypeParam param_name in
          let next_token, _ = current_token state3 in
          if next_token = Comma then
            let state4 = advance_parser state3 in
            parse_macro_params (new_param :: acc) state4
          else parse_macro_params (new_param :: acc) state3
      | _ -> raise (SyntaxError ("期望宏参数类型：表达式、语句或类型", snd (current_token state2))))
  | _ -> raise (SyntaxError ("期望宏参数名", snd (current_token state)))

(** 自然语言算术延续表达式 *)
let parse_natural_arithmetic_continuation expr _param_name state =
  let token_after, _ = current_token state in
  match token_after with
  | OfParticle ->
      (* 「减一」之「阶乘」 *)
      let state1 = advance_parser state in
      let func_name, state2 = parse_identifier state1 in
      (FunCallExpr (VarExpr func_name, [ expr ]), state2)
  | _ -> (expr, state)

(** 解析自然语言函数定义 *)
let rec parse_natural_function_definition state =
  let state1 = expect_token state DefineKeyword in
  (* 解析函数名：定义「函数名」 *)
  let function_name, state2 = parse_identifier state1 in
  (* 期望「接受」关键字 *)
  let state3 = expect_token state2 AcceptKeyword in
  (* 解析参数名：接受「参数」 *)
  let param_name, state4 = parse_identifier state3 in
  (* 期望冒号（ASCII或中文） *)
  let state5 = Parser_utils.expect_token_punctuation state4 Parser_utils.is_colon "colon" in
  let state5_clean = skip_newlines state5 in

  (* 解析函数体 - 支持自然语言表达式 *)
  let body_expr, state6 = parse_natural_function_body param_name state5_clean in

  (* 将自然语言函数定义转换为传统的函数表达式 *)
  let fun_expr = FunExpr ([ param_name ], body_expr) in

  (* 进行语义分析（可选，用于调试和优化提示） *)
  (try
     let semantic_info =
       Nlf_semantic.analyze_natural_function_semantics function_name [ param_name ] body_expr
     in
     let validation_errors = Nlf_semantic.validate_semantic_consistency semantic_info in
     if List.length validation_errors > 0 && false then ( (* 暂时禁用输出 *)
       log_debug (Printf.sprintf "函数「%s」语义分析:\n%s" function_name 
         (String.concat "\n" validation_errors));
       flush_all ()
     )
   with _ -> ()); (* 忽略语义分析错误，不影响编译 *)
  (LetExpr (function_name, fun_expr, VarExpr function_name), state6)

(** 解析自然语言函数体 *)
and parse_natural_function_body param_name state =
  let token, _ = current_token state in
  match token with
  | WhenKeyword ->
      (* 解析条件表达式：当「参数」为「值」时返回「结果」 *)
      parse_natural_conditional param_name state
  | ElseReturnKeyword ->
      (* 解析默认返回：否则返回「表达式」 *)
      let state1 = advance_parser state in
      parse_natural_expression param_name state1
  | InputKeyword ->
      (* 直接处理输入模式 *)
      parse_natural_expression param_name state
  | _ ->
      (* 解析一般表达式 *)
      parse_natural_expression param_name state

(** 解析自然语言条件表达式 *)
and parse_natural_conditional param_name state =
  let state1 = expect_token state WhenKeyword in
  (* 解析参数引用 *)
  let param_ref, state2 = parse_identifier state1 in

  (* 解析条件关系词 *)
  let token, _ = current_token state2 in
  let comparison_op, state3 =
    match token with
    | IsKeyword ->
        let state_next = advance_parser state2 in
        (Eq, state_next)
    | AsForKeyword ->
        (* 「为」在wenyan语法中 *)
        let state_next = advance_parser state2 in
        (Eq, state_next)
    | QuotedIdentifierToken "为" ->
        (* 处理「为」作为标识符的情况 *)
        let state_next = advance_parser state2 in
        (Eq, state_next)
    | EqualToKeyword ->
        let state_next = advance_parser state2 in
        (Eq, state_next)
    | LessThanEqualToKeyword ->
        let state_next = advance_parser state2 in
        (Le, state_next)
    | _ -> raise (SyntaxError ("期望条件关系词，如「为」或「等于」", snd (current_token state2)))
  in

  (* 解析条件值 *)
  let condition_value, state4 = parse_expression state3 in

  (* 期望「时返回」 *)
  let state5 = expect_token state4 ReturnWhenKeyword in

  (* 解析返回值 *)
  let return_value, state6 = parse_natural_expression param_name state5 in

  (* 检查是否有else子句 *)
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

(** 解析自然语言表达式 *)
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

(** 解析算术表达式（支持自然语言运算符）*)
and parse_natural_arithmetic_expression param_name state =
  let left_expr, state1 = parse_natural_primary param_name state in
  parse_natural_arithmetic_tail left_expr param_name state1

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

and parse_natural_primary param_name state =
  let token, _ = current_token state in
  match token with
  | QuotedIdentifierToken name ->
      let state1 = advance_parser state in
      (* 检查自然语言运算模式 *)
      parse_natural_identifier_patterns name param_name state1
  | InputKeyword ->
      (* 处理「输入」关键字 *)
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

(* 解析标识符相关的自然语言模式 *)
and parse_natural_identifier_patterns name param_name state =
  let token_after, _ = current_token state in
  match token_after with
  | OfParticle ->
      (* 「输入」之「阶乘」 -> 阶乘(输入) *)
      let state2 = advance_parser state in
      let func_name, state3 = parse_identifier state2 in
      (FunCallExpr (VarExpr func_name, [ VarExpr name ]), state3)
  | MinusOneKeyword ->
      (* 处理「减一」模式 *)
      let state2 = advance_parser state in
      let minus_one_expr = BinaryOpExpr (VarExpr name, Sub, LitExpr (IntLit 1)) in
      parse_natural_arithmetic_continuation minus_one_expr param_name state2
  | _ -> (VarExpr name, state)

(* 解析「输入」关键字相关的模式 *)
and parse_natural_input_patterns param_name state =
  let token_after, _ = current_token state in
  match token_after with
  | MinusOneKeyword ->
      (* 「输入减一」 *)
      let state1 = advance_parser state in
      let minus_one_expr = BinaryOpExpr (VarExpr param_name, Sub, LitExpr (IntLit 1)) in
      parse_natural_arithmetic_continuation minus_one_expr param_name state1
  | SmallKeyword ->
      (* 「输入小」开始的比较表达式 *)
      let state1 = advance_parser state in
      parse_natural_comparison_patterns param_name state1
  | _ -> (VarExpr param_name, state)

(* 解析比较模式，如「小于等于」 *)
and parse_natural_comparison_patterns param_name state =
  let token_after, _ = current_token state in
  match token_after with
  | LessThanEqualToKeyword ->
      (* 「输入小于等于1」 *)
      let state1 = advance_parser state in
      let right_expr, state2 = parse_expression state1 in
      (BinaryOpExpr (VarExpr param_name, Le, right_expr), state2)
  | _ ->
      (* 其他情况，返回输入变量 *)
      (VarExpr param_name, state)