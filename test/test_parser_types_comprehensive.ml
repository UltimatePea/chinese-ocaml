(** 解析器类型模块全面测试套件
    测试覆盖parser_types.ml模块的所有核心功能 *)

open Alcotest
open Yyocamlc_lib.Lexer_tokens
open Yyocamlc_lib.Parser_utils
open Yyocamlc_lib.Parser_types
open Yyocamlc_lib.Ast

(** 测试辅助函数模块 *)
module TestHelpers = struct
  (** 创建基础解析器状态 *)
  let create_parser_state tokens =
    let token_array = Array.of_list tokens in
    { token_array; current_index = 0; token_count = Array.length token_array }

  (** 创建基本类型表达式token序列 *)
  let create_basic_type_tokens () = [
    IntTypeKeyword; EOF
  ]

  (** 创建函数类型token序列 *)
  let create_function_type_tokens () = [
    IntTypeKeyword; Arrow; StringTypeKeyword; EOF
  ]

  (** 创建复杂函数类型token序列 *)
  let create_complex_function_type_tokens () = [
    IntTypeKeyword; Arrow; StringTypeKeyword; Arrow; BoolTypeKeyword; EOF
  ]

  (** 创建变体类型token序列 *)
  let create_variant_type_tokens () = [
    VariantKeyword; QuotedIdentifierToken "Some"; Colon; IntTypeKeyword; 
    Pipe; QuotedIdentifierToken "None"; EOF
  ]

  (** 创建变体标签token序列 *)
  let create_variant_labels_tokens () = [
    QuotedIdentifierToken "Red"; Pipe; QuotedIdentifierToken "Green"; 
    Pipe; QuotedIdentifierToken "Blue"; Colon; StringTypeKeyword; EOF
  ]

  (** 创建括号类型表达式token序列 *)
  let create_parenthesized_type_tokens () = [
    LeftParen; IntTypeKeyword; Arrow; StringTypeKeyword; RightParen; EOF
  ]

  (** 创建中文括号类型表达式token序列 *)
  let create_chinese_parenthesized_type_tokens () = [
    ChineseLeftParen; BoolTypeKeyword; ChineseRightParen; EOF
  ]

  (** 创建类型变量token序列 *)
  let create_type_var_tokens () = [
    QuotedIdentifierToken "T"; EOF
  ]

  (** 创建类型定义token序列 *)
  let create_type_definition_tokens () = [
    IntTypeKeyword; EOF
  ]

  (** 创建变体构造器token序列 *)
  let create_variant_constructors_tokens () = [
    Pipe; IdentifierTokenSpecial "Some"; OfKeyword; IntTypeKeyword;
    Pipe; IdentifierTokenSpecial "None"; EOF
  ]

  (** 创建私有类型token序列 *)
  let create_private_type_tokens () = [
    PrivateKeyword; StringTypeKeyword; EOF
  ]

  (** 创建别名类型token序列 *)
  let create_alias_type_tokens () = [
    IntTypeKeyword; EOF
  ]

  (** 创建模块类型签名token序列 *)
  let create_module_type_signature_tokens () = [
    SigKeyword; LetKeyword; IdentifierTokenSpecial "x"; Colon; IntTypeKeyword; EndKeyword; EOF
  ]

  (** 创建模块类型名称token序列 *)
  let create_module_type_name_tokens () = [
    QuotedIdentifierToken "MyModuleType"; EOF
  ]

  (** 创建值签名token序列 *)
  let create_value_signature_tokens () = [
    LetKeyword; IdentifierTokenSpecial "func"; Colon; IntTypeKeyword; Arrow; StringTypeKeyword; EOF
  ]

  (** 创建类型签名token序列 *)
  let create_type_signature_tokens () = [
    TypeKeyword; IdentifierTokenSpecial "t"; Assign; IntTypeKeyword; EOF
  ]

  (** 创建简单类型签名token序列 *)
  let create_simple_type_signature_tokens () = [
    TypeKeyword; IdentifierTokenSpecial "t"; EOF
  ]

  (** 创建模块签名token序列 *)
  let create_module_signature_tokens () = [
    ModuleKeyword; IdentifierTokenSpecial "M"; Colon; QuotedIdentifierToken "ModType"; EOF
  ]

  (** 创建异常签名token序列 *)
  let create_exception_signature_tokens () = [
    ExceptionKeyword; IdentifierTokenSpecial "MyError"; OfKeyword; StringTypeKeyword; EOF
  ]

  (** 创建简单异常签名token序列 *)
  let create_simple_exception_signature_tokens () = [
    ExceptionKeyword; IdentifierTokenSpecial "SimpleError"; EOF
  ]

  (** 检查解析是否成功（不抛出异常） *)
  let assert_parse_success parse_func tokens =
    try
      let state = create_parser_state tokens in
      let _ = parse_func state in
      true
    with _ -> false

  (** 检查解析是否失败（抛出异常） *)
  let assert_parse_failure parse_func tokens =
    try
      let state = create_parser_state tokens in
      let _ = parse_func state in
      false
    with _ -> true

  (** 验证类型表达式解析结果 *)
  let verify_type_expression_parse tokens =
    assert_parse_success parse_type_expression tokens

  (** 验证基本类型表达式解析结果 *)
  let verify_basic_type_expression_parse tokens =
    assert_parse_success parse_basic_type_expression tokens

  (** 验证类型定义解析结果 *)
  let verify_type_definition_parse tokens =
    assert_parse_success parse_type_definition tokens

  (** 验证模块类型解析结果 *)
  let verify_module_type_parse tokens =
    assert_parse_success parse_module_type tokens

end

(** 辅助模式解析测试 *)

let test_parse_advance_name_pattern () =
  (* 测试 advance -> name 模式 *)
  let tokens = [LetKeyword; IdentifierTokenSpecial "test"; EOF] in
  let state = TestHelpers.create_parser_state tokens in
  
  check bool "advance->name模式解析应该成功" true
    (try let _ = parse_advance_name_pattern state in true with _ -> false)

let test_parse_advance_name_colon_pattern () =
  (* 测试 advance -> name -> colon 模式 *)
  let tokens = [LetKeyword; IdentifierTokenSpecial "test"; Colon; IntTypeKeyword; EOF] in
  let state = TestHelpers.create_parser_state tokens in
  
  check bool "advance->name->colon模式解析应该成功" true
    (try let _ = parse_advance_name_colon_pattern state in true with _ -> false)

(** 变体类型解析测试 *)

let test_parse_variant_labels_basic () =
  (* 测试基础变体标签解析 *)
  let tokens = [QuotedIdentifierToken "Red"; Pipe; QuotedIdentifierToken "Green"; EOF] in
  let state = TestHelpers.create_parser_state tokens in
  
  check bool "基础变体标签解析应该成功" true
    (try let _ = parse_variant_labels state [] in true with _ -> false)

let test_parse_variant_labels_with_types () =
  (* 测试带类型的变体标签解析 *)
  let tokens = TestHelpers.create_variant_labels_tokens () in
  let state = TestHelpers.create_parser_state tokens in
  
  check bool "带类型的变体标签解析应该成功" true
    (try let _ = parse_variant_labels state [] in true with _ -> false)

let test_parse_variant_labels_edge_cases () =
  (* 测试变体标签解析的边界情况 *)
  
  (* 单个标签 *)
  let single_label_tokens = [QuotedIdentifierToken "Single"; EOF] in
  check bool "单个变体标签解析应该成功" true
    (TestHelpers.assert_parse_success 
      (fun state -> let _, state' = parse_variant_labels state [] in ((), state')) 
      single_label_tokens);

  (* 空标签列表（应该失败） *)
  let empty_tokens = [EOF] in
  check bool "空变体标签列表解析应该失败" true
    (TestHelpers.assert_parse_failure 
      (fun state -> let _, state' = parse_variant_labels state [] in ((), state'))
      empty_tokens)

(** 类型表达式解析测试 *)

let test_parse_type_expression_basic_types () =
  (* 测试基本类型解析 *)
  let basic_type_tokens = TestHelpers.create_basic_type_tokens () in
  check bool "基本类型表达式解析应该成功" true
    (TestHelpers.verify_type_expression_parse basic_type_tokens);

  (* 测试各种基本类型 *)
  let type_variants = [
    [IntTypeKeyword; EOF];
    [FloatTypeKeyword; EOF];
    [StringTypeKeyword; EOF];
    [BoolTypeKeyword; EOF];
    [UnitTypeKeyword; EOF];
    [ListTypeKeyword; EOF];
    [ArrayTypeKeyword; EOF];
  ] in
  
  List.iter (fun tokens ->
    check bool "各种基本类型解析应该成功" true
      (TestHelpers.verify_type_expression_parse tokens)
  ) type_variants

let test_parse_type_expression_function_types () =
  (* 测试函数类型解析 *)
  let function_type_tokens = TestHelpers.create_function_type_tokens () in
  check bool "函数类型表达式解析应该成功" true
    (TestHelpers.verify_type_expression_parse function_type_tokens);

  (* 测试复杂函数类型 *)
  let complex_function_tokens = TestHelpers.create_complex_function_type_tokens () in
  check bool "复杂函数类型表达式解析应该成功" true
    (TestHelpers.verify_type_expression_parse complex_function_tokens)

let test_parse_type_expression_variant_types () =
  (* 测试变体类型解析 *)
  let variant_type_tokens = TestHelpers.create_variant_type_tokens () in
  check bool "变体类型表达式解析应该成功" true
    (TestHelpers.verify_type_expression_parse variant_type_tokens)

let test_parse_type_expression_type_variables () =
  (* 测试类型变量解析 *)
  let type_var_tokens = TestHelpers.create_type_var_tokens () in
  check bool "类型变量表达式解析应该成功" true
    (TestHelpers.verify_type_expression_parse type_var_tokens)

let test_parse_type_expression_parenthesized () =
  (* 测试括号类型表达式 *)
  let paren_tokens = TestHelpers.create_parenthesized_type_tokens () in
  check bool "括号类型表达式解析应该成功" true
    (TestHelpers.verify_type_expression_parse paren_tokens);

  (* 测试中文括号类型表达式 *)
  let chinese_paren_tokens = TestHelpers.create_chinese_parenthesized_type_tokens () in
  check bool "中文括号类型表达式解析应该成功" true
    (TestHelpers.verify_type_expression_parse chinese_paren_tokens)

(** 基本类型表达式解析测试 *)

let test_parse_basic_type_expression () =
  (* 测试基本类型表达式解析 *)
  let basic_tokens = TestHelpers.create_basic_type_tokens () in
  check bool "基本类型表达式解析应该成功" true
    (TestHelpers.verify_basic_type_expression_parse basic_tokens);

  (* 测试括号内的基本类型 *)
  let paren_basic_tokens = [LeftParen; IntTypeKeyword; RightParen; EOF] in
  check bool "括号内基本类型表达式解析应该成功" true
    (TestHelpers.verify_basic_type_expression_parse paren_basic_tokens)

(** 类型定义解析测试 *)

let test_parse_type_definition_alias () =
  (* 测试别名类型定义 *)
  let alias_tokens = TestHelpers.create_alias_type_tokens () in
  check bool "别名类型定义解析应该成功" true
    (TestHelpers.verify_type_definition_parse alias_tokens)

let test_parse_type_definition_variant_constructors () =
  (* 测试变体构造器类型定义 *)
  let variant_tokens = TestHelpers.create_variant_constructors_tokens () in
  check bool "变体构造器类型定义解析应该成功" true
    (TestHelpers.verify_type_definition_parse variant_tokens)

let test_parse_type_definition_private () =
  (* 测试私有类型定义 *)
  let private_tokens = TestHelpers.create_private_type_tokens () in
  check bool "私有类型定义解析应该成功" true
    (TestHelpers.verify_type_definition_parse private_tokens)

let test_parse_type_definition_polymorphic_variant () =
  (* 测试多态变体类型定义 *)
  let polymorphic_variant_tokens = [
    VariantKeyword; QuotedIdentifierToken "A"; Pipe; QuotedIdentifierToken "B"; Colon; IntTypeKeyword; EOF
  ] in
  check bool "多态变体类型定义解析应该成功" true
    (TestHelpers.verify_type_definition_parse polymorphic_variant_tokens)

(** 变体构造器解析测试 *)

let test_parse_variant_constructors () =
  (* 测试变体构造器解析 *)
  let constructor_tokens = TestHelpers.create_variant_constructors_tokens () in
  check bool "变体构造器解析应该成功" true
    (TestHelpers.verify_type_definition_parse constructor_tokens);

  (* 测试简单构造器（无类型） *)
  let simple_constructor_tokens = [
    Pipe; IdentifierTokenSpecial "None"; Pipe; IdentifierTokenSpecial "Empty"; EOF
  ] in
  check bool "简单变体构造器解析应该成功" true
    (TestHelpers.verify_type_definition_parse simple_constructor_tokens);

  (* 测试中文管道符 *)
  let chinese_pipe_tokens = [
    ChinesePipe; IdentifierTokenSpecial "A"; ChinesePipe; IdentifierTokenSpecial "B"; EOF
  ] in
  check bool "中文管道符变体构造器解析应该成功" true
    (TestHelpers.verify_type_definition_parse chinese_pipe_tokens)

(** 模块类型解析测试 *)

let test_parse_module_type_signature () =
  (* 测试模块类型签名解析 *)
  let signature_tokens = TestHelpers.create_module_type_signature_tokens () in
  check bool "模块类型签名解析应该成功" true
    (TestHelpers.verify_module_type_parse signature_tokens)

let test_parse_module_type_name () =
  (* 测试模块类型名称解析 *)
  let name_tokens = TestHelpers.create_module_type_name_tokens () in
  check bool "模块类型名称解析应该成功" true
    (TestHelpers.verify_module_type_parse name_tokens)

(** 签名项解析测试 *)

let test_parse_signature_item_value () =
  (* 测试值签名项解析 *)
  let value_sig_tokens = TestHelpers.create_value_signature_tokens () in
  let state = TestHelpers.create_parser_state value_sig_tokens in
  
  check bool "值签名项解析应该成功" true
    (try let _ = parse_signature_item state in true with _ -> false)

let test_parse_signature_item_type () =
  (* 测试类型签名项解析 *)
  let type_sig_tokens = TestHelpers.create_type_signature_tokens () in
  let state = TestHelpers.create_parser_state type_sig_tokens in
  
  check bool "类型签名项解析应该成功" true
    (try let _ = parse_signature_item state in true with _ -> false);

  (* 测试简单类型签名（无定义） *)
  let simple_type_sig_tokens = TestHelpers.create_simple_type_signature_tokens () in
  let simple_state = TestHelpers.create_parser_state simple_type_sig_tokens in
  
  check bool "简单类型签名项解析应该成功" true
    (try let _ = parse_signature_item simple_state in true with _ -> false)

let test_parse_signature_item_module () =
  (* 测试模块签名项解析 *)
  let module_sig_tokens = TestHelpers.create_module_signature_tokens () in
  let state = TestHelpers.create_parser_state module_sig_tokens in
  
  check bool "模块签名项解析应该成功" true
    (try let _ = parse_signature_item state in true with _ -> false)

let test_parse_signature_item_exception () =
  (* 测试异常签名项解析 *)
  let exception_sig_tokens = TestHelpers.create_exception_signature_tokens () in
  let state = TestHelpers.create_parser_state exception_sig_tokens in
  
  check bool "异常签名项解析应该成功" true
    (try let _ = parse_signature_item state in true with _ -> false);

  (* 测试简单异常签名（无类型） *)
  let simple_exception_tokens = TestHelpers.create_simple_exception_signature_tokens () in
  let simple_state = TestHelpers.create_parser_state simple_exception_tokens in
  
  check bool "简单异常签名项解析应该成功" true
    (try let _ = parse_signature_item simple_state in true with _ -> false)

(** 签名项列表解析测试 *)

let test_parse_signature_items () =
  (* 测试签名项列表解析 *)
  let signature_items_tokens = [
    LetKeyword; IdentifierTokenSpecial "x"; Colon; IntTypeKeyword;
    TypeKeyword; IdentifierTokenSpecial "t"; Assign; StringTypeKeyword;
    EndKeyword; EOF
  ] in
  let state = TestHelpers.create_parser_state signature_items_tokens in
  
  check bool "签名项列表解析应该成功" true
    (try let _ = parse_signature_items [] state in true with _ -> false);

  (* 测试空签名项列表 *)
  let empty_signature_tokens = [EndKeyword; EOF] in
  let empty_state = TestHelpers.create_parser_state empty_signature_tokens in
  
  check bool "空签名项列表解析应该成功" true
    (try let _ = parse_signature_items [] empty_state in true with _ -> false)

(** 错误处理测试 *)

let test_error_handling_invalid_type_expressions () =
  (* 测试无效类型表达式 *)
  let invalid_tokens = [Plus; EOF] in  (* 运算符不是有效的类型表达式 *)
  check bool "无效类型表达式应该失败" true
    (TestHelpers.assert_parse_failure parse_type_expression invalid_tokens);

  (* 测试不匹配的括号 *)
  let unmatched_paren_tokens = [LeftParen; IntTypeKeyword; EOF] in
  check bool "不匹配括号类型表达式应该失败" true
    (TestHelpers.assert_parse_failure parse_type_expression unmatched_paren_tokens)

let test_error_handling_invalid_variant_labels () =
  (* 测试无效变体标签 *)
  let invalid_variant_tokens = [IntTypeKeyword; EOF] in  (* 不是引用标识符 *)
  check bool "无效变体标签应该失败" true
    (TestHelpers.assert_parse_failure 
      (fun state -> let _, state' = parse_variant_labels state [] in ((), state'))
      invalid_variant_tokens)

let test_error_handling_invalid_signature_items () =
  (* 测试无效签名项 *)
  let invalid_signature_tokens = [Plus; EOF] in  (* 不是有效的签名项开始 *)
  check bool "无效签名项应该失败" true
    (TestHelpers.assert_parse_failure parse_signature_item invalid_signature_tokens)

(** 复杂场景测试 *)

let test_complex_type_expressions () =
  (* 测试复杂的嵌套类型表达式 *)
  let complex_tokens = [
    LeftParen; IntTypeKeyword; Arrow; StringTypeKeyword; RightParen; 
    Arrow; BoolTypeKeyword; EOF
  ] in
  check bool "复杂嵌套类型表达式解析应该成功" true
    (TestHelpers.verify_type_expression_parse complex_tokens);

  (* 测试多层嵌套 *)
  let nested_tokens = [
    LeftParen; LeftParen; IntTypeKeyword; RightParen; Arrow; 
    LeftParen; StringTypeKeyword; Arrow; BoolTypeKeyword; RightParen; RightParen; EOF
  ] in
  check bool "多层嵌套类型表达式解析应该成功" true
    (TestHelpers.verify_type_expression_parse nested_tokens)

let test_complex_variant_definitions () =
  (* 测试复杂的变体定义 *)
  let complex_variant_tokens = [
    Pipe; IdentifierTokenSpecial "None";
    Pipe; IdentifierTokenSpecial "Some"; OfKeyword; IntTypeKeyword;
    Pipe; IdentifierTokenSpecial "Error"; OfKeyword; StringTypeKeyword; Arrow; BoolTypeKeyword;
    EOF
  ] in
  check bool "复杂变体定义解析应该成功" true
    (TestHelpers.verify_type_definition_parse complex_variant_tokens)

let test_complex_module_signatures () =
  (* 测试复杂的模块签名 *)
  let complex_sig_tokens = [
    SigKeyword;
    LetKeyword; IdentifierTokenSpecial "func1"; Colon; IntTypeKeyword; Arrow; StringTypeKeyword;
    TypeKeyword; IdentifierTokenSpecial "t"; Assign; IntTypeKeyword;
    ModuleKeyword; IdentifierTokenSpecial "Inner"; Colon; QuotedIdentifierToken "InnerType";
    ExceptionKeyword; IdentifierTokenSpecial "MyError"; OfKeyword; StringTypeKeyword;
    EndKeyword; EOF
  ] in
  check bool "复杂模块签名解析应该成功" true
    (TestHelpers.verify_module_type_parse complex_sig_tokens)

(** 性能测试 *)

let test_type_parsing_performance () =
  (* 测试大型类型表达式解析性能 *)
  let rec create_large_function_type depth =
    if depth <= 0 then [IntTypeKeyword]
    else 
      (create_large_function_type (depth - 1)) @ [Arrow] @ (create_large_function_type (depth - 1))
  in
  
  let large_type = create_large_function_type 5 @ [EOF] in
  
  let start_time = Sys.time () in
  let success = TestHelpers.verify_type_expression_parse large_type in
  let end_time = Sys.time () in
  
  check bool "大型类型表达式解析应该成功" true success;
  check bool "大型类型表达式解析应该在合理时间内完成" true
    ((end_time -. start_time) < 1.0)

let test_variant_parsing_performance () =
  (* 测试大量变体构造器解析性能 *)
  let rec create_many_constructors n acc =
    if n <= 0 then acc
    else 
      let constructor = [
        Pipe; IdentifierTokenSpecial ("Constructor" ^ string_of_int n); 
        OfKeyword; IntTypeKeyword
      ] in
      create_many_constructors (n - 1) (constructor @ acc)
  in
  
  let many_constructors = create_many_constructors 20 [] @ [EOF] in
  
  let start_time = Sys.time () in
  let success = TestHelpers.verify_type_definition_parse many_constructors in
  let end_time = Sys.time () in
  
  check bool "大量变体构造器解析应该成功" true success;
  check bool "大量变体构造器解析应该在合理时间内完成" true
    ((end_time -. start_time) < 0.5)

(** 集成测试 *)

let test_type_parsing_integration () =
  (* 测试完整的类型解析工作流程 *)
  
  (* 1. 解析基本类型 *)
  let basic_result = TestHelpers.verify_type_expression_parse [IntTypeKeyword; EOF] in
  check bool "集成测试：基本类型解析应该成功" true basic_result;
  
  (* 2. 解析函数类型 *)
  let function_result = TestHelpers.verify_type_expression_parse 
    [IntTypeKeyword; Arrow; StringTypeKeyword; EOF] in
  check bool "集成测试：函数类型解析应该成功" true function_result;
  
  (* 3. 解析变体类型 *)
  let variant_result = TestHelpers.verify_type_expression_parse
    [VariantKeyword; QuotedIdentifierToken "A"; Pipe; QuotedIdentifierToken "B"; EOF] in
  check bool "集成测试：变体类型解析应该成功" true variant_result;
  
  (* 4. 解析类型定义 *)
  let type_def_result = TestHelpers.verify_type_definition_parse
    [Pipe; IdentifierTokenSpecial "Some"; OfKeyword; IntTypeKeyword; EOF] in
  check bool "集成测试：类型定义解析应该成功" true type_def_result;
  
  (* 5. 解析模块类型 *)
  let module_type_result = TestHelpers.verify_module_type_parse
    [SigKeyword; LetKeyword; IdentifierTokenSpecial "x"; Colon; IntTypeKeyword; EndKeyword; EOF] in
  check bool "集成测试：模块类型解析应该成功" true module_type_result

(** 测试套件定义 *)

let helper_pattern_tests = [
  test_case "advance->name模式解析测试" `Quick test_parse_advance_name_pattern;
  test_case "advance->name->colon模式解析测试" `Quick test_parse_advance_name_colon_pattern;
]

let variant_label_tests = [
  test_case "基础变体标签解析测试" `Quick test_parse_variant_labels_basic;
  test_case "带类型变体标签解析测试" `Quick test_parse_variant_labels_with_types;
  test_case "变体标签边界条件测试" `Quick test_parse_variant_labels_edge_cases;
]

let type_expression_tests = [
  test_case "基本类型表达式解析测试" `Quick test_parse_type_expression_basic_types;
  test_case "函数类型表达式解析测试" `Quick test_parse_type_expression_function_types;
  test_case "变体类型表达式解析测试" `Quick test_parse_type_expression_variant_types;
  test_case "类型变量表达式解析测试" `Quick test_parse_type_expression_type_variables;
  test_case "括号类型表达式解析测试" `Quick test_parse_type_expression_parenthesized;
]

let basic_type_expression_tests = [
  test_case "基本类型表达式解析测试" `Quick test_parse_basic_type_expression;
]

let type_definition_tests = [
  test_case "别名类型定义解析测试" `Quick test_parse_type_definition_alias;
  test_case "变体构造器类型定义解析测试" `Quick test_parse_type_definition_variant_constructors;
  test_case "私有类型定义解析测试" `Quick test_parse_type_definition_private;
  test_case "多态变体类型定义解析测试" `Quick test_parse_type_definition_polymorphic_variant;
]

let variant_constructor_tests = [
  test_case "变体构造器解析测试" `Quick test_parse_variant_constructors;
]

let module_type_tests = [
  test_case "模块类型签名解析测试" `Quick test_parse_module_type_signature;
  test_case "模块类型名称解析测试" `Quick test_parse_module_type_name;
]

let signature_item_tests = [
  test_case "值签名项解析测试" `Quick test_parse_signature_item_value;
  test_case "类型签名项解析测试" `Quick test_parse_signature_item_type;
  test_case "模块签名项解析测试" `Quick test_parse_signature_item_module;
  test_case "异常签名项解析测试" `Quick test_parse_signature_item_exception;
]

let signature_items_tests = [
  test_case "签名项列表解析测试" `Quick test_parse_signature_items;
]

let error_handling_tests = [
  test_case "无效类型表达式错误处理测试" `Quick test_error_handling_invalid_type_expressions;
  test_case "无效变体标签错误处理测试" `Quick test_error_handling_invalid_variant_labels;
  test_case "无效签名项错误处理测试" `Quick test_error_handling_invalid_signature_items;
]

let complex_scenario_tests = [
  test_case "复杂类型表达式测试" `Quick test_complex_type_expressions;
  test_case "复杂变体定义测试" `Quick test_complex_variant_definitions;
  test_case "复杂模块签名测试" `Quick test_complex_module_signatures;
]

let performance_tests = [
  test_case "类型解析性能测试" `Slow test_type_parsing_performance;
  test_case "变体解析性能测试" `Slow test_variant_parsing_performance;
]

let integration_tests = [
  test_case "类型解析集成测试" `Quick test_type_parsing_integration;
]

(** 主测试运行器 *)
let () =
  run "Parser_types解析器类型模块综合测试套件" [
    "辅助模式解析测试", helper_pattern_tests;
    "变体标签解析测试", variant_label_tests;
    "类型表达式解析测试", type_expression_tests;
    "基本类型表达式解析测试", basic_type_expression_tests;
    "类型定义解析测试", type_definition_tests;
    "变体构造器解析测试", variant_constructor_tests;
    "模块类型解析测试", module_type_tests;
    "签名项解析测试", signature_item_tests;
    "签名项列表解析测试", signature_items_tests;
    "错误处理测试", error_handling_tests;
    "复杂场景测试", complex_scenario_tests;
    "性能测试", performance_tests;
    "集成测试", integration_tests;
  ]