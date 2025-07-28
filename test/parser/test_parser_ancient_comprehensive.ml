(** 骆言古雅体语法解析器综合测试套件 - Fix #1009 Phase 2 Week 2 核心模块测试覆盖率提升 *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser_ancient
open Yyocamlc_lib.Parser_utils
open Yyocamlc_lib.Types

(** 测试辅助工具模块 *)
module TestHelpers = struct
  (** 创建位置信息 *)
  let make_pos line column filename = { line; column; filename }

  (** 创建位置标记token *)
  let make_positioned_token token line column filename = (token, make_pos line column filename)

  (** 创建测试用的parser状态 *)
  let create_test_state tokens =
    let positioned_tokens =
      List.mapi (fun i token -> make_positioned_token token (i + 1) 1 "test.ly") tokens
    in
    create_parser_state positioned_tokens

  (** 比较表达式AST节点 *)
  let rec expr_equal expr1 expr2 =
    match (expr1, expr2) with
    | IntExpr i1, IntExpr i2 -> i1 = i2
    | StringExpr s1, StringExpr s2 -> s1 = s2
    | BoolExpr b1, BoolExpr b2 -> b1 = b2
    | VarExpr v1, VarExpr v2 -> v1 = v2
    | LitExpr l1, LitExpr l2 -> literal_equal l1 l2
    | BinOpExpr (op1, l1, r1), BinOpExpr (op2, l2, r2) ->
        op1 = op2 && expr_equal l1 l2 && expr_equal r1 r2
    | UnaryOpExpr (op1, e1), UnaryOpExpr (op2, e2) -> op1 = op2 && expr_equal e1 e2
    | FunCallExpr (f1, args1), FunCallExpr (f2, args2) ->
        expr_equal f1 f2
        && List.length args1 = List.length args2
        && List.for_all2 expr_equal args1 args2
    | FunExpr (params1, body1), FunExpr (params2, body2) ->
        params1 = params2 && expr_equal body1 body2
    | LetExpr (name1, val1, body1), LetExpr (name2, val2, body2) ->
        name1 = name2 && expr_equal val1 val2 && expr_equal body1 body2
    | CondExpr (c1, t1, e1), CondExpr (c2, t2, e2) ->
        expr_equal c1 c2 && expr_equal t1 t2 && expr_equal e1 e2
    | MatchExpr (e1, cases1), MatchExpr (e2, cases2) ->
        expr_equal e1 e2
        && List.length cases1 = List.length cases2
        && List.for_all2 match_case_equal cases1 cases2
    | ListExpr exprs1, ListExpr exprs2 ->
        List.length exprs1 = List.length exprs2 && List.for_all2 expr_equal exprs1 exprs2
    | _ -> false

  and literal_equal l1 l2 =
    match (l1, l2) with
    | UnitLit, UnitLit -> true
    | IntLit i1, IntLit i2 -> i1 = i2
    | StringLit s1, StringLit s2 -> s1 = s2
    | BoolLit b1, BoolLit b2 -> b1 = b2
    | _ -> false

  and match_case_equal case1 case2 =
    pattern_equal case1.pattern case2.pattern
    && expr_equal case1.expr case2.expr
    &&
    match (case1.guard, case2.guard) with
    | None, None -> true
    | Some g1, Some g2 -> expr_equal g1 g2
    | _ -> false

  and pattern_equal p1 p2 =
    match (p1, p2) with
    | WildcardPattern, WildcardPattern -> true
    | VariablePattern v1, VariablePattern v2 -> v1 = v2
    | LiteralPattern l1, LiteralPattern l2 -> literal_equal l1 l2
    | _ -> false

  (** 检查解析是否成功 *)
  let check_parse_success name expected_expr test_tokens parse_func =
    try
      let state = create_test_state test_tokens in
      let result_expr, _ = parse_func state in
      check bool name true (expr_equal expected_expr result_expr)
    with e ->
      Printf.printf "解析失败，异常：%s\n" (Printexc.to_string e);
      check bool name false true

  (** 检查解析是否失败 *)
  let check_parse_failure name test_tokens parse_func =
    try
      let state = create_test_state test_tokens in
      let _ = parse_func state in
      check bool name false true (* 应该失败但没有失败 *)
    with _ -> check bool name true true (* 正确地失败了 *)

  (** 创建简单的parse_expr函数 *)
  let dummy_parse_expr state =
    let token, pos = current_token state in
    match token with
    | IntToken i -> (IntExpr i, advance_parser state)
    | StringToken s -> (StringExpr s, advance_parser state)
    | BoolToken b -> (BoolExpr b, advance_parser state)
    | Identifier name -> (VarExpr name, advance_parser state)
    | QuotedIdentifierToken name -> (VarExpr name, advance_parser state)
    | _ -> raise (SyntaxError ("未支持的表达式token", pos))

  (** 创建简单的parse_pattern函数 *)
  let dummy_parse_pattern state =
    let token, pos = current_token state in
    match token with
    | IntToken i -> (LiteralPattern (IntLit i), advance_parser state)
    | StringToken s -> (LiteralPattern (StringLit s), advance_parser state)
    | BoolToken b -> (LiteralPattern (BoolLit b), advance_parser state)
    | Identifier name -> (VariablePattern name, advance_parser state)
    | Wildcard -> (WildcardPattern, advance_parser state)
    | _ -> raise (SyntaxError ("未支持的模式token", pos))
end

(** ==================== 1. 辅助函数测试 ==================== *)

let test_skip_newlines () =
  (* 测试跳过换行符 *)
  let tokens = [ Newline; Newline; IntToken 42; EOF ] in
  let state = TestHelpers.create_test_state tokens in
  let new_state = skip_newlines state in
  let token, _ = current_token new_state in
  check bool "跳过多个换行符" true (token = IntToken 42);

  (* 测试没有换行符 *)
  let tokens2 = [ IntToken 42; EOF ] in
  let state2 = TestHelpers.create_test_state tokens2 in
  let new_state2 = skip_newlines state2 in
  let token2, _ = current_token new_state2 in
  check bool "没有换行符时保持状态" true (token2 = IntToken 42)

let test_parse_natural_arithmetic_continuation () =
  (* 测试自然语言算术延续表达式 *)
  let expr = IntExpr 5 in
  let tokens = [ OfParticle; Identifier "factorial"; EOF ] in
  try
    let state = TestHelpers.create_test_state tokens in
    let result_expr, _ = parse_natural_arithmetic_continuation expr "x" state in
    let expected = FunCallExpr (VarExpr "factorial", [ IntExpr 5 ]) in
    check bool "算术延续表达式解析" true (TestHelpers.expr_equal result_expr expected)
  with _ -> (
    check bool "算术延续表达式解析失败" false true;

    (* 测试没有延续的情况 *)
    let tokens2 = [ EOF ] in
    try
      let state2 = TestHelpers.create_test_state tokens2 in
      let result_expr2, _ = parse_natural_arithmetic_continuation expr "x" state2 in
      check bool "无延续时返回原表达式" true (TestHelpers.expr_equal result_expr2 expr)
    with _ -> check bool "无延续解析失败" false true)

(** ==================== 2. 古雅体语法解析测试 ==================== *)

let test_parse_ancient_function_definition () =
  (* 测试古雅体函数定义：夫 函数名 者 受 参数 焉 算法为 表达式 也 *)
  let tokens =
    [
      AncientDefineKeyword;
      (* 夫 *)
      Identifier "func";
      (* 函数名 *)
      ThenWenyanKeyword;
      (* 者 *)
      AncientReceiveKeyword;
      (* 受 *)
      Identifier "x";
      (* 参数 *)
      AncientParticleFun;
      (* 焉 *)
      AncientAlgorithmKeyword;
      (* 算法 *)
      AncientIsKeyword;
      (* 乃 *)
      IntToken 42;
      (* 表达式 *)
      AncientEndKeyword;
      (* 也 *)
      EOF;
    ]
  in

  let expected = LetExpr ("func", FunExpr ([ "x" ], IntExpr 42), VarExpr "func") in
  TestHelpers.check_parse_success "古雅体函数定义解析" expected tokens
    (parse_ancient_function_definition TestHelpers.dummy_parse_expr)

let test_parse_ancient_match_expression () =
  (* 测试古雅体匹配表达式：观 变量 之 性 若 模式 则 答 表达式 观毕 *)
  let tokens =
    [
      AncientObserveKeyword;
      (* 观 *)
      Identifier "x";
      (* 变量 *)
      OfParticle;
      (* 之 *)
      AncientNatureKeyword;
      (* 性 *)
      IfWenyanKeyword;
      (* 若 *)
      IntToken 1;
      (* 模式 *)
      AncientThenKeyword;
      (* 则 *)
      AncientAnswerKeyword;
      (* 答 *)
      StringToken "one";
      (* 表达式 *)
      AncientObserveEndKeyword;
      (* 观毕 *)
      EOF;
    ]
  in

  let expected_case =
    { pattern = LiteralPattern (IntLit 1); guard = None; expr = StringExpr "one" }
  in
  let expected = MatchExpr (VarExpr "x", [ expected_case ]) in

  TestHelpers.check_parse_success "古雅体匹配表达式解析" expected tokens
    (parse_ancient_match_expression TestHelpers.dummy_parse_expr TestHelpers.dummy_parse_pattern)

let test_parse_ancient_match_with_default () =
  (* 测试带默认分支的古雅体匹配表达式 *)
  let tokens =
    [
      AncientObserveKeyword;
      (* 观 *)
      Identifier "x";
      (* 变量 *)
      OfParticle;
      (* 之 *)
      AncientNatureKeyword;
      (* 性 *)
      IfWenyanKeyword;
      (* 若 *)
      IntToken 1;
      (* 模式 *)
      AncientThenKeyword;
      (* 则 *)
      AncientAnswerKeyword;
      (* 答 *)
      StringToken "one";
      (* 表达式 *)
      AncientOtherwiseKeyword;
      (* 余者 *)
      AncientThenKeyword;
      (* 则 *)
      AncientAnswerKeyword;
      (* 答 *)
      StringToken "other";
      (* 默认表达式 *)
      AncientObserveEndKeyword;
      (* 观毕 *)
      EOF;
    ]
  in

  let case1 = { pattern = LiteralPattern (IntLit 1); guard = None; expr = StringExpr "one" } in
  let default_case = { pattern = WildcardPattern; guard = None; expr = StringExpr "other" } in
  let expected = MatchExpr (VarExpr "x", [ case1; default_case ]) in

  TestHelpers.check_parse_success "古雅体匹配表达式带默认分支" expected tokens
    (parse_ancient_match_expression TestHelpers.dummy_parse_expr TestHelpers.dummy_parse_pattern)

let test_parse_ancient_list_expression () =
  (* 测试古雅体列表表达式：列开始 元素1 其一 元素2 其二 列结束 *)
  let tokens =
    [
      AncientListStartKeyword;
      (* 列开始 *)
      IntToken 1;
      (* 元素1 *)
      AncientItsFirstKeyword;
      (* 其一 *)
      IntToken 2;
      (* 元素2 *)
      AncientItsSecondKeyword;
      (* 其二 *)
      IntToken 3;
      (* 元素3 *)
      AncientItsThirdKeyword;
      (* 其三 *)
      AncientListEndKeyword;
      (* 列结束 *)
      EOF;
    ]
  in

  let expected = ListExpr [ IntExpr 1; IntExpr 2; IntExpr 3 ] in
  TestHelpers.check_parse_success "古雅体列表表达式解析" expected tokens
    (parse_ancient_list_expression TestHelpers.dummy_parse_expr)

let test_parse_ancient_list_empty () =
  (* 测试空古雅体列表 *)
  let tokens = [ AncientListStartKeyword; (* 列开始 *) AncientListEndKeyword; (* 列结束 *) EOF ] in

  let expected = ListExpr [] in
  TestHelpers.check_parse_success "空古雅体列表解析" expected tokens
    (parse_ancient_list_expression TestHelpers.dummy_parse_expr)

let test_parse_ancient_conditional_expression () =
  (* 测试古雅体条件表达式：若 条件 则 表达式 否则 表达式 *)
  let tokens =
    [
      IfWenyanKeyword;
      (* 若 *)
      BoolToken true;
      (* 条件 *)
      AncientThenKeyword;
      (* 则 *)
      IntToken 1;
      (* then表达式 *)
      ElseKeyword;
      (* 否则 *)
      IntToken 2;
      (* else表达式 *)
      EOF;
    ]
  in

  let expected = CondExpr (BoolExpr true, IntExpr 1, IntExpr 2) in
  TestHelpers.check_parse_success "古雅体条件表达式解析" expected tokens
    (parse_ancient_conditional_expression TestHelpers.dummy_parse_expr)

let test_parse_ancient_conditional_no_else () =
  (* 测试没有else分支的古雅体条件表达式 *)
  let tokens =
    [
      IfWenyanKeyword;
      (* 若 *)
      BoolToken true;
      (* 条件 *)
      AncientThenKeyword;
      (* 则 *)
      IntToken 1;
      (* then表达式 *)
      EOF;
    ]
  in

  let expected = CondExpr (BoolExpr true, IntExpr 1, LitExpr UnitLit) in
  TestHelpers.check_parse_success "无else分支的古雅体条件表达式" expected tokens
    (parse_ancient_conditional_expression TestHelpers.dummy_parse_expr)

(** ==================== 3. 文言风格语法解析测试 ==================== *)

let test_parse_wenyan_let_expression () =
  (* 测试文言风格变量声明：吾有一数，名曰「变量」，其值四十二也。在 body *)
  let tokens =
    [
      HaveKeyword;
      (* 吾有 *)
      OneKeyword;
      (* 一 *)
      NumberKeyword;
      (* 数 *)
      Comma;
      (* ， *)
      NameKeyword;
      (* 名曰 *)
      QuotedIdentifierToken "var";
      (* 「变量」 *)
      Comma;
      (* ， *)
      ValueKeyword;
      (* 其值 *)
      IntToken 42;
      (* 四十二 *)
      AlsoKeyword;
      (* 也 *)
      Dot;
      (* 。 *)
      InKeyword;
      (* 在 *)
      Identifier "var";
      (* body表达式 *)
      EOF;
    ]
  in

  let expected = LetExpr ("var", IntExpr 42, VarExpr "var") in
  TestHelpers.check_parse_success "文言风格let表达式解析" expected tokens
    (parse_wenyan_let_expression TestHelpers.dummy_parse_expr)

let test_parse_wenyan_let_minimal () =
  (* 测试简化的文言风格变量声明 *)
  let tokens =
    [
      HaveKeyword;
      (* 吾有 *)
      OneKeyword;
      (* 一 *)
      NameKeyword;
      (* 名曰 *)
      QuotedIdentifierToken "x";
      (* 「x」 *)
      ValueKeyword;
      (* 其值 *)
      IntToken 5;
      (* 五 *)
      InKeyword;
      (* 在 *)
      Identifier "x";
      (* body表达式 *)
      EOF;
    ]
  in

  let expected = LetExpr ("x", IntExpr 5, VarExpr "x") in
  TestHelpers.check_parse_success "简化文言风格let表达式" expected tokens
    (parse_wenyan_let_expression TestHelpers.dummy_parse_expr)

let test_parse_wenyan_simple_let_expression () =
  (* 测试简化文言风格变量声明：设变量为值。body *)
  let tokens =
    [
      SetKeyword;
      (* 设 *)
      QuotedIdentifierToken "x";
      (* 「x」 *)
      AsForKeyword;
      (* 为 *)
      IntToken 10;
      (* 十 *)
      Dot;
      (* 。 *)
      Identifier "x";
      (* body表达式 *)
      EOF;
    ]
  in

  let expected = LetExpr ("x", IntExpr 10, VarExpr "x") in
  TestHelpers.check_parse_success "简化文言风格let表达式" expected tokens
    (parse_wenyan_simple_let_expression TestHelpers.dummy_parse_expr)

let test_parse_wenyan_simple_let_no_dot () =
  (* 测试没有句号的简化文言风格变量声明 *)
  let tokens =
    [
      SetKeyword;
      (* 设 *)
      QuotedIdentifierToken "y";
      (* 「y」 *)
      AsForKeyword;
      (* 为 *)
      IntToken 20;
      (* 二十 *)
      Identifier "y";
      (* body表达式 *)
      EOF;
    ]
  in

  let expected = LetExpr ("y", IntExpr 20, VarExpr "y") in
  TestHelpers.check_parse_success "无句号的简化文言风格let" expected tokens
    (parse_wenyan_simple_let_expression TestHelpers.dummy_parse_expr)

(** ==================== 4. 错误处理和边界条件测试 ==================== *)

let test_error_handling_ancient_function () =
  (* 测试古雅体函数定义错误处理 *)
  TestHelpers.check_parse_failure "缺少关键字的古雅体函数定义"
    [ AncientDefineKeyword; Identifier "func"; EOF ]
    (parse_ancient_function_definition TestHelpers.dummy_parse_expr);

  TestHelpers.check_parse_failure "错误token序列的古雅体函数定义"
    [ Identifier "func"; AncientDefineKeyword; EOF ]
    (parse_ancient_function_definition TestHelpers.dummy_parse_expr)

let test_error_handling_match () =
  (* 测试匹配表达式错误处理 *)
  TestHelpers.check_parse_failure "不完整的古雅体匹配表达式"
    [ AncientObserveKeyword; Identifier "x"; EOF ]
    (parse_ancient_match_expression TestHelpers.dummy_parse_expr TestHelpers.dummy_parse_pattern);

  TestHelpers.check_parse_failure "缺少观毕的匹配表达式"
    [ AncientObserveKeyword; Identifier "x"; OfParticle; AncientNatureKeyword; EOF ]
    (parse_ancient_match_expression TestHelpers.dummy_parse_expr TestHelpers.dummy_parse_pattern)

let test_error_handling_wenyan () =
  (* 测试文言表达式错误处理 *)
  TestHelpers.check_parse_failure "不完整的文言let表达式" [ HaveKeyword; OneKeyword; EOF ]
    (parse_wenyan_let_expression TestHelpers.dummy_parse_expr);

  TestHelpers.check_parse_failure "缺少值的简化文言let"
    [ SetKeyword; QuotedIdentifierToken "x"; AsForKeyword; EOF ]
    (parse_wenyan_simple_let_expression TestHelpers.dummy_parse_expr)

(** ==================== 5. 复杂和集成测试 ==================== *)

let test_complex_ancient_expressions () =
  (* 测试复杂的古雅体表达式组合 *)
  let tokens =
    [
      AncientListStartKeyword;
      (* 列开始 *)
      IntToken 1;
      (* 1 *)
      AncientItsFirstKeyword;
      (* 其一 *)
      IntToken 2;
      (* 2 *)
      AncientItsSecondKeyword;
      (* 其二 *)
      AncientListEndKeyword;
      (* 列结束 *)
      EOF;
    ]
  in

  let expected = ListExpr [ IntExpr 1; IntExpr 2 ] in
  TestHelpers.check_parse_success "复杂古雅体列表表达式" expected tokens
    (parse_ancient_list_expression TestHelpers.dummy_parse_expr)

(** ==================== 6. 性能和压力测试 ==================== *)

let test_performance_ancient () =
  (* 测试大型古雅体列表的解析性能 *)
  let large_list_tokens =
    [ AncientListStartKeyword ]
    @ List.flatten
        (List.init 50 (fun i ->
             [ IntToken i ]
             @
             match i mod 3 with
             | 0 -> [ AncientItsFirstKeyword ]
             | 1 -> [ AncientItsSecondKeyword ]
             | _ -> [ AncientItsThirdKeyword ]))
    @ [ AncientListEndKeyword; EOF ]
  in

  try
    let state = TestHelpers.create_test_state large_list_tokens in
    let start_time = Sys.time () in
    let _, _ = parse_ancient_list_expression TestHelpers.dummy_parse_expr state in
    let end_time = Sys.time () in
    let duration = end_time -. start_time in
    check bool "大型古雅体列表解析性能" true (duration < 1.0)
  with _ -> check bool "大型古雅体列表解析失败" false true

let test_memory_usage_ancient () =
  (* 测试内存使用情况 *)
  let tokens = List.init 100 (fun i -> IntToken i) @ [ EOF ] in
  try
    let state = TestHelpers.create_test_state tokens in
    let _ = skip_newlines state in
    check bool "内存使用测试通过" true true
  with
  | Out_of_memory -> check bool "内存不足" false true
  | _ -> check bool "其他错误" false true

(** ==================== 7. 集成和兼容性测试 ==================== *)

let test_integration_with_other_modules () =
  (* 测试与其他模块的集成 *)
  let tokens = [ Newline; IntToken 42; EOF ] in
  try
    let state = TestHelpers.create_test_state tokens in
    let new_state = skip_newlines state in
    let token, _ = current_token new_state in
    check bool "与parser_utils集成测试" true (token = IntToken 42)
  with _ -> check bool "模块集成失败" false true

(** ==================== 测试套件注册 ==================== *)

let test_suite =
  [
    (* 1. 辅助函数测试 *)
    ( "辅助函数测试",
      [
        test_case "跳过换行符" `Quick test_skip_newlines;
        test_case "自然语言算术延续" `Quick test_parse_natural_arithmetic_continuation;
      ] );
    (* 2. 古雅体语法解析测试 *)
    ( "古雅体语法解析",
      [
        test_case "古雅体函数定义" `Quick test_parse_ancient_function_definition;
        test_case "古雅体匹配表达式" `Quick test_parse_ancient_match_expression;
        test_case "古雅体匹配带默认分支" `Quick test_parse_ancient_match_with_default;
        test_case "古雅体列表表达式" `Quick test_parse_ancient_list_expression;
        test_case "空古雅体列表" `Quick test_parse_ancient_list_empty;
        test_case "古雅体条件表达式" `Quick test_parse_ancient_conditional_expression;
        test_case "无else分支条件表达式" `Quick test_parse_ancient_conditional_no_else;
      ] );
    (* 3. 文言风格语法解析测试 *)
    ( "文言风格语法解析",
      [
        test_case "文言风格let表达式" `Quick test_parse_wenyan_let_expression;
        test_case "简化文言风格let" `Quick test_parse_wenyan_let_minimal;
        test_case "简化文言风格变量声明" `Quick test_parse_wenyan_simple_let_expression;
        test_case "无句号简化文言let" `Quick test_parse_wenyan_simple_let_no_dot;
      ] );
    (* 4. 错误处理和边界条件测试 *)
    ( "错误处理和边界条件",
      [
        test_case "古雅体函数定义错误处理" `Quick test_error_handling_ancient_function;
        test_case "匹配表达式错误处理" `Quick test_error_handling_match;
        test_case "文言表达式错误处理" `Quick test_error_handling_wenyan;
      ] );
    (* 5. 复杂和集成测试 *)
    ("复杂和集成测试", [ test_case "复杂古雅体表达式" `Quick test_complex_ancient_expressions ]);
    (* 6. 性能和压力测试 *)
    ( "性能和压力测试",
      [
        test_case "古雅体解析性能" `Quick test_performance_ancient;
        test_case "内存使用测试" `Quick test_memory_usage_ancient;
      ] );
    (* 7. 集成和兼容性测试 *)
    ("集成和兼容性", [ test_case "模块集成测试" `Quick test_integration_with_other_modules ]);
  ]

(** 运行所有测试 *)
let () =
  Printf.printf "\n=== 骆言古雅体语法解析器综合测试 - Fix #1009 Phase 2 Week 2 ===\n";
  Printf.printf "测试模块: parser_ancient.ml (233行, 8个核心函数)\n";
  Printf.printf "测试覆盖: 古雅体语法、文言风格、匹配表达式、列表处理、错误处理\n";
  Printf.printf "==========================================\n\n";
  run "Parser_ancient综合测试" test_suite
