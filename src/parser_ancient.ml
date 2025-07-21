(** 骆言语法分析器古雅体模块 - Chinese Programming Language Parser Ancient Module *)

open Ast
open Lexer
open Parser_utils
open Unified_errors

type 'a parser = parser_state -> 'a * parser_state
(** 解析函数类型，用于高阶函数 *)

type expr_parser = expr parser
(** 表达式解析器类型 *)

type pattern_parser = pattern parser
(** 模式解析器类型 *)

(** 辅助函数 *)

(** 跳过换行符辅助函数 *)
let rec skip_newlines state =
  let token, _pos = current_token state in
  if token = Newline then skip_newlines (advance_parser state) else state

(** 解析自然语言算术延续表达式 *)
let parse_natural_arithmetic_continuation expr _param_name state =
  let token_after, _ = current_token state in
  match token_after with
  | OfParticle ->
      (* 「减一」之「阶乘」 *)
      let state1 = advance_parser state in
      let func_name, state2 = parse_identifier state1 in
      (FunCallExpr (VarExpr func_name, [ expr ]), state2)
  | _ -> (expr, state)

(** 古雅体语法解析函数 *)

(** 解析古雅体函数定义 *)
let parse_ancient_function_definition parse_expr state =
  (* 期望: 夫 函数名 者 受 参数 焉 算法为 表达式 也 *)
  let state1 = expect_token state AncientDefineKeyword in
  (* 夫 *)
  let function_name, state2 = parse_identifier state1 in
  let state3 = expect_token state2 ThenWenyanKeyword in
  (* 者 - wenyan then token *)
  let state4 = expect_token state3 AncientReceiveKeyword in
  (* 受 *)
  let param_name, state5 = parse_identifier state4 in
  let state6 = expect_token state5 AncientParticleFun in
  (* 焉 - function parameter particle *)
  let state7 = expect_token state6 AncientAlgorithmKeyword in
  (* 算法 *)
  let state8 = expect_token state7 ThenGetKeyword in
  (* 乃 *)
  let state8_clean = skip_newlines state8 in
  let body_expr, state9 = parse_expr state8_clean in
  let state10 = expect_token state9 AncientEndKeyword in
  (* 也 *)

  (* 转换为标准函数表达式 *)
  let fun_expr = FunExpr ([ param_name ], body_expr) in
  (LetExpr (function_name, fun_expr, VarExpr function_name), state10)

(** 解析古雅体匹配表达式 *)
let parse_ancient_match_expression parse_expr parse_pattern state =
  (* 期望: 观 标识符 之 性 若 模式 则 表达式 余者 则 表达式 观毕 *)
  let state1 = expect_token state AncientObserveKeyword in
  (* 观 *)
  let var_name, state2 = parse_identifier state1 in
  (* 仅解析标识符 *)
  let state3 = expect_token state2 OfParticle in
  (* 之 *)
  let state4 = expect_token state3 AncientNatureKeyword in
  (* 性 *)
  let expr = VarExpr var_name in
  (* 创建变量表达式 *)
  let state4_clean = skip_newlines state4 in

  (* 解析匹配分支 *)
  let rec parse_ancient_match_cases cases state =
    let token, _ = current_token state in
    match token with
    | AncientObserveEndKeyword -> (List.rev cases, advance_parser state)
    | IfWenyanKeyword ->
        (* 若 *)
        let state1 = advance_parser state in
        let pattern, state2 = parse_pattern state1 in
        let state3 = expect_token state2 AncientThenKeyword in
        let state4 = expect_token state3 AncientAnswerKeyword in
        let case_expr, state5 = parse_expr state4 in
        let state5_clean = skip_newlines state5 in
        let branch = { pattern; guard = None; expr = case_expr } in
        parse_ancient_match_cases (branch :: cases) state5_clean
    | AncientOtherwiseKeyword ->
        (* 余者 *)
        let state1 = advance_parser state in
        let state2 = expect_token state1 AncientThenKeyword in
        let state3 = expect_token state2 AncientAnswerKeyword in
        let default_expr, state4 = parse_expr state3 in
        let state4_clean = skip_newlines state4 in
        let default_branch = { pattern = WildcardPattern; guard = None; expr = default_expr } in
        let token2, _ = current_token state4_clean in
        if token2 = AncientObserveEndKeyword then
          let state5 = advance_parser state4_clean in
          (List.rev (default_branch :: cases), state5)
        else parse_ancient_match_cases (default_branch :: cases) state4_clean
    | _ -> raise (SyntaxError ("期望匹配分支或观毕", snd (current_token state)))
  in

  let cases, state5 = parse_ancient_match_cases [] state4_clean in
  (MatchExpr (expr, cases), state5)

(** 解析古雅体列表表达式 *)
let parse_ancient_list_expression parse_expr state =
  (* 期望: 列开始 元素1 其一 元素2 其二 元素3 其三 列结束 *)
  let state1 = expect_token state AncientListStartKeyword in
  (* 列开始 *)
  let rec parse_ancient_list_elements elements element_count state =
    let token, _ = current_token state in
    match token with
    | AncientListEndKeyword -> (ListExpr (List.rev elements), advance_parser state)
    | _ ->
        let expr, state1 = parse_expr state in
        let state2 =
          let next_token, _ = current_token state1 in
          if next_token = AncientListEndKeyword then state1
          else
            let keyword =
              match element_count mod 3 with
              | 0 -> AncientItsFirstKeyword
              | 1 -> AncientItsSecondKeyword
              | 2 -> AncientItsThirdKeyword
              | _ -> failwith "编译器错误：内部错误：序数模运算结果超出范围"
            in
            expect_token state1 keyword
        in
        parse_ancient_list_elements (expr :: elements) (element_count + 1) state2
  in
  parse_ancient_list_elements [] 0 state1

(** 解析古雅体条件表达式 *)
let parse_ancient_conditional_expression parse_expr state =
  (* 期望: 若 条件 则 表达式 不然 表达式 *)
  let state1 = expect_token state IfWenyanKeyword in
  (* 若 *)
  let cond, state2 = parse_expr state1 in
  let state3 = expect_token state2 AncientThenKeyword in
  (* 则 *)
  let then_branch, state4 = parse_expr state3 in
  let token, _ = current_token state4 in
  (* 检查是否有"不然"关键字，如果没有，使用"否则" *)
  let else_branch, state5 =
    if token = ElseKeyword then
      let state4a = advance_parser state4 in
      parse_expr state4a
    else
      (* 为了兼容，如果没有明确的else，返回单元值 *)
      (LitExpr UnitLit, state4)
  in
  (CondExpr (cond, then_branch, else_branch), state5)

(** 文言（wenyan）语法解析函数 *)

(** 解析文言风格变量声明: 吾有一数，名曰「数值」，其值四十二也。 *)
let parse_wenyan_let_expression parse_expr state =
  let state1 = expect_token state HaveKeyword in
  let state2 = expect_token state1 OneKeyword in

  (* 解析类型关键字（可选） *)
  let parse_optional_type_hint state =
    let token, _ = current_token state in
    match token with
    | NumberKeyword -> (Some "整数", advance_parser state)
    | QuotedIdentifierToken type_name -> (Some type_name, advance_parser state)
    | _ -> (None, state)
  in

  (* 跳过可选的逗号 *)
  let skip_optional_comma state =
    let token, _ = current_token state in
    if token = Comma then advance_parser state else state
  in

  (* 跳过可选的"也"关键字 *)
  let skip_optional_also_keyword state =
    let token, _ = current_token state in
    if token = AlsoKeyword || token = AfterThatKeyword then advance_parser state else state
  in

  (* 跳过可选的句号 *)
  let skip_optional_dot state =
    let token, _ = current_token state in
    if token = Dot then advance_parser state else state
  in

  let _type_hint, state3 = parse_optional_type_hint state2 in
  let state4 = expect_token state3 NameKeyword in
  let name, state5 = parse_wenyan_compound_identifier state4 in
  let state6 = skip_optional_comma state5 in
  let state7 = expect_token state6 ValueKeyword in
  let val_expr, state8 = parse_expr state7 in
  let state9 = skip_optional_also_keyword state8 in
  let state10 = skip_optional_dot state9 in
  let state10_clean = skip_newlines state10 in
  let state11 = expect_token state10_clean InKeyword in
  let body_expr, state12 = parse_expr state11 in
  (LetExpr (name, val_expr, body_expr), state12)

(** 解析简化文言风格变量声明: 设数值为四十二。 *)
let parse_wenyan_simple_let_expression parse_expr state =
  let state1 = expect_token state SetKeyword in

  (* 解析变量名 *)
  let name, state2 = parse_wenyan_compound_identifier state1 in

  (* 期望 "为" *)
  let state3 = expect_token state2 AsForKeyword in

  (* 解析值表达式 *)
  let val_expr, state4 = parse_expr state3 in

  (* 期望句号（可选） *)
  let state5 =
    let token, _ = current_token state4 in
    if token = Dot then advance_parser state4 else state4
  in
  let state5_clean = skip_newlines state5 in
  let body_expr, state6 = parse_expr state5_clean in
  (LetExpr (name, val_expr, body_expr), state6)
