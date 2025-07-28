(** 测试重构后的词法分析器模块 - 通过高层接口测试 *)

open Alcotest
open Yyocamlc_lib.Lexer

(* 测试辅助函数 *)
let check_token_types expected_types actual_tokens =
  let extract_tokens positioned_tokens = List.map fst positioned_tokens in
  let actual_types =
    List.map
      (fun token ->
        match token with
        | IntToken i -> "IntToken(" ^ string_of_int i ^ ")"
        | FloatToken f -> "FloatToken(" ^ string_of_float f ^ ")"
        | StringToken s -> "StringToken(\"" ^ s ^ "\")"
        | BoolToken b -> "BoolToken(" ^ string_of_bool b ^ ")"
        | QuotedIdentifierToken id -> "QuotedIdentifierToken(\"" ^ id ^ "\")"
        | LetKeyword -> "LetKeyword"
        | FunKeyword -> "FunKeyword"
        | IfKeyword -> "IfKeyword"
        | ThenKeyword -> "ThenKeyword"
        | ElseKeyword -> "ElseKeyword"
        | MatchKeyword -> "MatchKeyword"
        | WithKeyword -> "WithKeyword"
        | OtherKeyword -> "OtherKeyword"
        | TypeKeyword -> "TypeKeyword"
        | TrueKeyword -> "TrueKeyword"
        | FalseKeyword -> "FalseKeyword"
        | AndKeyword -> "AndKeyword"
        | OrKeyword -> "OrKeyword"
        | NotKeyword -> "NotKeyword"
        | HaveKeyword -> "HaveKeyword"
        | OneKeyword -> "OneKeyword"
        | NameKeyword -> "NameKeyword"
        | CallKeyword -> "CallKeyword"
        | AsForKeyword -> "AsForKeyword"
        | TimesKeyword -> "TimesKeyword"
        | IfWenyanKeyword -> "IfWenyanKeyword"
        | GreaterThanWenyan -> "GreaterThanWenyan"
        | LessThanWenyan -> "LessThanWenyan"
        | MultiplyKeyword -> "MultiplyKeyword"
        | DivideKeyword -> "DivideKeyword"
        | AddToKeyword -> "AddToKeyword"
        | SubtractKeyword -> "SubtractKeyword"
        | EqualToKeyword -> "EqualToKeyword"
        | LessThanEqualToKeyword -> "LessThanEqualToKeyword"
        | PlusKeyword -> "PlusKeyword"
        | WhereKeyword -> "WhereKeyword"
        | IntTypeKeyword -> "IntTypeKeyword"
        | FloatTypeKeyword -> "FloatTypeKeyword"
        | StringTypeKeyword -> "StringTypeKeyword"
        | BoolTypeKeyword -> "BoolTypeKeyword"
        | UnitTypeKeyword -> "UnitTypeKeyword"
        | ListTypeKeyword -> "ListTypeKeyword"
        | ArrayTypeKeyword -> "ArrayTypeKeyword"
        | AncientAlgorithmKeyword -> "AncientAlgorithmKeyword"
        | AncientRecordStartKeyword -> "AncientRecordStartKeyword"
        | AncientRecordEndKeyword -> "AncientRecordEndKeyword"
        | AncientRecordEmptyKeyword -> "AncientRecordEmptyKeyword"
        | AncientRecordUpdateKeyword -> "AncientRecordUpdateKeyword"
        | AncientRecordFinishKeyword -> "AncientRecordFinishKeyword"
        | ChineseLeftParen -> "ChineseLeftParen"
        | ChineseRightParen -> "ChineseRightParen"
        | ChineseComma -> "ChineseComma"
        | ChineseColon -> "ChineseColon"
        | Dot -> "Dot"
        | EOF -> "EOF"
        | Newline -> "Newline"
        | _ -> "OtherToken")
      (extract_tokens actual_tokens)
  in
  check (list string) "Token序列" expected_types actual_types

(* 测试关键字识别功能 - 验证Lexer_keywords模块 *)
let test_keyword_recognition () =
  let test_cases =
    [
      ("让", [ "LetKeyword"; "EOF" ]);
      ("函数", [ "FunKeyword"; "EOF" ]);
      ("如果", [ "IfKeyword"; "EOF" ]);
      ("那么", [ "ThenKeyword"; "EOF" ]);
      ("否则", [ "ElseKeyword"; "EOF" ]);
      ("匹配", [ "MatchKeyword"; "EOF" ]);
      ("与", [ "WithKeyword"; "EOF" ]);
      ("其他", [ "OtherKeyword"; "EOF" ]);
      ("类型", [ "TypeKeyword"; "EOF" ]);
      ("真", [ "BoolToken(true)"; "EOF" ]);
      ("假", [ "BoolToken(false)"; "EOF" ]);
      ("并且", [ "AndKeyword"; "EOF" ]);
      ("或者", [ "OrKeyword"; "EOF" ]);
      ("非", [ "NotKeyword"; "EOF" ]);
    ]
  in

  List.iter
    (fun (input, expected) ->
      let tokens = tokenize input "test.ly" in
      check_token_types expected tokens)
    test_cases

(* 测试文言文关键字识别 - 验证Lexer_keywords模块 *)
let test_wenyan_keyword_recognition () =
  let test_cases =
    [
      ("吾有", [ "HaveKeyword"; "EOF" ]);
      ("一", [ "OneKeyword"; "EOF" ]);
      ("名曰", [ "NameKeyword"; "EOF" ]);
      ("「呼」", [ "QuotedIdentifierToken(\"呼\")"; "EOF" ]);
      (* 单字符 "呼" 需要引用 *)
      ("为", [ "AsForKeyword"; "EOF" ]);
      ("「倍」", [ "QuotedIdentifierToken(\"倍\")"; "EOF" ]);
      (* 单字符 "倍" 需要引用 *)
      ("若", [ "IfWenyanKeyword"; "EOF" ]);
      ("大于", [ "GreaterThanWenyan"; "EOF" ]);
      ("小于", [ "LessThanWenyan"; "EOF" ]);
      ("其中", [ "WhereKeyword"; "EOF" ]);
    ]
  in

  List.iter
    (fun (input, expected) ->
      let tokens = tokenize input "test.ly" in
      check_token_types expected tokens)
    test_cases

(* 测试运算符关键字识别 - 验证Lexer_keywords模块 *)
let test_operator_keyword_recognition () =
  let test_cases =
    [
      ("乘以", [ "MultiplyKeyword"; "EOF" ]);
      ("除以", [ "DivideKeyword"; "EOF" ]);
      ("加上", [ "AddToKeyword"; "EOF" ]);
      ("减去", [ "SubtractKeyword"; "EOF" ]);
      ("等于", [ "EqualToKeyword"; "EOF" ]);
      ("小于等于", [ "LessThanEqualToKeyword"; "EOF" ]);
      ("加", [ "PlusKeyword"; "EOF" ]);
    ]
  in

  List.iter
    (fun (input, expected) ->
      let tokens = tokenize input "test.ly" in
      check_token_types expected tokens)
    test_cases

(* 测试类型关键字识别 - 验证Lexer_keywords模块 *)
let test_type_keyword_recognition () =
  let test_cases =
    [
      ("整数", [ "IntTypeKeyword"; "EOF" ]);
      ("浮点数", [ "FloatTypeKeyword"; "EOF" ]);
      ("字符串", [ "StringTypeKeyword"; "EOF" ]);
      ("布尔", [ "BoolTypeKeyword"; "EOF" ]);
      ("单元", [ "UnitTypeKeyword"; "EOF" ]);
      ("列表", [ "ListTypeKeyword"; "EOF" ]);
      ("数组", [ "ArrayTypeKeyword"; "EOF" ]);
    ]
  in

  List.iter
    (fun (input, expected) ->
      let tokens = tokenize input "test.ly" in
      check_token_types expected tokens)
    test_cases

(* 测试古雅体关键字识别 - 验证Lexer_keywords模块 *)
let test_ancient_keyword_recognition () =
  let test_cases =
    [
      ("算法", [ "AncientAlgorithmKeyword"; "EOF" ]);
      ("据开始", [ "AncientRecordStartKeyword"; "EOF" ]);
      ("据结束", [ "AncientRecordEndKeyword"; "EOF" ]);
      ("据空", [ "AncientRecordEmptyKeyword"; "EOF" ]);
      ("据更新", [ "AncientRecordUpdateKeyword"; "EOF" ]);
      ("据毕", [ "AncientRecordFinishKeyword"; "EOF" ]);
    ]
  in

  List.iter
    (fun (input, expected) ->
      let tokens = tokenize input "test.ly" in
      check_token_types expected tokens)
    test_cases

(* 测试字符串字面量解析 - 验证Lexer_parsers模块 *)
let test_string_literal_parsing () =
  let test_cases =
    [
      ("『你好世界』", [ "StringToken(\"你好世界\")"; "EOF" ]);
      ("『』", [ "StringToken(\"\")"; "EOF" ]);
      ("『包含\\n换行符』", [ "StringToken(\"包含\n换行符\")"; "EOF" ]);
      ("『包含\"引号\"』", [ "StringToken(\"包含\"引号\"\")"; "EOF" ]);
      ("『多行\n字符串』", [ "StringToken(\"多行\n字符串\")"; "EOF" ]);
      ("『Unicode: 😀🎉』", [ "StringToken(\"Unicode: 😀🎉\")"; "EOF" ]);
    ]
  in

  List.iter
    (fun (input, expected) ->
      let tokens = tokenize input "test.ly" in
      check_token_types expected tokens)
    test_cases

(* 测试引用标识符解析 - 验证Lexer_parsers模块 *)
let test_quoted_identifier_parsing () =
  let test_cases =
    [
      ("「变量名」", [ "QuotedIdentifierToken(\"变量名\")"; "EOF" ]);
      ("「」", [ "QuotedIdentifierToken(\"\")"; "EOF" ]);
      ("「长变量名称」", [ "QuotedIdentifierToken(\"长变量名称\")"; "EOF" ]);
      ("「变量123」", [ "QuotedIdentifierToken(\"变量123\")"; "EOF" ]);
      ("「变量_名.函数」", [ "QuotedIdentifierToken(\"变量_名.函数\")"; "EOF" ]);
      ("「变量 名 称」", [ "QuotedIdentifierToken(\"变量 名 称\")"; "EOF" ]);
      ("「variable_name」", [ "QuotedIdentifierToken(\"variable_name\")"; "EOF" ]);
      ("「混合name123」", [ "QuotedIdentifierToken(\"混合name123\")"; "EOF" ]);
    ]
  in

  List.iter
    (fun (input, expected) ->
      let tokens = tokenize input "test.ly" in
      check_token_types expected tokens)
    test_cases

(* 测试中文字符处理 - 验证Lexer_chars模块 *)
let test_chinese_character_handling () =
  let test_cases =
    [
      ("「中文字符」", [ "QuotedIdentifierToken(\"中文字符\")"; "EOF" ]);
      ("「測試繁體字」", [ "QuotedIdentifierToken(\"測試繁體字\")"; "EOF" ]);
      ("「數學符號」", [ "QuotedIdentifierToken(\"數學符號\")"; "EOF" ]);
      ("「古典文字」", [ "QuotedIdentifierToken(\"古典文字\")"; "EOF" ]);
    ]
  in

  List.iter
    (fun (input, expected) ->
      let tokens = tokenize input "test.ly" in
      check_token_types expected tokens)
    test_cases

(* 测试中文标点符号 - 验证Lexer_chars模块 *)
let test_chinese_punctuation () =
  let test_cases =
    [
      ("（）", [ "ChineseLeftParen"; "ChineseRightParen"; "EOF" ]);
      ("，", [ "ChineseComma"; "EOF" ]);
      ("：", [ "ChineseColon"; "EOF" ]);
      ("。", [ "Dot"; "EOF" ]);
    ]
  in

  List.iter
    (fun (input, expected) ->
      let tokens = tokenize input "test.ly" in
      check_token_types expected tokens)
    test_cases

(* 测试复合表达式 - 验证所有模块协同工作 *)
let test_complex_expressions () =
  let test_cases =
    [
      ( "让 「变量」 为 『字符串』",
        [
          "LetKeyword";
          "QuotedIdentifierToken(\"变量\")";
          "AsForKeyword";
          "StringToken(\"字符串\")";
          "EOF";
        ] );
      ( "如果 「条件」 那么 真 否则 假",
        [
          "IfKeyword";
          "QuotedIdentifierToken(\"条件\")";
          "ThenKeyword";
          "BoolToken(true)";
          "ElseKeyword";
          "BoolToken(false)";
          "EOF";
        ] );
      ( "函数 「参数」 匹配 与 其他",
        [
          "FunKeyword";
          "QuotedIdentifierToken(\"参数\")";
          "MatchKeyword";
          "WithKeyword";
          "OtherKeyword";
          "EOF";
        ] );
      ("「变量」 乘以 一", [ "QuotedIdentifierToken(\"变量\")"; "MultiplyKeyword"; "OneKeyword"; "EOF" ]);
      ( "算法 据开始 据结束",
        [ "AncientAlgorithmKeyword"; "AncientRecordStartKeyword"; "AncientRecordEndKeyword"; "EOF" ]
      );
    ]
  in

  List.iter
    (fun (input, expected) ->
      let tokens = tokenize input "test.ly" in
      check_token_types expected tokens)
    test_cases

(* 测试模块化重构后的性能 *)
let test_performance () =
  let large_input =
    String.concat " "
      (List.init 1000 (fun i ->
           match i mod 5 with
           | 0 -> "让"
           | 1 -> "「变量" ^ string_of_int i ^ "」"
           | 2 -> "为"
           | 3 -> "『字符串" ^ string_of_int i ^ "』"
           | _ -> "如果"))
  in

  let start_time = Unix.gettimeofday () in
  let tokens = tokenize large_input "test.ly" in
  let end_time = Unix.gettimeofday () in
  let duration = end_time -. start_time in

  (* 验证结果不为空 *)
  check bool "性能测试 - 有token产生" true (List.length tokens > 0);
  (* 验证性能合理 (应该在1秒内完成) *)
  check bool "性能测试 - 时间合理" true (duration < 1.0);
  Printf.printf "性能测试：处理%d个token用时%.4f秒\n" (List.length tokens) duration

(* 测试套件 *)
let test_suite =
  [
    ("基本关键字识别", `Quick, test_keyword_recognition);
    ("文言文关键字识别", `Quick, test_wenyan_keyword_recognition);
    ("运算符关键字识别", `Quick, test_operator_keyword_recognition);
    ("类型关键字识别", `Quick, test_type_keyword_recognition);
    ("古雅体关键字识别", `Quick, test_ancient_keyword_recognition);
    ("字符串字面量解析", `Quick, test_string_literal_parsing);
    ("引用标识符解析", `Quick, test_quoted_identifier_parsing);
    ("中文字符处理", `Quick, test_chinese_character_handling);
    ("中文标点符号", `Quick, test_chinese_punctuation);
    ("复合表达式", `Quick, test_complex_expressions);
    ("性能测试", `Quick, test_performance);
  ]

let () = run "重构后词法分析器模块测试" [ ("重构后词法分析器", test_suite) ]
