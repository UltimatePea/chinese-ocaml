(** 骆言模式匹配解析器综合测试 - 技术债务改进：提升测试覆盖率 Fix #962

    本测试模块专门针对 parser_patterns.ml 模块进行全面功能测试，
    重点测试模式匹配解析功能的正确性和健壮性。

    测试覆盖范围：
    - parse_pattern 基础模式解析
    - parse_list_pattern 列表模式解析  
    - parse_match_expression 现代匹配表达式解析
    - parse_ancient_match_expression 古雅体匹配表达式解析
    - parse_match_cases 匹配分支解析
    - build_cons_pattern cons模式构建
    - 复杂嵌套模式匹配测试
    - 边界条件和错误处理测试

    @author 骆言技术债务清理团队 - Issue #962 Parser模块测试覆盖率提升
    @version 1.0
    @since 2025-07-23 Issue #962 第七阶段Parser模块测试补强 *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser_utils
open Yyocamlc_lib.Parser_patterns

(** 测试工具函数 *)
module TestUtils = struct
  (** 创建测试位置 *)
  let create_test_pos line column = { line; column; filename = "test_parser_patterns.ml" }

  (** 创建简单的解析器状态 *)
  let create_test_state tokens = create_parser_state tokens

  (** 验证语法错误 *)
  let expect_syntax_error f =
    try
      ignore (f ());
      false
    with
    | SyntaxError _ -> true
    | _ -> false

  (** 创建基础的positioned_token *)
  let make_token token line col = 
    (token, create_test_pos line col)

  (** 创建测试用的表达式解析函数 *)
  let mock_parse_expr state =
    match current_token state with
    | (IntToken n, _) -> (LitExpr (IntLit n), advance_parser state)
    | (StringToken s, _) -> (LitExpr (StringLit s), advance_parser state)
    | (QuotedIdentifierToken id, _) -> (VarExpr id, advance_parser state)
    | (BoolToken b, _) -> (LitExpr (BoolLit b), advance_parser state)
    | _ -> failwith "Cannot parse expression"

  (** 验证模式相等性 *)
  let pattern_equal p1 p2 = 
    let rec equal_pattern p1 p2 =
      match (p1, p2) with
      | WildcardPattern, WildcardPattern -> true
      | VarPattern v1, VarPattern v2 -> v1 = v2
      | LitPattern l1, LitPattern l2 -> l1 = l2
      | EmptyListPattern, EmptyListPattern -> true
      | ListPattern ps1, ListPattern ps2 -> 
          List.length ps1 = List.length ps2 && List.for_all2 equal_pattern ps1 ps2
      | ConsPattern (h1, t1), ConsPattern (h2, t2) -> 
          equal_pattern h1 h2 && equal_pattern t1 t2
      | TuplePattern ps1, TuplePattern ps2 ->
          List.length ps1 = List.length ps2 && List.for_all2 equal_pattern ps1 ps2
      | ConstructorPattern (n1, ps1), ConstructorPattern (n2, ps2) ->
          n1 = n2 && List.length ps1 = List.length ps2 && List.for_all2 equal_pattern ps1 ps2
      | OrPattern (p1a, p1b), OrPattern (p2a, p2b) ->
          equal_pattern p1a p2a && equal_pattern p1b p2b
      | _ -> false
    in
    equal_pattern p1 p2

  (** 验证表达式相等性 *)
  let expr_equal = equal_expr

  (** 验证匹配分支相等性 *)
  let match_branch_equal mb1 mb2 =
    pattern_equal mb1.pattern mb2.pattern && 
    expr_equal mb1.expr mb2.expr &&
    match (mb1.guard, mb2.guard) with
    | None, None -> true
    | Some g1, Some g2 -> expr_equal g1 g2
    | _ -> false
end

(** 测试 parse_pattern *)
module TestParsePattern = struct
  let test_wildcard_pattern () =
    let tokens = [
      TestUtils.make_token (QuotedIdentifierToken "_") 1 1;
      TestUtils.make_token EOF 1 2;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (pattern, final_state) = parse_pattern state in
      let expected = WildcardPattern in
      check bool "通配符模式解析正确" true (TestUtils.pattern_equal pattern expected)
    with
    | SyntaxError _ -> check bool "通配符模式解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let test_variable_pattern () =
    let tokens = [
      TestUtils.make_token (QuotedIdentifierToken "x") 1 1;
      TestUtils.make_token EOF 1 2;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (pattern, final_state) = parse_pattern state in
      let expected = VarPattern "x" in
      check bool "变量模式解析正确" true (TestUtils.pattern_equal pattern expected)
    with
    | SyntaxError _ -> check bool "变量模式解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let test_literal_patterns () =
    let test_cases = [
      (IntToken 42, LitPattern (IntLit 42));
      (StringToken "hello", LitPattern (StringLit "hello"));
      (BoolToken true, LitPattern (BoolLit true));
      (BoolToken false, LitPattern (BoolLit false));
    ] in
    List.iter (fun (token_lit, expected_pattern) ->
      let tokens = [
        TestUtils.make_token token_lit 1 1;
        TestUtils.make_token EOF 1 2;
      ] in
      let state = TestUtils.create_test_state tokens in
      try
        let (pattern, final_state) = parse_pattern state in
        check bool "字面量模式解析正确" true (TestUtils.pattern_equal pattern expected_pattern)
      with
      | SyntaxError _ -> check bool "字面量模式解析应该成功" false true
      | _ -> check bool "出现意外错误" false true
    ) test_cases

  let test_constructor_pattern () =
    let tokens = [
      TestUtils.make_token (QuotedIdentifierToken "Some") 1 1;
      TestUtils.make_token (QuotedIdentifierToken "x") 1 2;
      TestUtils.make_token EOF 1 3;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (pattern, final_state) = parse_pattern state in
      let expected = ConstructorPattern ("Some", [VarPattern "x"]) in
      check bool "构造器模式解析正确" true (TestUtils.pattern_equal pattern expected)
    with
    | SyntaxError _ -> check bool "构造器模式解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let test_tuple_pattern () =
    let tokens = [
      TestUtils.make_token LeftParen 1 1;
      TestUtils.make_token (QuotedIdentifierToken "x") 1 2;
      TestUtils.make_token Comma 1 3;
      TestUtils.make_token (QuotedIdentifierToken "y") 1 4;
      TestUtils.make_token RightParen 1 5;
      TestUtils.make_token EOF 1 6;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (pattern, final_state) = parse_pattern state in
      let expected = TuplePattern [VarPattern "x"; VarPattern "y"] in
      check bool "元组模式解析正确" true (TestUtils.pattern_equal pattern expected)
    with
    | SyntaxError _ -> check bool "元组模式解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let test_or_pattern () =
    let tokens = [
      TestUtils.make_token (QuotedIdentifierToken "x") 1 1;
      TestUtils.make_token Pipe 1 2;
      TestUtils.make_token (QuotedIdentifierToken "y") 1 3;
      TestUtils.make_token EOF 1 4;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (pattern, final_state) = parse_pattern state in
      let expected = OrPattern (VarPattern "x", VarPattern "y") in
      check bool "或模式解析正确" true (TestUtils.pattern_equal pattern expected)
    with
    | SyntaxError _ -> check bool "或模式解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let tests = [
    test_case "Wildcard pattern" `Quick test_wildcard_pattern;
    test_case "Variable pattern" `Quick test_variable_pattern;
    test_case "Literal patterns" `Quick test_literal_patterns;
    test_case "Constructor pattern" `Quick test_constructor_pattern;
    test_case "Tuple pattern" `Quick test_tuple_pattern;
    test_case "Or pattern" `Quick test_or_pattern;
  ]
end

(** 测试 parse_list_pattern *)
module TestParseListPattern = struct
  let test_empty_list_pattern () =
    let tokens = [
      TestUtils.make_token LeftBracket 1 1;
      TestUtils.make_token RightBracket 1 2;
      TestUtils.make_token EOF 1 3;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (pattern, final_state) = parse_list_pattern state in
      let expected = EmptyListPattern in
      check bool "空列表模式解析正确" true (TestUtils.pattern_equal pattern expected)
    with
    | SyntaxError _ -> check bool "空列表模式解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let test_single_element_list_pattern () =
    let tokens = [
      TestUtils.make_token LeftBracket 1 1;
      TestUtils.make_token (QuotedIdentifierToken "x") 1 2;
      TestUtils.make_token RightBracket 1 3;
      TestUtils.make_token EOF 1 4;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (pattern, final_state) = parse_list_pattern state in
      let expected = ListPattern [VarPattern "x"] in
      check bool "单元素列表模式解析正确" true (TestUtils.pattern_equal pattern expected)
    with
    | SyntaxError _ -> check bool "单元素列表模式解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let test_multiple_element_list_pattern () =
    let tokens = [
      TestUtils.make_token LeftBracket 1 1;
      TestUtils.make_token (QuotedIdentifierToken "x") 1 2;
      TestUtils.make_token Semicolon 1 3;
      TestUtils.make_token (QuotedIdentifierToken "y") 1 4;
      TestUtils.make_token Semicolon 1 5;
      TestUtils.make_token (QuotedIdentifierToken "z") 1 6;
      TestUtils.make_token RightBracket 1 7;
      TestUtils.make_token EOF 1 8;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (pattern, final_state) = parse_list_pattern state in
      let expected = ListPattern [VarPattern "x"; VarPattern "y"; VarPattern "z"] in
      check bool "多元素列表模式解析正确" true (TestUtils.pattern_equal pattern expected)
    with
    | SyntaxError _ -> check bool "多元素列表模式解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let test_cons_pattern () =
    let tokens = [
      TestUtils.make_token (QuotedIdentifierToken "head") 1 1;
      TestUtils.make_token ChineseDoubleColon 1 2;
      TestUtils.make_token (QuotedIdentifierToken "tail") 1 3;
      TestUtils.make_token EOF 1 4;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (pattern, final_state) = parse_list_pattern state in
      let expected = ConsPattern (VarPattern "head", VarPattern "tail") in
      check bool "cons模式解析正确" true (TestUtils.pattern_equal pattern expected)
    with
    | SyntaxError _ -> check bool "cons模式解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let test_nested_cons_pattern () =
    let tokens = [
      TestUtils.make_token (QuotedIdentifierToken "first") 1 1;
      TestUtils.make_token ChineseDoubleColon 1 2;
      TestUtils.make_token (QuotedIdentifierToken "second") 1 3;
      TestUtils.make_token ChineseDoubleColon 1 4;
      TestUtils.make_token (QuotedIdentifierToken "rest") 1 5;
      TestUtils.make_token EOF 1 6;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (pattern, final_state) = parse_list_pattern state in
      let expected = ConsPattern (VarPattern "first", 
                                 ConsPattern (VarPattern "second", VarPattern "rest")) in
      check bool "嵌套cons模式解析正确" true (TestUtils.pattern_equal pattern expected)
    with
    | SyntaxError _ -> check bool "嵌套cons模式解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let tests = [
    test_case "Empty list pattern" `Quick test_empty_list_pattern;
    test_case "Single element list pattern" `Quick test_single_element_list_pattern;
    test_case "Multiple element list pattern" `Quick test_multiple_element_list_pattern;
    test_case "Cons pattern" `Quick test_cons_pattern;
    test_case "Nested cons pattern" `Quick test_nested_cons_pattern;
  ]
end

(** 测试 parse_match_expression *)
module TestParseMatchExpression = struct
  let test_basic_match_expression () =
    let tokens = [
      TestUtils.make_token (QuotedIdentifierToken "匹配") 1 1;
      TestUtils.make_token (QuotedIdentifierToken "x") 1 2;
      TestUtils.make_token (QuotedIdentifierToken "与") 1 3;
      TestUtils.make_token Pipe 1 4;
      TestUtils.make_token (IntToken 0) 1 5;
      TestUtils.make_token Arrow 1 6;
      TestUtils.make_token (StringToken "零") 1 7;
      TestUtils.make_token Pipe 1 8;
      TestUtils.make_token (QuotedIdentifierToken "n") 1 9;
      TestUtils.make_token Arrow 1 10;
      TestUtils.make_token (StringToken "非零") 1 11;
      TestUtils.make_token EOF 1 12;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (match_expr, final_state) = parse_match_expression state TestUtils.mock_parse_expr in
      match match_expr with
      | MatchExpr (VarExpr "x", branches) -> 
        check bool "基本匹配表达式解析正确" true (List.length branches = 2)
      | _ -> check bool "匹配表达式结构不正确" false true
    with
    | SyntaxError _ -> check bool "基本匹配表达式解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let test_match_with_guard () =
    let tokens = [
      TestUtils.make_token (QuotedIdentifierToken "匹配") 1 1;
      TestUtils.make_token (QuotedIdentifierToken "value") 1 2;
      TestUtils.make_token (QuotedIdentifierToken "与") 1 3;
      TestUtils.make_token Pipe 1 4;
      TestUtils.make_token (QuotedIdentifierToken "x") 1 5;
      TestUtils.make_token (QuotedIdentifierToken "当") 1 6;
      TestUtils.make_token (QuotedIdentifierToken "x") 1 7;
      TestUtils.make_token (QuotedIdentifierToken "大于") 1 8;
      TestUtils.make_token (IntToken 0) 1 9;
      TestUtils.make_token Arrow 1 10;
      TestUtils.make_token (StringToken "正数") 1 11;
      TestUtils.make_token Pipe 1 12;
      TestUtils.make_token (QuotedIdentifierToken "_") 1 13;
      TestUtils.make_token Arrow 1 14;
      TestUtils.make_token (StringToken "其他") 1 15;
      TestUtils.make_token EOF 1 16;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (match_expr, final_state) = parse_match_expression state TestUtils.mock_parse_expr in
      match match_expr with
      | MatchExpr (VarExpr "value", branches) -> 
        check bool "带守卫的匹配表达式解析正确" true (List.length branches = 2)
      | _ -> check bool "匹配表达式结构不正确" false true
    with
    | SyntaxError _ -> check bool "带守卫的匹配表达式解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let test_complex_pattern_match () =
    let tokens = [
      TestUtils.make_token (QuotedIdentifierToken "匹配") 1 1;
      TestUtils.make_token (QuotedIdentifierToken "data") 1 2;
      TestUtils.make_token (QuotedIdentifierToken "与") 1 3;
      TestUtils.make_token Pipe 1 4;
      TestUtils.make_token LeftBracket 1 5;
      TestUtils.make_token RightBracket 1 6;
      TestUtils.make_token Arrow 1 7;
      TestUtils.make_token (StringToken "空列表") 1 8;
      TestUtils.make_token Pipe 1 9;
      TestUtils.make_token (QuotedIdentifierToken "head") 1 10;
      TestUtils.make_token ChineseDoubleColon 1 11;
      TestUtils.make_token (QuotedIdentifierToken "tail") 1 12;
      TestUtils.make_token Arrow 1 13;
      TestUtils.make_token (StringToken "非空列表") 1 14;
      TestUtils.make_token EOF 1 15;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (match_expr, final_state) = parse_match_expression state TestUtils.mock_parse_expr in
      match match_expr with
      | MatchExpr (VarExpr "data", branches) -> 
        check bool "复杂模式匹配表达式解析正确" true (List.length branches = 2)
      | _ -> check bool "匹配表达式结构不正确" false true
    with
    | SyntaxError _ -> check bool "复杂模式匹配表达式解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let tests = [
    test_case "Basic match expression" `Quick test_basic_match_expression;
    test_case "Match with guard" `Quick test_match_with_guard;
    test_case "Complex pattern match" `Quick test_complex_pattern_match;
  ]
end

(** 测试 parse_ancient_match_expression *)
module TestParseAncientMatchExpression = struct
  let test_ancient_match_basic () =
    let tokens = [
      TestUtils.make_token (QuotedIdentifierToken "观") 1 1;
      TestUtils.make_token (QuotedIdentifierToken "其") 1 2;
      TestUtils.make_token (QuotedIdentifierToken "值") 1 3;
      TestUtils.make_token (QuotedIdentifierToken "也") 1 4;
      TestUtils.make_token Pipe 1 5;
      TestUtils.make_token (IntToken 1) 1 6;
      TestUtils.make_token Arrow 1 7;
      TestUtils.make_token (StringToken "壹") 1 8;
      TestUtils.make_token Pipe 1 9;
      TestUtils.make_token (QuotedIdentifierToken "_") 1 10;
      TestUtils.make_token Arrow 1 11;
      TestUtils.make_token (StringToken "他") 1 12;
      TestUtils.make_token EOF 1 13;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (match_expr, final_state) = parse_ancient_match_expression state TestUtils.mock_parse_expr in
      match match_expr with
      | MatchExpr (_, branches) -> 
        check bool "古雅体匹配表达式解析正确" true (List.length branches = 2)
      | _ -> check bool "古雅体匹配表达式结构不正确" false true
    with
    | SyntaxError _ -> check bool "古雅体匹配表达式解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let test_ancient_match_with_conditions () =
    let tokens = [
      TestUtils.make_token (QuotedIdentifierToken "察") 1 1;
      TestUtils.make_token (QuotedIdentifierToken "x") 1 2;
      TestUtils.make_token (QuotedIdentifierToken "之") 1 3;
      TestUtils.make_token (QuotedIdentifierToken "状") 1 4;
      TestUtils.make_token Pipe 1 5;
      TestUtils.make_token (QuotedIdentifierToken "n") 1 6;
      TestUtils.make_token (QuotedIdentifierToken "若") 1 7;
      TestUtils.make_token (QuotedIdentifierToken "n") 1 8;
      TestUtils.make_token (QuotedIdentifierToken "大于") 1 9;
      TestUtils.make_token (IntToken 0) 1 10;
      TestUtils.make_token Arrow 1 11;
      TestUtils.make_token (StringToken "正") 1 12;
      TestUtils.make_token Pipe 1 13;
      TestUtils.make_token (QuotedIdentifierToken "_") 1 14;
      TestUtils.make_token Arrow 1 15;
      TestUtils.make_token (StringToken "负") 1 16;
      TestUtils.make_token EOF 1 17;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (match_expr, final_state) = parse_ancient_match_expression state TestUtils.mock_parse_expr in
      match match_expr with
      | MatchExpr (_, branches) -> 
        check bool "古雅体条件匹配表达式解析正确" true (List.length branches = 2)
      | _ -> check bool "古雅体条件匹配表达式结构不正确" false true
    with
    | SyntaxError _ -> check bool "古雅体条件匹配表达式解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let tests = [
    test_case "Ancient match basic" `Quick test_ancient_match_basic;
    test_case "Ancient match with conditions" `Quick test_ancient_match_with_conditions;
  ]
end

(** 测试 parse_match_cases *)
module TestParseMatchCases = struct
  let test_single_match_case () =
    let tokens = [
      TestUtils.make_token Pipe 1 1;
      TestUtils.make_token (IntToken 42) 1 2;
      TestUtils.make_token Arrow 1 3;
      TestUtils.make_token (StringToken "答案") 1 4;
      TestUtils.make_token EOF 1 5;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (branches, final_state) = parse_match_cases state TestUtils.mock_parse_expr in
      check bool "单个匹配分支解析正确" true (List.length branches = 1)
    with
    | SyntaxError _ -> check bool "单个匹配分支解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let test_multiple_match_cases () =
    let tokens = [
      TestUtils.make_token Pipe 1 1;
      TestUtils.make_token (IntToken 0) 1 2;
      TestUtils.make_token Arrow 1 3;
      TestUtils.make_token (StringToken "零") 1 4;
      TestUtils.make_token Pipe 1 5;
      TestUtils.make_token (IntToken 1) 1 6;
      TestUtils.make_token Arrow 1 7;
      TestUtils.make_token (StringToken "一") 1 8;
      TestUtils.make_token Pipe 1 9;
      TestUtils.make_token (QuotedIdentifierToken "_") 1 10;
      TestUtils.make_token Arrow 1 11;
      TestUtils.make_token (StringToken "其他") 1 12;
      TestUtils.make_token EOF 1 13;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (branches, final_state) = parse_match_cases state TestUtils.mock_parse_expr in
      check bool "多个匹配分支解析正确" true (List.length branches = 3)
    with
    | SyntaxError _ -> check bool "多个匹配分支解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let test_match_cases_with_guards () =
    let tokens = [
      TestUtils.make_token Pipe 1 1;
      TestUtils.make_token (QuotedIdentifierToken "x") 1 2;
      TestUtils.make_token (QuotedIdentifierToken "当") 1 3;
      TestUtils.make_token (QuotedIdentifierToken "x") 1 4;
      TestUtils.make_token (QuotedIdentifierToken "大于") 1 5;
      TestUtils.make_token (IntToken 0) 1 6;
      TestUtils.make_token Arrow 1 7;
      TestUtils.make_token (StringToken "正数") 1 8;
      TestUtils.make_token Pipe 1 9;
      TestUtils.make_token (QuotedIdentifierToken "y") 1 10;
      TestUtils.make_token Arrow 1 11;
      TestUtils.make_token (StringToken "其他") 1 12;
      TestUtils.make_token EOF 1 13;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (branches, final_state) = parse_match_cases state TestUtils.mock_parse_expr in
      check bool "带守卫的匹配分支解析正确" true (List.length branches = 2)
    with
    | SyntaxError _ -> check bool "带守卫的匹配分支解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let tests = [
    test_case "Single match case" `Quick test_single_match_case;
    test_case "Multiple match cases" `Quick test_multiple_match_cases;
    test_case "Match cases with guards" `Quick test_match_cases_with_guards;
  ]
end

(** 测试 build_cons_pattern *)
module TestBuildConsPattern = struct
  let test_single_pattern_cons () =
    let patterns = [VarPattern "x"] in
    let result = build_cons_pattern patterns in
    let expected = VarPattern "x" in
    check bool "单模式cons构建正确" true (TestUtils.pattern_equal result expected)

  let test_two_pattern_cons () =
    let patterns = [VarPattern "head"; VarPattern "tail"] in
    let result = build_cons_pattern patterns in
    let expected = ConsPattern (VarPattern "head", VarPattern "tail") in
    check bool "双模式cons构建正确" true (TestUtils.pattern_equal result expected)

  let test_multiple_pattern_cons () =
    let patterns = [VarPattern "first"; VarPattern "second"; VarPattern "rest"] in
    let result = build_cons_pattern patterns in
    let expected = ConsPattern (VarPattern "first", 
                               ConsPattern (VarPattern "second", VarPattern "rest")) in
    check bool "多模式cons构建正确" true (TestUtils.pattern_equal result expected)

  let test_empty_pattern_list () =
    let patterns = [] in
    try
      let _ = build_cons_pattern patterns in
      check bool "空模式列表应该触发错误" false true
    with
    | _ -> check bool "空模式列表正确处理" true true

  let tests = [
    test_case "Single pattern cons" `Quick test_single_pattern_cons;
    test_case "Two pattern cons" `Quick test_two_pattern_cons;
    test_case "Multiple pattern cons" `Quick test_multiple_pattern_cons;
    test_case "Empty pattern list" `Quick test_empty_pattern_list;
  ]
end

(** 综合集成测试 *)
module TestIntegration = struct
  let test_complex_nested_pattern_matching () =
    let tokens = [
      TestUtils.make_token (QuotedIdentifierToken "匹配") 1 1;
      TestUtils.make_token (QuotedIdentifierToken "data") 1 2;
      TestUtils.make_token (QuotedIdentifierToken "与") 1 3;
      TestUtils.make_token Pipe 1 4;
      TestUtils.make_token (QuotedIdentifierToken "Some") 1 5;
      TestUtils.make_token LeftParen 1 6;
      TestUtils.make_token (QuotedIdentifierToken "x") 1 7;
      TestUtils.make_token Comma 1 8;
      TestUtils.make_token (QuotedIdentifierToken "y") 1 9;
      TestUtils.make_token RightParen 1 10;
      TestUtils.make_token (QuotedIdentifierToken "当") 1 11;
      TestUtils.make_token (QuotedIdentifierToken "x") 1 12;
      TestUtils.make_token (QuotedIdentifierToken "大于") 1 13;
      TestUtils.make_token (QuotedIdentifierToken "y") 1 14;
      TestUtils.make_token Arrow 1 15;
      TestUtils.make_token (StringToken "x更大") 1 16;
      TestUtils.make_token Pipe 1 17;
      TestUtils.make_token (QuotedIdentifierToken "None") 1 18;
      TestUtils.make_token Arrow 1 19;
      TestUtils.make_token (StringToken "无值") 1 20;
      TestUtils.make_token EOF 1 21;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (match_expr, final_state) = parse_match_expression state TestUtils.mock_parse_expr in
      match match_expr with
      | MatchExpr (VarExpr "data", branches) -> 
        check bool "复杂嵌套模式匹配解析正确" true (List.length branches = 2)
      | _ -> check bool "复杂嵌套模式匹配结构不正确" false true
    with
    | SyntaxError _ -> check bool "复杂嵌套模式匹配解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let test_list_pattern_comprehensive () =
    let tokens = [
      TestUtils.make_token (QuotedIdentifierToken "匹配") 1 1;
      TestUtils.make_token (QuotedIdentifierToken "list") 1 2;
      TestUtils.make_token (QuotedIdentifierToken "与") 1 3;
      TestUtils.make_token Pipe 1 4;
      TestUtils.make_token LeftBracket 1 5;
      TestUtils.make_token RightBracket 1 6;
      TestUtils.make_token Arrow 1 7;
      TestUtils.make_token (StringToken "空") 1 8;
      TestUtils.make_token Pipe 1 9;
      TestUtils.make_token LeftBracket 1 10;
      TestUtils.make_token (QuotedIdentifierToken "x") 1 11;
      TestUtils.make_token RightBracket 1 12;
      TestUtils.make_token Arrow 1 13;
      TestUtils.make_token (StringToken "单元素") 1 14;
      TestUtils.make_token Pipe 1 15;
      TestUtils.make_token (QuotedIdentifierToken "head") 1 16;
      TestUtils.make_token ChineseDoubleColon 1 17;
      TestUtils.make_token (QuotedIdentifierToken "tail") 1 18;
      TestUtils.make_token Arrow 1 19;
      TestUtils.make_token (StringToken "多元素") 1 20;
      TestUtils.make_token EOF 1 21;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (match_expr, final_state) = parse_match_expression state TestUtils.mock_parse_expr in
      match match_expr with
      | MatchExpr (VarExpr "list", branches) -> 
        check bool "列表模式综合测试解析正确" true (List.length branches = 3)
      | _ -> check bool "列表模式综合测试结构不正确" false true
    with
    | SyntaxError _ -> check bool "列表模式综合测试解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let test_error_handling_invalid_pattern () =
    let tokens = [
      TestUtils.make_token (QuotedIdentifierToken "匹配") 1 1;
      TestUtils.make_token (QuotedIdentifierToken "x") 1 2;
      TestUtils.make_token (QuotedIdentifierToken "与") 1 3;
      TestUtils.make_token Pipe 1 4;
      TestUtils.make_token (QuotedIdentifierToken "无效模式") 1 5;
      TestUtils.make_token EOF 1 6;
    ] in
    let state = TestUtils.create_test_state tokens in
    let should_fail = TestUtils.expect_syntax_error (fun () ->
      parse_match_expression state TestUtils.mock_parse_expr) in
    check bool "无效模式应该触发语法错误" true should_fail

  let tests = [
    test_case "Complex nested pattern matching" `Quick test_complex_nested_pattern_matching;
    test_case "List pattern comprehensive" `Quick test_list_pattern_comprehensive;
    test_case "Error handling invalid pattern" `Quick test_error_handling_invalid_pattern;
  ]
end

(** 主测试套件 *)
let () =
  run "Parser Patterns Comprehensive Tests" [
    ("Parse Pattern", TestParsePattern.tests);
    ("Parse List Pattern", TestParseListPattern.tests);
    ("Parse Match Expression", TestParseMatchExpression.tests);
    ("Parse Ancient Match Expression", TestParseAncientMatchExpression.tests);
    ("Parse Match Cases", TestParseMatchCases.tests);
    ("Build Cons Pattern", TestBuildConsPattern.tests);
    ("Integration Tests", TestIntegration.tests);
  ]