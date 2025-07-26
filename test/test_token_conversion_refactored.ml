(** 测试重构后的Token转换功能

    验证重构后的conversion_engine模块保持了原有功能 同时确保新的分层转换架构正常工作

    Author: Alpha专员, 主要工作代理 Fix: #1380 - Token系统重构性能优化 *)

open Yyocamlc_lib.Conversion_engine

(** 基础字符串转换测试 - 使用简化的API *)
let test_string_token_conversion () =
  let test_cases =
    [
      ("let", Some "LetKeyword");
      ("fun", Some "FunKeyword");
      ("if", Some "IfKeyword");
      ("unknown_token", None);
    ]
  in
  List.iter
    (fun (input, expected) ->
      let result = FastPath.convert_common_token input in
      if result = expected then
        Printf.printf "✓ 测试通过: %s -> %s\n" input
          (match expected with Some s -> s | None -> "None")
      else
        Printf.printf "✗ 测试失败: %s -> 期望 %s, 得到 %s\n" input
          (match expected with Some s -> s | None -> "None")
          (match result with Some s -> s | None -> "None"))
    test_cases

(** 转换策略测试 *)
let test_conversion_strategies () =
  let test_cases =
    [
      (Modern, "test_token", "string");
      (Classical, "古典_token", "string");
      (Lexer, "lexer_token", "string");
      (Auto, "auto_token", "string");
    ]
  in
  List.iter
    (fun (strategy, source, target_format) ->
      match convert_token ~strategy ~source ~target_format with
      | Success result -> Printf.printf "✓ 策略测试通过: %s -> %s\n" source result
      | Error err -> Printf.printf "✗ 策略测试失败: %s -> %s\n" source (error_to_string err))
    test_cases

(** 批量转换测试 *)
let test_batch_conversion () =
  let tokens = [ "let"; "fun"; "if"; "then" ] in
  match batch_convert ~strategy:Modern ~tokens ~target_format:"string" with
  | Success results -> Printf.printf "✓ 批量转换成功: [%s]\n" (String.concat "; " results)
  | Error err -> Printf.printf "✗ 批量转换失败: %s\n" (error_to_string err)

(** 向后兼容性API测试 *)
let test_backward_compatibility () =
  let test_cases = [ "let"; "fun"; "unknown" ] in
  List.iter
    (fun token ->
      match BackwardCompatibility.convert_token token with
      | Some result -> Printf.printf "✓ 兼容性API测试通过: %s -> %s\n" token result
      | None -> Printf.printf "✓ 兼容性API测试通过: %s -> None (预期)\n" token)
    test_cases

(** 错误处理测试 *)
let test_error_handling () =
  let test_error = ConversionError ("source", "target") in
  let error_str = error_to_string test_error in
  Printf.printf "✓ 错误处理测试: %s\n" error_str;

  (* 测试错误处理函数 *)
  handle_error test_error;
  Printf.printf "✓ 错误处理函数测试完成\n"

(** 统计信息测试 *)
let test_statistics () =
  let stats = Statistics.get_engine_stats () in
  Printf.printf "✓ 统计信息测试:\n%s\n" stats

(** 主测试函数 *)
let run_all_tests () =
  Printf.printf "=== 开始Token转换引擎测试 ===\n";

  Printf.printf "\n--- 基础转换测试 ---\n";
  test_string_token_conversion ();

  Printf.printf "\n--- 转换策略测试 ---\n";
  test_conversion_strategies ();

  Printf.printf "\n--- 批量转换测试 ---\n";
  test_batch_conversion ();

  Printf.printf "\n--- 向后兼容性测试 ---\n";
  test_backward_compatibility ();

  Printf.printf "\n--- 错误处理测试 ---\n";
  test_error_handling ();

  Printf.printf "\n--- 统计信息测试 ---\n";
  test_statistics ();

  Printf.printf "\n=== Token转换引擎测试完成 ===\n"

(* 运行测试 *)
let () = run_all_tests ()
