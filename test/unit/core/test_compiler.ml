(** 骆言编译器核心模块单元测试 *)

open Alcotest
open Yyocamlc_lib.Compiler

(* 测试编译选项 *)
let test_compile_options () =
  (* 测试默认选项 *)
  let default_opts = default_options in
  check bool "默认选项 - show_tokens" false default_opts.show_tokens;
  check bool "默认选项 - show_ast" false default_opts.show_ast;
  check bool "默认选项 - show_types" false default_opts.show_types;
  check bool "默认选项 - check_only" false default_opts.check_only;
  check bool "默认选项 - quiet_mode" false default_opts.quiet_mode;
  check bool "默认选项 - filename" true (default_opts.filename = None);
  check bool "默认选项 - recovery_mode" true default_opts.recovery_mode;
  check string "默认选项 - log_level" "normal" default_opts.log_level;
  check bool "默认选项 - compile_to_c" false default_opts.compile_to_c;
  check bool "默认选项 - c_output_file" true (default_opts.c_output_file = None);
  
  (* 测试安静模式选项 *)
  let quiet_opts = quiet_options in
  check bool "安静模式 - quiet_mode" true quiet_opts.quiet_mode;
  check string "安静模式 - log_level" "quiet" quiet_opts.log_level

(* 测试编译选项修改 *)
let test_compile_options_modification () =
  let modified_opts = {
    default_options with
    show_tokens = true;
    show_ast = true;
    filename = Some "test.ly";
  } in
  
  check bool "修改后的选项 - show_tokens" true modified_opts.show_tokens;
  check bool "修改后的选项 - show_ast" true modified_opts.show_ast;
  check bool "修改后的选项 - filename" true (modified_opts.filename = Some "test.ly");
  (* 其他选项应该保持默认值 *)
  check bool "修改后的选项 - show_types" false modified_opts.show_types;
  check bool "修改后的选项 - check_only" false modified_opts.check_only

(* 测试简单编译 *)
let test_simple_compilation () =
  let simple_program = "让 x = 42" in
  let result = compile_string quiet_options simple_program in
  
  (* 检查编译结果 *)
  match result with
  | Ok _ -> check bool "简单编译成功" true true
  | Error _ -> check bool "简单编译失败" false true

(* 测试基础表达式编译 *)
let test_basic_expression_compilation () =
  let expressions = [
    "42";
    "3.14";
    "真";
    "假";
    "\"测试字符串\"";
    "'字'";
  ] in
  
  List.iter (fun expr ->
    let result = compile_string quiet_options expr in
    match result with
    | Ok _ -> check bool ("基础表达式编译成功: " ^ expr) true true
    | Error msg -> check bool ("基础表达式编译失败: " ^ expr ^ " - " ^ msg) false true
  ) expressions

(* 测试变量和Let语句编译 *)
let test_variable_and_let_compilation () =
  let let_programs = [
    "让 x = 42";
    "让 y = 3.14";
    "让 z = 真";
    "让 name = \"测试\"";
  ] in
  
  List.iter (fun prog ->
    let result = compile_string quiet_options prog in
    match result with
    | Ok _ -> check bool ("Let语句编译成功: " ^ prog) true true
    | Error msg -> check bool ("Let语句编译失败: " ^ prog ^ " - " ^ msg) false true
  ) let_programs

(* 测试算术运算编译 *)
let test_arithmetic_compilation () =
  let arithmetic_programs = [
    "让 x = 1 + 2";
    "让 y = 5 - 3";
    "让 z = 2 * 3";
    "让 w = 6 / 2";
  ] in
  
  List.iter (fun prog ->
    let result = compile_string quiet_options prog in
    match result with
    | Ok _ -> check bool ("算术运算编译成功: " ^ prog) true true
    | Error msg -> check bool ("算术运算编译失败: " ^ prog ^ " - " ^ msg) false true
  ) arithmetic_programs

(* 测试比较运算编译 *)
let test_comparison_compilation () =
  let comparison_programs = [
    "让 x = 1 = 1";
    "让 y = 1 < 2";
    "让 z = 2 > 1";
    "让 w = 1 <= 2";
    "让 v = 2 >= 1";
  ] in
  
  List.iter (fun prog ->
    let result = compile_string quiet_options prog in
    match result with
    | Ok _ -> check bool ("比较运算编译成功: " ^ prog) true true
    | Error msg -> check bool ("比较运算编译失败: " ^ prog ^ " - " ^ msg) false true
  ) comparison_programs

(* 测试条件表达式编译 *)
let test_conditional_compilation () =
  let conditional_programs = [
    "让 x = 如果 真 那么 1 否则 0";
    "让 y = 如果 1 < 2 那么 \"小于\" 否则 \"不小于\"";
    "让 z = 如果 假 那么 42 否则 24";
  ] in
  
  List.iter (fun prog ->
    let result = compile_string quiet_options prog in
    match result with
    | Ok _ -> check bool ("条件表达式编译成功: " ^ prog) true true
    | Error msg -> check bool ("条件表达式编译失败: " ^ prog ^ " - " ^ msg) false true
  ) conditional_programs

(* 测试函数定义编译 *)
let test_function_compilation () =
  let function_programs = [
    "让 f = 函数 x -> x";
    "让 g = 函数 x -> x + 1";
    "让 h = 函数 x -> 如果 x > 0 那么 x 否则 0";
  ] in
  
  List.iter (fun prog ->
    let result = compile_string quiet_options prog in
    match result with
    | Ok _ -> check bool ("函数定义编译成功: " ^ prog) true true
    | Error msg -> check bool ("函数定义编译失败: " ^ prog ^ " - " ^ msg) false true
  ) function_programs

(* 测试复杂程序编译 *)
let test_complex_program_compilation () =
  let complex_program = "
让 x = 42
让 y = 24
让 sum = x + y
让 condition = sum > 50
让 result = 如果 condition 那么 \"大于50\" 否则 \"小于等于50\"
" in
  
  let result = compile_string quiet_options complex_program in
  match result with
  | Ok _ -> check bool "复杂程序编译成功" true true
  | Error msg -> check bool ("复杂程序编译失败: " ^ msg) false true

(* 测试递归函数编译 *)
let test_recursive_function_compilation () =
  let recursive_programs = [
    "递归 让 fact = 函数 n -> 如果 n <= 1 那么 1 否则 n * fact(n - 1)";
    "递归 让 fib = 函数 n -> 如果 n <= 1 那么 n 否则 fib(n - 1) + fib(n - 2)";
  ] in
  
  List.iter (fun prog ->
    let result = compile_string quiet_options prog in
    match result with
    | Ok _ -> check bool ("递归函数编译成功: " ^ prog) true true
    | Error msg -> check bool ("递归函数编译失败: " ^ prog ^ " - " ^ msg) false true
  ) recursive_programs

(* 测试语法错误处理 *)
let test_syntax_error_handling () =
  let invalid_programs = [
    "让 = 42";  (* 缺少变量名 *)
    "让 x 42";  (* 缺少等号 *)
    "让 x = ";  (* 缺少值 *)
    "42 +";     (* 不完整的表达式 *)
    "如果 真 那么 1"; (* 缺少else分支 *)
  ] in
  
  List.iter (fun prog ->
    let result = compile_string quiet_options prog in
    match result with
    | Ok _ -> check bool ("语法错误应该被捕获: " ^ prog) false true
    | Error _ -> check bool ("语法错误正确处理: " ^ prog) true true
  ) invalid_programs

(* 测试类型错误处理 *)
let test_type_error_handling () =
  let type_error_programs = [
    "让 x = 1 + \"字符串\"";  (* 类型不匹配 *)
    "让 y = 如果 1 那么 2 否则 3";  (* 条件不是布尔值 *)
    "让 z = 如果 真 那么 1 否则 \"字符串\"";  (* 分支类型不匹配 *)
  ] in
  
  List.iter (fun prog ->
    let result = compile_string quiet_options prog in
    match result with
    | Ok _ -> check bool ("类型错误应该被捕获: " ^ prog) false true
    | Error _ -> check bool ("类型错误正确处理: " ^ prog) true true
  ) type_error_programs

(* 测试编译选项对输出的影响 *)
let test_compile_options_effect () =
  let simple_program = "让 x = 42" in
  
  (* 测试check_only选项 *)
  let check_only_opts = { quiet_options with check_only = true } in
  let result = compile_string check_only_opts simple_program in
  match result with
  | Ok _ -> check bool "check_only选项编译成功" true true
  | Error _ -> check bool "check_only选项编译失败" false true;
  
  (* 测试不同的log_level *)
  let verbose_opts = { quiet_options with log_level = "verbose" } in
  let result2 = compile_string verbose_opts simple_program in
  match result2 with
  | Ok _ -> check bool "verbose模式编译成功" true true
  | Error _ -> check bool "verbose模式编译失败" false true

(* 测试多行程序编译 *)
let test_multiline_program_compilation () =
  let multiline_program = "让 x = 1
让 y = 2
让 z = x + y
让 result = z * 2" in
  
  let result = compile_string quiet_options multiline_program in
  match result with
  | Ok _ -> check bool "多行程序编译成功" true true
  | Error msg -> check bool ("多行程序编译失败: " ^ msg) false true

(* 测试注释处理 *)
let test_comment_handling () =
  let program_with_comments = "
// 这是注释
让 x = 42  // 行尾注释
// 另一个注释
让 y = 24
/* 多行注释
   继续注释 */
让 z = x + y
" in
  
  let result = compile_string quiet_options program_with_comments in
  match result with
  | Ok _ -> check bool "带注释的程序编译成功" true true
  | Error msg -> check bool ("带注释的程序编译失败: " ^ msg) false true

(* 测试空程序编译 *)
let test_empty_program_compilation () =
  let empty_program = "" in
  let result = compile_string quiet_options empty_program in
  match result with
  | Ok _ -> check bool "空程序编译成功" true true
  | Error _ -> check bool "空程序编译失败" false true;
  
  (* 测试只有空白字符的程序 *)
  let whitespace_program = "   \n\t  \n  " in
  let result2 = compile_string quiet_options whitespace_program in
  match result2 with
  | Ok _ -> check bool "空白字符程序编译成功" true true
  | Error _ -> check bool "空白字符程序编译失败" false true

(* 测试套件 *)
let test_suite = [
  ("编译选项测试", `Quick, test_compile_options);
  ("编译选项修改测试", `Quick, test_compile_options_modification);
  ("简单编译测试", `Quick, test_simple_compilation);
  ("基础表达式编译测试", `Quick, test_basic_expression_compilation);
  ("变量和Let语句编译测试", `Quick, test_variable_and_let_compilation);
  ("算术运算编译测试", `Quick, test_arithmetic_compilation);
  ("比较运算编译测试", `Quick, test_comparison_compilation);
  ("条件表达式编译测试", `Quick, test_conditional_compilation);
  ("函数定义编译测试", `Quick, test_function_compilation);
  ("复杂程序编译测试", `Quick, test_complex_program_compilation);
  ("递归函数编译测试", `Quick, test_recursive_function_compilation);
  ("语法错误处理测试", `Quick, test_syntax_error_handling);
  ("类型错误处理测试", `Quick, test_type_error_handling);
  ("编译选项效果测试", `Quick, test_compile_options_effect);
  ("多行程序编译测试", `Quick, test_multiline_program_compilation);
  ("注释处理测试", `Quick, test_comment_handling);
  ("空程序编译测试", `Quick, test_empty_program_compilation);
]

let () = run "Compiler单元测试" test_suite