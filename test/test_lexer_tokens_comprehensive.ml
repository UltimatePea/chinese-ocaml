(** 骆言词法令牌模块综合测试套件 - Fix #1009 Phase 2 核心模块测试覆盖率提升 *)

open Alcotest
open Yyocamlc_lib.Lexer_tokens

(** 测试辅助工具模块 *)
module TestHelpers = struct
  (** 创建位置信息 *)
  let make_pos line column filename = { line; column; filename }

  (** 创建带位置的token *)
  let make_positioned_token token line column filename =
    (token, make_pos line column filename)

  (** 比较两个token是否相等 *)
  let tokens_equal t1 t2 = equal_token t1 t2

  (** 比较位置信息是否相等 *)
  let positions_equal p1 p2 = equal_position p1 p2

  (** 比较带位置token是否相等 *)
  let positioned_tokens_equal pt1 pt2 = equal_positioned_token pt1 pt2
end

(** 1. 基本字面量token测试 *)

let test_literal_tokens () =
  (* 整数token *)
  let int_token = IntToken 42 in
  check bool "整数token创建" true (TestHelpers.tokens_equal int_token (IntToken 42));
  check bool "不同整数token" false (TestHelpers.tokens_equal int_token (IntToken 24));
  
  (* 浮点数token *)
  let float_token = FloatToken 3.14 in
  check bool "浮点数token创建" true (TestHelpers.tokens_equal float_token (FloatToken 3.14));
  
  (* 中文数字token *)
  let chinese_token = ChineseNumberToken "五" in
  check bool "中文数字token创建" true (TestHelpers.tokens_equal chinese_token (ChineseNumberToken "五"));
  
  (* 字符串token *)
  let string_token = StringToken "hello" in
  check bool "字符串token创建" true (TestHelpers.tokens_equal string_token (StringToken "hello"));
  
  (* 布尔token *)
  let bool_token = BoolToken true in
  check bool "布尔token创建" true (TestHelpers.tokens_equal bool_token (BoolToken true));
  check bool "不同布尔值" false (TestHelpers.tokens_equal bool_token (BoolToken false))

let test_identifier_tokens () =
  (* 引用标识符token *)
  let quoted_id = QuotedIdentifierToken "变量名" in
  check bool "引用标识符token" true (TestHelpers.tokens_equal quoted_id (QuotedIdentifierToken "变量名"));
  
  (* 特殊标识符token *)
  let special_id = IdentifierTokenSpecial "数值" in
  check bool "特殊标识符token" true (TestHelpers.tokens_equal special_id (IdentifierTokenSpecial "数值"));
  
  (* 不同标识符不相等 *)
  check bool "不同引用标识符" false (TestHelpers.tokens_equal quoted_id (QuotedIdentifierToken "其他名称"))

(** 2. 基础关键字token测试 *)

let test_basic_keywords () =
  (* 基础语言关键字 *)
  let keywords = [
    (LetKeyword, "Let关键字");
    (RecKeyword, "Rec关键字");
    (InKeyword, "In关键字");
    (FunKeyword, "Fun关键字");
    (IfKeyword, "If关键字");
    (ThenKeyword, "Then关键字");
    (ElseKeyword, "Else关键字");
    (MatchKeyword, "Match关键字");
    (WithKeyword, "With关键字");
    (TypeKeyword, "Type关键字");
    (TrueKeyword, "True关键字");
    (FalseKeyword, "False关键字");
    (AndKeyword, "And关键字");
    (OrKeyword, "Or关键字");
    (NotKeyword, "Not关键字");
  ] in
  
  List.iter (fun (token, desc) ->
    check bool desc true (TestHelpers.tokens_equal token token)
  ) keywords;
  
  (* 测试关键字不相等 *)
  check bool "不同关键字不相等" false (TestHelpers.tokens_equal LetKeyword FunKeyword)

let test_semantic_keywords () =
  (* 语义类型系统关键字 *)
  let semantic_keywords = [
    (AsKeyword, "As关键字");
    (CombineKeyword, "Combine关键字");
    (WithOpKeyword, "WithOp关键字");
    (WhenKeyword, "When关键字");
  ] in
  
  List.iter (fun (token, desc) ->
    check bool desc true (TestHelpers.tokens_equal token token)
  ) semantic_keywords

let test_exception_keywords () =
  (* 异常处理关键字 *)
  let exception_keywords = [
    (ExceptionKeyword, "Exception关键字");
    (RaiseKeyword, "Raise关键字");
    (TryKeyword, "Try关键字");
    (CatchKeyword, "Catch关键字");
    (FinallyKeyword, "Finally关键字");
  ] in
  
  List.iter (fun (token, desc) ->
    check bool desc true (TestHelpers.tokens_equal token token)
  ) exception_keywords

(** 3. 模块系统关键字测试 *)

let test_module_keywords () =
  let module_keywords = [
    (ModuleKeyword, "Module关键字");
    (ModuleTypeKeyword, "ModuleType关键字");
    (SigKeyword, "Sig关键字");
    (EndKeyword, "End关键字");
    (FunctorKeyword, "Functor关键字");
    (IncludeKeyword, "Include关键字");
  ] in
  
  List.iter (fun (token, desc) ->
    check bool desc true (TestHelpers.tokens_equal token token)
  ) module_keywords

(** 4. 文言文风格关键字测试 *)

let test_wenyan_keywords () =
  let wenyan_keywords = [
    (HaveKeyword, "Have关键字（吾有）");
    (OneKeyword, "One关键字（一）");
    (NameKeyword, "Name关键字（名曰）");
    (SetKeyword, "Set关键字（设）");
    (AlsoKeyword, "Also关键字（也）");
    (ThenGetKeyword, "ThenGet关键字（乃）");
    (CallKeyword, "Call关键字（曰）");
    (ValueKeyword, "Value关键字（其值）");
    (AsForKeyword, "AsFor关键字（为）");
    (NumberKeyword, "Number关键字（数）");
  ] in
  
  List.iter (fun (token, desc) ->
    check bool desc true (TestHelpers.tokens_equal token token)
  ) wenyan_keywords

let test_wenyan_extended_keywords () =
  let extended_keywords = [
    (WantExecuteKeyword, "WantExecute关键字（欲行）");
    (MustFirstGetKeyword, "MustFirstGet关键字（必先得）");
    (ForThisKeyword, "ForThis关键字（為是）");
    (TimesKeyword, "Times关键字（遍）");
    (EndCloudKeyword, "EndCloud关键字（云云）");
    (IfWenyanKeyword, "IfWenyan关键字（若）");
    (ThenWenyanKeyword, "ThenWenyan关键字（者）");
    (GreaterThanWenyan, "GreaterThanWenyan（大于）");
    (LessThanWenyan, "LessThanWenyan（小于）");
  ] in
  
  List.iter (fun (token, desc) ->
    check bool desc true (TestHelpers.tokens_equal token token)
  ) extended_keywords

(** 5. 古雅体关键字测试 *)

let test_ancient_keywords () =
  let ancient_keywords = [
    (AncientDefineKeyword, "AncientDefine关键字（夫...者）");
    (AncientEndKeyword, "AncientEnd关键字（也）");
    (AncientAlgorithmKeyword, "AncientAlgorithm关键字（算法）");
    (AncientCompleteKeyword, "AncientComplete关键字（竟）");
    (AncientObserveKeyword, "AncientObserve关键字（观）");
    (AncientNatureKeyword, "AncientNature关键字（性）");
    (AncientIfKeyword, "AncientIf关键字（若）");
    (AncientThenKeyword, "AncientThen关键字（则）");
    (AncientOtherwiseKeyword, "AncientOtherwise关键字（余者）");
    (AncientAnswerKeyword, "AncientAnswer关键字（答）");
  ] in
  
  List.iter (fun (token, desc) ->
    check bool desc true (TestHelpers.tokens_equal token token)
  ) ancient_keywords

let test_ancient_particles () =
  let ancient_particles = [
    (AncientParticleOf, "AncientParticleOf（之）");
    (AncientParticleFun, "AncientParticleFun（焉）");
    (AncientParticleThe, "AncientParticleThe（其）");
    (AncientCallItKeyword, "AncientCallIt关键字（名曰）");
  ] in
  
  List.iter (fun (token, desc) ->
    check bool desc true (TestHelpers.tokens_equal token token)
  ) ancient_particles

let test_ancient_record_keywords () =
  let ancient_record_keywords = [
    (AncientRecordStartKeyword, "AncientRecordStart关键字（据开始）");
    (AncientRecordEndKeyword, "AncientRecordEnd关键字（据结束）");
    (AncientRecordEmptyKeyword, "AncientRecordEmpty关键字（据空）");
    (AncientRecordUpdateKeyword, "AncientRecordUpdate关键字（据更新）");
    (AncientRecordFinishKeyword, "AncientRecordFinish关键字（据毕）");
  ] in
  
  List.iter (fun (token, desc) ->
    check bool desc true (TestHelpers.tokens_equal token token)
  ) ancient_record_keywords

(** 6. 自然语言函数定义关键字测试 *)

let test_natural_language_keywords () =
  let natural_keywords = [
    (DefineKeyword, "Define关键字（定义）");
    (AcceptKeyword, "Accept关键字（接受）");
    (ReturnWhenKeyword, "ReturnWhen关键字（时返回）");
    (ElseReturnKeyword, "ElseReturn关键字（否则返回）");
    (MultiplyKeyword, "Multiply关键字（乘以）");
    (DivideKeyword, "Divide关键字（除以）");
    (AddToKeyword, "AddTo关键字（加上）");
    (SubtractKeyword, "Subtract关键字（减去）");
    (IsKeyword, "Is关键字（为）");
    (EqualToKeyword, "EqualTo关键字（等于）");
  ] in
  
  List.iter (fun (token, desc) ->
    check bool desc true (TestHelpers.tokens_equal token token)
  ) natural_keywords

let test_natural_language_extended () =
  let extended_natural = [
    (LessThanEqualToKeyword, "LessThanEqualTo关键字（小于等于）");
    (FirstElementKeyword, "FirstElement关键字（首元素）");
    (RemainingKeyword, "Remaining关键字（剩余）");
    (EmptyKeyword, "Empty关键字（空）");
    (CharacterCountKeyword, "CharacterCount关键字（字符数量）");
    (InputKeyword, "Input关键字（输入）");
    (OutputKeyword, "Output关键字（输出）");
    (MinusOneKeyword, "MinusOne关键字（减一）");
    (PlusKeyword, "Plus关键字（加）");
    (SmallKeyword, "Small关键字（小）");
    (ShouldGetKeyword, "ShouldGet关键字（应得）");
  ] in
  
  List.iter (fun (token, desc) ->
    check bool desc true (TestHelpers.tokens_equal token token)
  ) extended_natural

(** 7. 类型关键字测试 *)

let test_type_keywords () =
  let type_keywords = [
    (IntTypeKeyword, "IntType关键字（整数）");
    (FloatTypeKeyword, "FloatType关键字（浮点数）");
    (StringTypeKeyword, "StringType关键字（字符串）");
    (BoolTypeKeyword, "BoolType关键字（布尔）");
    (UnitTypeKeyword, "UnitType关键字（单元）");
    (ListTypeKeyword, "ListType关键字（列表）");
    (ArrayTypeKeyword, "ArrayType关键字（数组）");
    (VariantKeyword, "Variant关键字（变体）");
    (TagKeyword, "Tag关键字（标签）");
  ] in
  
  List.iter (fun (token, desc) ->
    check bool desc true (TestHelpers.tokens_equal token token)
  ) type_keywords

(** 8. 古典诗词相关关键字测试 *)

let test_poetry_keywords () =
  let poetry_keywords = [
    (RhymeKeyword, "Rhyme关键字（韵）");
    (ToneKeyword, "Tone关键字（调）");
    (ToneLevelKeyword, "ToneLevel关键字（平）");
    (ToneFallingKeyword, "ToneFalling关键字（仄）");
    (ToneRisingKeyword, "ToneRising关键字（上）");
    (ToneDepartingKeyword, "ToneDeparting关键字（去）");
    (ToneEnteringKeyword, "ToneEntering关键字（入）");
    (ParallelKeyword, "Parallel关键字（对）");
    (PairedKeyword, "Paired关键字（偶）");
    (AntitheticKeyword, "Antithetic关键字（反）");
    (BalancedKeyword, "Balanced关键字（衡）");
  ] in
  
  List.iter (fun (token, desc) ->
    check bool desc true (TestHelpers.tokens_equal token token)
  ) poetry_keywords

let test_poetry_forms () =
  let poetry_forms = [
    (PoetryKeyword, "Poetry关键字（诗）");
    (FourCharKeyword, "FourChar关键字（四言）");
    (FiveCharKeyword, "FiveChar关键字（五言）");
    (SevenCharKeyword, "SevenChar关键字（七言）");
    (ParallelStructKeyword, "ParallelStruct关键字（骈体）");
    (RegulatedVerseKeyword, "RegulatedVerse关键字（律诗）");
    (QuatrainKeyword, "Quatrain关键字（绝句）");
    (CoupletKeyword, "Couplet关键字（对联）");
    (AntithesisKeyword, "Antithesis关键字（对仗）");
    (MeterKeyword, "Meter关键字（韵律）");
    (CadenceKeyword, "Cadence关键字（音律）");
  ] in
  
  List.iter (fun (token, desc) ->
    check bool desc true (TestHelpers.tokens_equal token token)
  ) poetry_forms

(** 9. 运算符token测试 *)

let test_arithmetic_operators () =
  let arithmetic_ops = [
    (Plus, "Plus运算符（+）");
    (Minus, "Minus运算符（-）");
    (Multiply, "Multiply运算符（*）");
    (Star, "Star运算符（*别名）");
    (Divide, "Divide运算符（/）");
    (Slash, "Slash运算符（/别名）");
    (Modulo, "Modulo运算符（%）");
    (Concat, "Concat运算符（^）");
  ] in
  
  List.iter (fun (token, desc) ->
    check bool desc true (TestHelpers.tokens_equal token token)
  ) arithmetic_ops;
  
  (* 测试别名tokens *)
  check bool "Star和Multiply是不同token" false (TestHelpers.tokens_equal Star Multiply);
  check bool "Slash和Divide是不同token" false (TestHelpers.tokens_equal Slash Divide)

let test_comparison_operators () =
  let comparison_ops = [
    (Assign, "Assign运算符（=）");
    (Equal, "Equal运算符（==）");
    (NotEqual, "NotEqual运算符（<>）");
    (Less, "Less运算符（<）");
    (LessEqual, "LessEqual运算符（<=）");
    (Greater, "Greater运算符（>）");
    (GreaterEqual, "GreaterEqual运算符（>=）");
  ] in
  
  List.iter (fun (token, desc) ->
    check bool desc true (TestHelpers.tokens_equal token token)
  ) comparison_ops

let test_special_operators () =
  let special_ops = [
    (Arrow, "Arrow运算符（->）");
    (DoubleArrow, "DoubleArrow运算符（=>）");
    (Dot, "Dot运算符（.）");
    (DoubleDot, "DoubleDot运算符（..）");
    (TripleDot, "TripleDot运算符（...）");
    (Bang, "Bang运算符（!）");
    (RefAssign, "RefAssign运算符（:=）");
    (AssignArrow, "AssignArrow运算符（<-）");
  ] in
  
  List.iter (fun (token, desc) ->
    check bool desc true (TestHelpers.tokens_equal token token)
  ) special_ops

(** 10. 分隔符token测试 *)

let test_ascii_separators () =
  let separators = [
    (LeftParen, "LeftParen（(）");
    (RightParen, "RightParen（)）");
    (LeftBracket, "LeftBracket（[）");
    (RightBracket, "RightBracket（]）");
    (LeftBrace, "LeftBrace（{）");
    (RightBrace, "RightBrace（}）");
    (Comma, "Comma（,）");
    (Semicolon, "Semicolon（;）");
    (Colon, "Colon（:）");
    (QuestionMark, "QuestionMark（?）");
    (Tilde, "Tilde（~）");
    (Pipe, "Pipe（|）");
    (Underscore, "Underscore（_）");
  ] in
  
  List.iter (fun (token, desc) ->
    check bool desc true (TestHelpers.tokens_equal token token)
  ) separators

let test_array_separators () =
  let array_separators = [
    (LeftArray, "LeftArray（[|）");
    (RightArray, "RightArray（|]）");
    (ChineseLeftArray, "ChineseLeftArray（「|）");
    (ChineseRightArray, "ChineseRightArray（|」）");
  ] in
  
  List.iter (fun (token, desc) ->
    check bool desc true (TestHelpers.tokens_equal token token)
  ) array_separators

(** 11. 中文标点符号token测试 *)

let test_chinese_punctuation () =
  let chinese_punct = [
    (ChineseLeftParen, "ChineseLeftParen（（）");
    (ChineseRightParen, "ChineseRightParen（））");
    (ChineseLeftBracket, "ChineseLeftBracket（「）");
    (ChineseRightBracket, "ChineseRightBracket（」）");
    (ChineseSquareLeftBracket, "ChineseSquareLeftBracket（【）");
    (ChineseSquareRightBracket, "ChineseSquareRightBracket（】）");
    (ChineseComma, "ChineseComma（，）");
    (ChineseSemicolon, "ChineseSemicolon（；）");
    (ChineseColon, "ChineseColon（：）");
    (ChineseDoubleColon, "ChineseDoubleColon（：：）");
    (ChinesePipe, "ChinesePipe（｜）");
  ] in
  
  List.iter (fun (token, desc) ->
    check bool desc true (TestHelpers.tokens_equal token token)
  ) chinese_punct

let test_chinese_arrows () =
  let chinese_arrows = [
    (ChineseArrow, "ChineseArrow（→）");
    (ChineseDoubleArrow, "ChineseDoubleArrow（⇒）");
    (ChineseAssignArrow, "ChineseAssignArrow（←）");
  ] in
  
  List.iter (fun (token, desc) ->
    check bool desc true (TestHelpers.tokens_equal token token)
  ) chinese_arrows;
  
  (* 测试中文和ASCII版本不相等 *)
  check bool "中文箭头与ASCII箭头不相等" false (TestHelpers.tokens_equal ChineseArrow Arrow);
  check bool "中文双箭头与ASCII双箭头不相等" false (TestHelpers.tokens_equal ChineseDoubleArrow DoubleArrow)

(** 12. 特殊token测试 *)

let test_special_tokens () =
  (* 特殊tokens *)
  check bool "Newline token" true (TestHelpers.tokens_equal Newline Newline);
  check bool "EOF token" true (TestHelpers.tokens_equal EOF EOF);
  
  (* 特殊tokens不相等 *)
  check bool "Newline与EOF不相等" false (TestHelpers.tokens_equal Newline EOF)

(** 13. 位置信息测试 *)

let test_position_creation () =
  let pos = TestHelpers.make_pos 10 5 "test.ly" in
  check int "位置行号" 10 pos.line;
  check int "位置列号" 5 pos.column;
  check string "文件名" "test.ly" pos.filename

let test_position_equality () =
  let pos1 = TestHelpers.make_pos 1 1 "file1.ly" in
  let pos2 = TestHelpers.make_pos 1 1 "file1.ly" in
  let pos3 = TestHelpers.make_pos 2 1 "file1.ly" in
  let pos4 = TestHelpers.make_pos 1 1 "file2.ly" in
  
  check bool "相同位置相等" true (TestHelpers.positions_equal pos1 pos2);
  check bool "不同行不相等" false (TestHelpers.positions_equal pos1 pos3);
  check bool "不同文件不相等" false (TestHelpers.positions_equal pos1 pos4)

(** 14. 带位置token测试 *)

let test_positioned_token_creation () =
  let token = IntToken 42 in
  let pos = TestHelpers.make_pos 5 10 "example.ly" in
  let positioned = TestHelpers.make_positioned_token token 5 10 "example.ly" in
  
  let (actual_token, actual_pos) = positioned in
  check bool "positioned token中的token" true (TestHelpers.tokens_equal actual_token token);
  check bool "positioned token中的位置" true (TestHelpers.positions_equal actual_pos pos)

let test_positioned_token_equality () =
  let pt1 = TestHelpers.make_positioned_token (IntToken 42) 1 1 "test.ly" in
  let pt2 = TestHelpers.make_positioned_token (IntToken 42) 1 1 "test.ly" in
  let pt3 = TestHelpers.make_positioned_token (IntToken 24) 1 1 "test.ly" in
  let pt4 = TestHelpers.make_positioned_token (IntToken 42) 2 1 "test.ly" in
  
  check bool "相同positioned token相等" true (TestHelpers.positioned_tokens_equal pt1 pt2);
  check bool "不同token不相等" false (TestHelpers.positioned_tokens_equal pt1 pt3);
  check bool "不同位置不相等" false (TestHelpers.positioned_tokens_equal pt1 pt4)

(** 15. 词法错误测试 *)

let test_lex_error () =
  let pos = TestHelpers.make_pos 3 7 "error.ly" in
  let error = LexError ("无效字符", pos) in
  
  (* 测试异常抛出和捕获 *)
  try
    (raise error : unit);
    fail "应该抛出异常"
  with LexError (msg, error_pos) ->
    check string "错误消息" "无效字符" msg;
    check bool "错误位置" true (TestHelpers.positions_equal error_pos pos)

(** 16. Token显示功能测试 *)

let test_token_show () =
  (* 测试show函数不会崩溃 *)
  let tokens_to_show = [
    IntToken 42;
    StringToken "test";
    QuotedIdentifierToken "变量";
    LetKeyword;
    Plus;
    LeftParen;
    ChineseLeftParen;
    EOF;
  ] in
  
  List.iter (fun token ->
    let shown = show_token token in
    check bool "show_token返回非空字符串" true (String.length shown > 0)
  ) tokens_to_show

let test_position_show () =
  let pos = TestHelpers.make_pos 1 1 "test.ly" in
  let shown = show_position pos in
  check bool "show_position返回非空字符串" true (String.length shown > 0)

let test_positioned_token_show () =
  let pt = TestHelpers.make_positioned_token (IntToken 42) 1 1 "test.ly" in
  let shown = show_positioned_token pt in
  check bool "show_positioned_token返回非空字符串" true (String.length shown > 0)

(** 17. 边界条件和压力测试 *)

let test_boundary_conditions () =
  (* 测试极值 *)
  let max_int_token = IntToken max_int in
  let min_int_token = IntToken min_int in
  check bool "最大整数token" true (TestHelpers.tokens_equal max_int_token (IntToken max_int));
  check bool "最小整数token" true (TestHelpers.tokens_equal min_int_token (IntToken min_int));
  
  (* 测试极长字符串 *)
  let long_string = String.make 10000 'a' in
  let long_string_token = StringToken long_string in
  check bool "长字符串token" true (TestHelpers.tokens_equal long_string_token (StringToken long_string));
  
  (* 测试空字符串 *)
  let empty_string_token = StringToken "" in
  check bool "空字符串token" true (TestHelpers.tokens_equal empty_string_token (StringToken ""))

let test_unicode_handling () =
  (* 测试Unicode字符串 *)
  let unicode_strings = [
    "你好世界";
    "🌟🎨🔥";
    "αβγδε";
    "中文编程语言";
    "古雅体诗词编程";
  ] in
  
  List.iter (fun unicode_str ->
    let unicode_token = StringToken unicode_str in
    check bool ("Unicode字符串: " ^ unicode_str) true (TestHelpers.tokens_equal unicode_token (StringToken unicode_str))
  ) unicode_strings

let test_performance () =
  (* 测试大量token创建 *)
  let tokens = Array.init 1000 (fun i -> IntToken i) in
  check int "大量token创建" 1000 (Array.length tokens);
  
  (* 测试token比较性能 *)
  let token1 = StringToken "performance_test" in
  let token2 = StringToken "performance_test" in
  let start_time = Sys.time () in
  for _i = 1 to 10000 do
    ignore (TestHelpers.tokens_equal token1 token2)
  done;
  let end_time = Sys.time () in
  let duration = end_time -. start_time in
  check bool "token比较性能测试" true (duration < 1.0) (* 应该在1秒内完成 *)

(** 测试套件定义 *)

let literal_tests = [
  test_case "literal_tokens" `Quick test_literal_tokens;
  test_case "identifier_tokens" `Quick test_identifier_tokens;
]

let keyword_tests = [
  test_case "basic_keywords" `Quick test_basic_keywords;
  test_case "semantic_keywords" `Quick test_semantic_keywords;
  test_case "exception_keywords" `Quick test_exception_keywords;
  test_case "module_keywords" `Quick test_module_keywords;
]

let wenyan_tests = [
  test_case "wenyan_keywords" `Quick test_wenyan_keywords;
  test_case "wenyan_extended_keywords" `Quick test_wenyan_extended_keywords;
]

let ancient_tests = [
  test_case "ancient_keywords" `Quick test_ancient_keywords;
  test_case "ancient_particles" `Quick test_ancient_particles;
  test_case "ancient_record_keywords" `Quick test_ancient_record_keywords;
]

let natural_language_tests = [
  test_case "natural_language_keywords" `Quick test_natural_language_keywords;
  test_case "natural_language_extended" `Quick test_natural_language_extended;
]

let type_tests = [
  test_case "type_keywords" `Quick test_type_keywords;
]

let poetry_tests = [
  test_case "poetry_keywords" `Quick test_poetry_keywords;
  test_case "poetry_forms" `Quick test_poetry_forms;
]

let operator_tests = [
  test_case "arithmetic_operators" `Quick test_arithmetic_operators;
  test_case "comparison_operators" `Quick test_comparison_operators;
  test_case "special_operators" `Quick test_special_operators;
]

let separator_tests = [
  test_case "ascii_separators" `Quick test_ascii_separators;
  test_case "array_separators" `Quick test_array_separators;
  test_case "chinese_punctuation" `Quick test_chinese_punctuation;
  test_case "chinese_arrows" `Quick test_chinese_arrows;
]

let special_tests = [
  test_case "special_tokens" `Quick test_special_tokens;
]

let position_tests = [
  test_case "position_creation" `Quick test_position_creation;
  test_case "position_equality" `Quick test_position_equality;
  test_case "positioned_token_creation" `Quick test_positioned_token_creation;
  test_case "positioned_token_equality" `Quick test_positioned_token_equality;
]

let error_tests = [
  test_case "lex_error" `Quick test_lex_error;
]

let show_tests = [
  test_case "token_show" `Quick test_token_show;
  test_case "position_show" `Quick test_position_show;
  test_case "positioned_token_show" `Quick test_positioned_token_show;
]

let boundary_tests = [
  test_case "boundary_conditions" `Quick test_boundary_conditions;
  test_case "unicode_handling" `Quick test_unicode_handling;
  test_case "performance" `Quick test_performance;
]

let () =
  run "骆言词法令牌模块综合测试" [
    "字面量tokens", literal_tests;
    "基础关键字", keyword_tests;
    "文言文风格关键字", wenyan_tests;
    "古雅体关键字", ancient_tests;
    "自然语言关键字", natural_language_tests;
    "类型关键字", type_tests;
    "诗词相关关键字", poetry_tests;
    "运算符tokens", operator_tests;
    "分隔符tokens", separator_tests;
    "特殊tokens", special_tests;
    "位置信息", position_tests;
    "错误处理", error_tests;
    "显示功能", show_tests;
    "边界条件和性能", boundary_tests;
  ]