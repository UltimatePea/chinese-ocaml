(** 骆言编译器主程序测试 - 测试命令行参数解析和主要功能 *)

open Alcotest
open Yyocamlc_lib.Compile_options

(** 创建一个可重用的main模块接口，因为main.ml是一个程序而不是模块 *)
module Main_functions = struct
  (** 解析命令行参数的函数，从main.ml复制的逻辑 *)
  let rec parse_args arg_list options =
    match arg_list with
    | [] -> options
    | "-tokens" :: rest_args -> parse_args rest_args { options with show_tokens = true }
    | "-ast" :: rest_args -> parse_args rest_args { options with show_ast = true }
    | "-types" :: rest_args -> parse_args rest_args { options with show_types = true }
    | "-check" :: rest_args -> parse_args rest_args { options with check_only = true }
    | "-verbose" :: rest_args -> parse_args rest_args { options with log_level = "verbose" }
    | "-debug" :: rest_args -> parse_args rest_args { options with log_level = "debug" }
    | "-c" :: rest_args -> parse_args rest_args { options with compile_to_c = true }
    | "-o" :: output_file :: rest_args ->
        parse_args rest_args { options with c_output_file = Some output_file }
    | "-i" :: rest_args -> parse_args rest_args options
    | filename :: rest_args -> parse_args rest_args { options with filename = Some filename }

  (** 检查是否是帮助命令 *)
  let is_help_command args =
    List.mem "-h" args || List.mem "-help" args

  (** 检查是否是交互模式命令 *)
  let is_interactive_mode args =
    args = [] || List.mem "-i" args
end

(** 测试命令行参数解析 - 基本标志 *)
let test_parse_basic_flags () =
  let base_options = default_options in
  
  (* 测试单个标志 *)
  let tokens_opts = Main_functions.parse_args ["-tokens"] base_options in
  check bool "解析-tokens标志" true tokens_opts.show_tokens;
  
  let ast_opts = Main_functions.parse_args ["-ast"] base_options in
  check bool "解析-ast标志" true ast_opts.show_ast;
  
  let types_opts = Main_functions.parse_args ["-types"] base_options in
  check bool "解析-types标志" true types_opts.show_types;
  
  let check_opts = Main_functions.parse_args ["-check"] base_options in
  check bool "解析-check标志" true check_opts.check_only

(** 测试命令行参数解析 - 编译选项 *)
let test_parse_compile_options () =
  let base_options = default_options in
  
  (* 测试编译到C选项 *)
  let c_opts = Main_functions.parse_args ["-c"] base_options in
  check bool "解析-c标志" true c_opts.compile_to_c;
  
  (* 测试输出文件选项 *)
  let output_opts = Main_functions.parse_args ["-o"; "test.c"] base_options in
  check (option string) "解析-o选项" (Some "test.c") output_opts.c_output_file;
  
  (* 测试组合选项 *)
  let combined_opts = Main_functions.parse_args ["-c"; "-o"; "output.c"] base_options in
  check bool "组合选项-c有效" true combined_opts.compile_to_c;
  check (option string) "组合选项-o有效" (Some "output.c") combined_opts.c_output_file

(** 测试命令行参数解析 - 日志级别 *)
let test_parse_log_levels () =
  let base_options = default_options in
  
  let verbose_opts = Main_functions.parse_args ["-verbose"] base_options in
  check string "解析-verbose标志" "verbose" verbose_opts.log_level;
  
  let debug_opts = Main_functions.parse_args ["-debug"] base_options in
  check string "解析-debug标志" "debug" debug_opts.log_level

(** 测试命令行参数解析 - 文件名处理 *)
let test_parse_filename () =
  let base_options = default_options in
  
  (* 测试单个文件名 *)
  let file_opts = Main_functions.parse_args ["program.ly"] base_options in
  check (option string) "解析文件名" (Some "program.ly") file_opts.filename;
  
  (* 测试文件名与标志组合 *)
  let combined_opts = Main_functions.parse_args ["-tokens"; "test.ly"] base_options in
  check bool "组合解析标志正确" true combined_opts.show_tokens;
  check (option string) "组合解析文件名正确" (Some "test.ly") combined_opts.filename

(** 测试复杂命令行参数组合 *)
let test_parse_complex_args () =
  let base_options = default_options in
  
  (* 测试复杂组合：编译到C，显示AST，输出到特定文件 *)
  let complex_args = ["-ast"; "-c"; "-o"; "complex.c"; "input.ly"] in
  let opts = Main_functions.parse_args complex_args base_options in
  
  check bool "复杂组合-显示AST" true opts.show_ast;
  check bool "复杂组合-编译到C" true opts.compile_to_c;
  check (option string) "复杂组合-输出文件" (Some "complex.c") opts.c_output_file;
  check (option string) "复杂组合-输入文件" (Some "input.ly") opts.filename

(** 测试帮助命令识别 *)
let test_help_command_detection () =
  check bool "识别-h帮助命令" true (Main_functions.is_help_command ["-h"]);
  check bool "识别-help帮助命令" true (Main_functions.is_help_command ["-help"]);
  check bool "不误识别其他命令为帮助" false (Main_functions.is_help_command ["-tokens"]);
  check bool "组合命令中识别帮助" true (Main_functions.is_help_command ["-tokens"; "-h"; "file.ly"])

(** 测试交互模式检测 *)
let test_interactive_mode_detection () =
  check bool "空参数列表触发交互模式" true (Main_functions.is_interactive_mode []);
  check bool "-i标志触发交互模式" true (Main_functions.is_interactive_mode ["-i"]);
  check bool "有文件名不触发交互模式" false (Main_functions.is_interactive_mode ["file.ly"]);
  check bool "其他标志不触发交互模式" false (Main_functions.is_interactive_mode ["-tokens"])

(** 测试边界情况 *)
let test_edge_cases () =
  let base_options = default_options in
  
  (* 测试空参数列表 *)
  let empty_opts = Main_functions.parse_args [] base_options in
  check (option string) "空参数列表不设置文件名" None empty_opts.filename;
  
  (* 测试只有标志没有文件 *)
  let flags_only = Main_functions.parse_args ["-tokens"; "-ast"] base_options in
  check bool "标志解析正确-tokens" true flags_only.show_tokens;
  check bool "标志解析正确-ast" true flags_only.show_ast;
  check (option string) "只有标志时不设置文件名" None flags_only.filename

(** 测试参数解析错误恢复 *)
let test_argument_parsing_robustness () =
  let base_options = default_options in
  
  (* 测试未知参数作为文件名处理 *)
  let unknown_opts = Main_functions.parse_args ["--unknown-flag"] base_options in
  check (option string) "未知参数作为文件名" (Some "--unknown-flag") unknown_opts.filename;
  
  (* 测试多个文件名（最后一个有效） *)
  let multi_file_opts = Main_functions.parse_args ["file1.ly"; "file2.ly"] base_options in
  check (option string) "多文件名取最后一个" (Some "file2.ly") multi_file_opts.filename

(** 测试选项优先级和覆盖 *)
let test_option_precedence () =
  let base_options = default_options in
  
  (* 测试日志级别覆盖 *)
  let override_opts = Main_functions.parse_args ["-verbose"; "-debug"] base_options in
  check string "后设置的日志级别有效" "debug" override_opts.log_level;
  
  (* 测试输出文件覆盖 *)
  let output_override = Main_functions.parse_args ["-o"; "first.c"; "-o"; "second.c"] base_options in
  check (option string) "后设置的输出文件有效" (Some "second.c") output_override.c_output_file

(** 测试套件 *)
let () =
  run "骆言编译器主程序测试"
    [
      ( "命令行参数解析-基本功能",
        [
          test_case "解析基本标志" `Quick test_parse_basic_flags;
          test_case "解析编译选项" `Quick test_parse_compile_options;
          test_case "解析日志级别" `Quick test_parse_log_levels;
          test_case "解析文件名" `Quick test_parse_filename;
        ] );
      ( "命令行参数解析-复杂情况",
        [
          test_case "复杂参数组合" `Quick test_parse_complex_args;
          test_case "帮助命令检测" `Quick test_help_command_detection;
          test_case "交互模式检测" `Quick test_interactive_mode_detection;
        ] );
      ( "命令行参数解析-边界情况",
        [
          test_case "边界情况处理" `Quick test_edge_cases;
          test_case "参数解析健壮性" `Quick test_argument_parsing_robustness;
          test_case "选项优先级测试" `Quick test_option_precedence;
        ] );
    ]