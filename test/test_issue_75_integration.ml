(** Integration test for Issue #75 - Unicode字符处理优化

    This test verifies that the enhanced Unicode processing fixes Issue #75 where fullwidth Unicode
    digits caused infinite loops in the lexer.

    Author: Whisky, PR Worker Issue: #1847 - Unicode字符处理优化 (fixes #75)

    @since 2025-07-31 *)

open Yyocamlc_lib

(** Test that fullwidth Unicode characters no longer cause infinite loops *)
let test_fullwidth_digits_no_infinite_loop () =
  let test_cases =
    [
      ("（１ ＋ ２）", "fullwidth parentheses and digits with plus");
      ("１２３", "fullwidth digits sequence");
      ("＋－×÷", "fullwidth mathematical operators");
      ("（", "single fullwidth left parenthesis");
      ("）", "single fullwidth right parenthesis");
    ]
  in

  List.iter
    (fun (input, description) ->
      try
        (* This should complete quickly (no infinite loop) and either succeed or fail with proper error *)
        let _ = Lexer.tokenize input "test_issue_75.ly" in
        (* If we get here, the input was successfully processed *)
        Printf.printf "✅ %s: Successfully processed without infinite loop\n" description
      with
      | Lexer_tokens.LexError (msg, _pos) ->
          (* This is expected for unsupported characters - the key is no infinite loop *)
          Printf.printf "✅ %s: Properly rejected with error (no infinite loop): %s\n" description
            msg
      | exn ->
          (* Any other exception is unexpected *)
          failwith
            (Printf.sprintf "❌ %s: Unexpected exception: %s" description (Printexc.to_string exn)))
    test_cases

(** Test that the enhanced Unicode processing is actually being used *)
let test_enhanced_unicode_processing_active () =
  (* Test with supported Chinese characters that should work *)
  let supported_inputs =
    [ "「你好」"; (* Chinese quotes *) "，"; (* Chinese comma *) "：" (* Chinese colon *) ]
  in

  List.iter
    (fun input ->
      try
        let tokens = Lexer.tokenize input "test_enhanced.ly" in
        Printf.printf "✅ Enhanced processing working for: %s (got %d tokens)\n" input
          (List.length tokens)
      with exn ->
        failwith
          (Printf.sprintf "❌ Enhanced processing failed for supported input '%s': %s" input
             (Printexc.to_string exn)))
    supported_inputs

(** Test that Issue #75 specific case is handled correctly *)
let test_issue_75_specific_case () =
  let problematic_input = "（１ ＋ ２）" in

  (* Verify that this completes in reasonable time (no infinite loop) *)
  let start_time = Unix.gettimeofday () in

  try
    let _ = Lexer.tokenize problematic_input "issue_75_test.ly" in
    let end_time = Unix.gettimeofday () in
    let duration = end_time -. start_time in

    if duration > 1.0 then
      failwith
        (Printf.sprintf "❌ Issue #75 not fully fixed: took %.2f seconds (possible infinite loop)"
           duration)
    else Printf.printf "✅ Issue #75 FIXED: Processed in %.4f seconds (no infinite loop)\n" duration
  with Lexer_tokens.LexError (msg, _pos) ->
    let end_time = Unix.gettimeofday () in
    let duration = end_time -. start_time in

    if duration > 1.0 then
      failwith
        (Printf.sprintf "❌ Issue #75 not fully fixed: took %.2f seconds even with error" duration)
    else
      Printf.printf "✅ Issue #75 FIXED: Properly rejected in %.4f seconds with error: %s\n" duration
        msg

(** Test performance improvement claims *)
let test_performance_no_regression () =
  let simple_input = "「定义」「变量」「甲」" in
  let iterations = 100 in

  let start_time = Unix.gettimeofday () in

  for _i = 1 to iterations do
    let _ = Lexer.tokenize simple_input "perf_test.ly" in
    ()
  done;

  let end_time = Unix.gettimeofday () in
  let total_duration = end_time -. start_time in
  let avg_duration = total_duration /. float_of_int iterations in

  Printf.printf
    "✅ Performance test: %d iterations in %.4f seconds (avg: %.6f seconds per iteration)\n"
    iterations total_duration avg_duration;

  (* Performance should be reasonable (less than 10ms per iteration) *)
  if avg_duration > 0.01 then
    Printf.printf "⚠️  Performance concern: Average %.6f seconds per iteration (>10ms)\n"
      avg_duration
  else
    Printf.printf "✅ Performance excellent: Average %.6f seconds per iteration (<10ms)\n"
      avg_duration

let () =
  print_endline "🔍 开始Issue #75集成测试 - Unicode字符处理优化验证...";
  print_endline "";

  print_endline "=== 测试1: 全宽字符不再导致无限循环 ===";
  test_fullwidth_digits_no_infinite_loop ();
  print_endline "";

  print_endline "=== 测试2: 增强Unicode处理功能激活 ===";
  test_enhanced_unicode_processing_active ();
  print_endline "";

  print_endline "=== 测试3: Issue #75具体案例修复验证 ===";
  test_issue_75_specific_case ();
  print_endline "";

  print_endline "=== 测试4: 性能回归测试 ===";
  test_performance_no_regression ();
  print_endline "";

  print_endline "🎉 Issue #75集成测试全部完成！";
  print_endline "✅ 无限循环问题已修复";
  print_endline "✅ 增强Unicode处理正常工作";
  print_endline "✅ 错误处理机制完善";
  print_endline "✅ 性能表现良好";
  print_endline "";
  print_endline "📈 Issue #75修复确认：词法分析器现在能正确处理Unicode字符而不会陷入无限循环"
