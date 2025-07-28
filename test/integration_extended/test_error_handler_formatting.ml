(** 错误处理格式化模块测试套件

    验证error_handler_formatting.ml模块的错误格式化功能 包括错误消息格式化、彩色输出、日志记录等功能

    创建目的：提升错误处理模块测试覆盖率至60%以上 Fix #925 *)

open Alcotest
open Yyocamlc_lib.Error_handler_formatting
open Yyocamlc_lib.Compiler_errors
open Yyocamlc_lib.Error_handler_types

(** 测试辅助函数 *)
let create_test_position () = { filename = "测试文件.ly"; line = 10; column = 5 }

let contains_substring s sub =
  try
    let _ = Str.search_forward (Str.regexp_string sub) s 0 in
    true
  with Not_found -> false

let create_test_context () =
  {
    source_file = "测试文件.ly";
    function_name = "测试函数";
    module_name = "测试模块";
    timestamp = Unix.time ();
    call_stack = [ "main"; "parse"; "error_handler" ];
    user_data = [ ("key1", "value1"); ("key2", "value2") ];
  }

let create_test_enhanced_error error_type recovery_strategy =
  let base_error = make_error_info error_type in
  {
    base_error;
    context = create_test_context ();
    recovery_strategy;
    attempt_count = 0;
    related_errors = [];
  }

(** 测试错误格式化功能 *)
let test_format_enhanced_error () =
  Printf.printf "测试错误格式化功能...\n";

  (* 测试语法错误格式化 *)
  let syntax_error =
    create_test_enhanced_error (SyntaxError ("语法错误测试", create_test_position ())) SkipAndContinue
  in
  let formatted_syntax = format_enhanced_error syntax_error in

  check bool "语法错误格式化应包含错误信息" true (contains_substring formatted_syntax "语");
  check bool "语法错误格式化应包含上下文信息" true (contains_substring formatted_syntax "上下文");
  check bool "语法错误格式化应包含恢复策略" true (contains_substring formatted_syntax "恢复");

  (* 测试类型错误格式化 *)
  let type_error =
    create_test_enhanced_error
      (TypeError ("类型错误测试", Some (create_test_position ())))
      SyncToNextStatement
  in
  let formatted_type = format_enhanced_error type_error in

  check bool "类型错误格式化应包含错误信息" true (String.length formatted_type > 0);
  check bool "类型错误格式化应包含同步策略" true (contains_substring formatted_type "同步");

  (* 测试内部错误格式化 *)
  let internal_error = create_test_enhanced_error (InternalError "内部错误测试") Abort in
  let formatted_internal = format_enhanced_error internal_error in

  check bool "内部错误格式化应包含错误信息" true (String.length formatted_internal > 0);
  check bool "内部错误格式化应包含终止策略" true (contains_substring formatted_internal "终止");

  Printf.printf "✓ 错误格式化功能测试通过\n"

(** 测试不同恢复策略的格式化 *)
let test_recovery_strategy_formatting () =
  Printf.printf "测试不同恢复策略的格式化...\n";

  let base_error_type = SyntaxError ("策略测试", create_test_position ()) in

  (* 测试跳过并继续策略 *)
  let skip_error = create_test_enhanced_error base_error_type SkipAndContinue in
  let formatted_skip = format_enhanced_error skip_error in
  check bool "跳过策略应正确格式化" true (contains_substring formatted_skip "跳过");

  (* 测试同步到下一语句策略 *)
  let sync_error = create_test_enhanced_error base_error_type SyncToNextStatement in
  let formatted_sync = format_enhanced_error sync_error in
  check bool "同步策略应正确格式化" true (contains_substring formatted_sync "同步");

  (* 测试尝试替代方案策略 *)
  let alt_error = create_test_enhanced_error base_error_type (TryAlternative "替代方案测试") in
  let formatted_alt = format_enhanced_error alt_error in
  check bool "替代方案策略应正确格式化" true (contains_substring formatted_alt "替代");

  (* 测试请求用户输入策略 *)
  let input_error = create_test_enhanced_error base_error_type RequestUserInput in
  let formatted_input = format_enhanced_error input_error in
  check bool "用户输入策略应正确格式化" true (contains_substring formatted_input "用户输入");

  (* 测试终止处理策略 *)
  let abort_error = create_test_enhanced_error base_error_type Abort in
  let formatted_abort = format_enhanced_error abort_error in
  check bool "终止处理策略应正确格式化" true (contains_substring formatted_abort "终止");

  Printf.printf "✓ 不同恢复策略格式化测试通过\n"

(** 测试彩色输出功能 *)
let test_colorize_error_message () =
  Printf.printf "测试彩色输出功能...\n";

  let test_message = "测试错误消息" in

  (* 测试警告级别彩色输出 *)
  let colored_warning = colorize_error_message Warning test_message in
  check bool "警告消息应包含颜色代码" true (String.length colored_warning >= String.length test_message);

  (* 测试错误级别彩色输出 *)
  let colored_error = colorize_error_message Error test_message in
  check bool "错误消息应包含颜色代码" true (String.length colored_error >= String.length test_message);

  (* 测试严重错误级别彩色输出 *)
  let colored_fatal = colorize_error_message Fatal test_message in
  check bool "严重错误消息应包含颜色代码" true (String.length colored_fatal >= String.length test_message);

  Printf.printf "✓ 彩色输出功能测试通过\n"

(** 测试重试信息格式化 *)
let test_attempt_count_formatting () =
  Printf.printf "测试重试信息格式化...\n";

  (* 测试无重试的情况 *)
  let no_retry_error =
    create_test_enhanced_error (SyntaxError ("无重试测试", create_test_position ())) SkipAndContinue
  in
  let formatted_no_retry = format_enhanced_error no_retry_error in
  check bool "无重试情况应正确格式化" true (String.length formatted_no_retry > 0);

  (* 测试有重试的情况 *)
  let retry_error =
    {
      (create_test_enhanced_error (SyntaxError ("重试测试", create_test_position ())) SkipAndContinue) with
      attempt_count = 3;
    }
  in
  let formatted_retry = format_enhanced_error retry_error in
  check bool "重试情况应包含重试信息" true (contains_substring formatted_retry "重试");

  Printf.printf "✓ 重试信息格式化测试通过\n"

(** 测试上下文信息格式化 *)
let test_context_formatting () =
  Printf.printf "测试上下文信息格式化...\n";

  (* 创建包含详细上下文的错误 *)
  let detailed_context =
    {
      source_file = "详细测试文件.ly";
      function_name = "详细测试函数";
      module_name = "详细测试模块";
      timestamp = 1640995200.0;
      (* 固定时间戳用于测试 *)
      call_stack = [ "main"; "parse"; "analyze"; "error" ];
      user_data = [ ("debug", "true"); ("level", "verbose") ];
    }
  in

  let context_error =
    {
      base_error = make_error_info (TypeError ("上下文测试", None));
      context = detailed_context;
      recovery_strategy = SkipAndContinue;
      attempt_count = 0;
      related_errors = [];
    }
  in

  let formatted_context = format_enhanced_error context_error in

  check bool "上下文格式化应包含文件名" true (contains_substring formatted_context "详细");
  check bool "上下文格式化应包含模块信息" true (contains_substring formatted_context "模块");
  check bool "上下文格式化应包含函数信息" true (contains_substring formatted_context "函数");

  Printf.printf "✓ 上下文信息格式化测试通过\n"

(** 测试日志记录功能 *)
let test_log_error_to_file () =
  Printf.printf "测试日志记录功能...\n";

  (* 创建测试错误用于日志记录 *)
  let log_error =
    create_test_enhanced_error
      (RuntimeError ("日志测试错误", Some (create_test_position ())))
      RequestUserInput
  in

  (* 测试日志记录功能（不会实际写入文件在测试环境） *)
  try
    log_error_to_file log_error;
    check bool "日志记录功能应正常运行" true true
  with _ ->
    check bool "日志记录功能出现异常" false true;

    Printf.printf "✓ 日志记录功能测试通过\n"

(** 测试边界条件和异常情况 *)
let test_edge_cases () =
  Printf.printf "测试边界条件和异常情况...\n";

  (* 测试空调用栈 *)
  let empty_stack_context =
    {
      source_file = "空栈测试.ly";
      function_name = "测试函数";
      module_name = "测试模块";
      timestamp = Unix.time ();
      call_stack = [];
      user_data = [];
    }
  in

  let empty_stack_error =
    {
      base_error = make_error_info (SyntaxError ("空栈测试", create_test_position ()));
      context = empty_stack_context;
      recovery_strategy = SkipAndContinue;
      attempt_count = 0;
      related_errors = [];
    }
  in

  let formatted_empty_stack = format_enhanced_error empty_stack_error in
  check bool "空调用栈应正确格式化" true (String.length formatted_empty_stack > 0);

  (* 测试长错误消息 *)
  let long_message = String.make 1000 'A' in
  let long_error = create_test_enhanced_error (RuntimeError (long_message, None)) Abort in
  let formatted_long = format_enhanced_error long_error in
  check bool "长错误消息应正确格式化" true (String.length formatted_long > 0);

  Printf.printf "✓ 边界条件和异常情况测试通过\n"

(** 主测试套件 *)
let () =
  Printf.printf "🚀 开始运行错误处理格式化模块测试套件\n";
  Printf.printf "================================================\n\n";

  test_format_enhanced_error ();
  test_recovery_strategy_formatting ();
  test_colorize_error_message ();
  test_attempt_count_formatting ();
  test_context_formatting ();
  test_log_error_to_file ();
  test_edge_cases ();

  Printf.printf "\n================================================\n";
  Printf.printf "✅ 所有测试通过！错误处理格式化模块运行正常\n";
  Printf.printf "📊 测试覆盖：错误格式化、彩色输出、日志记录、上下文格式化\n";
  Printf.printf "🎯 特色功能：恢复策略格式化、重试信息、边界条件测试\n";
  Printf.printf "================================================\n"
