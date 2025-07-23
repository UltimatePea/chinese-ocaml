(** 骆言词法分析器Token模块功能测试 - Functional Test for Lexer Tokens Module *)

open Alcotest
open Yyocamlc_lib.Lexer_tokens

(** 测试1: Token的show_token功能是否正常工作 *)
let test_show_token_not_empty () =
  let tokens = [
    IntToken 42;
    FloatToken 3.14;
    StringToken "测试";
    BoolToken true;
    LetKeyword;
    RecKeyword;
    QuotedIdentifierToken "变量"
  ] in
  List.iteri (fun i token ->
    let result = show_token token in
    check bool ("Token " ^ string_of_int i ^ " show_token非空") true (String.length result > 0)
  ) tokens

(** 测试2: Token相等性功能 *)
let test_token_equality_functional () =
  (* 相同token应该相等 *)
  let same_pairs = [
    (IntToken 42, IntToken 42);
    (FloatToken 3.14, FloatToken 3.14);
    (StringToken "test", StringToken "test");
    (BoolToken true, BoolToken true);
    (BoolToken false, BoolToken false);
    (LetKeyword, LetKeyword);
    (RecKeyword, RecKeyword);
    (QuotedIdentifierToken "var", QuotedIdentifierToken "var");
    (IdentifierTokenSpecial "数值", IdentifierTokenSpecial "数值");
  ] in
  List.iteri (fun i (t1, t2) ->
    check bool ("相同token对 " ^ string_of_int i ^ " 相等") true (equal_token t1 t2)
  ) same_pairs;
  
  (* 不同token应该不相等 *)
  let different_pairs = [
    (IntToken 42, IntToken 24);
    (FloatToken 3.14, FloatToken 2.71);
    (StringToken "test1", StringToken "test2");
    (BoolToken true, BoolToken false);
    (LetKeyword, RecKeyword);
    (IntToken 42, StringToken "42");
    (QuotedIdentifierToken "var1", QuotedIdentifierToken "var2");
  ] in
  List.iteri (fun i (t1, t2) ->
    check bool ("不同token对 " ^ string_of_int i ^ " 不相等") false (equal_token t1 t2)
  ) different_pairs

(** 测试3: 字面量Token类型创建和检查 *)
let test_literal_tokens () =
  let int_token = IntToken 100 in
  let float_token = FloatToken 99.99 in
  let string_token = StringToken "骆言" in
  let chinese_num_token = ChineseNumberToken "一二三" in
  let bool_true_token = BoolToken true in
  let bool_false_token = BoolToken false in
  
  (* 验证token能够正确创建并且show_token能返回非空字符串 *)
  let tokens = [int_token; float_token; string_token; chinese_num_token; bool_true_token; bool_false_token] in
  List.iter (fun token ->
    let shown = show_token token in
    check bool "字面量token显示非空" true (String.length shown > 0)
  ) tokens

(** 测试4: 标识符Token类型 *)
let test_identifier_tokens () =
  let quoted_id = QuotedIdentifierToken "测试变量" in
  let special_id = IdentifierTokenSpecial "特殊标识符" in
  
  check bool "引用标识符相等性" true (equal_token quoted_id (QuotedIdentifierToken "测试变量"));
  check bool "特殊标识符相等性" true (equal_token special_id (IdentifierTokenSpecial "特殊标识符"));
  check bool "不同标识符不相等" false (equal_token quoted_id special_id)

(** 测试5: 基础关键字Token *)
let test_basic_keywords () =
  let keywords = [
    LetKeyword; RecKeyword; InKeyword; FunKeyword; IfKeyword; 
    ThenKeyword; ElseKeyword; MatchKeyword; WithKeyword; OtherKeyword;
    TypeKeyword; PrivateKeyword; TrueKeyword; FalseKeyword
  ] in
  
  (* 验证每个关键字都能正确显示 *)
  List.iter (fun keyword ->
    let shown = show_token keyword in
    check bool "关键字显示非空" true (String.length shown > 0)
  ) keywords;
  
  (* 验证相同关键字相等 *)
  check bool "Let关键字相等" true (equal_token LetKeyword LetKeyword);
  check bool "不同关键字不相等" false (equal_token LetKeyword RecKeyword)

(** 测试6: 逻辑运算关键字 *)
let test_logical_keywords () =
  let logical_keywords = [AndKeyword; OrKeyword; NotKeyword] in
  
  List.iter (fun keyword ->
    let shown = show_token keyword in
    check bool "逻辑关键字显示非空" true (String.length shown > 0)
  ) logical_keywords;
  
  check bool "And关键字相等" true (equal_token AndKeyword AndKeyword);
  check bool "不同逻辑关键字不相等" false (equal_token AndKeyword OrKeyword)

(** 测试7: 语义类型系统关键字 *)
let test_semantic_keywords () =
  let semantic_keywords = [AsKeyword; CombineKeyword; WithOpKeyword; WhenKeyword] in
  
  List.iter (fun keyword ->
    let shown = show_token keyword in
    check bool "语义关键字显示非空" true (String.length shown > 0)
  ) semantic_keywords

(** 测试8: 错误恢复关键字 *)
let test_error_recovery_keywords () =
  let error_keywords = [OrElseKeyword; WithDefaultKeyword] in
  
  List.iter (fun keyword ->
    let shown = show_token keyword in
    check bool "错误恢复关键字显示非空" true (String.length shown > 0)
  ) error_keywords

(** 测试9: 异常处理关键字 *)
let test_exception_keywords () =
  let exception_keywords = [ExceptionKeyword; RaiseKeyword; TryKeyword; CatchKeyword; FinallyKeyword] in
  
  List.iter (fun keyword ->
    let shown = show_token keyword in
    check bool "异常处理关键字显示非空" true (String.length shown > 0)
  ) exception_keywords

(** 测试10: 模块系统关键字 *)
let test_module_keywords () =
  let module_keywords = [
    ModuleKeyword; ModuleTypeKeyword; SigKeyword; EndKeyword; 
    FunctorKeyword; IncludeKeyword; RefKeyword
  ] in
  
  List.iter (fun keyword ->
    let shown = show_token keyword in
    check bool "模块系统关键字显示非空" true (String.length shown > 0)
  ) module_keywords

(** 测试11: 宏系统关键字 *)
let test_macro_keywords () =
  let macro_keywords = [MacroKeyword; ExpandKeyword] in
  
  List.iter (fun keyword ->
    let shown = show_token keyword in
    check bool "宏系统关键字显示非空" true (String.length shown > 0)
  ) macro_keywords

(** 测试12: 文言文风格关键字 *)
let test_wenyan_keywords () =
  let wenyan_keywords = [
    HaveKeyword; OneKeyword; NameKeyword; SetKeyword; AlsoKeyword;
    ThenGetKeyword; CallKeyword; ValueKeyword; AsForKeyword; NumberKeyword
  ] in
  
  List.iter (fun keyword ->
    let shown = show_token keyword in
    check bool "文言文关键字显示非空" true (String.length shown > 0)
  ) wenyan_keywords

(** 测试13: 文言文扩展关键字 *)
let test_wenyan_extended_keywords () =
  let wenyan_ext_keywords = [
    WantExecuteKeyword; MustFirstGetKeyword; ForThisKeyword; TimesKeyword;
    EndCloudKeyword; IfWenyanKeyword; ThenWenyanKeyword; GreaterThanWenyan; LessThanWenyan
  ] in
  
  List.iter (fun keyword ->
    let shown = show_token keyword in
    check bool "文言文扩展关键字显示非空" true (String.length shown > 0)
  ) wenyan_ext_keywords

(** 测试14: 古雅体关键字 *)
let test_ancient_keywords () =
  let ancient_keywords = [
    AncientDefineKeyword; AncientEndKeyword; AncientAlgorithmKeyword; AncientCompleteKeyword;
    AncientObserveKeyword; AncientNatureKeyword; AncientIfKeyword; AncientThenKeyword;
    AncientOtherwiseKeyword; AncientAnswerKeyword; AncientRecursiveKeyword; AncientCombineKeyword;
    AncientAsOneKeyword; AncientTakeKeyword; AncientReceiveKeyword; AncientParticleOf; AncientParticleFun
  ] in
  
  List.iter (fun keyword ->
    let shown = show_token keyword in
    check bool "古雅体关键字显示非空" true (String.length shown > 0)
  ) ancient_keywords

(** 测试15: 边界情况处理 *)
let test_edge_cases () =
  (* 空字符串 *)
  let empty_string_token = StringToken "" in
  check bool "空字符串token显示非空" true (String.length (show_token empty_string_token) > 0);
  
  (* 零值 *)
  let zero_int_token = IntToken 0 in
  let zero_float_token = FloatToken 0.0 in
  check bool "零值int token显示非空" true (String.length (show_token zero_int_token) > 0);
  check bool "零值float token显示非空" true (String.length (show_token zero_float_token) > 0);
  
  (* 负数 *)
  let negative_int_token = IntToken (-42) in
  let negative_float_token = FloatToken (-3.14) in
  check bool "负数int token显示非空" true (String.length (show_token negative_int_token) > 0);
  check bool "负数float token显示非空" true (String.length (show_token negative_float_token) > 0);
  
  (* 相等性测试 *)
  check bool "零值相等" true (equal_token zero_int_token (IntToken 0));
  check bool "负数相等" true (equal_token negative_int_token (IntToken (-42)))

(** 测试16: Token类型区分 *)
let test_token_type_distinction () =
  let tokens = [
    IntToken 42;
    FloatToken 42.0;
    StringToken "42";
    BoolToken true;
    LetKeyword;
    QuotedIdentifierToken "42";
    ChineseNumberToken "四十二"
  ] in
  
  (* 验证不同类型的token都不相等 *)
  for i = 0 to List.length tokens - 1 do
    for j = i + 1 to List.length tokens - 1 do
      let token1 = List.nth tokens i in
      let token2 = List.nth tokens j in
      check bool (Printf.sprintf "不同类型token %d-%d 不相等" i j) false (equal_token token1 token2)
    done
  done

(** 测试套件定义和运行 *)
let lexer_tokens_functional_tests = [
  ("show_token功能正常", `Quick, test_show_token_not_empty);
  ("Token相等性功能", `Quick, test_token_equality_functional);
  ("字面量Token类型", `Quick, test_literal_tokens);
  ("标识符Token类型", `Quick, test_identifier_tokens);
  ("基础关键字Token", `Quick, test_basic_keywords);
  ("逻辑运算关键字", `Quick, test_logical_keywords);
  ("语义类型系统关键字", `Quick, test_semantic_keywords);
  ("错误恢复关键字", `Quick, test_error_recovery_keywords);
  ("异常处理关键字", `Quick, test_exception_keywords);
  ("模块系统关键字", `Quick, test_module_keywords);
  ("宏系统关键字", `Quick, test_macro_keywords);
  ("文言文风格关键字", `Quick, test_wenyan_keywords);
  ("文言文扩展关键字", `Quick, test_wenyan_extended_keywords);
  ("古雅体关键字", `Quick, test_ancient_keywords);
  ("边界情况处理", `Quick, test_edge_cases);
  ("Token类型区分", `Quick, test_token_type_distinction);
]

let () =
  run "Lexer_tokens模块功能测试" [
    ("Lexer Tokens Functional", lexer_tokens_functional_tests);
  ]