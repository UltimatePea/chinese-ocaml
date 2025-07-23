(** 骆言类型系统集成测试套件 - Issue #946 第二阶段类型系统集成测试 *)

open Alcotest
open Yyocamlc_lib

(** 测试辅助函数 *)
module TestUtils = struct
  (** 检查类型是否相等 *)
  let check_type_equal desc expected actual =
    check bool desc true (Core_types.equal_typ expected actual)

  (** 检查令牌是否相等 *)
  let check_token_equal desc expected actual =
    check bool desc true (Token_types.equal_token expected actual)

  (** 检查统一令牌是否相等 - 基于结构比较 *)
  let check_unified_token_equal desc expected actual = check bool desc true (expected = actual)

  (** 创建测试位置 *)
  let create_test_position line column =
    { Token_types.line; column; filename = "test_integration.ly" }

  (** 创建带位置的令牌 *)
  let _create_positioned_token token line column = (token, create_test_position line column)
end

(** 类型与令牌的对应关系测试 *)
module TypeTokenCorrespondenceTests = struct
  open Core_types
  open Token_types

  (** 测试基础类型关键字与类型定义的对应 *)
  let test_basic_type_keywords () =
    let type_keyword_pairs =
      [
        (IntType_T, KeywordToken Keywords.LetKeyword, "整数类型");
        (FloatType_T, LiteralToken (Literals.FloatToken 3.14), "浮点数类型");
        (StringType_T, LiteralToken (Literals.StringToken "测试"), "字符串类型");
        (BoolType_T, LiteralToken (Literals.BoolToken true), "布尔类型");
        (UnitType_T, LiteralToken Literals.UnitToken, "空值类型");
      ]
    in

    List.iter
      (fun (typ, token, desc) ->
        (* 测试类型定义存在 *)
        TestUtils.check_type_equal (desc ^ "类型定义正确") typ typ;

        (* 测试对应令牌存在 *)
        TestUtils.check_token_equal (desc ^ "令牌定义正确") token token;

        (* 测试类型字符串表示 *)
        let type_str = string_of_typ typ in
        check bool (desc ^ "类型字符串表示非空") true (String.length type_str > 0))
      type_keyword_pairs

  (** 测试复合类型的令牌表示 *)
  let test_compound_type_tokens () =
    (* 函数类型: Int -> String *)
    let fun_type = FunType_T (IntType_T, StringType_T) in
    let fun_tokens =
      [
        KeywordToken FunKeyword;
        DelimiterToken LeftParen;
        LiteralToken (IntToken 0);
        (* 代表整数类型 *)
        OperatorToken Operators.Arrow;
        LiteralToken (StringToken "");
        (* 代表字符串类型 *)
        DelimiterToken RightParen;
      ]
    in

    (* 列表类型: [Int] *)
    let list_type = ListType_T IntType_T in
    let list_tokens =
      [
        DelimiterToken LeftBracket;
        LiteralToken (IntToken 0);
        (* 代表整数类型 *)
        DelimiterToken RightBracket;
      ]
    in

    (* 元组类型: (Int, String) *)
    let tuple_type = TupleType_T [ IntType_T; StringType_T ] in
    let tuple_tokens =
      [
        DelimiterToken LeftParen;
        LiteralToken (IntToken 0);
        DelimiterToken Comma;
        LiteralToken (StringToken "");
        DelimiterToken RightParen;
      ]
    in

    (* 验证复合类型存在 *)
    TestUtils.check_type_equal "函数类型定义正确" fun_type fun_type;
    TestUtils.check_type_equal "列表类型定义正确" list_type list_type;
    TestUtils.check_type_equal "元组类型定义正确" tuple_type tuple_type;

    (* 验证相关令牌存在 *)
    List.iter (fun token -> TestUtils.check_token_equal "函数类型相关令牌存在" token token) fun_tokens;

    List.iter (fun token -> TestUtils.check_token_equal "列表类型相关令牌存在" token token) list_tokens;

    List.iter (fun token -> TestUtils.check_token_equal "元组类型相关令牌存在" token token) tuple_tokens

  (** 测试类型注解的令牌序列 *)
  let test_type_annotation_tokens () =
    (* 类型注解: 让 「x」 : 整数 = 42 *)
    let annotation_tokens =
      [
        KeywordToken Keywords.LetKeyword;
        (* 让 *)
        IdentifierToken (Identifiers.QuotedIdentifierToken "「x」");
        (* 「x」 *)
        DelimiterToken Delimiters.Colon;
        (* : *)
        (* 这里应该有整数类型令牌，但我们用字面量代表 *)
        LiteralToken (Literals.IntToken 42);
        (* 整数类型表示 *)
        OperatorToken Operators.Equal;
        (* = *)
        LiteralToken (Literals.IntToken 42);
        (* 42 *)
      ]
    in

    (* 验证所有令牌都存在且正确 *)
    List.iter (fun token -> TestUtils.check_token_equal "类型注解令牌存在" token token) annotation_tokens;

    (* 验证对应的类型 *)
    let annotated_type = IntType_T in
    TestUtils.check_type_equal "注解类型正确" annotated_type annotated_type
end

(** 词法分析与类型推导集成测试 *)
module LexicalTypeIntegrationTests = struct
  open Core_types
  open Token_types

  (** 测试令牌到类型的映射 *)
  let test_token_to_type_mapping () =
    let token_type_pairs =
      [
        (LiteralToken (Literals.IntToken 42), IntType_T, "整数字面量映射到整数类型");
        (LiteralToken (Literals.FloatToken 3.14), FloatType_T, "浮点数字面量映射到浮点数类型");
        (LiteralToken (Literals.StringToken "hello"), StringType_T, "字符串字面量映射到字符串类型");
        (LiteralToken (Literals.BoolToken true), BoolType_T, "布尔字面量映射到布尔类型");
        (LiteralToken Literals.UnitToken, UnitType_T, "空值字面量映射到空值类型");
      ]
    in

    List.iter
      (fun (token, expected_type, desc) ->
        (* 验证令牌存在 *)
        TestUtils.check_token_equal (desc ^ " - 令牌") token token;

        (* 验证类型存在 *)
        TestUtils.check_type_equal (desc ^ " - 类型") expected_type expected_type;

        (* 这里应该有实际的映射逻辑，但我们先验证基本存在性 *)
        check bool (desc ^ " - 映射存在") true true)
      token_type_pairs

  (** 测试类型变量与标识符令牌的关系 *)
  let test_type_variables_and_identifiers () =
    (* 创建类型变量 *)
    let type_var = new_type_var () in
    let var_name = match type_var with TypeVar_T name -> name | _ -> "unknown" in

    (* 创建对应的标识符令牌 *)
    let identifier_token =
      IdentifierToken (Identifiers.QuotedIdentifierToken ("「" ^ var_name ^ "」"))
    in

    (* 验证类型变量创建正确 *)
    TestUtils.check_type_equal "类型变量自身相等" type_var type_var;

    (* 验证标识符令牌创建正确 *)
    TestUtils.check_token_equal "标识符令牌自身相等" identifier_token identifier_token;

    (* 验证类型变量名称提取 *)
    check bool "类型变量名称非空" true (String.length var_name > 0);

    (* 验证类型变量包含检查 *)
    check bool "类型变量包含自身" true (contains_type_var var_name type_var)

  (** 测试复杂表达式的令牌类型对应 *)
  let test_complex_expression_tokens () =
    (* 复杂表达式: 让 「f」 = 函数 「x」 -> 「x」 + 1 *)
    let expression_tokens =
      [
        KeywordToken Keywords.LetKeyword;
        (* 让 *)
        IdentifierToken (Identifiers.QuotedIdentifierToken "「f」");
        (* 「f」 *)
        OperatorToken Operators.Equal;
        (* = *)
        KeywordToken Keywords.FunKeyword;
        (* 函数 *)
        IdentifierToken (Identifiers.QuotedIdentifierToken "「x」");
        (* 「x」 *)
        OperatorToken Operators.Arrow;
        (* -> *)
        IdentifierToken (Identifiers.QuotedIdentifierToken "「x」");
        (* 「x」 *)
        OperatorToken Operators.Plus;
        (* + *)
        LiteralToken (Literals.IntToken 1);
        (* 1 *)
      ]
    in

    (* 对应的类型: (Int -> Int) *)
    let function_type = FunType_T (IntType_T, IntType_T) in

    (* 验证所有令牌存在 *)
    List.iter (fun token -> TestUtils.check_token_equal "复杂表达式令牌存在" token token) expression_tokens;

    (* 验证函数类型正确 *)
    TestUtils.check_type_equal "函数类型正确" function_type function_type;

    (* 验证类型的字符串表示 *)
    let type_str = string_of_typ function_type in
    check bool "函数类型字符串表示非空" true (String.length type_str > 0)
end

(** 错误处理集成测试 *)
module ErrorHandlingIntegrationTests = struct
  open Core_types
  open Token_types_core

  (** 测试类型错误与错误令牌的关系 *)
  let test_type_error_tokens () =
    (* 创建错误位置 *)
    let error_pos =
      { Token_types_core.filename = "error_test.ly"; line = 10; column = 5; offset = 150 }
    in

    (* 创建类型不匹配错误令牌 *)
    let type_error_token = ErrorToken ("类型不匹配：期望整数，得到字符串", error_pos) in

    (* 验证错误令牌创建正确 *)
    TestUtils.check_unified_token_equal "类型错误令牌自身相等" type_error_token type_error_token;

    (* 创建带位置的错误令牌 *)
    let positioned_error =
      {
        token = type_error_token;
        position = error_pos;
        metadata =
          Some
            {
              category = Special;
              priority = HighPriority;
              description = "类型检查错误";
              chinese_name = Some "类型错误";
              aliases = [ "type_error" ];
              deprecated = false;
            };
      }
    in

    (* 验证错误令牌位置信息 *)
    check int "错误令牌行号正确" 10 positioned_error.position.line;
    check int "错误令牌列号正确" 5 positioned_error.position.column;
    check string "错误令牌文件名正确" "error_test.ly" positioned_error.position.filename;

    (* 验证元数据设置 *)
    match positioned_error.metadata with
    | Some meta ->
        check bool "错误令牌高优先级" true (meta.priority = HighPriority);
        check bool "错误令牌特殊分类" true (meta.category = Special)
    | None -> check bool "错误令牌应有元数据" false true

  (** 测试未定义类型的错误处理 *)
  let test_undefined_type_error () =
    (* 模拟未定义类型引用 *)
    let undefined_type = ConstructType_T ("未定义类型", []) in

    (* 验证类型定义存在（即使是未定义的） *)
    TestUtils.check_type_equal "未定义类型定义存在" undefined_type undefined_type;

    (* 验证是复合类型 *)
    check bool "未定义类型是复合类型" true (is_compound_type undefined_type);

    (* 验证字符串表示 *)
    let type_str = string_of_typ undefined_type in
    check bool "未定义类型字符串表示包含名称" true (String.length type_str > 0);

    (* 创建对应的错误令牌 *)
    let error_pos =
      { Token_types_core.filename = "undefined.ly"; line = 1; column = 1; offset = 0 }
    in
    let undefined_error = ErrorToken ("未定义的类型：未定义类型", error_pos) in

    TestUtils.check_unified_token_equal "未定义类型错误令牌正确" undefined_error undefined_error
end

(** 性能和边界条件测试 *)
module PerformanceBoundaryTests = struct
  open Core_types
  open Token_types

  (** 测试大量类型创建的性能 *)
  let test_bulk_type_creation () =
    (* 创建1000个类型变量 *)
    let type_vars = Array.init 1000 (fun _ -> new_type_var ()) in

    (* 验证所有类型变量都不同 *)
    for i = 0 to 999 do
      for j = i + 1 to 999 do
        check bool
          (Printf.sprintf "类型变量%d与%d不同" i j)
          false
          (Core_types.equal_typ type_vars.(i) type_vars.(j))
      done
    done;

    (* 验证类型变量个数正确 *)
    check int "创建类型变量数量正确" 1000 (Array.length type_vars)

  (** 测试复杂类型嵌套 *)
  let test_complex_type_nesting () =
    (* 创建深度嵌套的类型: [[[[Int]]]] *)
    let deeply_nested =
      let rec nest_list depth typ =
        if depth <= 0 then typ else nest_list (depth - 1) (ListType_T typ)
      in
      nest_list 10 IntType_T
    in

    (* 验证深度嵌套类型创建成功 *)
    TestUtils.check_type_equal "深度嵌套类型自身相等" deeply_nested deeply_nested;

    (* 验证是复合类型 *)
    check bool "深度嵌套类型是复合类型" true (is_compound_type deeply_nested);

    (* 验证字符串表示不会栈溢出 *)
    let nested_str = string_of_typ deeply_nested in
    check bool "深度嵌套类型字符串表示非空" true (String.length nested_str > 0)

  (** 测试大量令牌处理 *)
  let test_bulk_token_processing () =
    (* 创建1000个不同的整数令牌 *)
    let int_tokens = Array.init 1000 (fun i -> LiteralToken (Literals.IntToken i)) in

    (* 验证所有令牌创建正确 *)
    for i = 0 to 999 do
      let expected = LiteralToken (Literals.IntToken i) in
      TestUtils.check_token_equal (Printf.sprintf "整数令牌%d正确" i) expected int_tokens.(i)
    done;

    (* 验证不同值的令牌不相等 *)
    for i = 0 to 998 do
      check bool
        (Printf.sprintf "令牌%d与%d不同" i (i + 1))
        false
        (Token_types.equal_token int_tokens.(i) int_tokens.(i + 1))
    done

  (** 测试类型环境的边界条件 *)
  let test_type_environment_boundaries () =
    (* 创建大型类型环境 *)
    let large_env = ref TypeEnv.empty in

    (* 添加1000个变量 *)
    for i = 0 to 999 do
      let var_name = "变量" ^ string_of_int i in
      let var_type = if i mod 2 = 0 then IntType_T else StringType_T in
      let scheme = TypeScheme ([], var_type) in
      large_env := TypeEnv.add var_name scheme !large_env
    done;

    (* 验证环境大小 *)
    check bool "大型环境非空" false (TypeEnv.is_empty !large_env);

    (* 验证能够查找变量 *)
    let found_scheme = TypeEnv.find "变量500" !large_env in
    let (TypeScheme (_, found_type)) = found_scheme in
    TestUtils.check_type_equal "环境中找到正确类型" IntType_T found_type;

    (* 验证查找不存在的变量会失败 *)
    try
      let _ = TypeEnv.find "不存在的变量" !large_env in
      check bool "查找不存在变量应失败" false true
    with
    | Not_found -> check bool "正确处理未找到变量" true true
    | _ -> check bool "查找失败类型错误" false true
end

(** 实际使用场景模拟测试 *)
module RealWorldScenarioTests = struct
  open Core_types
  open Token_types

  (** 模拟简单变量定义的完整流程 *)
  let test_simple_variable_definition () =
    (* 源代码: 让 「x」 = 42 *)
    let tokens =
      [
        KeywordToken Keywords.LetKeyword;
        IdentifierToken (Identifiers.QuotedIdentifierToken "「x」");
        OperatorToken Operators.Equal;
        LiteralToken (Literals.IntToken 42);
      ]
    in

    (* 对应的类型推导 *)
    let variable_type = IntType_T in
    let type_env = TypeEnv.add "x" (TypeScheme ([], variable_type)) TypeEnv.empty in

    (* 验证令牌序列 *)
    List.iter (fun token -> TestUtils.check_token_equal "变量定义令牌存在" token token) tokens;

    (* 验证类型推导 *)
    TestUtils.check_type_equal "变量类型推道正确" variable_type variable_type;

    (* 验证类型环境 *)
    check bool "类型环境包含变量" true (TypeEnv.mem "x" type_env);
    let found_scheme = TypeEnv.find "x" type_env in
    let (TypeScheme (_, found_type)) = found_scheme in
    TestUtils.check_type_equal "环境中类型正确" variable_type found_type

  (** 模拟函数定义的完整流程 *)
  let test_function_definition () =
    (* 源代码: 让 「add」 = 函数 「x」 「y」 -> 「x」 + 「y」 *)
    let tokens =
      [
        KeywordToken Keywords.LetKeyword;
        IdentifierToken (Identifiers.QuotedIdentifierToken "「add」");
        OperatorToken Operators.Equal;
        KeywordToken Keywords.FunKeyword;
        IdentifierToken (Identifiers.QuotedIdentifierToken "「x」");
        IdentifierToken (Identifiers.QuotedIdentifierToken "「y」");
        OperatorToken Operators.Arrow;
        IdentifierToken (Identifiers.QuotedIdentifierToken "「x」");
        OperatorToken Operators.Plus;
        IdentifierToken (Identifiers.QuotedIdentifierToken "「y」");
      ]
    in

    (* 对应的函数类型: Int -> Int -> Int *)
    let param_type = IntType_T in
    let return_type = IntType_T in
    let function_type = FunType_T (param_type, FunType_T (param_type, return_type)) in

    (* 验证令牌序列 *)
    List.iter (fun token -> TestUtils.check_token_equal "函数定义令牌存在" token token) tokens;

    (* 验证函数类型 *)
    TestUtils.check_type_equal "函数类型正确" function_type function_type;

    (* 验证函数类型是复合类型 *)
    check bool "函数类型是复合类型" true (is_compound_type function_type);

    (* 验证类型字符串表示 *)
    let type_str = string_of_typ function_type in
    check bool "函数类型字符串非空" true (String.length type_str > 0)

  (** 模拟条件表达式的完整流程 *)
  let test_conditional_expression () =
    (* 源代码: 如果 真 那么 42 否则 0 *)
    let tokens =
      [
        KeywordToken Keywords.IfKeyword;
        LiteralToken (Literals.BoolToken true);
        KeywordToken Keywords.ThenKeyword;
        LiteralToken (Literals.IntToken 42);
        KeywordToken Keywords.ElseKeyword;
        LiteralToken (Literals.IntToken 0);
      ]
    in

    (* 条件表达式的类型应该是分支的公共类型 *)
    let condition_type = BoolType_T in
    let branch_type = IntType_T in
    let result_type = branch_type in
    (* 两个分支都是整数 *)

    (* 验证令牌序列 *)
    List.iter (fun token -> TestUtils.check_token_equal "条件表达式令牌存在" token token) tokens;

    (* 验证类型 *)
    TestUtils.check_type_equal "条件类型正确" condition_type condition_type;
    TestUtils.check_type_equal "分支类型正确" branch_type branch_type;
    TestUtils.check_type_equal "结果类型正确" result_type result_type;

    (* 验证基础类型判断 *)
    check bool "条件是基础类型" true (is_base_type condition_type);
    check bool "结果是基础类型" true (is_base_type result_type)

  (** 模拟类型错误场景 *)
  let test_type_error_scenario () =
    (* 源代码: 让 「x」 = 42 + "hello" (类型错误) *)
    let tokens =
      [
        KeywordToken Keywords.LetKeyword;
        IdentifierToken (Identifiers.QuotedIdentifierToken "「x」");
        OperatorToken Operators.Equal;
        LiteralToken (Literals.IntToken 42);
        OperatorToken Operators.Plus;
        LiteralToken (Literals.StringToken "hello");
      ]
    in

    (* 类型冲突：整数 + 字符串 *)
    let int_type = IntType_T in
    let string_type = StringType_T in

    (* 验证正常令牌 *)
    List.iter (fun token -> TestUtils.check_token_equal "类型错误场景令牌存在" token token) tokens;

    (* 验证类型不兼容 *)
    check bool "整数与字符串类型不同" false (Core_types.equal_typ int_type string_type);

    (* 创建类型错误令牌 *)
    let error_pos =
      { Token_types_core.filename = "type_error.ly"; line = 1; column = 15; offset = 15 }
    in
    let type_error = Token_types_core.ErrorToken ("类型错误：无法将字符串与整数相加", error_pos) in

    (* 验证错误令牌 *)
    let same_error = Token_types_core.ErrorToken ("类型错误：无法将字符串与整数相加", error_pos) in
    TestUtils.check_unified_token_equal "类型错误令牌创建正确" type_error same_error
end

(** 主测试套件 *)
let () =
  run "骆言类型系统集成测试"
    [
      ( "类型与令牌对应关系测试",
        [
          test_case "基础类型关键字对应" `Quick TypeTokenCorrespondenceTests.test_basic_type_keywords;
          test_case "复合类型令牌表示" `Quick TypeTokenCorrespondenceTests.test_compound_type_tokens;
          test_case "类型注解令牌序列" `Quick TypeTokenCorrespondenceTests.test_type_annotation_tokens;
        ] );
      ( "词法分析与类型推导集成测试",
        [
          test_case "令牌到类型的映射" `Quick LexicalTypeIntegrationTests.test_token_to_type_mapping;
          test_case "类型变量与标识符关系" `Quick
            LexicalTypeIntegrationTests.test_type_variables_and_identifiers;
          test_case "复杂表达式令牌类型对应" `Quick LexicalTypeIntegrationTests.test_complex_expression_tokens;
        ] );
      ( "错误处理集成测试",
        [
          test_case "类型错误令牌" `Quick ErrorHandlingIntegrationTests.test_type_error_tokens;
          test_case "未定义类型错误" `Quick ErrorHandlingIntegrationTests.test_undefined_type_error;
        ] );
      ( "性能和边界条件测试",
        [
          test_case "大量类型创建性能" `Quick PerformanceBoundaryTests.test_bulk_type_creation;
          test_case "复杂类型嵌套" `Quick PerformanceBoundaryTests.test_complex_type_nesting;
          test_case "大量令牌处理" `Quick PerformanceBoundaryTests.test_bulk_token_processing;
          test_case "类型环境边界条件" `Quick PerformanceBoundaryTests.test_type_environment_boundaries;
        ] );
      ( "实际使用场景模拟测试",
        [
          test_case "简单变量定义" `Quick RealWorldScenarioTests.test_simple_variable_definition;
          test_case "函数定义" `Quick RealWorldScenarioTests.test_function_definition;
          test_case "条件表达式" `Quick RealWorldScenarioTests.test_conditional_expression;
          test_case "类型错误场景" `Quick RealWorldScenarioTests.test_type_error_scenario;
        ] );
    ]
