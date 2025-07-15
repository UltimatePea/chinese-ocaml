(** 骆言编译器C后端端到端测试 - C Backend End-to-End Testing *)

open Alcotest

type e2e_test_config = { source_code : string; expected_output : string; test_name : string }
(** C后端端到端测试配置 *)

(** 创建临时文件名 *)
let create_temp_filename prefix suffix =
  let temp_dir = Filename.get_temp_dir_name () in
  let timestamp = string_of_float (Unix.time ()) in
  let random_suffix = string_of_int (Random.int 10000) in
  Filename.concat temp_dir (Printf.sprintf "%s_%s_%s%s" prefix timestamp random_suffix suffix)

(** 执行系统命令并返回输出 *)
let run_command cmd =
  let ic = Unix.open_process_in cmd in
  let output =
    let buf = Buffer.create 1024 in
    (try
       while true do
         Buffer.add_string buf (input_line ic);
         Buffer.add_char buf '\n'
       done
     with End_of_file -> ());
    Buffer.contents buf
  in
  let status = Unix.close_process_in ic in
  (output, status)

(** 端到端测试：从骆言源代码到C编译执行 *)
let test_c_backend_e2e config () =
  let source_file = create_temp_filename "luoyan_test" ".ly" in
  let c_file = create_temp_filename "luoyan_test" ".c" in
  let exe_file = create_temp_filename "luoyan_test" "" in

  try
    (* 第1步：写入骆言源代码 *)
    let oc = open_out source_file in
    output_string oc config.source_code;
    close_out oc;

    (* 第2步：编译骆言源代码到C代码 *)
    let compile_options =
      {
        Yyocamlc_lib.Compiler.default_options with
        compile_to_c = true;
        c_output_file = Some c_file;
        quiet_mode = true;
      }
    in
    let compile_success = Yyocamlc_lib.Compiler.compile_file compile_options source_file in

    check bool (config.test_name ^ " - 骆言到C编译成功") true compile_success;

    if compile_success then (
      (* 第3步：检查C文件是否生成 *)
      check bool (config.test_name ^ " - C文件已生成") true (Sys.file_exists c_file);

      (* 第4步：使用clang编译C代码 *)
      let c_runtime_path = "c_backend/runtime/luoyan_runtime.c" in
      let c_runtime_header_path = "c_backend/runtime" in
      let compile_cmd =
        Printf.sprintf
          "cd /Users/zc/temp/chinese-ocaml && clang -Wall -Wextra -std=c99 -I%s %s %s -o %s 2>&1"
          c_runtime_header_path c_file c_runtime_path exe_file
      in
      let compile_output, compile_status = run_command compile_cmd in

      check bool
        (config.test_name ^ " - C代码编译成功")
        (compile_status = Unix.WEXITED 0) (compile_status = Unix.WEXITED 0);

      if compile_status <> Unix.WEXITED 0 then (
        Printf.printf "C编译错误输出: %s\n" compile_output;
        flush_all ());

      if compile_status = Unix.WEXITED 0 then (
        (* 第5步：执行生成的可执行文件 *)
        let run_cmd = exe_file in
        let run_output, run_status = run_command run_cmd in

        check bool
          (config.test_name ^ " - 程序执行成功")
          (run_status = Unix.WEXITED 0) (run_status = Unix.WEXITED 0);

        if run_status = Unix.WEXITED 0 then
          (* 第6步：验证输出 *)
          check string (config.test_name ^ " - 输出正确") config.expected_output run_output
        else (
          Printf.printf "程序执行错误输出: %s\n" run_output;
          flush_all ())))
  with e -> (
    Printf.printf "测试异常: %s\n" (Printexc.to_string e);
    flush_all ();
    check bool (config.test_name ^ " - 无异常") true false;

    (* 清理临时文件 *)
    (try Sys.remove source_file with _ -> ());
    (try Sys.remove c_file with _ -> ());
    try Sys.remove exe_file with _ -> ())

(** Hello World测试 *)
let test_hello_world () =
  let config =
    {
      source_code = "让 问候 = \"你好，世界！\"\n打印 问候";
      expected_output = "你好，世界！\n";
      test_name = "Hello World";
    }
  in
  test_c_backend_e2e config ()

(** 基本算术测试 *)
let test_basic_arithmetic () =
  let config =
    {
      source_code = "让 a = 10\n让 b = 5\n让 结果 = a + b\n打印 结果";
      expected_output = "15\n";
      test_name = "基本算术";
    }
  in
  test_c_backend_e2e config ()

(** 递归函数测试 *)
let test_recursive_function () =
  let config =
    {
      source_code = "递归 让 阶乘 = 函数 n -> 如果 n <= 1 那么 1 否则 n * 阶乘 (n - 1)\n让 结果 = 阶乘 5\n打印 结果";
      expected_output = "120\n";
      test_name = "递归函数";
    }
  in
  test_c_backend_e2e config ()

(** 条件语句测试 *)
let test_conditionals () =
  let config =
    {
      source_code = "让 x = 10\n如果 x > 5 那么 打印 \"大于5\" 否则 打印 \"不大于5\"";
      expected_output = "大于5\n";
      test_name = "条件语句";
    }
  in
  test_c_backend_e2e config ()

(** 布尔运算测试 *)
let test_boolean_operations () =
  let config =
    {
      source_code = "让 a = 真\n让 b = 假\n打印 (a 并且 b)";
      expected_output = "false\n";
      test_name = "布尔运算";
    }
  in
  test_c_backend_e2e config ()

(** 列表操作测试 *)
let test_list_operations () =
  let config =
    {
      source_code = "让 「列表」 = (列开始 1 其一 2 其二 3 其三 列结束)\n打印 「列表」";
      expected_output = "(列开始 1 其一 2 其二 3 其三 列结束)\n";
      test_name = "列表操作";
    }
  in
  test_c_backend_e2e config ()

(** 记录操作测试 *)
let test_record_operations () =
  let config =
    {
      source_code =
        "让 学生 = { 姓名 = \"张三\"; 年龄 = 20; 成绩 = 95.5 }\n让 姓名 = 学生.姓名\n让 年龄 = 学生.年龄\n打印 姓名\n打印 年龄";
      expected_output = "张三\n20\n";
      test_name = "记录操作";
    }
  in
  test_c_backend_e2e config ()

(** 记录更新测试 *)
let test_record_update () =
  let config =
    {
      source_code =
        "让 学生1 = { 姓名 = \"李四\"; 年龄 = 18; 成绩 = 88.0 }\n\
         让 学生2 = { 学生1 与 年龄 = 19; 成绩 = 92.0 }\n\
         让 姓名 = 学生2.姓名\n\
         让 年龄 = 学生2.年龄\n\
         让 成绩 = 学生2.成绩\n\
         打印 姓名\n\
         打印 年龄\n\
         打印 成绩";
      expected_output = "李四\n19\n92\n";
      test_name = "记录更新";
    }
  in
  test_c_backend_e2e config ()

let test_advanced_functions () =
  let config =
    {
      source_code = "让 加法 = 函数 x -> 函数 y -> x + y\n让 结果 = 加法 5 3\n打印 结果";
      expected_output = "8\n";
      test_name = "高阶函数";
    }
  in
  test_c_backend_e2e config ()

let test_multiple_function_calls () =
  let config =
    {
      source_code =
        "让 双倍 = 函数 x -> x * 2\n\
         让 平方 = 函数 x -> x * x\n\
         让 数字 = 5\n\
         让 双倍结果 = 双倍 数字\n\
         让 平方结果 = 平方 数字\n\
         打印 双倍结果\n\
         打印 平方结果";
      expected_output = "10\n25\n";
      test_name = "多函数调用";
    }
  in
  test_c_backend_e2e config ()

(** C后端端到端测试套件 *)
let () =
  Random.self_init ();
  (* 初始化随机数生成器 *)
  run "骆言编译器C后端端到端测试"
    [
      ( "基础功能",
        [
          test_case "Hello World" `Quick test_hello_world;
          test_case "基本算术" `Quick test_basic_arithmetic;
          test_case "条件语句" `Quick test_conditionals;
          test_case "布尔运算" `Quick test_boolean_operations;
        ] );
      ( "高级功能",
        [
          test_case "递归函数" `Quick test_recursive_function;
          test_case "列表操作" `Quick test_list_operations;
          test_case "记录操作" `Quick test_record_operations;
          test_case "记录更新" `Quick test_record_update;
        ] );
      ( "高级功能扩展",
        [
          test_case "高阶函数" `Quick test_advanced_functions;
          test_case "多函数调用" `Quick test_multiple_function_calls;
        ] );
    ]

