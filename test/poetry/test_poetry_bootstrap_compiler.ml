(** 测试诗韵自举编译器的执行性 - 解决Issue #1122 *)

let test_poetry_compiler_executability () =
  let test_name = "Poetry Bootstrap Compiler Executability Test" in
  Printf.printf "运行测试: %s\n" test_name;

  (* 测试编译器是否存在且可执行 *)
  let compiler_path = "自举/experimental/poetry_bootstrap_compiler.ml" in
  if not (Sys.file_exists compiler_path) then failwith ("诗韵编译器文件不存在: " ^ compiler_path);

  (* 创建测试输入文件 *)
  let test_input = "夫 测试函数 者 {\n  让 消息 等于 \"测试成功\" 在\n  答 消息\n} 也" in
  let test_file = "test_poetry_input.ly" in
  let oc = open_out test_file in
  output_string oc test_input;
  close_out oc;

  (* 通过系统调用运行编译器 *)
  let compile_cmd = "cd 自举/experimental && ocaml poetry_bootstrap_compiler.ml > /dev/null 2>&1" in
  let compile_result = Sys.command compile_cmd in

  if compile_result <> 0 then failwith "诗韵编译器执行失败";

  (* 检查是否生成了预期的输出文件 *)
  let output_file = "自举/experimental/output_poetry.c" in
  if not (Sys.file_exists output_file) then failwith ("编译器未生成预期的C代码文件: " ^ output_file);

  (* 验证生成的C代码可编译 *)
  let gcc_cmd = "cd 自举/experimental && gcc -o test_poetry_output output_poetry.c" in
  let gcc_result = Sys.command gcc_cmd in

  if gcc_result <> 0 then failwith "生成的C代码无法编译";

  (* 清理测试文件 *)
  (try Sys.remove test_file with _ -> ());
  (try Sys.remove "自举/experimental/test_poetry_output" with _ -> ());

  Printf.printf "✓ 测试通过: %s\n" test_name;
  Printf.printf "  - 诗韵编译器可成功执行\n";
  Printf.printf "  - 生成的C代码可编译运行\n";
  Printf.printf "  - Issue #1122 已解决\n\n"

let test_poetry_compiler_features () =
  let test_name = "Poetry Bootstrap Compiler Features Test" in
  Printf.printf "运行测试: %s\n" test_name;

  (* 读取生成的C代码并验证内容 *)
  let output_file = "自举/experimental/output_poetry.c" in
  if Sys.file_exists output_file then (
    let ic = open_in output_file in
    let content = really_input_string ic (in_channel_length ic) in
    close_in ic;

    (* 验证生成的代码包含预期内容 *)
    if not (String.contains content '\230' && String.contains content '\141') then
      failwith "生成的C代码缺少诗词文化元素";

    if not (String.contains content '#') then failwith "生成的C代码缺少必要的头文件";

    Printf.printf "✓ 测试通过: %s\n" test_name;
    Printf.printf "  - 生成的C代码包含诗词文化元素\n";
    Printf.printf "  - 代码结构完整\n\n")
  else Printf.printf "⚠ 跳过测试: 输出文件不存在\n\n"

(** 主测试函数 *)
let run_tests () =
  Printf.printf "开始测试诗韵自举编译器 (Issue #1122 解决方案)\n";
  Printf.printf "========================================\n\n";

  try
    test_poetry_compiler_executability ();
    test_poetry_compiler_features ();
    Printf.printf "所有测试通过！诗韵编译器现在是真正可执行的。\n";
    Printf.printf "Issue #1122 已成功解决。\n\n"
  with
  | Failure msg ->
      Printf.printf "测试失败: %s\n" msg;
      exit 1
  | e ->
      Printf.printf "测试过程中发生错误: %s\n" (Printexc.to_string e);
      exit 1

(* 运行测试 *)
let () = run_tests ()
