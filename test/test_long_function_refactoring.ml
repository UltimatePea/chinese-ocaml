(** 长函数重构测试模块
    
    测试重构后的函数功能是否保持一致
    覆盖Token兼容性桥接、转换系统和字符串转换等核心功能
    
    Author: Alpha, 主要工作Agent
    Date: 2025-07-26
    Related: Issue #1412 *)

open Token_unified
open Token_compatibility_bridge
open Token_conversion_unified

(** 测试Token兼容性桥接模块的重构后功能 *)
module TestTokenBridge = struct
  let test_to_lexer_token_conversion () =
    let test_cases = [
      (* 字面量测试 *)
      (IntToken 42, fun result -> 
        match result with 
        | Lexer_tokens.IntToken 42 -> true 
        | _ -> false);
      (StringToken "hello", fun result -> 
        match result with 
        | Lexer_tokens.StringToken "hello" -> true 
        | _ -> false);
      (* 关键字测试 *)
      (BasicKeyword `Let, fun result -> 
        match result with 
        | Lexer_tokens.LetKeyword -> true 
        | _ -> false);
      (ControlKeyword `If, fun result -> 
        match result with 
        | Lexer_tokens.IfKeyword -> true 
        | _ -> false);
      (* 操作符测试 *)
      (OperatorToken `Plus, fun result -> 
        match result with 
        | Lexer_tokens.Plus -> true 
        | _ -> false);
      (* 分隔符测试 *)
      (DelimiterToken `LeftParen, fun result -> 
        match result with 
        | Lexer_tokens.LeftParenToken -> true 
        | _ -> false);
    ] in
    
    List.for_all (fun (token, checker) ->
      try
        let result = ToLexerToken.convert token in
        checker result
      with _ -> false
    ) test_cases

  let test_from_lexer_token_conversion () =
    let test_cases = [
      (* 字面量测试 *)
      (Lexer_tokens.IntToken 42, fun result -> 
        match result with 
        | IntToken 42 -> true 
        | _ -> false);
      (Lexer_tokens.StringToken "hello", fun result -> 
        match result with 
        | StringToken "hello" -> true 
        | _ -> false);
      (* 关键字测试 *)
      (Lexer_tokens.LetKeyword, fun result -> 
        match result with 
        | BasicKeyword `Let -> true 
        | _ -> false);
      (Lexer_tokens.IfKeyword, fun result -> 
        match result with 
        | ControlKeyword `If -> true 
        | _ -> false);
    ] in
    
    List.for_all (fun (token, checker) ->
      try
        let result = FromLexerToken.convert token in
        checker result
      with _ -> false
    ) test_cases

  let test_conversion_roundtrip () =
    let test_tokens = [
      IntToken 123;
      StringToken "test";
      BasicKeyword `Let;
      ControlKeyword `If;
      OperatorToken `Plus;
      DelimiterToken `LeftParen;
    ] in
    
    List.for_all (fun token ->
      try
        let legacy = ToLexerToken.convert token in
        let back = FromLexerToken.convert legacy in
        token = back
      with _ -> false
    ) test_tokens
end

(** 测试Token转换系统的重构后功能 *)
module TestTokenConversion = struct
  let test_identifier_converter () =
    let test_cases = [
      (Token_mapping.Token_definitions_unified.QuotedIdentifierToken "test", 
       QuotedIdentifierToken "test");
      (Token_mapping.Token_definitions_unified.IdentifierTokenSpecial "main", 
       IdentifierTokenSpecial "main");
    ] in
    
    List.for_all (fun (input, expected) ->
      try
        let result = identifier_converter input in
        result = expected
      with _ -> false
    ) test_cases

  let test_literal_converter () =
    let test_cases = [
      (Token_mapping.Token_definitions_unified.IntToken 42, IntToken 42);
      (Token_mapping.Token_definitions_unified.StringToken "hello", StringToken "hello");
      (Token_mapping.Token_definitions_unified.BoolToken true, BoolToken true);
    ] in
    
    List.for_all (fun (input, expected) ->
      try
        let result = literal_converter input in
        result = expected
      with _ -> false
    ) test_cases

  let test_basic_keyword_converter () =
    let test_cases = [
      (Token_mapping.Token_definitions_unified.LetKeyword, LetKeyword);
      (Token_mapping.Token_definitions_unified.FunKeyword, FunKeyword);
      (Token_mapping.Token_definitions_unified.IfKeyword, IfKeyword);
    ] in
    
    List.for_all (fun (input, expected) ->
      try
        let result = basic_keyword_converter input in
        result = expected
      with _ -> false
    ) test_cases

  let test_default_converters_registry () =
    (* 验证注册表包含所有预期的转换器 *)
    let expected_categories = [`Identifier; `Literal; `BasicKeyword; `TypeKeyword; `Classical] in
    let registered_categories = List.map fst default_converters in
    List.for_all (fun cat -> List.mem cat registered_categories) expected_categories
end

(** 测试Token字符串转换的重构后功能 *)
module TestTokenString = struct
  open Token_unified
  
  let test_literal_and_identifier_to_string () =
    let test_cases = [
      (IntToken 42, "42");
      (StringToken "hello", "\"hello\"");
      (BoolToken true, "真");
      (BoolToken false, "假");
      (IdentifierToken "main", "main");
      (QuotedIdentifierToken "test", "「test」");
    ] in
    
    List.for_all (fun (token, expected) ->
      try
        let result = literal_and_identifier_to_string token in
        result = expected
      with _ -> false
    ) test_cases

  let test_keyword_to_string () =
    let test_cases = [
      (BasicKeyword `Let, "让");
      (BasicKeyword `Fun, "函数");
      (TypeKeyword `Int, "整数");
      (ControlKeyword `If, "如果");
      (ClassicalKeyword `Have, "有");
    ] in
    
    List.for_all (fun (token, expected) ->
      try
        let result = keyword_to_string token in
        result = expected
      with _ -> false
    ) test_cases

  let test_operator_to_string () =
    let test_cases = [
      (OperatorToken `Plus, "+");
      (OperatorToken `Minus, "-");
      (OperatorToken `Equal, "=");
      (OperatorToken `Arrow, "->");
    ] in
    
    List.for_all (fun (token, expected) ->
      try
        let result = operator_to_string token in
        result = expected
      with _ -> false
    ) test_cases

  let test_delimiter_and_special_to_string () =
    let test_cases = [
      (DelimiterToken `LeftParen, "(");
      (DelimiterToken `RightParen, ")");
      (EOF, "<EOF>");
      (Error "test", "<ERROR: test>");
    ] in
    
    List.for_all (fun (token, expected) ->
      try
        let result = delimiter_and_special_to_string token in
        result = expected
      with _ -> false
    ) test_cases

  let test_token_to_string_consistency () =
    (* 测试主转换函数与专门转换器的一致性 *)
    let test_tokens = [
      IntToken 42;
      StringToken "test";
      BasicKeyword `Let;
      OperatorToken `Plus;
      DelimiterToken `LeftParen;
      EOF;
    ] in
    
    List.for_all (fun token ->
      try
        let main_result = token_to_string token in
        let specific_result = match token with
          | IntToken _ | StringToken _ | IdentifierToken _ | _ as t when 
              (match t with 
               | IntToken _ | FloatToken _ | StringToken _ | BoolToken _ 
               | ChineseNumberToken _ | UnitToken | IdentifierToken _ 
               | QuotedIdentifierToken _ | ConstructorToken _ | ModuleNameToken _ 
               | TypeNameToken _ -> true 
               | _ -> false) -> literal_and_identifier_to_string t
          | BasicKeyword _ | TypeKeyword _ | ControlKeyword _ | ClassicalKeyword _ as t -> 
              keyword_to_string t
          | OperatorToken _ as t -> operator_to_string t
          | DelimiterToken _ | EOF | Error _ as t -> delimiter_and_special_to_string t
        in
        main_result = specific_result
      with _ -> false
    ) test_tokens
end

(** 运行所有测试 *)
let run_all_tests () =
  let tests = [
    ("Token桥接 - ToLexerToken转换", TestTokenBridge.test_to_lexer_token_conversion);
    ("Token桥接 - FromLexerToken转换", TestTokenBridge.test_from_lexer_token_conversion);
    ("Token桥接 - 往返转换一致性", TestTokenBridge.test_conversion_roundtrip);
    ("Token转换 - 标识符转换器", TestTokenConversion.test_identifier_converter);
    ("Token转换 - 字面量转换器", TestTokenConversion.test_literal_converter);
    ("Token转换 - 基础关键字转换器", TestTokenConversion.test_basic_keyword_converter);
    ("Token转换 - 转换器注册表", TestTokenConversion.test_default_converters_registry);
    ("Token字符串 - 字面量和标识符", TestTokenString.test_literal_and_identifier_to_string);
    ("Token字符串 - 关键字转换", TestTokenString.test_keyword_to_string);
    ("Token字符串 - 操作符转换", TestTokenString.test_operator_to_string);
    ("Token字符串 - 分隔符和特殊Token", TestTokenString.test_delimiter_and_special_to_string);
    ("Token字符串 - 主函数一致性", TestTokenString.test_token_to_string_consistency);
  ] in
  
  let results = List.map (fun (name, test_func) ->
    try
      let result = test_func () in
      (name, result, None)
    with e ->
      (name, false, Some (Printexc.to_string e))
  ) tests in
  
  let passed = List.filter (fun (_, result, _) -> result) results in
  let failed = List.filter (fun (_, result, _) -> not result) results in
  
  Printf.printf "长函数重构测试结果：\n";
  Printf.printf "总计: %d, 通过: %d, 失败: %d\n\n" 
    (List.length tests) (List.length passed) (List.length failed);
  
  if List.length failed > 0 then (
    Printf.printf "失败的测试：\n";
    List.iter (fun (name, _, error) ->
      Printf.printf "- %s" name;
      match error with
      | Some err -> Printf.printf " (错误: %s)" err
      | None -> ();
      Printf.printf "\n"
    ) failed
  ) else (
    Printf.printf "所有测试通过！重构成功保持功能一致性。\n"
  );
  
  List.length failed = 0

(* 如果作为主程序运行，执行测试 *)
let () = 
  if !Sys.interactive then () else
    let success = run_all_tests () in
    exit (if success then 0 else 1)