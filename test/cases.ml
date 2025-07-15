(** 错误案例测试 - 确保错误能被正确检测 *)

open Alcotest
open Yyocamlc_lib

(** 读取文件内容 *)
let read_file filename =
  let ic = open_in filename in
  let content = really_input_string ic (in_channel_length ic) in
  close_in ic;
  content

(** 测试错误案例 *)
let test_error_case test_name source_file expected_error_file =
  let source_content = read_file source_file in
  let _expected_error = try String.trim (read_file expected_error_file) with _ -> "任何错误" in

  (* 使用非恢复模式确保错误被检测 *)
  let no_recovery_options = { Compiler.quiet_options with recovery_mode = false } in

  let result = Compiler.compile_string no_recovery_options source_content in

  check bool (test_name ^ " - 应该失败") false result

(** 测试所有错误案例 *)
let test_all_error_cases () =
  let test_files_path =
    let current_dir = Sys.getcwd () in
    let possible_paths =
      [
        "test_files/";
        "test/test_files/";
        "../../../test/test_files/";
        (* From _build/default/test to source test *)
        "../../test/test_files/";
        (* Alternative path *)
        current_dir ^ "/test_files/";
        current_dir ^ "/test/test_files/";
      ]
    in
    let rec find_path paths =
      match paths with
      | [] -> failwith ("Cannot find test files directory. Current dir: " ^ current_dir)
      | path :: rest ->
          if Sys.file_exists (path ^ "error_undefined_var.ly") then path else find_path rest
    in
    find_path possible_paths
  in

  let error_cases =
    [
      ( "未定义变量",
        test_files_path ^ "error_undefined_var.ly",
        test_files_path ^ "error_undefined_var.expected_error" );
      ( "类型不匹配",
        test_files_path ^ "error_type_mismatch.ly",
        test_files_path ^ "error_type_mismatch.expected_error" );
      ( "除零错误",
        test_files_path ^ "error_div_zero.ly",
        test_files_path ^ "error_div_zero.expected_error" );
    ]
  in

  List.iter (fun (name, source, expected) -> test_error_case name source expected) error_cases

(** 测试错误恢复案例 *)
let test_recovery_case test_name source_content expected_behavior =
  (* 使用恢复模式 *)
  let recovery_options = { Compiler.quiet_options with recovery_mode = true } in

  let result = Compiler.compile_string recovery_options source_content in

  check bool (test_name ^ " - " ^ expected_behavior) true result

(** 测试错误恢复功能 *)
let test_error_recovery_cases () =
  let recovery_cases =
    [
      ("字符串转数字恢复", "让 「x」 为 一二三\n让 「y」 为 「x」 加 一\n「打印」 「y」", "应该成功执行");
      ("类型不匹配恢复", "让 「x」 为 一二三\n让 「y」 为 二\n让 「z」 为 「y」 加 「x」\n「打印」 「z」", "应该成功执行");
    ]
  in

  List.iter (fun (name, source, expected) -> test_recovery_case name source expected) recovery_cases

(** 测试套件 *)
let () =
  run "错误案例测试"
    [
      ("错误检测", [ test_case "所有错误案例" `Quick test_all_error_cases ]);
      ("错误恢复", [ test_case "恢复案例" `Quick test_error_recovery_cases ]);
    ]

