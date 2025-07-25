(** 骆言语法分析器运算符表达式解析模块 - 整合版

    本模块整合了原有的多个运算符表达式解析模块：
    - parser_exprs_arithmetic.ml
    - parser_exprs_logical.ml
    - parser_exprs_binary.ml
    - parser_exprs_core.ml (部分功能)

    整合目的： 1. 消除代码重复（特别是二元运算符解析逻辑） 2. 统一运算符优先级处理 3. 简化模块依赖关系 4. 提高代码可维护性

    技术债务重构 - Fix #796
    @author 骆言AI代理
    @version 3.0 (整合版)
    @since 2025-07-21 *)

open Ast
open Lexer
open Parser_utils
open Parser_expressions_utils

(** ==================== 核心二元运算符解析器 ==================== *)

(** 通用二元运算符解析器 - 消除重复代码 *)
let create_binary_operator_parser operators next_level_parser state =
  let rec parse_tail left_expr state =
    let token, _ = current_token state in
    match Parser_utils.token_to_binary_op token with
    | Some op when List.mem op operators ->
        let state1 = advance_parser state in
        let right_expr, state2 = next_level_parser state1 in
        let new_expr = BinaryOpExpr (left_expr, op, right_expr) in
        parse_tail new_expr state2
    | _ -> (left_expr, state)
  in
  let expr, state1 = next_level_parser state in
  parse_tail expr state1

(** ==================== 赋值和逻辑运算符 ==================== *)

(** 解析赋值表达式 *)
let parse_assignment_expr parse_or_else_expr state =
  let left_expr, state1 = parse_or_else_expr state in
  let token, _ = current_token state1 in
  if token = RefAssign then
    let state2 = advance_parser state1 in
    let right_expr, state3 = parse_or_else_expr state2 in
    (AssignExpr (left_expr, right_expr), state3)
  else (left_expr, state1)

(** 解析否则返回表达式 *)
let parse_or_else_expr parse_or_fn state =
  let rec parse_tail left_expr state =
    let token, _ = current_token state in
    if token = OrElseKeyword then
      let state1 = advance_parser state in
      let right_expr, state2 = parse_or_fn state1 in
      let new_expr = OrElseExpr (left_expr, right_expr) in
      parse_tail new_expr state2
    else (left_expr, state)
  in
  let expr, state1 = parse_or_fn state in
  parse_tail expr state1

(** 解析逻辑或表达式 *)
let parse_or_expr parse_and_fn state = create_binary_operator_parser [ Or ] parse_and_fn state

(** 解析逻辑与表达式 *)
let parse_and_expr parse_comparison_fn state =
  create_binary_operator_parser [ And ] parse_comparison_fn state

(** 解析比较表达式 *)
let parse_comparison_expr parse_arithmetic_fn state =
  create_binary_operator_parser [ Eq; Neq; Lt; Le; Gt; Ge ] parse_arithmetic_fn state

(** ==================== 算术运算符 ==================== *)

(** 解析算术表达式（加法和减法） *)
let parse_arithmetic_expr parse_multiplicative_fn state =
  create_binary_operator_parser [ Add; Sub ] parse_multiplicative_fn state

(** 解析乘除表达式 *)
let parse_multiplicative_expr parse_unary_fn state =
  create_binary_operator_parser [ Mul; Div; Mod ] parse_unary_fn state

(** ==================== 一元运算符 ==================== *)

(** 解析一元表达式 *)
let parse_unary_expr parse_unary_expr_rec parse_primary_expr state =
  let token, _pos = current_token state in
  match token with
  | Minus ->
      let state1 = advance_parser state in
      let expr, state2 = parse_unary_expr_rec state1 in
      (UnaryOpExpr (Neg, expr), state2)
  | NotKeyword ->
      let state1 = advance_parser state in
      let expr, state2 = parse_unary_expr_rec state1 in
      (UnaryOpExpr (Not, expr), state2)
  | Bang ->
      let state1 = advance_parser state in
      let expr, state2 = parse_unary_expr_rec state1 in
      (DerefExpr expr, state2)
  | _ -> parse_primary_expr state

(** ==================== 后缀运算符 ==================== *)

(** ==================== 运算符优先级链 ==================== *)

(* 运算符优先级解析链 *)
let create_operator_precedence_chain parse_primary_expr =
  (* Create aliases to avoid name collision with local bindings *)
  let module_parse_assignment_expr = parse_assignment_expr in
  let module_parse_or_else_expr = parse_or_else_expr in
  let module_parse_or_expr = parse_or_expr in
  let module_parse_and_expr = parse_and_expr in
  let module_parse_comparison_expr = parse_comparison_expr in
  let module_parse_arithmetic_expr = parse_arithmetic_expr in
  let module_parse_multiplicative_expr = parse_multiplicative_expr in
  let module_parse_unary_expr = parse_unary_expr in
  let rec parse_expr state = module_parse_assignment_expr parse_or_else_expr state
  and parse_or_else_expr state = module_parse_or_else_expr parse_or_expr state
  and parse_or_expr state = module_parse_or_expr parse_and_expr state
  and parse_and_expr state = module_parse_and_expr parse_comparison_expr state
  and parse_comparison_expr state = module_parse_comparison_expr parse_arithmetic_expr state
  and parse_arithmetic_expr state = module_parse_arithmetic_expr parse_multiplicative_expr state
  and parse_multiplicative_expr state = module_parse_multiplicative_expr parse_unary_expr state
  and parse_unary_expr state = module_parse_unary_expr parse_unary_expr parse_postfix_expr state
  and parse_postfix_expr state =
    let expr, state1 = parse_primary_expr state in
    let rec parse_argument_list_local parse_expr acc state =
      let token, _ = current_token state in
      if token = RightParen || token = ChineseRightParen then (acc, state)
      else
        let arg, state1 = parse_expr state in
        let new_acc = arg :: acc in
        let token1, _ = current_token state1 in
        if token1 = RightParen || token1 = ChineseRightParen then (new_acc, state1)
        else if token1 = Comma then
          (* 跳过逗号，继续解析下一个参数 *)
          let state2 = advance_parser state1 in
          parse_argument_list_local parse_expr new_acc state2
        else
          (* 其他情况，可能是错误或者结束 *)
          (new_acc, state1)
    in
    let rec postfix_helper parse_expr expr state =
      let token, _ = current_token state in
      match token with
      (* 函数调用 *)
      | LeftParen | ChineseLeftParen ->
          let state1 = advance_parser state in
          let args, state2 = parse_argument_list_local parse_expr [] state1 in
          let state3 = expect_token_punctuation state2 is_right_paren "right parenthesis" in
          let new_expr = FunCallExpr (expr, List.rev args) in
          postfix_helper parse_expr new_expr state3
      (* 字段访问 *)
      | Dot -> (
          let state1 = advance_parser state in
          let token2, _ = current_token state1 in
          match token2 with
          | QuotedIdentifierToken field_name ->
              let state2 = advance_parser state1 in
              (* 判断是模块访问还是字段访问 *)
              let new_expr =
                match expr with
                | VarExpr module_name
                  when String.length module_name > 0
                       && Char.uppercase_ascii module_name.[0] = module_name.[0] ->
                    (* 如果左侧是以大写字母开头的变量，视为模块访问 *)
                    ModuleAccessExpr (expr, field_name)
                | _ ->
                    (* 否则视为字段访问 *)
                    FieldAccessExpr (expr, field_name)
              in
              postfix_helper parse_expr new_expr state2
          | _ -> (expr, state))
      (* 数组索引 *)
      | LeftBracket | ChineseLeftBracket ->
          let state1 = advance_parser state in
          let index_expr, state2 = parse_expr state1 in
          let state3 = expect_token_punctuation state2 is_right_bracket "right bracket" in
          let new_expr = ArrayAccessExpr (expr, index_expr) in
          postfix_helper parse_expr new_expr state3
      | _ -> (expr, state)
    in
    postfix_helper parse_expr expr state1
  in
  ( parse_expr,
    parse_or_else_expr,
    parse_or_expr,
    parse_and_expr,
    parse_comparison_expr,
    parse_arithmetic_expr,
    parse_multiplicative_expr,
    parse_unary_expr )

(** ==================== 向后兼容性接口 ==================== *)

(** 向后兼容：创建标准运算符解析器链 *)
let create_standard_operator_parsers parse_primary_expr =
  create_operator_precedence_chain parse_primary_expr

(** 向后兼容：单独的算术表达式解析器 *)
let parse_arithmetic_only parse_primary_expr state =
  let rec parse_unary_rec state = parse_unary_expr parse_unary_rec parse_primary_expr state in
  let parse_mult state = parse_multiplicative_expr parse_unary_rec state in
  parse_arithmetic_expr parse_mult state

(** 向后兼容：单独的逻辑表达式解析器 *)
let parse_logical_only parse_primary_expr state =
  let parse_comp state = parse_comparison_expr (parse_arithmetic_only parse_primary_expr) state in
  let parse_and state = parse_and_expr parse_comp state in
  parse_or_expr parse_and state

(** ==================== 接口兼容性函数 ==================== *)

(** 解析赋值表达式 - 接口兼容 *)
let parse_assignment_expression parse_or_else_fn state =
  parse_assignment_expr parse_or_else_fn state

(** 解析否则返回表达式 - 接口兼容 *)
let parse_or_else_expression parse_or_fn state = parse_or_else_expr parse_or_fn state

(** 解析逻辑或表达式 - 接口兼容 *)
let parse_or_expression parse_and_fn state = parse_or_expr parse_and_fn state

(** 解析逻辑与表达式 - 接口兼容 *)
let parse_and_expression parse_comparison_fn state = parse_and_expr parse_comparison_fn state

(** 解析比较表达式 - 接口兼容 *)
let parse_comparison_expression parse_arithmetic_fn state =
  parse_comparison_expr parse_arithmetic_fn state

(** 解析算术表达式 - 接口兼容 *)
let parse_arithmetic_expression parse_multiplicative_fn state =
  parse_arithmetic_expr parse_multiplicative_fn state

(** 解析乘除表达式 - 接口兼容 *)
let parse_multiplicative_expression parse_unary_fn state =
  parse_multiplicative_expr parse_unary_fn state

(** 解析一元表达式 - 接口兼容 *)
let parse_unary_expression parse_unary_rec parse_primary_fn state =
  parse_unary_expr parse_unary_rec parse_primary_fn state

(** 解析后缀表达式 - 接口兼容 *)
let parse_postfix_expression parse_expr expr state = parse_postfix_expr parse_expr expr state
