(** 编译器错误类型模块综合测试 - 骆言编译器 *)

open Alcotest
open Yyocamlc_lib

(** 测试位置类型创建和比较 *)
let test_position_type () =
  let pos1 = { Compiler_errors_types.filename = "test.ly"; line = 10; column = 25 } in
  let pos2 = { Compiler_errors_types.filename = "test.ly"; line = 10; column = 25 } in
  let pos3 = { Compiler_errors_types.filename = "other.ly"; line = 5; column = 15 } in

  check bool "位置类型相等比较" true (Compiler_errors_types.equal_position pos1 pos2);
  check bool "位置类型不相等" false (Compiler_errors_types.equal_position pos1 pos3);
  check string "文件名提取正确" "test.ly" pos1.filename;
  check int "行号提取正确" 10 pos1.line;
  check int "列号提取正确" 25 pos1.column

(** 测试编译器错误类型创建 *)
let test_compiler_error_types () =
  let pos = { Compiler_errors_types.filename = "test.ly"; line = 5; column = 10 } in

  (* 测试词法分析错误 *)
  let lex_error = Compiler_errors_types.LexError ("未知字符", pos) in
  (match lex_error with
  | Compiler_errors_types.LexError (msg, p) ->
      check string "词法错误消息正确" "未知字符" msg;
      check bool "词法错误位置正确" true (Compiler_errors_types.equal_position pos p)
  | _ -> fail "词法错误类型匹配失败");

  (* 测试语法分析错误 *)
  let parse_error = Compiler_errors_types.ParseError ("缺少分号", pos) in
  (match parse_error with
  | Compiler_errors_types.ParseError (msg, p) ->
      check string "语法错误消息正确" "缺少分号" msg;
      check bool "语法错误位置正确" true (Compiler_errors_types.equal_position pos p)
  | _ -> fail "语法错误类型匹配失败");

  (* 测试类型错误 *)
  let type_error = Compiler_errors_types.TypeError ("类型不匹配", Some pos) in
  (match type_error with
  | Compiler_errors_types.TypeError (msg, Some p) ->
      check string "类型错误消息正确" "类型不匹配" msg;
      check bool "类型错误位置正确" true (Compiler_errors_types.equal_position pos p)
  | _ -> fail "类型错误类型匹配失败");

  (* 测试内部错误 *)
  let internal_error = Compiler_errors_types.InternalError "内部状态异常" in
  match internal_error with
  | Compiler_errors_types.InternalError msg -> check string "内部错误消息正确" "内部状态异常" msg
  | _ -> fail "内部错误类型匹配失败"

(** 测试错误严重级别 *)
let test_error_severity () =
  (* 直接测试error_severity类型的构造子 *)
  let test_warning_severity = Compiler_errors_types.Warning in
  let test_fatal_severity = Compiler_errors_types.Fatal in

  check bool "警告级别构造正确" true
    (match test_warning_severity with Compiler_errors_types.Warning -> true | _ -> false);

  check bool "致命级别构造正确" true
    (match test_fatal_severity with Compiler_errors_types.Fatal -> true | _ -> false);

  (* 测试严重级别不相等 *)
  check bool "警告级别不等于致命级别" false (test_warning_severity = test_fatal_severity)

(** 测试错误信息记录 *)
let test_error_info () =
  let pos = { Compiler_errors_types.filename = "test.ly"; line = 15; column = 8 } in
  let error = Compiler_errors_types.SyntaxError ("缺少右括号", pos) in
  let error_info =
    {
      Compiler_errors_types.error;
      severity = Compiler_errors_types.Warning;
      (* 使用Warning避免与Error构造子冲突 *)
      context = Some "函数调用表达式";
      suggestions = [ "检查括号配对"; "添加缺少的右括号" ];
    }
  in

  (* 测试错误信息字段 *)
  (match error_info.error with
  | Compiler_errors_types.SyntaxError (msg, p) ->
      check string "错误信息中的消息正确" "缺少右括号" msg;
      check bool "错误信息中的位置正确" true (Compiler_errors_types.equal_position pos p)
  | _ -> fail "错误信息中的错误类型不匹配");

  check bool "错误严重级别正确" true (error_info.severity = Compiler_errors_types.Warning);
  (match error_info.context with
  | Some ctx -> check string "错误上下文正确" "函数调用表达式" ctx
  | None -> fail "错误上下文缺失");
  check int "建议数量正确" 2 (List.length error_info.suggestions);
  check string "第一个建议正确" "检查括号配对" (List.hd error_info.suggestions)

(** 测试错误处理结果类型 *)
let test_error_result () =
  (* 成功结果 *)
  let success_result : string Compiler_errors_types.error_result =
    Compiler_errors_types.Ok "编译成功"
  in
  (match success_result with
  | Compiler_errors_types.Ok value -> check string "成功结果值正确" "编译成功" value
  | Compiler_errors_types.Error _ -> fail "成功结果类型不匹配");

  (* 错误结果 *)
  let error = Compiler_errors_types.InternalError "测试错误" in
  let error_info =
    {
      Compiler_errors_types.error;
      severity = Compiler_errors_types.Fatal;
      context = None;
      suggestions = [];
    }
  in
  let error_result : string Compiler_errors_types.error_result =
    Compiler_errors_types.Error error_info
  in

  match error_result with
  | Compiler_errors_types.Error info ->
      (match info.error with
      | Compiler_errors_types.InternalError msg -> check string "错误结果消息正确" "测试错误" msg
      | _ -> fail "错误结果错误类型不匹配");
      check bool "错误结果严重级别正确" true (info.severity = Compiler_errors_types.Fatal)
  | Compiler_errors_types.Ok _ -> fail "错误结果类型不匹配"

(** 测试错误收集器 *)
let test_error_collector () =
  let collector = { Compiler_errors_types.errors = []; has_fatal = false } in

  (* 初始状态测试 *)
  check int "初始错误列表为空" 0 (List.length collector.errors);
  check bool "初始无致命错误" false collector.has_fatal;

  (* 添加警告错误 *)
  let warning_info =
    {
      Compiler_errors_types.error = Compiler_errors_types.InternalError "警告测试";
      severity = Compiler_errors_types.Warning;
      context = None;
      suggestions = [];
    }
  in
  collector.errors <- warning_info :: collector.errors;
  check int "添加一个错误后列表长度为1" 1 (List.length collector.errors);
  check bool "添加警告后仍无致命错误" false collector.has_fatal;

  (* 添加致命错误 *)
  let fatal_info =
    {
      Compiler_errors_types.error = Compiler_errors_types.InternalError "致命错误测试";
      severity = Compiler_errors_types.Fatal;
      context = None;
      suggestions = [];
    }
  in
  collector.errors <- fatal_info :: collector.errors;
  collector.has_fatal <- true;
  check int "添加致命错误后列表长度为2" 2 (List.length collector.errors);
  check bool "添加致命错误后标记为有致命错误" true collector.has_fatal

(** 测试错误处理配置 *)
let test_error_handling_config () =
  let config =
    {
      Compiler_errors_types.continue_on_error = true;
      max_errors = 50;
      show_suggestions = true;
      colored_output = false;
    }
  in

  check bool "错误后继续配置正确" true config.continue_on_error;
  check int "最大错误数量配置正确" 50 config.max_errors;
  check bool "显示建议配置正确" true config.show_suggestions;
  check bool "彩色输出配置正确" false config.colored_output;

  (* 测试配置修改 *)
  let modified_config = { config with max_errors = 100; colored_output = true } in
  check int "修改后最大错误数量正确" 100 modified_config.max_errors;
  check bool "修改后彩色输出配置正确" true modified_config.colored_output;
  check bool "其他配置保持不变" true modified_config.continue_on_error

(** 测试编译器异常 *)
let test_compiler_exception () =
  let pos = { Compiler_errors_types.filename = "exception_test.ly"; line = 20; column = 5 } in
  let error = Compiler_errors_types.RuntimeError ("除零错误", Some pos) in
  let error_info =
    {
      Compiler_errors_types.error;
      severity = Compiler_errors_types.Fatal;
      context = Some "算术表达式求值";
      suggestions = [ "检查除数是否为零" ];
    }
  in

  let exception_test () = raise (Compiler_errors_types.CompilerError error_info) in

  (* 测试异常捕获 *)
  try
    let _ = exception_test () in
    fail "异常应该被抛出"
  with
  | Compiler_errors_types.CompilerError info ->
      (match info.error with
      | Compiler_errors_types.RuntimeError (msg, Some p) ->
          check string "异常错误消息正确" "除零错误" msg;
          check bool "异常错误位置正确" true (Compiler_errors_types.equal_position pos p)
      | _ -> fail "异常错误类型不匹配");
      check bool "异常严重级别正确" true (info.severity = Compiler_errors_types.Fatal)
  | _ -> fail "捕获的异常类型不正确"

(** 测试套件 *)
let () =
  run "编译器错误类型模块综合测试"
    [
      ("位置类型测试", [ test_case "位置类型创建和比较" `Quick test_position_type ]);
      ("编译器错误类型测试", [ test_case "基本编译器错误类型" `Quick test_compiler_error_types ]);
      ( "错误严重级别和信息",
        [
          test_case "错误严重级别" `Quick test_error_severity;
          test_case "错误信息记录" `Quick test_error_info;
          test_case "错误处理结果" `Quick test_error_result;
        ] );
      ( "错误收集和配置",
        [
          test_case "错误收集器" `Quick test_error_collector;
          test_case "错误处理配置" `Quick test_error_handling_config;
        ] );
      ("异常处理", [ test_case "编译器异常" `Quick test_compiler_exception ]);
    ]
