(** 骆言语法分析器函数表达式解析模块 - Function Expression Parser *)

open Ast
open Lexer
open Parser_utils
open Parser_expressions_utils

(** 解析函数表达式 *)
let rec parse_function_expression parse_expr state =
  let state1 = expect_token state FunKeyword in
  let token, _ = current_token state1 in
  (* 检查是否有标签参数 *)
  if token = Tilde then parse_labeled_function_expression parse_expr state1
  else
    (* 普通函数表达式 *)
    let rec parse_param_list param_list state =
      let token, _ = current_token state in
      match token with
      | QuotedIdentifierToken name ->
          let state1 = advance_parser state in
          parse_param_list (name :: param_list) state1
      | Arrow | ChineseArrow | ShouldGetKeyword | AncientArrowKeyword ->
          let state1 = advance_parser state in
          (List.rev param_list, state1)
      | _ -> raise (SyntaxError ("期望参数或箭头", snd (current_token state)))
    in
    let param_list, state2 = parse_param_list [] state1 in
    let state2_clean = skip_newlines state2 in
    let expr, state3 = parse_expr state2_clean in
    (FunExpr (param_list, expr), state3)

(** 解析标签函数表达式 *)
and parse_labeled_function_expression parse_expr state =
  let rec parse_labeled_param_list param_list state =
    let token, pos = current_token state in
    match token with
    | Tilde ->
        let state1 = advance_parser state in
        let label_param, state2 = parse_label_param state1 in
        parse_labeled_param_list (label_param :: param_list) state2
    | Arrow | ChineseArrow ->
        let state1 = advance_parser state in
        (List.rev param_list, state1)
    | _ -> raise (SyntaxError ("期望标签参数或箭头", pos))
  in
  let label_params, state1 = parse_labeled_param_list [] state in
  let state1_clean = skip_newlines state1 in
  let expr, state2 = parse_expr state1_clean in
  (LabeledFunExpr (label_params, expr), state2)

(** 解析单个标签参数 *)
and parse_label_param state =
  let label_name, state1 = parse_identifier state in
  let token, _ = current_token state1 in
  match token with
  | QuestionMark ->
      (* 可选参数 *)
      let state2 = advance_parser state1 in
      let token2, _ = current_token state2 in
      if token2 = Colon then
        (* 有默认值的可选参数: ~label?: default_value *)
        let state3 = advance_parser state2 in
        let default_expr, state4 =
          let token, _ = current_token state3 in
          match token with
          | IntToken i -> (LitExpr (IntLit i), advance_parser state3)
          | QuotedIdentifierToken name -> (VarExpr name, advance_parser state3)
          | _ -> (LitExpr UnitLit, state3)
        in
        ( {
            label_name;
            param_name = label_name;
            param_type = None;
            is_optional = true;
            default_value = Some default_expr;
          },
          state4 )
      else
        (* 无默认值的可选参数: ~label? *)
        ( {
            label_name;
            param_name = label_name;
            param_type = None;
            is_optional = true;
            default_value = None;
          },
          state2 )
  | Colon ->
      (* 带类型注解的参数: ~label: type *)
      let state2 = advance_parser state1 in
      let type_expr, state3 =
        let name, state = parse_identifier state2 in
        (TypeVar name, state)
      in
      ( {
          label_name;
          param_name = label_name;
          param_type = Some type_expr;
          is_optional = false;
          default_value = None;
        },
        state3 )
  | _ ->
      (* 普通标签参数: ~label *)
      ( {
          label_name;
          param_name = label_name;
          param_type = None;
          is_optional = false;
          default_value = None;
        },
        state1 )
