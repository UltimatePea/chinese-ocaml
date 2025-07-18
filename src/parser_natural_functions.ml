(** 骆言自然语言函数定义解析器 - 模块化重构版本 *)

open Ast
open Lexer
open Parser_utils

(** 导入必要的函数 *)
let skip_newlines = ref (fun _ -> failwith "skip_newlines not initialized")
let parse_identifier = ref (fun _ -> failwith "parse_identifier not initialized")
let parse_literal = ref (fun _ -> failwith "parse_literal not initialized")
let expect_token = ref (fun _ _ -> failwith "expect_token not initialized")

(** 前向声明 - 需要从Parser_exprs模块导入 *)
let parse_expr = ref (fun _ -> failwith "parse_expr not initialized")
let () = ()  (* 占位符 *)

(** 初始化模块日志器 *)
let log_debug, _ = Logger_utils.init_debug_error_loggers "ParserNaturalFunctions"

(** 位置转换函数 *)
let lexer_pos_to_compiler_pos (pos : Lexer.position) : Compiler_errors.position =
  { filename = pos.filename; line = pos.line; column = pos.column }

(** 解析函数头部：「定义」「函数名」「接受」「参数」 *)
let parse_natural_function_header state =
  let state1 = !expect_token state DefineKeyword in
  let function_name, state2 = !parse_identifier state1 in
  let state3 = !expect_token state2 AcceptKeyword in
  let param_name, state4 = !parse_identifier state3 in
  let state5 = Parser_utils.expect_token_punctuation state4 Parser_utils.is_colon "colon" in
  let state5_clean = !skip_newlines state5 in
  (function_name, param_name, state5_clean)

(** 解析条件关系词 *)
let parse_conditional_relation_word state =
  let token, _ = current_token state in
  match token with
  | IsKeyword ->
      let state_next = advance_parser state in
      (Eq, state_next)
  | AsForKeyword ->
      let state_next = advance_parser state in
      (Eq, state_next)
  | QuotedIdentifierToken "为" ->
      let state_next = advance_parser state in
      (Eq, state_next)
  | EqualToKeyword ->
      let state_next = advance_parser state in
      (Eq, state_next)
  | LessThanEqualToKeyword ->
      let state_next = advance_parser state in
      (Le, state_next)
  | _ ->
      let pos = lexer_pos_to_compiler_pos (snd (current_token state)) in
      match Compiler_errors.syntax_error "期望条件关系词，如「为」或「等于」" pos with
      | Error error_info ->
          raise
            (Parser_utils.SyntaxError
               (Compiler_errors.format_error_info error_info, snd (current_token state)))
      | Ok _ -> failwith "不应该到达此处"

(** 解析自然语言条件表达式 *)
let rec parse_natural_conditional param_name state =
  let state1 = !expect_token state WhenKeyword in
  let param_ref, state2 = !parse_identifier state1 in
  let comparison_op, state3 = parse_conditional_relation_word state2 in
  let condition_value, state4 = !parse_expr state3 in
  let state5 = !expect_token state4 ReturnWhenKeyword in
  let return_value, state6 = parse_natural_expr param_name state5 in
  let state6_clean = !skip_newlines state6 in
  (param_ref, comparison_op, condition_value, return_value, state6_clean)

(** 解析自然语言算术运算连续表达式 *)
and parse_natural_arithmetic_continuation base_expr param_name state =
  let token, _ = current_token state in
  match token with
  | PlusKeyword ->
      let state1 = advance_parser state in
      let right_expr, state2 = !parse_expr state1 in
      let new_expr = BinaryOpExpr (base_expr, Add, right_expr) in
      parse_natural_arithmetic_continuation new_expr param_name state2
  | SubtractKeyword ->
      let state1 = advance_parser state in
      let right_expr, state2 = !parse_expr state1 in
      let new_expr = BinaryOpExpr (base_expr, Sub, right_expr) in
      parse_natural_arithmetic_continuation new_expr param_name state2
  | MultiplyKeyword ->
      let state1 = advance_parser state in
      let right_expr, state2 = !parse_expr state1 in
      let new_expr = BinaryOpExpr (base_expr, Mul, right_expr) in
      parse_natural_arithmetic_continuation new_expr param_name state2
  | DivideKeyword ->
      let state1 = advance_parser state in
      let right_expr, state2 = !parse_expr state1 in
      let new_expr = BinaryOpExpr (base_expr, Div, right_expr) in
      parse_natural_arithmetic_continuation new_expr param_name state2
  | _ -> (base_expr, state)

(** 解析自然语言比较模式 *)
and parse_natural_comparison_patterns param_name state =
  let token_after, _ = current_token state in
  match token_after with
  | LessThanEqualToKeyword ->
      let state1 = advance_parser state in
      let right_expr, state2 = !parse_expr state1 in
      (BinaryOpExpr (VarExpr param_name, Le, right_expr), state2)
  | _ ->
      (VarExpr param_name, state)

(** 解析自然语言表达式 *)
and parse_natural_expr param_name state =
  let token, _ = current_token state in
  match token with
  | InputKeyword ->
      let state1 = advance_parser state in
      let next_token, _ = current_token state1 in
      (match next_token with
       | PlusKeyword ->
           let state2 = advance_parser state1 in
           let right_expr, state3 = !parse_expr state2 in
           let plus_expr = BinaryOpExpr (VarExpr param_name, Add, right_expr) in
           parse_natural_arithmetic_continuation plus_expr param_name state3
       | SubtractKeyword ->
           let state2 = advance_parser state1 in
           let right_expr, state3 = !parse_expr state2 in
           let minus_expr = BinaryOpExpr (VarExpr param_name, Sub, right_expr) in
           parse_natural_arithmetic_continuation minus_expr param_name state3
       | MultiplyKeyword ->
           let state2 = advance_parser state1 in
           let right_expr, state3 = !parse_expr state2 in
           let mul_expr = BinaryOpExpr (VarExpr param_name, Mul, right_expr) in
           parse_natural_arithmetic_continuation mul_expr param_name state3
       | DivideKeyword ->
           let state2 = advance_parser state1 in
           let right_expr, state3 = !parse_expr state2 in
           let div_expr = BinaryOpExpr (VarExpr param_name, Div, right_expr) in
           parse_natural_arithmetic_continuation div_expr param_name state3
       | _ -> (VarExpr param_name, state1))
  | MinusOneKeyword ->
      let state1 = advance_parser state in
      let minus_one_expr = BinaryOpExpr (VarExpr param_name, Sub, LitExpr (IntLit 1)) in
      parse_natural_arithmetic_continuation minus_one_expr param_name state1
  | SmallKeyword ->
      let state1 = advance_parser state in
      parse_natural_comparison_patterns param_name state1
  | _ -> (VarExpr param_name, state)

(** 解析自然语言函数体 *)
let parse_natural_function_body param_name state =
  let token, _ = current_token state in
  match token with
  | WhenKeyword ->
      let param_ref, comparison_op, condition_value, return_value, state_clean = 
        parse_natural_conditional param_name state in
      let token_after, _ = current_token state_clean in
      if token_after = ElseReturnKeyword then
        let state_else = advance_parser state_clean in
        let else_expr, state_final = parse_natural_expr param_name state_else in
        let condition_expr = BinaryOpExpr (VarExpr param_ref, comparison_op, condition_value) in
        (CondExpr (condition_expr, return_value, else_expr), state_final)
      else
        let condition_expr = BinaryOpExpr (VarExpr param_ref, comparison_op, condition_value) in
        (CondExpr (condition_expr, return_value, LitExpr UnitLit), state_clean)
  | ElseReturnKeyword ->
      let state1 = advance_parser state in
      parse_natural_expr param_name state1
  | InputKeyword ->
      parse_natural_expr param_name state
  | _ ->
      parse_natural_expr param_name state

(** 执行语义分析 *)
let perform_semantic_analysis function_name param_name body_expr =
  try
    let semantic_info =
      Nlf_semantic.analyze_natural_function_semantics function_name [param_name] body_expr
    in
    let validation_errors = Nlf_semantic.validate_semantic_consistency semantic_info in
    if List.length validation_errors > 0 && false then (
      log_debug
        (Printf.sprintf "函数「%s」语义分析:\n%s" function_name (String.concat "\n" validation_errors));
      flush_all ())
  with _ -> ()

(** 初始化parse_expr引用 *)
let set_parse_expr_ref f =
  parse_expr := f

(** 初始化所有函数引用 *)
let set_parser_functions_ref ~skip_newlines_f ~parse_identifier_f ~parse_literal_f ~expect_token_f =
  skip_newlines := skip_newlines_f;
  parse_identifier := parse_identifier_f;
  parse_literal := parse_literal_f;
  expect_token := expect_token_f

(** 主要的自然语言函数定义解析函数 *)
let parse_natural_function_definition state =
  let function_name, param_name, state_clean = parse_natural_function_header state in
  let body_expr, state_final = parse_natural_function_body param_name state_clean in
  let fun_expr = FunExpr ([param_name], body_expr) in
  perform_semantic_analysis function_name param_name body_expr;
  (LetExpr (function_name, fun_expr, VarExpr function_name), state_final)