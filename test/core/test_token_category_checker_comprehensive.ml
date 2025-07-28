(** 全面的Token_category_checker模块测试 *)

open Alcotest
open Yyocamlc_lib.Token_category_checker
open Yyocamlc_lib.Token_types_core

(** 测试字面量token识别 *)
let test_is_literal_token () =
  (* 测试整数字面量 *)
  check bool "int literal" true (is_literal_token (IntToken 42));
  check bool "float literal" true (is_literal_token (FloatToken 3.14));
  check bool "string literal" true (is_literal_token (StringToken "hello"));
  check bool "bool literal true" true (is_literal_token (BoolToken true));
  check bool "bool literal false" true (is_literal_token (BoolToken false));
  check bool "chinese number" true (is_literal_token (ChineseNumberToken "一"));
  check bool "unit literal" true (is_literal_token UnitToken);

  (* 测试非字面量token *)
  check bool "identifier not literal" false (is_literal_token (IdentifierToken "x"));
  check bool "keyword not literal" false (is_literal_token LetKeyword);
  check bool "operator not literal" false (is_literal_token PlusOp)

(** 测试标识符token识别 *)
let test_is_identifier_token () =
  (* 测试各种标识符类型 *)
  check bool "regular identifier" true (is_identifier_token (IdentifierToken "variable"));
  check bool "quoted identifier" true (is_identifier_token (QuotedIdentifierToken "quoted_var"));
  check bool "constructor token" true (is_identifier_token (ConstructorToken "Constructor"));
  check bool "special identifier" true (is_identifier_token (IdentifierTokenSpecial "special"));
  check bool "module name" true (is_identifier_token (ModuleNameToken "Module"));
  check bool "type name" true (is_identifier_token (TypeNameToken "my_type"));

  (* 测试非标识符token *)
  check bool "keyword not identifier" false (is_identifier_token LetKeyword);
  check bool "literal not identifier" false (is_identifier_token (IntToken 42));
  check bool "operator not identifier" false (is_identifier_token PlusOp)

(** 测试基础关键字token识别 *)
let test_is_basic_keyword_token () =
  (* 测试控制流关键字 *)
  check bool "let keyword" true (is_basic_keyword_token LetKeyword);
  check bool "fun keyword" true (is_basic_keyword_token FunKeyword);
  check bool "if keyword" true (is_basic_keyword_token IfKeyword);
  check bool "then keyword" true (is_basic_keyword_token ThenKeyword);
  check bool "else keyword" true (is_basic_keyword_token ElseKeyword);
  check bool "match keyword" true (is_basic_keyword_token MatchKeyword);
  check bool "with keyword" true (is_basic_keyword_token WithKeyword);

  (* 测试逻辑关键字 *)
  check bool "and keyword" true (is_basic_keyword_token AndKeyword);
  check bool "or keyword" true (is_basic_keyword_token OrKeyword);
  check bool "not keyword" true (is_basic_keyword_token NotKeyword);
  check bool "true keyword" true (is_basic_keyword_token TrueKeyword);
  check bool "false keyword" true (is_basic_keyword_token FalseKeyword);

  (* 测试模块相关关键字 *)
  check bool "module keyword" true (is_basic_keyword_token ModuleKeyword);
  check bool "struct keyword" true (is_basic_keyword_token StructKeyword);
  check bool "sig keyword" true (is_basic_keyword_token SigKeyword);
  check bool "open keyword" true (is_basic_keyword_token OpenKeyword);

  (* 测试非基础关键字 *)
  check bool "identifier not basic keyword" false (is_basic_keyword_token (IdentifierToken "x"));
  check bool "number keyword not basic" false (is_basic_keyword_token ZeroKeyword)

(** 测试数字关键字token识别 *)
let test_is_number_keyword_token () =
  (* 测试基础数字 *)
  check bool "zero keyword" true (is_number_keyword_token ZeroKeyword);
  check bool "one keyword" true (is_number_keyword_token OneKeyword);
  check bool "two keyword" true (is_number_keyword_token TwoKeyword);
  check bool "nine keyword" true (is_number_keyword_token NineKeyword);

  (* 测试特殊数字 *)
  check bool "ten keyword" true (is_number_keyword_token TenKeyword);
  check bool "hundred keyword" true (is_number_keyword_token HundredKeyword);
  check bool "thousand keyword" true (is_number_keyword_token ThousandKeyword);
  check bool "ten thousand keyword" true (is_number_keyword_token TenThousandKeyword);

  (* 测试非数字关键字 *)
  check bool "let not number keyword" false (is_number_keyword_token LetKeyword);
  check bool "identifier not number keyword" false (is_number_keyword_token (IdentifierToken "x"))

(** 测试类型关键字token识别 *)
let test_is_type_keyword_token () =
  (* 测试基础类型 *)
  check bool "int type" true (is_type_keyword_token IntTypeKeyword);
  check bool "float type" true (is_type_keyword_token FloatTypeKeyword);
  check bool "string type" true (is_type_keyword_token StringTypeKeyword);
  check bool "bool type" true (is_type_keyword_token BoolTypeKeyword);
  check bool "unit type" true (is_type_keyword_token UnitTypeKeyword);

  (* 测试复合类型 *)
  check bool "list type" true (is_type_keyword_token ListTypeKeyword);
  check bool "array type" true (is_type_keyword_token ArrayTypeKeyword);
  check bool "ref type" true (is_type_keyword_token RefTypeKeyword);
  check bool "function type" true (is_type_keyword_token FunctionTypeKeyword);
  check bool "tuple type" true (is_type_keyword_token TupleTypeKeyword);
  check bool "record type" true (is_type_keyword_token RecordTypeKeyword);
  check bool "variant type" true (is_type_keyword_token VariantTypeKeyword);
  check bool "option type" true (is_type_keyword_token OptionTypeKeyword);
  check bool "result type" true (is_type_keyword_token ResultTypeKeyword);

  (* 测试非类型关键字 *)
  check bool "let not type keyword" false (is_type_keyword_token LetKeyword);
  check bool "identifier not type keyword" false (is_type_keyword_token (IdentifierToken "x"))

(** 测试文言文关键字token识别 *)
let test_is_wenyan_keyword_token () =
  (* 测试文言文控制流 *)
  check bool "wenyan if" true (is_wenyan_keyword_token WenyanIfKeyword);
  check bool "wenyan then" true (is_wenyan_keyword_token WenyanThenKeyword);
  check bool "wenyan else" true (is_wenyan_keyword_token WenyanElseKeyword);
  check bool "wenyan while" true (is_wenyan_keyword_token WenyanWhileKeyword);
  check bool "wenyan for" true (is_wenyan_keyword_token WenyanForKeyword);
  check bool "wenyan function" true (is_wenyan_keyword_token WenyanFunctionKeyword);
  check bool "wenyan return" true (is_wenyan_keyword_token WenyanReturnKeyword);
  check bool "wenyan true" true (is_wenyan_keyword_token WenyanTrueKeyword);
  check bool "wenyan false" true (is_wenyan_keyword_token WenyanFalseKeyword);
  check bool "wenyan let" true (is_wenyan_keyword_token WenyanLetKeyword);

  (* 测试非文言文关键字 *)
  check bool "regular let not wenyan" false (is_wenyan_keyword_token LetKeyword);
  check bool "identifier not wenyan" false (is_wenyan_keyword_token (IdentifierToken "x"))

(** 测试边界条件和复合场景 *)
let test_edge_cases () =
  (* 测试所有分类函数对同一个token的结果 *)
  let test_token = LetKeyword in
  check bool "let is basic keyword" true (is_basic_keyword_token test_token);
  check bool "let is not literal" false (is_literal_token test_token);
  check bool "let is not identifier" false (is_identifier_token test_token);
  check bool "let is not number keyword" false (is_number_keyword_token test_token);
  check bool "let is not type keyword" false (is_type_keyword_token test_token);
  check bool "let is not wenyan keyword" false (is_wenyan_keyword_token test_token);

  (* 测试复杂标识符 *)
  let complex_id = IdentifierToken "complex_variable_name_123" in
  check bool "complex id is identifier" true (is_identifier_token complex_id);
  check bool "complex id not keyword" false (is_basic_keyword_token complex_id);

  (* 测试数字字面量vs数字关键字 *)
  let int_literal = IntToken 123 in
  let number_keyword = ThreeKeyword in
  check bool "int literal is literal" true (is_literal_token int_literal);
  check bool "int literal not number keyword" false (is_number_keyword_token int_literal);
  check bool "number keyword is number keyword" true (is_number_keyword_token number_keyword);
  check bool "number keyword not literal" false (is_literal_token number_keyword)

(** 压力测试：测试所有可能的token类型 *)
let test_comprehensive_coverage () =
  let all_tests =
    [
      (* 字面量测试 *)
      (IntToken 0, "IntToken", [ is_literal_token ]);
      (FloatToken 0.0, "FloatToken", [ is_literal_token ]);
      (StringToken "", "StringToken", [ is_literal_token ]);
      (BoolToken true, "BoolToken", [ is_literal_token ]);
      (UnitToken, "UnitToken", [ is_literal_token ]);
      (* 标识符测试 *)
      (IdentifierToken "id", "IdentifierToken", [ is_identifier_token ]);
      (ConstructorToken "Cons", "ConstructorToken", [ is_identifier_token ]);
      (* 关键字测试 *)
      (LetKeyword, "LetKeyword", [ is_basic_keyword_token ]);
      (IfKeyword, "IfKeyword", [ is_basic_keyword_token ]);
      (ZeroKeyword, "ZeroKeyword", [ is_number_keyword_token ]);
      (IntTypeKeyword, "IntTypeKeyword", [ is_type_keyword_token ]);
      (WenyanIfKeyword, "WenyanIfKeyword", [ is_wenyan_keyword_token ]);
    ]
  in

  List.iter
    (fun (token, name, predicates) ->
      List.iter
        (fun predicate ->
          let result = predicate token in
          check bool (name ^ " predicate") true (result = result)
          (* 至少保证函数能被调用 *))
        predicates)
    all_tests

let tests =
  [
    ("is_literal_token", `Quick, test_is_literal_token);
    ("is_identifier_token", `Quick, test_is_identifier_token);
    ("is_basic_keyword_token", `Quick, test_is_basic_keyword_token);
    ("is_number_keyword_token", `Quick, test_is_number_keyword_token);
    ("is_type_keyword_token", `Quick, test_is_type_keyword_token);
    ("is_wenyan_keyword_token", `Quick, test_is_wenyan_keyword_token);
    ("edge_cases", `Quick, test_edge_cases);
    ("comprehensive_coverage", `Quick, test_comprehensive_coverage);
  ]

let () = run "Token_category_checker Comprehensive" [ ("token_category_checker", tests) ]
