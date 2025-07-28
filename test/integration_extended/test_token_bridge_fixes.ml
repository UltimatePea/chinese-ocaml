(** 测试Token兼容性桥接修复 - Fix #1448

    验证关键修复: 1. Token映射一致性 (Plus vs PlusToken) 2. Result类型替代failwith 3. 往返转换测试

    Author: Charlie, 计划代理专员 *)

open Yyocamlc_lib

(** 测试基础往返转换 *)
let test_basic_round_trip () =
  let test_cases =
    [
      (* 字面量token *)
      Token_unified.IntToken 42;
      Token_unified.FloatToken 3.14;
      Token_unified.StringToken "test";
      Token_unified.BoolToken true;
      (* 操作符token - 重点测试修复的映射问题 *)
      Token_unified.OperatorToken `Plus;
      Token_unified.OperatorToken `Minus;
      Token_unified.OperatorToken `Multiply;
      Token_unified.OperatorToken `Equal;
      (* 分隔符token *)
      Token_unified.DelimiterToken `LeftParen;
      Token_unified.DelimiterToken `RightParen;
      Token_unified.DelimiterToken `Comma;
      (* 关键字token *)
      Token_unified.BasicKeyword `Let;
      Token_unified.BasicKeyword `Fun;
      (* 特殊token *)
      Token_unified.EOF;
    ]
  in

  List.iter
    (fun token ->
      match Token_compatibility_bridge.to_lexer_token_result token with
      | Ok legacy_token -> (
          match Token_compatibility_bridge.from_lexer_token_result legacy_token with
          | Ok back_to_unified ->
              if token <> back_to_unified then
                failwith (Printf.sprintf "Round-trip failed for token")
          | Error msg -> failwith (Printf.sprintf "FromLexer conversion failed: %s" msg))
      | Error msg -> failwith (Printf.sprintf "ToLexer conversion failed: %s" msg))
    test_cases;
  Printf.printf "✅ All round-trip conversions passed\n"

(** 测试错误处理 *)
let test_error_handling () =
  (* 测试Result类型返回而不是failwith *)
  let error_token = Token_unified.Error "test error" in
  match Token_compatibility_bridge.to_lexer_token_result error_token with
  | Ok _ -> failwith "Error token should not convert successfully"
  | Error _ -> Printf.printf "✅ Error handling works correctly\n"

(** 运行所有测试 *)
let () =
  Printf.printf "开始测试Token兼容性桥接修复...\n";
  test_basic_round_trip ();
  test_error_handling ();
  Printf.printf "🎉 所有测试通过！修复验证成功。\n"
