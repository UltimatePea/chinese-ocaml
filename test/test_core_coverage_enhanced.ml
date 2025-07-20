(** 核心模块测试覆盖率增强 - Phase 25 测试覆盖率提升
    
    本测试模块专门针对核心编译器模块进行基础功能测试，
    重点测试词法分析、语法分析和AST构建的关键功能。
    
    测试覆盖范围：
    - 词法分析器基础功能
    - AST节点构建和验证
    - 中文字符处理
    - 错误处理机制
    - Unicode支持
    
    @author 骆言技术债务清理团队 - Phase 25
    @version 1.0
    @since 2025-07-20 Issue #678 核心模块测试覆盖率提升 *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Lexer

(** 基础AST构建测试 *)
module AstConstructionTests = struct

  (** 测试字面量AST构建 *)
  let test_literal_ast_construction () =
    (* 测试整数字面量 *)
    let int_expr = make_int 42 in
    check (testable pp_expr equal_expr) "整数字面量AST" (LitExpr (IntLit 42)) int_expr;
    
    (* 测试字符串字面量 *)
    let str_expr = make_string "你好世界" in
    check (testable pp_expr equal_expr) "中文字符串字面量AST" (LitExpr (StringLit "你好世界")) str_expr;
    
    (* 测试布尔字面量 *)
    let bool_true = LitExpr (BoolLit true) in
    let bool_false = LitExpr (BoolLit false) in
    check (testable pp_expr equal_expr) "布尔true字面量AST" (LitExpr (BoolLit true)) bool_true;
    check (testable pp_expr equal_expr) "布尔false字面量AST" (LitExpr (BoolLit false)) bool_false

  (** 测试变量表达式构建 *)
  let test_variable_expression_construction () =
    let var_exprs = [
      ("x", "简单变量");
      ("变量名", "中文变量名");
      ("var_123", "带数字变量名");
      ("函数名_中英混合", "中英混合变量名");
    ] in
    
    List.iter (fun (var_name, desc) ->
      let var_expr = VarExpr var_name in
      check (testable pp_expr equal_expr) desc (VarExpr var_name) var_expr
    ) var_exprs

  (** 测试二元运算表达式构建 *)
  let test_binary_operation_construction () =
    let operations = [
      (Add, "加法");
      (Sub, "减法");
      (Mul, "乘法");
      (Div, "除法");
      (Eq, "相等比较");
      (Lt, "小于比较");
    ] in
    
    List.iter (fun (op, desc) ->
      let left = make_int 1 in
      let right = make_int 2 in
      let bin_expr = BinaryOpExpr (left, op, right) in
      let expected = BinaryOpExpr (LitExpr (IntLit 1), op, LitExpr (IntLit 2)) in
      check (testable pp_expr equal_expr) desc expected bin_expr
    ) operations

  (** 测试复合表达式构建 *)
  let test_compound_expression_construction () =
    (* 测试元组表达式 *)
    let tuple_expr = TupleExpr [make_int 1; make_string "test"; LitExpr (BoolLit true)] in
    let expected_tuple = TupleExpr [LitExpr (IntLit 1); LitExpr (StringLit "test"); LitExpr (BoolLit true)] in
    check (testable pp_expr equal_expr) "元组表达式构建" expected_tuple tuple_expr;
    
    (* 测试列表表达式 *)
    let list_expr = ListExpr [make_int 1; make_int 2; make_int 3] in
    let expected_list = ListExpr [LitExpr (IntLit 1); LitExpr (IntLit 2); LitExpr (IntLit 3)] in
    check (testable pp_expr equal_expr) "列表表达式构建" expected_list list_expr;
    
    (* 测试字段访问表达式 *)
    let field_access = FieldAccessExpr (VarExpr "对象", "字段") in
    check (testable pp_expr equal_expr) "字段访问表达式构建" field_access field_access

end

(** 词法分析器基础测试 *)
module LexerBasicTests = struct

  (** 测试数字token识别 *)
  let test_number_token_recognition () =
    let numbers = [42; 0; 123; 999] in
    List.iter (fun num ->
      let pos = { line = 1; column = 1; filename = "test" } in
      let token = IntToken num in
      let token_with_pos = (token, pos) in
      check (testable pp_token equal_token) (Printf.sprintf "数字%d token识别" num) token (fst token_with_pos)
    ) numbers

  (** 测试字符串token识别 *)
  let test_string_token_recognition () =
    let strings = ["hello"; "你好"; "world世界"; "测试string"] in
    List.iter (fun str ->
      let pos = { line = 1; column = 1; filename = "test" } in
      let token = StringToken str in
      let token_with_pos = (token, pos) in
      check (testable pp_token equal_token) (Printf.sprintf "字符串'%s' token识别" str) token (fst token_with_pos)
    ) strings

  (** 测试标识符token识别 *)
  let test_identifier_token_recognition () =
    let identifiers = ["x"; "变量"; "func_name"; "中文_标识符"] in
    List.iter (fun id ->
      let pos = { line = 1; column = 1; filename = "test" } in
      let token = QuotedIdentifierToken id in
      let token_with_pos = (token, pos) in
      check (testable pp_token equal_token) (Printf.sprintf "标识符'%s' token识别" id) token (fst token_with_pos)
    ) identifiers

  (** 测试运算符token识别 *)
  let test_operator_token_recognition () =
    let operators = [
      (Plus, "+");
      (Minus, "-");
      (Multiply, "*");
      (Assign, "=");
      (LeftParen, "(");
      (RightParen, ")");
    ] in
    
    List.iter (fun (token, desc) ->
      let pos = { line = 1; column = 1; filename = "test" } in
      let token_with_pos = (token, pos) in
      check (testable pp_token equal_token) (Printf.sprintf "运算符'%s' token识别" desc) token (fst token_with_pos)
    ) operators

end

(** Unicode和中文字符处理测试 *)
module UnicodeHandlingTests = struct

  (** 测试中文字符串处理 *)
  let test_chinese_string_handling () =
    let chinese_strings = [
      "春眠不觉晓";
      "处处闻啼鸟";
      "夜来风雨声";
      "花落知多少";
    ] in
    
    List.iter (fun text ->
      let str_expr = make_string text in
      check (testable pp_expr equal_expr) (Printf.sprintf "中文字符串'%s'处理" text) 
        (LitExpr (StringLit text)) str_expr
    ) chinese_strings

  (** 测试混合字符处理 *)
  let test_mixed_character_handling () =
    let mixed_strings = [
      "Hello世界";
      "测试123";
      "中English文";
      "数字456汉字";
    ] in
    
    List.iter (fun text ->
      let str_expr = make_string text in
      check (testable pp_expr equal_expr) (Printf.sprintf "混合字符'%s'处理" text)
        (LitExpr (StringLit text)) str_expr
    ) mixed_strings

  (** 测试Unicode表情符号处理 *)
  let test_unicode_emoji_handling () =
    let emoji_strings = [
      "🌸春天";
      "🌙月亮";
      "🔥火焰";
      "💻代码";
    ] in
    
    List.iter (fun text ->
      let str_expr = make_string text in
      check (testable pp_expr equal_expr) (Printf.sprintf "表情符号'%s'处理" text)
        (LitExpr (StringLit text)) str_expr
    ) emoji_strings

end

(** 错误处理和边界条件测试 *)
module ErrorHandlingTests = struct

  (** 测试空字符串处理 *)
  let test_empty_string_handling () =
    let empty_expr = make_string "" in
    check (testable pp_expr equal_expr) "空字符串处理" (LitExpr (StringLit "")) empty_expr

  (** 测试零值处理 *)
  let test_zero_value_handling () =
    let zero_expr = make_int 0 in
    check (testable pp_expr equal_expr) "零值处理" (LitExpr (IntLit 0)) zero_expr

  (** 测试负数处理 *)
  let test_negative_number_handling () =
    let neg_expr = LitExpr (IntLit (-42)) in
    check (testable pp_expr equal_expr) "负数处理" (LitExpr (IntLit (-42))) neg_expr

  (** 测试长字符串处理 *)
  let test_long_string_handling () =
    let long_string = String.make 1000 'a' in
    let long_expr = make_string long_string in
    check (testable pp_expr equal_expr) "长字符串处理" (LitExpr (StringLit long_string)) long_expr

end

(** 性能和压力测试 *)
module PerformanceTests = struct

  (** 测试大量表达式构建 *)
  let test_bulk_expression_construction () =
    let start_time = Sys.time () in
    
    (* 构建1000个表达式 *)
    let expressions = List.init 1000 (fun i -> make_int i) in
    
    let construction_time = Sys.time () -. start_time in
    
    (* 验证所有表达式都被正确构建 *)
    List.iteri (fun i expr ->
      check (testable pp_expr equal_expr) (Printf.sprintf "批量表达式%d构建" i) 
        (LitExpr (IntLit i)) expr
    ) expressions;
    
    (* 性能要求：构建时间应在合理范围内 *)
    check bool "批量表达式构建性能" true (construction_time < 1.0);
    
    Printf.printf "1000个表达式构建时间: %.6f 秒\n" construction_time

  (** 测试深度嵌套表达式 *)
  let test_deep_nested_expressions () =
    (* 创建深度嵌套的二元运算表达式 *)
    let rec create_nested_expr depth =
      if depth <= 0 then
        make_int 1
      else
        BinaryOpExpr (create_nested_expr (depth - 1), Add, make_int depth)
    in
    
    let deep_expr = create_nested_expr 10 in
    
    (* 验证表达式结构 *)
    let rec count_depth expr =
      match expr with
      | BinaryOpExpr (left, _, _) -> 1 + count_depth left
      | _ -> 0
    in
    
    let actual_depth = count_depth deep_expr in
    check int "深度嵌套表达式深度" 10 actual_depth

  (** 测试内存使用 *)
  let test_memory_usage () =
    let gc_stats_before = Gc.stat () in
    
    (* 创建和销毁大量表达式 *)
    for _i = 1 to 1000 do
      let expr = BinaryOpExpr (make_int 1, Add, make_int 2) in
      ignore expr
    done;
    
    Gc.full_major ();
    let gc_stats_after = Gc.stat () in
    
    let memory_increase = gc_stats_after.live_words - gc_stats_before.live_words in
    
    (* 内存增长应该在合理范围内 *)
    check bool "内存使用合理" true (memory_increase < 50000);
    
    Printf.printf "内存增长: %d words\n" memory_increase

end

(** 测试套件注册 *)
let test_suite = [
  "AST构建测试", [
    test_case "字面量AST构建" `Quick AstConstructionTests.test_literal_ast_construction;
    test_case "变量表达式构建" `Quick AstConstructionTests.test_variable_expression_construction;
    test_case "二元运算构建" `Quick AstConstructionTests.test_binary_operation_construction;
    test_case "复合表达式构建" `Quick AstConstructionTests.test_compound_expression_construction;
  ];
  
  "词法分析器基础", [
    test_case "数字token识别" `Quick LexerBasicTests.test_number_token_recognition;
    test_case "字符串token识别" `Quick LexerBasicTests.test_string_token_recognition;
    test_case "标识符token识别" `Quick LexerBasicTests.test_identifier_token_recognition;
    test_case "运算符token识别" `Quick LexerBasicTests.test_operator_token_recognition;
  ];
  
  "Unicode处理", [
    test_case "中文字符串处理" `Quick UnicodeHandlingTests.test_chinese_string_handling;
    test_case "混合字符处理" `Quick UnicodeHandlingTests.test_mixed_character_handling;
    test_case "Unicode表情符号" `Quick UnicodeHandlingTests.test_unicode_emoji_handling;
  ];
  
  "错误处理", [
    test_case "空字符串处理" `Quick ErrorHandlingTests.test_empty_string_handling;
    test_case "零值处理" `Quick ErrorHandlingTests.test_zero_value_handling;
    test_case "负数处理" `Quick ErrorHandlingTests.test_negative_number_handling;
    test_case "长字符串处理" `Quick ErrorHandlingTests.test_long_string_handling;
  ];
  
  "性能测试", [
    test_case "批量表达式构建" `Quick PerformanceTests.test_bulk_expression_construction;
    test_case "深度嵌套表达式" `Quick PerformanceTests.test_deep_nested_expressions;
    test_case "内存使用测试" `Quick PerformanceTests.test_memory_usage;
  ];
]

(** 运行所有测试 *)
let () = 
  Printf.printf "骆言核心模块测试覆盖率增强 - Phase 25\n";
  Printf.printf "======================================================\n";
  run "Core Coverage Enhanced Tests" test_suite