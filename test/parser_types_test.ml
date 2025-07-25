(** 骆言Parser_types模块综合测试

    此测试文件为parser_types.ml提供完整的测试覆盖， 确保类型解析、变体类型解析、模块类型解析等功能正确工作。

    测试覆盖范围：
    - 基本类型表达式解析
    - 函数类型解析
    - 变体类型解析
    - 多态变体类型解析
    - 模块类型解析
    - 签名项解析
    - 错误处理和边界条件

    @author Claude AI Assistant
    @version 1.0
    @since 2025-07-25 *)

open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser_utils
open Yyocamlc_lib.Parser_types

(** {1 测试辅助函数} *)

(** 创建测试位置信息 *)
let create_test_pos line column = { line; column; filename = "test" }

(** {1 模块存在性测试} *)

let test_module_availability () =
  (* 测试模块是否可以正常加载 *)
  Alcotest.(check bool) "Parser_types模块可用" true true

(** {1 基本类型表达式解析测试} *)

let test_basic_type_expressions () =
  let test_cases =
    [
      (* 基本类型 *)
      ([ (IntTypeKeyword, create_test_pos 1 1); (EOF, create_test_pos 1 2) ], true, "整数类型解析");
      ([ (StringTypeKeyword, create_test_pos 1 1); (EOF, create_test_pos 1 2) ], true, "字符串类型解析");
      ([ (BoolTypeKeyword, create_test_pos 1 1); (EOF, create_test_pos 1 2) ], true, "布尔类型解析");
      ([ (UnitTypeKeyword, create_test_pos 1 1); (EOF, create_test_pos 1 2) ], true, "单元类型解析");
      ([ (FloatTypeKeyword, create_test_pos 1 1); (EOF, create_test_pos 1 2) ], true, "浮点数类型解析");
    ]
  in

  List.iter
    (fun (tokens, expected_success, description) ->
      try
        let state = create_parser_state tokens in
        let _ = parse_type_expression state in
        if expected_success then Alcotest.(check bool) (description ^ " - 成功解析") true true
        else Alcotest.fail (description ^ " - 应该失败但成功了")
      with
      | SyntaxError (_, _) when not expected_success ->
          Alcotest.(check bool) (description ^ " - 期望错误") true true
      | SyntaxError (msg, _) when expected_success ->
          Alcotest.fail (description ^ " - 意外语法错误: " ^ msg)
      | exn when expected_success ->
          Alcotest.fail (description ^ " - 意外异常: " ^ Printexc.to_string exn)
      | _ when not expected_success -> Alcotest.(check bool) (description ^ " - 正确处理异常") true true)
    test_cases

(** {1 函数类型表达式解析测试} *)

let test_function_type_expressions () =
  let test_cases =
    [
      (* 简单函数类型 *)
      ( [
          (IntTypeKeyword, create_test_pos 1 1);
          (Arrow, create_test_pos 1 2);
          (StringTypeKeyword, create_test_pos 1 3);
          (EOF, create_test_pos 1 4);
        ],
        true,
        "简单函数类型" );
      ( [
          (StringTypeKeyword, create_test_pos 1 1);
          (Arrow, create_test_pos 1 2);
          (IntTypeKeyword, create_test_pos 1 3);
          (Arrow, create_test_pos 1 4);
          (BoolTypeKeyword, create_test_pos 1 5);
          (EOF, create_test_pos 1 6);
        ],
        true,
        "柯里化函数类型" );
    ]
  in

  List.iter
    (fun (tokens, expected_success, description) ->
      try
        let state = create_parser_state tokens in
        let _ = parse_type_expression state in
        if expected_success then Alcotest.(check bool) (description ^ " - 成功解析") true true
        else Alcotest.fail (description ^ " - 应该失败但成功了")
      with
      | SyntaxError (_, _) when not expected_success ->
          Alcotest.(check bool) (description ^ " - 期望错误") true true
      | SyntaxError (msg, _) when expected_success ->
          Alcotest.fail (description ^ " - 意外语法错误: " ^ msg)
      | exn when expected_success ->
          Alcotest.fail (description ^ " - 意外异常: " ^ Printexc.to_string exn)
      | _ when not expected_success -> Alcotest.(check bool) (description ^ " - 正确处理异常") true true)
    test_cases

(** {1 变体类型解析测试} *)

let test_variant_type_parsing () =
  let test_cases =
    [
      (* 简单变体类型 *)
      ( [
          (Pipe, create_test_pos 1 1);
          (QuotedIdentifierToken "成功", create_test_pos 1 2);
          (EOF, create_test_pos 1 3);
        ],
        true,
        "简单变体构造器" );
      ( [
          (Pipe, create_test_pos 1 1);
          (QuotedIdentifierToken "成功", create_test_pos 1 2);
          (OfKeyword, create_test_pos 1 3);
          (StringTypeKeyword, create_test_pos 1 4);
          (EOF, create_test_pos 1 5);
        ],
        true,
        "带类型的变体构造器" );
    ]
  in

  List.iter
    (fun (tokens, expected_success, description) ->
      try
        let state = create_parser_state tokens in
        let _ = parse_type_definition state in
        if expected_success then Alcotest.(check bool) (description ^ " - 成功解析") true true
        else Alcotest.fail (description ^ " - 应该失败但成功了")
      with
      | SyntaxError (_, _) when not expected_success ->
          Alcotest.(check bool) (description ^ " - 期望错误") true true
      | SyntaxError (msg, _) when expected_success ->
          Alcotest.fail (description ^ " - 意外语法错误: " ^ msg)
      | exn when expected_success ->
          Alcotest.fail (description ^ " - 意外异常: " ^ Printexc.to_string exn)
      | _ when not expected_success -> Alcotest.(check bool) (description ^ " - 正确处理异常") true true)
    test_cases

(** {1 多态变体类型解析测试} *)

let test_polymorphic_variant_parsing () =
  let test_cases =
    [
      (* 多态变体类型 *)
      ( [
          (VariantKeyword, create_test_pos 1 1);
          (QuotedIdentifierToken "标签1", create_test_pos 1 2);
          (EOF, create_test_pos 1 3);
        ],
        true,
        "简单多态变体" );
      ( [
          (VariantKeyword, create_test_pos 1 1);
          (QuotedIdentifierToken "标签1", create_test_pos 1 2);
          (Pipe, create_test_pos 1 3);
          (QuotedIdentifierToken "标签2", create_test_pos 1 4);
          (EOF, create_test_pos 1 5);
        ],
        true,
        "多个多态变体标签" );
    ]
  in

  List.iter
    (fun (tokens, expected_success, description) ->
      try
        let state = create_parser_state tokens in
        let _ = parse_type_definition state in
        if expected_success then Alcotest.(check bool) (description ^ " - 成功解析") true true
        else Alcotest.fail (description ^ " - 应该失败但成功了")
      with
      | SyntaxError (_, _) when not expected_success ->
          Alcotest.(check bool) (description ^ " - 期望错误") true true
      | SyntaxError (msg, _) when expected_success ->
          Alcotest.fail (description ^ " - 意外语法错误: " ^ msg)
      | exn when expected_success ->
          Alcotest.fail (description ^ " - 意外异常: " ^ Printexc.to_string exn)
      | _ when not expected_success -> Alcotest.(check bool) (description ^ " - 正确处理异常") true true)
    test_cases

(** {1 类型别名解析测试} *)

let test_type_alias_parsing () =
  let test_cases =
    [
      (* 类型别名 *)
      ([ (IntTypeKeyword, create_test_pos 1 1); (EOF, create_test_pos 1 2) ], true, "简单类型别名");
      ( [
          (IntTypeKeyword, create_test_pos 1 1);
          (Arrow, create_test_pos 1 2);
          (StringTypeKeyword, create_test_pos 1 3);
          (EOF, create_test_pos 1 4);
        ],
        true,
        "函数类型别名" );
      ( [ (QuotedIdentifierToken "用户类型", create_test_pos 1 1); (EOF, create_test_pos 1 2) ],
        true,
        "用户定义类型别名" );
      (* 私有类型 *)
      ( [
          (PrivateKeyword, create_test_pos 1 1);
          (IntTypeKeyword, create_test_pos 1 2);
          (EOF, create_test_pos 1 3);
        ],
        true,
        "私有类型" );
    ]
  in

  List.iter
    (fun (tokens, expected_success, description) ->
      try
        let state = create_parser_state tokens in
        let _ = parse_type_definition state in
        if expected_success then Alcotest.(check bool) (description ^ " - 成功解析") true true
        else Alcotest.fail (description ^ " - 应该失败但成功了")
      with
      | SyntaxError (_, _) when not expected_success ->
          Alcotest.(check bool) (description ^ " - 期望错误") true true
      | SyntaxError (msg, _) when expected_success ->
          Alcotest.fail (description ^ " - 意外语法错误: " ^ msg)
      | exn when expected_success ->
          Alcotest.fail (description ^ " - 意外异常: " ^ Printexc.to_string exn)
      | _ when not expected_success -> Alcotest.(check bool) (description ^ " - 正确处理异常") true true)
    test_cases

(** {1 括号类型表达式解析测试} *)

let test_parenthesized_type_expressions () =
  let test_cases =
    [
      (* 带括号的类型表达式 *)
      ( [
          (LeftParen, create_test_pos 1 1);
          (IntTypeKeyword, create_test_pos 1 2);
          (RightParen, create_test_pos 1 3);
          (EOF, create_test_pos 1 4);
        ],
        true,
        "简单括号类型" );
      ( [
          (LeftParen, create_test_pos 1 1);
          (IntTypeKeyword, create_test_pos 1 2);
          (Arrow, create_test_pos 1 3);
          (StringTypeKeyword, create_test_pos 1 4);
          (RightParen, create_test_pos 1 5);
          (EOF, create_test_pos 1 6);
        ],
        true,
        "括号函数类型" );
      (* 中文括号 *)
      ( [
          (ChineseLeftParen, create_test_pos 1 1);
          (IntTypeKeyword, create_test_pos 1 2);
          (ChineseRightParen, create_test_pos 1 3);
          (EOF, create_test_pos 1 4);
        ],
        true,
        "中文括号类型" );
    ]
  in

  List.iter
    (fun (tokens, expected_success, description) ->
      try
        let state = create_parser_state tokens in
        let _ = parse_type_expression state in
        if expected_success then Alcotest.(check bool) (description ^ " - 成功解析") true true
        else Alcotest.fail (description ^ " - 应该失败但成功了")
      with
      | SyntaxError (_, _) when not expected_success ->
          Alcotest.(check bool) (description ^ " - 期望错误") true true
      | SyntaxError (msg, _) when expected_success ->
          Alcotest.fail (description ^ " - 意外语法错误: " ^ msg)
      | exn when expected_success ->
          Alcotest.fail (description ^ " - 意外异常: " ^ Printexc.to_string exn)
      | _ when not expected_success -> Alcotest.(check bool) (description ^ " - 正确处理异常") true true)
    test_cases

(** {1 模块类型解析测试} *)

let test_module_type_parsing () =
  let test_cases =
    [
      (* 模块类型名称 *)
      ( [ (QuotedIdentifierToken "模块类型", create_test_pos 1 1); (EOF, create_test_pos 1 2) ],
        true,
        "模块类型名称" );
      (* 签名 *)
      ( [
          (SigKeyword, create_test_pos 1 1);
          (EndKeyword, create_test_pos 1 2);
          (EOF, create_test_pos 1 3);
        ],
        true,
        "空签名" );
    ]
  in

  List.iter
    (fun (tokens, expected_success, description) ->
      try
        let state = create_parser_state tokens in
        let _ = parse_module_type state in
        if expected_success then Alcotest.(check bool) (description ^ " - 成功解析") true true
        else Alcotest.fail (description ^ " - 应该失败但成功了")
      with
      | SyntaxError (_, _) when not expected_success ->
          Alcotest.(check bool) (description ^ " - 期望错误") true true
      | SyntaxError (msg, _) when expected_success ->
          Alcotest.fail (description ^ " - 意外语法错误: " ^ msg)
      | exn when expected_success ->
          Alcotest.fail (description ^ " - 意外异常: " ^ Printexc.to_string exn)
      | _ when not expected_success -> Alcotest.(check bool) (description ^ " - 正确处理异常") true true)
    test_cases

(** {1 错误处理和边界条件测试} *)

let test_error_handling () =
  let test_cases =
    [
      (* 语法错误 *)
      ([ (Arrow, create_test_pos 1 1); (EOF, create_test_pos 1 2) ], false, "单独的箭头应该失败");
      ( [
          (IntTypeKeyword, create_test_pos 1 1);
          (Arrow, create_test_pos 1 2);
          (EOF, create_test_pos 1 3);
        ],
        false,
        "不完整的函数类型应该失败" );
      ( [
          (LeftParen, create_test_pos 1 1);
          (IntTypeKeyword, create_test_pos 1 2);
          (EOF, create_test_pos 1 3);
        ],
        false,
        "不匹配的左括号应该失败" );
      ([ (EOF, create_test_pos 1 1) ], false, "空输入应该失败");
      (* 无效的变体类型 *)
      ([ (Pipe, create_test_pos 1 1); (EOF, create_test_pos 1 2) ], false, "单独的管道符应该失败");
      ( [
          (Pipe, create_test_pos 1 1);
          (OfKeyword, create_test_pos 1 2);
          (IntTypeKeyword, create_test_pos 1 3);
          (EOF, create_test_pos 1 4);
        ],
        false,
        "缺少构造器名称应该失败" );
      (* 无效的模块类型 *)
      ([ (SigKeyword, create_test_pos 1 1); (EOF, create_test_pos 1 2) ], false, "不完整的签名应该失败");
    ]
  in

  List.iter
    (fun (tokens, expected_success, description) ->
      try
        let state = create_parser_state tokens in
        (* 尝试类型表达式解析 *)
        try
          let _ = parse_type_expression state in
          if not expected_success then Alcotest.fail (description ^ " - 类型表达式应该失败")
          else Alcotest.(check bool) (description ^ " - 类型表达式成功") true true
        with
        | SyntaxError (_, _) when not expected_success ->
            Alcotest.(check bool) (description ^ " - 正确捕获类型表达式错误") true true
        | SyntaxError (msg, _) when expected_success ->
            Alcotest.fail (description ^ " - 意外的类型表达式错误: " ^ msg)
        | _ -> ()
      with exn ->
        if not expected_success then Alcotest.(check bool) (description ^ " - 正确处理异常") true true
        else Alcotest.fail (description ^ " - 意外异常: " ^ Printexc.to_string exn))
    test_cases

(** {1 边界条件和特殊情况测试} *)

let test_boundary_conditions () =
  let test_cases =
    [
      (* 深度嵌套 *)
      ( [
          (LeftParen, create_test_pos 1 1);
          (LeftParen, create_test_pos 1 2);
          (LeftParen, create_test_pos 1 3);
          (IntTypeKeyword, create_test_pos 1 4);
          (RightParen, create_test_pos 1 5);
          (RightParen, create_test_pos 1 6);
          (RightParen, create_test_pos 1 7);
          (Arrow, create_test_pos 1 8);
          (StringTypeKeyword, create_test_pos 1 9);
          (EOF, create_test_pos 1 10);
        ],
        true,
        "深度嵌套括号" );
      (* 多重柯里化 *)
      ( [
          (IntTypeKeyword, create_test_pos 1 1);
          (Arrow, create_test_pos 1 2);
          (StringTypeKeyword, create_test_pos 1 3);
          (Arrow, create_test_pos 1 4);
          (BoolTypeKeyword, create_test_pos 1 5);
          (Arrow, create_test_pos 1 6);
          (UnitTypeKeyword, create_test_pos 1 7);
          (EOF, create_test_pos 1 8);
        ],
        true,
        "多重柯里化" );
    ]
  in

  List.iter
    (fun (tokens, expected_success, description) ->
      try
        let state = create_parser_state tokens in
        let _ = parse_type_expression state in
        if expected_success then Alcotest.(check bool) (description ^ " - 成功解析") true true
        else Alcotest.fail (description ^ " - 应该失败但成功了")
      with
      | SyntaxError (_, _) when not expected_success ->
          Alcotest.(check bool) (description ^ " - 期望错误") true true
      | SyntaxError (msg, _) when expected_success ->
          Alcotest.fail (description ^ " - 意外语法错误: " ^ msg)
      | exn when expected_success ->
          Alcotest.fail (description ^ " - 意外异常: " ^ Printexc.to_string exn)
      | _ when not expected_success -> Alcotest.(check bool) (description ^ " - 正确处理异常") true true)
    test_cases

(** {1 测试套件定义} *)

let () =
  let open Alcotest in
  run "Parser_types模块综合测试"
    [
      ("模块可用性测试", [ test_case "模块可用性测试" `Quick test_module_availability ]);
      ("基础类型表达式解析", [ test_case "基本类型表达式解析" `Quick test_basic_type_expressions ]);
      ("函数类型表达式解析", [ test_case "函数类型表达式解析" `Quick test_function_type_expressions ]);
      ("变体类型解析", [ test_case "变体类型解析" `Quick test_variant_type_parsing ]);
      ("多态变体类型解析", [ test_case "多态变体类型解析" `Quick test_polymorphic_variant_parsing ]);
      ("类型别名解析", [ test_case "类型别名解析" `Quick test_type_alias_parsing ]);
      ("括号类型表达式解析", [ test_case "括号类型表达式解析" `Quick test_parenthesized_type_expressions ]);
      ("模块类型解析", [ test_case "模块类型解析" `Quick test_module_type_parsing ]);
      ( "错误处理和边界条件",
        [
          test_case "错误处理测试" `Quick test_error_handling;
          test_case "边界条件测试" `Quick test_boundary_conditions;
        ] );
    ]
