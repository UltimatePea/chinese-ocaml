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
  check bool "简单编译成功" true result

(* 测试编译选项对输出的影响 *)
let test_compile_options_effect () =
  let simple_program = "让 x = 42" in
  
  (* 测试check_only选项 *)
  let check_only_opts = { quiet_options with check_only = true } in
  let result = compile_string check_only_opts simple_program in
  check bool "check_only选项编译成功" true result;
  
  (* 测试不同的log_level *)
  let verbose_opts = { quiet_options with log_level = "verbose" } in
  let result2 = compile_string verbose_opts simple_program in
  check bool "verbose模式编译成功" true result2

(* 测试空程序编译 *)
let test_empty_program_compilation () =
  let empty_program = "" in
  let result = compile_string quiet_options empty_program in
  check bool "空程序编译成功" true result;
  
  (* 测试只有空白字符的程序 *)
  let whitespace_program = "   \n\t  \n  " in
  let result2 = compile_string quiet_options whitespace_program in
  check bool "空白字符程序编译成功" true result2


let () = run "Compiler单元测试" [
  ("编译选项测试", [test_compile_options]);
  ("编译选项修改测试", [test_compile_options_modification]);
  ("简单编译测试", [test_simple_compilation]);
  ("编译选项效果测试", [test_compile_options_effect]);
  ("空程序编译测试", [test_empty_program_compilation]);
]