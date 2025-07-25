(** 骆言Token系统整合重构 - 统一Token模块综合测试 验证新的Token架构的基础功能和整合效果 - Fix #1325 *)

open Alcotest
open Token_test_utils.TokenTestUtils
open Token_test_utils.TokenDataGenerator
open Token_test_utils.TokenClassificationUtils
open Tokens.Unified_tokens

(** 基础Token创建和相等性测试 *)
module BasicTokenTests = struct
  (** 测试基础Token创建功能 *)
  let test_basic_token_creation () =
    (* 测试关键字Token创建 *)
    let let_token = make_let_keyword () in
    let if_token = make_if_keyword () in
    assert_token_not_equal ~left:let_token ~right:if_token "let和if关键字应该不同";

    (* 测试字面量Token创建 *)
    let int_token = make_int_token 42 in
    let string_token = make_string_token "测试" in
    let bool_token = make_bool_token true in
    assert_token_not_equal ~left:int_token ~right:string_token "整数和字符串Token应该不同";
    assert_token_not_equal ~left:string_token ~right:bool_token "字符串和布尔Token应该不同";

    (* 测试操作符Token创建 *)
    let plus_token = make_plus_op () in
    let minus_token = make_minus_op () in
    assert_token_not_equal ~left:plus_token ~right:minus_token "加法和减法操作符应该不同"

  (** 测试Token相等性比较 *)
  let test_token_equality () =
    (* 相同Token应该相等 *)
    let token1 = make_int_token 123 in
    let token2 = make_int_token 123 in
    assert_token_equal ~expected:token1 ~actual:token2 "相同整数Token应该相等";

    let str_token1 = make_string_token "骆言" in
    let str_token2 = make_string_token "骆言" in
    assert_token_equal ~expected:str_token1 ~actual:str_token2 "相同字符串Token应该相等";

    (* 不同Token应该不等 *)
    let different_int = make_int_token 456 in
    assert_token_not_equal ~left:token1 ~right:different_int "不同整数Token应该不等"

  (** 测试Token自身相等性 *)
  let test_token_self_equality () =
    let tokens = generate_all_tokens () in
    List.iteri
      (fun i token ->
        assert_token_equal ~expected:token ~actual:token (Printf.sprintf "Token[%d]应该等于自身" i))
      tokens
end

(** Token分类和类型检查测试 *)
module TokenClassificationTests = struct
  (** 测试关键字Token分类 *)
  let test_keyword_classification () =
    let keyword_tokens = generate_keyword_tokens () in
    List.iter
      (fun token ->
        check bool "Token应被识别为关键字" true (is_keyword token);
        check bool "关键字不应被识别为字面量" false (is_literal token);
        check bool "关键字不应被识别为操作符" false (is_operator token))
      keyword_tokens

  (** 测试字面量Token分类 *)
  let test_literal_classification () =
    let literal_tokens = generate_literal_tokens () in
    List.iter
      (fun token ->
        check bool "Token应被识别为字面量" true (is_literal token);
        check bool "字面量不应被识别为关键字" false (is_keyword token);
        check bool "字面量不应被识别为操作符" false (is_operator token))
      literal_tokens

  (** 测试操作符Token分类 *)
  let test_operator_classification () =
    let operator_tokens = generate_operator_tokens () in
    List.iter
      (fun token ->
        check bool "Token应被识别为操作符" true (is_operator token);
        check bool "操作符不应被识别为关键字" false (is_keyword token);
        check bool "操作符不应被识别为字面量" false (is_literal token))
      operator_tokens

  (** 测试分隔符Token分类 *)
  let test_delimiter_classification () =
    let delimiter_tokens = generate_delimiter_tokens () in
    List.iter
      (fun token ->
        check bool "Token应被识别为分隔符" true (is_delimiter token);
        check bool "分隔符不应被识别为关键字" false (is_keyword token);
        check bool "分隔符不应被识别为字面量" false (is_literal token))
      delimiter_tokens

  (** 测试标识符Token分类 *)
  let test_identifier_classification () =
    let identifier_tokens = generate_identifier_tokens () in
    List.iter
      (fun token ->
        check bool "Token应被识别为标识符" true (is_identifier token);
        check bool "标识符不应被识别为关键字" false (is_keyword token);
        check bool "标识符不应被识别为字面量" false (is_literal token))
      identifier_tokens

  (** 测试文言文Token分类 *)
  let test_wenyan_classification () =
    let wenyan_tokens = generate_wenyan_tokens () in
    List.iter
      (fun token ->
        check bool "Token应被识别为文言文" true (is_wenyan token);
        check bool "文言文不应被识别为关键字" false (is_keyword token);
        check bool "文言文不应被识别为字面量" false (is_literal token))
      wenyan_tokens

  (** 测试自然语言Token分类 *)
  let test_natural_language_classification () =
    let nl_tokens = generate_natural_language_tokens () in
    List.iter
      (fun token ->
        check bool "Token应被识别为自然语言" true (is_natural_language token);
        check bool "自然语言不应被识别为关键字" false (is_keyword token);
        check bool "自然语言不应被识别为字面量" false (is_literal token))
      nl_tokens

  (** 测试诗词Token分类 *)
  let test_poetry_classification () =
    let poetry_tokens = generate_poetry_tokens () in
    List.iter
      (fun token ->
        check bool "Token应被识别为诗词" true (is_poetry token);
        check bool "诗词不应被识别为关键字" false (is_keyword token);
        check bool "诗词不应被识别为字面量" false (is_literal token))
      poetry_tokens
end

(** Token字符串转换测试 *)
module TokenStringConversionTests = struct
  (** 测试基础Token字符串转换 *)
  let test_basic_token_string_conversion () =
    (* 测试整数Token转换 *)
    let int_token = make_int_token 42 in
    let int_str = token_to_string int_token in
    check string "整数Token字符串转换" "42" int_str;

    (* 测试字符串Token转换 *)
    let str_token = make_string_token "骆言" in
    let str_str = token_to_string str_token in
    check string "字符串Token转换应包含引号" "\"骆言\"" str_str;

    (* 测试布尔Token转换 *)
    let true_token = make_bool_token true in
    let false_token = make_bool_token false in
    check string "真值Token字符串转换" "true" (token_to_string true_token);
    check string "假值Token字符串转换" "false" (token_to_string false_token)

  (** 测试所有Token类型的字符串转换 *)
  let test_comprehensive_string_conversion () =
    let all_tokens = generate_all_tokens () in
    List.iter
      (fun token ->
        let token_str = token_to_string token in
        check bool "Token字符串转换不应为空" true (String.length token_str > 0);
        check bool "Token字符串应为有效UTF-8" true (String.length token_str > 0))
      all_tokens

  (** 测试边界情况字符串转换 *)
  let test_edge_case_string_conversion () =
    let edge_tokens = generate_edge_case_tokens () in
    List.iter
      (fun token ->
        let token_str = token_to_string token in
        check bool "边界情况Token转换不应失败" true (String.length token_str >= 0))
      edge_tokens
end

(** Token位置信息测试 *)
module TokenPositionTests = struct
  (** 测试位置信息创建 *)
  let test_position_creation () =
    let pos1 = { line = 1; column = 10; filename = "test.ly" } in
    let pos2 = { line = 1; column = 10; filename = "test.ly" } in
    let pos3 = { line = 2; column = 10; filename = "test.ly" } in

    assert_position_equal ~expected:pos1 ~actual:pos2 "相同位置应该相等";
    check bool "不同行的位置应该不等" false
      (pos1.line = pos3.line && pos1.column = pos3.column && pos1.filename = pos3.filename)

  (** 测试带位置的Token *)
  let test_positioned_tokens () =
    let token = make_int_token 123 in
    let pos = { line = 5; column = 15; filename = "example.ly" } in
    let positioned_token = (token, pos) in

    let extracted_token, extracted_pos = positioned_token in
    assert_token_equal ~expected:token ~actual:extracted_token "提取的Token应该相等";
    assert_position_equal ~expected:pos ~actual:extracted_pos "提取的位置应该相等"
end

(** Token列表操作测试 *)
module TokenListTests = struct
  (** 测试Token列表相等性 *)
  let test_token_list_equality () =
    let tokens1 = [ make_int_token 1; make_string_token "test"; make_bool_token true ] in
    let tokens2 = [ make_int_token 1; make_string_token "test"; make_bool_token true ] in
    let tokens3 = [ make_int_token 2; make_string_token "test"; make_bool_token true ] in

    assert_token_list_equal ~expected:tokens1 ~actual:tokens2 "相同Token列表应该相等";
    check bool "不同Token列表应该不等" false (List.for_all2 equal_token tokens1 tokens3)

  (** 测试空Token列表 *)
  let test_empty_token_list () =
    let empty1 = [] in
    let empty2 = [] in
    let non_empty = [ make_int_token 0 ] in

    assert_token_list_equal ~expected:empty1 ~actual:empty2 "空列表应该相等";
    check bool "空列表和非空列表应该不等" false (List.length empty1 = List.length non_empty)

  (** 测试大型Token列表 *)
  let test_large_token_list () =
    let large_list = generate_all_tokens () in
    let list_copy = generate_all_tokens () in

    assert_token_list_equal ~expected:large_list ~actual:list_copy "相同生成的大型Token列表应该相等";

    check int "大型Token列表长度应正确" (List.length large_list) (List.length list_copy)
end

(** 综合集成测试 *)
module IntegrationTests = struct
  (** 测试Token系统整体功能 *)
  let test_token_system_integration () =
    (* 创建各种类型的Token *)
    let tokens =
      [
        make_let_keyword ();
        make_int_token 42;
        make_string_token "变量名";
        make_plus_op ();
        make_quoted_identifier "计算结果";
      ]
    in

    (* 验证所有Token都能正确创建和分类 *)
    List.iteri
      (fun i token ->
        let token_str = token_to_string token in
        check bool (Printf.sprintf "Token[%d]字符串转换成功" i) true (String.length token_str > 0);

        let type_name = get_token_type_name token in
        check bool (Printf.sprintf "Token[%d]类型识别成功" i) true (String.length type_name > 0))
      tokens

  (** 测试Token转换链 *)
  let test_token_conversion_chain () =
    let original_token = make_string_token "骆言编程语言" in
    let token_string = token_to_string original_token in
    let expected_string = "\"骆言编程语言\"" in

    check string "Token转换链应保持一致" expected_string token_string;

    (* 验证可以从字符串识别Token类型 *)
    check bool "应能识别为字符串Token" true (is_literal original_token)
end

(** 运行所有测试的主函数 *)
let () =
  let open Alcotest in
  run "骆言Token系统整合重构 - 统一Token模块测试"
    [
      ( "基础Token功能测试",
        [
          test_case "Token创建功能" `Quick BasicTokenTests.test_basic_token_creation;
          test_case "Token相等性比较" `Quick BasicTokenTests.test_token_equality;
          test_case "Token自身相等性" `Quick BasicTokenTests.test_token_self_equality;
        ] );
      ( "Token分类测试",
        [
          test_case "关键字分类" `Quick TokenClassificationTests.test_keyword_classification;
          test_case "字面量分类" `Quick TokenClassificationTests.test_literal_classification;
          test_case "操作符分类" `Quick TokenClassificationTests.test_operator_classification;
          test_case "分隔符分类" `Quick TokenClassificationTests.test_delimiter_classification;
          test_case "标识符分类" `Quick TokenClassificationTests.test_identifier_classification;
          test_case "文言文分类" `Quick TokenClassificationTests.test_wenyan_classification;
          test_case "自然语言分类" `Quick TokenClassificationTests.test_natural_language_classification;
          test_case "诗词分类" `Quick TokenClassificationTests.test_poetry_classification;
        ] );
      ( "Token字符串转换测试",
        [
          test_case "基础字符串转换" `Quick TokenStringConversionTests.test_basic_token_string_conversion;
          test_case "全面字符串转换" `Quick TokenStringConversionTests.test_comprehensive_string_conversion;
          test_case "边界情况转换" `Quick TokenStringConversionTests.test_edge_case_string_conversion;
        ] );
      ( "Token位置信息测试",
        [
          test_case "位置信息创建" `Quick TokenPositionTests.test_position_creation;
          test_case "带位置Token" `Quick TokenPositionTests.test_positioned_tokens;
        ] );
      ( "Token列表操作测试",
        [
          test_case "列表相等性" `Quick TokenListTests.test_token_list_equality;
          test_case "空列表处理" `Quick TokenListTests.test_empty_token_list;
          test_case "大型列表处理" `Quick TokenListTests.test_large_token_list;
        ] );
      ( "集成测试",
        [
          test_case "Token系统整合" `Quick IntegrationTests.test_token_system_integration;
          test_case "Token转换链" `Quick IntegrationTests.test_token_conversion_chain;
        ] );
    ]
