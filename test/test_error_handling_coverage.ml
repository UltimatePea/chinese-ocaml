(** 错误处理覆盖率测试 - 提升编译器错误处理系统的测试覆盖率 *)

open Yyocamlc_lib.Compiler_errors
open Yyocamlc_lib.Compiler_errors_types
open Yyocamlc_lib.Compiler_errors_creation
open Yyocamlc_lib.Compiler_errors_formatter

(** 测试错误类型定义 *)
let test_error_types () =
  Printf.printf "测试错误类型定义...\n";

  (* 测试位置信息创建 *)
  let pos = { filename = "test.ly"; line = 10; column = 5 } in
  assert (pos.filename = "test.ly");
  assert (pos.line = 10);
  assert (pos.column = 5);

  Printf.printf "✅ 错误类型定义测试通过\n"

(** 测试错误创建功能 *)
let test_error_creation () =
  Printf.printf "测试错误创建功能...\n";

  let pos = { filename = "test.ly"; line = 15; column = 8 } in

  (* 测试语法错误创建 *)
  (match syntax_error "语法错误测试" pos with
  | Error error_info -> Printf.printf "  语法错误创建成功: %s\n" (format_error_info error_info)
  | Ok _ -> assert false);

  (* 测试类型错误创建 *)
  (match type_error "类型错误测试" (Some pos) with
  | Error error_info -> Printf.printf "  类型错误创建成功: %s\n" (format_error_info error_info)
  | Ok _ -> assert false);

  (* 测试语义错误创建 *)
  (match semantic_error "语义错误测试" (Some pos) with
  | Error error_info -> Printf.printf "  语义错误创建成功: %s\n" (format_error_info error_info)
  | Ok _ -> assert false);

  (* 测试解析错误创建 *)
  (match parse_error "解析错误测试" pos with
  | Error error_info -> Printf.printf "  解析错误创建成功: %s\n" (format_error_info error_info)
  | Ok _ -> assert false);

  (* 测试词法错误创建 *)
  (match lex_error "词法错误测试" pos with
  | Error error_info -> Printf.printf "  词法错误创建成功: %s\n" (format_error_info error_info)
  | Ok _ -> assert false);

  Printf.printf "✅ 错误创建功能测试通过\n"

(** 测试运行时错误创建 *)
let test_runtime_error_creation () =
  Printf.printf "测试运行时错误创建...\n";

  let pos = { filename = "runtime.ly"; line = 20; column = 3 } in

  (* 测试运行时错误 *)
  (match runtime_error "运行时错误测试" (Some pos) with
  | Error error_info -> Printf.printf "  运行时错误创建成功: %s\n" (format_error_info error_info)
  | Ok _ -> assert false);

  (* 测试代码生成错误 *)
  (match codegen_error ~context:"测试上下文" "代码生成错误测试" with
  | Error error_info -> Printf.printf "  代码生成错误创建成功: %s\n" (format_error_info error_info)
  | Ok _ -> assert false);

  (* 测试IO错误 *)
  (match io_error "IO错误测试" "文件系统" with
  | Error error_info -> Printf.printf "  IO错误创建成功: %s\n" (format_error_info error_info)
  | Ok _ -> assert false);

  Printf.printf "✅ 运行时错误创建测试通过\n"

(** 测试特殊错误类型 *)
let test_special_error_types () =
  Printf.printf "测试特殊错误类型...\n";

  let pos = { filename = "poetry.ly"; line = 5; column = 12 } in

  (* 测试诗词解析错误 *)
  (match poetry_parse_error "诗词解析错误测试" (Some pos) with
  | Error error_info -> Printf.printf "  诗词解析错误创建成功: %s\n" (format_error_info error_info)
  | Ok _ -> assert false);

  (* 测试内部错误 *)
  (match internal_error "内部错误测试" with
  | Error error_info -> Printf.printf "  内部错误创建成功: %s\n" (format_error_info error_info)
  | Ok _ -> assert false);

  Printf.printf "✅ 特殊错误类型测试通过\n"

(** 测试错误格式化功能 *)
let test_error_formatting () =
  Printf.printf "测试错误格式化功能...\n";

  let pos = { filename = "format_test.ly"; line = 25; column = 10 } in

  (* 创建并格式化不同类型的错误 *)
  let test_format error_result error_type =
    match error_result with
    | Error error_info ->
        let formatted = format_error_info error_info in
        Printf.printf "  %s格式化: %s\n" error_type formatted;
        assert (String.length formatted > 0)
    | Ok _ -> assert false
  in

  test_format (syntax_error "格式化测试语法错误" pos) "语法错误";
  test_format (type_error "格式化测试类型错误" (Some pos)) "类型错误";
  test_format (runtime_error "格式化测试运行时错误" (Some pos)) "运行时错误";

  Printf.printf "✅ 错误格式化功能测试通过\n"

(** 测试错误提取功能 *)
let test_error_extraction () =
  Printf.printf "测试错误提取功能...\n";

  let pos = { filename = "extract.ly"; line = 30; column = 15 } in
  let error_result = syntax_error "提取测试错误" pos in

  (* 测试错误信息提取 *)
  let error_info = extract_error_info error_result in
  let formatted = format_error_info error_info in
  Printf.printf "  提取的错误信息: %s\n" formatted;
  assert (String.length formatted > 0);

  Printf.printf "✅ 错误提取功能测试通过\n"

(** 测试异常抛出功能 *)
let test_exception_raising () =
  Printf.printf "测试异常抛出功能...\n";

  let pos = { filename = "exception.ly"; line = 35; column = 20 } in
  let error_result = syntax_error "异常测试错误" pos in
  let error_info = extract_error_info error_result in

  (* 测试异常抛出（捕获以验证） *)
  (try
     raise_compiler_error error_info;
     assert false (* 不应该到达这里 *)
   with
  | CompilerError caught_error ->
      let formatted = format_error_info caught_error in
      Printf.printf "  成功捕获编译器异常: %s\n" formatted;
      assert (String.length formatted > 0)
  | _ -> assert false);

  Printf.printf "✅ 异常抛出功能测试通过\n"

(** 测试遗留异常转换功能 *)
let test_legacy_exception_wrapping () =
  Printf.printf "测试遗留异常转换功能...\n";

  (* 测试包装正常返回值的函数 *)
  let normal_function () = Ok "正常结果" in
  (match wrap_legacy_exception normal_function with
  | Ok result ->
      Printf.printf "  正常函数包装成功: %s\n" result;
      assert (result = "正常结果")
  | Error _ -> assert false);

  (* 测试包装错误返回值的函数 *)
  let error_function () =
    let pos = { filename = "legacy.ly"; line = 40; column = 25 } in
    syntax_error "包装测试错误" pos
  in
  (match wrap_legacy_exception error_function with
  | Error error_info ->
      let formatted = format_error_info error_info in
      Printf.printf "  错误函数包装成功: %s\n" formatted
  | Ok _ -> assert false);

  Printf.printf "✅ 遗留异常转换功能测试通过\n"

(** 测试边界情况 *)
let test_edge_cases () =
  Printf.printf "测试边界情况...\n";

  (* 测试空文件名 *)
  let empty_pos = { filename = ""; line = 1; column = 1 } in
  (match syntax_error "空文件名测试" empty_pos with
  | Error error_info ->
      let formatted = format_error_info error_info in
      Printf.printf "  空文件名错误处理: %s\n" formatted
  | Ok _ -> assert false);

  (* 测试零行号和列号 *)
  let zero_pos = { filename = "test.ly"; line = 0; column = 0 } in
  (match parse_error "零位置测试" zero_pos with
  | Error error_info ->
      let formatted = format_error_info error_info in
      Printf.printf "  零位置错误处理: %s\n" formatted
  | Ok _ -> assert false);

  (* 测试无位置信息的错误 *)
  (match type_error "无位置测试" None with
  | Error error_info ->
      let formatted = format_error_info error_info in
      Printf.printf "  无位置错误处理: %s\n" formatted
  | Ok _ -> assert false);

  Printf.printf "✅ 边界情况测试通过\n"

(** 运行所有测试 *)
let run_tests () =
  Printf.printf "=== 错误处理覆盖率测试开始 ===\n";

  test_error_types ();
  test_error_creation ();
  test_runtime_error_creation ();
  test_special_error_types ();
  test_error_formatting ();
  test_error_extraction ();
  test_exception_raising ();
  test_legacy_exception_wrapping ();
  test_edge_cases ();

  Printf.printf "=== 错误处理覆盖率测试完成 ===\n";
  Printf.printf "🎯 目标：提升compiler_errors.ml及其子模块的测试覆盖率\n"

let () = run_tests ()
