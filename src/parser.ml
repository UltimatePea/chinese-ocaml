(** 骆言语法分析器 - Chinese Programming Language Parser *)

open Ast
open Lexer

(** 语法错误 *)
exception SyntaxError of string * position

(** 解析器状态 *)
type parser_state = {
  token_list: positioned_token list;
  current_pos: int;
}

(** 创建解析状态 *)
let create_parser_state token_list = {
  token_list;
  current_pos = 0;
}

(** 获取当前词元 *)
let current_token state =
  if state.current_pos >= List.length state.token_list then
    (EOF, { line = 0; column = 0; filename = "" })
  else
    List.nth state.token_list state.current_pos

(** 查看下一个词元（不消费） *)
let peek_token state =
  let next_pos = state.current_pos + 1 in
  if next_pos >= List.length state.token_list then
    (EOF, { line = 0; column = 0; filename = "" })
  else
    List.nth state.token_list next_pos

(** 向前移动 *)
let advance_parser state =
  if state.current_pos >= List.length state.token_list then state
  else { state with current_pos = state.current_pos + 1 }

(** 期望特定词元 *)
let expect_token state expected_token =
  let (token, pos) = current_token state in
  if token = expected_token then
    advance_parser state
  else
    raise (SyntaxError ("期望 " ^ show_token expected_token ^ "，但遇到 " ^ show_token token, pos))

(** 检查是否为特定词元 *)
let is_token state target_token =
  let (token, _) = current_token state in
  token = target_token

(** 解析标识符（严格引用模式）*)
let parse_identifier state =
  let (token, pos) = current_token state in
  match token with
  | QuotedIdentifierToken name -> (name, advance_parser state)
  | IdentifierToken name -> 
    (* 允许普通标识符 *)
    (name, advance_parser state)
  | _ -> raise (SyntaxError ("期望引用标识符「名称」，但遇到 " ^ show_token token, pos))

(** 解析标识符（严格引用模式下的关键字处理）*)
let parse_identifier_allow_keywords state =
  (* 允许各种标识符形式，包括普通标识符和引用标识符 *)
  let (token, pos) = current_token state in
  match token with
  | QuotedIdentifierToken name -> 
    (name, advance_parser state)
  | IdentifierToken name -> 
    (* 允许普通标识符 *)
    (name, advance_parser state)
  | EmptyKeyword ->
    (* 特殊处理：在模式匹配中，"空" 可以作为构造器名 *)
    ("空", advance_parser state)
  | _ -> 
    raise (SyntaxError ("期望引用标识符「名称」，但遇到 " ^ show_token token, pos))

(** 中文标点符号辅助函数 *)
let is_left_paren token = token = LeftParen || token = ChineseLeftParen
let is_right_paren token = token = RightParen || token = ChineseRightParen
let is_left_bracket token = token = LeftBracket || token = ChineseLeftBracket
let is_right_bracket token = token = RightBracket || token = ChineseRightBracket
let is_left_brace token = token = LeftBrace
let is_right_brace token = token = RightBrace
let is_comma token = token = Comma || token = ChineseComma || token = AncientCommaKeyword
let is_semicolon token = token = Semicolon || token = ChineseSemicolon || token = AfterThatKeyword
let is_colon token = token = Colon || token = ChineseColon
let is_pipe token = token = Pipe || token = ChinesePipe
let is_arrow token = token = Arrow || token = ChineseArrow
let is_double_arrow token = token = DoubleArrow || token = ChineseDoubleArrow
let is_assign_arrow token = token = AssignArrow || token = ChineseAssignArrow
let is_left_array token = token = LeftArray || token = ChineseLeftArray
let is_right_array token = token = RightArray || token = ChineseRightArray

(** 检查当前token是否为指定的标点符号（ASCII或中文） *)
let is_punctuation state check_fn =
  let (token, _) = current_token state in
  check_fn token

(** 期望指定的标点符号（ASCII或中文版本） *)
let expect_token_punctuation state check_fn description =
  let (token, pos) = current_token state in
  if check_fn token then
    advance_parser state
  else
    raise (SyntaxError ("期望 " ^ description ^ "，但遇到 " ^ show_token token, pos))

(** 解析wenyan风格的复合标识符（可能包含多个部分） *)
let parse_wenyan_compound_identifier state =
  let rec collect_parts parts state =
    let (token, pos) = current_token state in
    match token with
    | IdentifierToken name -> 
      collect_parts (name :: parts) (advance_parser state)
    | QuotedIdentifierToken name ->
      collect_parts (name :: parts) (advance_parser state)
    | IdentifierTokenSpecial name ->
      (* 支持特殊标识符如"数值" *)
      collect_parts (name :: parts) (advance_parser state)
    | NumberKeyword -> 
      collect_parts ("数" :: parts) (advance_parser state)
    | EmptyKeyword ->
      collect_parts ("空" :: parts) (advance_parser state)
    | ValueKeyword -> 
      (* ValueKeyword 不应该被包含在标识符中，它是语法分隔符 *)
      if parts = [] then
        raise (SyntaxError ("期望标识符，但遇到 " ^ show_token token, pos))
      else
        (String.concat "" (List.rev parts), state)
    | _ -> 
      if parts = [] then
        raise (SyntaxError ("期望标识符，但遇到 " ^ show_token token, pos))
      else
        (String.concat "" (List.rev parts), state)
  in
  collect_parts [] state

(** 解析字面量 *)
let parse_literal state =
  let (token, pos) = current_token state in
  match token with
  | IntToken n -> (IntLit n, advance_parser state)
  | FloatToken f -> (FloatLit f, advance_parser state)
  | StringToken s -> (StringLit s, advance_parser state)
  | BoolToken b -> (BoolLit b, advance_parser state)
  | _ -> raise (SyntaxError ("期望字面量，但遇到 " ^ show_token token, pos))

(** 解析二元运算符 *)
let token_to_binary_op token =
  match token with
  | Plus -> Some Add
  | Minus -> Some Sub
  | Star -> Some Mul
  | Multiply -> Some Mul
  | Slash -> Some Div
  | Divide -> Some Div
  | Modulo -> Some Mod
  | Concat -> Some Concat
  | Equal -> Some Eq
  | NotEqual -> Some Neq
  | Less -> Some Lt
  | LessEqual -> Some Le
  | Greater -> Some Gt
  | GreaterEqual -> Some Ge
  | AndKeyword -> Some And
  | OrKeyword -> Some Or
  | _ -> None

(** 运算符优先级 *)
let operator_precedence op =
  match op with
  | Or -> 1
  | And -> 2
  | Eq | Neq | Lt | Le | Gt | Ge -> 3
  | Add | Sub | Concat -> 4
  | Mul | Div | Mod -> 5

(** 解析宏参数 *)
let rec parse_macro_params acc state =
  let (token, _) = current_token state in
  match token with
  | RightParen -> (List.rev acc, state)
  | IdentifierToken param_name ->
    let state1 = advance_parser state in
    let state2 = expect_token state1 Colon in
    let (token, _) = current_token state2 in
    (match token with
     | IdentifierToken "表达式" ->
       let state3 = advance_parser state2 in
       let new_param = ExprParam param_name in
       let (next_token, _) = current_token state3 in
       if next_token = Comma then
         let state4 = advance_parser state3 in
         parse_macro_params (new_param :: acc) state4
       else
         parse_macro_params (new_param :: acc) state3
     | IdentifierToken "语句" ->
       let state3 = advance_parser state2 in
       let new_param = StmtParam param_name in
       let (next_token, _) = current_token state3 in
       if next_token = Comma then
         let state4 = advance_parser state3 in
         parse_macro_params (new_param :: acc) state4
       else
         parse_macro_params (new_param :: acc) state3
     | IdentifierToken "类型" ->
       let state3 = advance_parser state2 in
       let new_param = TypeParam param_name in
       let (next_token, _) = current_token state3 in
       if next_token = Comma then
         let state4 = advance_parser state3 in
         parse_macro_params (new_param :: acc) state4
       else
         parse_macro_params (new_param :: acc) state3
     | _ -> raise (SyntaxError ("期望宏参数类型：表达式、语句或类型", snd (current_token state2))))
  | _ -> raise (SyntaxError ("期望宏参数名", snd (current_token state)))

(** 前向声明 *)
let rec parse_expression state = parse_assignment_expression state
and parse_ancient_function_definition state =
  (* 期望: 夫 函数名 者 受 参数 焉 算法为 表达式 是谓 *)
  let state1 = expect_token state AncientDefineKeyword in (* 夫 *)
  let (function_name, state2) = parse_identifier state1 in
  let state3 = expect_token state2 ThenWenyanKeyword in (* 者 - wenyan then token *)
  let state4 = expect_token state3 AncientReceiveKeyword in (* 受 *)
  let (param_name, state5) = parse_identifier state4 in
  let state6 = expect_token state5 AncientParticleFun in (* 焉 - function parameter particle *)
  let state7 = expect_token state6 AncientAlgorithmKeyword in (* 算法 *)
  let state8 = expect_token state7 ThenGetKeyword in (* 乃 *)
  let state8_clean = skip_newlines state8 in
  let (body_expr, state9) = parse_expression state8_clean in
  let state10 = expect_token state9 AncientEndKeyword in (* 是谓 *)
  
  (* 转换为标准函数表达式 *)
  let fun_expr = FunExpr ([param_name], body_expr) in
  (LetExpr (function_name, fun_expr, VarExpr function_name), state10)

and parse_ancient_match_expression state =
  (* 期望: 观 标识符 之 性 若 模式 则 表达式 余者 则 表达式 观毕 *)
  let state1 = expect_token state AncientObserveKeyword in (* 观 *)
  let (var_name, state2) = parse_identifier state1 in (* 仅解析标识符 *)
  let state3 = expect_token state2 OfParticle in (* 之 *)
  let state4 = expect_token state3 AncientNatureKeyword in (* 性 *)
  let expr = VarExpr var_name in (* 创建变量表达式 *)
  let state4_clean = skip_newlines state4 in
  
  (* 解析匹配分支 *)
  let rec parse_ancient_match_cases cases state =
    let (token, _) = current_token state in
    match token with
    | AncientObserveEndKeyword -> (List.rev cases, advance_parser state) (* 观毕 *)
    | IfWenyanKeyword -> (* 若 *)
      let state1 = advance_parser state in
      let (pattern, state2) = parse_pattern state1 in
      let state3 = expect_token state2 AncientThenKeyword in (* 则 *)
      let state4 = expect_token state3 AncientAnswerKeyword in (* 答 *)
      let (case_expr, state5) = parse_expression state4 in
      let state5_clean = skip_newlines state5 in
      let branch = { pattern = pattern; guard = None; expr = case_expr } in
      parse_ancient_match_cases (branch :: cases) state5_clean
    | AncientOtherwiseKeyword -> (* 余者 *)
      let state1 = advance_parser state in
      let state2 = expect_token state1 AncientThenKeyword in (* 则 *)
      let state3 = expect_token state2 AncientAnswerKeyword in (* 答 *)
      let (default_expr, state4) = parse_expression state3 in
      let state4_clean = skip_newlines state4 in
      let (token2, _) = current_token state4_clean in
      let default_branch = { pattern = WildcardPattern; guard = None; expr = default_expr } in
      if token2 = AncientObserveEndKeyword then
        let state5 = advance_parser state4_clean in
        (List.rev (default_branch :: cases), state5)
      else
        parse_ancient_match_cases (default_branch :: cases) state4_clean
    | _ -> raise (SyntaxError ("期望匹配分支或观毕", snd (current_token state)))
  in
  
  let (cases, state5) = parse_ancient_match_cases [] state4_clean in
  (MatchExpr (expr, cases), state5)

(** 解析古雅体列表表达式 *)
and parse_ancient_list_expression state =
  (* 期望: 列开始 元素1 其一 元素2 其二 元素3 其三 列结束 *)
  let state1 = expect_token state AncientListStartKeyword in (* 列开始 *)
  let rec parse_ancient_list_elements elements element_count state =
    let (token, _) = current_token state in
    match token with
    | AncientListEndKeyword -> 
      (ListExpr (List.rev elements), advance_parser state) (* 列结束 *)
    | _ ->
      let (expr, state1) = parse_expression state in
      let state2 = (match element_count with
        | 0 -> expect_token state1 AncientItsFirstKeyword    (* 其一 *)
        | 1 -> expect_token state1 AncientItsSecondKeyword   (* 其二 *)
        | 2 -> expect_token state1 AncientItsThirdKeyword    (* 其三 *)
        | _ -> 
          (* 对于更多元素，可以继续使用其一、其二、其三的模式，或者直接解析到列结束 *)
          let (next_token, _) = current_token state1 in
          if next_token = AncientListEndKeyword then state1
          else expect_token state1 AncientItsFirstKeyword  (* 循环使用其一、其二、其三 *)
      ) in
      parse_ancient_list_elements (expr :: elements) (element_count + 1) state2
  in
  parse_ancient_list_elements [] 0 state1

(** 解析古雅体条件表达式 *)
and parse_ancient_conditional_expression state =
  (* 期望: 若 条件 则 表达式 不然 表达式 *)
  let state1 = expect_token state IfWenyanKeyword in (* 若 *)
  let (cond, state2) = parse_expression state1 in
  let state3 = expect_token state2 AncientThenKeyword in (* 则 *)
  let (then_branch, state4) = parse_expression state3 in
  let (token, _) = current_token state4 in
  (* 检查是否有"不然"关键字，如果没有，使用"否则" *)
  let (else_branch, state5) = 
    if token = ElseKeyword then
      let state4a = advance_parser state4 in
      parse_expression state4a
    else
      (* 为了兼容，如果没有明确的else，返回单元值 *)
      (LitExpr UnitLit, state4)
  in
  (CondExpr (cond, then_branch, else_branch), state5)

(** 解析赋值表达式 *)
and parse_assignment_expression state =
  let (left_expr, state1) = parse_or_else_expression state in
  let (token, _) = current_token state1 in
  if token = RefAssign then
    let state2 = advance_parser state1 in
    let (right_expr, state3) = parse_expression state2 in
    (AssignExpr (left_expr, right_expr), state3)
  else
    (left_expr, state1)

(** 解析否则返回表达式 *)
and parse_or_else_expression state =
  let rec parse_tail left_expr state =
    let (token, _) = current_token state in
    if token = OrElseKeyword then
      let state1 = advance_parser state in
      let (right_expr, state2) = parse_or_expression state1 in
      let new_expr = OrElseExpr (left_expr, right_expr) in
      parse_tail new_expr state2
    else
      (left_expr, state)
  in
  let (expr, state1) = parse_or_expression state in
  parse_tail expr state1

(** 解析逻辑或表达式 *)
and parse_or_expression state =
  let rec parse_tail left_expr state =
    let (token, _) = current_token state in
    match token_to_binary_op token with
    | Some Or ->
      let state1 = advance_parser state in
      let (right_expr, state2) = parse_and_expression state1 in
             let new_expr = BinaryOpExpr (left_expr, Or, right_expr) in
      parse_tail new_expr state2
    | _ -> (left_expr, state)
  in
  let (expr, state1) = parse_and_expression state in
  parse_tail expr state1

(** 解析逻辑与表达式 *)
and parse_and_expression state =
  let rec parse_tail left_expr state =
    let (token, _) = current_token state in
    match token_to_binary_op token with
    | Some And ->
      let state1 = advance_parser state in
      let (right_expr, state2) = parse_comparison_expression state1 in
             let new_expr = BinaryOpExpr (left_expr, And, right_expr) in
      parse_tail new_expr state2
    | _ -> (left_expr, state)
  in
  let (expr, state1) = parse_comparison_expression state in
  parse_tail expr state1

(** 解析比较表达式 *)
and parse_comparison_expression state =
  let rec parse_tail left_expr state =
    let (token, _) = current_token state in
    match token_to_binary_op token with
                   | Some (Eq | Neq | Lt | Le | Gt | Ge as op) ->
       let state1 = advance_parser state in
       let (right_expr, state2) = parse_arithmetic_expression state1 in
       let new_expr = BinaryOpExpr (left_expr, op, right_expr) in
       parse_tail new_expr state2
    | _ -> (left_expr, state)
  in
  let (expr, state1) = parse_arithmetic_expression state in
  parse_tail expr state1

(** 解析算术表达式 *)
and parse_arithmetic_expression state =
  let rec parse_tail left_expr state =
    let (token, _) = current_token state in
    match token_to_binary_op token with
         | Some (Add | Sub as op) ->
       let state1 = advance_parser state in
       let (right_expr, state2) = parse_multiplicative_expression state1 in
       let new_expr = BinaryOpExpr (left_expr, op, right_expr) in
       parse_tail new_expr state2
    | _ -> (left_expr, state)
  in
  let (expr, state1) = parse_multiplicative_expression state in
  parse_tail expr state1

(** 解析乘除表达式 *)
and parse_multiplicative_expression state =
  let rec parse_tail left_expr state =
    let (token, _) = current_token state in
    match token_to_binary_op token with
         | Some (Mul | Div | Mod as op) ->
       let state1 = advance_parser state in
       let (right_expr, state2) = parse_unary_expression state1 in
       let new_expr = BinaryOpExpr (left_expr, op, right_expr) in
       parse_tail new_expr state2
    | _ -> (left_expr, state)
  in
  let (expr, state1) = parse_unary_expression state in
  parse_tail expr state1

(** 解析一元表达式 *)
and parse_unary_expression state =
  let (token, _pos) = current_token state in
  match token with
  | Minus ->
    let state1 = advance_parser state in
    let (expr, state2) = parse_unary_expression state1 in
    (UnaryOpExpr (Neg, expr), state2)
  | NotKeyword ->
    let state1 = advance_parser state in
    let (expr, state2) = parse_unary_expression state1 in
    (UnaryOpExpr (Not, expr), state2)
  | Bang ->
    let state1 = advance_parser state in
    let (expr, state2) = parse_unary_expression state1 in
    (DerefExpr expr, state2)
  | _ -> parse_primary_expression state

(** 解析基础表达式 *)
and parse_primary_expression state =
  let (token, pos) = current_token state in
  match token with
  | IntToken _ | FloatToken _ | StringToken _ ->
    let (literal, state1) = parse_literal state in
    (LitExpr literal, state1)
  | BoolToken _ ->
    (* 检查是否是复合标识符的开始（如"真值"、"假值"） *)
    let (token_after, _) = peek_token state in
    (match token_after with
    | IdentifierToken _ ->
      (* 可能是复合标识符，使用parse_identifier_allow_keywords解析 *)
      let (name, state1) = parse_identifier_allow_keywords state in
      parse_function_call_or_variable name state1
    | _ ->
      (* 解析为布尔字面量 *)
      let (literal, state1) = parse_literal state in
      (LitExpr literal, state1))
  | QuotedIdentifierToken name ->
    let state1 = advance_parser state in
    parse_function_call_or_variable name state1
  | IdentifierToken name ->
    (* 允许普通标识符 *)
    let state1 = advance_parser state in
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
  | NumberKeyword ->
    (* 尝试解析wenyan复合标识符，如"数值" *)
    let (name, state1) = parse_wenyan_compound_identifier state in
    parse_function_call_or_variable name state1
  | LeftParen | ChineseLeftParen ->
    let state1 = advance_parser state in
    let (expr, state2) = parse_expression state1 in
    let state3 = expect_token_punctuation state2 is_right_paren "right parenthesis" in
    parse_postfix_expression expr state3
  | IfKeyword -> parse_conditional_expression state
  | IfWenyanKeyword -> parse_ancient_conditional_expression state
  | MatchKeyword -> parse_match_expression state
  | FunKeyword -> parse_function_expression state
  | LetKeyword -> parse_let_expression state
  | DefineKeyword -> parse_natural_function_definition state
  | HaveKeyword -> parse_wenyan_let_expression state
  | SetKeyword -> parse_wenyan_simple_let_expression state
  | AncientDefineKeyword -> parse_ancient_function_definition state
  | AncientObserveKeyword -> parse_ancient_match_expression state
  | AncientListStartKeyword -> parse_ancient_list_expression state
  | LeftBracket | ChineseLeftBracket -> parse_list_expression state
  | LeftArray | ChineseLeftArray -> parse_array_expression state
  | CombineKeyword -> parse_combine_expression state
  | LeftBrace -> 
    let (record_expr, state1) = parse_record_expression state in
    parse_postfix_expression record_expr state1
  | TryKeyword -> parse_try_expression state
  | RaiseKeyword -> parse_raise_expression state
  | RefKeyword -> parse_ref_expression state
  | ModuleKeyword -> parse_module_expression state
  | EmptyKeyword | TypeKeyword | ThenKeyword | ElseKeyword 
  | WithKeyword | TrueKeyword | FalseKeyword | AndKeyword | OrKeyword 
  | NotKeyword | ValueKeyword ->
    (* Handle keywords that might be part of compound identifiers *)
    let (name, state1) = parse_identifier_allow_keywords state in
    parse_function_call_or_variable name state1
  | _ -> raise (SyntaxError ("意外的词元: " ^ show_token token, pos))

(** 解析列表表达式 *)
and parse_list_expression state =
  let state1 = expect_token_punctuation state is_left_bracket "left bracket" in
  let rec parse_list_elements elements has_spread spread_expr state =
    let (token, _) = current_token state in
    match token with
    | RightBracket | ChineseRightBracket -> 
      let state' = advance_parser state in
      if has_spread then
        match spread_expr with
        | Some spread ->
          (* Transform [a, b, ...rest] into (连接 [a, b]) rest *)
          let list_expr = ListExpr (List.rev elements) in
          let concat_list = FunCallExpr (VarExpr "连接", [list_expr]) in
          (FunCallExpr (concat_list, [spread]), state')
        | None -> raise (SyntaxError ("内部错误：缺少展开表达式", snd (current_token state)))
      else
        (ListExpr (List.rev elements), state')
    | TripleDot when not has_spread ->
      (* Handle spread syntax: ...expr *)
      let state1 = advance_parser state in
      let (spread, state2) = parse_expression state1 in
      parse_list_elements elements true (Some spread) state2
    | _ when has_spread ->
      raise (SyntaxError ("展开语法后不能有更多元素", snd (current_token state)))
    | _ ->
      let (expr, state1) = parse_expression state in
      let (token, _) = current_token state1 in
      (match token with
       | Comma | ChineseComma | AncientCommaKeyword ->
         let state2 = advance_parser state1 in
         parse_list_elements (expr :: elements) false None state2
       | RightBracket | ChineseRightBracket ->
         (ListExpr (List.rev (expr :: elements)), advance_parser state1)
       | _ -> raise (SyntaxError ("期望逗号或右方括号", snd (current_token state1))))
  in
  parse_list_elements [] false None state1

(** 解析数组表达式 *)
and parse_array_expression state =
  let state1 = expect_token_punctuation state is_left_array "left array bracket" in
  let rec parse_array_elements elements state =
    let state = skip_newlines state in
    let (token, _) = current_token state in
    match token with
    | RightArray | ChineseRightArray -> 
      (ArrayExpr (List.rev elements), advance_parser state)
    | _ ->
      let (expr, state1) = parse_expression state in
      let (token, _) = current_token state1 in
      (match token with
       | Semicolon | ChineseSemicolon | AfterThatKeyword ->
         let state2 = advance_parser state1 in
         parse_array_elements (expr :: elements) state2
       | RightArray | ChineseRightArray ->
         (ArrayExpr (List.rev (expr :: elements)), advance_parser state1)
       | _ -> raise (SyntaxError ("期望分号或右数组括号", snd (current_token state1))))
  in
  let (array_expr, state2) = parse_array_elements [] state1 in
  parse_postfix_expression array_expr state2

(** 解析函数调用或变量 *)
and parse_function_call_or_variable name state =
  (* Check if this identifier should be part of a compound identifier *)
  let (final_name, state_after_name) = 
    let (token, _) = current_token state in
    match (name, token) with
    | ("去除", EmptyKeyword) ->
      (* Handle "去除空白" specifically *)
      let state1 = advance_parser state in
      let (token2, _) = current_token state1 in
      (match token2 with
       | IdentifierToken "白" ->
         let state2 = advance_parser state1 in
         ("去除空白", state2)
       | _ -> (name, state))
    | _ -> (name, state)
  in
  
  let rec collect_args arg_list state =
    let (token, _) = current_token state in
    match token with
    | LeftParen | IdentifierToken _ | QuotedIdentifierToken _ | IntToken _ | FloatToken _ | StringToken _ | BoolToken _ ->
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
  let (token, _) = current_token state in
  match token with
  | Dot ->
    let state1 = advance_parser state in
    let (token2, _) = current_token state1 in
    (match token2 with
     | LeftParen ->
       (* 数组访问 expr.(index) *)
       let state2 = advance_parser state1 in
       let (index_expr, state3) = parse_expression state2 in
       let state4 = expect_token state3 RightParen in
       (* 检查是否是数组更新 *)
       let (token3, _) = current_token state4 in
       (match token3 with
        | AssignArrow ->
          (* 数组更新 expr.(index) <- value *)
          let state5 = advance_parser state4 in
          let (value_expr, state6) = parse_expression state5 in
          (ArrayUpdateExpr (expr, index_expr, value_expr), state6)
        | _ ->
          (* 只是数组访问 *)
          let new_expr = ArrayAccessExpr (expr, index_expr) in
          parse_postfix_expression new_expr state4)
     | IdentifierToken field_name ->
       (* 记录字段访问 expr.field *)
       let state2 = advance_parser state1 in
       let new_expr = FieldAccessExpr (expr, field_name) in
       parse_postfix_expression new_expr state2
     | _ -> raise (SyntaxError ("期望字段名或左括号", snd (current_token state1))))
  | _ -> (expr, state)

(** 跳过换行符 *)
and skip_newlines state =
  let (token, _) = current_token state in
  if token = Newline then
    skip_newlines (advance_parser state)
  else
    state

(** 解析条件表达式 *)
and parse_conditional_expression state =
  let state1 = expect_token state IfKeyword in
  let (cond, state2) = parse_expression state1 in
  let state3 = expect_token state2 ThenKeyword in
  let state3_clean = skip_newlines state3 in
  let (then_branch, state4) = parse_expression state3_clean in
  let state4_clean = skip_newlines state4 in
  let state5 = expect_token state4_clean ElseKeyword in
  let state5_clean = skip_newlines state5 in
  let (else_branch, state6) = parse_expression state5_clean in
  (CondExpr (cond, then_branch, else_branch), state6)

(** 解析匹配表达式 *)
and parse_match_expression state =
  let state1 = expect_token state MatchKeyword in
  let (expr, state2) = parse_expression state1 in
  let state3 = expect_token state2 WithKeyword in
  let state3_clean = skip_newlines state3 in
  let rec parse_branch_list branch_list state =
    let state = skip_newlines state in
    if is_punctuation state is_pipe then
      let state1 = advance_parser state in
      let (pattern, state2) = parse_pattern state1 in
      (* 检查是否有guard条件 (当 expression) *)
      let (guard, state3) = 
        if is_token state2 WhenKeyword then
          let state2_1 = advance_parser state2 in
          let (guard_expr, state2_2) = parse_expression state2_1 in
          (Some guard_expr, state2_2)
        else
          (None, state2)
      in
      let state4 = expect_token_punctuation state3 is_arrow "arrow" in
      let state4_clean = skip_newlines state4 in
      let (expr, state5) = parse_expression state4_clean in
      let state5_clean = skip_newlines state5 in
      let branch = { pattern; guard; expr } in
      parse_branch_list (branch :: branch_list) state5_clean
    else
      (List.rev branch_list, state)
  in
  let (branch_list, state4) = parse_branch_list [] state3_clean in
  (MatchExpr (expr, branch_list), state4)

(** 解析类型表达式 *)
and parse_type_expression state =
  let (token, pos) = current_token state in
  match token with
  | IntTypeKeyword -> (BaseTypeExpr IntType, advance_parser state)
  | FloatTypeKeyword -> (BaseTypeExpr FloatType, advance_parser state)
  | StringTypeKeyword -> (BaseTypeExpr StringType, advance_parser state)
  | BoolTypeKeyword -> (BaseTypeExpr BoolType, advance_parser state)
  | UnitTypeKeyword -> (BaseTypeExpr UnitType, advance_parser state)
  | ListTypeKeyword -> (TypeVar "列表", advance_parser state)
  | ArrayTypeKeyword -> (TypeVar "数组", advance_parser state)
  | QuotedIdentifierToken name ->
    (* 用户定义的类型必须使用引用语法 *)
    let state1 = advance_parser state in
    (TypeVar name, state1)
  | IdentifierToken name -> 
    (* 在严格模式下，普通标识符不被接受 *)
    raise (SyntaxError ("类型名 '" ^ name ^ "' 必须使用引用语法「" ^ name ^ "」", pos))
  | _ -> raise (SyntaxError ("期望类型表达式", pos))

(** 解析模式 *)
and parse_pattern state =
  let (token, pos) = current_token state in
  match token with
  | Underscore -> (WildcardPattern, advance_parser state)
  | QuotedIdentifierToken _ | EmptyKeyword 
  | FunKeyword | TypeKeyword | LetKeyword | IfKeyword | ThenKeyword | ElseKeyword 
  | MatchKeyword | WithKeyword | TrueKeyword | FalseKeyword | AndKeyword | OrKeyword 
  | NotKeyword | ModuleKeyword | NumberKeyword | ValueKeyword | IdentifierToken _ ->
    (* Use parse_identifier_allow_keywords for pattern names to handle keywords like "空" *)
    let (name, state1) = parse_identifier_allow_keywords state in
    (* Check if this is a constructor pattern (including exception) *)
    let rec parse_constructor_args args state =
      let (token, _) = current_token state in
      match token with
      | Arrow | ChineseArrow | Pipe | ChinesePipe | RightBracket | ChineseRightBracket | RightParen | ChineseRightParen | Comma | ChineseComma | AncientThenKeyword -> 
        (List.rev args, state)
      | _ ->
        let (arg, state1) = parse_pattern state in
        parse_constructor_args (arg :: args) state1
    in
    let (args, state2) = parse_constructor_args [] state1 in
    if args = [] then
      (VarPattern name, state2)
    else
      (ConstructorPattern (name, args), state2)
  | IntToken n -> (LitPattern (IntLit n), advance_parser state)
  | FloatToken f -> (LitPattern (FloatLit f), advance_parser state)
  | StringToken s -> (LitPattern (StringLit s), advance_parser state)
  | BoolToken b -> (LitPattern (BoolLit b), advance_parser state)
  | LeftBracket | ChineseLeftBracket -> parse_list_pattern state
  | _ -> raise (SyntaxError ("意外的模式: " ^ show_token token, pos))

(** 解析列表模式 *)
and parse_list_pattern state =
  let state1 = expect_token_punctuation state is_left_bracket "left bracket" in
  let (token, _) = current_token state1 in
  match token with
  | RightBracket | ChineseRightBracket -> (EmptyListPattern, advance_parser state1)
  | _ ->
    let (head_pattern, state2) = parse_pattern state1 in
    let (token, _) = current_token state2 in
    (match token with
     | Comma | ChineseComma ->
       let state3 = advance_parser state2 in
       let (token, _) = current_token state3 in
       (match token with
        | TripleDot ->
          (* Handle [head, ...tail] syntax *)
          let state4 = advance_parser state3 in
          let (tail_pattern, state5) = parse_pattern state4 in
          let state6 = expect_token_punctuation state5 is_right_bracket "right bracket" in
          (ConsPattern (head_pattern, tail_pattern), state6)
        | _ ->
          (* Handle multiple elements [a, b, c] as nested ConsPattern *)
          let rec parse_remaining_patterns patterns state =
            let (pattern, state1) = parse_pattern state in
            let (token, _) = current_token state1 in
            (match token with
             | Comma | ChineseComma ->
               let state2 = advance_parser state1 in
               parse_remaining_patterns (pattern :: patterns) state2
             | RightBracket | ChineseRightBracket ->
               (pattern :: patterns, advance_parser state1)
             | _ -> raise (SyntaxError ("期望逗号或右方括号", snd (current_token state1))))
          in
          let (remaining_patterns, state4) = parse_remaining_patterns [] state3 in
          (* Convert [a, b, c] to ConsPattern(a, ConsPattern(b, ConsPattern(c, EmptyListPattern))) *)
          let rec build_cons_pattern all_patterns =
            match all_patterns with
            | [] -> EmptyListPattern
            | [p] -> ConsPattern (p, EmptyListPattern)
            | p :: rest -> ConsPattern (p, build_cons_pattern rest)
          in
          (build_cons_pattern (head_pattern :: remaining_patterns), state4))
     | RightBracket | ChineseRightBracket ->
       (* Handle single element [head] *)
       let state3 = advance_parser state2 in
       (ConsPattern (head_pattern, EmptyListPattern), state3)
     | _ -> raise (SyntaxError ("期望逗号或右方括号", snd (current_token state2))))

(** 解析函数表达式 *)
and parse_function_expression state =
  let state1 = expect_token state FunKeyword in
  let rec parse_param_list param_list state =
    let (token, _) = current_token state in
    match token with
    | IdentifierToken name ->
      let state1 = advance_parser state in
      parse_param_list (name :: param_list) state1
    | QuotedIdentifierToken name ->
      let state1 = advance_parser state in
      parse_param_list (name :: param_list) state1
    | Arrow | ChineseArrow ->
      let state1 = advance_parser state in
      (List.rev param_list, state1)
    | _ -> raise (SyntaxError ("期望参数或箭头", snd (current_token state)))
  in
  let (param_list, state2) = parse_param_list [] state1 in
  let state2_clean = skip_newlines state2 in
  let (expr, state3) = parse_expression state2_clean in
  (FunExpr (param_list, expr), state3)

(** 解析自然语言函数定义 *)
and parse_natural_function_definition state =
  let state1 = expect_token state DefineKeyword in
  (* 解析函数名：定义「函数名」 *)
  let (function_name, state2) = parse_identifier state1 in
  (* 期望「接受」关键字 *)
  let state3 = expect_token state2 AcceptKeyword in
  (* 解析参数名：接受「参数」 *)
  let (param_name, state4) = parse_identifier state3 in
  (* 期望冒号（ASCII或中文） *)
  let state5 = expect_token_punctuation state4 is_colon "colon" in
  let state5_clean = skip_newlines state5 in
  
  (* 解析函数体 - 支持自然语言表达式 *)
  let (body_expr, state6) = parse_natural_function_body param_name state5_clean in
  
  (* 将自然语言函数定义转换为传统的函数表达式 *)
  let fun_expr = FunExpr ([param_name], body_expr) in
  
  (* 进行语义分析（可选，用于调试和优化提示） *)
  (try
     let semantic_info = Nlf_semantic.analyze_natural_function_semantics function_name [param_name] body_expr in
     let validation_errors = Nlf_semantic.validate_semantic_consistency semantic_info in
     if List.length validation_errors > 0 && false then ( (* 暂时禁用输出 *)
       Printf.printf "函数「%s」语义分析:\n%s\n" function_name 
         (String.concat "\n" validation_errors);
       flush_all ()
     )
   with _ -> ()); (* 忽略语义分析错误，不影响编译 *)
  
  (LetExpr (function_name, fun_expr, VarExpr function_name), state6)

(** 解析自然语言函数体 *)
and parse_natural_function_body param_name state =
  let (token, _) = current_token state in
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
  let (param_ref, state2) = parse_identifier state1 in
  
  (* 解析条件关系词 *)
  let (token, _) = current_token state2 in
  let (comparison_op, state3) = match token with
  | IsKeyword -> 
    let state_next = advance_parser state2 in
    (Eq, state_next)
  | AsForKeyword -> (* 「为」在wenyan语法中 *)
    let state_next = advance_parser state2 in
    (Eq, state_next)
  | IdentifierToken "为" -> (* 处理「为」作为标识符的情况 *)
    let state_next = advance_parser state2 in
    (Eq, state_next)
  | EqualToKeyword ->
    let state_next = advance_parser state2 in
    (Eq, state_next)
  | LessThanEqualToKeyword ->
    let state_next = advance_parser state2 in
    (Le, state_next)
  | _ ->
    raise (SyntaxError ("期望条件关系词，如「为」或「等于」", snd (current_token state2)))
  in
  
  (* 解析条件值 *)
  let (condition_value, state4) = parse_expression state3 in
  
  (* 期望「时返回」 *)
  let state5 = expect_token state4 ReturnWhenKeyword in
  
  (* 解析返回值 *)
  let (return_value, state6) = parse_natural_expression param_name state5 in
  
  (* 检查是否有else子句 *)
  let state6_clean = skip_newlines state6 in
  let (token_after, _) = current_token state6_clean in
  
  if token_after = ElseReturnKeyword then
    let state7 = advance_parser state6_clean in
    let (else_expr, state8) = parse_natural_expression param_name state7 in
    let condition_expr = BinaryOpExpr (VarExpr param_ref, comparison_op, condition_value) in
    (CondExpr (condition_expr, return_value, else_expr), state8)
  else
    let condition_expr = BinaryOpExpr (VarExpr param_ref, comparison_op, condition_value) in
    (CondExpr (condition_expr, return_value, LitExpr UnitLit), state6)

(** 解析自然语言表达式 *)
and parse_natural_expression param_name state =
  let (token, _) = current_token state in
  match token with
  | IdentifierToken _ | QuotedIdentifierToken _ ->
    let (expr, state1) = parse_natural_arithmetic_expression param_name state in
    (expr, state1)
  | InputKeyword ->
    let (expr, state1) = parse_natural_arithmetic_expression param_name state in
    (expr, state1)
  | IntToken _ | FloatToken _ | StringToken _ ->
    let (literal, state1) = parse_literal state in
    (LitExpr literal, state1)
  | _ ->
    parse_expression state

(** 解析算术表达式（支持自然语言运算符）*)
and parse_natural_arithmetic_expression param_name state =
  let (left_expr, state1) = parse_natural_primary param_name state in
  parse_natural_arithmetic_tail left_expr param_name state1

and parse_natural_arithmetic_tail left_expr param_name state =
  let (token, _) = current_token state in
  match token with
  | MultiplyKeyword ->
    let state1 = advance_parser state in
    let (right_expr, state2) = parse_natural_primary param_name state1 in
    let new_expr = BinaryOpExpr (left_expr, Mul, right_expr) in
    parse_natural_arithmetic_tail new_expr param_name state2
  | AddToKeyword ->
    let state1 = advance_parser state in
    let (right_expr, state2) = parse_natural_primary param_name state1 in
    let new_expr = BinaryOpExpr (left_expr, Add, right_expr) in
    parse_natural_arithmetic_tail new_expr param_name state2
  | SubtractKeyword ->
    let state1 = advance_parser state in
    let (right_expr, state2) = parse_natural_primary param_name state1 in
    let new_expr = BinaryOpExpr (left_expr, Sub, right_expr) in
    parse_natural_arithmetic_tail new_expr param_name state2
  | _ ->
    (left_expr, state)

and parse_natural_primary param_name state =
  let (token, _) = current_token state in
  match token with
  | IdentifierToken name | QuotedIdentifierToken name ->
    let state1 = advance_parser state in
    (* 检查自然语言运算模式 *)
    parse_natural_identifier_patterns name param_name state1
  | InputKeyword ->
    (* 处理「输入」关键字 *)
    let state1 = advance_parser state in
    parse_natural_input_patterns param_name state1
  | IntToken _ | FloatToken _ | StringToken _ ->
    let (literal, state1) = parse_literal state in
    (LitExpr literal, state1)
  | LeftParen ->
    let state1 = advance_parser state in
    let (expr, state2) = parse_expression state1 in
    let state3 = expect_token state2 RightParen in
    (expr, state3)
  | _ ->
    parse_expression state

(* 解析标识符相关的自然语言模式 *)
and parse_natural_identifier_patterns name param_name state =
  let (token_after, _) = current_token state in
  match token_after with
  | OfParticle -> (* 「输入」之「阶乘」 -> 阶乘(输入) *)
    let state2 = advance_parser state in
    let (func_name, state3) = parse_identifier state2 in
    (FunCallExpr (VarExpr func_name, [VarExpr name]), state3)
  | MinusOneKeyword -> (* 处理「减一」模式 *)
    let state2 = advance_parser state in
    let minus_one_expr = BinaryOpExpr (VarExpr name, Sub, LitExpr (IntLit 1)) in
    parse_natural_arithmetic_continuation minus_one_expr param_name state2
  | _ ->
    (VarExpr name, state)

(* 解析「输入」关键字相关的模式 *)
and parse_natural_input_patterns param_name state =
  let (token_after, _) = current_token state in
  match token_after with
  | MinusOneKeyword -> (* 「输入减一」 *)
    let state1 = advance_parser state in
    let minus_one_expr = BinaryOpExpr (VarExpr param_name, Sub, LitExpr (IntLit 1)) in
    parse_natural_arithmetic_continuation minus_one_expr param_name state1
  | SmallKeyword -> (* 「输入小」开始的比较表达式 *)
    let state1 = advance_parser state in
    parse_natural_comparison_patterns param_name state1
  | _ ->
    (VarExpr param_name, state)

(* 解析比较模式，如「小于等于」 *)
and parse_natural_comparison_patterns param_name state =
  let (token_after, _) = current_token state in
  match token_after with
  | LessThanEqualToKeyword ->
    (* 「输入小于等于1」 *)
    let state1 = advance_parser state in
    let (right_expr, state2) = parse_expression state1 in
    (BinaryOpExpr (VarExpr param_name, Le, right_expr), state2)
  | _ ->
    (* 其他情况，返回输入变量 *)
    (VarExpr param_name, state)

(* 解析算术运算的延续，如「减一的阶乘」 *)
and parse_natural_arithmetic_continuation expr _param_name state =
  let (token_after, _) = current_token state in
  match token_after with
  | OfParticle -> (* 「减一」之「阶乘」 *)
    let state1 = advance_parser state in
    let (func_name, state2) = parse_identifier state1 in
    (FunCallExpr (VarExpr func_name, [expr]), state2)
  | _ ->
    (expr, state)

(** 解析让表达式 *)
and parse_let_expression state =
  let state1 = expect_token state LetKeyword in
  let (name, state2) = parse_identifier_allow_keywords state1 in
  (* Check for semantic type annotation *)
  let (semantic_label_opt, state_after_name) = 
    let (token, _) = current_token state2 in
    if token = AsKeyword then
      let state3 = advance_parser state2 in
      let (label, state4) = parse_identifier state3 in
      (Some label, state4)
    else
      (None, state2)
  in
  let state3 = expect_token state_after_name Assign in
  let (val_expr, state4) = parse_expression state3 in
  let state4_clean = skip_newlines state4 in
  let (token, _) = current_token state4_clean in
  let state5 = 
    if token = InKeyword then
      advance_parser state4_clean
    else
      state4_clean
  in
  let state5_clean = skip_newlines state5 in
  let (body_expr, state6) = parse_expression state5_clean in
  match semantic_label_opt with
  | Some label -> (SemanticLetExpr (name, label, val_expr, body_expr), state6)
  | None -> (LetExpr (name, val_expr, body_expr), state6)

(** 解析文言风格变量声明: 吾有一数，名曰「数值」，其值四十二也。 *)
and parse_wenyan_let_expression state =
  let state1 = expect_token state HaveKeyword in
  let state2 = expect_token state1 OneKeyword in
  
  (* 解析类型关键字（可选） *)
  let (_type_hint, state3) = 
    let (token, _) = current_token state2 in
    match token with
    | NumberKeyword -> (Some "整数", advance_parser state2)
    | IdentifierToken type_name -> (Some type_name, advance_parser state2)
    | _ -> (None, state2)
  in
  
  (* 期望 "名曰" *)
  let state4 = expect_token state3 NameKeyword in
  
  (* 解析变量名 *)
  let (name, state5) = parse_wenyan_compound_identifier state4 in
  
  (* 期望逗号或"其值" *)
  let (token, _) = current_token state5 in
  let state6 = 
    if token = Comma then advance_parser state5
    else if token = ValueKeyword then state5
    else state5
  in
  
  (* 期望 "其值" *)
  let state7 = expect_token state6 ValueKeyword in
  
  (* 解析值表达式 *)
  let (val_expr, state8) = parse_expression state7 in
  
  (* 期望 "也" (可选) *)
  let state9 = 
    let (token, _) = current_token state8 in
    if token = AlsoKeyword || token = AfterThatKeyword then advance_parser state8 else state8
  in
  
  (* 期望句号（可选） *)
  let state10 = 
    let (token, _) = current_token state9 in
    if token = Dot then advance_parser state9 else state9
  in
  
  let state10_clean = skip_newlines state10 in
  
  (* 期望 "在" 关键字 *)
  let state11 = expect_token state10_clean InKeyword in
  
  (* 解析后续表达式 *)
  let (body_expr, state12) = parse_expression state11 in
  (LetExpr (name, val_expr, body_expr), state12)

(** 解析简化文言风格变量声明: 设数值为四十二。 *)
and parse_wenyan_simple_let_expression state =
  let state1 = expect_token state SetKeyword in
  
  (* 解析变量名 *)
  let (name, state2) = parse_wenyan_compound_identifier state1 in
  
  (* 期望 "为" *)
  let state3 = expect_token state2 AsForKeyword in
  
  (* 解析值表达式 *)
  let (val_expr, state4) = parse_expression state3 in
  
  (* 期望句号（可选） *)
  let state5 = 
    let (token, _) = current_token state4 in
    if token = Dot then advance_parser state4 else state4
  in
  
  let state5_clean = skip_newlines state5 in
  
  (* 解析后续表达式 *)
  let (body_expr, state6) = parse_expression state5_clean in
  (LetExpr (name, val_expr, body_expr), state6)

(** 解析组合表达式 *)
and parse_combine_expression state =
  let state1 = expect_token state CombineKeyword in
  (* Parse first expression *)
  let (first_expr, state2) = parse_expression state1 in
  (* Parse remaining expressions with 以及 separator *)
  let rec parse_combine_list expr_list state =
    let (token, _) = current_token state in
    if token = WithOpKeyword then
      let state1 = advance_parser state in
      let (expr, state2) = parse_expression state1 in
      parse_combine_list (expr :: expr_list) state2
    else
      (List.rev expr_list, state)
  in
  let (rest_exprs, final_state) = parse_combine_list [first_expr] state2 in
  (CombineExpr rest_exprs, final_state)

(** 解析记录表达式 *)
and parse_record_expression state =
  let state1 = expect_token_punctuation state is_left_brace "left brace" in
  let rec parse_fields fields state =
    let state = skip_newlines state in
    let (token, pos) = current_token state in
    match token with
    | RightBrace -> (RecordExpr (List.rev fields), advance_parser state)
    | IdentifierToken field_name ->
      let state1 = advance_parser state in
      (* Check if this is a record update expression *)
      if fields = [] && is_token state1 WithKeyword then
        (* This is { expr 与 field = value } syntax *)
        let expr = VarExpr field_name in
        let state2 = expect_token state1 WithKeyword in
        let (updates, state3) = parse_record_updates state2 in
        (RecordUpdateExpr (expr, updates), state3)
      else
        (* Regular field *)
        let state2 = expect_token state1 Assign in
        let (value, state3) = parse_expression state2 in
        let state4 = 
          let (token, _) = current_token state3 in
          if is_semicolon token then advance_parser state3 else state3
        in
        parse_fields ((field_name, value) :: fields) state4
    | _ ->
      (* Could be { expr 与 ... } where expr is not just an identifier *)
      if fields = [] then
        let (expr, state1) = parse_expression state in
        let state2 = expect_token state1 WithKeyword in
        let (updates, state3) = parse_record_updates state2 in
        (RecordUpdateExpr (expr, updates), state3)
      else
        raise (SyntaxError ("期望字段名或右花括号", pos))
  in
  let (fields_or_expr, state2) = parse_fields [] state1 in
  (fields_or_expr, state2)

(** 解析记录更新字段 *)
and parse_record_updates state =
  let rec parse_updates updates state =
    let state = skip_newlines state in
    let (token, _) = current_token state in
    match token with
    | RightBrace -> (List.rev updates, advance_parser state)
    | IdentifierToken field_name ->
      let state1 = advance_parser state in
      let state2 = expect_token state1 Assign in
      let (value, state3) = parse_expression state2 in
      let state4 = 
        let (token, _) = current_token state3 in
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
  let (try_expr, state2) = parse_expression state1 in
  let state2 = skip_newlines state2 in
  let state3 = expect_token state2 CatchKeyword in
  let state3 = skip_newlines state3 in
  
  (* 解析catch分支 *)
  let rec parse_catch_branches branches state =
    let state = skip_newlines state in
    let (token, _) = current_token state in
    match token with
    | Pipe ->
      let state1 = advance_parser state in
      let (pattern, state2) = parse_pattern state1 in
      (* Exception handling typically doesn't use guards, but we support it *)
      let (guard, state3) = 
        if is_token state2 WhenKeyword then
          let state2_1 = advance_parser state2 in
          let (guard_expr, state2_2) = parse_expression state2_1 in
          (Some guard_expr, state2_2)
        else
          (None, state2)
      in
      let state4 = expect_token state3 Arrow in
      let state4 = skip_newlines state4 in
      let (expr, state5) = parse_expression state4 in
      let state5 = skip_newlines state5 in
      let branch = { pattern; guard; expr } in
      parse_catch_branches (branch :: branches) state5
    | _ -> (List.rev branches, state)
  in
  
  let (catch_branches, state4) = parse_catch_branches [] state3 in
  
  (* 检查是否有finally块 *)
  let state4 = skip_newlines state4 in
  let (token, _) = current_token state4 in
  match token with
  | FinallyKeyword ->
    let state5 = advance_parser state4 in
    let state5 = skip_newlines state5 in
    let (finally_expr, state6) = parse_expression state5 in
    (TryExpr (try_expr, catch_branches, Some finally_expr), state6)
  | _ ->
    (TryExpr (try_expr, catch_branches, None), state4)

(** 解析raise表达式 *)
and parse_raise_expression state =
  let state1 = expect_token state RaiseKeyword in
  let (expr, state2) = parse_expression state1 in
  (RaiseExpr expr, state2)

(** 解析ref表达式 *)
and parse_ref_expression state =
  let state1 = expect_token state RefKeyword in
  let (expr, state2) = parse_expression state1 in
  (RefExpr expr, state2)

(** 解析模块表达式 - 暂时简单实现 *)
and parse_module_expression state =
  (* 简单实现：假设模块表达式是一个标识符 *)
  let (module_name, state1) = parse_identifier state in
  (VarExpr module_name, state1)


(** 解析参数列表 *)
and parse_parameter_list state =
  let state1 = expect_token state LeftParen in
  let rec parse_params params state =
    let (token, _) = current_token state in
    match token with
    | RightParen -> (List.rev params, advance_parser state)
    | IdentifierToken param_name ->
      let state1 = advance_parser state in
      let (token, _) = current_token state1 in
      (match token with
       | Comma ->
         let state2 = advance_parser state1 in
         parse_params (param_name :: params) state2
       | RightParen ->
         parse_params (param_name :: params) state1
       | _ -> raise (SyntaxError ("期望逗号或右圆括号", snd (current_token state1))))
    | _ when List.length params = 0 ->
      (* 空参数列表 *)
      ([], state)
    | _ -> raise (SyntaxError ("期望参数名", snd (current_token state)))
  in
  parse_params [] state1

(** 解析类型定义 *)
let rec parse_type_definition state =
  let (token, _) = current_token state in
  match token with
  | Pipe ->
    (* Algebraic type with variants: | Constructor1 | Constructor2 of type | ... *)
    parse_variant_constructors state []
  | _ ->
    (* Type alias: existing_type *)
    let (type_expr, state1) = parse_type_expression state in
    (AliasType type_expr, state1)

(** 解析变体构造器列表 *)
and parse_variant_constructors state constructors =
  let (token, _) = current_token state in
  match token with
  | Pipe ->
    let state1 = advance_parser state in
    let (constructor_name, state2) = parse_identifier_allow_keywords state1 in
    let (token, _) = current_token state2 in
    (match token with
     | OfKeyword ->
       (* Constructor with type: | Name of type *)
       let state3 = advance_parser state2 in
       let (type_expr, state4) = parse_type_expression state3 in
       let new_constructor = (constructor_name, Some type_expr) in
       parse_variant_constructors state4 (new_constructor :: constructors)
     | _ ->
       (* Constructor without type: | Name *)
       let new_constructor = (constructor_name, None) in
       parse_variant_constructors state2 (new_constructor :: constructors))
  | _ ->
    (* End of constructors *)
    (AlgebraicType (List.rev constructors), state)

(** 解析语句 *)
(** 跳过换行符辅助函数 *)
let rec skip_newlines state =
  let (token, _pos) = current_token state in
  if token = Newline then
    skip_newlines (advance_parser state)
  else
    state

(** 解析模块类型 *)
let rec parse_module_type state =
  let (token, _pos) = current_token state in
  match token with
  | SigKeyword ->
    let state1 = advance_parser state in
    let (signature_items, state2) = parse_signature_items [] state1 in
    let state3 = expect_token state2 EndKeyword in
    (Signature signature_items, state3)
  | IdentifierToken name ->
    let state1 = advance_parser state in
    (ModuleTypeName name, state1)
  | QuotedIdentifierToken name ->
    let state1 = advance_parser state in
    (ModuleTypeName name, state1)
  | _ ->
    let (token, pos) = current_token state in
    raise (SyntaxError ("期望模块类型定义，但遇到 " ^ show_token token, pos))

(** 解析签名项列表 *)
and parse_signature_items items state =
  let state = skip_newlines state in
  let (token, _pos) = current_token state in
  if token = EndKeyword then
    (List.rev items, state)
  else
    let (item, state1) = parse_signature_item state in
    let state2 = skip_newlines state1 in
    parse_signature_items (item :: items) state2

(** 解析单个签名项 *)
and parse_signature_item state =
  let (token, _pos) = current_token state in
  match token with
  | LetKeyword ->
    (* 值签名: 让 名称 : 类型 *)
    let state1 = advance_parser state in
    let (name, state2) = parse_identifier_allow_keywords state1 in
    let state3 = expect_token state2 Colon in
    let (type_expr, state4) = parse_type_expression state3 in
    (SigValue (name, type_expr), state4)
  | TypeKeyword ->
    (* 类型签名: 类型 名称 [= 定义] *)
    let state1 = advance_parser state in
    let (name, state2) = parse_identifier_allow_keywords state1 in
    let (token, _) = current_token state2 in
    if token = Assign then
      let state3 = advance_parser state2 in
      let (type_def, state4) = parse_type_definition state3 in
      (SigTypeDecl (name, Some type_def), state4)
    else
      (SigTypeDecl (name, None), state2)
  | ModuleKeyword ->
    (* 模块签名: 模块 名称 : 模块类型 *)
    let state1 = advance_parser state in
    let (name, state2) = parse_identifier_allow_keywords state1 in
    let state3 = expect_token state2 Colon in
    let (module_type, state4) = parse_module_type state3 in
    (SigModule (name, module_type), state4)
  | ExceptionKeyword ->
    (* 异常签名: 异常 名称 [of 类型] *)
    let state1 = advance_parser state in
    let (name, state2) = parse_identifier_allow_keywords state1 in
    let (token, _) = current_token state2 in
    if token = OfKeyword then
      let state3 = advance_parser state2 in
      let (type_expr, state4) = parse_type_expression state3 in
      (SigException (name, Some type_expr), state4)
    else
      (SigException (name, None), state2)
  | _ ->
    let (token, pos) = current_token state in
    raise (SyntaxError ("期望签名项，但遇到 " ^ show_token token, pos))

let parse_statement state =
  let (token, _pos) = current_token state in
  match token with
  | LetKeyword ->
    let state1 = advance_parser state in
    let (name, state2) = parse_identifier_allow_keywords state1 in
    (* Check for semantic type annotation *)
    let (semantic_label_opt, state_after_name) = 
      let (token, _) = current_token state2 in
      if token = AsKeyword then
        let state3 = advance_parser state2 in
        let (label, state4) = parse_identifier state3 in
        (Some label, state4)
      else
        (None, state2)
    in
    let state3 = expect_token state_after_name Assign in
    let (expr, state4) = parse_expression state3 in
    (match semantic_label_opt with
     | Some label -> (SemanticLetStmt (name, label, expr), state4)
     | None -> (LetStmt (name, expr), state4))
  | RecKeyword ->
    let state1 = advance_parser state in
    let state2 = expect_token state1 LetKeyword in
    let (name, state3) = parse_identifier_allow_keywords state2 in
    let state4 = expect_token state3 Assign in
    let (expr, state5) = parse_expression state4 in
    (RecLetStmt (name, expr), state5)
  | DefineKeyword ->
    (* 解析自然语言函数定义 *)
    let (expr, state1) = parse_natural_function_definition state in
    (match expr with
    | LetExpr (func_name, fun_expr, _) -> (LetStmt (func_name, fun_expr), state1)
    | _ -> raise (SyntaxError ("自然语言函数定义解析错误", snd (current_token state))))
  | SetKeyword ->
    (* 解析wenyan风格变量声明：设变量名为表达式 *)
    let state1 = advance_parser state in
    let (name, state2) = parse_wenyan_compound_identifier state1 in
    let state3 = expect_token state2 AsForKeyword in  (* 期望"为"关键字 *)
    let (expr, state4) = parse_expression state3 in
    (LetStmt (name, expr), state4)
  | ExceptionKeyword ->
    let state1 = advance_parser state in
    let (name, state2) = parse_identifier_allow_keywords state1 in
    let (token, _) = current_token state2 in
    (match token with
     | OfKeyword ->
       let state3 = advance_parser state2 in
       let (type_expr, state4) = parse_type_expression state3 in
       (ExceptionDefStmt (name, Some type_expr), state4)
     | _ ->
       (ExceptionDefStmt (name, None), state2))
  | TypeKeyword ->
    let state1 = advance_parser state in
    let (name, state2) = parse_identifier_allow_keywords state1 in
    let state3 = expect_token state2 Assign in
    let (type_def, state4) = parse_type_definition state3 in
    (TypeDefStmt (name, type_def), state4)
  | ModuleTypeKeyword ->
    let state1 = advance_parser state in
    let (name, state2) = parse_identifier_allow_keywords state1 in
    let state3 = expect_token state2 Assign in
    let (module_type, state4) = parse_module_type state3 in
    (ModuleTypeDefStmt (name, module_type), state4)
  | MacroKeyword ->
    let state1 = advance_parser state in
    let (macro_name, state2) = parse_identifier_allow_keywords state1 in
    let state3 = expect_token state2 LeftParen in
    let (params, state4) = parse_macro_params [] state3 in
    let state5 = expect_token state4 RightParen in
    let state6 = expect_token state5 Assign in
    let (body, state7) = parse_expression state6 in
    let macro_def = {
      macro_def_name = macro_name;
      params = params;
      body = body;
    } in
    (MacroDefStmt macro_def, state7)
  | _ ->
    let (expr, state1) = parse_expression state in
    (ExprStmt expr, state1)


(** 跳过可选的语句终结符 *)
let skip_optional_statement_terminator state =
  let (token, _) = current_token state in
  if is_semicolon token || token = AlsoKeyword then
    advance_parser state
  else
    state

(** 解析程序 *)
let parse_program token_list =
  let rec parse_statement_list stmt_list state =
    let state = skip_newlines state in
    let (token, _) = current_token state in
    if token = EOF then
      List.rev stmt_list
    else
      let (stmt, state1) = parse_statement state in
      let state2 = skip_optional_statement_terminator state1 in
      let state3 = skip_newlines state2 in
      parse_statement_list (stmt :: stmt_list) state3
  in
  let initial_state = create_parser_state token_list in
  parse_statement_list [] initial_state