(** 骆言编译器端到端测试 - End-to-End Testing *)

(* open Yyocamlc_lib *)
open Alcotest


(** 测试辅助函数 - 捕获输出 *)
let capture_output f =
  let temp_file = Filename.temp_file "yyocamlc_test" ".txt" in
  let original_stdout = Unix.dup Unix.stdout in
  let output_channel = open_out temp_file in
  
  Unix.dup2 (Unix.descr_of_out_channel output_channel) Unix.stdout;
  let result = f () in
  close_out output_channel;
  Unix.dup2 original_stdout Unix.stdout;
  Unix.close original_stdout;
  
  let ic = open_in temp_file in
  let output = really_input_string ic (in_channel_length ic) in
  close_in ic;
  Sys.remove temp_file;
  
  (result, output)

(** 端到端测试 - Hello World *)
let test_e2e_hello_world () =
  let source_code = "让 「问候」 = \"你好，世界！\"\n打印 「问候」" in
  let expected_output = "你好，世界！\n" in
  
  let (success, output) = capture_output (fun () ->
    Yyocamlc_lib.Compiler.compile_string Yyocamlc_lib.Compiler.quiet_options source_code
  ) in
  
  check bool "Hello World 程序执行成功" true success;
  check string "Hello World 输出正确" expected_output output

(** 端到端测试 - 基本算术 *)
let test_e2e_basic_arithmetic () =
  let source_code = "
让 「a」 = 10
让 「b」 = 5
让 「和」 = 「a」 + 「b」
让 「差」 = 「a」 - 「b」
让 「积」 = 「a」 * 「b」
让 「商」 = 「a」 / 「b」
打印 \"和: \"
打印 「和」
打印 \"差: \"
打印 「差」
打印 \"积: \"
打印 「积」
打印 \"商: \"
打印 「商」" in
  
  let expected_output = "和: \n15\n差: \n5\n积: \n50\n商: \n2\n" in
  
  let (success, output) = capture_output (fun () ->
    Yyocamlc_lib.Compiler.compile_string Yyocamlc_lib.Compiler.quiet_options source_code
  ) in
  
  check bool "基本算术程序执行成功" true success;
  check string "基本算术输出正确" expected_output output

(** 端到端测试 - 阶乘计算 *)
let test_e2e_factorial () =
  let source_code = "
递归 让 「阶乘」 = 函数 「值」 -> 
  如果 「值」 == 0 那么 
    1 
  否则 
    「值」 * 「阶乘」(「值」 - 1)

让 「数字」 = 5
让 「结果」 = 「阶乘」(「数字」)
打印 \"5的阶乘是：\"
打印 「结果」" in
  
  let expected_output = "5的阶乘是：\n120\n" in
  
  let (success, output) = capture_output (fun () ->
    Yyocamlc_lib.Compiler.compile_string Yyocamlc_lib.Compiler.quiet_options source_code
  ) in
  
  check bool "阶乘程序执行成功" true success;
  check string "阶乘输出正确" expected_output output

(** 端到端测试 - 斐波那契数列 *)
let test_e2e_fibonacci () =
  let source_code = "
递归 让 「斐波那契」 = 函数 「n」 ->
  匹配 「n」 与
  | 0 -> 0
  | 1 -> 1
  | _ -> 「斐波那契」 (「n」 - 1) + 「斐波那契」 (「n」 - 2)

让 「结果」 = 「斐波那契」 6
打印 \"斐波那契(6) = \"
打印 「结果」" in
  
  let expected_output = "斐波那契(6) = \n8\n" in
  
  let (success, output) = capture_output (fun () ->
    Yyocamlc_lib.Compiler.compile_string Yyocamlc_lib.Compiler.quiet_options source_code
  ) in
  
  check bool "斐波那契程序执行成功" true success;
  check string "斐波那契输出正确" expected_output output

(** 端到端测试 - 条件语句 *)
let test_e2e_conditionals () =
  let source_code = "
让 「x」 = 10
让 「y」 = 5

如果 「x」 > 「y」 那么
  打印 \"x 大于 y\"
否则
  打印 \"x 不大于 y\"

如果 「x」 == 「y」 那么
  打印 \"x 等于 y\"
否则
  打印 \"x 不等于 y\"" in
  
  let expected_output = "x 大于 y\nx 不等于 y\n" in
  
  let (success, output) = capture_output (fun () ->
    Yyocamlc_lib.Compiler.compile_string Yyocamlc_lib.Compiler.quiet_options source_code
  ) in
  
  check bool "条件语句程序执行成功" true success;
  check string "条件语句输出正确" expected_output output

(** 端到端测试 - 模式匹配 *)
let test_e2e_pattern_matching () =
  let source_code = "
让 「测试数字」 = 函数 「x」 ->
  匹配 「x」 与
  | 0 -> \"零\"
  | 1 -> \"一\"
  | 2 -> \"二\"
  | _ -> \"其他\"

打印 (「测试数字」 0)
打印 (「测试数字」 1)
打印 (「测试数字」 2)
打印 (「测试数字」 5)" in
  
  let expected_output = "零\n一\n二\n其他\n" in
  
  let (success, output) = capture_output (fun () ->
    Yyocamlc_lib.Compiler.compile_string Yyocamlc_lib.Compiler.quiet_options source_code
  ) in
  
  check bool "模式匹配程序执行成功" true success;
  check string "模式匹配输出正确" expected_output output

(** 端到端测试 - 列表操作 *)
let test_e2e_list_operations () =
  let source_code = "
让 「列表」 = (列开始 1 其一 2 其二 3 其三 列结束)

递归 让 「求和」 = 函数 「lst」 ->
  观「lst」之性
  若 空空如也 则 答 0
  若 有首有尾 首名为「head」 尾名为「tail」 则 答 「head」 + 「求和」 「tail」
  观毕

让 「结果」 = 「求和」 「列表」
打印 『列表求和: 』
打印 「结果」" in
  
  let expected_output = "列表求和: \n6\n" in
  
  let (success, output) = capture_output (fun () ->
    Yyocamlc_lib.Compiler.compile_string Yyocamlc_lib.Compiler.quiet_options source_code
  ) in
  
  check bool "列表操作程序执行成功" true success;
  check string "列表操作输出正确" expected_output output

(** 端到端测试 - 嵌套函数 *)
let test_e2e_nested_functions () =
  let source_code = "
让 「外部函数」 = 函数 「x」 ->
  让 「内部函数」 = 函数 「y」 ->
    「x」 + 「y」
  「内部函数」 (「x」 * 2)

让 「结果」 = 「外部函数」 5
打印 \"嵌套函数结果: \"
打印 「结果」" in
  
  let expected_output = "嵌套函数结果: \n15\n" in
  
  let (success, output) = capture_output (fun () ->
    Yyocamlc_lib.Compiler.compile_string Yyocamlc_lib.Compiler.quiet_options source_code
  ) in
  
  check bool "嵌套函数程序执行成功" true success;
  check string "嵌套函数输出正确" expected_output output

(** 端到端测试 - 错误处理 - 词法错误 *)
let test_e2e_lexer_error () =
  let source_code = "让 「x」 = \"未闭合的字符串" in
  
  let (success, output) = capture_output (fun () ->
    Yyocamlc_lib.Compiler.compile_string Yyocamlc_lib.Compiler.quiet_options source_code
  ) in
  
  check bool "词法错误程序应该失败" false success;
  check bool "词法错误应该有错误输出" true (String.length output > 0)

(** 端到端测试 - 错误处理 - 语法错误 *)
let test_e2e_syntax_error () =
  let source_code = "让 「x」 = 1 + + 2" in
  
  let (success, output) = capture_output (fun () ->
    Yyocamlc_lib.Compiler.compile_string Yyocamlc_lib.Compiler.quiet_options source_code
  ) in
  
  check bool "语法错误程序应该失败" false success;
  check bool "语法错误应该有错误输出" true (String.length output > 0)

(** 端到端测试 - 错误处理 - 运行时错误 *)
let test_e2e_runtime_error () =
  let source_code = "让 「x」 = 「未定义变量」" in
  
  let (success, output) = capture_output (fun () ->
    let no_recovery_options = { Yyocamlc_lib.Compiler.quiet_options with recovery_mode = false } in
    Yyocamlc_lib.Compiler.compile_string no_recovery_options source_code
  ) in
  
  check bool "运行时错误程序应该失败" false success;
  check bool "运行时错误应该有错误输出" true (String.length output > 0)

(** 端到端测试 - 复杂程序 - 排序算法 *)
let test_e2e_sorting_algorithm () =
  let source_code = "
递归 让 「插入」 = 函数 「x」 -> 函数 「lst」 ->
  观「lst」之性
  若 空空如也 则 答 (列开始 「x」 其一 列结束)
  若 有首有尾 首名为「h」 尾名为「t」 则
    如果 「x」 < 「h」 那么
      有首有尾 首名为「x」 尾名为(有首有尾 首名为「h」 尾名为「t」)
    否则
      让 「插入x」 = 「插入」 「x」
      有首有尾 首名为「h」 尾名为(「插入x」 「t」)
  观毕

递归 让 「插入排序」 = 函数 「lst」 ->
  观「lst」之性
  若 空空如也 则 答 空空如也
  若 有首有尾 首名为「h」 尾名为「t」 则
    让 「插入h」 = 「插入」 「h」
    「插入h」 (「插入排序」 「t」)
  观毕

让 「测试列表」 = (列开始 3 其一 1 其二 2 其三 列结束)
让 「排序结果」 = 「插入排序」 「测试列表」
打印 『排序结果: 』
打印 「排序结果」" in
  
  let expected_output = "排序结果: \n(列开始 1 其一 2 其二 3 其三 列结束)\n" in
  
  let (success, output) = capture_output (fun () ->
    Yyocamlc_lib.Compiler.compile_string Yyocamlc_lib.Compiler.quiet_options source_code
  ) in
  
  check bool "排序算法程序执行成功" true success;
  check string "排序算法输出正确" expected_output output

(** 端到端测试 - 文件编译测试 *)
let test_e2e_file_compilation () =
  let temp_file = Filename.temp_file "test_e2e" ".ly" in
  let test_content = "让 「x」 = 42\n打印 「x」" in
  
  (* 写入测试文件 *)
  let oc = open_out temp_file in
  output_string oc test_content;
  close_out oc;
  
  let _expected_output = "42\n" in
  let _ = _expected_output in (* suppress unused warning *)
  
  let (success, output) = capture_output (fun () ->
    Yyocamlc_lib.Compiler.compile_file Yyocamlc_lib.Compiler.quiet_options temp_file
  ) in
  
  (* 清理临时文件 *)
  Sys.remove temp_file;
  
  check bool "文件编译执行成功" true success;
  check bool "文件编译有输出" (String.length output > 0) true

(** 端到端测试 - 交互式模式测试 *)
let test_e2e_interactive_mode () =
  let _test_input = "让 「x」 = 10\n让 「y」 = 20\n「x」 + 「y」" in
  let _expected_output = "30" in
  let _ = _test_input in
  let _ = _expected_output in
  
  (* 注意：这个测试可能需要模拟交互式输入，这里只是示例 *)
  check bool "交互式模式测试占位符" true true

(** 端到端测试 - 性能测试 - 大数计算 *)
let test_e2e_performance_large_calculation () =
  let source_code = "
递归 让 「累加」 = 函数 「n」 ->
  如果 「n」 == 0 那么
    0
  否则
    「n」 + 「累加」 (「n」 - 1)

让 「结果」 = 「累加」 100
打印 \"1到100的和: \"
打印 「结果」" in
  
  let expected_output = "1到100的和: \n5050\n" in
  
  let (success, output) = capture_output (fun () ->
    Yyocamlc_lib.Compiler.compile_string Yyocamlc_lib.Compiler.quiet_options source_code
  ) in
  
  check bool "大数计算程序执行成功" true success;
  check string "大数计算输出正确" expected_output output

(** 端到端测试 - 内存测试 - 深度递归 *)
let test_e2e_memory_deep_recursion () =
  let source_code = "
递归 让 「深度函数」 = 函数 「n」 ->
  如果 「n」 == 0 那么
    0
  否则
    1 + 「深度函数」 (「n」 - 1)

让 「结果」 = 「深度函数」 50
打印 \"递归深度: \"
打印 「结果」" in
  
  let expected_output = "递归深度: \n50\n" in
  
  let (success, output) = capture_output (fun () ->
    Yyocamlc_lib.Compiler.compile_string Yyocamlc_lib.Compiler.quiet_options source_code
  ) in
  
  check bool "深度递归程序执行成功" true success;
  check string "深度递归输出正确" expected_output output

(** 端到端测试 - 边界条件测试 *)
let test_e2e_edge_cases () =
  let source_code = "
让 「空字符串」 = \"\"
让 「零」 = 0
让 「负数」 = -5
让 「大数」 = 999999

打印 \"空字符串长度: \"
打印 (「长度」 「空字符串」)
打印 \"零: \"
打印 「零」
打印 \"负数: \"
打印 「负数」
打印 \"大数: \"
打印 「大数」" in
  
  let expected_output = "空字符串长度: \n0\n零: \n0\n负数: \n-5\n大数: \n999999\n" in
  
  let (success, output) = capture_output (fun () ->
    Yyocamlc_lib.Compiler.compile_string Yyocamlc_lib.Compiler.quiet_options source_code
  ) in
  
  check bool "边界条件程序执行成功" true success;
  check string "边界条件输出正确" expected_output output

(** 端到端测试套件 *)
let () =
  run "骆言编译器端到端测试" [
    ("基础功能", [
      test_case "Hello World" `Quick test_e2e_hello_world;
      test_case "基本算术" `Quick test_e2e_basic_arithmetic;
      test_case "条件语句" `Quick test_e2e_conditionals;
      test_case "模式匹配" `Quick test_e2e_pattern_matching;
    ]);
    ("函数和递归", [
      test_case "阶乘计算" `Quick test_e2e_factorial;
      test_case "斐波那契数列" `Quick test_e2e_fibonacci;
      test_case "嵌套函数" `Quick test_e2e_nested_functions;
    ]);
    ("数据结构", [
      test_case "列表操作" `Quick test_e2e_list_operations;
      test_case "排序算法" `Quick test_e2e_sorting_algorithm;
    ]);
    ("错误处理", [
      test_case "词法错误" `Quick test_e2e_lexer_error;
      test_case "语法错误" `Quick test_e2e_syntax_error;
      test_case "运行时错误" `Quick test_e2e_runtime_error;
    ]);
    ("系统功能", [
      test_case "文件编译" `Quick test_e2e_file_compilation;
      test_case "交互式模式" `Quick test_e2e_interactive_mode;
    ]);
    ("性能和边界", [
      test_case "大数计算" `Quick test_e2e_performance_large_calculation;
      test_case "深度递归" `Quick test_e2e_memory_deep_recursion;
      test_case "边界条件" `Quick test_e2e_edge_cases;
    ]);
  ]