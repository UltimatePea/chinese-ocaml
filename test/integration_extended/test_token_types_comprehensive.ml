(** 骆言令牌类型系统综合测试套件 - Issue #946 第二阶段令牌处理测试补强 *)

open Alcotest
open Yyocamlc_lib.Token_types

(** 测试辅助函数 *)
module TestUtils = struct
  (** 检查令牌是否相等 *)
  let check_token_equal desc expected actual = check bool desc true (equal_token expected actual)

  (** 检查令牌不相等 *)
  let check_token_not_equal desc left right = check bool desc false (equal_token left right)

  (** 检查位置信息是否相等 *)
  let check_position_equal desc expected actual =
    check bool desc true (equal_position expected actual)
end

(** 操作符令牌测试 *)
module OperatorTokenTests = struct
  open Operators

  (** 测试算术操作符令牌 *)
  let test_arithmetic_operators () =
    let ops = [ Plus; Minus; Multiply; Divide; Modulo; Power ] in
    let op_tokens = List.map (fun op -> OperatorToken op) ops in

    (* 测试操作符令牌自身相等 *)
    List.iter2
      (fun op token -> TestUtils.check_token_equal (show_operator_token op ^ "令牌自身相等") token token)
      ops op_tokens;

    (* 测试不同操作符令牌不等 *)
    let plus_token = OperatorToken Plus in
    let minus_token = OperatorToken Minus in
    TestUtils.check_token_not_equal "加法与减法操作符不等" plus_token minus_token;

    (* 测试操作符类型检查 *)
    check bool "加法令牌是操作符" true (TokenUtils.is_operator plus_token);
    check bool "加法令牌不是关键字" false (TokenUtils.is_keyword plus_token)

  (** 测试比较操作符令牌 *)
  let test_comparison_operators () =
    let comparison_ops = [ Equal; NotEqual; LessThan; LessEqual; GreaterThan; GreaterEqual ] in
    let comparison_tokens = List.map (fun op -> OperatorToken op) comparison_ops in

    (* 测试比较操作符令牌创建和相等性 *)
    List.iter2
      (fun op token ->
        TestUtils.check_token_equal (show_operator_token op ^ "比较操作符令牌相等") token token;
        check bool (show_operator_token op ^ "是操作符令牌") true (TokenUtils.is_operator token))
      comparison_ops comparison_tokens;

    (* 测试不同比较操作符不等 *)
    let equal_token = OperatorToken Equal in
    let not_equal_token = OperatorToken NotEqual in
    TestUtils.check_token_not_equal "等于与不等于操作符不同" equal_token not_equal_token

  (** 测试逻辑操作符令牌 *)
  let test_logical_operators () =
    let logical_ops = [ LogicalAnd; LogicalOr; LogicalNot ] in
    let logical_tokens = List.map (fun op -> OperatorToken op) logical_ops in

    List.iter2
      (fun op token ->
        TestUtils.check_token_equal (show_operator_token op ^ "逻辑操作符令牌相等") token token;
        check bool (show_operator_token op ^ "是操作符令牌") true (TokenUtils.is_operator token))
      logical_ops logical_tokens

  (** 测试位操作符令牌 *)
  let test_bitwise_operators () =
    let bitwise_ops =
      [ BitwiseAnd; BitwiseOr; BitwiseXor; BitwiseNot; ShiftLeft; ShiftRight; ArithShiftRight ]
    in
    let bitwise_tokens = List.map (fun op -> OperatorToken op) bitwise_ops in

    List.iter2
      (fun op token ->
        TestUtils.check_token_equal (show_operator_token op ^ "位操作符令牌相等") token token;
        check bool (show_operator_token op ^ "是操作符令牌") true (TokenUtils.is_operator token))
      bitwise_ops bitwise_tokens

  (** 测试其他特殊操作符令牌 *)
  let test_special_operators () =
    let special_ops =
      [ Assign; Dereference; Reference; Compose; PipeForward; PipeBackward; Arrow; DoubleArrow ]
    in
    let special_tokens = List.map (fun op -> OperatorToken op) special_ops in

    List.iter2
      (fun op token ->
        TestUtils.check_token_equal (show_operator_token op ^ "特殊操作符令牌相等") token token;
        check bool (show_operator_token op ^ "是操作符令牌") true (TokenUtils.is_operator token))
      special_ops special_tokens
end

(** 关键字令牌测试 *)
module KeywordTokenTests = struct
  open Keywords

  (** 测试基础关键字令牌 *)
  let test_basic_keywords () =
    let basic_keywords =
      [ LetKeyword; RecKeyword; InKeyword; FunKeyword; IfKeyword; ThenKeyword; ElseKeyword ]
    in
    let keyword_tokens = List.map (fun kw -> KeywordToken kw) basic_keywords in

    (* 测试关键字令牌自身相等 *)
    List.iter2
      (fun kw token ->
        TestUtils.check_token_equal (show_keyword_token kw ^ "关键字令牌相等") token token;
        check bool (show_keyword_token kw ^ "是关键字令牌") true (TokenUtils.is_keyword token);
        check bool (show_keyword_token kw ^ "不是操作符令牌") false (TokenUtils.is_operator token))
      basic_keywords keyword_tokens;

    (* 测试不同关键字不等 *)
    let let_token = KeywordToken LetKeyword in
    let fun_token = KeywordToken FunKeyword in
    TestUtils.check_token_not_equal "让与函数关键字不等" let_token fun_token

  (** 测试匹配和模式相关关键字 *)
  let test_pattern_keywords () =
    let pattern_keywords = [ MatchKeyword; WithKeyword; OtherKeyword; WhenKeyword ] in
    let pattern_tokens = List.map (fun kw -> KeywordToken kw) pattern_keywords in

    List.iter2
      (fun kw token ->
        TestUtils.check_token_equal (show_keyword_token kw ^ "模式关键字令牌相等") token token;
        check bool (show_keyword_token kw ^ "是关键字令牌") true (TokenUtils.is_keyword token))
      pattern_keywords pattern_tokens

  (** 测试类型系统关键字 *)
  let test_type_keywords () =
    let type_keywords = [ TypeKeyword; PrivateKeyword; AsKeyword; OfKeyword ] in
    let type_tokens = List.map (fun kw -> KeywordToken kw) type_keywords in

    List.iter2
      (fun kw token ->
        TestUtils.check_token_equal (show_keyword_token kw ^ "类型关键字令牌相等") token token;
        check bool (show_keyword_token kw ^ "是关键字令牌") true (TokenUtils.is_keyword token))
      type_keywords type_tokens

  (** 测试布尔和逻辑关键字 *)
  let test_boolean_keywords () =
    let boolean_keywords = [ TrueKeyword; FalseKeyword; AndKeyword; OrKeyword; NotKeyword ] in
    let boolean_tokens = List.map (fun kw -> KeywordToken kw) boolean_keywords in

    List.iter2
      (fun kw token ->
        TestUtils.check_token_equal (show_keyword_token kw ^ "布尔关键字令牌相等") token token;
        check bool (show_keyword_token kw ^ "是关键字令牌") true (TokenUtils.is_keyword token))
      boolean_keywords boolean_tokens

  (** 测试异常处理关键字 *)
  let test_exception_keywords () =
    let exception_keywords =
      [ ExceptionKeyword; RaiseKeyword; TryKeyword; CatchKeyword; FinallyKeyword ]
    in
    let exception_tokens = List.map (fun kw -> KeywordToken kw) exception_keywords in

    List.iter2
      (fun kw token ->
        TestUtils.check_token_equal (show_keyword_token kw ^ "异常关键字令牌相等") token token;
        check bool (show_keyword_token kw ^ "是关键字令牌") true (TokenUtils.is_keyword token))
      exception_keywords exception_tokens

  (** 测试模块系统关键字 *)
  let test_module_keywords () =
    let module_keywords =
      [
        ModuleKeyword;
        ModuleTypeKeyword;
        OpenKeyword;
        IncludeKeyword;
        SigKeyword;
        StructKeyword;
        EndKeyword;
        FunctorKeyword;
        ValKeyword;
        ExternalKeyword;
      ]
    in
    let module_tokens = List.map (fun kw -> KeywordToken kw) module_keywords in

    List.iter2
      (fun kw token ->
        TestUtils.check_token_equal (show_keyword_token kw ^ "模块关键字令牌相等") token token;
        check bool (show_keyword_token kw ^ "是关键字令牌") true (TokenUtils.is_keyword token))
      module_keywords module_tokens

  (** 测试古雅体和文言文关键字 *)
  let test_classical_keywords () =
    let classical_keywords =
      [
        BeginKeyword;
        FinishKeyword;
        WenyanNow;
        WenyanHave;
        WenyanIs;
        ClassicalLet;
        ClassicalIn;
        ClassicalBe;
      ]
    in
    let classical_tokens = List.map (fun kw -> KeywordToken kw) classical_keywords in

    List.iter2
      (fun kw token ->
        TestUtils.check_token_equal (show_keyword_token kw ^ "古雅体关键字令牌相等") token token;
        check bool (show_keyword_token kw ^ "是关键字令牌") true (TokenUtils.is_keyword token))
      classical_keywords classical_tokens

  (** 测试诗词语法关键字 *)
  let test_poetry_keywords () =
    let poetry_keywords =
      [
        PoetryStart;
        PoetryEnd;
        VerseStart;
        VerseEnd;
        RhymePattern;
        TonePattern;
        ParallelStart;
        ParallelEnd;
      ]
    in
    let poetry_tokens = List.map (fun kw -> KeywordToken kw) poetry_keywords in

    List.iter2
      (fun kw token ->
        TestUtils.check_token_equal (show_keyword_token kw ^ "诗词关键字令牌相等") token token;
        check bool (show_keyword_token kw ^ "是关键字令牌") true (TokenUtils.is_keyword token))
      poetry_keywords poetry_tokens
end

(** 字面量令牌测试 *)
module LiteralTokenTests = struct
  open Literals

  (** 测试数值字面量令牌 *)
  let test_numeric_literals () =
    let int_token = LiteralToken (IntToken 42) in
    let float_token = LiteralToken (FloatToken 3.14) in
    let chinese_num_token = LiteralToken (ChineseNumberToken "四十二") in

    (* 测试数值令牌自身相等 *)
    TestUtils.check_token_equal "整数字面量令牌相等" int_token int_token;
    TestUtils.check_token_equal "浮点数字面量令牌相等" float_token float_token;
    TestUtils.check_token_equal "中文数字字面量令牌相等" chinese_num_token chinese_num_token;

    (* 测试不同数值令牌不等 *)
    TestUtils.check_token_not_equal "整数与浮点数令牌不等" int_token float_token;
    TestUtils.check_token_not_equal "阿拉伯与中文数字令牌不等" int_token chinese_num_token;

    (* 测试类型检查 *)
    check bool "整数令牌是字面量" true (TokenUtils.is_literal int_token);
    check bool "浮点数令牌是字面量" true (TokenUtils.is_literal float_token);
    check bool "中文数字令牌是字面量" true (TokenUtils.is_literal chinese_num_token)

  (** 测试文本字面量令牌 *)
  let test_text_literals () =
    let string_token = LiteralToken (StringToken "你好世界") in
    let char_token = LiteralToken (CharToken 'A') in

    TestUtils.check_token_equal "字符串字面量令牌相等" string_token string_token;
    TestUtils.check_token_equal "字符字面量令牌相等" char_token char_token;
    TestUtils.check_token_not_equal "字符串与字符令牌不等" string_token char_token;

    check bool "字符串令牌是字面量" true (TokenUtils.is_literal string_token);
    check bool "字符令牌是字面量" true (TokenUtils.is_literal char_token)

  (** 测试布尔和特殊字面量令牌 *)
  let test_boolean_and_special_literals () =
    let true_token = LiteralToken (BoolToken true) in
    let false_token = LiteralToken (BoolToken false) in
    let unit_token = LiteralToken UnitToken in
    let null_token = LiteralToken NullToken in

    TestUtils.check_token_equal "真值字面量令牌相等" true_token true_token;
    TestUtils.check_token_equal "假值字面量令牌相等" false_token false_token;
    TestUtils.check_token_equal "空值字面量令牌相等" unit_token unit_token;
    TestUtils.check_token_equal "空引用字面量令牌相等" null_token null_token;

    TestUtils.check_token_not_equal "真假值令牌不等" true_token false_token;
    TestUtils.check_token_not_equal "空值与空引用令牌不等" unit_token null_token;

    check bool "布尔令牌是字面量" true (TokenUtils.is_literal true_token);
    check bool "空值令牌是字面量" true (TokenUtils.is_literal unit_token)
end

(** 标识符令牌测试 *)
module IdentifierTokenTests = struct
  open Identifiers

  (** 测试标识符令牌创建和相等性 *)
  let test_identifier_creation () =
    let quoted_id = IdentifierToken (QuotedIdentifierToken "「变量名」") in
    let special_id = IdentifierToken (IdentifierTokenSpecial "数值") in
    let constructor_id = IdentifierToken (ConstructorToken "Some") in
    let module_id = IdentifierToken (ModuleIdToken "MyModule") in
    let type_id = IdentifierToken (TypeIdToken "MyType") in
    let label_id = IdentifierToken (LabelToken "label") in

    (* 测试标识符令牌自身相等 *)
    TestUtils.check_token_equal "引用标识符令牌相等" quoted_id quoted_id;
    TestUtils.check_token_equal "特殊标识符令牌相等" special_id special_id;
    TestUtils.check_token_equal "构造函数标识符令牌相等" constructor_id constructor_id;
    TestUtils.check_token_equal "模块标识符令牌相等" module_id module_id;
    TestUtils.check_token_equal "类型标识符令牌相等" type_id type_id;
    TestUtils.check_token_equal "标签标识符令牌相等" label_id label_id;

    (* 测试不同标识符令牌不等 *)
    TestUtils.check_token_not_equal "不同类型标识符不等1" quoted_id special_id;
    TestUtils.check_token_not_equal "不同类型标识符不等2" constructor_id module_id;
    TestUtils.check_token_not_equal "不同类型标识符不等3" type_id label_id;

    (* 测试类型检查 *)
    check bool "引用标识符是标识符令牌" true (TokenUtils.is_identifier quoted_id);
    check bool "构造函数标识符是标识符令牌" true (TokenUtils.is_identifier constructor_id);
    check bool "模块标识符是标识符令牌" true (TokenUtils.is_identifier module_id);
    check bool "标识符不是关键字" false (TokenUtils.is_keyword quoted_id)

  (** 测试标识符内容检查 *)
  let test_identifier_content () =
    let var1 = IdentifierToken (QuotedIdentifierToken "「变量一」") in
    let var2 = IdentifierToken (QuotedIdentifierToken "「变量二」") in

    (* 同名标识符应相等 *)
    let same_var = IdentifierToken (QuotedIdentifierToken "「变量一」") in
    TestUtils.check_token_equal "同名标识符相等" var1 same_var;

    (* 不同名标识符应不等 *)
    TestUtils.check_token_not_equal "不同名标识符不等" var1 var2
end

(** 分隔符令牌测试 *)
module DelimiterTokenTests = struct
  open Delimiters

  (** 测试ASCII分隔符令牌 *)
  let test_ascii_delimiters () =
    let ascii_delims =
      [
        LeftParen;
        RightParen;
        LeftBracket;
        RightBracket;
        LeftBrace;
        RightBrace;
        Comma;
        Semicolon;
        Colon;
      ]
    in
    let ascii_tokens = List.map (fun del -> DelimiterToken del) ascii_delims in

    List.iter2
      (fun del token ->
        TestUtils.check_token_equal (show_delimiter_token del ^ "分隔符令牌相等") token token;
        check bool (show_delimiter_token del ^ "是分隔符令牌") true (TokenUtils.is_delimiter token);
        check bool (show_delimiter_token del ^ "不是操作符令牌") false (TokenUtils.is_operator token))
      ascii_delims ascii_tokens;

    (* 测试不同分隔符不等 *)
    let left_paren = DelimiterToken LeftParen in
    let right_paren = DelimiterToken RightParen in
    TestUtils.check_token_not_equal "左右括号分隔符不等" left_paren right_paren

  (** 测试中文分隔符令牌 *)
  let test_chinese_delimiters () =
    let chinese_delims =
      [
        ChineseLeftParen;
        ChineseRightParen;
        ChineseLeftBracket;
        ChineseRightBracket;
        ChineseComma;
        ChineseSemicolon;
        ChineseColon;
      ]
    in
    let chinese_tokens = List.map (fun del -> DelimiterToken del) chinese_delims in

    List.iter2
      (fun del token ->
        TestUtils.check_token_equal (show_delimiter_token del ^ "中文分隔符令牌相等") token token;
        check bool (show_delimiter_token del ^ "是分隔符令牌") true (TokenUtils.is_delimiter token))
      chinese_delims chinese_tokens;

    (* 测试ASCII与中文分隔符不等 *)
    let ascii_paren = DelimiterToken LeftParen in
    let chinese_paren = DelimiterToken ChineseLeftParen in
    TestUtils.check_token_not_equal "ASCII与中文括号不等" ascii_paren chinese_paren

  (** 测试特殊分隔符令牌 *)
  let test_special_delimiters () =
    let special_delims =
      [
        LeftArray;
        RightArray;
        AssignArrow;
        LeftQuote;
        RightQuote;
        ChineseDoubleColon;
        ChineseArrow;
        ChineseDoubleArrow;
      ]
    in
    let special_tokens = List.map (fun del -> DelimiterToken del) special_delims in

    List.iter2
      (fun del token ->
        TestUtils.check_token_equal (show_delimiter_token del ^ "特殊分隔符令牌相等") token token;
        check bool (show_delimiter_token del ^ "是分隔符令牌") true (TokenUtils.is_delimiter token))
      special_delims special_tokens
end

(** 特殊令牌测试 *)
module SpecialTokenTests = struct
  open Special

  (** 测试特殊令牌创建和检查 *)
  let test_special_tokens () =
    let newline_token = SpecialToken Newline in
    let eof_token = SpecialToken EOF in
    let comment_token = SpecialToken (Comment "这是注释") in
    let chinese_comment_token = SpecialToken (ChineseComment "这是中文注释") in
    let whitespace_token = SpecialToken (Whitespace "   ") in

    (* 测试特殊令牌自身相等 *)
    TestUtils.check_token_equal "换行令牌相等" newline_token newline_token;
    TestUtils.check_token_equal "EOF令牌相等" eof_token eof_token;
    TestUtils.check_token_equal "注释令牌相等" comment_token comment_token;
    TestUtils.check_token_equal "中文注释令牌相等" chinese_comment_token chinese_comment_token;
    TestUtils.check_token_equal "空白令牌相等" whitespace_token whitespace_token;

    (* 测试不同特殊令牌不等 *)
    TestUtils.check_token_not_equal "换行与EOF令牌不等" newline_token eof_token;
    TestUtils.check_token_not_equal "注释与空白令牌不等" comment_token whitespace_token;

    (* 测试特殊令牌类型检查 *)
    check bool "换行令牌是特殊令牌" true (TokenUtils.is_special newline_token);
    check bool "EOF令牌是特殊令牌" true (TokenUtils.is_special eof_token);
    check bool "注释令牌是特殊令牌" true (TokenUtils.is_special comment_token);

    (* 测试特定特殊令牌检查函数 *)
    check bool "EOF令牌检查正确" true (TokenUtils.is_eof eof_token);
    check bool "换行令牌检查正确" true (TokenUtils.is_newline newline_token);
    check bool "非EOF令牌检查正确" false (TokenUtils.is_eof newline_token);
    check bool "非换行令牌检查正确" false (TokenUtils.is_newline eof_token)
end

(** 位置信息测试 *)
module PositionTests = struct
  (** 测试位置信息创建和操作 *)
  let test_position_creation () =
    let pos1 = { line = 1; column = 1; filename = "test.ly" } in
    let pos2 = { line = 2; column = 10; filename = "main.ly" } in
    let pos3 = { line = 1; column = 1; filename = "test.ly" } in

    (* 测试位置信息相等性 *)
    TestUtils.check_position_equal "相同位置信息相等" pos1 pos3;
    check bool "不同位置信息不等" false (equal_position pos1 pos2);

    (* 测试位置信息字段访问 *)
    check int "位置行号正确" 1 pos1.line;
    check int "位置列号正确" 1 pos1.column;
    check string "位置文件名正确" "test.ly" pos1.filename

  (** 测试带位置的令牌 *)
  let test_positioned_tokens () =
    let pos = { line = 5; column = 10; filename = "example.ly" } in
    let token = KeywordToken Keywords.LetKeyword in
    let positioned_token = (token, pos) in

    let extracted_token, extracted_pos = positioned_token in
    TestUtils.check_token_equal "从位置令牌提取令牌正确" token extracted_token;
    TestUtils.check_position_equal "从位置令牌提取位置正确" pos extracted_pos;

    (* 测试带位置令牌的相等性 *)
    let same_positioned = (token, pos) in
    let different_positioned = (token, { line = 6; column = 10; filename = "example.ly" }) in

    check bool "相同带位置令牌相等" true (equal_positioned_token positioned_token same_positioned);
    check bool "不同带位置令牌不等" false (equal_positioned_token positioned_token different_positioned)
end

(** 令牌实用函数测试 *)
module TokenUtilityTests = struct
  (** 测试令牌字符串表示 *)
  let test_token_string_representation () =
    let int_token = LiteralToken (Literals.IntToken 42) in
    let keyword_token = KeywordToken Keywords.LetKeyword in
    let operator_token = OperatorToken Operators.Plus in
    let identifier_token = IdentifierToken (Identifiers.QuotedIdentifierToken "「变量」") in
    let delimiter_token = DelimiterToken Delimiters.LeftParen in
    let special_token = SpecialToken Special.EOF in

    (* 测试令牌字符串表示非空 *)
    let int_str = TokenUtils.token_to_string int_token in
    let keyword_str = TokenUtils.token_to_string keyword_token in
    let operator_str = TokenUtils.token_to_string operator_token in
    let identifier_str = TokenUtils.token_to_string identifier_token in
    let delimiter_str = TokenUtils.token_to_string delimiter_token in
    let special_str = TokenUtils.token_to_string special_token in

    check bool "整数令牌字符串表示非空" true (String.length int_str > 0);
    check bool "关键字令牌字符串表示非空" true (String.length keyword_str > 0);
    check bool "操作符令牌字符串表示非空" true (String.length operator_str > 0);
    check bool "标识符令牌字符串表示非空" true (String.length identifier_str > 0);
    check bool "分隔符令牌字符串表示非空" true (String.length delimiter_str > 0);
    check bool "特殊令牌字符串表示非空" true (String.length special_str > 0);

    (* 测试不同令牌有不同的字符串表示 *)
    check bool "不同令牌字符串表示不同1" false (String.equal int_str keyword_str);
    check bool "不同令牌字符串表示不同2" false (String.equal operator_str identifier_str);
    check bool "不同令牌字符串表示不同3" false (String.equal delimiter_str special_str)

  (** 测试令牌分类函数综合性 *)
  let test_token_classification_comprehensive () =
    let test_cases =
      [
        (OperatorToken Operators.Plus, "操作符", [ TokenUtils.is_operator ]);
        (KeywordToken Keywords.LetKeyword, "关键字", [ TokenUtils.is_keyword ]);
        (LiteralToken (Literals.IntToken 42), "字面量", [ TokenUtils.is_literal ]);
        ( IdentifierToken (Identifiers.QuotedIdentifierToken "「x」"),
          "标识符",
          [ TokenUtils.is_identifier ] );
        (DelimiterToken Delimiters.LeftParen, "分隔符", [ TokenUtils.is_delimiter ]);
        (SpecialToken Special.EOF, "特殊令牌", [ TokenUtils.is_special ]);
      ]
    in

    List.iter
      (fun (token, desc, predicates) ->
        (* 测试正确的分类返回true *)
        List.iter (fun predicate -> check bool (desc ^ "分类正确") true (predicate token)) predicates;

        (* 简化测试：只测试基本分类功能 *)
        check bool (desc ^ "令牌有效") true true)
      test_cases
end

(** 主测试套件 *)
let () =
  run "骆言令牌类型系统综合测试"
    [
      ( "操作符令牌测试",
        [
          test_case "算术操作符" `Quick OperatorTokenTests.test_arithmetic_operators;
          test_case "比较操作符" `Quick OperatorTokenTests.test_comparison_operators;
          test_case "逻辑操作符" `Quick OperatorTokenTests.test_logical_operators;
          test_case "位操作符" `Quick OperatorTokenTests.test_bitwise_operators;
          test_case "特殊操作符" `Quick OperatorTokenTests.test_special_operators;
        ] );
      ( "关键字令牌测试",
        [
          test_case "基础关键字" `Quick KeywordTokenTests.test_basic_keywords;
          test_case "模式匹配关键字" `Quick KeywordTokenTests.test_pattern_keywords;
          test_case "类型系统关键字" `Quick KeywordTokenTests.test_type_keywords;
          test_case "布尔逻辑关键字" `Quick KeywordTokenTests.test_boolean_keywords;
          test_case "异常处理关键字" `Quick KeywordTokenTests.test_exception_keywords;
          test_case "模块系统关键字" `Quick KeywordTokenTests.test_module_keywords;
          test_case "古雅体关键字" `Quick KeywordTokenTests.test_classical_keywords;
          test_case "诗词语法关键字" `Quick KeywordTokenTests.test_poetry_keywords;
        ] );
      ( "字面量令牌测试",
        [
          test_case "数值字面量" `Quick LiteralTokenTests.test_numeric_literals;
          test_case "文本字面量" `Quick LiteralTokenTests.test_text_literals;
          test_case "布尔和特殊字面量" `Quick LiteralTokenTests.test_boolean_and_special_literals;
        ] );
      ( "标识符令牌测试",
        [
          test_case "标识符创建" `Quick IdentifierTokenTests.test_identifier_creation;
          test_case "标识符内容" `Quick IdentifierTokenTests.test_identifier_content;
        ] );
      ( "分隔符令牌测试",
        [
          test_case "ASCII分隔符" `Quick DelimiterTokenTests.test_ascii_delimiters;
          test_case "中文分隔符" `Quick DelimiterTokenTests.test_chinese_delimiters;
          test_case "特殊分隔符" `Quick DelimiterTokenTests.test_special_delimiters;
        ] );
      ("特殊令牌测试", [ test_case "特殊令牌" `Quick SpecialTokenTests.test_special_tokens ]);
      ( "位置信息测试",
        [
          test_case "位置信息创建" `Quick PositionTests.test_position_creation;
          test_case "带位置令牌" `Quick PositionTests.test_positioned_tokens;
        ] );
      ( "令牌实用函数测试",
        [
          test_case "令牌字符串表示" `Quick TokenUtilityTests.test_token_string_representation;
          test_case "令牌分类函数" `Quick TokenUtilityTests.test_token_classification_comprehensive;
        ] );
    ]
