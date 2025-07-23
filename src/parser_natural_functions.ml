(** 骆言自然语言函数定义解析器 - 模块化重构版本 *)

open Ast
open Lexer
open Parser_utils
open Utils.Base_formatter

(** 初始化模块日志器 *)
let log_debug, _ = Logger_utils.init_debug_error_loggers "ParserNaturalFunctions"

(** 位置转换函数 *)
let lexer_pos_to_compiler_pos (pos : Lexer.position) : Compiler_errors.position =
  { filename = pos.filename; line = pos.line; column = pos.column }

(** 解析函数头部：「定义」「函数名」「接受」「参数」 *)
let parse_natural_function_header ~expect_token ~parse_identifier ~skip_newlines state =
  (* 支持多种函数定义开始关键字：「定义」、「创建」等 *)
  let state1 = 
    let token, _ = current_token state in
    match token with
    | DefineKeyword -> expect_token state DefineKeyword
    | QuotedIdentifierToken "定义" -> advance_parser state
    | QuotedIdentifierToken "创建" -> advance_parser state
    | _ -> expect_token state DefineKeyword  (* 默认期望DefineKeyword以保持向后兼容 *)
  in
  let function_name, state2 = parse_identifier state1 in
  
  (* 检查是否有更多tokens用于完整的函数签名 *)
  let token, _ = current_token state2 in
  match token with
  | EOF -> 
      (* 简单的函数定义，只有定义关键字和函数名 *)
      ("", function_name, state2)
  | QuotedIdentifierToken "函数" ->
      (* 跳过函数类型关键字 *)
      let state2_5 = advance_parser state2 in
      ("函数", function_name, state2_5)
  | QuotedIdentifierToken "方法" ->
      (* 跳过函数类型关键字 *)
      let state2_5 = advance_parser state2 in
      ("方法", function_name, state2_5)
  | AcceptKeyword | QuotedIdentifierToken "接受" ->
      (* 完整的函数签名，包含参数 *)
      let state3 = 
        match token with
        | AcceptKeyword -> expect_token state2 AcceptKeyword
        | QuotedIdentifierToken "接受" -> advance_parser state2
        | _ -> state2
      in
      let _param_name, state4 = parse_identifier state3 in
      let state5 = 
        try 
          Parser_utils.expect_token_punctuation state4 Parser_utils.is_colon "colon"
        with 
        | _ -> state4  (* 如果没有冒号，继续处理 *)
      in
      let state5_clean = skip_newlines state5 in
      ("带参数", function_name, state5_clean)
  | _ -> 
      (* 其他情况，只返回函数名 *)
      ("", function_name, state2)

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
  | QuotedIdentifierToken "等于" ->
      let state_next = advance_parser state in
      (Eq, state_next)
  | QuotedIdentifierToken "大于" ->
      let state_next = advance_parser state in
      (Gt, state_next)
  | QuotedIdentifierToken "小于" ->
      let state_next = advance_parser state in
      (Lt, state_next)
  | QuotedIdentifierToken "大于等于" ->
      let state_next = advance_parser state in
      (Ge, state_next)
  | QuotedIdentifierToken "小于等于" ->
      let state_next = advance_parser state in
      (Le, state_next)
  | QuotedIdentifierToken "不等于" ->
      let state_next = advance_parser state in
      (Neq, state_next)
  | EqualToKeyword ->
      let state_next = advance_parser state in
      (Eq, state_next)
  | LessThanEqualToKeyword ->
      let state_next = advance_parser state in
      (Le, state_next)
  | GreaterThanWenyan ->
      let state_next = advance_parser state in
      (Gt, state_next)
  | LessThanWenyan ->
      let state_next = advance_parser state in
      (Lt, state_next)
  | _ -> (
      let pos = lexer_pos_to_compiler_pos (snd (current_token state)) in
      match Compiler_errors.syntax_error "期望条件关系词，如「为」、「等于」、「大于」、「小于」等" pos with
      | Error error_info ->
          raise
            (Parser_utils.SyntaxError
               (Compiler_errors.format_error_info error_info, snd (current_token state)))
      | Ok _ -> assert false (* 不可达代码：syntax_error总是返回Error *))

(** 解析自然语言条件表达式 *)
let rec parse_natural_conditional ~expect_token ~parse_identifier ~skip_newlines ~parse_expr
    param_name state =
  (* 支持多种条件表达式开始关键字：「当」、「如果」等 *)
  let state1 = 
    let token, _ = current_token state in
    match token with
    | WhenKeyword -> expect_token state WhenKeyword
    | IfKeyword -> expect_token state IfKeyword  
    | QuotedIdentifierToken "如果" -> advance_parser state
    | QuotedIdentifierToken "当" -> advance_parser state
    | _ -> expect_token state WhenKeyword  (* 默认期望WhenKeyword以保持向后兼容 *)
  in
  let param_ref, state2 = parse_identifier state1 in
  let comparison_op, state3 = parse_conditional_relation_word state2 in
  let condition_value, state4 = parse_expr state3 in
  (* 支持多种条件返回关键字：「时返回」、「那么」、「时」等 *)
  let state5 = 
    let token, _ = current_token state4 in
    match token with
    | ReturnWhenKeyword -> expect_token state4 ReturnWhenKeyword
    | ThenKeyword -> expect_token state4 ThenKeyword
    | QuotedIdentifierToken "那么" -> advance_parser state4
    | QuotedIdentifierToken "时" -> advance_parser state4
    | QuotedIdentifierToken "时返回" -> advance_parser state4
    | _ -> expect_token state4 ReturnWhenKeyword  (* 默认期望ReturnWhenKeyword以保持向后兼容 *)
  in
  let return_value, state6 = parse_natural_expr ~parse_expr param_name state5 in
  let state6_clean = skip_newlines state6 in
  (param_ref, comparison_op, condition_value, return_value, state6_clean)

(** 解析自然语言算术运算连续表达式 *)
and parse_natural_arithmetic_continuation ~parse_expr base_expr param_name state =
  let token, _ = current_token state in
  match token with
  | PlusKeyword ->
      let state1 = advance_parser state in
      let right_expr, state2 = parse_expr state1 in
      let new_expr = BinaryOpExpr (base_expr, Add, right_expr) in
      parse_natural_arithmetic_continuation ~parse_expr new_expr param_name state2
  | SubtractKeyword ->
      let state1 = advance_parser state in
      let right_expr, state2 = parse_expr state1 in
      let new_expr = BinaryOpExpr (base_expr, Sub, right_expr) in
      parse_natural_arithmetic_continuation ~parse_expr new_expr param_name state2
  | MultiplyKeyword ->
      let state1 = advance_parser state in
      let right_expr, state2 = parse_expr state1 in
      let new_expr = BinaryOpExpr (base_expr, Mul, right_expr) in
      parse_natural_arithmetic_continuation ~parse_expr new_expr param_name state2
  | DivideKeyword ->
      let state1 = advance_parser state in
      let right_expr, state2 = parse_expr state1 in
      let new_expr = BinaryOpExpr (base_expr, Div, right_expr) in
      parse_natural_arithmetic_continuation ~parse_expr new_expr param_name state2
  | _ -> (base_expr, state)

(** 解析自然语言比较模式 *)
and parse_natural_comparison_patterns ~parse_expr param_name state =
  let token_after, _ = current_token state in
  match token_after with
  | LessThanEqualToKeyword ->
      let state1 = advance_parser state in
      let right_expr, state2 = parse_expr state1 in
      (BinaryOpExpr (VarExpr param_name, Le, right_expr), state2)
  | _ -> (VarExpr param_name, state)

(** 解析自然语言表达式 *)
and parse_natural_expr ~parse_expr param_name state =
  let token, _ = current_token state in
  match token with
  | InputKeyword -> (
      let state1 = advance_parser state in
      let next_token, _ = current_token state1 in
      match next_token with
      | PlusKeyword ->
          let state2 = advance_parser state1 in
          let right_expr, state3 = parse_expr state2 in
          let plus_expr = BinaryOpExpr (VarExpr param_name, Add, right_expr) in
          parse_natural_arithmetic_continuation ~parse_expr plus_expr param_name state3
      | SubtractKeyword ->
          let state2 = advance_parser state1 in
          let right_expr, state3 = parse_expr state2 in
          let minus_expr = BinaryOpExpr (VarExpr param_name, Sub, right_expr) in
          parse_natural_arithmetic_continuation ~parse_expr minus_expr param_name state3
      | MultiplyKeyword ->
          let state2 = advance_parser state1 in
          let right_expr, state3 = parse_expr state2 in
          let mul_expr = BinaryOpExpr (VarExpr param_name, Mul, right_expr) in
          parse_natural_arithmetic_continuation ~parse_expr mul_expr param_name state3
      | DivideKeyword ->
          let state2 = advance_parser state1 in
          let right_expr, state3 = parse_expr state2 in
          let div_expr = BinaryOpExpr (VarExpr param_name, Div, right_expr) in
          parse_natural_arithmetic_continuation ~parse_expr div_expr param_name state3
      | _ -> (VarExpr param_name, state1))
  | MinusOneKeyword ->
      let state1 = advance_parser state in
      let minus_one_expr = BinaryOpExpr (VarExpr param_name, Sub, LitExpr (IntLit 1)) in
      parse_natural_arithmetic_continuation ~parse_expr minus_one_expr param_name state1
  | SmallKeyword ->
      let state1 = advance_parser state in
      parse_natural_comparison_patterns ~parse_expr param_name state1
  | _ -> (VarExpr param_name, state)

(** 解析自然语言函数体 *)
let parse_natural_function_body ~expect_token ~parse_identifier ~skip_newlines ~parse_expr
    param_name state =
  let token, _ = current_token state in
  match token with
  | WhenKeyword ->
      let param_ref, comparison_op, condition_value, return_value, state_clean =
        parse_natural_conditional ~expect_token ~parse_identifier ~skip_newlines ~parse_expr
          param_name state
      in
      let token_after, _ = current_token state_clean in
      if token_after = ElseReturnKeyword then
        let state_else = advance_parser state_clean in
        let else_expr, state_final = parse_natural_expr ~parse_expr param_name state_else in
        let condition_expr = BinaryOpExpr (VarExpr param_ref, comparison_op, condition_value) in
        (CondExpr (condition_expr, return_value, else_expr), state_final)
      else
        let condition_expr = BinaryOpExpr (VarExpr param_ref, comparison_op, condition_value) in
        (CondExpr (condition_expr, return_value, LitExpr UnitLit), state_clean)
  | ElseReturnKeyword ->
      let state1 = advance_parser state in
      parse_expr state1
  | InputKeyword -> parse_natural_expr ~parse_expr param_name state
  | _ -> parse_natural_expr ~parse_expr param_name state

(** 执行语义分析 *)
let perform_semantic_analysis function_name param_name body_expr =
  try
    let semantic_info =
      Nlf_semantic.analyze_natural_function_semantics function_name [ param_name ] body_expr
    in
    let validation_errors = Nlf_semantic.validate_semantic_consistency semantic_info in
    if List.length validation_errors > 0 && false then (
      log_debug
        (concat_strings [ "函数「"; function_name; "」语义分析:\n"; String.concat "\n" validation_errors ]);
      flush_all ())
  with _ -> ()

(** 主要的自然语言函数定义解析函数 *)
let parse_natural_function_definition ~expect_token ~parse_identifier ~skip_newlines ~parse_expr
    state =
  let function_name, param_name, state_clean =
    parse_natural_function_header ~expect_token ~parse_identifier ~skip_newlines state
  in
  let body_expr, state_final =
    parse_natural_function_body ~expect_token ~parse_identifier ~skip_newlines ~parse_expr
      param_name state_clean
  in
  let fun_expr = FunExpr ([ param_name ], body_expr) in
  perform_semantic_analysis function_name param_name body_expr;
  (LetExpr (function_name, fun_expr, VarExpr function_name), state_final)
