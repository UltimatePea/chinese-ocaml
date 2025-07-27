(** 测试Token兼容性桥接修复 - Fix #1448
    
    验证关键修复:
    1. Token映射一致性 (Plus vs PlusToken)
    2. Result类型替代failwith
    3. 往返转换测试
    
    Author: Charlie, 计划代理专员 *)

open Token_unified
open Token_compatibility_bridge

(** 测试基础往返转换 *)
let test_basic_round_trip () =
  let test_cases = [
    (* 字面量token *)
    IntToken 42;
    FloatToken 3.14;
    StringToken "test";
    BoolToken true;
    
    (* 操作符token - 重点测试修复的映射问题 *)
    OperatorToken `Plus;
    OperatorToken `Minus;
    OperatorToken `Multiply;
    OperatorToken `Equal;
    
    (* 分隔符token *)
    DelimiterToken `LeftParen;
    DelimiterToken `RightParen;
    DelimiterToken `Comma;
    
    (* 关键字token *)
    BasicKeyword `Let;
    BasicKeyword `Fun;
    
    (* 特殊token *)
    EOF;
  ] in
  
  List.iter (fun token ->
    match to_lexer_token_result token with
    | Ok legacy_token ->
        (match from_lexer_token_result legacy_token with
         | Ok back_to_unified ->
             if token <> back_to_unified then
               failwith (Printf.sprintf "Round-trip failed for token")
         | Error msg ->
             failwith (Printf.sprintf "FromLexer conversion failed: %s" msg))
    | Error msg ->
        failwith (Printf.sprintf "ToLexer conversion failed: %s" msg)
  ) test_cases;
  Printf.printf "✅ All round-trip conversions passed\n"

(** 测试错误处理 *)
let test_error_handling () =
  (* 测试Result类型返回而不是failwith *)
  let error_token = Error "test error" in
  match to_lexer_token_result error_token with
  | Ok _ -> failwith "Error token should not convert successfully"
  | Error _ -> Printf.printf "✅ Error handling works correctly\n"

(** 运行所有测试 *)
let () =
  Printf.printf "开始测试Token兼容性桥接修复...\n";
  test_basic_round_trip ();
  test_error_handling ();
  Printf.printf "🎉 所有测试通过！修复验证成功。\n"